import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker/core/widgets/glass_panel.dart';
import 'package:tracker/core/theme/app_colors.dart';
import 'package:tracker/core/widgets/glass_dialog.dart';
import '../bucket_repository.dart';



class BucketListScreen extends ConsumerWidget {
  const BucketListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Budget Buckets'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<BucketBalance>>(
        future: ref.read(bucketRepositoryProvider).getBucketBalances(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final balances = snapshot.data!;

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
                            ? Color(int.parse(bucketBalance.color!.replaceFirst('#', '0xff'))) 
                            : AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(
                      bucketBalance.name,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(
                      '\$${available.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: available >= 0 ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () => context.push('/products/settings/buckets/edit/${bucketBalance.id}'),
                    onLongPress: () => _confirmDeleteBucket(context, ref, bucketBalance.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: () => context.push('/products/settings/buckets/add'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _confirmDeleteBucket(BuildContext context, WidgetRef ref, int id) {
    showGlassDialog(
      context: context,
      title: 'Delete Bucket',
      message: 'Are you sure you want to delete this bucket? This action cannot be undone.',
      actionsBuilder: (ctx) => [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
        TextButton(
          onPressed: () async {
            await ref.read(bucketRepositoryProvider).delete(id);
            Navigator.of(ctx).pop();
          },
          child: const Text('Delete', style: TextStyle(color: AppColors.error)),
        ),
      ],
    );
  }
}
