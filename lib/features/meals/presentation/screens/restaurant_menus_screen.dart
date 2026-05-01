import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/nutrition_widgets.dart';
import '../../../../core/widgets/skeleton_widgets.dart';
import '../providers/meals_provider.dart';

class RestaurantMenusScreen extends ConsumerStatefulWidget {
  const RestaurantMenusScreen({super.key});

  @override
  ConsumerState<RestaurantMenusScreen> createState() =>
      _RestaurantMenusScreenState();
}

class _RestaurantMenusScreenState
    extends ConsumerState<RestaurantMenusScreen> {
  final _searchCtrl = TextEditingController();
  bool _showRecommended = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(filteredMealsProvider);
    final recommendedAsync = ref.watch(recommendedMealsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Restaurant Menus')),
      body: Column(
        children: [
          // ── Search bar ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search,
                          color: AppColors.textHint),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close,
                                  color: AppColors.textHint),
                              onPressed: () {
                                _searchCtrl.clear();
                                ref
                                    .read(mealSearchQueryProvider.notifier)
                                    .state = '';
                              },
                            )
                          : null,
                    ),
                    onChanged: (v) {
                      ref.read(mealSearchQueryProvider.notifier).state = v;
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                // Filter toggle
                GestureDetector(
                  onTap: () =>
                      setState(() => _showRecommended = !_showRecommended),
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    decoration: BoxDecoration(
                      color: _showRecommended
                          ? AppColors.primary
                          : AppColors.surfaceVariant,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMd),
                    ),
                    child: Icon(
                      Icons.tune,
                      color: _showRecommended
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Home Meals Banner ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.pagePaddingH),
            child: GestureDetector(
              onTap: () => context.go(AppRoutes.homeMeals),
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.lg),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.home_outlined, color: AppColors.primary),
                    const SizedBox(width: AppDimensions.md),
                    Text('Home Meals',
                        style: AppTextStyles.headlineSmall
                            .copyWith(color: AppColors.primary)),
                    const Spacer(),
                    const Icon(Icons.chevron_right, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.lg),

          // ── Section toggle ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.pagePaddingH),
            child: Row(
              children: [
                _TabChip(
                  label: 'All Meals',
                  selected: !_showRecommended,
                  onTap: () => setState(() => _showRecommended = false),
                ),
                const SizedBox(width: AppDimensions.sm),
                _TabChip(
                  label: '⭐ Recommended',
                  selected: _showRecommended,
                  onTap: () => setState(() => _showRecommended = true),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.md),

          // ── Meal List ─────────────────────────────────────────────────────
          Expanded(
            child: _showRecommended
                ? _RecommendedList(recommendedAsync: recommendedAsync)
                : _AllMealsList(filteredAsync: filteredAsync),
          ),
        ],
      ),
    );
  }
}

class _AllMealsList extends ConsumerWidget {
  final AsyncValue filteredAsync;
  const _AllMealsList({required this.filteredAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return filteredAsync.when(
      loading: () => const MealListSkeleton(),
      error: (e, _) => AppErrorWidget(message: e.toString()),
      data: (meals) {
        final mealList = meals as List;
        if (mealList.isEmpty) {
          return const AppEmptyWidget(
            message: 'No meals found.',
            icon: Icons.restaurant_outlined,
          );
        }
        return ListView.builder(
          padding:
              const EdgeInsets.symmetric(horizontal: AppDimensions.pagePaddingH),
          itemCount: mealList.length,
          itemBuilder: (_, i) {
            final meal = mealList[i];
            return MealCard(
              meal: meal,
              onTap: () => context.go('${AppRoutes.meals}/${meal.id}'),
            );
          },
        );
      },
    );
  }
}

class _RecommendedList extends ConsumerWidget {
  final AsyncValue recommendedAsync;
  const _RecommendedList({required this.recommendedAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return recommendedAsync.when(
      loading: () => const MealListSkeleton(count: 4),
      error: (e, _) => AppErrorWidget(message: e.toString()),
      data: (scored) {
        final list = scored as List;
        if (list.isEmpty) {
          return const AppEmptyWidget(
            message: 'Complete your BMI setup to\nget personalized recommendations.',
            icon: Icons.recommend_outlined,
          );
        }
        return ListView.builder(
          padding:
              const EdgeInsets.symmetric(horizontal: AppDimensions.pagePaddingH),
          itemCount: list.length,
          itemBuilder: (_, i) {
            final s = list[i];
            return MealCard(
              meal: s.meal,
              score: s.score,
              showWarning: s.hasAllergen || s.hasWarnings,
              warnings: [
                if (s.hasAllergen) 'allergen',
                ...s.warnings,
              ],
              onTap: () => context.go('${AppRoutes.meals}/${s.meal.id}'),
            );
          },
        );
      },
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.lg, vertical: AppDimensions.sm),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
