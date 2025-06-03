// lib/features/home/presentation/screens/home_screen.dart

/// The main landing screen of the application.
///
/// Displays options for different game modes (Party Play, Quick Pick),
/// navigation to Custom Play wizard, Dare Store, and Settings.
/// Also includes basic app branding.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // For localized text
import 'package:audioplayers/audioplayers.dart'; // Added audioplayers
import 'package:firebase_analytics/firebase_analytics.dart'; // Added Firebase Analytics
// Note: Duplicate FlutterLogo import was removed by hand as the tool might not catch it.
// If it was `import 'package:flutter/material.dart' as fm;` then it would be fine.
import '../../../finger_chooser/presentation/screens/chooser_screen.dart';
import 'package:finger_chooser_app/features/custom_play/presentation/screens/custom_play_wizard_screen.dart'; // Corrected package name
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../store/presentation/screens/store_screen.dart';

class HomeScreen extends StatefulWidget { // Changed to StatefulWidget
  const HomeScreen({super.key});

  static const String routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> { // State class
  final AudioPlayer _buttonClickPlayer = AudioPlayer();

  @override
  void dispose() {
    _buttonClickPlayer.dispose();
    super.dispose();
  }

  void _playButtonClickSound() {
    _buttonClickPlayer.play(AssetSource('sounds/button_click.mp3'));
  }

  void _handleNavigation(BuildContext context, Widget screen, {String? eventName, Map<String, Object?>? parameters}) {
    HapticFeedback.selectionClick();
    _playButtonClickSound();

    if (eventName != null) {
      FirebaseAnalytics.instance.logEvent(name: eventName, parameters: parameters);
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: localizations.settings,
            onPressed: () => _handleNavigation(context, const SettingsScreen()),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const FlutterLogo(size: 80.0), // Added FlutterLogo
              const SizedBox(height: 30), // Added spacing after logo
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: () => _handleNavigation(
                  context,
                  const ChooserScreen(isQuickPlayMode: false),
                  eventName: 'party_play_started',
                  parameters: {'mode': 'party_dares'},
                ),
                child: const Text("🎉 Party Play (with Dares)"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: () => _handleNavigation(
                  context,
                  const ChooserScreen(isQuickPlayMode: true),
                  eventName: 'quick_pick_started',
                  parameters: {'mode': 'quick_pick_fingers_only'},
                ),
                child: const Text("👆 Quick Pick (Fingers Only)"),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: () => _handleNavigation(
                  context,
                  const CustomPlayWizardScreen(),
                  eventName: 'custom_play_wizard_opened',
                ),
                child: const Text("🛠️ Custom Play (Wizard)"),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.storefront_outlined),
                label: Text(localizations.darePacksButtonLabel),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: () => _handleNavigation(
                  context,
                  const StoreScreen(),
                  eventName: 'store_opened', // Example event for store
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}