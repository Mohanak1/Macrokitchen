import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/nutrition_widgets.dart';
import '../../../bmi/presentation/providers/bmi_provider.dart';
import '../providers/meals_provider.dart';

class MealDetailScreen extends ConsumerWidget {
  final String mealId;
  const MealDetailScreen({super.key, required this.mealId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealAsync = ref.watch(mealByIdProvider(mealId));
    final bmiAsync = ref.watch(bmiProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Meal Details')),
      body: mealAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
        data: (meal) {
          if (meal == null) {
            return const AppEmptyWidget(message: 'Meal not found.');
          }

          // Check allergens against user profile
          final profile = bmiAsync.value;
          final userAllergies =
              profile?.allergies.map((a) => a.toLowerCase()).toSet() ?? {};
          final mealAllergens =
              meal.allergens.map((a) => a.toLowerCase()).toSet();
          final matchingAllergens = userAllergies.intersection(mealAllergens);
          final hasAllergen = matchingAllergens.isNotEmpty;

          // Condition warnings
          final conditions = profile?.conditions ?? [];
          final warnings = <String>[];
          if (conditions.any((c) => c.contains('high_bp')) &&
              (meal.sodium ?? 0) > 800) {
            warnings.add('High Sodium — not suitable for High BP');
          }
          if (conditions.any((c) => c.contains('diabetes')) &&
              (meal.sugar ?? 0) > 15) {
            warnings.add('High Sugar — not suitable for Diabetes');
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meal image
                meal.imageUrl != null && meal.imageUrl!.isNotEmpty
                    ? Image.network(
                        meal.imageUrl!,
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: double.infinity,
                        height: 200,
                        color: AppColors.inputFill,
                        child: const Icon(Icons.restaurant,
                            color: AppColors.primary, size: 64),
                      ),

                Padding(
                  padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(meal.title,
                                style: AppTextStyles.headlineLarge),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: AppColors.rating, size: 18),
                              const SizedBox(width: 2),
                              Text(
                                meal.rating.toStringAsFixed(1),
                                style: AppTextStyles.labelLarge,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(meal.restaurantName,
                          style: AppTextStyles.bodyMedium),

                      const SizedBox(height: AppDimensions.xl),

                      // ── Allergen Warning ─────────────────────────────────
                      if (hasAllergen) ...[
                        _WarningBanner(
                          icon: Icons.warning_amber_rounded,
                          color: AppColors.error,
                          bgColor: Colors.red.shade50,
                          message:
                              'This meal contains allergens you are sensitive to: ${matchingAllergens.join(', ')}',
                        ),
                        const SizedBox(height: AppDimensions.lg),
                      ],

                      // ── Condition Warnings ────────────────────────────────
                      ...warnings.map((w) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppDimensions.md),
                            child: _WarningBanner(
                              icon: Icons.info_outline,
                              color: AppColors.warning,
                              bgColor: Colors.orange.shade50,
                              message: w,
                            ),
                          )),

                      // ── Macro summary ────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _MacroBlock(
                            label: 'Calories',
                            value: meal.calories.toStringAsFixed(0),
                            unit: 'kCal',
                            color: AppColors.calories,
                          ),
                          _MacroBlock(
                            label: 'Protein',
                            value: meal.protein.toStringAsFixed(0),
                            unit: 'g',
                            color: AppColors.protein,
                          ),
                          _MacroBlock(
                            label: 'Carbs',
                            value: meal.carbs.toStringAsFixed(0),
                            unit: 'g',
                            color: AppColors.carbs,
                          ),
                          if (meal.totalFat != null)
                            _MacroBlock(
                              label: 'Fat',
                              value: meal.totalFat!.toStringAsFixed(0),
                              unit: 'g',
                              color: AppColors.fats,
                            ),
                        ],
                      ),

                      const SizedBox(height: AppDimensions.xl),

                      // ── Full Nutrition Table ──────────────────────────────
                      const Text('Nutrition Facts',
                          style: AppTextStyles.headlineMedium),
                      const SizedBox(height: AppDimensions.md),
                      const Divider(),
                      NutritionRow(
                          label: 'Calories',
                          value: '${meal.calories.toStringAsFixed(0)} kCal'),
                      const Divider(),
                      NutritionRow(
                          label: 'Protein',
                          value: '${meal.protein.toStringAsFixed(0)}g'),
                      const Divider(),
                      NutritionRow(
                          label: 'Carbohydrates',
                          value: '${meal.carbs.toStringAsFixed(0)}g'),
                      if (meal.totalFat != null) ...[
                        const Divider(),
                        NutritionRow(
                            label: 'Total Fat',
                            value: '${meal.totalFat!.toStringAsFixed(0)}g'),
                      ],
                      if (meal.saturatedFat != null) ...[
                        const Divider(),
                        NutritionRow(
                            label: '  Saturated Fat',
                            value: '${meal.saturatedFat!.toStringAsFixed(0)}g'),
                      ],
                      if (meal.sodium != null) ...[
                        const Divider(),
                        NutritionRow(
                            label: 'Sodium',
                            value: '${meal.sodium!.toStringAsFixed(0)}mg'),
                      ],
                      if (meal.sugar != null) ...[
                        const Divider(),
                        NutritionRow(
                            label: 'Sugar',
                            value: '${meal.sugar!.toStringAsFixed(0)}g'),
                      ],
                      if (meal.fiber != null) ...[
                        const Divider(),
                        NutritionRow(
                            label: 'Fiber',
                            value: '${meal.fiber!.toStringAsFixed(0)}g'),
                      ],

                      // ── Allergens ─────────────────────────────────────────
                      if (meal.allergens.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.xl),
                        const Text('Contains',
                            style: AppTextStyles.headlineSmall),
                        const SizedBox(height: AppDimensions.sm),
                        Wrap(
                          spacing: AppDimensions.sm,
                          runSpacing: AppDimensions.sm,
                          children: meal.allergens.map((a) {
                            final isUserAllergen =
                                userAllergies.contains(a.toLowerCase());
                            return Chip(
                              label: Text(a,
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: isUserAllergen
                                        ? AppColors.error
                                        : AppColors.textSecondary,
                                  )),
                              backgroundColor: isUserAllergen
                                  ? Colors.red.shade50
                                  : AppColors.surfaceVariant,
                              side: BorderSide(
                                color: isUserAllergen
                                    ? AppColors.error
                                    : AppColors.border,
                              ),
                            );
                          }).toList(),
                        ),
                      ],

                      const SizedBox(height: AppDimensions.huge),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String message;

  const _WarningBanner({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: AppDimensions.iconLg),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroBlock extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _MacroBlock({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: AppTextStyles.labelLarge.copyWith(color: color),
                ),
                Text(unit, style: AppTextStyles.caption.copyWith(color: color)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
