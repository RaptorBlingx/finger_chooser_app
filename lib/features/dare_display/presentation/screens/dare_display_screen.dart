// lib/features/dare_display/presentation/screens/dare_display_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../models/finger_model.dart';
import '../../../../models/dare_model.dart'; 

class DareDisplayScreen extends StatelessWidget {
  final Finger? selectedFinger; 
  final Dare? selectedDare; 

  const DareDisplayScreen({
    super.key,
    this.selectedFinger,
    this.selectedDare, 
  });

  static const String routeName = '/dare-display';

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    // ***** ENSURE DARETEXT IS DECLARED HERE *****
    final String dareText; // Declare the variable
    if (selectedDare != null) {
      // For now, prioritize English. Add locale checking later for Arabic.
      // final locale = Localizations.localeOf(context);
      // if (locale.languageCode == 'ar' && selectedDare!.textAr != null && selectedDare!.textAr!.isNotEmpty) {
      //   dareText = selectedDare!.textAr!;
      // } else {
      //   dareText = selectedDare!.textEn;
      // }
      dareText = selectedDare!.textEn; // Simplified for now
    } else {
      dareText = "No dare found! Play nice. :)"; // Fallback
    }
    // *******************************************

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appTitle), 
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (selectedFinger != null)
                Text(
                  "${localizations.appTitle}: Player chosen!", // Example, customize as needed
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
                  dareText, // <<< NOW dareText IS DEFINED
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Play Again / Next Round"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}