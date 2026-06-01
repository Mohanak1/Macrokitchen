import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// ── Settings State ─────────────────────────────────────────────────────────

class AppSettings {
  final String language; // 'en' | 'ar'

  const AppSettings({this.language = 'en'});

  AppSettings copyWith({String? language}) {
    return AppSettings(language: language ?? this.language);
  }
}

// ── Settings Notifier ──────────────────────────────────────────────────────

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings());

  static String _key(String uid) => 'app_language_$uid';

  /// Load the saved language for a specific user.
  Future<void> loadForUser(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString(_key(uid)) ?? 'en';
    state = AppSettings(language: lang);
  }

  /// Reset to English (called on logout so auth pages are always in English).
  void reset() {
    state = const AppSettings(language: 'en');
  }

  Future<void> setLanguage(String lang, {required String uid}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(uid), lang);
    state = state.copyWith(language: lang);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

/// Watches auth state and syncs language: loads per-user pref on login,
/// resets to English on logout.
final settingsSyncProvider = Provider<void>((ref) {
  final authState = ref.watch(authStateProvider);
  final notifier = ref.read(settingsProvider.notifier);
  Future.microtask(() {
    authState.when(
      data: (user) {
        if (user != null) {
          notifier.loadForUser(user.uid);
        } else {
          notifier.reset();
        }
      },
      loading: () {},
      error: (_, __) => notifier.reset(),
    );
  });
});

/// Convenience: current locale
final appLocaleProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).language;
});
