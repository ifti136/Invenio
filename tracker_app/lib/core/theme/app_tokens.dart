import 'package:flutter/material.dart';

class AppRadii {
  static const double hero = 24;
  static const double card = 20;
  static const double tile = 16;
  static const double input = 14;
  static const double button = 14;
  static const double sheet = 28;
  static const double pill = 999;
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  static const EdgeInsets gutter = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets cardPadding = EdgeInsets.all(14);
}

class AppTextStyles {
  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];

  static const TextStyle display = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.6,
    fontFeatures: tabular,
  );

  static const TextStyle title = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.2,
    fontFeatures: tabular,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0.6,
  );

  static const TextStyle number = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    fontFeatures: tabular,
  );
}
