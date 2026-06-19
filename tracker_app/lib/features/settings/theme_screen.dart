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
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: (MediaQuery.of(context).size.width - 80) / 2,
                    child: const ThemeCard(
                      id: AppThemeId.darkAurora,
                      label: "Dark Aurora",
                    ),
                  ),
                  SizedBox(
                    width: (MediaQuery.of(context).size.width - 80) / 2,
                    child: const ThemeCard(
                      id: AppThemeId.lightAurora,
                      label: "Light Aurora",
                    ),
                  ),
                  SizedBox(
                    width: (MediaQuery.of(context).size.width - 80) / 2,
                    child: const ThemeCard(
                      id: AppThemeId.midnightBlue,
                      label: "Midnight Blue",
                    ),
                  ),
                  SizedBox(
                    width: (MediaQuery.of(context).size.width - 80) / 2,
                    child: const ThemeCard(
                      id: AppThemeId.solidSlate,
                      label: "Solid Slate",
                    ),
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
