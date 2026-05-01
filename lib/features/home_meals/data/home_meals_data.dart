import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';

// ── Entity ────────────────────────────────────────────────────────────────────

class HomeMeal extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? notes;
  final double calories;
  final double protein;
  final double carbs;
  final double totalFat;
  final double? sodium;
  final double? sugar;
  final double? fiber;
  final double? saturatedFat;
  final DateTime loggedAt;

  const HomeMeal({
    required this.id,
    required this.userId,
    required this.title,
    this.notes,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.totalFat,
    this.sodium,
    this.sugar,
    this.fiber,
    this.saturatedFat,
    required this.loggedAt,
  });

  @override
  List<Object?> get props => [id, userId, title, loggedAt];
}

// ── Model ─────────────────────────────────────────────────────────────────────

class HomeMealModel extends HomeMeal {
  const HomeMealModel({
    required super.id,
    required super.userId,
    required super.title,
    super.notes,
    required super.calories,
    required super.protein,
    required super.carbs,
    required super.totalFat,
    super.sodium,
    super.sugar,
    super.fiber,
    super.saturatedFat,
    required super.loggedAt,
  });

  factory HomeMealModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return HomeMealModel(
      id: doc.id,
      userId: d['userId'] as String? ?? '',
      title: d['title'] as String? ?? '',
      notes: d['notes'] as String?,
      calories: (d['calories'] as num?)?.toDouble() ?? 0,
      protein: (d['protein'] as num?)?.toDouble() ?? 0,
      carbs: (d['carbs'] as num?)?.toDouble() ?? 0,
      totalFat: (d['totalFat'] as num?)?.toDouble() ?? 0,
      sodium: (d['sodium'] as num?)?.toDouble(),
      sugar: (d['sugar'] as num?)?.toDouble(),
      fiber: (d['fiber'] as num?)?.toDouble(),
      saturatedFat: (d['saturatedFat'] as num?)?.toDouble(),
      loggedAt: d['loggedAt'] != null
          ? (d['loggedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'title': title,
        'notes': notes,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'totalFat': totalFat,
        'sodium': sodium,
        'sugar': sugar,
        'fiber': fiber,
        'saturatedFat': saturatedFat,
        'loggedAt': FieldValue.serverTimestamp(),
      };
}

// ── Datasource ────────────────────────────────────────────────────────────────

class HomeMealsDatasource {
  final FirebaseFirestore _db;
  HomeMealsDatasource({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Future<List<HomeMealModel>> getUserHomeMeals(String userId) async {
    final snap = await _db
        .collection('home_meals')
        .where('userId', isEqualTo: userId)
        .orderBy('loggedAt', descending: true)
        .get();
    return snap.docs.map(HomeMealModel.fromFirestore).toList();
  }

  Future<void> addHomeMeal(HomeMealModel meal) async {
    await _db.collection('home_meals').add(meal.toFirestore());
  }

  Future<void> updateHomeMeal(String id, HomeMealModel meal) async {
    await _db.collection('home_meals').doc(id).update({
      'title': meal.title,
      'notes': meal.notes,
      'calories': meal.calories,
      'protein': meal.protein,
      'carbs': meal.carbs,
      'totalFat': meal.totalFat,
      'sodium': meal.sodium,
      'sugar': meal.sugar,
      'fiber': meal.fiber,
      'saturatedFat': meal.saturatedFat,
    });
  }

  Future<void> deleteHomeMeal(String id) async {
    await _db.collection('home_meals').doc(id).delete();
  }
}

// ── Repository Interface ──────────────────────────────────────────────────────

abstract class HomeMealsRepository {
  Future<Either<Failure, List<HomeMeal>>> getUserHomeMeals(String userId);
  Future<Either<Failure, void>> addHomeMeal(HomeMeal meal, String userId);
  Future<Either<Failure, void>> updateHomeMeal(String id, HomeMeal meal);
  Future<Either<Failure, void>> deleteHomeMeal(String id);
}

// ── Repository Implementation ─────────────────────────────────────────────────

class HomeMealsRepositoryImpl implements HomeMealsRepository {
  final HomeMealsDatasource _ds;
  HomeMealsRepositoryImpl(this._ds);

  @override
  Future<Either<Failure, List<HomeMeal>>> getUserHomeMeals(
      String userId) async {
    try {
      return Right(await _ds.getUserHomeMeals(userId));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addHomeMeal(
      HomeMeal meal, String userId) async {
    try {
      final model = HomeMealModel(
        id: '',
        userId: userId,
        title: meal.title,
        notes: meal.notes,
        calories: meal.calories,
        protein: meal.protein,
        carbs: meal.carbs,
        totalFat: meal.totalFat,
        sodium: meal.sodium,
        sugar: meal.sugar,
        fiber: meal.fiber,
        saturatedFat: meal.saturatedFat,
        loggedAt: DateTime.now(),
      );
      await _ds.addHomeMeal(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateHomeMeal(
      String id, HomeMeal meal) async {
    try {
      final model = HomeMealModel(
        id: id,
        userId: meal.userId,
        title: meal.title,
        notes: meal.notes,
        calories: meal.calories,
        protein: meal.protein,
        carbs: meal.carbs,
        totalFat: meal.totalFat,
        sodium: meal.sodium,
        sugar: meal.sugar,
        fiber: meal.fiber,
        saturatedFat: meal.saturatedFat,
        loggedAt: meal.loggedAt,
      );
      await _ds.updateHomeMeal(id, model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteHomeMeal(String id) async {
    try {
      await _ds.deleteHomeMeal(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
