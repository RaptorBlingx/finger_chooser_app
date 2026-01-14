/// Screen that displays available dare packs for purchase or acquisition.
///
/// This screen currently shows a placeholder list of dare packs.
/// Future enhancements would include actual purchase/unlock logic and
/// integration with a backend or in-app purchase service.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:audioplayers/audioplayers.dart'; // Added audioplayers
import '../../../../models/dare_pack_model.dart';

class StoreScreen extends StatefulWidget { // Changed to StatefulWidget
  const StoreScreen({super.key});

  static const String routeName = '/store';

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> { // State class
  final AudioPlayer _buttonClickPlayer = AudioPlayer();

  // Placeholder list of dare packs - moved here to be accessible in build
  // In a real app, this would come from a provider/service
  final List<DarePack> darePacks = [
    DarePack(
      id: 'pack1',
      name: 'Starter Dares',
      description: 'A collection of fun and easy dares to get you started. Perfect for all audiences.',
      price: 'Free',
      iconData: Icons.star_outline,
      isFree: true,
      dareCount: 60,
      category: 'mild',
    ),
    DarePack(
      id: 'pack2',
      name: 'Extreme Challenge Pack',
      description: 'Push your limits with these intense and wild dares. Not for the faint of heart!',
      price: '\$1.99',
      iconData: Icons.whatshot_outlined,
      isFree: false,
      dareCount: 50,
      category: 'wild',
    ),
    DarePack(
      id: 'pack3',
      name: 'Hilarious Pranks Pack',
      description: 'Get ready to laugh with these funny prank dares. Great for parties!',
      price: '\$0.99',
      iconData: Icons.emoji_emotions_outlined,
      isFree: false,
      dareCount: 40,
      category: 'spicy',
    ),
    DarePack(
      id: 'pack4',
      name: 'Truth or Dare Classics',
      description: 'A mix of classic truth questions and dare challenges. (Truths not implemented yet!)',
      price: 'Free',
      iconData: Icons.question_answer_outlined,
      isFree: true,
      dareCount: 60,
      category: 'spicy',
    ),
  ];

  @override
  void dispose() {
    _buttonClickPlayer.dispose();
    super.dispose();
  }

  void _playButtonClickSound() {
    _buttonClickPlayer.play(AssetSource('sounds/button_click.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.storeScreenTitle),
      ),
      body: ListView.builder(
        itemCount: darePacks.length, // Use the list from the state class
        itemBuilder: (context, index) {
          final pack = darePacks[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: Icon(pack.iconData, size: 40.0, color: Theme.of(context).primaryColor),
              title: Text(pack.name, style: Theme.of(context).textTheme.titleMedium),
              subtitle: Text(pack.description, style: Theme.of(context).textTheme.bodyMedium),
              trailing: ElevatedButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  _playButtonClickSound();
                  // TODO: Implement pack acquisition logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Acquiring ${pack.name}... (Not implemented)')),
                  );
                },
                child: Text(pack.price == 'Free' ? localizations.getButtonLabel : pack.price),
              ),
            ),
          );
        },
      ),
    );
  }
}
