import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../bmi/presentation/providers/bmi_provider.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../providers/home_meals_provider.dart';

class HomeMealPageScreen extends ConsumerWidget {
  const HomeMealPageScreen({super.key});

  Future<void> _logMeal(BuildContext context, WidgetRef ref, HomeMeal meal,
      {required double dailyTarget, required double consumed}) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final willExceed = (consumed + meal.calories) > dailyTarget;
    if (willExceed && context.mounted) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Calorie Limit Exceeded'),
          content: Text(
            'Adding this meal will bring you to ${(consumed + meal.calories).toStringAsFixed(0)} kCal, '
            'exceeding your daily target of ${dailyTarget.toStringAsFixed(0)} kCal.',
          ),
          actions: [
            TextButton(
                onPressed: () => ctx.pop(false), child: const Text('Cancel')),
            TextButton(
                onPressed: () => ctx.pop(true),
                child: const Text('Log Anyway')),
          ],
        ),
      );
      if (proceed != true) return;
    }

    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final entry = MealHistoryEntry(
      id: '',
      userId: user.uid,
      homeMealId: meal.id,
      mealTitle: meal.title,
      type: 'home',
      calories: meal.calories,
      protein: meal.protein,
      carbs: meal.carbs,
      totalFat: meal.totalFat,
      loggedAt: now,
      date: date,
    );

    final error = await ref.read(historyNotifierProvider.notifier).log(entry);
    if (context.mounted) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error),
        );
      } else {
        ref.invalidate(todayTotalsProvider);
        ref.invalidate(historyProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meal logged!'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealsAsync = ref.watch(homeMealsStreamProvider);
    final bmiAsync = ref.watch(bmiProfileProvider);
    final todayAsync = ref.watch(todayTotalsProvider);
    final l = AppLocalizations.of(context)!;

    final dailyTarget = bmiAsync.value?.dailyCalorieTarget ?? 2000;
    final consumed = todayAsync.value?.calories ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.homeMealPage),
        actions: [
          TextButton(
            onPressed: () => context.go('/home-meals/add'),
            child: Text(l.edit),
          ),
        ],
      ),
      body: mealsAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => Center(child: Text('${l.errorLoadingMeals}: $e')),
        data: (meals) {
          final totalConsumed = consumed;
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
                    Text(l.caloriesRemaining,
                        style: AppTextStyles.headlineSmall),
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      '${dailyTarget.toStringAsFixed(0)} - ${totalConsumed.toStringAsFixed(0)} = ${remaining.toStringAsFixed(0)} ${l.kCal}',
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
                        message: l.noHomeMealsYet,
                        icon: Icons.add_box_outlined,
                        actionLabel: l.logAMeal,
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
                            onLog: () => _logMeal(context, ref, meal,
                                dailyTarget: dailyTarget, consumed: consumed),
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
    final l = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteMealTitle),
        content: Text(l.deleteMealMessage),
        actions: [
          TextButton(onPressed: () => ctx.pop(false), child: Text(l.cancel)),
          TextButton(
              onPressed: () => ctx.pop(true),
              child: Text(l.delete,
                  style: const TextStyle(color: AppColors.error))),
        ],
      ),
    );
  }
}

class _HomeMealTile extends StatelessWidget {
  final HomeMeal meal;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onLog;

  const _HomeMealTile({
    required this.meal,
    required this.onDelete,
    required this.onEdit,
    required this.onLog,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
                    // ── CHANGED: bolder calories text ──
                    Text(
                      '${meal.calories.toStringAsFixed(0)} ${l.kCal}',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // ── CHANGED: darker macros text ──
                Text(
                  'P: ${meal.protein.toStringAsFixed(0)}g  C: ${meal.carbs.toStringAsFixed(0)}g  F: ${meal.totalFat.toStringAsFixed(0)}g',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon:
                const Icon(Icons.add_circle_outline, color: AppColors.primary),
            tooltip: 'Log meal',
            onPressed: onLog,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textHint),
            onSelected: (v) {
              if (v == 'edit') onEdit();
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'edit', child: Text(l.edit)),
              PopupMenuItem(
                  value: 'delete',
                  child: Text(l.delete,
                      style: const TextStyle(color: AppColors.error))),
            ],
          ),
        ],
      ),
    );
  }
}
