import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:audioplayers/audioplayers.dart'; // Added audioplayers
import '../../../../providers/locale_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget { // Changed to ConsumerStatefulWidget
  const SettingsScreen({super.key});

  static const String routeName = '/settings';

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> { // State class
  final AudioPlayer _buttonClickPlayer = AudioPlayer();

  @override
  void dispose() {
    _buttonClickPlayer.dispose();
    super.dispose();
  }

  void _playButtonClickSound() {
    _buttonClickPlayer.play(AssetSource('sounds/button_click.mp3'));
  }

  void _handleLanguageChange(Locale newLocale) {
    HapticFeedback.selectionClick();
    _playButtonClickSound();
    ref.read(localeNotifierProvider.notifier).setLocale(newLocale);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settingsScreenTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              localizations.languageSettingLabel,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () => _handleLanguageChange(const Locale('en', '')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentLocale.languageCode == 'en' ? Theme.of(context).colorScheme.primary : Colors.grey,
                  ),
                  child: Text(localizations.englishLanguage, style: TextStyle(color: currentLocale.languageCode == 'en' ? Theme.of(context).colorScheme.onPrimary : Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () => _handleLanguageChange(const Locale('ar', '')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentLocale.languageCode == 'ar' ? Theme.of(context).colorScheme.primary : Colors.grey,
                  ),
                  child: Text(localizations.arabicLanguage, style: TextStyle(color: currentLocale.languageCode == 'ar' ? Theme.of(context).colorScheme.onPrimary : Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
