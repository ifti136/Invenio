import 'package:flutter/material.dart';
import 'glass_panel.dart';

Future<void> showGlassDialog({
  required BuildContext context,
  String? title,
  String? message,
  Widget? content,
  List<Widget> actions = const [],
  bool barrierDismissible = true,
}) {
  final scheme = Theme.of(context).colorScheme;
  return showDialog<void>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black.withOpacity(0.35),
    builder: (ctx) {
      return Dialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: GlassPanel(
          radius: 24,
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null) ...[
                Text(
                  title,
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
              ],
              if (message != null)
                Text(
                  message,
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              if (content != null) ...[
                if (message != null || title != null) const SizedBox(height: 12),
                content,
              ],
              if (actions.isNotEmpty) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (var i = 0; i < actions.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      actions[i],
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

class GlassDialogAction extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isDestructive;
  final bool isPrimary;

  const GlassDialogAction({
    super.key,
    required this.label,
    this.onPressed,
    this.isDestructive = false,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final Color fg = isDestructive
        ? scheme.error
        : (isPrimary ? scheme.primary : scheme.onSurfaceVariant);
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: fg,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      child: Text(label),
    );
  }
}
