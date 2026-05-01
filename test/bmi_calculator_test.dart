import 'package:flutter_test/flutter_test.dart';
import 'package:macrokitchen/core/utils/bmi_calculator.dart';

void main() {
  group('BmiCalculator', () {
    test('calculates BMI correctly for normal weight', () {
      final bmi = BmiCalculator.calculate(weightKg: 70, heightCm: 175);
      expect(bmi, closeTo(22.86, 0.01));
    });

    test('calculates BMI correctly for underweight', () {
      final bmi = BmiCalculator.calculate(weightKg: 45, heightCm: 175);
      expect(bmi, closeTo(14.69, 0.01));
    });

    test('returns 0 for invalid inputs', () {
      expect(BmiCalculator.calculate(weightKg: 0, heightCm: 175), 0);
      expect(BmiCalculator.calculate(weightKg: 70, heightCm: 0), 0);
    });

    group('getCategory', () {
      test('underweight below 18.5', () {
        expect(BmiCalculator.getCategory(17.0), BmiCategory.underweight);
      });

      test('normal between 18.5 and 24.9', () {
        expect(BmiCalculator.getCategory(22.0), BmiCategory.normal);
      });

      test('overweight between 25 and 29.9', () {
        expect(BmiCalculator.getCategory(27.5), BmiCategory.overweight);
      });

      test('obese at 30 or above', () {
        expect(BmiCalculator.getCategory(32.0), BmiCategory.obese);
      });

      test('boundary at exactly 18.5 is normal', () {
        expect(BmiCalculator.getCategory(18.5), BmiCategory.normal);
      });

      test('boundary at exactly 25.0 is overweight', () {
        expect(BmiCalculator.getCategory(25.0), BmiCategory.overweight);
      });

      test('boundary at exactly 30.0 is obese', () {
        expect(BmiCalculator.getCategory(30.0), BmiCategory.obese);
      });
    });

    group('getCategoryLabel', () {
      test('returns correct English labels', () {
        expect(BmiCalculator.getCategoryLabel(BmiCategory.underweight),
            'Underweight');
        expect(BmiCalculator.getCategoryLabel(BmiCategory.normal), 'Normal');
        expect(BmiCalculator.getCategoryLabel(BmiCategory.overweight),
            'Overweight');
        expect(BmiCalculator.getCategoryLabel(BmiCategory.obese), 'Obese');
      });
    });
  });

  group('CalorieCalculator', () {
    test('calculates male BMR correctly', () {
      // 10*70 + 6.25*175 - 5*25 + 5 = 700 + 1093.75 - 125 + 5 = 1673.75
      final bmr = CalorieCalculator.calculateBMR(
        weightKg: 70,
        heightCm: 175,
        age: 25,
        isMale: true,
      );
      expect(bmr, closeTo(1673.75, 0.1));
    });

    test('calculates female BMR correctly', () {
      // 10*60 + 6.25*165 - 5*30 - 161 = 600 + 1031.25 - 150 - 161 = 1320.25
      final bmr = CalorieCalculator.calculateBMR(
        weightKg: 60,
        heightCm: 165,
        age: 30,
        isMale: false,
      );
      expect(bmr, closeTo(1320.25, 0.1));
    });

    test('applies sedentary activity multiplier', () {
      const bmr = 1600.0;
      final tdee = CalorieCalculator.calculateTDEE(
        bmr: bmr,
        activityLevel: ActivityLevel.sedentary,
      );
      expect(tdee, closeTo(1920.0, 0.1));
    });

    test('adjusts for weight loss goal (-500 cal)', () {
      const tdee = 2000.0;
      final adjusted = CalorieCalculator.adjustForGoal(
        tdee: tdee,
        goal: UserGoal.weightLoss,
      );
      expect(adjusted, closeTo(1500.0, 0.1));
    });

    test('adjusts for muscle gain goal (+300 cal)', () {
      const tdee = 2000.0;
      final adjusted = CalorieCalculator.adjustForGoal(
        tdee: tdee,
        goal: UserGoal.muscleGain,
      );
      expect(adjusted, closeTo(2300.0, 0.1));
    });

    test('no adjustment for balanced goal', () {
      const tdee = 2000.0;
      final adjusted = CalorieCalculator.adjustForGoal(
        tdee: tdee,
        goal: UserGoal.balanced,
      );
      expect(adjusted, closeTo(2000.0, 0.1));
    });

    test('single meal target is daily / 3', () {
      final target = CalorieCalculator.singleMealTarget(2100);
      expect(target, closeTo(700.0, 0.1));
    });
  });
}
