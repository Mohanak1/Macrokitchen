import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';

// ─── App Primary Button ───────────────────────────────────────────────────────

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final double? width;
  final IconData? prefixIcon;
  final Color? backgroundColor;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.width,
    this.prefixIcon,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return SizedBox(
        width: width ?? double.infinity,
        height: AppDimensions.buttonHeight,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: _buildChild(),
        ),
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: AppDimensions.buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
        ),
        child: _buildChild(),
      ),
    );
  }

  Widget _buildChild() {
    if (isLoading) {
      return const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (prefixIcon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(prefixIcon, size: AppDimensions.iconMd, color: Colors.white),
          const SizedBox(width: AppDimensions.sm),
          Text(label, style: AppTextStyles.buttonText),
        ],
      );
    }

    return Text(label, style: AppTextStyles.buttonText);
  }
}

// ─── App Text Field ───────────────────────────────────────────────────────────

class AppTextField extends StatefulWidget {
  final String hint;
  final String? label;
  final TextEditingController? controller;
  final bool isPassword;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool enabled;
  final int maxLines;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;

  const AppTextField({
    super.key,
    required this.hint,
    this.label,
    this.controller,
    this.isPassword = false,
    this.prefixIcon,
    this.suffix,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.maxLines = 1,
    this.textInputAction,
    this.focusNode,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscure : false,
      keyboardType: widget.keyboardType,
      enabled: widget.enabled,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      textInputAction: widget.textInputAction,
      focusNode: widget.focusNode,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        hintText: widget.hint,
        labelText: widget.label,
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: AppColors.primary, size: AppDimensions.iconMd)
            : null,
        suffixIcon: widget.isPassword
            ? GestureDetector(
                onTap: () => setState(() => _obscure = !_obscure),
                child: Icon(
                  _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                  size: AppDimensions.iconMd,
                ),
              )
            : widget.suffix,
      ),
    );
  }
}

// ─── Loading Overlay ──────────────────────────────────────────────────────────

class AppLoading extends StatelessWidget {
  final String? message;

  const AppLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          if (message != null) ...[
            const SizedBox(height: AppDimensions.lg),
            Text(message!, style: AppTextStyles.bodyMedium),
          ],
        ],
      ),
    );
  }
}

// ─── Error Widget ─────────────────────────────────────────────────────────────

class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 48,
            ),
            const SizedBox(height: AppDimensions.lg),
            Text(
              message,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.lg),
              AppButton(
                label: 'Retry',
                onPressed: onRetry,
                width: 120,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Empty State Widget ───────────────────────────────────────────────────────

class AppEmptyWidget extends StatelessWidget {
  final String message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyWidget({
    super.key,
    required this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              color: AppColors.textHint,
              size: 56,
            ),
            const SizedBox(height: AppDimensions.lg),
            Text(
              message,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppDimensions.xl),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                width: 160,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
