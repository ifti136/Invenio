import 'package:flutter/material.dart';

class SystemSettingsScreen extends StatelessWidget {
  const SystemSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SYSTEM')),
      body: const Center(child: Text('App Version & Data Management')),
    );
  }
}
