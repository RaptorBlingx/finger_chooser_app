// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'features/finger_chooser/presentation/screens/chooser_screen.dart'; 
import 'providers/locale_provider.dart'; // Import your locale provider

import 'features/dare_display/presentation/screens/dare_display_screen.dart';
import 'models/finger_model.dart'; 

import 'features/home/presentation/screens/home_screen.dart'; 


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

    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      locale: locale, 
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (context) => AppLocalizations.of(context)?.appTitle ?? 'Finger Chooser', 
      theme: ThemeData(
        primarySwatch: Colors.blue, 
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto', // Consider if you'll use a custom font for Arabic later
        // You can define button themes here too
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            // backgroundColor: Colors.blueAccent, // Example global button color
            // foregroundColor: Colors.white,
          ),
        ),
      ),
      // Set HomeScreen as the initial route
      home: const HomeScreen(), 
      // We can set up named routes later if needed
      // routes: {
      //   HomeScreen.routeName: (ctx) => const HomeScreen(),
      //   ChooserScreen.routeName: (ctx) => const ChooserScreen(), // You'd need to define routeName in ChooserScreen
      //   DareDisplayScreen.routeName: (ctx) => const DareDisplayScreen(), // Needs args handling if used directly
      // },
      // onGenerateRoute for passing arguments with named routes can also be set up here
    );
  }
}
