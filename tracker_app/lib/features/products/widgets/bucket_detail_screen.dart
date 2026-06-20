import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/core/theme/app_colors.dart';
import 'package:tracker/core/utils/formatters.dart';
import 'package:tracker/core/widgets/glass_panel.dart';
import 'package:tracker/core/widgets/section_header.dart';
import 'package:tracker/db/app_database.dart';
import 'package:tracker/features/products/bucket_repository.dart';
import 'bucket_form_sheet.dart';

class BucketDetailScreen extends ConsumerWidget {
  final int bucketId;
  const BucketDetailScreen({super.key, required this.bucketId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bucketAsync =
        ref.watch(bucketRepositoryProvider).getById(bucketId).then(
      (bucket) async {
        final repo = ref.read(bucketRepositoryProvider);
        final expenses = await repo.getExpensesForBucket(bucketId);
        return (bucket: bucket, expenses: expenses);
      },
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Bucket Detail',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: bucketAsync,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final data = snapshot.data!;
          final bucket = data.bucket;
          final expenses = data.expenses;

          if (bucket == null) {
            return const Center(child: Text('Bucket not found'));
          }

          final color = bucket.color != null
              ? Color(int.parse(bucket.color!.replaceFirst('#', '0xff')))
              : AppColors.accent;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            children: [
              GlassPanel(
                padding: const EdgeInsets.all(16),
                noBlur: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            bucket.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit,
                              color: Colors.white70, size: 20),
                          onPressed: () {
                            showBucketFormSheet(context, bucket: bucket);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Budget: ${formatMoney(bucket.allocatedAmount)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const SectionHeader('EXPENSE HISTORY'),
              const SizedBox(height: 12),
              if (expenses.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Text(
                      'No expenses linked to this bucket',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                )
              else
                ...expenses.map((e) => _ExpenseHistoryTile(
                      expense: e.$1,
                      wallet: e.$2,
                    )),
            ],
          );
        },
      ),
    );
  }
}

class _ExpenseHistoryTile extends StatelessWidget {
  final Expense expense;
  final Wallet wallet;
  const _ExpenseHistoryTile({required this.expense, required this.wallet});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassPanel(
        padding: const EdgeInsets.all(12),
        noBlur: true,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(expense.createdAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white60,
                        ),
                  ),
                  if (expense.note != null && expense.note!.isNotEmpty)
                    Text(
                      expense.note!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet,
                          size: 12, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(
                        wallet.name,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white60,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '-${formatMoney(expense.amount)}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.danger,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year}';
  }
}
