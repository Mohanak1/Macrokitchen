import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../domain/entities/meal.dart';

// ── Meal Model ────────────────────────────────────────────────────────────────

class MealModel extends Meal {
  const MealModel({
    required super.id,
    required super.restaurantId,
    required super.restaurantName,
    required super.title,
    super.imageUrl,
    required super.type,
    super.rating,
    required super.calories,
    required super.protein,
    required super.carbs,
    super.totalFat,
    super.sodium,
    super.sugar,
    super.fiber,
    super.saturatedFat,
    super.allergens,
    super.isActive,
    required super.createdAt,
  });

  factory MealModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MealModel(
      id: doc.id,
      restaurantId: data['restaurantId'] as String? ?? '',
      restaurantName: data['restaurantName'] as String? ?? '',
      title: data['title'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      type: data['type'] as String? ?? 'restaurant',
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      calories: (data['calories'] as num?)?.toDouble() ?? 0,
      protein: (data['protein'] as num?)?.toDouble() ?? 0,
      carbs: (data['carbs'] as num?)?.toDouble() ?? 0,
      totalFat: (data['totalFat'] as num?)?.toDouble(),
      sodium: (data['sodium'] as num?)?.toDouble(),
      sugar: (data['sugar'] as num?)?.toDouble(),
      fiber: (data['fiber'] as num?)?.toDouble(),
      saturatedFat: (data['saturatedFat'] as num?)?.toDouble(),
      allergens: List<String>.from(data['allergens'] as List? ?? []),
      isActive: data['isActive'] as bool? ?? true,
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (data['createdAt'] as Timestamp).millisecondsSinceEpoch)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'restaurantId': restaurantId,
        'restaurantName': restaurantName,
        'title': title,
        'imageUrl': imageUrl,
        'type': type,
        'rating': rating,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'totalFat': totalFat,
        'sodium': sodium,
        'sugar': sugar,
        'fiber': fiber,
        'saturatedFat': saturatedFat,
        'allergens': allergens,
        'isActive': isActive,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

// ── Remote Datasource ─────────────────────────────────────────────────────────

class MealsRemoteDatasource {
  final FirebaseFirestore _db;
  MealsRemoteDatasource({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Future<List<MealModel>> getAllMeals() async {
    final snap = await _db
        .collection('meals')
        .where('isActive', isEqualTo: true)
        .get();
    return snap.docs.map(MealModel.fromFirestore).toList();
  }

  Future<List<MealModel>> getMealsByRestaurant(String restaurantId) async {
    final snap = await _db
        .collection('meals')
        .where('restaurantId', isEqualTo: restaurantId)
        .where('isActive', isEqualTo: true)
        .get();
    return snap.docs.map(MealModel.fromFirestore).toList();
  }

  Future<MealModel?> getMealById(String mealId) async {
    final doc = await _db.collection('meals').doc(mealId).get();
    if (!doc.exists) return null;
    return MealModel.fromFirestore(doc);
  }

  Future<void> addMeal(MealModel meal) async {
    await _db.collection('meals').add(meal.toFirestore());
  }

  Future<void> updateMeal(String mealId, MealModel meal) async {
    await _db.collection('meals').doc(mealId).update(meal.toFirestore());
  }

  Future<void> deleteMeal(String mealId) async {
    await _db.collection('meals').doc(mealId).update({'isActive': false});
  }
}

// ── Repository Interface ──────────────────────────────────────────────────────

abstract class MealsRepository {
  Future<Either<Failure, List<Meal>>> getAllMeals();
  Future<Either<Failure, List<Meal>>> getMealsByRestaurant(String restaurantId);
  Future<Either<Failure, Meal?>> getMealById(String mealId);
  Future<Either<Failure, void>> addMeal(Meal meal, String restaurantId, String restaurantName);
  Future<Either<Failure, void>> updateMeal(String mealId, Meal meal);
  Future<Either<Failure, void>> deleteMeal(String mealId);
}

// ── Repository Implementation ─────────────────────────────────────────────────

class MealsRepositoryImpl implements MealsRepository {
  final MealsRemoteDatasource _ds;
  MealsRepositoryImpl(this._ds);

  @override
  Future<Either<Failure, List<Meal>>> getAllMeals() async {
    try {
      return Right(await _ds.getAllMeals());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Meal>>> getMealsByRestaurant(String restaurantId) async {
    try {
      return Right(await _ds.getMealsByRestaurant(restaurantId));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Meal?>> getMealById(String mealId) async {
    try {
      return Right(await _ds.getMealById(mealId));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addMeal(
      Meal meal, String restaurantId, String restaurantName) async {
    try {
      final model = MealModel(
        id: '',
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        title: meal.title,
        imageUrl: meal.imageUrl,
        type: 'restaurant',
        rating: meal.rating,
        calories: meal.calories,
        protein: meal.protein,
        carbs: meal.carbs,
        totalFat: meal.totalFat,
        sodium: meal.sodium,
        sugar: meal.sugar,
        fiber: meal.fiber,
        saturatedFat: meal.saturatedFat,
        allergens: meal.allergens,
        isActive: true,
        createdAt: DateTime.now(),
      );
      await _ds.addMeal(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateMeal(String mealId, Meal meal) async {
    try {
      final model = MealModel(
        id: mealId,
        restaurantId: meal.restaurantId,
        restaurantName: meal.restaurantName,
        title: meal.title,
        imageUrl: meal.imageUrl,
        type: meal.type,
        rating: meal.rating,
        calories: meal.calories,
        protein: meal.protein,
        carbs: meal.carbs,
        totalFat: meal.totalFat,
        sodium: meal.sodium,
        sugar: meal.sugar,
        fiber: meal.fiber,
        saturatedFat: meal.saturatedFat,
        allergens: meal.allergens,
        isActive: meal.isActive,
        createdAt: meal.createdAt,
      );
      await _ds.updateMeal(mealId, model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMeal(String mealId) async {
    try {
      await _ds.deleteMeal(mealId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
