import 'package:flutter/material.dart';

class DebugBorders extends StatelessWidget {
  final Widget child;
  final String label;
  final Color color;
  final double borderWidth;

  const DebugBorders({
    super.key,
    required this.child,
    required this.label,
    required this.color,
    this.borderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(border: Border.all(color: color, width: borderWidth)),
      child: Stack(
        children: [
          child,
          Positioned(
            top: 2,
            left: 4,
            child: Container(
              color: color.withOpacity(0.9),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const Color kDebugFieldColor = Color(0xFFFF00FF);
const Color kDebugPanelColor = Colors.orange;
const Color kDebugAppBarColor = Colors.yellow;
const Color kDebugBodyColor = Colors.green;
const Color kDebugNavColor = Colors.blue;
const Color kDebugStackColor = Colors.red;
const Color kDebugButtonColor = Colors.teal;
