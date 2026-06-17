import 'package:flutter/material.dart';
import '../../core/widgets/glass_panel.dart';
import '../../core/theme/app_colors.dart';

class SystemSettingsScreen extends StatelessWidget {
  const SystemSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SYSTEM')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassPanel(
            noBlur: true,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App Version',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                _infoRow(context, 'Version', '1.0.2+1'),
                _infoRow(context, 'Schema', 'v5'),
                _infoRow(context, 'Min SDK', 'Android 24'),
                _infoRow(context, 'Framework', 'Flutter 3.24.4'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassPanel(
            noBlur: true,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data Management',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                _actionTile(
                  context,
                  icon: Icons.backup_outlined,
                  label: 'Export Database',
                  subtitle: 'Save a copy of your data',
                ),
                const Divider(color: Colors.white12, height: 24),
                _actionTile(
                  context,
                  icon: Icons.restore_outlined,
                  label: 'Import Database',
                  subtitle: 'Restore from a backup',
                ),
                const Divider(color: Colors.white12, height: 24),
                _actionTile(
                  context,
                  icon: Icons.delete_outline,
                  label: 'Clear All Data',
                  subtitle: 'Remove all records permanently',
                  iconColor: AppColors.danger,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Invenio — Inventory Management',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white38,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
        ],
      ),
    );
  }

  Widget _actionTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    Color iconColor = AppColors.accent,
  }) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                  Text(subtitle,
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
          ],
        ),
      ),
    );
  }
}
