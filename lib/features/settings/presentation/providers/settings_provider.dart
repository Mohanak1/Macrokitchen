import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  SettingsNotifier() : super(const AppSettings()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('app_language') ?? 'en';
    state = AppSettings(language: lang);
  }

  Future<void> setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', lang);
    state = state.copyWith(language: lang);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

/// Convenience: current locale
final appLocaleProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).language;
});
