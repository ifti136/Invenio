import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/widgets/glass_panel.dart';
import '../../core/theme/app_colors.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  static const String appVersion = '2.0.0+16';
  static const String developer = 'Invenio Developer';
  static const String repoUrl = 'https://github.com/ifti136/Invenio';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Invenio'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassPanel(
            noBlur: true,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.storefront_outlined,
                  size: 64,
                  color: AppColors.accent,
                ),
                const SizedBox(height: 16),
                Text(
                  'Invenio',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'v$appVersion',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 24),
                _infoRow(context, 'Developer', developer),
                _infoRow(context, 'Repository', repoUrl),
                _infoRow(context, 'Platform', 'Android (min API 24)'),
                _infoRow(context, 'Framework', 'Flutter 3.24.4'),
                _infoRow(context, 'Database', 'Drift / SQLite (Schema v6)'),
                _infoRow(context, 'License', 'MIT'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GlassPanel(
            noBlur: true,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Change History',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                _changeRow(context, 'v2.0.0', 'POS-style restyle: teal Liquid Glass, rounded cards, 5-slot nav, receipt popup'),
                _changeRow(context, 'v2.1.0', 'About section and app walkthrough with shop name'),
                _changeRow(context, 'v2.1.1', 'Minor polish and bug fixes'),
                _changeRow(context, 'v2.1.2', 'Fix blank gray screen on launch'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                OutlinedButton.icon(
                  onPressed: () => Share.share(
                    'Check out Invenio - Inventory & Economy Tracker\n$repoUrl',
                  ),
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: const Text('Share App'),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => Share.share(repoUrl),
                  icon: const Icon(Icons.link_outlined, size: 18),
                  label: const Text('View on GitHub'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Invenio — Inventory & Economy Tracker\nOffline-first. No auth. No cloud sync.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.38),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.6),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _changeRow(BuildContext context, String version, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            version,
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
