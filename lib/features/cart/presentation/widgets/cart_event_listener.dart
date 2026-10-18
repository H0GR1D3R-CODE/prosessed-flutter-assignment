import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/core/router/routes.dart';
import 'package:shopsphere/features/cart/presentation/bloc/cart_cubit.dart';
import 'package:shopsphere/l10n/l10n.dart';

/// Turns cart events into snackbars, wherever in the app they happen: "Added", "Removed - Undo",
/// "That's all we have" and "Couldn't save".
class CartEventListener extends StatelessWidget {
  const CartEventListener({
    required this.router,
    required this.child,
    super.key,
  });

  final GoRouter router;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartCubit, CartState>(
      listenWhen: (previous, current) =>
          current.event != null && current.event != previous.event,
      listener: (context, state) {
        final l10n = context.l10n;
        final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
        switch (state.event) {
          case CartItemAdded(:final title, :final quantity):
            messenger.showSnackBar(
              SnackBar(
                // Material 3 keeps a snackbar with an action on screen until it is dismissed,
                // which would leave it covering the checkout button.
                persist: false,
                duration: const Duration(seconds: 3),
                content: Text(l10n.addedToCart(quantity, title)),
                action: SnackBarAction(
                  label: l10n.viewCart,
                  onPressed: () => router.go(Routes.cart),
                ),
              ),
            );
          case CartLimitReached(:final title, :final limit):
            messenger.showSnackBar(
              SnackBar(content: Text(l10n.cartLimitReached(limit, title))),
            );
          case final CartItemRemoved removed:
            messenger.showSnackBar(
              SnackBar(
                persist: false,
                duration: const Duration(seconds: 5),
                content: Text(l10n.cartRemoved(removed.item.title)),
                action: SnackBarAction(
                  label: l10n.undo,
                  onPressed: () =>
                      context.read<CartCubit>().undoRemove(removed),
                ),
              ),
            );
          case CartSaveFailed():
            messenger.showSnackBar(
              SnackBar(content: Text(l10n.cartSaveFailed)),
            );
          case null:
            break;
        }
      },
      child: child,
    );
  }
}
