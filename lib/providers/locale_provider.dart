// lib/providers/locale_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For persistence

/// Key used to store the selected locale language code in SharedPreferences.
const String _prefLocaleKey = 'app_locale';

/// Notifier responsible for managing and persisting the application's locale.
///
/// It loads the saved locale from [SharedPreferences] on initialization
/// and saves it whenever the locale is changed.
class LocaleNotifier extends StateNotifier<Locale?> {
  /// Creates a [LocaleNotifier] instance.
  ///
  /// Requires [SharedPreferences] to be provided for persistence.
  /// The initial state is `null`, and [_loadLocale] is called to populate it.
  LocaleNotifier(this._sharedPreferences) : super(null) {
    _loadLocale();
  }

  final SharedPreferences _sharedPreferences;

  /// The current locale of the application.
  ///
  /// This is a [Locale] object representing the language and optionally country code.
  /// A `null` state typically means the system locale or the first supported locale
  /// in `MaterialApp` will be used.
  // (Implicitly documented by `state` getter from StateNotifier)


  /// Loads the saved locale from SharedPreferences.
  ///
  /// If a locale is found, it updates the state. Otherwise, the state remains `null`,
  /// allowing MaterialApp to use its default resolution (system locale or first supported).
  Future<void> _loadLocale() async {
    final String? languageCode = _sharedPreferences.getString(_prefLocaleKey);
    if (languageCode != null && languageCode.isNotEmpty) {
      state = Locale(languageCode);
    } else {
      // State remains null, MaterialApp will handle default.
      state = null;
    }
  }

  /// Sets the application's locale and persists it to SharedPreferences.
  ///
  /// - [locale]: The new [Locale] to set.
  Future<void> setLocale(Locale locale) async {
    await _sharedPreferences.setString(_prefLocaleKey, locale.languageCode);
    state = locale;
  }
}

/// Provider for asynchronously obtaining the [SharedPreferences] instance.
///
/// This is used by [localeNotifierProvider] to ensure SharedPreferences is
/// available before [LocaleNotifier] is created.
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

/// Provider for the [LocaleNotifier].
///
/// This provider depends on [sharedPreferencesProvider] to get an instance
/// of [SharedPreferences]. It then creates and provides the [LocaleNotifier].
///
/// The UI should handle the loading state of `sharedPreferencesProvider` (e.g., show a
/// loading indicator) before attempting to use providers that depend on it, like this one.
final localeNotifierProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  final sharedPreferencesAsyncValue = ref.watch(sharedPreferencesProvider);

  // When SharedPreferences is loaded, create the LocaleNotifier.
  // Otherwise, this will re-evaluate when sharedPreferencesProvider resolves.
  // The UI consuming this provider or sharedPreferencesProvider should handle loading/error states.
  return sharedPreferencesAsyncValue.when(
    data: (prefs) => LocaleNotifier(prefs),
    loading: () {
      // This state should ideally be handled by the app's root, perhaps showing a splash screen
      // or basic loading UI until SharedPreferences are ready.
      // Forcing a non-nullable return or throwing here isn't ideal for provider's build phase.
      // A common pattern is to have the dependent UI show a loader if this provider is in a "loading" state.
      // However, StateNotifierProvider expects a synchronous return.
      // A robust way is to ensure SharedPreferences is loaded before this provider is even accessed,
      // typically at app startup. For this example, we assume it resolves quickly.
      // If it must be handled here, one might return a dummy or throw an error if not ready,
      // but that shifts responsibility.
      // The current setup where this provider depends on an AsyncValue
      // means widgets watching this *specific* provider will get `null` (or previous state)
      // until `sharedPreferencesAsyncValue` has data.
      // The `asData!.value` in the original code is unsafe if not guarded.
      // Awaiting it in main.dart or having App widget handle FutureProvider is better.
      // For simplicity, assuming the UI handles the loading state of sharedPreferencesProvider.
      // If it hasn't loaded, we can't create LocaleNotifier.
      // A better pattern for this provider:
      final SharedPreferences? prefs = sharedPreferencesAsyncValue.valueOrNull;
      if (prefs != null) {
        return LocaleNotifier(prefs);
      }
      // This should not be reached if the app correctly awaits sharedPreferencesProvider
      // at a higher level or if the UI handles its loading state.
      // To satisfy the non-nullable return type when `prefs` is null (during loading/error):
      // One option is to have a "dummy" notifier or throw, but that's not great.
      // The ideal is that this part of the provider graph isn't even built/watched
      // until sharedPreferencesProvider has data.
      // For now, this will cause an error if accessed while sharedPreferencesProvider is loading.
      // This highlights a dependency that must be resolved before use.
      // A common solution is a splash screen that waits for such FutureProviders.
      throw Exception("SharedPreferences not available for LocaleNotifier. Ensure sharedPreferencesProvider is loaded.");
    },
    error: (err, stack) => throw Exception("Error loading SharedPreferences for LocaleNotifier: $err"),
  );
});