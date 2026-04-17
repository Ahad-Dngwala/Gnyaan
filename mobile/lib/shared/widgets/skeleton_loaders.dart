import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:gnyaan/core/theme/app_colors.dart';
import 'package:gnyaan/core/constants/app_constants.dart';

/// Skeleton shimmer placeholder for document cards
class SkeletonDocumentCard extends StatelessWidget {
  const SkeletonDocumentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bg500,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _SkeletonBox(width: 40, height: 40, radius: 12),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonBox(width: double.infinity, height: 14, radius: 4),
                      const SizedBox(height: 6),
                      _SkeletonBox(width: 80, height: 10, radius: 4),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SkeletonBox(width: double.infinity, height: 10, radius: 4),
            const SizedBox(height: 6),
            _SkeletonBox(width: 200, height: 10, radius: 4),
            const SizedBox(height: 16),
            _SkeletonBox(width: double.infinity, height: 4, radius: 2),
          ],
        ),
      ),
    );
  }
}

/// Skeleton shimmer for list items
class SkeletonListItem extends StatelessWidget {
  const SkeletonListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            _SkeletonBox(width: 48, height: 48, radius: 12),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBox(width: double.infinity, height: 14, radius: 4),
                  const SizedBox(height: 8),
                  _SkeletonBox(width: 140, height: 10, radius: 4),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _SkeletonBox(width: 60, height: 24, radius: 12),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for search results
class SkeletonSearchResult extends StatelessWidget {
  const SkeletonSearchResult({super.key});

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bg500,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SkeletonBox(width: 120, height: 10, radius: 4),
            const SizedBox(height: 10),
            _SkeletonBox(width: double.infinity, height: 14, radius: 4),
            const SizedBox(height: 6),
            _SkeletonBox(width: double.infinity, height: 10, radius: 4),
            const SizedBox(height: 6),
            _SkeletonBox(width: 180, height: 10, radius: 4),
          ],
        ),
      ),
    );
  }
}

/// Inner shimmer wrapper
class _Shimmer extends StatelessWidget {
  const _Shimmer({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.bg500,
      highlightColor: AppColors.bg400,
      period: const Duration(milliseconds: 1400),
      child: child,
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    this.radius = 4,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.bg400,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
