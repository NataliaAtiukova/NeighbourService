import 'package:flutter/material.dart';

import '../utils/motion.dart';

class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    required this.index,
    this.animate = true,
  });

  final Widget child;
  final int index;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    if (!animate) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: MotionDurations.stagger(index),
      curve: MotionCurves.standard,
      child: child,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 14),
            child: child,
          ),
        );
      },
    );
  }
}
