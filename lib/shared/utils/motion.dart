import 'package:flutter/animation.dart';

class MotionDurations {
  static const fast = Duration(milliseconds: 140);
  static const medium = Duration(milliseconds: 260);
  static const slow = Duration(milliseconds: 420);

  static Duration stagger(int index, {int baseMs = 180, int stepMs = 40}) {
    return Duration(milliseconds: baseMs + (index * stepMs));
  }
}

class MotionCurves {
  static const standard = Curves.easeOutCubic;
  static const emphasized = Curves.easeInOutCubic;
}

const Offset kPageSlideOffset = Offset(0, 0.04);
