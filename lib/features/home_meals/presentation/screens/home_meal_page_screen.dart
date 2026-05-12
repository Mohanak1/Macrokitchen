import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../bmi/presentation/providers/bmi_provider.dart';
import '../providers/home_meals_provider.dart';

class HomeMealPageScreen extends ConsumerWidget {
  const HomeMealPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealsAsync = ref.watch(homeMealsStreamProvider);
    final bmiAsync = ref.watch(bmiProfileProvider);

    final dailyTarget = bmiAsync.value?.dailyCalorieTarget ?? 2000;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Meal Page'),
        actions: [
          TextButton(
            onPressed: () => context.go('/home-meals/add'),
            child: const Text('Edit'),
          ),
        ],
      ),
      body: mealsAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
        data: (meals) {
          final totalConsumed =
              meals.fold<double>(0, (sum, m) => sum + m.calories);
          final remaining = (dailyTarget - totalConsumed).clamp(0, dailyTarget);

          return Column(
            children: [
              // ── Calorie Summary ──────────────────────────────────────────
              Container(
                margin: const EdgeInsets.all(AppDimensions.pagePaddingH),
                padding: const EdgeInsets.all(AppDimensions.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.border.withOpacity(0.2),
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
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      '${dailyTarget.toStringAsFixed(0)} - ${totalConsumed.toStringAsFixed(0)} = ${remaining.toStringAsFixed(0)} kCal',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: AppDimensions.md),
                    Row(
                      children: [
                        Text(
                          totalConsumed.toStringAsFixed(0),
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
                                value:
                                    (totalConsumed / dailyTarget).clamp(0, 1),
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

              // ── Meal List ────────────────────────────────────────────────
              Expanded(
                child: meals.isEmpty
                    ? AppEmptyWidget(
                        message: 'No home meals logged yet.',
                        icon: Icons.add_box_outlined,
                        actionLabel: 'Log a Meal',
                        onAction: () => context.go('/home-meals/add'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.pagePaddingH),
                        itemCount: meals.length,
                        itemBuilder: (_, i) {
                          final meal = meals[i];
                          return _HomeMealTile(
                            meal: meal,
                            onDelete: () async {
                              final confirmed = await _confirm(context);
                              if (confirmed == true) {
                                await ref
                                    .read(homeMealNotifierProvider.notifier)
                                    .delete(meal.id);
                    
                              }
                            },
                            onEdit: () =>
                                context.go('/home-meals/add?mealId=${meal.id}'),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/home-meals/add'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<bool?> _confirm(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete meal?'),
        content: const Text('This meal will be removed from your log.'),
        actions: [
          TextButton(
              onPressed: () => ctx.pop(false), child: const Text('Cancel')),
          TextButton(
              onPressed: () => ctx.pop(true),
              child: const Text('Delete',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
  }
}

class _HomeMealTile extends StatelessWidget {
  final HomeMeal meal;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _HomeMealTile({
    required this.meal,
    required this.onDelete,
    required this.onEdit,
  });

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
          const Icon(Icons.restaurant_menu, color: AppColors.primary),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(meal.title,
                          style: AppTextStyles.headlineSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    Text('${meal.calories.toStringAsFixed(0)} kCal',
                        style: AppTextStyles.labelLarge
                            .copyWith(color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'P: ${meal.protein.toStringAsFixed(0)}g  C: ${meal.carbs.toStringAsFixed(0)}g  F: ${meal.totalFat.toStringAsFixed(0)}g',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textHint),
            onSelected: (v) {
              if (v == 'edit') onEdit();
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(
                  value: 'delete',
                  child:
                      Text('Delete', style: TextStyle(color: AppColors.error))),
            ],
          ),
        ],
      ),
    );
  }
}
