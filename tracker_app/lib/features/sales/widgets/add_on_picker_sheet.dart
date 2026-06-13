import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/core/theme/app_colors.dart';
import 'package:tracker/core/utils/formatters.dart';
import 'package:tracker/core/widgets/app_bottom_nav.dart';
import 'package:tracker/core/widgets/glass_panel.dart';
import 'package:tracker/core/widgets/glass_text_field.dart';
import 'package:tracker/core/widgets/haptic_wrapper.dart';
import 'package:tracker/core/widgets/sheet_drag_handle.dart';
import 'package:tracker/db/app_database.dart';
import 'package:tracker/features/sales/add_on_repository.dart';

class AddOnEntry {
  final int typeId;
  final String name;
  double amount;

  AddOnEntry({
    required this.typeId,
    required this.name,
    required this.amount,
  });

  AddOnEntry copyWith({double? amount}) {
    return AddOnEntry(
      typeId: typeId,
      name: name,
      amount: amount ?? this.amount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddOnEntry && other.typeId == typeId;
  }

  @override
  int get hashCode => typeId.hashCode;
}

class AddOnPickerSheet extends ConsumerStatefulWidget {
  final List<AddOnEntry> initialEntries;

  const AddOnPickerSheet({super.key, required this.initialEntries});

  @override
  ConsumerState<AddOnPickerSheet> createState() => _AddOnPickerSheetState();
}

class _AddOnPickerSheetState extends ConsumerState<AddOnPickerSheet> {
  late List<AddOnEntry> _entries;
  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _entries = List.from(widget.initialEntries);
    for (var entry in _entries) {
      _controllers[entry.typeId] = TextEditingController(text: entry.amount.toStringAsFixed(2));
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  double get _totalCost => _entries.fold(0.0, (sum, e) => sum + e.amount);

  void _addAddOn(AddOnType type) {
    if (_entries.any((e) => e.typeId == type.id)) return;
    setState(() {
      _entries.add(AddOnEntry(
        typeId: type.id,
        name: type.name,
        amount: 0.0, // defaultAmount is missing from DB, using 0.0
      ));
      _controllers[type.id] = TextEditingController(text: '0.00');
    });
  }

  void _removeAddOn(int index) {
    final typeId = _entries[index].typeId;
    setState(() {
      _entries.removeAt(index);
      _controllers.remove(typeId);
    });
  }

  void _updateAmount(int index, String value) {
    final amount = double.tryParse(value.trim()) ?? 0.0;
    setState(() {
      _entries[index] = _entries[index].copyWith(amount: amount);
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeTypes = ref.watch(activeAddOnTypesProvider).value ?? [];
    final scheme = Theme.of(context).colorScheme;

    return GlassPanel(
      radius: 28,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      noBlur: true,
      solid: true,
      child: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetDragHandle(),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Add-Ons',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Selected Add-Ons
            if (_entries.isNotEmpty) ...[
              Text(
                'Selected',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              ..._entries.asMap().entries.map((entry) {
                final idx = entry.key;
                final item = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GlassPanel(
                    noBlur: true,
                    solid: true,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: GlassTextField(
                            label: 'Amount',
                            controller: _controllers[item.typeId],
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (v) => _updateAmount(idx, v),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18, color: AppColors.danger),
                          onPressed: () => _removeAddOn(idx),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
            ],

            // Available Add-Ons
            Text(
              'Available',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeTypes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final type = activeTypes[index];
                final isAdded = _entries.any((e) => e.typeId == type.id);
                return HapticWrapper(
                  onTap: isAdded ? null : () => _addAddOn(type),
                  child: GlassPanel(
                    noBlur: true,
                    solid: true,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            type.name,
                            style: TextStyle(
                              fontSize: 14,
                              color: isAdded 
                                  ? scheme.onSurfaceVariant.withOpacity(0.5) 
                                  : scheme.onSurface,
                            ),
                          ),
                        ),
                        Icon(
                          isAdded ? Icons.check_circle : Icons.add_circle_outline,
                          color: isAdded ? AppColors.success : scheme.primary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            
            // Footer
            GlassPanel.flush(
              padding: const EdgeInsets.all(16),
              noBlur: true,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total add-on cost',
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          formatMoney(_totalCost),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  HapticWrapper(
                    onTap: () => Navigator.of(context).pop(_entries),
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(_entries),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showAddOnPicker(BuildContext context, {required List<AddOnEntry> initialEntries}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (_) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom: math.max(
              MediaQuery.of(context).viewInsets.bottom,
              MediaQuery.of(context).padding.bottom + kBottomNavHeight + 8,
            ),
          ),
          child: AddOnPickerSheet(initialEntries: initialEntries),
        ),
      ],
    ),
  );
}
