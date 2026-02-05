import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/motion.dart';

class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    this.enableHaptics = false,
  });

  final Widget child;
  final bool enableHaptics;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        if (widget.enableHaptics) {
          HapticFeedback.selectionClick();
        }
        setState(() => _pressed = true);
      },
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: MotionDurations.fast,
        curve: MotionCurves.standard,
        scale: _pressed ? 0.98 : 1,
        child: widget.child,
      ),
    );
  }
}
