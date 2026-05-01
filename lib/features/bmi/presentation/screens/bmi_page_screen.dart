import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/bmi_calculator.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../providers/bmi_provider.dart';

class BmiPageScreen extends ConsumerWidget {
  const BmiPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bmiAsync = ref.watch(bmiProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.go(AppRoutes.setup),
          ),
        ],
      ),
      body: bmiAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
        data: (profile) {
          if (profile == null) {
            return AppEmptyWidget(
              message: 'No BMI data yet.\nComplete the setup to get started.',
              icon: Icons.monitor_weight_outlined,
              actionLabel: 'Set Up Now',
              onAction: () => context.go(AppRoutes.setup),
            );
          }

          final category = BmiCalculator.getCategory(profile.bmiValue);
          final categoryLabel = BmiCalculator.getCategoryLabel(category);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User name
                const Text(
                  'Profile',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: AppDimensions.xl),

                // Height card
                _MetricCard(
                  icon: Icons.straighten,
                  value: '${profile.heightCm.toStringAsFixed(0)}cm',
                  label: 'Height',
                ),
                const SizedBox(height: AppDimensions.md),

                // Weight card
                _MetricCard(
                  icon: Icons.monitor_weight_outlined,
                  value: '${profile.weightKg.toStringAsFixed(0)}kg',
                  label: 'Weight',
                ),
                const SizedBox(height: AppDimensions.md),

                // BMI card
                _MetricCard(
                  icon: Icons.assessment_outlined,
                  value: profile.bmiValue.toStringAsFixed(1),
                  label: 'BMI — $categoryLabel',
                  valueColor: _bmiColor(category),
                ),

                const SizedBox(height: AppDimensions.xxl),

                // Conditions
                if (profile.conditions.isNotEmpty) ...[
                  const Text('Conditions', style: AppTextStyles.headlineSmall),
                  const SizedBox(height: AppDimensions.sm),
                  Wrap(
                    spacing: AppDimensions.sm,
                    children: profile.conditions.map((c) {
                      return Chip(
                        label: Text(
                          c.replaceAll('_', ' ').toUpperCase(),
                          style: AppTextStyles.labelMedium
                              .copyWith(color: AppColors.allergyWarning),
                        ),
                        backgroundColor: AppColors.allergyWarningLight,
                        side: const BorderSide(color: AppColors.allergyWarning),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppDimensions.xl),
                ],

                // Allergies
                if (profile.allergies.isNotEmpty) ...[
                  const Text('Allergies', style: AppTextStyles.headlineSmall),
                  const SizedBox(height: AppDimensions.sm),
                  Wrap(
                    spacing: AppDimensions.sm,
                    runSpacing: AppDimensions.sm,
                    children: profile.allergies.map((a) {
                      return Chip(
                        avatar: const Icon(Icons.no_food,
                            size: 14, color: AppColors.error),
                        label: Text(
                          a[0].toUpperCase() + a.substring(1),
                          style: AppTextStyles.labelMedium,
                        ),
                        backgroundColor: AppColors.surfaceVariant,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppDimensions.xl),
                ],

                // Activity
                const Text('Activity', style: AppTextStyles.headlineSmall),
                const SizedBox(height: AppDimensions.sm),
                _InfoRow(
                    label: 'Exercise Frequency',
                    value: profile.activityLevel.labelEn),
                _InfoRow(
                    label: 'Movement',
                    value: profile.movement[0].toUpperCase() +
                        profile.movement.substring(1)),
                _InfoRow(label: 'Goal', value: profile.goal.labelEn),
                _InfoRow(
                    label: 'Daily Calorie Target',
                    value:
                        '${profile.dailyCalorieTarget.toStringAsFixed(0)} kcal'),

                const SizedBox(height: AppDimensions.xxxl),

                AppButton(
                  label: 'Edit Profile',
                  isOutlined: true,
                  onPressed: () => context.go(AppRoutes.setup),
                ),

                const SizedBox(height: AppDimensions.xxl),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _bmiColor(BmiCategory cat) {
    switch (cat) {
      case BmiCategory.underweight:
        return AppColors.info;
      case BmiCategory.normal:
        return AppColors.success;
      case BmiCategory.overweight:
        return AppColors.warning;
      case BmiCategory.obese:
        return AppColors.error;
    }
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? valueColor;

  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon,
                color: AppColors.primary, size: AppDimensions.iconLg),
          ),
          const SizedBox(width: AppDimensions.lg),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.headlineLarge.copyWith(
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
              Text(label, style: AppTextStyles.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
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
