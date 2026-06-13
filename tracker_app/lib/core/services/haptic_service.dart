import 'package:flutter/services.dart';

enum HapticProfile {
  light,
  medium,
  heavy,
}

class HapticService {
  static void trigger(HapticProfile profile) {
    switch (profile) {
      case HapticProfile.light:
        HapticFeedback.lightImpact();
        break;
      case HapticProfile.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticProfile.heavy:
        HapticFeedback.heavyImpact();
        break;
    }
  }
}
