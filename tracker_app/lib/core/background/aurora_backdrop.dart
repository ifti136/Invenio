import 'package:aurora_background/aurora_background.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AuroraBackdrop extends StatelessWidget {
  final Widget? child;
  final Brightness brightness;

  const AuroraBackdrop({
    super.key,
    this.child,
    this.brightness = Brightness.dark,
  });

  @override
  Widget build(BuildContext context) {
    final b = brightness == Brightness.dark
        ? _AuroraPalette.dark
        : _AuroraPalette.light;
    return AuroraBackground(
      numberOfWaves: 3,
      backgroundColors: b.backgrounds,
      waveDurations: const [10, 18, 26],
      waveColors: b.waves,
      waveHeightMultiplier: 0.22,
      baseHeightMultiplier: 0.40,
      waveBlur: 36,
      child: child ?? const SizedBox.expand(),
    );
  }
}

class _AuroraPalette {
  final List<Color> backgrounds;
  final List<List<Color>> waves;

  const _AuroraPalette({required this.backgrounds, required this.waves});

  static const Color _t = AppColors.auroraTeal;
  static const Color _i = AppColors.auroraIndigo;
  static const Color _m = AppColors.auroraMagenta;

  static const dark = _AuroraPalette(
    backgrounds: [
      AppColors.auroraBg1,
      AppColors.auroraBg2,
      AppColors.auroraBg3,
    ],
    waves: [
      [_t, _t, _t],
      [_i, _i, _i],
      [_m, _m, _m],
    ],
  );

  static const light = _AuroraPalette(
    backgrounds: [
      Color(0xFFF6F2EC),
      Color(0xFFEFE6DA),
      Color(0xFFE8D9E8),
    ],
    waves: [
      [_t, _t, _t],
      [_i, _i, _i],
      [_m, _m, _m],
    ],
  );
}
