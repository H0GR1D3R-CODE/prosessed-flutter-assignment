import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/theme/orb_tints.dart';
import 'package:shopsphere/core/theme/spacing.dart';
import 'package:shopsphere/features/discover/domain/discover.dart';
import 'package:shopsphere/features/discover/presentation/bloc/discover_cubits.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/presentation/bloc/categories_cubit.dart';
import 'package:shopsphere/features/products/presentation/bloc/product_list_cubit.dart';
import 'package:shopsphere/l10n/l10n.dart';

enum SuggestionKind { recent, category }

/// One line in the suggestions: something searched before, or a category that matches.
@immutable
class SearchSuggestion {
  const SearchSuggestion.recent(this.text)
    : kind = SuggestionKind.recent,
      slug = null;

  const SearchSuggestion.category(this.text, String this.slug)
    : kind = SuggestionKind.category;

  final SuggestionKind kind;

  /// The search word, or the category's name.
  final String text;
  final String? slug;

  bool get isRecent => kind == SuggestionKind.recent;

  @override
  bool operator ==(Object other) =>
      other is SearchSuggestion && other.kind == kind && other.text == text;

  @override
  int get hashCode => Object.hash(kind, text);
}

/// The shop's search field: it offers recent searches when it gains focus, narrows them (and
/// matching categories) as you type, and can be reached from the keyboard.
class SearchBox extends StatefulWidget {
  const SearchBox({
    required this.controller,
    required this.focusNode,
    required this.height,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final double height;

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  /// Set when a suggestion was chosen, so pressing Enter on it is not also a plain submit.
  bool _chose = false;

  List<SearchSuggestion> _suggestions(String typed) {
    final history = context.read<SearchHistoryCubit>().state.terms;
    final recents = SearchHistory.matching(history, typed);
    final query = typed.trim().toLowerCase();
    final categories = context.read<CategoriesCubit>().state;
    final matching = query.length < 2 || categories is! CategoriesLoaded
        ? const <ProductCategory>[]
        : categories.categories
              .where((c) => c.name.toLowerCase().contains(query))
              .take(3)
              .toList();
    return [
      for (final term in recents) SearchSuggestion.recent(term),
      for (final category in matching)
        SearchSuggestion.category(category.name, category.slug),
    ];
  }

  void _onSelected(SearchSuggestion suggestion) {
    _chose = true;
    final products = context.read<ProductListCubit>();
    if (suggestion.isRecent) {
      products.searchSubmitted(suggestion.text);
      context.read<SearchHistoryCubit>().record(suggestion.text);
    } else {
      products.selectCategory(suggestion.slug);
    }
    widget.focusNode.unfocus();
  }

  void _submit(String text, VoidCallback pickHighlighted) {
    // RawAutocomplete picks the highlighted suggestion, if there is one.
    pickHighlighted();
    if (_chose) {
      _chose = false;
      return;
    }
    context.read<ProductListCubit>().searchSubmitted(text);
    context.read<SearchHistoryCubit>().record(text);
    widget.focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final products = context.read<ProductListCubit>();
    return LayoutBuilder(
      builder: (context, constraints) => RawAutocomplete<SearchSuggestion>(
        textEditingController: widget.controller,
        focusNode: widget.focusNode,
        displayStringForOption: (s) => s.isRecent ? s.text : '',
        optionsBuilder: (value) => _suggestions(value.text),
        onSelected: _onSelected,
        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
          return ListenableBuilder(
            listenable: Listenable.merge([controller, focusNode]),
            builder: (context, _) => SizedBox(
              height: widget.height,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textInputAction: TextInputAction.search,
                onChanged: products.searchChanged,
                onSubmitted: (text) => _submit(text, onFieldSubmitted),
                decoration: InputDecoration(
                  hintText: l10n.shopSearchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  contentPadding: const EdgeInsets.symmetric(horizontal: Gap.l),
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                          tooltip: l10n.shopClearSearch,
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            controller.clear();
                            products.clearSearch();
                          },
                        )
                      : (_hasPhysicalKeyboard && !focusNode.hasFocus)
                      ? Tooltip(
                          message: l10n.searchShortcutHint,
                          child: const _KeyHint(label: '/'),
                        )
                      : null,
                ),
              ),
            ),
          );
        },
        optionsViewBuilder: (context, onSelected, options) => _Suggestions(
          options: options.toList(),
          maxWidth: constraints.maxWidth,
          showingRecents: widget.controller.text.trim().isEmpty,
          onSelected: onSelected,
        ),
      ),
    );
  }

  /// Phones have a touch keyboard, so the "/" shortcut is only worth advertising elsewhere.
  bool get _hasPhysicalKeyboard =>
      kIsWeb ||
      const {
        TargetPlatform.windows,
        TargetPlatform.macOS,
        TargetPlatform.linux,
      }.contains(defaultTargetPlatform);
}

/// A small keycap, to say "press this key".
class _KeyHint extends StatelessWidget {
  const _KeyHint({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      widthFactor: 1,
      child: Padding(
        padding: const EdgeInsets.only(right: Gap.m),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            child: Text(
              label,
              style: context.text.labelLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The dropdown under the search field.
class _Suggestions extends StatelessWidget {
  const _Suggestions({
    required this.options,
    required this.maxWidth,
    required this.showingRecents,
    required this.onSelected,
  });

  final List<SearchSuggestion> options;
  final double maxWidth;
  final bool showingRecents;
  final AutocompleteOnSelected<SearchSuggestion> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final highlighted = AutocompleteHighlightedOption.of(context);
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Material(
          elevation: 8,
          shadowColor: colors.shadow.withValues(alpha: 0.25),
          color: colors.surfaceContainerLowest,
          borderRadius: Radii.brL,
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: 380),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: Gap.xs),
              children: [
                if (showingRecents)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Gap.l,
                      Gap.xs,
                      Gap.xs,
                      0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.searchRecent,
                            style: context.text.labelLarge?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              context.read<SearchHistoryCubit>().clear(),
                          child: Text(l10n.searchClearAll),
                        ),
                      ],
                    ),
                  ),
                for (var i = 0; i < options.length; i++)
                  _SuggestionRow(
                    suggestion: options[i],
                    highlighted: i == highlighted,
                    onTap: () => onSelected(options[i]),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({
    required this.suggestion,
    required this.highlighted,
    required this.onTap,
  });

  final SearchSuggestion suggestion;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final isRecent = suggestion.isRecent;
    return Semantics(
      button: true,
      label: isRecent
          ? suggestion.text
          : l10n.searchCategorySuggestion(suggestion.text),
      excludeSemantics: true,
      child: Material(
        color: highlighted ? colors.surfaceContainerHigh : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.only(left: Gap.l),
              child: Row(
                children: [
                  Icon(
                    isRecent
                        ? Icons.history_rounded
                        : CategoryIcons.of(suggestion.slug ?? ''),
                    size: 20,
                    color: colors.onSurfaceVariant,
                  ),
                  Gap.wm,
                  Expanded(
                    child: Text(
                      isRecent
                          ? suggestion.text
                          : l10n.searchCategorySuggestion(suggestion.text),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodyLarge,
                    ),
                  ),
                  if (isRecent)
                    IconButton(
                      tooltip: l10n.searchForget(suggestion.text),
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () => context
                          .read<SearchHistoryCubit>()
                          .forget(suggestion.text),
                    )
                  else
                    const SizedBox(width: Gap.l),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
