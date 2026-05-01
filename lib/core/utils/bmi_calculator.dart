/// BMI and calorie calculation utilities
/// Based on: WHO BMI standards + Mifflin-St Jeor equation
class BmiCalculator {
  BmiCalculator._();

  /// Calculate BMI: weight(kg) / height(m)²
  static double calculate({
    required double weightKg,
    required double heightCm,
  }) {
    final heightM = heightCm / 100;
    if (heightM <= 0 || weightKg <= 0) return 0;
    return weightKg / (heightM * heightM);
  }

  /// WHO BMI category
  static BmiCategory getCategory(double bmi) {
    if (bmi < 18.5) return BmiCategory.underweight;
    if (bmi < 25.0) return BmiCategory.normal;
    if (bmi < 30.0) return BmiCategory.overweight;
    return BmiCategory.obese;
  }

  static String getCategoryLabel(BmiCategory category) {
    switch (category) {
      case BmiCategory.underweight:
        return 'Underweight';
      case BmiCategory.normal:
        return 'Normal';
      case BmiCategory.overweight:
        return 'Overweight';
      case BmiCategory.obese:
        return 'Obese';
    }
  }

  static String getCategoryLabelAr(BmiCategory category) {
    switch (category) {
      case BmiCategory.underweight:
        return 'نقص الوزن';
      case BmiCategory.normal:
        return 'طبيعي';
      case BmiCategory.overweight:
        return 'زيادة الوزن';
      case BmiCategory.obese:
        return 'سمنة';
    }
  }
}

/// Calorie / TDEE Calculator using Mifflin-St Jeor equation
class CalorieCalculator {
  CalorieCalculator._();

  /// Basal Metabolic Rate (Mifflin-St Jeor)
  static double calculateBMR({
    required double weightKg,
    required double heightCm,
    required int age,
    required bool isMale,
  }) {
    final base = (10 * weightKg) + (6.25 * heightCm) - (5 * age);
    return isMale ? base + 5 : base - 161;
  }

  /// Total Daily Energy Expenditure
  static double calculateTDEE({
    required double bmr,
    required ActivityLevel activityLevel,
  }) {
    return bmr * activityLevel.multiplier;
  }

  /// Adjust TDEE based on user's goal
  static double adjustForGoal({
    required double tdee,
    required UserGoal goal,
  }) {
    switch (goal) {
      case UserGoal.weightLoss:
        return tdee - 500;
      case UserGoal.muscleGain:
        return tdee + 300;
      case UserGoal.balanced:
        return tdee;
    }
  }

  /// Single meal calorie target (assuming 3 meals/day)
  static double singleMealTarget(double dailyTarget) => dailyTarget / 3;
}

enum BmiCategory { underweight, normal, overweight, obese }

enum ActivityLevel {
  sedentary(1.2, 'Rarely', 'نادراً'),
  lightlyActive(1.375, 'Light', 'خفيف'),
  moderatelyActive(1.55, '1-3 per week', '1-3 في الأسبوع'),
  veryActive(1.725, '4-6 per week', '4-6 في الأسبوع'),
  superActive(1.9, 'Daily', 'يومياً');

  final double multiplier;
  final String labelEn;
  final String labelAr;

  const ActivityLevel(this.multiplier, this.labelEn, this.labelAr);
}

enum UserGoal {
  weightLoss('Weight Loss', 'خسارة الوزن'),
  muscleGain('Muscle Gain', 'بناء العضلات'),
  balanced('Balanced', 'متوازن');

  final String labelEn;
  final String labelAr;

  const UserGoal(this.labelEn, this.labelAr);
}
