import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/home_meals_data.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Re-export for convenience
export '../../data/home_meals_data.dart' show HomeMeal;

final homeMealsDatasourceProvider = Provider((_) => HomeMealsDatasource());

final homeMealsRepositoryProvider = Provider<HomeMealsRepository>((ref) {
  return HomeMealsRepositoryImpl(ref.read(homeMealsDatasourceProvider));
});

final homeMealsProvider = FutureProvider<List<HomeMeal>>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return [];

  final result =
      await ref.read(homeMealsRepositoryProvider).getUserHomeMeals(user.uid);
  return result.fold((_) => [], (meals) => meals);
});

/// Live stream of the current user's home meals (newest first).
/// Use this in the UI so the page updates automatically when a meal is saved.
final homeMealsStreamProvider = StreamProvider<List<HomeMeal>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const <HomeMeal>[]);
  final repo = ref.watch(homeMealsRepositoryProvider);
  return repo.streamUserHomeMeals(user.uid);
});

class HomeMealNotifier extends StateNotifier<AsyncValue<void>> {
  final HomeMealsRepository _repo;
  HomeMealNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<String?> add(HomeMeal meal, String userId) async {
    state = const AsyncValue.loading();
    final result = await _repo.addHomeMeal(meal, userId);
    return result.fold(
      (f) { state = const AsyncValue.data(null); return f.message; },
      (_) { state = const AsyncValue.data(null); return null; },
    );
  }

  Future<String?> update(String id, HomeMeal meal) async {
    state = const AsyncValue.loading();
    final result = await _repo.updateHomeMeal(id, meal);
    return result.fold(
      (f) { state = const AsyncValue.data(null); return f.message; },
      (_) { state = const AsyncValue.data(null); return null; },
    );
  }

  Future<String?> delete(String id) async {
    state = const AsyncValue.loading();
    final result = await _repo.deleteHomeMeal(id);
    return result.fold(
      (f) { state = const AsyncValue.data(null); return f.message; },
      (_) { state = const AsyncValue.data(null); return null; },
    );
  }
}

final homeMealNotifierProvider =
    StateNotifierProvider<HomeMealNotifier, AsyncValue<void>>((ref) {
  return HomeMealNotifier(ref.read(homeMealsRepositoryProvider));
});
