import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:tracker/core/widgets/app_bottom_nav.dart';
import 'package:tracker/core/widgets/glass_panel.dart';
import 'package:tracker/core/widgets/glass_text_field.dart';
import 'package:tracker/core/widgets/haptic_wrapper.dart';
import 'package:tracker/core/widgets/sheet_drag_handle.dart';
import 'package:tracker/core/services/haptic_service.dart';
import 'package:tracker/db/app_database.dart';
import '../bucket_repository.dart';

class BucketFormSheet extends ConsumerStatefulWidget {
  final BudgetBucket? bucket;

  const BucketFormSheet({super.key, this.bucket});

  @override
  ConsumerState<BucketFormSheet> createState() => _BucketFormSheetState();
}

class _BucketFormSheetState extends ConsumerState<BucketFormSheet> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController();
  late final _amount = TextEditingController();
  String? _selectedColor;

  final List<String> _availableColors = [
    '#FF5252', '#FF4081', '#E040FB', '#7C4DFF',
    '#536DFE', '#448AFF', '#40C4FF', '#18FFFF',
    '#64FFDA', '#69F0AE', '#B2FF59', '#EEFF41',
    '#FFFF00', '#FFD740', '#FFAB40', '#FF6E40',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.bucket != null) {
      _name.text = widget.bucket!.name;
      _amount.text = widget.bucket!.allocatedAmount.toStringAsFixed(2);
      _selectedColor = widget.bucket!.color;
    } else {
      _name.text = '';
      _amount.text = '0.00';
      _selectedColor = '#1D9E75';
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  bool _saving = false;

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final repo = ref.read(bucketRepositoryProvider);
      final name = _name.text.trim();
      final amount = double.tryParse(_amount.text.trim()) ?? 0.0;

      if (widget.bucket == null) {
        await repo.create(name: name, allocatedAmount: amount, color: _selectedColor);
      } else {
        await repo.update(
          id: widget.bucket!.id,
          name: name,
          allocatedAmount: amount,
          color: _selectedColor,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving bucket: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 28,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      noBlur: true,
      solid: true,
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetDragHandle(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.bucket == null ? 'Add Bucket' : 'Edit Bucket',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                ),
                HapticWrapper(
                  profile: HapticProfile.light,
                  onTap: () => Navigator.of(context).pop(),
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GlassTextField(
              controller: _name,
              label: 'Bucket Name',
              hint: 'e.g. Emergency Fund, Vacation',
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            GlassTextField(
              controller: _amount,
              label: 'Allocated Amount',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (double.tryParse(v.trim()) == null) return 'Invalid amount';
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Bucket Color',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableColors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () {
                    HapticService.trigger(HapticProfile.light);
                    setState(() => _selectedColor = color);
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Color(int.parse(color.replaceFirst('#', '0xff'))),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: Colors.black26, blurRadius: 4)]
                          : [],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            HapticWrapper(
              profile: HapticProfile.medium,
              onTap: _saving ? null : _save,
              child: FilledButton(
                onPressed: null,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Bucket'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showBucketFormSheet(
  BuildContext context, {
  BudgetBucket? bucket,
}) {
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
          child: BucketFormSheet(bucket: bucket),
        ),
      ],
    ),
  );
}
