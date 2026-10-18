import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/l10n/l10n.dart';

/// A photo from the network that copes with a bad moment instead of showing a broken image.
///
/// * It tries again by itself (twice, a little later each time), because the first request often
///   fails only because many photos were asked for at once.
/// * If it still fails it shows a quiet tile with [fallbackIcon] that reloads when tapped.
/// * On the web the browser's own `<img>` is used as a fallback when a cross-origin fetch is
///   refused, which is the usual reason photos fail there.
/// * On phones it uses the disk cache from `cached_network_image`.
class NetworkPhoto extends StatefulWidget {
  const NetworkPhoto({
    required this.url,
    this.fit = BoxFit.contain,
    this.fallbackIcon = Icons.image_outlined,
    this.memCacheWidth,
    this.fadeIn = const Duration(milliseconds: 220),
    this.placeholder,
    this.fallback,
    super.key,
  });

  final String url;
  final BoxFit fit;

  /// Shown when the photo cannot be loaded; a hint of what the photo would have been.
  final IconData fallbackIcon;

  /// Decode the photo no wider than this, to save memory on long lists.
  final int? memCacheWidth;
  final Duration fadeIn;

  /// Shown while the photo loads; empty by default.
  final Widget? placeholder;

  /// Replaces the reload tile when the photo cannot be loaded (an avatar shows initials).
  final Widget? fallback;

  /// Lets a test supply what the photo loads from (the real loaders need a network).
  @visibleForTesting
  static ImageProvider Function(String url)? imageProviderForTesting;

  @override
  State<NetworkPhoto> createState() => _NetworkPhotoState();
}

class _NetworkPhotoState extends State<NetworkPhoto> {
  static const List<Duration> _retryDelays = [
    Duration(milliseconds: 1200),
    Duration(milliseconds: 3000),
  ];

  int _attempt = 0;
  bool _failed = false;
  bool _retryQueued = false;
  Timer? _timer;

  @override
  void didUpdateWidget(NetworkPhoto oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) _reset();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _reset() {
    _timer?.cancel();
    _attempt = 0;
    _failed = false;
    _retryQueued = false;
  }

  /// Called from a build method, so the state change waits until the frame is done.
  void _onError() {
    if (_retryQueued || _failed) return;
    _retryQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_attempt >= _retryDelays.length) {
        setState(() => _failed = true);
        return;
      }
      _timer = Timer(_retryDelays[_attempt], () {
        if (!mounted) return;
        setState(() {
          _attempt++;
          _retryQueued = false;
        });
      });
    });
  }

  void _reload() {
    setState(() {
      _attempt = 0;
      _failed = false;
      _retryQueued = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return widget.fallback ??
          _Fallback(icon: widget.fallbackIcon, onTap: _reload);
    }

    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final fade = reduceMotion ? Duration.zero : widget.fadeIn;
    final placeholder = widget.placeholder ?? const SizedBox.expand();

    Widget frame(
      BuildContext context,
      Widget child,
      int? frame,
      bool wasSynchronous,
    ) {
      if (wasSynchronous) return child;
      return AnimatedOpacity(
        opacity: frame == null ? 0 : 1,
        duration: fade,
        curve: Curves.easeOut,
        child: child,
      );
    }

    Widget error(BuildContext context, Object error, StackTrace? stack) {
      _onError();
      return placeholder;
    }

    final key = ValueKey('${widget.url}#$_attempt');
    final testProvider = NetworkPhoto.imageProviderForTesting;
    if (testProvider != null) {
      return Image(
        key: key,
        image: testProvider(widget.url),
        fit: widget.fit,
        frameBuilder: frame,
        errorBuilder: error,
      );
    }

    if (kIsWeb) {
      return Image.network(
        widget.url,
        key: key,
        fit: widget.fit,
        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
        frameBuilder: frame,
        errorBuilder: error,
      );
    }

    return CachedNetworkImage(
      key: key,
      imageUrl: widget.url,
      fit: widget.fit,
      memCacheWidth: widget.memCacheWidth,
      fadeInDuration: fade,
      placeholder: (context, url) => placeholder,
      errorWidget: (context, url, error) {
        _onError();
        return placeholder;
      },
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = context.l10n.photoReload;
    return LayoutBuilder(
      builder: (context, constraints) {
        final roomy = constraints.biggest.shortestSide >= 120;
        return Semantics(
          button: true,
          label: label,
          excludeSemantics: true,
          child: InkResponse(
            onTap: onTap,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: roomy ? 40 : 28,
                    color: colors.onSurfaceVariant,
                  ),
                  if (roomy) ...[
                    const SizedBox(height: 6),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: context.text.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
