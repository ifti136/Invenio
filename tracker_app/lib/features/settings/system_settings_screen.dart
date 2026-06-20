import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../core/widgets/glass_panel.dart';
import '../../core/widgets/glass_dialog.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/haptic_service.dart';
import '../../db/app_database.dart';

class SystemSettingsScreen extends ConsumerWidget {
  const SystemSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                _infoRow(context, 'Version', '1.5.1+13'),
                _infoRow(context, 'Schema', 'v6'),
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
                  onTap: () => _exportDatabase(context, ref),
                ),
                const Divider(color: Colors.white12, height: 24),
                _actionTile(
                  context,
                  icon: Icons.restore_outlined,
                  label: 'Import Database',
                  subtitle: 'Restore from a backup',
                  onTap: () => _importDatabase(context, ref),
                ),
                const Divider(color: Colors.white12, height: 24),
                _actionTile(
                  context,
                  icon: Icons.delete_outline,
                  label: 'Clear All Data',
                  subtitle: 'Remove all records permanently',
                  iconColor: AppColors.danger,
                  onTap: () => _clearAllData(context, ref),
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
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
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

  Future<void> _exportDatabase(BuildContext context, WidgetRef ref) async {
    HapticService.trigger(HapticProfile.medium);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dir.path, 'tracker.db'));
      if (!await dbFile.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Database file not found')),
          );
        }
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final tempFile = File(p.join(tempDir.path, 'invenio_backup.db'));
      await dbFile.copy(tempFile.path);

      await Share.shareXFiles(
        [XFile(tempFile.path)],
        subject: 'Invenio Database Backup',
        text: 'Invenio database backup - ${DateTime.now().toIso8601String()}',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _importDatabase(BuildContext context, WidgetRef ref) async {
    HapticService.trigger(HapticProfile.medium);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Import not available yet. Export a backup from another device first.'),
        ),
      );
    }
  }

  Future<void> _clearAllData(BuildContext context, WidgetRef ref) async {
    HapticService.trigger(HapticProfile.heavy);
    if (!context.mounted) return;
    showGlassDialog(
      context: context,
      title: 'Clear All Data',
      message:
          'This will permanently delete all products, sales, expenses, wallets, and every other record. This action cannot be undone.',
      actionsBuilder: (ctx) => [
        GlassDialogAction(
          label: 'Cancel',
          onPressed: () => Navigator.of(ctx).pop(),
        ),
        GlassDialogAction(
          label: 'Clear Everything',
          isDestructive: true,
          isPrimary: true,
          onPressed: () async {
              final db = ref.read(appDatabaseProvider);
              await db.delete(db.saleAddOns).go();
              await db.delete(db.addOnTypes).go();
              await db.delete(db.transfers).go();
              await db.delete(db.expenses).go();
              await db.delete(db.stockMovements).go();
              await db.delete(db.sales).go();
              await db.delete(db.budgetBuckets).go();
              await db.delete(db.allocationRules).go();
              await db.delete(db.wallets).go();
              await db.delete(db.products).go();
              ref.invalidate(appDatabaseProvider);
              Navigator.of(ctx).pop();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data cleared.')),
                );
              }
            },
        ),
      ],
    );
  }
}
