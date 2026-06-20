import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import 'glass_panel.dart';
import 'haptic_wrapper.dart';
import '../services/haptic_service.dart';

class ThemeCard extends ConsumerWidget {
  final AppThemeId id;
  final String label;

  const ThemeCard({
    super.key,
    required this.id,
    required this.label,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(themeProviderProvider);
    final isSelected = selectedId.value == id;
    final settings = AppTheme.fromId(id);

    return HapticWrapper(
      profile: HapticProfile.medium,
      onTap: () => ref.read(themeProviderProvider.notifier).setTheme(id),
      child: GlassPanel(
        opaque: isSelected,
        radius: 20,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mini Aurora Strip
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 60,
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: settings.aurora.backgrounds.length > 1
                        ? LinearGradient(
                            colors: settings.aurora.backgrounds,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: settings.aurora.backgrounds.length == 1
                        ? settings.aurora.backgrounds.first
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
