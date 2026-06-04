import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: brightness,
    );
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface),
        actionsIconTheme: IconThemeData(color: scheme.onSurface),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primary.withOpacity(isDark ? 0.22 : 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: scheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            );
          }
          return TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: scheme.primary);
          }
          return IconThemeData(color: scheme.onSurfaceVariant);
        }),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
      cardTheme: CardTheme(
        color: scheme.surface.withOpacity(isDark ? 0.55 : 0.65),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withOpacity(0.04),
        selectedColor: scheme.primary.withOpacity(isDark ? 0.22 : 0.18),
        side: BorderSide(
          color: scheme.onSurfaceVariant.withOpacity(0.18),
          width: 0.6,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        labelStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: TextStyle(
          color: scheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        checkmarkColor: scheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        showCheckmark: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        focusElevation: 3,
        hoverElevation: 3,
        highlightElevation: 4,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
