import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/core/router/routes.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/theme/orb_tints.dart';
import 'package:shopsphere/core/theme/shop_colors.dart';
import 'package:shopsphere/core/theme/spacing.dart';
import 'package:shopsphere/core/utils/formatters.dart';
import 'package:shopsphere/core/widgets/buttons.dart';
import 'package:shopsphere/core/widgets/orb.dart';
import 'package:shopsphere/features/cart/domain/entities/order_receipt.dart';
import 'package:shopsphere/l10n/l10n.dart';

/// Shown after an order is accepted: a volt orb lands, a check draws itself inside it.
class OrderSuccessPage extends StatefulWidget {
  const OrderSuccessPage({required this.receipt, super.key});

  final OrderReceipt receipt;

  @override
  State<OrderSuccessPage> createState() => _OrderSuccessPageState();
}

class _OrderSuccessPageState extends State<OrderSuccessPage>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  /// A burst of confetti once the check has landed.
  late final AnimationController _confetti = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      _confetti.value = 1;
    } else if (!_controller.isAnimating && _controller.value == 0) {
      _controller.forward();
      _confetti.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final receipt = widget.receipt;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Gap.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final t = _controller.value;
                  final land = Curves.elasticOut.transform(
                    (t / 0.5).clamp(0.0, 1.0),
                  );
                  final check = Curves.easeOutCubic.transform(
                    ((t - 0.3) / 0.35).clamp(0.0, 1.0),
                  );
                  final ripple = ((t - 0.15) / 0.6).clamp(0.0, 1.0);
                  final text = Curves.easeOut.transform(
                    ((t - 0.55) / 0.4).clamp(0.0, 1.0),
                  );
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox.square(
                        dimension: 220,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            Positioned.fill(
                              child: IgnorePointer(
                                child: AnimatedBuilder(
                                  animation: _confetti,
                                  builder: (context, _) => CustomPaint(
                                    painter: _ConfettiPainter(
                                      // Waits for the check, then runs for about two seconds.
                                      progress: ((_confetti.value - 0.2) / 0.8)
                                          .clamp(0.0, 1.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            CustomPaint(
                              size: const Size.square(220),
                              painter: _RipplePainter(
                                progress: ripple,
                                color: context.colors.onSurface,
                              ),
                            ),
                            Transform.scale(
                              scale: 0.4 + 0.6 * land,
                              child: SizedBox.square(
                                dimension: 168,
                                child: Orb(
                                  tint: const OrbTint(
                                    light: Color(0xFFF1FFB4),
                                    deep: Palette.volt,
                                  ),
                                  child: CustomPaint(
                                    size: const Size.square(76),
                                    painter: _CheckPainter(progress: check),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Gap.hxl,
                      Opacity(
                        opacity: text,
                        child: Transform.translate(
                          offset: Offset(0, (1 - text) * 14),
                          child: Column(
                            children: [
                              Text(
                                l10n.orderPlacedTitle,
                                textAlign: TextAlign.center,
                                style: context.text.displaySmall,
                              ),
                              Gap.hs,
                              Text(
                                l10n.orderPlacedMessage(receipt.orderId),
                                textAlign: TextAlign.center,
                                style: context.text.titleMedium,
                              ),
                              const SizedBox(height: Gap.xs),
                              Text(
                                l10n.orderPlacedDetail(
                                  receipt.itemCount,
                                  Formatters.money(receipt.total),
                                ),
                                textAlign: TextAlign.center,
                                style: context.text.bodyLarge?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                ),
                              ),
                              if (receipt.couponCode != null &&
                                  receipt.couponDiscount > 0) ...[
                                const SizedBox(height: Gap.xs),
                                Text(
                                  '${l10n.couponLine(receipt.couponCode!)}: '
                                  '−${Formatters.money(receipt.couponDiscount)}',
                                  textAlign: TextAlign.center,
                                  style: context.text.bodyMedium?.copyWith(
                                    color: context.shop.success,
                                  ),
                                ),
                              ],
                              if (receipt.donation > 0) ...[
                                const SizedBox(height: Gap.xs),
                                Text(
                                  l10n.giveThanks(
                                    Formatters.money(receipt.donation),
                                  ),
                                  textAlign: TextAlign.center,
                                  style: context.text.bodyMedium?.copyWith(
                                    color: context.shop.success,
                                  ),
                                ),
                              ],
                              Gap.hl,
                              Text(
                                l10n.orderPlacedDemoNote,
                                textAlign: TextAlign.center,
                                style: context.text.bodySmall?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                ),
                              ),
                              Gap.hxxl,
                              AppButton(
                                kind: AppButtonKind.accent,
                                label: l10n.orderContinue,
                                onPressed: () => context.go(Routes.shop),
                              ),
                              Gap.hm,
                              AppButton(
                                kind: AppButtonKind.outline,
                                label: l10n.orderViewOrders,
                                onPressed: () => context.push(Routes.orders),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A single ring that expands and fades behind the orb.
class _RipplePainter extends CustomPainter {
  const _RipplePainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final radius = size.width * (0.38 + 0.12 * progress);
    canvas.drawCircle(
      size.center(Offset.zero),
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = color.withValues(alpha: 0.5 * (1 - progress)),
    );
  }

  @override
  bool shouldRepaint(_RipplePainter old) =>
      old.progress != progress || old.color != color;
}

/// A check mark that draws itself.
class _CheckPainter extends CustomPainter {
  const _CheckPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.16, size.height * 0.54)
      ..lineTo(size.width * 0.42, size.height * 0.78)
      ..lineTo(size.width * 0.86, size.height * 0.26);
    final metric = path.computeMetrics().first;
    canvas.drawPath(
      metric.extractPath(0, metric.length * progress),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = math.max(6, size.width * 0.12)
        ..color = Palette.ink,
    );
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.progress != progress;
}

/// Confetti thrown up from behind the check and falling back under gravity.
///
/// Every piece's path is worked out from a fixed seed, so it is the same each time and costs
/// nothing but a few maths operations per frame.
class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({required this.progress});

  final double progress;

  static const int _pieces = 46;
  static const double _seconds = 2.2;
  static const double _gravity = 980;
  static const List<Color> _palette = [
    Palette.volt,
    Color(0xFFFF5E4D),
    Color(0xFF72B9FF),
    Color(0xFFA48FFF),
    Color(0xFF6FD6A4),
    Color(0xFFFFCF4D),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final random = math.Random(11);
    final origin = size.center(Offset.zero);
    final t = progress * _seconds;
    for (var i = 0; i < _pieces; i++) {
      // A fan, mostly upwards.
      final angle = -math.pi * (0.1 + 0.8 * random.nextDouble());
      final speed = 320 + 380 * random.nextDouble();
      final spin = (random.nextDouble() - 0.5) * 14;
      final extent = 6 + 6 * random.nextDouble();
      final color = _palette[i % _palette.length];
      final round = i.isEven;

      final x = origin.dx + math.cos(angle) * speed * t;
      final y =
          origin.dy + math.sin(angle) * speed * t + 0.5 * _gravity * t * t;
      final fade = progress < 0.7 ? 1.0 : 1 - (progress - 0.7) / 0.3;

      canvas
        ..save()
        ..translate(x, y)
        ..rotate(spin * t);
      final paint = Paint()..color = color.withValues(alpha: fade);
      if (round) {
        canvas.drawCircle(Offset.zero, extent * 0.5, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: extent * 1.5,
              height: extent * 0.7,
            ),
            const Radius.circular(2),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
