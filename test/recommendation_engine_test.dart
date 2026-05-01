import 'package:flutter_test/flutter_test.dart';
import 'package:macrokitchen/core/utils/bmi_calculator.dart';
import 'package:macrokitchen/core/utils/recommendation_engine.dart';
import 'package:macrokitchen/features/bmi/domain/entities/bmi_profile.dart';
import 'package:macrokitchen/features/meals/domain/entities/meal.dart';

// Helper builders
BmiProfile _makeProfile({
  UserGoal goal = UserGoal.balanced,
  List<String> allergies = const [],
  List<String> conditions = const [],
  double dailyTarget = 2000,
}) {
  return BmiProfile(
    uid: 'test-uid',
    gender: 'male',
    heightCm: 175,
    weightKg: 75,
    age: 25,
    activityLevel: ActivityLevel.moderatelyActive,
    goal: goal,
    movement: 'light',
    bmiValue: 24.5,
    bmiCategory: BmiCategory.normal,
    dailyCalorieTarget: dailyTarget,
    conditions: conditions,
    allergies: allergies,
    updatedAt: DateTime.now(),
  );
}

Meal _makeMeal({
  String id = 'meal-1',
  String title = 'Test Meal',
  double calories = 650,
  double protein = 30,
  double carbs = 50,
  double totalFat = 20,
  double sodium = 400,
  double sugar = 5,
  List<String> allergens = const [],
}) {
  return Meal(
    id: id,
    restaurantId: 'rest-1',
    restaurantName: 'Test Restaurant',
    title: title,
    type: 'restaurant',
    calories: calories,
    protein: protein,
    carbs: carbs,
    totalFat: totalFat,
    sodium: sodium,
    sugar: sugar,
    allergens: allergens,
    createdAt: DateTime.now(),
  );
}

void main() {
  group('RecommendationEngine', () {
    test('returns empty list for empty meals input', () {
      final profile = _makeProfile();
      final results = RecommendationEngine.recommend(
        meals: [],
        profile: profile,
        dailyCalorieTarget: 2000,
      );
      expect(results, isEmpty);
    });

    test('scores a safe, calorie-appropriate meal above 50', () {
      final profile = _makeProfile(goal: UserGoal.balanced);
      final meal = _makeMeal(calories: 667, protein: 25, carbs: 45, totalFat: 15);

      final results = RecommendationEngine.recommend(
        meals: [meal],
        profile: profile,
        dailyCalorieTarget: 2000,
      );

      expect(results.length, 1);
      expect(results.first.score, greaterThan(50));
      expect(results.first.isRecommended, isTrue);
      expect(results.first.hasAllergen, isFalse);
    });

    test('flags meal with matching user allergen', () {
      final profile = _makeProfile(allergies: ['milk']);
      final meal = _makeMeal(allergens: ['Milk', 'Eggs']);

      final results = RecommendationEngine.recommend(
        meals: [meal],
        profile: profile,
        dailyCalorieTarget: 2000,
      );

      expect(results.first.hasAllergen, isTrue);
      expect(results.first.conflictingAllergens, contains('milk'));
      expect(results.first.isRecommended, isFalse);
    });

    test('does NOT flag meal when allergens do not match user profile', () {
      final profile = _makeProfile(allergies: ['peanuts']);
      final meal = _makeMeal(allergens: ['Milk']);

      final results = RecommendationEngine.recommend(
        meals: [meal],
        profile: profile,
        dailyCalorieTarget: 2000,
      );

      expect(results.first.hasAllergen, isFalse);
    });

    test('warns about high sodium for High BP condition', () {
      final profile = _makeProfile(conditions: ['high_bp']);
      final meal = _makeMeal(sodium: 900); // above 800mg threshold

      final results = RecommendationEngine.recommend(
        meals: [meal],
        profile: profile,
        dailyCalorieTarget: 2000,
      );

      expect(results.first.warnings, contains('high_sodium'));
      expect(results.first.hasWarnings, isTrue);
      expect(results.first.isSafe, isFalse);
    });

    test('does NOT warn about sodium below 800mg for High BP', () {
      final profile = _makeProfile(conditions: ['high_bp']);
      final meal = _makeMeal(sodium: 600);

      final results = RecommendationEngine.recommend(
        meals: [meal],
        profile: profile,
        dailyCalorieTarget: 2000,
      );

      expect(results.first.warnings, isNot(contains('high_sodium')));
    });

    test('warns about high sugar for Diabetes condition', () {
      final profile = _makeProfile(conditions: ['diabetes']);
      final meal = _makeMeal(sugar: 20); // above 15g threshold

      final results = RecommendationEngine.recommend(
        meals: [meal],
        profile: profile,
        dailyCalorieTarget: 2000,
      );

      expect(results.first.warnings, contains('high_sugar'));
    });

    test('sorts safe meals before allergen meals', () {
      final profile = _makeProfile(allergies: ['milk']);
      final allergenMeal = _makeMeal(id: 'a', title: 'Allergen Meal',
          allergens: ['Milk'], calories: 667, protein: 35);
      final safeMeal = _makeMeal(id: 'b', title: 'Safe Meal',
          allergens: [], calories: 667, protein: 25);

      final results = RecommendationEngine.recommend(
        meals: [allergenMeal, safeMeal],
        profile: profile,
        dailyCalorieTarget: 2000,
      );

      expect(results.first.meal.id, 'b'); // safe meal first
      expect(results.last.meal.id, 'a');  // allergen meal last
    });

    test('higher score for weight-loss goal with high-protein low-fat meal', () {
      final profile = _makeProfile(goal: UserGoal.weightLoss);
      final goodMeal = _makeMeal(id: 'good', protein: 35, totalFat: 10, carbs: 30, calories: 650);
      final badMeal  = _makeMeal(id: 'bad',  protein: 10, totalFat: 30, carbs: 70, calories: 650);

      final results = RecommendationEngine.recommend(
        meals: [badMeal, goodMeal],
        profile: profile,
        dailyCalorieTarget: 2000,
      );

      final goodScore = results.firstWhere((r) => r.meal.id == 'good').score;
      final badScore  = results.firstWhere((r) => r.meal.id == 'bad').score;
      expect(goodScore, greaterThan(badScore));
    });

    test('higher score for muscle-gain goal with high-protein high-calorie meal', () {
      final profile = _makeProfile(goal: UserGoal.muscleGain);
      final goodMeal = _makeMeal(id: 'good', protein: 40, carbs: 50, calories: 800);
      final badMeal  = _makeMeal(id: 'bad',  protein: 10, carbs: 20, calories: 300);

      final results = RecommendationEngine.recommend(
        meals: [badMeal, goodMeal],
        profile: profile,
        dailyCalorieTarget: 2000,
      );

      final goodScore = results.firstWhere((r) => r.meal.id == 'good').score;
      final badScore  = results.firstWhere((r) => r.meal.id == 'bad').score;
      expect(goodScore, greaterThan(badScore));
    });

    test('score is clamped between 0 and 100', () {
      final profile = _makeProfile(
        allergies: ['milk'],
        conditions: ['high_bp', 'diabetes'],
      );
      final badMeal = _makeMeal(
        allergens: ['Milk'],
        sodium: 1200,
        sugar: 30,
        calories: 5000, // wildly off target
      );

      final results = RecommendationEngine.recommend(
        meals: [badMeal],
        profile: profile,
        dailyCalorieTarget: 2000,
      );

      expect(results.first.score, greaterThanOrEqualTo(0));
      expect(results.first.score, lessThanOrEqualTo(100));
    });

    test('isSafe is true only when no allergen and no warnings', () {
      final profile = _makeProfile();
      final meal = _makeMeal(allergens: [], sodium: 300, sugar: 5);

      final results = RecommendationEngine.recommend(
        meals: [meal],
        profile: profile,
        dailyCalorieTarget: 2000,
      );

      expect(results.first.isSafe, isTrue);
    });
  });
}
