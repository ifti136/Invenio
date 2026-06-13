import 'package:flutter/material.dart';
import '../services/haptic_service.dart';

class HapticWrapper extends StatelessWidget {
  final Widget child;
  final HapticProfile profile;
  final VoidCallback? onTap;

  const HapticWrapper({
    super.key,
    required this.child,
    this.profile = HapticProfile.light,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticService.trigger(profile);
        if (onTap != null) {
          onTap!();
        }
      },
      child: child,
    );
  }
}
