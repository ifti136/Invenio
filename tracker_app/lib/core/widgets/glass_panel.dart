import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';
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
  });

  const GlassPanel.flush({
    super.key,
    this.child,
    this.margin = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
    this.blur = 18,
    this.isFrostedGlass = false,
    this.expand = true,
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

    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRRect(
          borderRadius: radius > 0 ? BorderRadius.circular(radius) : BorderRadius.zero,
          child: GlassContainer(
            height: expand ? constraints.maxHeight : height,
            width: expand ? constraints.maxWidth : width,
            margin: margin,
            padding: padding,
            borderRadius: radius > 0 ? BorderRadius.circular(radius) : BorderRadius.zero,
            isFrostedGlass: isFrostedGlass,
            blur: blur,
            borderWidth: 1.0,
            elevation: 0,
            shadowColor: Colors.black.withOpacity(0.0),
            frostedOpacity: isDark ? 0.10 : 0.08,
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(fillTop),
                Colors.white.withOpacity(fillBottom),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderGradient: LinearGradient(
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
            child: child,
          ),
        );
      },
    );
  }
}
