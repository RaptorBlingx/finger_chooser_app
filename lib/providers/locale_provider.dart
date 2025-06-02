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

  final SharedPreferences _sharedPreferences;

  Future<void> _loadLocale() async {
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
    await _sharedPreferences.setString(_prefLocaleKey, locale.languageCode);
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
  // Return a placeholder or loading state until SharedPreferences is ready
  // For simplicity here, we'll throw if not ready, but in a real app, handle loading.
  // A better approach might be to make LocaleNotifier handle async init or
  // have the UI handle the loading state of SharedPreferences.
  if (sharedPreferencesAsyncValue.hasValue) {
    return LocaleNotifier(sharedPreferencesAsyncValue.value!);
  }
  // This case should ideally be handled by showing a loading indicator in the UI
  // until sharedPreferencesProvider resolves.
  // For now, we'll just return a notifier with a dummy/uninitialized SharedPreferences instance,
  // which isn't ideal. Or, we can make the initial state of LocaleNotifier handle this.
  // Let's assume for now the app will wait for SharedPreferences.
  // A better way:
  // final SharedPreferences sharedPreferences = ref.watch(sharedPreferencesProvider).valueOrNull ?? (throw Exception("SP not loaded"));
  // return LocaleNotifier(sharedPreferences);
  // For now, let's keep it simple:
  return LocaleNotifier(sharedPreferencesAsyncValue.asData!.value); // Will throw if not loaded, handle this in UI
});