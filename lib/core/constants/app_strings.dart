/// Non-localised app string constants
class AppStrings {
  AppStrings._();

  // Allergy keys (must match Firestore + SetupScreen)
  static const List<String> allergyKeys = [
    'milk', 'peanuts', 'shellfish', 'fish',
    'eggs', 'tree nut', 'soy', 'wheat', 'sesame',
  ];

  static const List<String> allergyLabels = [
    'Milk', 'Peanuts', 'Shellfish', 'Fish',
    'Eggs', 'Tree Nut', 'Soy', 'Wheat', 'Sesame',
  ];

  // Condition keys
  static const List<String> conditionKeys = ['diabetes', 'high_bp'];
  static const List<String> conditionLabels = ['Diabetes', 'High BP'];

  // BMI category labels
  static const String underweight = 'Underweight';
  static const String normalWeight = 'Normal';
  static const String overweight = 'Overweight';
  static const String obese = 'Obese';

  // Nutrition warning thresholds (mg/g)
  static const double highSodiumThreshold = 800; // mg per meal
  static const double highSugarThreshold = 15;   // g per meal

  // Meal types
  static const String restaurantMeal = 'restaurant';
  static const String homeMeal = 'home';

  // User roles
  static const String roleUser = 'user';
  static const String roleRestaurant = 'restaurant';

  // Firestore collections
  static const String colUsers = 'users';
  static const String colBmiProfiles = 'bmi_profiles';
  static const String colRestaurants = 'restaurants';
  static const String colMeals = 'meals';
  static const String colHomeMeals = 'home_meals';
  static const String colMealHistory = 'meal_history';
}
