import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/core/utils/formatters.dart';
import 'package:tracker/core/widgets/glass_panel.dart';
import 'package:tracker/core/widgets/glass_dialog.dart';
import 'package:tracker/core/theme/app_colors.dart';
import 'package:tracker/core/services/haptic_service.dart';
import '../bucket_repository.dart';
import 'bucket_form_sheet.dart';
import '../../dashboard/dashboard_provider.dart';

class BucketListScreen extends ConsumerWidget {
  const BucketListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bucketAvailablesAsync = ref.watch(bucketAvailablesProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Budget Buckets'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: bucketAvailablesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
            child: Text('Error: $err',
                style: const TextStyle(color: Colors.white))),
        data: (balances) {
          if (balances.isEmpty) {
            return const Center(
              child: Text(
                'No buckets created yet',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: balances.length,
            itemBuilder: (context, index) {
              final bucketBalance = balances[index];
              final available = bucketBalance.available;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassPanel(
                  noBlur: true,
                  child: ListTile(
                    leading: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: bucketBalance.color != null
                            ? Color(int.parse(
                                bucketBalance.color!.replaceFirst('#', '0xff')))
                            : AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(
                      bucketBalance.name,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(
                      formatMoney(available),
                      style: TextStyle(
                        color: available >= 0
                            ? AppColors.success
                            : AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () async {
                      HapticService.trigger(HapticProfile.light);
                      final bucket = await ref
                          .read(bucketRepositoryProvider)
                          .getById(bucketBalance.id);
                      if (context.mounted) {
                        showBucketFormSheet(context, bucket: bucket);
                      }
                    },
                    onLongPress: () {
                      HapticService.trigger(HapticProfile.heavy);
                      _confirmDeleteBucket(context, ref, bucketBalance.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: () {
          HapticService.trigger(HapticProfile.medium);
          showBucketFormSheet(context);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _confirmDeleteBucket(BuildContext context, WidgetRef ref, int id) {
    showGlassDialog(
      context: context,
      title: 'Delete Bucket',
      message:
          'Are you sure you want to delete this bucket? This action cannot be undone.',
      actionsBuilder: (ctx) => [
        GlassDialogAction(
          label: 'Cancel',
          onPressed: () {
            HapticService.trigger(HapticProfile.light);
            Navigator.of(ctx).pop();
          },
        ),
        GlassDialogAction(
          label: 'Delete',
          isDestructive: true,
          isPrimary: true,
          onPressed: () async {
            final navigator = Navigator.of(ctx);
            HapticService.trigger(HapticProfile.heavy);
            await ref.read(bucketRepositoryProvider).delete(id);
            ref.invalidate(dashboardProvider);
            navigator.pop();
          },
        ),
      ],
    );
  }
}
