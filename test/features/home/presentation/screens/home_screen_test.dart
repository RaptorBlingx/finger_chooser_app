import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:finger_chooser_app/features/home/presentation/screens/home_screen.dart';
import 'package:finger_chooser_app/features/finger_chooser/presentation/screens/chooser_screen.dart';
import 'package:finger_chooser_app/features/custom_play/presentation/screens/custom_play_wizard_screen.dart';
import 'package:finger_chooser_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:finger_chooser_app/features/store/presentation/screens/store_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Mock Navigator for testing navigation
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

// Helper to pump the widget with all necessary ancestors
Future<void> pumpHomeScreen(WidgetTester tester, {NavigatorObserver? navigatorObserver}) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomeScreen(),
        navigatorObservers: navigatorObserver != null ? [navigatorObserver] : [],
      ),
    ),
  );
}

// Custom RouteMatcher
class RoutePredicate extends ArgumentMatcher {
  final Type screenType;
  RoutePredicate(this.screenType);

  @override
  bool matches(dynamic item, Map matchState) {
    return item is MaterialPageRoute && item.builder(MockBuildContext())?.runtimeType == screenType;
  }

  @override
  Description describe(Description description) {
    return description.add('is a MaterialPageRoute to $screenType');
  }
}
class MockBuildContext extends Mock implements BuildContext {}


void main() {
  group('HomeScreen Widget Tests', () {
    late NavigatorObserver mockNavigatorObserver;

    setUp(() {
      mockNavigatorObserver = MockNavigatorObserver();
    });

    testWidgets('Renders all main navigation buttons and settings icon', (WidgetTester tester) async {
      await pumpHomeScreen(tester);

      // Verify titles/texts on buttons
      // Note: Some texts like "Party Play (with Dares)" are hardcoded in HomeScreen.
      // For fully robust tests, these should also use localization keys.
      expect(find.textContaining('Party Play', findRichText: true), findsOneWidget);
      expect(find.textContaining('Quick Pick', findRichText: true), findsOneWidget);
      expect(find.textContaining('Custom Play', findRichText: true), findsOneWidget);

      // Need to access localizations for Dare Packs button
      final localizations = await AppLocalizations.delegate.load(const Locale('en'));
      expect(find.text(localizations.darePacksButtonLabel), findsOneWidget);

      // Verify settings icon
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byType(FlutterLogo), findsOneWidget); // Check for logo
    });

    testWidgets('Tapping "Party Play" button navigates to ChooserScreen (Party Mode)', (WidgetTester tester) async {
      await pumpHomeScreen(tester, navigatorObserver: mockNavigatorObserver);
      await tester.tap(find.textContaining('Party Play'));
      await tester.pumpAndSettle(); // Wait for navigation animation

      verify(mockNavigatorObserver.didPush(RoutePredicate(ChooserScreen), any));
      // Additionally, check if isQuickPlayMode is false (more complex, might need to inspect route arguments)
    });

    testWidgets('Tapping "Quick Pick" button navigates to ChooserScreen (Quick Pick Mode)', (WidgetTester tester) async {
      await pumpHomeScreen(tester, navigatorObserver: mockNavigatorObserver);
      await tester.tap(find.textContaining('Quick Pick'));
      await tester.pumpAndSettle();

      verify(mockNavigatorObserver.didPush(RoutePredicate(ChooserScreen), any));
      // Additionally, check if isQuickPlayMode is true
    });

    testWidgets('Tapping "Custom Play" button navigates to CustomPlayWizardScreen', (WidgetTester tester) async {
      await pumpHomeScreen(tester, navigatorObserver: mockNavigatorObserver);
      await tester.tap(find.textContaining('Custom Play'));
      await tester.pumpAndSettle();

      verify(mockNavigatorObserver.didPush(RoutePredicate(CustomPlayWizardScreen), any));
    });

    testWidgets('Tapping "Dare Packs" button navigates to StoreScreen', (WidgetTester tester) async {
      await pumpHomeScreen(tester, navigatorObserver: mockNavigatorObserver);
      final localizations = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.tap(find.text(localizations.darePacksButtonLabel));
      await tester.pumpAndSettle();

      verify(mockNavigatorObserver.didPush(RoutePredicate(StoreScreen), any));
    });

    testWidgets('Tapping Settings icon navigates to SettingsScreen', (WidgetTester tester) async {
      await pumpHomeScreen(tester, navigatorObserver: mockNavigatorObserver);
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      verify(mockNavigatorObserver.didPush(RoutePredicate(SettingsScreen), any));
    });
  });
}
