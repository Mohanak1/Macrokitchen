import 'package:equatable/equatable.dart';
import '../../../../core/utils/bmi_calculator.dart';

class BmiProfile extends Equatable {
  final String uid;
  final String gender; // 'male' | 'female'
  final double heightCm;
  final double weightKg;
  final int age;
  final ActivityLevel activityLevel;
  final UserGoal goal;
  final String movement; // 'rarely' | 'light' | 'moderate' | 'active'
  final double bmiValue;
  final BmiCategory bmiCategory;
  final double dailyCalorieTarget;
  final List<String> conditions; // ['diabetes', 'high_bp']
  final List<String> allergies;  // ['milk', 'eggs', ...]
  final DateTime updatedAt;

  const BmiProfile({
    required this.uid,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.age,
    required this.activityLevel,
    required this.goal,
    required this.movement,
    required this.bmiValue,
    required this.bmiCategory,
    required this.dailyCalorieTarget,
    required this.conditions,
    required this.allergies,
    required this.updatedAt,
  });

  bool get isMale => gender == 'male';

  BmiProfile copyWith({
    String? gender,
    double? heightCm,
    double? weightKg,
    int? age,
    ActivityLevel? activityLevel,
    UserGoal? goal,
    String? movement,
    double? bmiValue,
    BmiCategory? bmiCategory,
    double? dailyCalorieTarget,
    List<String>? conditions,
    List<String>? allergies,
  }) {
    return BmiProfile(
      uid: uid,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      age: age ?? this.age,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      movement: movement ?? this.movement,
      bmiValue: bmiValue ?? this.bmiValue,
      bmiCategory: bmiCategory ?? this.bmiCategory,
      dailyCalorieTarget: dailyCalorieTarget ?? this.dailyCalorieTarget,
      conditions: conditions ?? this.conditions,
      allergies: allergies ?? this.allergies,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [uid, gender, heightCm, weightKg, age, bmiValue];
}
