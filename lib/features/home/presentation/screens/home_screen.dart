// lib/features/home/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // For localized text
import '../../../finger_chooser/presentation/screens/chooser_screen.dart'; // To navigate to ChooserScreen
// Import other screens as they are created (e.g., SettingsScreen, StoreScreen)

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const String routeName = '/home'; // Optional: for named routing later

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appTitle), // Or a more specific "Home" title
        // Potentially add actions like settings icon later
        // actions: [ 
        //   IconButton(
        //     icon: const Icon(Icons.settings),
        //     onPressed: () {
        //       // Navigate to SettingsScreen
        //     },
        //   ),
        // ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch, // Make buttons stretch
            children: <Widget>[
              // TODO: Add App Logo/Branding here if desired

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  // Navigate to ChooserScreen for "Party Play" (with dares)
                  // We will pass a parameter to distinguish modes later
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ChooserScreen(
                         isQuickPlayMode: false, // Add this parameter to ChooserScreen later
                      ),
                    ),
                  );
                },
                // For now, let's call the default mode "Party Play"
                child: const Text("🎉 Party Play (with Dares)"), 
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                  // backgroundColor: Colors.lightBlueAccent, // Example different color
                ),
                onPressed: () {
                  // Navigate to ChooserScreen for "Quick Pick" (no dares)
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ChooserScreen(
                         isQuickPlayMode: true, // Add this parameter to ChooserScreen later
                      ),
                    ),
                  );
                },
                child: const Text("👆 Quick Pick (Fingers Only)"),
              ),
              const SizedBox(height: 20),
              OutlinedButton( // Example for a less prominent button
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  // Placeholder for Custom Play Wizard
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Custom Play Wizard - Coming Soon!")),
                  );
                },
                child: const Text("🛠️ Custom Play (Wizard)"),
              ),
              // TODO: Add buttons for "Store/Packs" and "Settings" later
              // const SizedBox(height: 20),
              // TextButton(
              //   onPressed: () { /* Navigate to Store */ },
              //   child: const Text("🛍️ Store / Dare Packs"),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}