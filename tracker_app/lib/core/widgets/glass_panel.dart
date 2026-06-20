import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui';
import '../theme/app_colors.dart';

class GlassPanel extends StatelessWidget {
  static bool testOverride = false;

  final Widget? child;
  final double? width;
  final double? height;
  final double radius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final bool isFrostedGlass;
  final bool expand;
  final bool noBlur;
  final bool opaque;

  const GlassPanel({
    super.key,
    this.child,
    this.width,
    this.height,
    this.radius = 20,
    this.margin,
    this.padding,
    this.blur = 18,
    this.isFrostedGlass = false,
    this.expand = false,
    this.noBlur = false,
    this.opaque = false,
  });

  const GlassPanel.flush({
    super.key,
    this.child,
    this.margin = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
    this.blur = 18,
    this.isFrostedGlass = false,
    this.expand = true,
    this.noBlur = false,
    this.opaque = false,
  })  : width = null,
        height = null,
        radius = 0;

  @override
  Widget build(BuildContext context) {
    if (testOverride) {
      return Container(
        height: height,
        width: width,
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: radius > 0 ? BorderRadius.circular(radius) : null,
        ),
        child: child,
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillTop = isDark ? 0.14 : 0.22;
    final fillBottom = isDark ? 0.04 : 0.08;
    final borderTop = isDark ? 0.30 : 0.55;
    final borderBottom = isDark ? 0.10 : 0.18;
    final accent = isDark ? 0.18 : 0.10;
    final scheme = Theme.of(context).colorScheme;

    if (noBlur || opaque) {
      return Container(
        height: expand ? double.infinity : height,
        width: expand ? double.infinity : width,
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color:
              opaque ? scheme.surface.withOpacity(isDark ? 0.92 : 0.95) : null,
          borderRadius: radius > 0 ? BorderRadius.circular(radius) : null,
          gradient: opaque
              ? null
              : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(fillTop),
                    Colors.white.withOpacity(fillBottom),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          border: radius > 0
              ? Border.all(
                  color: opaque
                      ? scheme.outline.withOpacity(0.20)
                      : Colors.white.withOpacity(borderTop),
                  width: 1.0,
                )
              : null,
        ),
        child: child,
      );
    }

    return Container(
      margin: margin,
      width: expand ? double.infinity : width,
      height: expand ? double.infinity : height,
      child: ClipRRect(
        borderRadius:
            radius > 0 ? BorderRadius.circular(radius) : BorderRadius.zero,
        child: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: const SizedBox.expand(),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(fillTop),
                      Colors.white.withOpacity(fillBottom),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            if (isFrostedGlass)
              Positioned.fill(
                child: Container(
                  color: Colors.white.withOpacity(isDark ? 0.10 : 0.08),
                ),
              ),
            if (radius > 0)
              Positioned.fill(
                child: CustomPaint(
                  painter: GlassBorderPainter(
                    radius: radius,
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(borderTop),
                        Colors.white.withOpacity(borderBottom),
                        AppColors.accent.withOpacity(0.0),
                        AppColors.accent.withOpacity(accent),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: const [0.0, 0.49, 0.50, 1.0],
                    ),
                  ),
                ),
              ),
            Padding(
              padding: padding ?? EdgeInsets.zero,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class GlassBorderPainter extends CustomPainter {
  final double radius;
  final Gradient gradient;

  GlassBorderPainter({required this.radius, required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader =
          gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant GlassBorderPainter oldDelegate) {
    if (oldDelegate.radius != radius) {
      return true;
    }
    if (oldDelegate.gradient is! LinearGradient || gradient is! LinearGradient) {
      return true;
    }
    final oldG = oldDelegate.gradient as LinearGradient;
    final newG = gradient as LinearGradient;
    return !listEquals(oldG.colors, newG.colors) ||
        !listEquals(oldG.stops, newG.stops) ||
        oldG.begin != newG.begin ||
        oldG.end != newG.end;
  }
}
