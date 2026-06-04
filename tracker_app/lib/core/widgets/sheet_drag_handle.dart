import 'package:flutter/material.dart';

class SheetDragHandle extends StatelessWidget {
  const SheetDragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: scheme.onSurfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
