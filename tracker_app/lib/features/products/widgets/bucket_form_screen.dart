import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/core/widgets/glass_panel.dart';
import 'package:tracker/core/widgets/glass_text_field.dart';
import 'package:tracker/core/theme/app_colors.dart';
import '../bucket_repository.dart';


class BucketFormScreen extends ConsumerStatefulWidget {
  final int? bucketId;

  const BucketFormScreen({super.key, this.bucketId});

  @override
  ConsumerState<BucketFormScreen> createState() => _BucketFormScreenState();
}

class _BucketFormScreenState extends ConsumerState<BucketFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  Color _selectedColor = AppColors.accent;

  final List<Color> _availableColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    AppColors.accent,
  ];

  @override
  void initState() {
    super.initState();
    _loadBucketData();
  }

  Future<void> _loadBucketData() async {
    if (widget.bucketId != null) {
      final bucket = await ref.read(bucketRepositoryProvider).getById(widget.bucketId!);
      if (bucket != null) {
        setState(() {
          _nameController.text = bucket.name;
          _amountController.text = bucket.allocatedAmount.toStringAsFixed(2);
          if (bucket.color != null) {
            _selectedColor = Color(int.parse(bucket.color!));
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final colorValue = _selectedColor.value.toString();

    if (widget.bucketId == null) {
      await ref.read(bucketRepositoryProvider).create(
            name: name,
            allocatedAmount: amount,
            color: colorValue,
          );
    } else {
      await ref.read(bucketRepositoryProvider).update(
            id: widget.bucketId!,
            name: name,
            allocatedAmount: amount,
            color: colorValue,
          );
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.bucketId != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Bucket' : 'New Bucket'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassPanel(
                noBlur: true,
                child: Column(
                  children: [
                    GlassTextField(
                      controller: _nameController,
                      label: 'Bucket Name',
                      validator: (value) => (value == null || value.isEmpty) ? 'Please enter a name' : null,
                    ),
                    const SizedBox(height: 16),
                    GlassTextField(
                      controller: _amountController,
                      label: 'Allocated Amount',
                      keyboardType: TextInputType.number,
                      validator: (value) => (value == null || double.tryParse(value) == null) ? 'Please enter a valid amount' : null,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Bucket Color',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _availableColors.map((color) {
                        return ChoiceChip(
                          label: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24),
                            ),
                          ),
                          selected: _selectedColor == color,
                          onSelected: (selected) {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                          selectedColor: Colors.white10,
                          backgroundColor: Colors.transparent,
                          labelStyle: const TextStyle(color: Colors.transparent),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _save,
                  child: const Text('Save Bucket', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
