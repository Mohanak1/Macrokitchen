import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class RestaurantLoginScreen extends ConsumerStatefulWidget {
  const RestaurantLoginScreen({super.key});

  @override
  ConsumerState<RestaurantLoginScreen> createState() =>
      _RestaurantLoginScreenState();
}

class _RestaurantLoginScreenState extends ConsumerState<RestaurantLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final error = await ref.read(authNotifierProvider.notifier).loginRestaurant(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    } else if (mounted) {
      context.go(AppRoutes.restaurantDashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.pagePaddingH,
            vertical: AppDimensions.pagePaddingV,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppDimensions.huge),

                // Brand
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.store_outlined,
                            color: AppColors.primary, size: 40),
                      ),
                      const SizedBox(height: AppDimensions.lg),
                      Text('MacroKitchen',
                          style: AppTextStyles.displayMedium
                              .copyWith(color: AppColors.primary)),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.xxxl),

                const Text(
                  'Log In to your\nRestaurant Account',
                  style: AppTextStyles.headlineLarge,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppDimensions.xxxl),

                AppTextField(
                  hint: 'Mcdonald@gmail.com',
                  label: 'Email',
                  controller: _emailCtrl,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email is required';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppDimensions.lg),

                AppTextField(
                  hint: '••••••••••',
                  label: 'Password',
                  controller: _passwordCtrl,
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _login(),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    return null;
                  },
                ),

                const SizedBox(height: AppDimensions.md),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('Contact Us'),
                    ),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.forgotPassword),
                      child: const Text('Forgot Your Password ?'),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.lg),

                AppButton(
                  label: 'Log In',
                  onPressed: _login,
                  isLoading: isLoading,
                ),

                const SizedBox(height: AppDimensions.xl),

                Center(
                  child: GestureDetector(
                    onTap: () => context.go(AppRoutes.login),
                    child: Text(
                      'Back to User Login',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
