import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/bmi/presentation/screens/setup_screen.dart';
import '../../features/bmi/presentation/screens/bmi_page_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/weekly_progress_screen.dart';
import '../../features/meals/presentation/screens/restaurant_menus_screen.dart';
import '../../features/meals/presentation/screens/meal_detail_screen.dart';
import '../../features/home_meals/presentation/screens/home_meal_page_screen.dart';
import '../../features/home_meals/presentation/screens/add_home_meal_screen.dart';
import '../../features/history/presentation/screens/meal_history_screen.dart';
import '../../features/restaurant_dashboard/presentation/screens/restaurant_login_screen.dart';
import '../../features/restaurant_dashboard/presentation/screens/restaurant_dashboard_screen.dart';
import '../../features/restaurant_dashboard/presentation/screens/add_meal_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/report/report_screen.dart';
import '../widgets/main_shell.dart';

// Route paths
class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const restaurantLogin = '/restaurant-login';

  static const setup = '/setup';

  // Shell routes (bottom nav)
  static const home = '/home';
  static const meals = '/meals';
  static const homeMeals = '/home-meals';

  // Sub-routes
  static const bmiPage = '/bmi-page';
  static const weeklyProgress = '/weekly-progress';
  static const mealHistory = '/meal-history';
  static const mealDetail = '/meal/:mealId';
  static const addHomeMeal = '/add-home-meal';
  static const settings = '/settings';

  // Restaurant dashboard
  static const restaurantDashboard = '/restaurant/dashboard';
  static const restaurantAddMeal = '/restaurant/add-meal';
  static const report = '/report';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final user = authState.value;
      final isLoggedIn = user != null;
      final isRestaurant = user?.isRestaurant ?? false;
      final isSplash = state.matchedLocation == AppRoutes.splash;
      final isAuthRoute =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.forgotPassword ||
          state.matchedLocation == AppRoutes.restaurantLogin;

      // Let splash handle its own navigation
      if (isSplash) return null;

      // Restaurant dashboard pages — auth checked inside screen
      if (state.matchedLocation.startsWith('/restaurant') &&
          state.matchedLocation != AppRoutes.restaurantLogin) {
        if (!isLoggedIn) return AppRoutes.restaurantLogin;
        if (!isRestaurant) return AppRoutes.home;
        return null;
      }

      if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;

      if (isLoggedIn && isAuthRoute) {
        return isRestaurant ? AppRoutes.restaurantDashboard : AppRoutes.home;
      }

      // Prevent restaurant accounts from accessing regular user pages
      if (isLoggedIn && isRestaurant) return AppRoutes.restaurantDashboard;

      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.restaurantLogin,
        builder: (context, state) => const RestaurantLoginScreen(),
      ),

      // BMI Setup (no shell)
      GoRoute(
        path: AppRoutes.setup,
        builder: (context, state) => const SetupScreen(),
      ),

      // Restaurant Dashboard (no shell)
      GoRoute(
        path: AppRoutes.restaurantDashboard,
        builder: (context, state) => const RestaurantDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.restaurantAddMeal,
        builder: (context, state) {
          final mealId = state.uri.queryParameters['mealId'];
          return AddMealScreen(editMealId: mealId);
        },
      ),

      // Main Shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
            routes: [
              GoRoute(
                path: 'bmi-page',
                builder: (context, state) => const BmiPageScreen(),
              ),
              GoRoute(
                path: 'weekly-progress',
                builder: (context, state) => const WeeklyProgressScreen(),
              ),
              GoRoute(
                path: 'meal-history',
                builder: (context, state) => const MealHistoryScreen(),
              ),
              GoRoute(
                path: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
              GoRoute(
                path: 'report',
                builder: (context, state) => const ReportScreen(),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.meals,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: RestaurantMenusScreen()),
            routes: [
              GoRoute(
                path: ':mealId',
                builder: (context, state) {
                  final mealId = state.pathParameters['mealId']!;
                  return MealDetailScreen(mealId: mealId);
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.homeMeals,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeMealPageScreen()),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) {
                  final mealId = state.uri.queryParameters['mealId'];
                  return AddHomeMealScreen(editMealId: mealId);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
