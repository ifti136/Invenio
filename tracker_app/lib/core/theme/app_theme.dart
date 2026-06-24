import 'package:flutter/material.dart';
import 'app_colors.dart';

enum AppThemeId {
  darkAurora,
  lightAurora,
  midnightBlue,
  @Deprecated('Use darkAurora instead')
  solidSlate,
  paper,
  ocean,
}

class AuroraConfig {
  final List<Color> backgrounds;
  final List<List<Color>> waves;
  final bool enabled;

  const AuroraConfig({
    required this.backgrounds,
    required this.waves,
    this.enabled = true,
  });
}

class AppTheme {
  static ThemeData andAurora(AppThemeId id) {
    final theme = fromId(id);
    return theme.data;
  }

  static AuroraConfig aurora(AppThemeId id) {
    return fromId(id).aurora;
  }

  static ThemeSettings fromId(AppThemeId id) {
    switch (id) {
      case AppThemeId.lightAurora:
        return ThemeSettings(
          data: _build(Brightness.light),
          aurora: const AuroraConfig(
            backgrounds: [
              Color(0xFFF6F2EC),
              Color(0xFFEFE6DA),
              Color(0xFFE8D9E8),
            ],
            waves: [
              [
                AppColors.auroraTeal,
                AppColors.auroraTeal,
                AppColors.auroraTeal
              ],
              [
                AppColors.auroraIndigo,
                AppColors.auroraIndigo,
                AppColors.auroraIndigo
              ],
              [
                AppColors.auroraMagenta,
                AppColors.auroraMagenta,
                AppColors.auroraMagenta
              ],
            ],
          ),
        );
      case AppThemeId.midnightBlue:
        return ThemeSettings(
          data: _build(Brightness.dark, seed: AppColors.midnightWave1),
          aurora: const AuroraConfig(
            backgrounds: [
              AppColors.midnightBg1,
              AppColors.midnightBg2,
              AppColors.midnightBg3,
            ],
            waves: [
              [
                AppColors.midnightWave1,
                AppColors.midnightWave1,
                AppColors.midnightWave1
              ],
              [
                AppColors.midnightWave2,
                AppColors.midnightWave2,
                AppColors.midnightWave2
              ],
              [
                AppColors.midnightWave3,
                AppColors.midnightWave3,
                AppColors.midnightWave3
              ],
            ],
          ),
        );
      case AppThemeId.paper:
        return ThemeSettings(
          data: _build(
            Brightness.light,
            solid: true,
            primary: AppColors.paperPrimary,
            secondary: AppColors.paperSecondary,
            surface: AppColors.paperSurface,
            text: AppColors.paperText,
          ),
          aurora: const AuroraConfig(
            backgrounds: [
              AppColors.paperBgStart,
              AppColors.paperBgEnd,
            ],
            waves: [],
            enabled: false,
          ),
        );
      case AppThemeId.ocean:
        return ThemeSettings(
          data: _build(
            Brightness.dark,
            solid: true,
            primary: AppColors.oceanPrimary,
            secondary: AppColors.oceanSecondary,
            surface: AppColors.oceanSurface,
            text: AppColors.oceanText,
          ),
          aurora: const AuroraConfig(
            backgrounds: [
              AppColors.oceanBgStart,
              AppColors.oceanBgEnd,
            ],
            waves: [],
            enabled: false,
          ),
        );
      case AppThemeId.darkAurora:
      default:
        return ThemeSettings(
          data: _build(Brightness.dark),
          aurora: const AuroraConfig(
            backgrounds: [
              AppColors.auroraBg1,
              AppColors.auroraBg2,
              AppColors.auroraBg3,
            ],
            waves: [
              [
                AppColors.auroraTeal,
                AppColors.auroraTeal,
                AppColors.auroraTeal
              ],
              [
                AppColors.auroraIndigo,
                AppColors.auroraIndigo,
                AppColors.auroraIndigo
              ],
              [
                AppColors.auroraMagenta,
                AppColors.auroraMagenta,
                AppColors.auroraMagenta
              ],
            ],
          ),
        );
    }
  }

  static ThemeData _build(Brightness brightness,
      {Color? seed,
      bool solid = false,
      Color? primary,
      Color? secondary,
      Color? surface,
      Color? text}) {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: seed ?? AppColors.accent,
      brightness: brightness,
    );

    final scheme = baseScheme.copyWith(
      primary: primary ?? baseScheme.primary,
      secondary: secondary ?? baseScheme.secondary,
      surface:
          surface ?? (solid ? AppColors.solidSlateSurface : baseScheme.surface),
      onSurface: text ?? baseScheme.onSurface,
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
        backgroundColor: solid
            ? (surface ?? AppColors.solidSlateSurface)
            : Colors.transparent,
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
        backgroundColor: solid
            ? (surface ?? AppColors.solidSlateSurface)
            : Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: solid
            ? (surface ?? AppColors.solidSlateSurface)
            : Colors.transparent,
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
        color: solid
            ? (surface ?? AppColors.solidSlateSurface)
            : scheme.surface.withOpacity(isDark ? 0.55 : 0.65),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: solid
            ? (surface ?? AppColors.solidSlateSurface).withOpacity(0.5)
            : Colors.white.withOpacity(0.04),
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

class ThemeSettings {
  final ThemeData data;
  final AuroraConfig aurora;

  const ThemeSettings({required this.data, required this.aurora});
}
