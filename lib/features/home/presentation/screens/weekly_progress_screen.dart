import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../bmi/presentation/providers/bmi_provider.dart';

class WeeklyProgressScreen extends ConsumerWidget {
  const WeeklyProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final bmiAsync = ref.watch(bmiProfileProvider);

    final user = authState.value;
    final profile = bmiAsync.value;

    if (profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Weekly Progress')),
        body: AppEmptyWidget(
          message: 'Complete your BMI setup first.',
          icon: Icons.bar_chart_outlined,
          actionLabel: 'Set Up Now',
          onAction: () {},
        ),
      );
    }

    // Simulated weekly weight data based on current weight
    // In production this would come from a WeightHistory collection
    final currentWeight = profile.weightKg;
    final startWeight = currentWeight + 7.5; // simulate starting higher
    final weeklyData = _generateWeeklyData(startWeight, currentWeight);
    final changePercent =
        ((currentWeight - startWeight) / startWeight * 100).abs();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Progress'),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── User Name ────────────────────────────────────────────────
            if (user != null)
              Text(user.name, style: AppTextStyles.headlineMedium),

            const SizedBox(height: AppDimensions.xl),

            // ── Weight Chart ─────────────────────────────────────────────
            const Text('Weight', style: AppTextStyles.headlineSmall),
            const Align(
              alignment: Alignment.topRight,
              child: Text('Weekly ▾', style: AppTextStyles.bodyMedium),
            ),
            const SizedBox(height: AppDimensions.md),

            Container(
              height: 200,
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine: (_) => const FlLine(
                      color: AppColors.border,
                      strokeWidth: 0.5,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (val, _) {
                          const labels = [
                            'Jan',
                            'Feb',
                            'Mar',
                            'Apr',
                            'May',
                            'Jun',
                            'Jul',
                            'Aug'
                          ];
                          final idx = val.toInt();
                          if (idx < 0 || idx >= labels.length) {
                            return const SizedBox();
                          }
                          return Text(labels[idx],
                              style: AppTextStyles.caption);
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        interval: 5,
                        getTitlesWidget: (val, _) => Text(
                          '${val.toInt()}kg',
                          style: AppTextStyles.caption,
                        ),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: weeklyData
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                          .toList(),
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withOpacity(0.12),
                      ),
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.primary,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                  minY: currentWeight - 5,
                  maxY: startWeight + 2,
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.xl),

            // ── Stats Cards ──────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Start',
                    value: '${startWeight.toStringAsFixed(0)}kg',
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: _StatCard(
                    label: 'Current',
                    value: '${currentWeight.toStringAsFixed(0)}kg',
                    highlighted: true,
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: _StatCard(
                    label: 'Change',
                    value: '${changePercent.toStringAsFixed(2)}%',
                    isPositive: currentWeight < startWeight,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.xl),

            // ── BMI Summary ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppDimensions.lg),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('BMI', style: AppTextStyles.bodyMedium),
                      Text(
                        profile.bmiValue.toStringAsFixed(1),
                        style: AppTextStyles.headlineLarge
                            .copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Goal', style: AppTextStyles.bodyMedium),
                      Text(
                        profile.goal.labelEn,
                        style: AppTextStyles.headlineSmall
                            .copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.xxl),
          ],
        ),
      ),
    );
  }

  List<double> _generateWeeklyData(double start, double current) {
    // Simulate a gradual decline from start to current over 8 months
    final step = (start - current) / 7;
    return List.generate(8, (i) => start - (step * i));
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final bool highlighted;
  final bool? isPositive;

  const _StatCard({
    required this.label,
    required this.value,
    this.highlighted = false,
    this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    Color valueColor = AppColors.textPrimary;
    if (isPositive != null) {
      valueColor = isPositive! ? AppColors.success : AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.primaryContainer : AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: highlighted ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              color: highlighted ? AppColors.primary : valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
