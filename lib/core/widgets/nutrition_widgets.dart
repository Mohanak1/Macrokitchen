import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';
import '../../features/meals/domain/entities/meal.dart';

// ─── Macro Ring / Donut Chart ─────────────────────────────────────────────────

class MacroRingChart extends StatelessWidget {
  final double consumed; // calories consumed
  final double target; // daily target
  final double carbs;
  final double protein;
  final double fats;

  const MacroRingChart({
    super.key,
    required this.consumed,
    required this.target,
    required this.carbs,
    required this.protein,
    required this.fats,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = (target - consumed).clamp(0, target);
    final progress = consumed / target;

    return Column(
      children: [
        // Progress display
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              consumed.toStringAsFixed(0),
              style: AppTextStyles.headlineLarge.copyWith(
                color: AppColors.primary,
                fontSize: 28,
              ),
            ),
            Text(
              target.toStringAsFixed(0),
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.md),

        // Donut chart
        SizedBox(
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  startDegreeOffset: -90,
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                  sections: [
                    PieChartSectionData(
                      value: consumed.clamp(0, target),
                      color: _progressColor(progress),
                      radius: 30,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      value: remaining.toDouble(),
                      color: AppColors.chartBackground,
                      radius: 28,
                      showTitle: false,
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: AppTextStyles.headlineLarge.copyWith(
                      fontSize: 22,
                      color: _progressColor(progress),
                    ),
                  ),
                  const Text(
                    'consumed',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppDimensions.lg),

        // Macro breakdown
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _MacroLabel(
                label: 'Calories',
                value: consumed.toStringAsFixed(0),
                color: AppColors.calories),
            _MacroLabel(
                label: 'Carbs',
                value: '${carbs.toStringAsFixed(0)}g',
                color: AppColors.carbs),
            _MacroLabel(
                label: 'Fats',
                value: '${fats.toStringAsFixed(0)}g',
                color: AppColors.fats),
            _MacroLabel(
                label: 'Protein',
                value: '${protein.toStringAsFixed(0)}g',
                color: AppColors.protein),
          ],
        ),
      ],
    );
  }

  Color _progressColor(double progress) {
    if (progress < 0.5) return AppColors.success;
    if (progress < 0.85) return AppColors.warning;
    return AppColors.error;
  }
}

class _MacroLabel extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroLabel({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.macroLabel),
        Text(value, style: AppTextStyles.macroValue.copyWith(fontSize: 14)),
      ],
    );
  }
}

// ─── Meal Card ────────────────────────────────────────────────────────────────

class MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback? onTap;
  final bool showWarning;
  final List<String>? warnings;
  final double? score;

  const MealCard({
    super.key,
    required this.meal,
    this.onTap,
    this.showWarning = false,
    this.warnings,
    this.score,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.md),
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: showWarning
              ? Border.all(color: AppColors.allergyWarning, width: 1.5)
              : Border.all(color: AppColors.border, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.border.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Meal image / icon
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              child: meal.imageUrl != null && meal.imageUrl!.isNotEmpty
                  ? Image.network(
                      meal.imageUrl!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _defaultIcon(),
                    )
                  : _defaultIcon(),
            ),
            const SizedBox(width: AppDimensions.md),

            // Meal info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          meal.title,
                          style: AppTextStyles.headlineSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${meal.calories.toStringAsFixed(0)} kCal',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Macros row
                  Row(
                    children: [
                      _MicroChip(
                          label: 'P: ${meal.protein.toStringAsFixed(0)}g',
                          color: AppColors.protein),
                      const SizedBox(width: AppDimensions.xs),
                      _MicroChip(
                          label: 'C: ${meal.carbs.toStringAsFixed(0)}g',
                          color: AppColors.carbs),
                      const SizedBox(width: AppDimensions.xs),
                      if (meal.totalFat != null)
                        _MicroChip(
                            label: 'F: ${meal.totalFat!.toStringAsFixed(0)}g',
                            color: AppColors.fats),
                    ],
                  ),

                  if (showWarning &&
                      warnings != null &&
                      warnings!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: AppColors.allergyWarning, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          _warningText(warnings!),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.allergyWarning,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            if (score != null) ...[
              const SizedBox(width: AppDimensions.sm),
              Column(
                children: [
                  const Icon(Icons.star_rounded,
                      color: AppColors.rating, size: 16),
                  Text(
                    (score! / 20).toStringAsFixed(1),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _defaultIcon() {
    return Container(
      width: 56,
      height: 56,
      color: AppColors.inputFill,
      child: const Icon(Icons.restaurant, color: AppColors.primary),
    );
  }

  String _warningText(List<String> warnings) {
    if (warnings.contains('allergen')) return 'Contains allergen';
    if (warnings.contains('high_sodium')) return 'High sodium';
    if (warnings.contains('high_sugar')) return 'High sugar';
    return 'Health warning';
  }
}

class _MicroChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MicroChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Nutrition Info Row ───────────────────────────────────────────────────────

class NutritionRow extends StatelessWidget {
  final String label;
  final String value;

  const NutritionRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(value, style: AppTextStyles.labelLarge),
        ],
      ),
    );
  }
}
