// lib/providers/locale_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For persistence

const String _prefLocaleKey = 'app_locale';

// State Notifier for locale
class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier(this._sharedPreferences) : super(null) {
    _loadLocale();
  }

  /// Fallback constructor when SharedPreferences isn't loaded yet.
  LocaleNotifier._uninitialized() : _sharedPreferences = null, super(null);

  final SharedPreferences? _sharedPreferences;

  Future<void> _loadLocale() async {
    if (_sharedPreferences == null) return;
    final String? languageCode = _sharedPreferences.getString(_prefLocaleKey);
    if (languageCode != null && languageCode.isNotEmpty) {
      state = Locale(languageCode);
    } else {
      // Default to English or device locale if nothing saved
      // For now, let's default to null, MaterialApp will pick system or first supported.
      state = null; 
    }
  }

  Future<void> setLocale(Locale locale) async {
    await _sharedPreferences?.setString(_prefLocaleKey, locale.languageCode);
    state = locale;
  }
}

// Provider for SharedPreferences (async)
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

// Provider for LocaleNotifier
// We use a FutureProvider that depends on SharedPreferences being ready
final localeNotifierProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  final sharedPreferencesAsyncValue = ref.watch(sharedPreferencesProvider);
  if (sharedPreferencesAsyncValue.hasValue) {
    return LocaleNotifier(sharedPreferencesAsyncValue.value!);
  }
  // SharedPreferences not yet loaded — return a notifier that defaults to null locale
  // (MaterialApp will use system locale). Once SP loads, the provider will rebuild.
  return LocaleNotifier._uninitialized();
});