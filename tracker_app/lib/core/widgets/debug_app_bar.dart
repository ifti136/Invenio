import 'package:flutter/material.dart';
import 'debug_borders.dart';

class DebugAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Color borderColor;

  const DebugAppBar({
    super.key,
    required this.title,
    this.actions,
    this.borderColor = kDebugAppBarColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return DebugBorders(
      label: 'APPBAR',
      color: borderColor,
      child: AppBar(
        title: Text(title),
        actions: actions,
      ),
    );
  }
}
