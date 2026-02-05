import 'package:flutter/material.dart';

import '../utils/motion.dart';

class SkeletonBox extends StatefulWidget {
  const SkeletonBox({super.key, required this.height, this.width});

  final double height;
  final double? width;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: MotionDurations.slow,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.surfaceVariant;
    final highlight = Theme.of(context).colorScheme.onSurfaceVariant
        .withOpacity(0.1);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment(-1 - _controller.value, -0.2),
              end: Alignment(1 + _controller.value, 0.2),
              colors: [
                baseColor,
                highlight,
                baseColor,
              ],
            ),
          ),
        );
      },
    );
  }
}

class ListingCardSkeleton extends StatelessWidget {
  const ListingCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SkeletonBox(height: 16, width: 160),
            SizedBox(height: 12),
            SkeletonBox(height: 14, width: 220),
            SizedBox(height: 12),
            SkeletonBox(height: 12, width: 120),
            SizedBox(height: 16),
            SkeletonBox(height: 36, width: 140),
          ],
        ),
      ),
    );
  }
}

class DetailsSkeleton extends StatelessWidget {
  const DetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        SkeletonBox(height: 24, width: 220),
        SizedBox(height: 12),
        SkeletonBox(height: 16, width: 180),
        SizedBox(height: 24),
        SkeletonBox(height: 80),
        SizedBox(height: 24),
        SkeletonBox(height: 16, width: 160),
        SizedBox(height: 12),
        SkeletonBox(height: 60),
      ],
    );
  }
}
