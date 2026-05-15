import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/nutrition_widgets.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../bmi/presentation/providers/bmi_provider.dart';
import '../../../history/presentation/providers/history_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final authState = ref.watch(authStateProvider);
    final bmiAsync = ref.watch(bmiProfileProvider);
    final todayTotalsAsync = ref.watch(todayTotalsProvider);

    final user = authState.value;
    final profile = bmiAsync.value;
    final dailyTarget = profile?.dailyCalorieTarget ?? 2000;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go('${AppRoutes.home}/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(bmiProfileProvider);
          ref.invalidate(todayTotalsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Greeting ─────────────────────────────────────────────────
              if (user != null) ...[
                Text(l.helloUser(user.name.split(' ').first),
                    style: AppTextStyles.headlineMedium),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  profile != null
                      ? l.bmiSummary(
                          profile.bmiValue.toStringAsFixed(1),
                          profile.goal.labelEn,
                        )
                      : l.setupHint,
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: AppDimensions.xl),
              ],

              // ── Calorie Ring ──────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(AppDimensions.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.border.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: todayTotalsAsync.when(
                  loading: () => const SizedBox(
                    height: 200,
                    child: AppLoading(),
                  ),
                  error: (_, __) => MacroRingChart(
                    consumed: 0,
                    target: dailyTarget,
                    carbs: 0,
                    protein: 0,
                    fats: 0,
                  ),
                  data: (totals) => MacroRingChart(
                    consumed: totals.calories,
                    target: dailyTarget,
                    carbs: totals.carbs,
                    protein: totals.protein,
                    fats: totals.fats,
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.xl),

              // ── Quick Links ───────────────────────────────────────────────
              _QuickLink(
                icon: Icons.directions_walk,
                label: l.weeklyProgress,
                onTap: () => context.go('${AppRoutes.home}/weekly-progress'),
              ),
              const SizedBox(height: AppDimensions.md),
              _QuickLink(
                icon: Icons.restaurant_menu,
                label: l.mealHistory,
                onTap: () => context.go('${AppRoutes.home}/meal-history'),
              ),
              const SizedBox(height: AppDimensions.md),
              _QuickLink(
                icon: Icons.monitor_weight_outlined,
                label: l.bmiProfile,
                onTap: () => context.go('${AppRoutes.home}/bmi-page'),
              ),
              const SizedBox(height: AppDimensions.md),
              _QuickLink(
                icon: Icons.summarize_outlined,
                label: l.nutritionReport,
                onTap: () => context.go('${AppRoutes.home}/report'),
              ),

              const SizedBox(height: AppDimensions.xl),

              // ── Setup CTA (if no profile) ─────────────────────────────────
              if (profile == null)
                AppButton(
                  label: l.setupBmiNow,
                  onPressed: () => context.go(AppRoutes.setup),
                  prefixIcon: Icons.assignment_outlined,
                ),

              const SizedBox(height: AppDimensions.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.lg,
          vertical: AppDimensions.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: AppDimensions.lg),
            Expanded(
              child: Text(label, style: AppTextStyles.headlineSmall),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}