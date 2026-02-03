import 'package:flutter/material.dart';

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, required this.height, this.width});

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
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
