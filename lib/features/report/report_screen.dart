import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/bmi_calculator.dart';
import '../../core/widgets/app_widgets.dart';
import '../bmi/presentation/providers/bmi_provider.dart';
import '../history/presentation/providers/history_provider.dart';
import '../home_meals/presentation/providers/home_meals_provider.dart';

class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bmiAsync = ref.watch(bmiProfileProvider);
    final historyAsync = ref.watch(historyProvider);
    final homeMealsAsync = ref.watch(homeMealsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Report',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export/share coming soon')),
              );
            },
          ),
        ],
      ),
      body: bmiAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
        data: (profile) {
          if (profile == null) {
            return const AppEmptyWidget(
              message: 'Complete your BMI setup to generate a report.',
              icon: Icons.summarize_outlined,
            );
          }

          final history = historyAsync.value ?? [];
          final homeMeals = homeMealsAsync.value ?? [];

          // Aggregate totals from history
          final totalCal = history.fold<double>(0, (s, e) => s + e.calories) +
              homeMeals.fold<double>(0, (s, m) => s + m.calories);
          final totalProtein =
              history.fold<double>(0, (s, e) => s + e.protein) +
                  homeMeals.fold<double>(0, (s, m) => s + m.protein);
          final totalCarbs = history.fold<double>(0, (s, e) => s + e.carbs) +
              homeMeals.fold<double>(0, (s, m) => s + m.carbs);
          final totalFat = history.fold<double>(0, (s, e) => s + e.totalFat) +
              homeMeals.fold<double>(0, (s, m) => s + m.totalFat);

          final totalEntries = history.length + homeMeals.length;
          final avgCalPerMeal = totalEntries > 0 ? totalCal / totalEntries : 0;

          final bmiCategory = BmiCalculator.getCategory(profile.bmiValue);
          final bmiLabel = BmiCalculator.getCategoryLabel(bmiCategory);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Report header ──────────────────────────────────────────
                _SectionCard(
                  title: 'Health Profile',
                  child: Column(
                    children: [
                      _ReportRow(
                          label: 'BMI',
                          value:
                              '${profile.bmiValue.toStringAsFixed(1)} ($bmiLabel)'),
                      _ReportRow(label: 'Goal', value: profile.goal.labelEn),
                      _ReportRow(
                          label: 'Daily Target',
                          value:
                              '${profile.dailyCalorieTarget.toStringAsFixed(0)} kcal'),
                      _ReportRow(
                          label: 'Activity Level',
                          value: profile.activityLevel.labelEn),
                      if (profile.conditions.isNotEmpty)
                        _ReportRow(
                          label: 'Conditions',
                          value: profile.conditions
                              .map((c) => c.replaceAll('_', ' '))
                              .join(', ')
                              .toUpperCase(),
                          valueColor: AppColors.allergyWarning,
                        ),
                      if (profile.allergies.isNotEmpty)
                        _ReportRow(
                          label: 'Allergies',
                          value: profile.allergies
                              .map((a) => a[0].toUpperCase() + a.substring(1))
                              .join(', '),
                          valueColor: AppColors.error,
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.lg),

                // ── Nutrition Summary ──────────────────────────────────────
                _SectionCard(
                  title: 'Logged Nutrition Summary',
                  subtitle: '$totalEntries meals logged',
                  child: Column(
                    children: [
                      _MacroBar(
                        label: 'Calories',
                        value: totalCal,
                        unit: 'kcal',
                        color: AppColors.calories,
                        max: profile.dailyCalorieTarget * 7,
                      ),
                      const SizedBox(height: AppDimensions.md),
                      _MacroBar(
                        label: 'Protein',
                        value: totalProtein,
                        unit: 'g',
                        color: AppColors.protein,
                        max: 1400, // 200g/day * 7
                      ),
                      const SizedBox(height: AppDimensions.md),
                      _MacroBar(
                        label: 'Carbohydrates',
                        value: totalCarbs,
                        unit: 'g',
                        color: AppColors.carbs,
                        max: 2100, // 300g/day * 7
                      ),
                      const SizedBox(height: AppDimensions.md),
                      _MacroBar(
                        label: 'Total Fat',
                        value: totalFat,
                        unit: 'g',
                        color: AppColors.fats,
                        max: 490, // 70g/day * 7
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.lg),

                // ── Average per meal ───────────────────────────────────────
                _SectionCard(
                  title: 'Averages Per Meal',
                  child: Column(
                    children: [
                      _ReportRow(
                          label: 'Avg. Calories/meal',
                          value: '${avgCalPerMeal.toStringAsFixed(0)} kcal'),
                      _ReportRow(
                          label: 'Avg. Protein/meal',
                          value: totalEntries > 0
                              ? '${(totalProtein / totalEntries).toStringAsFixed(1)}g'
                              : '—'),
                      _ReportRow(
                          label: 'Avg. Carbs/meal',
                          value: totalEntries > 0
                              ? '${(totalCarbs / totalEntries).toStringAsFixed(1)}g'
                              : '—'),
                      _ReportRow(
                          label: 'Avg. Fat/meal',
                          value: totalEntries > 0
                              ? '${(totalFat / totalEntries).toStringAsFixed(1)}g'
                              : '—'),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.lg),

                // ── Recommendation notes ───────────────────────────────────
                _SectionCard(
                  title: 'Personalised Notes',
                  child: _RecommendationNotes(
                    bmiCategory: bmiCategory,
                    goal: profile.goal,
                    conditions: profile.conditions,
                  ),
                ),

                const SizedBox(height: AppDimensions.xxl),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.border.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: AppTextStyles.headlineSmall),
              if (subtitle != null) ...[
                const Spacer(),
                Text(subtitle!, style: AppTextStyles.bodySmall),
              ],
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          const Divider(height: 1),
          const SizedBox(height: AppDimensions.md),
          child,
        ],
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _ReportRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.labelLarge.copyWith(
                color: valueColor ?? AppColors.textPrimary,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final Color color;
  final double max;

  const _MacroBar({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (value / max).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodyMedium),
            Text(
              '${value.toStringAsFixed(0)} $unit',
              style: AppTextStyles.labelLarge.copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: color.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _RecommendationNotes extends StatelessWidget {
  final BmiCategory bmiCategory;
  final UserGoal goal;
  final List<String> conditions;

  const _RecommendationNotes({
    required this.bmiCategory,
    required this.goal,
    required this.conditions,
  });

  @override
  Widget build(BuildContext context) {
    final notes = <_Note>[];

    // BMI-based notes
    switch (bmiCategory) {
      case BmiCategory.underweight:
        notes.add(const _Note(
          icon: Icons.info_outline,
          color: AppColors.info,
          text:
              'Your BMI indicates underweight. Focus on nutrient-dense, calorie-rich meals and increase protein intake.',
        ));
        break;
      case BmiCategory.normal:
        notes.add(const _Note(
          icon: Icons.check_circle_outline,
          color: AppColors.success,
          text:
              'Your BMI is in the healthy range. Maintain balanced macros and stay consistent with your activity level.',
        ));
        break;
      case BmiCategory.overweight:
        notes.add(const _Note(
          icon: Icons.warning_amber_outlined,
          color: AppColors.warning,
          text:
              'Your BMI is above normal. A caloric deficit of 300–500 kcal/day combined with regular exercise can help.',
        ));
        break;
      case BmiCategory.obese:
        notes.add(const _Note(
          icon: Icons.warning_amber_rounded,
          color: AppColors.error,
          text:
              'Your BMI is in the obese range. Consider consulting a nutritionist. Focus on reducing processed foods and increasing vegetables.',
        ));
        break;
    }

    // Goal-based notes
    switch (goal) {
      case UserGoal.weightLoss:
        notes.add(const _Note(
          icon: Icons.trending_down,
          color: AppColors.primary,
          text:
              'For weight loss, prioritise high-protein, lower-fat meals. Aim for at least 1.2g of protein per kg of body weight.',
        ));
        break;
      case UserGoal.muscleGain:
        notes.add(const _Note(
          icon: Icons.fitness_center,
          color: AppColors.primary,
          text:
              'For muscle gain, aim for 1.6–2.2g of protein per kg of body weight and ensure a slight caloric surplus.',
        ));
        break;
      case UserGoal.balanced:
        notes.add(const _Note(
          icon: Icons.balance,
          color: AppColors.primary,
          text:
              'For balanced nutrition, distribute macros roughly 50% carbs, 25% protein, 25% fat across your daily meals.',
        ));
        break;
    }

    // Condition-based notes
    if (conditions.contains('high_bp')) {
      notes.add(const _Note(
        icon: Icons.favorite_border,
        color: AppColors.allergyWarning,
        text:
            'High BP: Limit sodium to under 2,300mg per day. Avoid processed and fast foods. Eat potassium-rich foods like bananas and spinach.',
      ));
    }
    if (conditions.contains('diabetes')) {
      notes.add(const _Note(
        icon: Icons.monitor_heart_outlined,
        color: AppColors.allergyWarning,
        text:
            'Diabetes: Focus on low-GI carbohydrates, limit added sugars, and maintain consistent meal timing throughout the day.',
      ));
    }

    return Column(
      children: notes
          .map((n) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(n.icon, color: n.color, size: 20),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: Text(n.text, style: AppTextStyles.bodyMedium),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _Note {
  final IconData icon;
  final Color color;
  final String text;
  const _Note({required this.icon, required this.color, required this.text});
}
