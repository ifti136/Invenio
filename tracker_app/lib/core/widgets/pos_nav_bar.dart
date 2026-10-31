import 'package:flutter/material.dart';

import '../services/haptic_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import 'glass_panel.dart';
import 'nav_metrics.dart';

class PosNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onSell;
  final int lowStockCount;

  const PosNavBar({
    super.key,
    required this.currentIndex,
    required this.onSelect,
    required this.onSell,
    this.lowStockCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kBottomNavHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: GlassPanel(
                radius: 22,
                isFrostedGlass: true,
                padding: EdgeInsets.zero,
                child: Row(
                  children: [
                    Expanded(
                      child: _NavSlot(
                        icon: Icons.home_outlined,
                        selectedIcon: Icons.home_rounded,
                        label: 'Home',
                        selected: currentIndex == 0,
                        onTap: () => onSelect(0),
                      ),
                    ),
                    Expanded(
                      child: _NavSlot(
                        icon: Icons.inventory_2_outlined,
                        selectedIcon: Icons.inventory_2_rounded,
                        label: 'Products',
                        selected: currentIndex == 1,
                        onTap: () => onSelect(1),
                        badgeCount: lowStockCount,
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    Expanded(
                      child: _NavSlot(
                        icon: Icons.bar_chart_outlined,
                        selectedIcon: Icons.bar_chart_rounded,
                        label: 'Reports',
                        selected: currentIndex == 2,
                        onTap: () => onSelect(2),
                      ),
                    ),
                    Expanded(
                      child: _NavSlot(
                        icon: Icons.more_horiz_rounded,
                        selectedIcon: Icons.more_horiz_rounded,
                        label: 'More',
                        selected: currentIndex == 3,
                        onTap: () => onSelect(3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -8,
            left: 0,
            right: 0,
            child: Center(
              child: _PosButton(onTap: onSell),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavSlot extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;

  const _NavSlot({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accentInk = AppColors.accentInkFor(Theme.of(context).brightness);
    final color = selected ? accentInk : scheme.onSurfaceVariant;

    Widget iconWidget = Icon(
      selected ? selectedIcon : icon,
      size: 22,
      color: color,
    );

    if (badgeCount > 0) {
      iconWidget = Badge(
        isLabelVisible: true,
        label: Text('$badgeCount'),
        child: iconWidget,
      );
    }

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.input),
        onTap: () {
          HapticService.trigger(HapticProfile.light);
          onTap();
        },
        child: SizedBox(
          height: 48,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconWidget,
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PosButton extends StatefulWidget {
  final VoidCallback onTap;

  const _PosButton({required this.onTap});

  @override
  State<_PosButton> createState() => _PosButtonState();
}

class _PosButtonState extends State<_PosButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Semantics(
      button: true,
      label: 'New sale',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () {
          HapticService.trigger(HapticProfile.medium);
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _pressed && !reduceMotion ? 0.96 : 1,
          duration: Duration(milliseconds: reduceMotion ? 0 : 120),
          curve: Curves.easeOut,
          child: Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.point_of_sale_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
