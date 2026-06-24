import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_panel.dart';

import '../../core/widgets/theme_card.dart';

class ThemeScreen extends ConsumerWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Theme"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: GlassPanel(
          noBlur: true,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Appearance",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: const [
                  ThemeCard(
                    id: AppThemeId.darkAurora,
                    label: "Dark Aurora",
                  ),
                  ThemeCard(
                    id: AppThemeId.lightAurora,
                    label: "Light Aurora",
                  ),
                  ThemeCard(
                    id: AppThemeId.midnightBlue,
                    label: "Midnight Blue",
                  ),
                  ThemeCard(
                    id: AppThemeId.paper,
                    label: "Paper",
                  ),
                  ThemeCard(
                    id: AppThemeId.ocean,
                    label: "Deep Ocean",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
