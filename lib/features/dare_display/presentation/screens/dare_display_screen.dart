// lib/features/dare_display/presentation/screens/dare_display_screen.dart

/// Screen responsible for displaying the selected dare to the user.
///
/// It receives the chosen [Finger] (optional, to indicate who was chosen)
/// and the [Dare] to be displayed. The dare text is localized based on the
/// current app locale. Sound and haptic feedback are provided.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:audioplayers/audioplayers.dart'; // Added audioplayers
import '../../../../models/finger_model.dart';
import '../../../../models/dare_model.dart';

class DareDisplayScreen extends StatefulWidget { // Changed to StatefulWidget
  final Finger? selectedFinger;
  final Dare? selectedDare;

  const DareDisplayScreen({
    super.key,
    this.selectedFinger,
    this.selectedDare,
  });

  static const String routeName = '/dare-display';

  @override
  State<DareDisplayScreen> createState() => _DareDisplayScreenState();
}

class _DareDisplayScreenState extends State<DareDisplayScreen> {
  final AudioPlayer _dareRevealPlayer = AudioPlayer();
  final AudioPlayer _buttonClickPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    // Play dare reveal sound
    if (widget.selectedDare != null) {
      _dareRevealPlayer.play(AssetSource('sounds/dare_reveal.mp3'));
    }
  }

  @override
  void dispose() {
    _dareRevealPlayer.dispose();
    _buttonClickPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    final String dareText;
    if (widget.selectedDare != null) {
      if (locale.languageCode == 'ar' && widget.selectedDare!.textAr != null && widget.selectedDare!.textAr!.isNotEmpty) {
        dareText = widget.selectedDare!.textAr!;
      } else {
        dareText = widget.selectedDare!.textEn;
      }
    } else {
      dareText = localizations.noDareFound;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.dareDisplayScreenTitle),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (widget.selectedFinger != null)
                Text(
                  localizations.playerChosenTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  dareText,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  _buttonClickPlayer.play(AssetSource('sounds/button_click.mp3'));
                  Navigator.of(context).pop();
                },
                child: Text(localizations.playAgainButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}