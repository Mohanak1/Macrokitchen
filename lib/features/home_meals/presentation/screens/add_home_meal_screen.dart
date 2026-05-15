import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/home_meals_provider.dart';

class AddHomeMealScreen extends ConsumerStatefulWidget {
  final String? editMealId;
  const AddHomeMealScreen({super.key, this.editMealId});

  @override
  ConsumerState<AddHomeMealScreen> createState() => _AddHomeMealScreenState();
}

class _AddHomeMealScreenState extends ConsumerState<AddHomeMealScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _kCalCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _carbsCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  final _sodiumCtrl = TextEditingController();
  final _sugarCtrl = TextEditingController();
  final _fiberCtrl = TextEditingController();
  final _saturatedFatCtrl = TextEditingController();

  bool get isEditing => widget.editMealId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) _loadExistingMeal();
  }

  void _loadExistingMeal() {
    // Find the meal in cache and pre-fill
    final meals = ref.read(homeMealsStreamProvider).value ?? [];
    final meal = meals.where((m) => m.id == widget.editMealId).firstOrNull;
    if (meal != null) {
      _titleCtrl.text = meal.title;
      _notesCtrl.text = meal.notes ?? '';
      _kCalCtrl.text = meal.calories.toString();
      _proteinCtrl.text = meal.protein.toString();
      _carbsCtrl.text = meal.carbs.toString();
      _fatCtrl.text = meal.totalFat.toString();
      _sodiumCtrl.text = meal.sodium?.toString() ?? '';
      _sugarCtrl.text = meal.sugar?.toString() ?? '';
      _fiberCtrl.text = meal.fiber?.toString() ?? '';
      _saturatedFatCtrl.text = meal.saturatedFat?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    _kCalCtrl.dispose();
    _proteinCtrl.dispose();
    _carbsCtrl.dispose();
    _fatCtrl.dispose();
    _sodiumCtrl.dispose();
    _sugarCtrl.dispose();
    _fiberCtrl.dispose();
    _saturatedFatCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final meal = HomeMeal(
      id: widget.editMealId ?? '',
      userId: user.uid,
      title: _titleCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      calories: double.parse(_kCalCtrl.text),
      protein: double.parse(_proteinCtrl.text),
      carbs: double.parse(_carbsCtrl.text),
      totalFat: double.parse(_fatCtrl.text),
      sodium: _sodiumCtrl.text.isEmpty ? null : double.tryParse(_sodiumCtrl.text),
      sugar: _sugarCtrl.text.isEmpty ? null : double.tryParse(_sugarCtrl.text),
      fiber: _fiberCtrl.text.isEmpty ? null : double.tryParse(_fiberCtrl.text),
      saturatedFat: _saturatedFatCtrl.text.isEmpty
          ? null
          : double.tryParse(_saturatedFatCtrl.text),
      loggedAt: DateTime.now(),
    );

    final notifier = ref.read(homeMealNotifierProvider.notifier);
    final error = isEditing
        ? await notifier.update(widget.editMealId!, meal)
        : await notifier.add(meal, user.uid);

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    } else if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isLoading = ref.watch(homeMealNotifierProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l.editMeal : l.homeMeal),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Required fields
              _FormField(hint: l.titleField, required: true, ctrl: _titleCtrl),
              const SizedBox(height: AppDimensions.md),
              _FormField(
                  hint: l.notes,
                  ctrl: _notesCtrl,
                  maxLines: 3,
                  keyboardType: TextInputType.multiline),
              const SizedBox(height: AppDimensions.md),
              _FormField(
                  hint: l.kCal,
                  required: true,
                  ctrl: _kCalCtrl,
                  keyboardType: TextInputType.number),
              const SizedBox(height: AppDimensions.md),
              _FormField(
                  hint: l.protein,
                  required: true,
                  ctrl: _proteinCtrl,
                  keyboardType: TextInputType.number),
              const SizedBox(height: AppDimensions.md),
              _FormField(
                  hint: l.carbs,
                  required: true,
                  ctrl: _carbsCtrl,
                  keyboardType: TextInputType.number),
              const SizedBox(height: AppDimensions.md),
              _FormField(
                  hint: l.totalFat,
                  required: true,
                  ctrl: _fatCtrl,
                  keyboardType: TextInputType.number),
              const SizedBox(height: AppDimensions.md),
              _FormField(
                  hint: l.sodium,
                  ctrl: _sodiumCtrl,
                  keyboardType: TextInputType.number),
              const SizedBox(height: AppDimensions.md),
              Row(
                children: [
                  Expanded(
                    child: _FormField(
                        hint: l.sugar,
                        ctrl: _sugarCtrl,
                        keyboardType: TextInputType.number),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: _FormField(
                        hint: l.fiber,
                        ctrl: _fiberCtrl,
                        keyboardType: TextInputType.number),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.md),
              _FormField(
                  hint: l.saturatedFat,
                  ctrl: _saturatedFatCtrl,
                  keyboardType: TextInputType.number),
              const SizedBox(height: AppDimensions.xxxl),
              AppButton(
                label: l.save,
                onPressed: _save,
                isLoading: isLoading,
              ),
              const SizedBox(height: AppDimensions.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String hint;
  final bool required;
  final TextEditingController ctrl;
  final TextInputType keyboardType;
  final int maxLines;

  const _FormField({
    required this.hint,
    required this.ctrl,
    this.required = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: required ? '$hint *' : hint,
      ),
      validator: required
          ? (v) {
              if (v == null || v.trim().isEmpty) return l.fieldRequired;
              if (keyboardType == TextInputType.number &&
                  double.tryParse(v) == null) {
                return l.enterValidNumber;
              }
              return null;
            }
          : null,
    );
  }
}