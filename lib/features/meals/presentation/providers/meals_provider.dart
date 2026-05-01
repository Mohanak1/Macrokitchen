import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/meals_data.dart';
import '../../domain/entities/meal.dart';
import '../../../bmi/presentation/providers/bmi_provider.dart';
import '../../../../core/utils/recommendation_engine.dart';

// ── Infrastructure providers ──────────────────────────────────────────────────

final mealsDatasourceProvider = Provider((_) => MealsRemoteDatasource());

final mealsRepositoryProvider = Provider<MealsRepository>((ref) {
  return MealsRepositoryImpl(ref.read(mealsDatasourceProvider));
});

// ── All meals ─────────────────────────────────────────────────────────────────

final allMealsProvider = FutureProvider<List<Meal>>((ref) async {
  final result = await ref.read(mealsRepositoryProvider).getAllMeals();
  return result.fold((_) => [], (meals) => meals);
});

// ── Meals by restaurant ───────────────────────────────────────────────────────

final mealsByRestaurantProvider =
    FutureProvider.family<List<Meal>, String>((ref, restaurantId) async {
  final result = await ref
      .read(mealsRepositoryProvider)
      .getMealsByRestaurant(restaurantId);
  return result.fold((_) => [], (meals) => meals);
});

// ── Single meal ───────────────────────────────────────────────────────────────

final mealByIdProvider =
    FutureProvider.family<Meal?, String>((ref, mealId) async {
  final result = await ref.read(mealsRepositoryProvider).getMealById(mealId);
  return result.fold((_) => null, (meal) => meal);
});

// ── Recommended meals (scored + filtered) ────────────────────────────────────

final recommendedMealsProvider = FutureProvider<List<ScoredMeal>>((ref) async {
  final meals = await ref.watch(allMealsProvider.future);
  final profile = await ref.watch(bmiProfileProvider.future);

  if (profile == null) return [];

  return RecommendationEngine.recommend(
    meals: meals,
    profile: profile,
    dailyCalorieTarget: profile.dailyCalorieTarget,
  );
});

// ── Meal search / filter ──────────────────────────────────────────────────────

final mealSearchQueryProvider = StateProvider<String>((_) => '');

final filteredMealsProvider = Provider<AsyncValue<List<Meal>>>((ref) {
  final query = ref.watch(mealSearchQueryProvider).toLowerCase();
  final mealsAsync = ref.watch(allMealsProvider);

  return mealsAsync.whenData((meals) {
    if (query.isEmpty) return meals;
    return meals
        .where((m) =>
            m.title.toLowerCase().contains(query) ||
            m.restaurantName.toLowerCase().contains(query))
        .toList();
  });
});

// ── Meal action notifier (add/update/delete for restaurant) ───────────────────

class MealActionNotifier extends StateNotifier<AsyncValue<void>> {
  final MealsRepository _repo;
  MealActionNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<String?> addMeal(
    Meal meal,
    String restaurantId,
    String restaurantName,
  ) async {
    state = const AsyncValue.loading();
    final result = await _repo.addMeal(meal, restaurantId, restaurantName);
    return result.fold(
      (f) {
        state = const AsyncValue.data(null);
        return f.message;
      },
      (_) {
        state = const AsyncValue.data(null);
        return null;
      },
    );
  }

  Future<String?> updateMeal(String mealId, Meal meal) async {
    state = const AsyncValue.loading();
    final result = await _repo.updateMeal(mealId, meal);
    return result.fold(
      (f) {
        state = const AsyncValue.data(null);
        return f.message;
      },
      (_) {
        state = const AsyncValue.data(null);
        return null;
      },
    );
  }

  Future<String?> deleteMeal(String mealId) async {
    state = const AsyncValue.loading();
    final result = await _repo.deleteMeal(mealId);
    return result.fold(
      (f) {
        state = const AsyncValue.data(null);
        return f.message;
      },
      (_) {
        state = const AsyncValue.data(null);
        return null;
      },
    );
  }
}

final mealActionProvider =
    StateNotifierProvider<MealActionNotifier, AsyncValue<void>>((ref) {
  return MealActionNotifier(ref.read(mealsRepositoryProvider));
});
