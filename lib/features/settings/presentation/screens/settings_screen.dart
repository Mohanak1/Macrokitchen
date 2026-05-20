import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../providers/settings_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final isArabic = settings.language == 'ar';

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        children: [
          // ── Language ──────────────────────────────────────────────────
          // Kept bilingual on purpose so users can find it in either language.
          _SettingsSection(
            title: 'Language / اللغة',
            child: Row(
              children: [
                _LangButton(
                  label: 'English',
                  selected: !isArabic,
                  onTap: () =>
                      ref.read(settingsProvider.notifier).setLanguage('en'),
                ),
                const SizedBox(width: AppDimensions.md),
                _LangButton(
                  label: 'العربية',
                  selected: isArabic,
                  onTap: () =>
                      ref.read(settingsProvider.notifier).setLanguage('ar'),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.xl),

          // ── Account ───────────────────────────────────────────────────
          _SettingsSection(
            title: l.account,
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.person_outline,
                  label: l.editBmiProfile,
                  onTap: () => context.go(AppRoutes.setup),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.monitor_weight_outlined,
                  label: l.viewBmiData,
                  onTap: () => context.go('${AppRoutes.home}/bmi-page'),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.history,
                  label: l.mealHistory,
                  onTap: () => context.go('${AppRoutes.home}/meal-history'),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.summarize_outlined,
                  label: l.nutritionReport,
                  onTap: () => context.go('${AppRoutes.home}/report'),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.xl),

          // ── About ─────────────────────────────────────────────────────
          _SettingsSection(
            title: l.about,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('MacroKitchen v1.0.0',
                          style: AppTextStyles.labelLarge),
                      const SizedBox(height: 4),
                      Text(
                        l.appDescription,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.xl),

          // ── Logout ────────────────────────────────────────────────────
          _SettingsTile(
            icon: Icons.logout,
            label: l.logout,
            iconColor: AppColors.error,
            labelColor: AppColors.error,
            onTap: () async {
              await ref.read(authNotifierProvider.notifier).logout();
            },
          ),

          const SizedBox(height: AppDimensions.xxl),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _SettingsSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.primary),
      title: Text(
        label,
        style: AppTextStyles.bodyLarge.copyWith(color: labelColor),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: onTap,
    );
  }
}

class _LangButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangButton({
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