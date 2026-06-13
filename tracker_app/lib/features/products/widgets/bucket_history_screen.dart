import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/core/theme/app_colors.dart';
import 'package:tracker/core/utils/formatters.dart';
import 'package:tracker/core/widgets/glass_panel.dart';
import 'package:tracker/db/app_database.dart';
import 'package:tracker/features/products/bucket_repository.dart';

class BucketHistoryScreen extends ConsumerWidget {
  final int bucketId;
  const BucketHistoryScreen({super.key, required this.bucketId});

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
      appBar: AppBar(
        title: const Text(
          'Bucket History',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
        ),
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

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            children: [
              GlassPanel(
                padding: const EdgeInsets.all(16),
                noBlur: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bucket.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Budget: ${formatMoney(bucket.allocatedAmount)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (expenses.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Text('No expenses linked to this bucket'),
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
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  if (expense.note != null && expense.note!.isNotEmpty)
                    Text(
                      expense.note!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet,
                          size: 12, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(
                        wallet.name,
                        style: Theme.of(context).textTheme.labelSmall,
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
