import '../../features/bmi/domain/entities/bmi_profile.dart';
import '../../features/meals/domain/entities/meal.dart';
import 'bmi_calculator.dart';

/// Rules-based meal recommendation engine.
/// Scores each meal 0–100 based on:
///   1. Calorie proximity to single-meal target
///   2. Macro distribution matching user goal
///   3. Allergen/condition filtering
///
/// Assumptions documented:
/// - Single meal target = daily target / 3
/// - High protein threshold: > 25g per meal
/// - High sodium: > 800mg per meal (warning for High BP)
/// - High sugar: > 15g per meal (warning for Diabetes)
class RecommendationEngine {
  RecommendationEngine._();

  static const double _maxCalorieDelta = 300;

  /// Returns scored + filtered meals sorted by score descending
  static List<ScoredMeal> recommend({
    required List<Meal> meals,
    required BmiProfile profile,
    required double dailyCalorieTarget,
  }) {
    final singleMealTarget = dailyCalorieTarget / 3;
    final goal = profile.goal;
    final allergies = profile.allergies.map((a) => a.toLowerCase()).toSet();
    final conditions = profile.conditions.map((c) => c.toLowerCase()).toSet();

    final results = <ScoredMeal>[];

    for (final meal in meals) {
      // --- 1. Allergen filtering ---
      final mealAllergens = meal.allergens.map((a) => a.toLowerCase()).toSet();
      final hasAllergen = allergies.intersection(mealAllergens).isNotEmpty;
      final conflictingAllergens = allergies.intersection(mealAllergens).toList();

      // --- 2. Condition warnings ---
      final warnings = <String>[];
      if (conditions.contains('high_bp') || conditions.contains('high bp')) {
        if ((meal.sodium ?? 0) > 800) {
          warnings.add('high_sodium');
        }
      }
      if (conditions.contains('diabetes')) {
        if ((meal.sugar ?? 0) > 15) {
          warnings.add('high_sugar');
        }
      }

      // --- 3. Score calculation ---
      double score = 100;

      // Calorie score (0–40 points): penalize distance from target
      final calorieDelta = (meal.calories - singleMealTarget).abs();
      final calorieScore = 40 * (1 - (calorieDelta / _maxCalorieDelta).clamp(0, 1));

      // Macro score (0–40 points)
      double macroScore = 0;
      switch (goal) {
        case UserGoal.weightLoss:
          // Reward: high protein, low fat, moderate carbs
          if (meal.protein >= 25) macroScore += 15;
          if (meal.totalFat != null && meal.totalFat! <= 15) macroScore += 15;
          if (meal.carbs <= 40) macroScore += 10;
          break;
        case UserGoal.muscleGain:
          // Reward: high protein, moderate carbs, sufficient calories
          if (meal.protein >= 30) macroScore += 20;
          if (meal.carbs >= 30 && meal.carbs <= 60) macroScore += 10;
          if (meal.calories >= singleMealTarget) macroScore += 10;
          break;
        case UserGoal.balanced:
          // Reward: moderate of everything
          if (meal.protein >= 20) macroScore += 13;
          if (meal.carbs >= 20 && meal.carbs <= 60) macroScore += 13;
          if (meal.totalFat != null && meal.totalFat! <= 25) macroScore += 14;
          break;
      }

      // Warning penalty (0–20 points)
      double warningPenalty = 0;
      if (hasAllergen) warningPenalty += 20; // Hard penalty
      warningPenalty += warnings.length * 10;
      warningPenalty = warningPenalty.clamp(0, 20);

      score = calorieScore + macroScore - warningPenalty;
      score = score.clamp(0, 100);

      results.add(ScoredMeal(
        meal: meal,
        score: score,
        hasAllergen: hasAllergen,
        conflictingAllergens: conflictingAllergens,
        warnings: warnings,
      ));
    }

    // Sort: non-allergen first, then by score
    results.sort((a, b) {
      if (a.hasAllergen != b.hasAllergen) {
        return a.hasAllergen ? 1 : -1;
      }
      return b.score.compareTo(a.score);
    });

    return results;
  }
}

class ScoredMeal {
  final Meal meal;
  final double score;
  final bool hasAllergen;
  final List<String> conflictingAllergens;
  final List<String> warnings; // 'high_sodium', 'high_sugar'

  const ScoredMeal({
    required this.meal,
    required this.score,
    required this.hasAllergen,
    required this.conflictingAllergens,
    required this.warnings,
  });

  bool get isRecommended => !hasAllergen && score >= 50;
  bool get hasWarnings => warnings.isNotEmpty;
  bool get isSafe => !hasAllergen && !hasWarnings;
}
