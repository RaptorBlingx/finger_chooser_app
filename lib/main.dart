// lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Initialize AdMob
    await MobileAds.instance.initialize();

    // Wrap the app with ProviderScope for Riverpod state management
    runApp(
      const ProviderScope(
        child: FingerChooserApp(),
      ),
    );
  }, (error, stack) {
    // Catch all asynchronous errors not caught by Flutter framework
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
  });
}
