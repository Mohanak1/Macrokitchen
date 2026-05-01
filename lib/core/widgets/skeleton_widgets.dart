import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// Shimmering skeleton for a meal card during loading
class MealCardSkeleton extends StatelessWidget {
  const MealCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.surfaceVariant,
        highlightColor: Colors.white,
        child: Row(
          children: [
            // Image placeholder
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusXs),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  // Macro chips row
                  Row(
                    children: List.generate(
                      3,
                      (i) => Container(
                        margin: const EdgeInsets.only(right: AppDimensions.sm),
                        height: 10,
                        width: 50,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusXs),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A list of skeleton meal cards
class MealListSkeleton extends StatelessWidget {
  final int count;
  const MealListSkeleton({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pagePaddingH),
      itemCount: count,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, __) => const MealCardSkeleton(),
    );
  }
}

/// Skeleton for the calorie ring / home screen header
class HomeHeaderSkeleton extends StatelessWidget {
  const HomeHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceVariant,
      highlightColor: Colors.white,
      child: Container(
        margin: const EdgeInsets.all(AppDimensions.pagePaddingH),
        height: 280,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
      ),
    );
  }
}

/// Generic block skeleton (for any rectangular area)
class BlockSkeleton extends StatelessWidget {
  final double height;
  final double? width;
  final double radius;

  const BlockSkeleton({
    super.key,
    required this.height,
    this.width,
    this.radius = AppDimensions.radiusMd,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceVariant,
      highlightColor: Colors.white,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
