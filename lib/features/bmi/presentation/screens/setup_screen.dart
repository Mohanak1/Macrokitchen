import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/bmi_calculator.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/bmi_profile.dart';
import '../providers/bmi_provider.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _heightCtrl = TextEditingController(text: '182');
  final _weightCtrl = TextEditingController(text: '75');
  final _ageCtrl = TextEditingController(text: '23');

  String _gender = 'male';
  ActivityLevel _activityLevel = ActivityLevel.moderatelyActive;
  UserGoal _goal = UserGoal.balanced;
  String _movement = 'Rarely';

  final Set<String> _selectedConditions = {};
  final Set<String> _selectedAllergies = {};

  static const _conditions = ['Diabetes', 'High BP'];
  static const _allergies = [
    'Milk',
    'Peanuts',
    'Shellfish',
    'Fish',
    'Eggs',
    'Tree Nut',
    'Soy',
    'Wheat',
    'Sesame',
  ];

  static const _activityOptions = [
    'Rarely',
    'Light',
    '1-3 per week',
    '4-6 per week',
    'Daily'
  ];

  static const _movementOptions = ['Rarely', 'Light', 'Moderate', 'Active'];

  static const _goalOptions = ['Weight Loss', 'Muscle Gain', 'Balanced'];

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _calculate() async {
    // Validate using Validators utility
    final heightErr = Validators.height(_heightCtrl.text);
    final weightErr = Validators.weight(_weightCtrl.text);
    final ageErr = Validators.age(_ageCtrl.text);

    final firstError = heightErr ?? weightErr ?? ageErr;
    if (firstError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(firstError), backgroundColor: AppColors.error),
      );
      return;
    }

    final height = double.parse(_heightCtrl.text);
    final weight = double.parse(_weightCtrl.text);
    final age = int.parse(_ageCtrl.text);

    final bmi = BmiCalculator.calculate(weightKg: weight, heightCm: height);
    final bmiCategory = BmiCalculator.getCategory(bmi);

    final bmr = CalorieCalculator.calculateBMR(
      weightKg: weight,
      heightCm: height,
      age: age,
      isMale: _gender == 'male',
    );
    final tdee = CalorieCalculator.calculateTDEE(
        bmr: bmr, activityLevel: _activityLevel);
    final dailyTarget =
        CalorieCalculator.adjustForGoal(tdee: tdee, goal: _goal);

    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final profile = BmiProfile(
      uid: user.uid,
      gender: _gender,
      heightCm: height,
      weightKg: weight,
      age: age,
      activityLevel: _activityLevel,
      goal: _goal,
      movement: _movement.toLowerCase(),
      bmiValue: bmi,
      bmiCategory: bmiCategory,
      dailyCalorieTarget: dailyTarget,
      conditions: _selectedConditions
          .map((c) => c.toLowerCase().replaceAll(' ', '_'))
          .toList(),
      allergies: _selectedAllergies.map((a) => a.toLowerCase()).toList(),
      updatedAt: DateTime.now(),
    );

    final error = await ref.read(bmiNotifierProvider.notifier).save(profile);
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    } else if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(bmiNotifierProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('SetUp')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Gender ──────────────────────────────────────────────────────
            const _SectionLabel('Gender'),
            const SizedBox(height: AppDimensions.sm),
            Row(
              children: [
                _GenderButton(
                  label: 'Male',
                  selected: _gender == 'male',
                  onTap: () => setState(() => _gender = 'male'),
                ),
                const SizedBox(width: AppDimensions.lg),
                _GenderButton(
                  label: 'Female',
                  selected: _gender == 'female',
                  onTap: () => setState(() => _gender = 'female'),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.xl),

            // ── Height / Weight / Age ────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _MeasurementField(
                    label: 'Height',
                    unit: 'cm',
                    controller: _heightCtrl,
                  ),
                ),
                const SizedBox(width: AppDimensions.lg),
                Expanded(
                  child: _MeasurementField(
                    label: 'Weight',
                    unit: 'kg',
                    controller: _weightCtrl,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.lg),
            Center(
              child: SizedBox(
                width: 140,
                child: _MeasurementField(
                  label: 'Age',
                  unit: 'yrs',
                  controller: _ageCtrl,
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.xl),

            // ── Exercise Frequency ───────────────────────────────────────────
            const _SectionLabel('Exercise frequency'),
            const SizedBox(height: AppDimensions.sm),
            _DropdownField<ActivityLevel>(
              value: _activityLevel,
              items: ActivityLevel.values,
              labelBuilder: (v) => v.labelEn,
              onChanged: (v) => setState(() => _activityLevel = v!),
            ),

            const SizedBox(height: AppDimensions.lg),

            // ── Weight Goal ──────────────────────────────────────────────────
            const _SectionLabel('Weight goal'),
            const SizedBox(height: AppDimensions.sm),
            _DropdownField<UserGoal>(
              value: _goal,
              items: UserGoal.values,
              labelBuilder: (v) => v.labelEn,
              onChanged: (v) => setState(() => _goal = v!),
            ),

            const SizedBox(height: AppDimensions.lg),

            // ── Movement ─────────────────────────────────────────────────────
            const _SectionLabel('Movement'),
            const SizedBox(height: AppDimensions.sm),
            _DropdownField<String>(
              value: _movement,
              items: _movementOptions,
              labelBuilder: (v) => v,
              onChanged: (v) => setState(() => _movement = v!),
            ),

            const SizedBox(height: AppDimensions.xl),

            // ── Conditions ───────────────────────────────────────────────────
            const _SectionLabel('Conditions'),
            const SizedBox(height: AppDimensions.sm),
            Wrap(
              spacing: AppDimensions.sm,
              runSpacing: AppDimensions.sm,
              children: _conditions.map((c) {
                final selected = _selectedConditions.contains(c);
                return _SelectChip(
                  label: c,
                  selected: selected,
                  onTap: () => setState(() {
                    selected
                        ? _selectedConditions.remove(c)
                        : _selectedConditions.add(c);
                  }),
                );
              }).toList(),
            ),

            const SizedBox(height: AppDimensions.xl),

            // ── Allergies ────────────────────────────────────────────────────
            const _SectionLabel('Allergies'),
            const SizedBox(height: AppDimensions.sm),
            Wrap(
              spacing: AppDimensions.sm,
              runSpacing: AppDimensions.sm,
              children: _allergies.map((a) {
                final selected = _selectedAllergies.contains(a);
                return _SelectChip(
                  label: a,
                  selected: selected,
                  onTap: () => setState(() {
                    selected
                        ? _selectedAllergies.remove(a)
                        : _selectedAllergies.add(a);
                  }),
                );
              }).toList(),
            ),

            const SizedBox(height: AppDimensions.xxxl),

            // ── Calculate Button ─────────────────────────────────────────────
            AppButton(
              label: 'Calculate',
              onPressed: _calculate,
              isLoading: isLoading,
            ),

            const SizedBox(height: AppDimensions.xxl),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.headlineSmall);
  }
}

class _GenderButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GenderButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.xl,
          vertical: AppDimensions.md,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _MeasurementField extends StatelessWidget {
  final String label;
  final String unit;
  final TextEditingController controller;

  const _MeasurementField({
    required this.label,
    required this.unit,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        const SizedBox(height: AppDimensions.xs),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineSmall,
          decoration: InputDecoration(
            suffixText: unit,
            suffixStyle: AppTextStyles.bodyMedium,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.md,
              vertical: AppDimensions.md,
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final void Function(T?) onChanged;

  const _DropdownField({
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.lg,
        vertical: AppDimensions.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.inputBorderUnfocused),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          style: AppTextStyles.bodyLarge,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(labelBuilder(item)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _SelectChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.lg,
          vertical: AppDimensions.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
