import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/image_upload_service.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../meals/domain/entities/meal.dart';
import '../../../meals/presentation/providers/meals_provider.dart';
import '../providers/restaurant_provider.dart';

class AddMealScreen extends ConsumerStatefulWidget {
  final String? editMealId;
  const AddMealScreen({super.key, this.editMealId});

  @override
  ConsumerState<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends ConsumerState<AddMealScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _kCalCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _carbsCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  final _sodiumCtrl = TextEditingController();
  final _sugarCtrl = TextEditingController();
  final _fiberCtrl = TextEditingController();
  final _saturatedFatCtrl = TextEditingController();

  // Allergen chips
  static const _allergenOptions = [
    'Milk',
    'Peanuts',
    'Shellfish',
    'Fish',
    'Eggs',
    'Tree Nut',
    'Soy',
    'Wheat',
    'Sesame'
  ];
  final Set<String> _selectedAllergens = {};

  File? _pickedImage;
  String? _uploadedImageUrl;
  bool _uploadingImage = false;

  bool get isEditing => widget.editMealId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) _prefillMeal();
  }

  Future<void> _pickAndUploadImage() async {
    final service = ref.read(imageUploadServiceProvider);
    final file = await service.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    setState(() {
      _pickedImage = file;
      _uploadingImage = true;
    });

    final result = await service.uploadMealImage(file);
    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image upload failed: ${failure.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      (url) => _uploadedImageUrl = url,
    );

    if (mounted) setState(() => _uploadingImage = false);
  }

  void _prefillMeal() {
    final meals = ref.read(restaurantOwnMealsProvider).value ?? [];
    final meal = meals.where((m) => m.id == widget.editMealId).firstOrNull;
    if (meal != null) {
      _titleCtrl.text = meal.title;
      _kCalCtrl.text = meal.calories.toString();
      _proteinCtrl.text = meal.protein.toString();
      _carbsCtrl.text = meal.carbs.toString();
      _fatCtrl.text = (meal.totalFat ?? 0).toString();
      _sodiumCtrl.text = (meal.sodium ?? 0).toString();
      _sugarCtrl.text = (meal.sugar ?? 0).toString();
      _fiberCtrl.text = (meal.fiber ?? 0).toString();
      _saturatedFatCtrl.text = (meal.saturatedFat ?? 0).toString();
      _selectedAllergens.addAll(meal.allergens);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
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

    final restaurantAsync = ref.read(currentRestaurantProvider);
    final restaurant = restaurantAsync.value;
    if (restaurant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Restaurant profile not found.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final meal = Meal(
      id: widget.editMealId ?? '',
      restaurantId: restaurant.id,
      restaurantName: restaurant.name,
      title: _titleCtrl.text.trim(),
      imageUrl: _uploadedImageUrl,
      type: 'restaurant',
      calories: double.parse(_kCalCtrl.text),
      protein: double.parse(_proteinCtrl.text),
      carbs: double.parse(_carbsCtrl.text),
      totalFat: _fatCtrl.text.isEmpty ? null : double.tryParse(_fatCtrl.text),
      sodium:
          _sodiumCtrl.text.isEmpty ? null : double.tryParse(_sodiumCtrl.text),
      sugar: _sugarCtrl.text.isEmpty ? null : double.tryParse(_sugarCtrl.text),
      fiber: _fiberCtrl.text.isEmpty ? null : double.tryParse(_fiberCtrl.text),
      saturatedFat: _saturatedFatCtrl.text.isEmpty
          ? null
          : double.tryParse(_saturatedFatCtrl.text),
      allergens: _selectedAllergens.map((a) => a.toLowerCase()).toList(),
      createdAt: DateTime.now(),
    );

    final notifier = ref.read(mealActionProvider.notifier);
    final String? error;

    if (isEditing) {
      error = await notifier.updateMeal(widget.editMealId!, meal);
    } else {
      error = await notifier.addMeal(meal, restaurant.id, restaurant.name);
    }

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    } else if (mounted) {
      ref.invalidate(restaurantOwnMealsProvider);
      ref.invalidate(allMealsProvider);
      context.go(AppRoutes.restaurantDashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(mealActionProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Meal' : 'Restaurant Meal'),
        leading: BackButton(
            onPressed: () => context.go(AppRoutes.restaurantDashboard)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image Picker ────────────────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: _uploadingImage ? null : _pickAndUploadImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMd),
                      border: Border.all(color: AppColors.inputBorderUnfocused),
                    ),
                    child: _uploadingImage
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primary))
                        : _pickedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusMd),
                                child: Image.file(_pickedImage!,
                                    fit: BoxFit.cover),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined,
                                      color: AppColors.primary, size: 32),
                                  SizedBox(height: 4),
                                  Text('Add Image',
                                      style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 12)),
                                ],
                              ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.xl),

              // Required fields matching Figma mockup
              _Field(
                  label: 'Restaurant',
                  ctrl: null,
                  readOnly: true,
                  hint: ref.watch(currentRestaurantProvider).value?.name ?? ''),
              const SizedBox(height: AppDimensions.md),
              _Field(label: 'Title', ctrl: _titleCtrl, required: true),
              const SizedBox(height: AppDimensions.md),
              _Field(
                  label: 'kCal',
                  ctrl: _kCalCtrl,
                  required: true,
                  numeric: true),
              const SizedBox(height: AppDimensions.md),
              _Field(
                  label: 'Protein',
                  ctrl: _proteinCtrl,
                  required: true,
                  numeric: true),
              const SizedBox(height: AppDimensions.md),
              _Field(
                  label: 'Carbs',
                  ctrl: _carbsCtrl,
                  required: true,
                  numeric: true),
              const SizedBox(height: AppDimensions.md),
              _Field(
                  label: 'Total Fat',
                  ctrl: _fatCtrl,
                  required: true,
                  numeric: true),
              const SizedBox(height: AppDimensions.md),
              _Field(label: 'Sodium', ctrl: _sodiumCtrl, numeric: true),
              const SizedBox(height: AppDimensions.md),
              Row(
                children: [
                  Expanded(
                    child:
                        _Field(label: 'Sugar', ctrl: _sugarCtrl, numeric: true),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child:
                        _Field(label: 'Fiber', ctrl: _fiberCtrl, numeric: true),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.md),
              _Field(
                  label: 'Saturated Fat',
                  ctrl: _saturatedFatCtrl,
                  required: true,
                  numeric: true),

              const SizedBox(height: AppDimensions.xl),

              // Allergens
              const Text('Allergens', style: AppTextStyles.headlineSmall),
              const SizedBox(height: AppDimensions.sm),
              Wrap(
                spacing: AppDimensions.sm,
                runSpacing: AppDimensions.sm,
                children: _allergenOptions.map((a) {
                  final sel = _selectedAllergens.contains(a);
                  return FilterChip(
                    label: Text(a),
                    selected: sel,
                    onSelected: (_) => setState(() {
                      sel
                          ? _selectedAllergens.remove(a)
                          : _selectedAllergens.add(a);
                    }),
                    selectedColor: AppColors.allergyWarningLight,
                    checkmarkColor: AppColors.allergyWarning,
                    labelStyle: AppTextStyles.labelMedium.copyWith(
                      color: sel
                          ? AppColors.allergyWarning
                          : AppColors.textSecondary,
                    ),
                    side: BorderSide(
                        color:
                            sel ? AppColors.allergyWarning : AppColors.border),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppDimensions.xxxl),

              AppButton(
                label: 'Save',
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

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController? ctrl;
  final bool required;
  final bool numeric;
  final bool readOnly;
  final String? hint;

  const _Field({
    required this.label,
    required this.ctrl,
    this.required = false,
    this.numeric = false,
    this.readOnly = false,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      readOnly: readOnly,
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
      ),
      validator: required
          ? (v) {
              if (v == null || v.trim().isEmpty) return '$label is required';
              if (numeric && double.tryParse(v) == null) {
                return 'Enter a valid number';
              }
              return null;
            }
          : null,
    );
  }
}
