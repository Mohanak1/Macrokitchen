import '../../../../core/utils/bmi_calculator.dart';
import '../../domain/entities/bmi_profile.dart';

class BmiProfileModel extends BmiProfile {
  const BmiProfileModel({
    required super.uid,
    required super.gender,
    required super.heightCm,
    required super.weightKg,
    required super.age,
    required super.activityLevel,
    required super.goal,
    required super.movement,
    required super.bmiValue,
    required super.bmiCategory,
    required super.dailyCalorieTarget,
    required super.conditions,
    required super.allergies,
    required super.updatedAt,
  });

  factory BmiProfileModel.fromFirestore(Map<String, dynamic> data, String uid) {
    final activityIndex = data['activityLevelIndex'] as int? ?? 0;
    final goalIndex = data['goalIndex'] as int? ?? 2;
    final categoryIndex = data['bmiCategoryIndex'] as int? ?? 1;

    return BmiProfileModel(
      uid: uid,
      gender: data['gender'] as String? ?? 'male',
      heightCm: (data['heightCm'] as num?)?.toDouble() ?? 170,
      weightKg: (data['weightKg'] as num?)?.toDouble() ?? 70,
      age: data['age'] as int? ?? 25,
      activityLevel: ActivityLevel.values[activityIndex.clamp(0, ActivityLevel.values.length - 1)],
      goal: UserGoal.values[goalIndex.clamp(0, UserGoal.values.length - 1)],
      movement: data['movement'] as String? ?? 'rarely',
      bmiValue: (data['bmiValue'] as num?)?.toDouble() ?? 0,
      bmiCategory: BmiCategory.values[categoryIndex.clamp(0, BmiCategory.values.length - 1)],
      dailyCalorieTarget: (data['dailyCalorieTarget'] as num?)?.toDouble() ?? 2000,
      conditions: List<String>.from(data['conditions'] as List? ?? []),
      allergies: List<String>.from(data['allergies'] as List? ?? []),
      updatedAt: data['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (data['updatedAt'] as dynamic).millisecondsSinceEpoch)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'gender': gender,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'age': age,
      'activityLevelIndex': activityLevel.index,
      'goalIndex': goal.index,
      'movement': movement,
      'bmiValue': bmiValue,
      'bmiCategoryIndex': bmiCategory.index,
      'dailyCalorieTarget': dailyCalorieTarget,
      'conditions': conditions,
      'allergies': allergies,
      'updatedAt': updatedAt,
    };
  }

  factory BmiProfileModel.fromEntity(BmiProfile p) {
    return BmiProfileModel(
      uid: p.uid,
      gender: p.gender,
      heightCm: p.heightCm,
      weightKg: p.weightKg,
      age: p.age,
      activityLevel: p.activityLevel,
      goal: p.goal,
      movement: p.movement,
      bmiValue: p.bmiValue,
      bmiCategory: p.bmiCategory,
      dailyCalorieTarget: p.dailyCalorieTarget,
      conditions: p.conditions,
      allergies: p.allergies,
      updatedAt: p.updatedAt,
    );
  }
}
