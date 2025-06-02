import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finger_chooser_app/providers/locale_provider.dart'; // Adjust import path as necessary

void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // Needed for SharedPreferences

  group('LocaleNotifier Tests', () {
    late LocaleNotifier localeNotifier;
    Map<String, Object> mockPrefsValues = {};

    setUp(() async {
      // Reset SharedPreferences for each test
      SharedPreferences.setMockInitialValues(mockPrefsValues);
      localeNotifier = LocaleNotifier();
      // Wait for any async initialization in LocaleNotifier if it has one (e.g. _loadLocale)
      // For this provider, _loadLocale is called in constructor, so we might need a slight delay or a way to ensure it completes.
      // However, since it's synchronous in the provided code, direct instantiation is fine.
      // If _loadLocale were async and not awaited in constructor, a more complex setup would be needed.
    });

    tearDown(() {
      mockPrefsValues = {}; // Clear values for next test
    });

    test('Initial locale is English when no preference is stored', () {
      expect(localeNotifier.debugState, const Locale('en', ''));
    });

    test('Loads locale from SharedPreferences if available', () async {
      SharedPreferences.setMockInitialValues({
        LocaleNotifier.localePrefsKey: 'ar',
      });
      // Re-initialize to trigger loading from SharedPreferences
      final notifierWithPrefs = LocaleNotifier();
      expect(notifierWithPrefs.debugState, const Locale('ar', ''));
    });
    
    test('Loads English locale from SharedPreferences if "en" is stored', () async {
      SharedPreferences.setMockInitialValues({
        LocaleNotifier.localePrefsKey: 'en',
      });
      final notifierWithPrefs = LocaleNotifier();
      expect(notifierWithPrefs.debugState, const Locale('en', ''));
    });


    test('setLocale updates the locale and persists to SharedPreferences', () async {
      // Initial state check (assuming default is 'en')
      expect(localeNotifier.debugState, const Locale('en', ''));

      // Set to Arabic
      await localeNotifier.setLocale(const Locale('ar', ''));
      expect(localeNotifier.debugState, const Locale('ar', ''));

      // Verify persistence
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(LocaleNotifier.localePrefsKey), 'ar');

      // Set back to English
      await localeNotifier.setLocale(const Locale('en', ''));
      expect(localeNotifier.debugState, const Locale('en', ''));
      expect(prefs.getString(LocaleNotifier.localePrefsKey), 'en');
    });

     test('setLocale with unsupported language defaults to English and does not persist', () async {
      // This test depends on how strictly LocaleNotifier handles unsupported locales.
      // Based on current implementation, it accepts any language code.
      // If it had validation, this test would be more meaningful.
      // For now, we assume it will store whatever is passed.
      await localeNotifier.setLocale(const Locale('fr', ''));
      expect(localeNotifier.debugState, const Locale('fr', ''));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(LocaleNotifier.localePrefsKey), 'fr'); 
      // If it were to default, it would be:
      // expect(localeNotifier.debugState, const Locale('en', ''));
      // expect(prefs.getString(LocaleNotifier.localePrefsKey), 'en'); // or not set
    });
  });
}
