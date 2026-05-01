import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    final error = await ref.read(authNotifierProvider.notifier).resetPassword(
          email: _emailCtrl.text.trim(),
        );
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    } else if (mounted) {
      setState(() => _sent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        child: _sent ? _buildSuccess() : _buildForm(isLoading),
      ),
    );
  }

  Widget _buildForm(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppDimensions.xxl),
          const Icon(Icons.lock_reset, color: AppColors.primary, size: 56),
          const SizedBox(height: AppDimensions.xl),
          const Text(
            'Forgot Your Password?',
            style: AppTextStyles.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.md),
          const Text(
            "Enter your email and we'll send you a link to reset your password.",
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.xxxl),
          AppTextField(
            hint: 'your@email.com',
            label: 'Email Address',
            controller: _emailCtrl,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email is required';
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.xxl),
          AppButton(
            label: 'Send Reset Link',
            onPressed: _send,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.mark_email_read_outlined,
            color: AppColors.success, size: 72),
        const SizedBox(height: AppDimensions.xl),
        const Text(
          'Email Sent!',
          style: AppTextStyles.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.md),
        const Text(
          'Check your inbox for a password reset link.',
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.xxxl),
        AppButton(
          label: 'Back to Login',
          onPressed: () => context.pop(),
        ),
      ],
    );
  }
}
