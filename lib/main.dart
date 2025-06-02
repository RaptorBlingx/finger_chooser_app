// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'firebase_options.dart'; 
// *** THIS IMPORT IS CRUCIAL ***
import 'app.dart'; // Import the FingerChooserApp widget from app.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, 
  );

  // Wrap your app with ProviderScope
  runApp(
    const ProviderScope( // Add this
      child: FingerChooserApp(),
    ),
  ); 
}
