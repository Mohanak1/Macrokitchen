import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home_meals/presentation/providers/home_meals_provider.dart';

// ── Entity ────────────────────────────────────────────────────────────────────

class MealHistoryEntry extends Equatable {
  final String id;
  final String userId;
  final String? mealId; // null for home meals
  final String? homeMealId; // null for restaurant meals
  final String mealTitle;
  final String type; // 'restaurant' | 'home'
  final double calories;
  final double protein;
  final double carbs;
  final double totalFat;
  final DateTime loggedAt;
  final String date; // 'YYYY-MM-DD' for easy daily querying

  const MealHistoryEntry({
    required this.id,
    required this.userId,
    this.mealId,
    this.homeMealId,
    required this.mealTitle,
    required this.type,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.totalFat,
    required this.loggedAt,
    required this.date,
  });

  @override
  List<Object?> get props => [id, userId, mealTitle, loggedAt];
}

// ── Totals helper ─────────────────────────────────────────────────────────────

class DailyTotals {
  final double calories;
  final double protein;
  final double carbs;
  final double fats;

  const DailyTotals({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  static DailyTotals zero() =>
      const DailyTotals(calories: 0, protein: 0, carbs: 0, fats: 0);

  static DailyTotals fromEntries(List<MealHistoryEntry> entries) {
    return DailyTotals(
      calories: entries.fold(0, (s, e) => s + e.calories),
      protein: entries.fold(0, (s, e) => s + e.protein),
      carbs: entries.fold(0, (s, e) => s + e.carbs),
      fats: entries.fold(0, (s, e) => s + e.totalFat),
    );
  }
}

// ── Model ─────────────────────────────────────────────────────────────────────

class MealHistoryModel extends MealHistoryEntry {
  const MealHistoryModel({
    required super.id,
    required super.userId,
    super.mealId,
    super.homeMealId,
    required super.mealTitle,
    required super.type,
    required super.calories,
    required super.protein,
    required super.carbs,
    required super.totalFat,
    required super.loggedAt,
    required super.date,
  });

  factory MealHistoryModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final ts = d['loggedAt'];
    final DateTime loggedAt =
        ts != null ? (ts as Timestamp).toDate() : DateTime.now();
    return MealHistoryModel(
      id: doc.id,
      userId: d['userId'] as String? ?? '',
      mealId: d['mealId'] as String?,
      homeMealId: d['homeMealId'] as String?,
      mealTitle: d['mealTitle'] as String? ?? '',
      type: d['type'] as String? ?? 'restaurant',
      calories: (d['calories'] as num?)?.toDouble() ?? 0,
      protein: (d['protein'] as num?)?.toDouble() ?? 0,
      carbs: (d['carbs'] as num?)?.toDouble() ?? 0,
      totalFat: (d['totalFat'] as num?)?.toDouble() ?? 0,
      loggedAt: loggedAt,
      date: d['date'] as String? ??
          '${loggedAt.year}-${loggedAt.month.toString().padLeft(2, '0')}-${loggedAt.day.toString().padLeft(2, '0')}',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'mealId': mealId,
        'homeMealId': homeMealId,
        'mealTitle': mealTitle,
        'type': type,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'totalFat': totalFat,
        'loggedAt': FieldValue.serverTimestamp(),
        'date': date,
      };
}

// ── Datasource ────────────────────────────────────────────────────────────────

class HistoryDatasource {
  final FirebaseFirestore _db;
  HistoryDatasource({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Future<List<MealHistoryModel>> getHistory(String userId) async {
    final snap = await _db
        .collection('meal_history')
        .where('userId', isEqualTo: userId)
        .orderBy('loggedAt', descending: true)
        .limit(50)
        .get();
    return snap.docs.map(MealHistoryModel.fromFirestore).toList();
  }

  Future<List<MealHistoryModel>> getTodayHistory(
      String userId, String date) async {
    final snap = await _db
        .collection('meal_history')
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: date)
        .get();
    return snap.docs.map(MealHistoryModel.fromFirestore).toList();
  }

  Future<void> logEntry(MealHistoryModel entry) async {
    await _db.collection('meal_history').add(entry.toFirestore());
  }

  Future<void> deleteEntry(String id) async {
    await _db.collection('meal_history').doc(id).delete();
  }
}

// ── Repository ────────────────────────────────────────────────────────────────

abstract class HistoryRepository {
  Future<Either<Failure, List<MealHistoryEntry>>> getHistory(String userId);
  Future<Either<Failure, List<MealHistoryEntry>>> getTodayHistory(
      String userId, String date);
  Future<Either<Failure, void>> logEntry(MealHistoryEntry entry);
  Future<Either<Failure, void>> deleteEntry(String id);
}

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryDatasource _ds;
  HistoryRepositoryImpl(this._ds);

  @override
  Future<Either<Failure, List<MealHistoryEntry>>> getHistory(
      String userId) async {
    try {
      return Right(await _ds.getHistory(userId));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MealHistoryEntry>>> getTodayHistory(
      String userId, String date) async {
    try {
      return Right(await _ds.getTodayHistory(userId, date));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logEntry(MealHistoryEntry entry) async {
    try {
      final model = MealHistoryModel(
        id: entry.id,
        userId: entry.userId,
        mealId: entry.mealId,
        homeMealId: entry.homeMealId,
        mealTitle: entry.mealTitle,
        type: entry.type,
        calories: entry.calories,
        protein: entry.protein,
        carbs: entry.carbs,
        totalFat: entry.totalFat,
        loggedAt: entry.loggedAt,
        date: entry.date,
      );
      await _ds.logEntry(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEntry(String id) async {
    try {
      await _ds.deleteEntry(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final historyDatasourceProvider = Provider((_) => HistoryDatasource());

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepositoryImpl(ref.read(historyDatasourceProvider));
});

final historyProvider = FutureProvider<List<MealHistoryEntry>>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return [];
  final result = await ref.read(historyRepositoryProvider).getHistory(user.uid);
  return result.fold((_) => [], (list) => list);
});

/// Today's aggregated totals (used for calorie ring on home screen)
final todayTotalsProvider = FutureProvider<DailyTotals>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return DailyTotals.zero();

  final now = DateTime.now();
  final date =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

  // Also include today's home meals
  final homeAsync = ref.watch(homeMealsProvider);
  final homeCalories =
      homeAsync.value?.fold<double>(0, (s, m) => s + m.calories) ?? 0;
  final homeProtein =
      homeAsync.value?.fold<double>(0, (s, m) => s + m.protein) ?? 0;
  final homeCarbs =
      homeAsync.value?.fold<double>(0, (s, m) => s + m.carbs) ?? 0;
  final homeFats =
      homeAsync.value?.fold<double>(0, (s, m) => s + m.totalFat) ?? 0;

  final result =
      await ref.read(historyRepositoryProvider).getTodayHistory(user.uid, date);
  final entries = result.fold((_) => <MealHistoryEntry>[], (l) => l);

  return DailyTotals(
    calories: entries.fold<double>(0, (s, e) => s + e.calories) + homeCalories,
    protein: entries.fold<double>(0, (s, e) => s + e.protein) + homeProtein,
    carbs: entries.fold<double>(0, (s, e) => s + e.carbs) + homeCarbs,
    fats: entries.fold<double>(0, (s, e) => s + e.totalFat) + homeFats,
  );
});

class HistoryNotifier extends StateNotifier<AsyncValue<void>> {
  final HistoryRepository _repo;
  HistoryNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<String?> log(MealHistoryEntry entry) async {
    state = const AsyncValue.loading();
    final result = await _repo.logEntry(entry);
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

  Future<String?> delete(String id) async {
    state = const AsyncValue.loading();
    final result = await _repo.deleteEntry(id);
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

final historyNotifierProvider =
    StateNotifierProvider<HistoryNotifier, AsyncValue<void>>((ref) {
  return HistoryNotifier(ref.read(historyRepositoryProvider));
});
