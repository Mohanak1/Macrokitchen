import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../meals/presentation/providers/meals_provider.dart';
import '../providers/restaurant_provider.dart';

class RestaurantDashboardScreen extends ConsumerWidget {
  const RestaurantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantAsync = ref.watch(currentRestaurantProvider);
    final mealsAsync = ref.watch(restaurantOwnMealsProvider);

    return Scaffold(
      appBar: AppBar(
        title: restaurantAsync.when(
          data: (r) => Text(r?.name ?? 'Restaurant Page'),
          loading: () => const Text('Restaurant Page'),
          error: (_, __) => const Text('Restaurant Page'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) context.go(AppRoutes.restaurantLogin);
            },
          ),
        ],
      ),
      body: restaurantAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
        data: (restaurant) {
          if (restaurant == null) {
            return const AppEmptyWidget(
              message:
                  'No restaurant profile found.\nContact the administrator.',
              icon: Icons.store_outlined,
            );
          }

          return mealsAsync.when(
            loading: () => const AppLoading(),
            error: (e, _) => AppErrorWidget(message: e.toString()),
            data: (meals) {
              return ListView(
                padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
                children: [
                  // Restaurant logo
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: restaurant.logoUrl != null
                              ? ClipOval(
                                  child: Image.network(restaurant.logoUrl!,
                                      fit: BoxFit.cover))
                              : const Icon(Icons.store,
                                  color: AppColors.primary, size: 36),
                        ),
                        const SizedBox(height: AppDimensions.sm),
                        Text(restaurant.name,
                            style: AppTextStyles.headlineMedium),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.xl),

                  if (meals.isEmpty)
                    const AppEmptyWidget(
                      message: 'No meals yet. Add your first meal.',
                      icon: Icons.fastfood_outlined,
                    )
                  else
                    ...meals.map((meal) => _RestaurantMealTile(
                          meal: meal,
                          onEdit: () => context.go(
                              '${AppRoutes.restaurantAddMeal}?mealId=${meal.id}'),
                          onDelete: () async {
                            final ok = await _confirm(context);
                            if (ok == true) {
                              await ref
                                  .read(mealActionProvider.notifier)
                                  .deleteMeal(meal.id);
                              ref.invalidate(restaurantOwnMealsProvider);
                            }
                          },
                        )),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRoutes.restaurantAddMeal),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      // Refresh button at bottom matching mockup
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.pagePaddingH,
              vertical: AppDimensions.md),
          child: OutlinedButton.icon(
            onPressed: () {
              ref.invalidate(restaurantOwnMealsProvider);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirm(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete meal?'),
        content: const Text('This will remove the meal from your menu.'),
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

class _RestaurantMealTile extends StatelessWidget {
  final dynamic meal; // Meal entity
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RestaurantMealTile({
    required this.meal,
    required this.onEdit,
    required this.onDelete,
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
          // Meal image
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            child: meal.imageUrl != null && meal.imageUrl!.isNotEmpty
                ? Image.network(meal.imageUrl!,
                    width: 52, height: 52, fit: BoxFit.cover)
                : Container(
                    width: 52,
                    height: 52,
                    color: AppColors.inputFill,
                    child: const Icon(Icons.fastfood, color: AppColors.primary),
                  ),
          ),
          const SizedBox(width: AppDimensions.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                    if (meal.rating > 0) ...[
                      const SizedBox(width: AppDimensions.sm),
                      const Icon(Icons.star_rounded,
                          color: AppColors.rating, size: 14),
                      Text(meal.rating.toStringAsFixed(1),
                          style: AppTextStyles.caption),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'P: ${meal.protein.toStringAsFixed(0)}g  C: ${meal.carbs.toStringAsFixed(0)}g  F: ${(meal.totalFat ?? 0).toStringAsFixed(0)}g',
                  style: AppTextStyles.bodySmall,
                ),
                Text('Na: ${(meal.sodium ?? 0).toStringAsFixed(0)}mg',
                    style: AppTextStyles.bodySmall),
              ],
            ),
          ),

          // Actions
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    size: AppDimensions.iconMd, color: AppColors.primary),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: AppDimensions.iconMd, color: AppColors.error),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
