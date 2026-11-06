import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker/core/theme/app_theme.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  for (final entry in {
    'light': AppTheme.light().colorScheme,
    'dark': AppTheme.dark().colorScheme,
  }.entries) {
    final name = entry.key;
    final scheme = entry.value;

    test('$name text and surface pairs meet 4.5:1', () {
      final pairs = <String, (Color, Color)>{
        'onSurface/surface': (scheme.onSurface, scheme.surface),
        'onSurfaceVariant/surface': (scheme.onSurfaceVariant, scheme.surface),
        'onSurfaceVariant/surfaceContainerLow': (
          scheme.onSurfaceVariant,
          scheme.surfaceContainerLow
        ),
        'onPrimary/primary': (scheme.onPrimary, scheme.primary),
        'onPrimaryContainer/primaryContainer': (
          scheme.onPrimaryContainer,
          scheme.primaryContainer
        ),
        'onSecondaryContainer/secondaryContainer': (
          scheme.onSecondaryContainer,
          scheme.secondaryContainer
        ),
        'onError/error': (scheme.onError, scheme.error),
        'onErrorContainer/errorContainer': (
          scheme.onErrorContainer,
          scheme.errorContainer
        ),
        'onTertiaryContainer/tertiaryContainer': (
          scheme.onTertiaryContainer,
          scheme.tertiaryContainer
        ),
        'primary/surface': (scheme.primary, scheme.surface),
        'error/surface': (scheme.error, scheme.surface),
        'tertiary/surface': (scheme.tertiary, scheme.surface),
      };

      for (final pair in pairs.entries) {
        expect(
          _contrast(pair.value.$1, pair.value.$2),
          greaterThanOrEqualTo(4.5),
          reason: '$name ${pair.key} must reach 4.5:1',
        );
      }
    });

    test('$name outlines meet 3:1 against their surfaces', () {
      expect(
        _contrast(scheme.outline, scheme.surface),
        greaterThanOrEqualTo(3.0),
        reason: '$name outline/surface must reach 3:1',
      );
    });
  }
}
