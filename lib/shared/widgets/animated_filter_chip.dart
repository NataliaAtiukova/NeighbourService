import 'package:flutter/material.dart';

import '../utils/motion.dart';

class AnimatedFilterChip extends StatelessWidget {
  const AnimatedFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outline = theme.colorScheme.outline;
    final primary = theme.colorScheme.primary;
    return AnimatedScale(
      duration: MotionDurations.fast,
      curve: MotionCurves.standard,
      scale: selected ? 1.02 : 1.0,
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: onSelected,
        avatar: icon == null ? null : Icon(icon, size: 18),
        side: BorderSide(color: selected ? primary : outline),
        selectedColor: primary.withOpacity(0.18),
        showCheckmark: false,
      ),
    );
  }
}
