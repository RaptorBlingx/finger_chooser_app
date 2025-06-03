import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finger_chooser_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:finger_chooser_app/providers/locale_provider.dart'; // Adjust import
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Helper to pump SettingsScreen with necessary ancestors
Future<void> pumpSettingsScreen(WidgetTester tester, ProviderContainer container) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SettingsScreen(),
      ),
    ),
  );
}

void main() {
  group('SettingsScreen Widget Tests', () {
    late ProviderContainer container;
    late LocaleNotifier localeNotifier;

    setUp(() async {
      // Ensure SharedPreferences are mocked for LocaleNotifier
      SharedPreferences.setMockInitialValues({});
      localeNotifier = LocaleNotifier(); // Create a real instance
      container = ProviderContainer(
        overrides: [
          localeNotifierProvider.overrideWithValue(localeNotifier),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('Renders language selection buttons', (WidgetTester tester) async {
      await pumpSettingsScreen(tester, container);

      final localizations = await AppLocalizations.delegate.load(const Locale('en'));
      expect(find.text(localizations.languageSettingLabel), findsOneWidget);
      expect(find.text(localizations.englishLanguage), findsOneWidget);
      expect(find.text(localizations.arabicLanguage), findsOneWidget);
    });

    testWidgets('Tapping "English" button sets locale to English', (WidgetTester tester) async {
      // Ensure initial locale is not English for a change to be detected
      await localeNotifier.setLocale(const Locale('ar', ''));
      await pumpSettingsScreen(tester, container);

      final localizations = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.tap(find.text(localizations.englishLanguage));
      await tester.pumpAndSettle(); // Allow UI to rebuild

      expect(container.read(localeNotifierProvider), const Locale('en', ''));

      // Verify UI indication (e.g. button style - more complex and brittle)
      // Example: Check if the English button's background color changed as expected
      final englishButton = tester.widget<ElevatedButton>(find.text(localizations.englishLanguage));
      expect(englishButton.style?.backgroundColor?.resolve({}), equals(Theme.of(tester.element(find.text(localizations.englishLanguage))).colorScheme.primary));
    });

    testWidgets('Tapping "Arabic" button sets locale to Arabic', (WidgetTester tester) async {
      // Initial locale is English by default in LocaleNotifier
      await pumpSettingsScreen(tester, container);

      final localizations = await AppLocalizations.delegate.load(const Locale('en')); // Load any locale for keys
      await tester.tap(find.text(localizations.arabicLanguage));
      await tester.pumpAndSettle();

      expect(container.read(localeNotifierProvider), const Locale('ar', ''));

      final arabicButton = tester.widget<ElevatedButton>(find.text(localizations.arabicLanguage));
      expect(arabicButton.style?.backgroundColor?.resolve({}), equals(Theme.of(tester.element(find.text(localizations.arabicLanguage))).colorScheme.primary));
    });

    testWidgets('UI correctly indicates current language (English)', (WidgetTester tester) async {
      await localeNotifier.setLocale(const Locale('en', ''));
      await pumpSettingsScreen(tester, container);

      final localizations = await AppLocalizations.delegate.load(const Locale('en'));
      final englishButton = tester.widget<ElevatedButton>(find.text(localizations.englishLanguage));
      final arabicButton = tester.widget<ElevatedButton>(find.text(localizations.arabicLanguage));

      expect(englishButton.style?.backgroundColor?.resolve({}), equals(Theme.of(tester.element(find.text(localizations.englishLanguage))).colorScheme.primary));
      expect(arabicButton.style?.backgroundColor?.resolve({}), equals(Colors.grey));
    });

    testWidgets('UI correctly indicates current language (Arabic)', (WidgetTester tester) async {
      await localeNotifier.setLocale(const Locale('ar', ''));
      await pumpSettingsScreen(tester, container);

      final localizations = await AppLocalizations.delegate.load(const Locale('en')); // Keys are lang-agnostic
      final englishButton = tester.widget<ElevatedButton>(find.text(localizations.englishLanguage));
      final arabicButton = tester.widget<ElevatedButton>(find.text(localizations.arabicLanguage));

      expect(arabicButton.style?.backgroundColor?.resolve({}), equals(Theme.of(tester.element(find.text(localizations.arabicLanguage))).colorScheme.primary));
      expect(englishButton.style?.backgroundColor?.resolve({}), equals(Colors.grey));
    });
  });
}
