import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrokitchen/core/theme/app_theme.dart';
import 'package:macrokitchen/features/auth/domain/entities/app_user.dart';
import 'package:macrokitchen/features/auth/presentation/providers/auth_provider.dart';
import 'package:macrokitchen/features/auth/presentation/screens/login_screen.dart';
import 'package:macrokitchen/features/auth/presentation/screens/register_screen.dart';
import 'package:macrokitchen/features/bmi/presentation/screens/setup_screen.dart';

// ── Test helpers ──────────────────────────────────────────────────────────────

Widget _wrap(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: child,
    ),
  );
}

// Mock auth state: logged out
final _loggedOutOverride = authStateProvider.overrideWith(
  (ref) => Stream.value(null),
);

// Mock auth state: logged in
final _loggedInOverride = authStateProvider.overrideWith(
  (ref) => Stream.value(
    AppUser(
      uid: 'test-uid',
      name: 'Test User',
      email: 'test@example.com',
      role: 'user',
      language: 'en',
      createdAt: DateTime.now(),
    ),
  ),
);

// ── Login Screen tests ────────────────────────────────────────────────────────

void main() {
  group('LoginScreen', () {
    testWidgets('renders email and password fields', (tester) async {
      await tester.pumpWidget(_wrap(
        const LoginScreen(),
        overrides: [_loggedOutOverride],
      ));
      await tester.pump();

      expect(find.byType(TextFormField), findsAtLeast(2));
      expect(find.text('Log In to your'), findsOneWidget);
    });

    testWidgets('shows validation error when submitting empty fields',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const LoginScreen(),
        overrides: [_loggedOutOverride],
      ));
      await tester.pump();

      // Tap login button without filling fields
      await tester.tap(find.text('Log In'));
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('shows invalid email error for bad email', (tester) async {
      await tester.pumpWidget(_wrap(
        const LoginScreen(),
        overrides: [_loggedOutOverride],
      ));
      await tester.pump();

      // Enter invalid email
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'notanemail');
      await tester.tap(find.text('Log In'));
      await tester.pump();

      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('has Sign Up link', (tester) async {
      await tester.pumpWidget(_wrap(
        const LoginScreen(),
        overrides: [_loggedOutOverride],
      ));
      await tester.pump();

      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('has restaurant owner link', (tester) async {
      await tester.pumpWidget(_wrap(
        const LoginScreen(),
        overrides: [_loggedOutOverride],
      ));
      await tester.pump();

      expect(find.text('Restaurant owner?'), findsOneWidget);
    });
  });

  // ── Register Screen ─────────────────────────────────────────────────────────

  group('RegisterScreen', () {
    testWidgets('renders all required fields', (tester) async {
      await tester.pumpWidget(_wrap(
        const RegisterScreen(),
        overrides: [_loggedOutOverride],
      ));
      await tester.pump();

      // Name, Email, Password, Confirm Password
      expect(find.byType(TextFormField), findsAtLeast(4));
    });

    testWidgets('shows error when passwords do not match', (tester) async {
      await tester.pumpWidget(_wrap(
        const RegisterScreen(),
        overrides: [_loggedOutOverride],
      ));
      await tester.pump();

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(0), 'Test User');
      await tester.enterText(fields.at(1), 'test@example.com');
      await tester.enterText(fields.at(2), 'Password1');
      await tester.enterText(fields.at(3), 'Different1');

      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('shows error for weak password (no uppercase)', (tester) async {
      await tester.pumpWidget(_wrap(
        const RegisterScreen(),
        overrides: [_loggedOutOverride],
      ));
      await tester.pump();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Test User');
      await tester.enterText(fields.at(1), 'test@example.com');
      await tester.enterText(fields.at(2), 'lowercase1');
      await tester.enterText(fields.at(3), 'lowercase1');

      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      expect(find.text('Include at least one uppercase letter'), findsOneWidget);
    });
  });

  // ── Setup Screen ────────────────────────────────────────────────────────────

  group('SetupScreen', () {
    testWidgets('renders gender selector', (tester) async {
      await tester.pumpWidget(_wrap(
        const SetupScreen(),
        overrides: [_loggedInOverride],
      ));
      await tester.pump();

      expect(find.text('Gender'), findsOneWidget);
      expect(find.text('Male'), findsOneWidget);
      expect(find.text('Female'), findsOneWidget);
    });

    testWidgets('renders Conditions and Allergies sections', (tester) async {
      await tester.pumpWidget(_wrap(
        const SetupScreen(),
        overrides: [_loggedInOverride],
      ));
      await tester.pump();

      expect(find.text('Conditions'), findsOneWidget);
      expect(find.text('Allergies'), findsOneWidget);
      expect(find.text('Diabetes'), findsOneWidget);
      expect(find.text('High BP'), findsOneWidget);
    });

    testWidgets('renders Calculate button', (tester) async {
      await tester.pumpWidget(_wrap(
        const SetupScreen(),
        overrides: [_loggedInOverride],
      ));
      await tester.pump();

      expect(find.text('Calculate'), findsOneWidget);
    });

    testWidgets('shows height validation error for invalid value',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const SetupScreen(),
        overrides: [_loggedInOverride],
      ));
      await tester.pump();

      // Clear the height field and enter an invalid value
      final heightField = find.byType(TextFormField).first;
      await tester.tap(heightField);
      await tester.enterText(heightField, '20'); // below 50 cm

      await tester.tap(find.text('Calculate'));
      await tester.pump();

      expect(find.textContaining('between 50'), findsOneWidget);
    });
  });
}
