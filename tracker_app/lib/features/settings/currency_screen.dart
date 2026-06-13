import 'package:flutter/material.dart';

class CurrencyScreen extends StatelessWidget {
  const CurrencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CURRENCY')),
      body: const Center(child: Text('Currency Configuration')),
    );
  }
}
