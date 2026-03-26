// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/locale_provider.dart';
import 'features/home/presentation/screens/home_screen_premium.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'core/theme/app_theme.dart'; 

final _onboardingCompleteProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('onboarding_complete') ?? false;
});

class FingerChooserApp extends ConsumerWidget {
  const FingerChooserApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeNotifierProvider);
    final sharedPreferencesAsyncValue = ref.watch(sharedPreferencesProvider);

    if (sharedPreferencesAsyncValue is AsyncLoading) {
        return const MaterialApp( 
          home: Scaffold(body: Center(child: CircularProgressIndicator())),
        );
    }
    if (sharedPreferencesAsyncValue is AsyncError) {
        return MaterialApp( 
          home: Scaffold(body: Center(child: Text('Error loading preferences: ${sharedPreferencesAsyncValue.error}'))),
        );
    }

    final onboardingDone = ref.watch(_onboardingCompleteProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (context) => AppLocalizations.of(context)?.appTitle ?? 'Finger Chooser',
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: onboardingDone.when(
        data: (done) => done
            ? const HomeScreenPremium()
            : OnboardingScreen(
                onComplete: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('onboarding_complete', true);
                  ref.invalidate(_onboardingCompleteProvider);
                },
              ),
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => const HomeScreenPremium(),
      ),
    );
  }
}
