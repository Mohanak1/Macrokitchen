import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../bmi/presentation/providers/bmi_provider.dart';
import '../providers/history_provider.dart';

class MealHistoryScreen extends ConsumerWidget {
  const MealHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);
    final bmiAsync = ref.watch(bmiProfileProvider);
    final todayAsync = ref.watch(todayTotalsProvider);

    final dailyTarget = bmiAsync.value?.dailyCalorieTarget ?? 2000;

    return Scaffold(
      appBar: AppBar(title: const Text('Meal History')),
      body: historyAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
        data: (entries) {
          final consumed = todayAsync.value?.calories ?? 0;
          final remaining = (dailyTarget - consumed).clamp(0.0, dailyTarget);

          return Column(
            children: [
              // ── Daily Summary Card ───────────────────────────────────────
              Container(
                margin: const EdgeInsets.all(AppDimensions.pagePaddingH),
                padding: const EdgeInsets.all(AppDimensions.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.border.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Calories Remaining',
                        style: AppTextStyles.headlineSmall),
                    const SizedBox(height: AppDimensions.xs),
                    Text(
                      '${dailyTarget.toStringAsFixed(0)} - ${consumed.toStringAsFixed(0)} = ${remaining.toStringAsFixed(0)} kCal',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: AppDimensions.md),
                    Row(
                      children: [
                        Text(
                          consumed.toStringAsFixed(0),
                          style: AppTextStyles.labelLarge
                              .copyWith(color: AppColors.primary),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.md),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusFull),
                              child: LinearProgressIndicator(
                                value: (consumed / dailyTarget).clamp(0.0, 1.0),
                                minHeight: 10,
                                backgroundColor: AppColors.surfaceVariant,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.primary),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          dailyTarget.toStringAsFixed(0),
                          style: AppTextStyles.labelLarge,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Entry List ───────────────────────────────────────────────
              Expanded(
                child: entries.isEmpty
                    ? const AppEmptyWidget(
                        message:
                            'No meals logged yet.\nBrowse meals to get started.',
                        icon: Icons.no_meals_outlined,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.pagePaddingH),
                        itemCount: entries.length,
                        itemBuilder: (_, i) {
                          final e = entries[i];
                          return _HistoryTile(
                            entry: e,
                            onDelete: () async {
                              await ref
                                  .read(historyNotifierProvider.notifier)
                                  .delete(e.id);
                              ref.invalidate(historyProvider);
                              ref.invalidate(todayTotalsProvider);
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final MealHistoryEntry entry;
  final VoidCallback onDelete;

  const _HistoryTile({required this.entry, required this.onDelete});

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
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: entry.type == 'home'
                  ? AppColors.primaryContainer
                  : AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              entry.type == 'home' ? Icons.home : Icons.restaurant,
              color: AppColors.primary,
              size: AppDimensions.iconMd,
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        entry.mealTitle,
                        style: AppTextStyles.headlineSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${entry.calories.toStringAsFixed(0)} kCal',
                      style: AppTextStyles.labelLarge
                          .copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Macro chips
                Row(
                  children: [
                    _MacroText('P: ${entry.protein.toStringAsFixed(0)}g',
                        AppColors.protein),
                    const SizedBox(width: AppDimensions.sm),
                    _MacroText('C: ${entry.carbs.toStringAsFixed(0)}g',
                        AppColors.carbs),
                    const SizedBox(width: AppDimensions.sm),
                    _MacroText('F: ${entry.totalFat.toStringAsFixed(0)}g',
                        AppColors.fats),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(entry.loggedAt),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: AppColors.textHint, size: AppDimensions.iconMd),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0)
      return 'Today ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    if (diff.inDays == 1) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _MacroText extends StatelessWidget {
  final String text;
  final Color color;
  const _MacroText(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.bodySmall.copyWith(color: color),
    );
  }
}
