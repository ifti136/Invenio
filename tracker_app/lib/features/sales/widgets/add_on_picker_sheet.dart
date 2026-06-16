import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/core/theme/app_colors.dart';
import 'package:tracker/core/utils/formatters.dart';
import 'package:tracker/core/widgets/app_bottom_nav.dart';
import 'package:tracker/core/widgets/glass_panel.dart';
import 'package:tracker/core/widgets/glass_text_field.dart';
import 'package:tracker/core/widgets/haptic_wrapper.dart';
import 'package:tracker/core/services/haptic_service.dart';
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
      _controllers[entry.typeId] =
          TextEditingController(text: entry.amount.toStringAsFixed(2));
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

  void _toggleAddOn(AddOnType type) {
    final existingIndex = _entries.indexWhere((e) => e.typeId == type.id);
    if (existingIndex != -1) {
      _removeAddOn(existingIndex);
    } else {
      _addAddOn(type);
    }
  }

  void _addAddOn(AddOnType type) {
    setState(() {
      _entries.add(AddOnEntry(
        typeId: type.id,
        name: type.name,
        amount: 0.0,
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

  void _updateAmount(int typeId, String value) {
    final amount = double.tryParse(value.trim()) ?? 0.0;
    final index = _entries.indexWhere((e) => e.typeId == typeId);
    if (index != -1) {
      setState(() {
        _entries[index] = _entries[index].copyWith(amount: amount);
      });
    }
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
                HapticWrapper(
                  profile: HapticProfile.light,
                  onTap: null,
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activeTypes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final type = activeTypes[index];
                  final entry = _entries.cast<AddOnEntry?>().firstWhere(
                        (e) => e?.typeId == type.id,
                        orElse: () => null,
                      );
                  final isSelected = entry != null;

                  return HapticWrapper(
                    profile: HapticProfile.light,
                    onTap: null,
                    child: GlassPanel(
                      noBlur: true,
                      solid: true,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => _toggleAddOn(type),
                            child: Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: isSelected
                                  ? AppColors.success
                                  : scheme.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              type.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? scheme.onSurface
                                    : scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          if (isSelected)
                            SizedBox(
                              width: 100,
                              child: GlassTextField(
                                label: 'Amount',
                                controller: _controllers[type.id],
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                onChanged: (v) => _updateAmount(type.id, v),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
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
                    profile: HapticProfile.medium,
                    onTap: null,
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

Future<List<AddOnEntry>?> showAddOnPicker(BuildContext context,
    {required List<AddOnEntry> initialEntries}) {
  return showModalBottomSheet(
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
