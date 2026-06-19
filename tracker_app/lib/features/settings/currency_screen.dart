import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/glass_panel.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_text_field.dart';
import '../../core/utils/formatters.dart';
import '../../core/services/haptic_service.dart';
import '../../core/services/currency_service.dart';

class CurrencyScreen extends ConsumerStatefulWidget {
  const CurrencyScreen({super.key});

  @override
  ConsumerState<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends ConsumerState<CurrencyScreen> {
  late final _symbol = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final symbol = ref.read(currencySymbolProvider);
      _symbol.text = symbol;
    });
  }

  @override
  void dispose() {
    _symbol.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final symbol = _symbol.text.trim();
    if (symbol.isEmpty) return;
    final service = await ref.read(currencyServiceProvider.future);
    await service.setSymbol(symbol);
    setCurrencySymbol(symbol);
    ref.invalidate(currencySymbolProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Currency symbol updated')),
      );
    }
  }

  Future<void> _reset() async {
    final service = await ref.read(currencyServiceProvider.future);
    await service.reset();
    setCurrencySymbol('৳');
    ref.invalidate(currencySymbolProvider);
    setState(() {
      _symbol.text = '৳';
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Currency reset to default')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CURRENCY'),
        centerTitle: true,
      ),
      body: Center(
        child: GlassPanel(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.currency_exchange,
                  size: 48, color: AppColors.accent),
              const SizedBox(height: 16),
              const Text(
                'Currency Configuration',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'Set your preferred currency symbol and formatting.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              GlassTextField(
                controller: _symbol,
                label: 'Currency Symbol',
                hint: 'e.g. USD',
                onChanged: (v) {},
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        HapticService.trigger(HapticProfile.light);
                        _reset();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        HapticService.trigger(HapticProfile.medium);
                        _save();
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
