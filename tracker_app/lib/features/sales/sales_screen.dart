import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/money/money.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/money_text.dart';
import '../../core/widgets/status_chip.dart';
import '../../db/app_database.dart';
import '../settings/settings_providers.dart';
import 'sale_flow.dart';
import 'sale_models.dart';
import 'sale_providers.dart';

enum _DateFilter { all, today, week, month }

enum _StatusFilter { all, paid, partial, due }

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> {
  final _search = TextEditingController();
  String _query = '';
  _DateFilter _date = _DateFilter.all;
  int _channelId = 0;
  _StatusFilter _status = _StatusFilter.all;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sales = ref.watch(salesListProvider);
    final channels =
        ref.watch(channelsProvider).valueOrNull ?? const <Channel>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Sales')),
      body: sales.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load sales',
          message: 'Something went wrong while reading your sales.',
          actionLabel: 'Retry',
          actionIcon: Icons.refresh,
          onAction: () => ref.invalidate(salesListProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No sales yet',
              message:
                  'Log your first sale to see revenue, profit, and stock changes here.',
              actionLabel: 'New sale',
              actionIcon: Icons.add,
              onAction: () => openNewSale(context, ref),
            );
          }

          final filtered = _apply(items);
          final groups = _group(filtered);

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                sliver: SliverList.list(
                  children: [
                    SearchBar(
                      controller: _search,
                      hintText: 'Search sales',
                      leading: const Icon(Icons.search),
                      trailing: [
                        if (_query.isNotEmpty)
                          IconButton(
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _search.clear();
                              setState(() => _query = '');
                            },
                          ),
                      ],
                      onChanged: (value) => setState(() => _query = value),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _filters(channels),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ),
              ),
              if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.filter_alt_off_outlined,
                    title: 'No sales match',
                    message: 'Try a different search or clear the filters.',
                    actionLabel: 'Clear filters',
                    actionIcon: Icons.filter_alt_off_outlined,
                    onAction: _clearFilters,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.xxl * 2,
                  ),
                  sliver: SliverList.builder(
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      return _DaySection(group: group);
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _filters(List<Channel> channels) {
    final scheme = Theme.of(context).colorScheme;
    final channelOptions = <(int, String)>[
      (0, 'All channels'),
      for (final channel in channels) (channel.id, channel.name),
    ];
    final selectedChannel = channels.any((c) => c.id == _channelId)
        ? channels.firstWhere((c) => c.id == _channelId).name
        : 'Channel';

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _menuChip<_DateFilter>(
            label: _date == _DateFilter.all ? 'Date' : _dateLabel(_date),
            value: _date,
            active: _date != _DateFilter.all,
            options: const [
              (_DateFilter.all, 'All dates'),
              (_DateFilter.today, 'Today'),
              (_DateFilter.week, 'Last 7 days'),
              (_DateFilter.month, 'Last 30 days'),
            ],
            onSelected: (value) => setState(() => _date = value),
          ),
          const SizedBox(width: AppSpacing.sm),
          _menuChip<int>(
            label: _channelId == 0 ? 'Channel' : selectedChannel,
            value: _channelId,
            active: _channelId != 0,
            options: channelOptions,
            onSelected: (value) => setState(() => _channelId = value),
          ),
          const SizedBox(width: AppSpacing.sm),
          _menuChip<_StatusFilter>(
            label:
                _status == _StatusFilter.all ? 'Status' : _statusLabel(_status),
            value: _status,
            active: _status != _StatusFilter.all,
            options: const [
              (_StatusFilter.all, 'All status'),
              (_StatusFilter.paid, 'Paid'),
              (_StatusFilter.partial, 'Part paid'),
              (_StatusFilter.due, 'Due'),
            ],
            onSelected: (value) => setState(() => _status = value),
          ),
          if (_hasFilters) ...[
            const SizedBox(width: AppSpacing.sm),
            TextButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Clear'),
              style: TextButton.styleFrom(foregroundColor: scheme.primary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _menuChip<T>({
    required String label,
    required T value,
    required bool active,
    required List<(T, String)> options,
    required ValueChanged<T> onSelected,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return PopupMenuButton<T>(
      tooltip: label,
      initialValue: value,
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final option in options)
          PopupMenuItem<T>(
            value: option.$1,
            child: Text(option.$2),
          ),
      ],
      child: Chip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
        backgroundColor:
            active ? scheme.secondaryContainer : scheme.surfaceContainerLow,
        side: BorderSide(color: scheme.outlineVariant),
      ),
    );
  }

  bool get _hasFilters =>
      _query.trim().isNotEmpty ||
      _date != _DateFilter.all ||
      _channelId != 0 ||
      _status != _StatusFilter.all;

  List<SaleSummary> _apply(List<SaleSummary> items) {
    final query = _query.trim().toLowerCase();
    final cutoff = _cutoff();
    return items.where((sale) {
      if (cutoff != null) {
        final date = DateTime.fromMillisecondsSinceEpoch(sale.createdAt);
        if (date.isBefore(cutoff)) return false;
      }
      if (_channelId != 0 && sale.channelId != _channelId) return false;
      if (_status != _StatusFilter.all && sale.status != _status.name) {
        return false;
      }
      if (query.isEmpty) return true;
      final haystack = [
        sale.customerName ?? 'Walk-in',
        sale.itemsLabel,
        sale.channelName,
        'Sale #${sale.id}',
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  DateTime? _cutoff() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_date) {
      case _DateFilter.all:
        return null;
      case _DateFilter.today:
        return today;
      case _DateFilter.week:
        return today.subtract(const Duration(days: 6));
      case _DateFilter.month:
        return today.subtract(const Duration(days: 29));
    }
  }

  List<_DayGroup> _group(List<SaleSummary> items) {
    final groups = <DateTime, _DayGroup>{};
    for (final sale in items) {
      final time = DateTime.fromMillisecondsSinceEpoch(sale.createdAt);
      final day = DateTime(time.year, time.month, time.day);
      groups.putIfAbsent(day, () => _DayGroup(day: day)).sales.add(sale);
    }
    return groups.values.toList();
  }

  void _clearFilters() {
    _search.clear();
    setState(() {
      _query = '';
      _date = _DateFilter.all;
      _channelId = 0;
      _status = _StatusFilter.all;
    });
  }

  String _dateLabel(_DateFilter filter) {
    switch (filter) {
      case _DateFilter.all:
        return 'Date';
      case _DateFilter.today:
        return 'Today';
      case _DateFilter.week:
        return '7 days';
      case _DateFilter.month:
        return '30 days';
    }
  }

  String _statusLabel(_StatusFilter filter) {
    switch (filter) {
      case _StatusFilter.all:
        return 'Status';
      case _StatusFilter.paid:
        return 'Paid';
      case _StatusFilter.partial:
        return 'Part paid';
      case _StatusFilter.due:
        return 'Due';
    }
  }
}

class _DayGroup {
  final DateTime day;
  final List<SaleSummary> sales = [];

  _DayGroup({required this.day});

  int get totalMinor => sales.fold(0, (sum, sale) => sum + sale.totalMinor);
}

class _DaySection extends StatelessWidget {
  final _DayGroup group;

  const _DaySection({required this.group});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.md,
            bottom: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _label(context, group.day),
                  style: AppTextStyles.label.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              MoneyText(
                Money(group.totalMinor),
                style: AppTextStyles.label.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        for (final sale in group.sales)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _SaleTile(sale: sale),
          ),
      ],
    );
  }

  String _label(BuildContext context, DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (day == today) return 'Today';
    if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat('EEE, MMM d').format(day);
  }
}

class _SaleTile extends ConsumerWidget {
  final SaleSummary sale;

  const _SaleTile({required this.sale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final time = DateFormat('h:mm a').format(
      DateTime.fromMillisecondsSinceEpoch(sale.createdAt),
    );
    final customer = sale.customerName ?? 'Walk-in';
    final hasDue = sale.dueMinor > 0;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.card),
        onTap: () => context.push('/sales/${sale.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 56,
                child: Text(
                  time,
                  style: AppTextStyles.label.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      sale.itemsLabel.isEmpty
                          ? '${sale.itemCount} item${sale.itemCount == 1 ? '' : 's'}'
                          : sale.itemsLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        StatusChip(status: sale.status),
                        if (hasDue)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Due',
                                style: AppTextStyles.label.copyWith(
                                  color: scheme.error,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              MoneyText(
                                Money(sale.dueMinor),
                                style: AppTextStyles.label.copyWith(
                                  color: scheme.error,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              MoneyText(
                Money(sale.totalMinor),
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
