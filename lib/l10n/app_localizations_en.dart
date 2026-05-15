// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'MacroKitchen';

  @override
  String get login => 'Log In';

  @override
  String get register => 'Sign Up';

  @override
  String get logout => 'Log Out';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Your Password?';

  @override
  String get fullName => 'Full Name';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get setup => 'SetUp';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get height => 'Height';

  @override
  String get weight => 'Weight';

  @override
  String get age => 'Age';

  @override
  String get exerciseFrequency => 'Exercise frequency';

  @override
  String get weightGoal => 'Weight goal';

  @override
  String get movement => 'Movement';

  @override
  String get conditions => 'Conditions';

  @override
  String get allergies => 'Allergies';

  @override
  String get calculate => 'Calculate';

  @override
  String get home => 'Home';

  @override
  String get meals => 'Meals';

  @override
  String get settings => 'Settings';

  @override
  String get caloriesRemaining => 'Calories Remaining';

  @override
  String get weeklyProgress => 'Weekly Progress';

  @override
  String get mealHistory => 'Meal History';

  @override
  String get bmiProfile => 'BMI Profile';

  @override
  String get restaurantMenus => 'Restaurant Menus';

  @override
  String get homeMeals => 'Home Meals';

  @override
  String get recommended => 'Recommended';

  @override
  String get allMeals => 'All Meals';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get calories => 'Calories';

  @override
  String get protein => 'Protein';

  @override
  String get carbs => 'Carbohydrates';

  @override
  String get fat => 'Fat';

  @override
  String get sodium => 'Sodium';

  @override
  String get sugar => 'Sugar';

  @override
  String get fiber => 'Fiber';

  @override
  String get saturatedFat => 'Saturated Fat';

  @override
  String get language => 'Language';

  @override
  String get allergenWarning =>
      'This meal contains allergens you are sensitive to';

  @override
  String get highSodiumWarning => 'High Sodium — not suitable for High BP';

  @override
  String get highSugarWarning => 'High Sugar — not suitable for Diabetes';

  @override
  String get noMealsFound => 'No meals found.';

  @override
  String get completeBmiSetup =>
      'Complete your BMI setup to get personalized recommendations.';

  @override
  String get homeMealPage => 'Home Meal Page';

  @override
  String get kCal => 'kCal';

  @override
  String get totalFat => 'Total Fat';

  @override
  String get noHomeMealsYet => 'No home meals logged yet.';

  @override
  String get logAMeal => 'Log a Meal';

  @override
  String get errorLoadingMeals => 'Error loading meals';

  @override
  String get deleteMealTitle => 'Delete meal?';

  @override
  String get deleteMealMessage => 'This meal will be removed from your log.';

  @override
  String get editMeal => 'Edit Meal';

  @override
  String get homeMeal => 'Home Meal';

  @override
  String get titleField => 'Title';

  @override
  String get notes => 'Notes';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get enterValidNumber => 'Enter a valid number';

  @override
  String get profile => 'Profile';

  @override
  String get nutritionReport => 'Nutrition Report';

  @override
  String helloUser(String name) {
    return 'Hello, $name 👋';
  }

  @override
  String bmiSummary(String value, String goal) {
    return 'BMI: $value · $goal';
  }

  @override
  String get setupHint => 'Complete setup to get recommendations';

  @override
  String get setupBmiNow => 'Complete BMI Setup';
}
