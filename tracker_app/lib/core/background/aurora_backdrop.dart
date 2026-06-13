import 'package:aurora_background/aurora_background.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AuroraBackdrop extends StatelessWidget {
  final Widget? child;
  final AuroraConfig config;

  const AuroraBackdrop({
    super.key,
    this.child,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    if (!config.enabled) {
      return Container(
        color: config.backgrounds.isNotEmpty
            ? config.backgrounds.first
            : Colors.black,
        child: child ?? const SizedBox.expand(),
      );
    }

    return AuroraBackground(
      numberOfWaves: config.waves.length,
      backgroundColors: config.backgrounds,
      waveDurations: const [10, 18, 26],
      waveColors: config.waves,
      waveHeightMultiplier: 0.22,
      baseHeightMultiplier: 0.40,
      waveBlur: 36,
      child: child ?? const SizedBox.expand(),
    );
  }
}
