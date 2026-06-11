import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/glass_text_field.dart';
import 'allocation_rules_repository.dart';


class AllocationRuleFormScreen extends ConsumerStatefulWidget {
  final int? ruleId;
  final String? initialLabel;
  final double? initialPercentage;
  final bool? initialIsActive;

  const AllocationRuleFormScreen({
    super.key,
    this.ruleId,
    this.initialLabel,
    this.initialPercentage,
    this.initialIsActive,
  });

  @override
  ConsumerState<AllocationRuleFormScreen> createState() => _AllocationRuleFormScreenState();
}

class _AllocationRuleFormScreenState extends ConsumerState<AllocationRuleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labelController;
  late TextEditingController _percentageController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.initialLabel);
    _percentageController = TextEditingController(text: widget.initialPercentage?.toString());
    _isActive = widget.initialIsActive ?? true;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _percentageController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final label = _labelController.text.trim();
    final percentage = double.tryParse(_percentageController.text.trim()) ?? 0.0;
    final repo = ref.read(allocationRulesRepositoryProvider);

    if (widget.ruleId != null) {
      await repo.updateRule(widget.ruleId!, label, percentage, _isActive);
    } else {
      await repo.createRule(label, percentage, _isActive);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.ruleId != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Rule' : 'New Allocation Rule'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               GlassTextField(
                 controller: _labelController,
                 label: 'Rule Label',
                 hint: 'e.g. Savings, Tax, Reinvestment',
                 validator: (value) {
                   if (value == null || value.trim().isEmpty) return 'Label is required';
                   return null;
                 },
               ),
               const SizedBox(height: 16),
               GlassTextField(
                 controller: _percentageController,
                 label: 'Percentage (%)',
                 hint: '0.0 - 100.0',
                 keyboardType: TextInputType.numberWithOptions(decimal: true),
                 validator: (value) {
                   if (value == null || value.trim().isEmpty) return 'Percentage is required';
                   final p = double.tryParse(value.trim());
                   if (p == null) return 'Invalid number';
                   if (p < 0 || p > 100) return 'Must be between 0 and 100';
                   return null;
                 },
               ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Active', style: TextStyle(color: Colors.white)),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
                activeColor: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(isEditing ? 'Update Rule' : 'Create Rule'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
