// lib/features/finger_chooser/presentation/screens/chooser_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../dare_display/presentation/screens/dare_display_screen.dart'; 

import '../../../../providers/locale_provider.dart'; // For language switching
import '../provider/chooser_state_provider.dart'; // Our new state provider
import '../provider/chooser_models.dart';      // For GamePhase, ChooserScreenState
import '../../../../models/finger_model.dart';  // For Finger model

class ChooserScreen extends ConsumerStatefulWidget {
 // const ChooserScreen({super.key});
  final bool isQuickPlayMode; 

  const ChooserScreen({
    super.key,
    this.isQuickPlayMode = false, // Default to false (Party Play with dares)
  });


  @override
  ConsumerState<ChooserScreen> createState() => _ChooserScreenState();

}

class _ChooserScreenState extends ConsumerState<ChooserScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final chooserState = ref.watch(chooserStateProvider);
    final chooserNotifier = ref.read(chooserStateProvider.notifier); // <<< DEFINED HERE
    final bool currentIsQuickPlayMode = widget.isQuickPlayMode; // Access mode


    ref.listen<ChooserScreenState>(chooserStateProvider, (previous, next) {
      if (next.gamePhase == GamePhase.selectionComplete && next.selectedFinger != null) {
        _animationController.repeat(reverse: true); 

        // Only navigate to DareDisplayScreen if NOT in Quick Play mode
        if (!currentIsQuickPlayMode) { // <<< CHECK MODE HERE
          Future.delayed(const Duration(milliseconds: 2000), () { 
            _animationController.stop(); 
            _animationController.reset(); 


              if (ModalRoute.of(context)?.isCurrent ?? false) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DareDisplayScreen(
                      selectedFinger: next.selectedFinger,
                      selectedDare: next.selectedDare,
                    ),
                  ),
                ).then((_) {
                  chooserNotifier.resetGame();
                });
              }
            });
          } else {
            // In Quick Play mode, just show the result on ChooserScreen
            // The animation will play. The "Play Again" button will allow reset.
            // We might want to stop the animation after a shorter period if not navigating
            Future.delayed(const Duration(milliseconds: 2000), () {
              if (mounted && _animationController.isAnimating) { // Check if widget is still mounted
                  _animationController.stop();
                  _animationController.reset(); // Optionally reset or just let it sit at end of pulse
              }
            });
          }
        } else if (previous?.gamePhase == GamePhase.selectionComplete && 
                  next.gamePhase != GamePhase.selectionComplete) {
          _animationController.stop();
          _animationController.reset();
        } else if (next.gamePhase == GamePhase.falseStart) {
          _animationController.stop();
          _animationController.reset();
        }
      });


    String getInstructionText() {
      switch (chooserState.gamePhase) {
        case GamePhase.waitingForFingers:
          return chooserState.activeFingers.isEmpty
              ? localizations.placeFingersPrompt
              : "${chooserState.activeFingers.length} ${chooserState.activeFingers.length == 1 ? 'finger' : 'fingers'} on screen. Need at least $kMinFingersToStart.";
        case GamePhase.countdownActive:
          return "Choosing in: ${chooserState.countdownSecondsRemaining}...";
        case GamePhase.selectionComplete:
          if (chooserState.selectedFinger != null) {
            if (currentIsQuickPlayMode) { // <<< CHECK FOR QUICK PLAY MODE
              return "Finger ID ${chooserState.selectedFinger!.id} is it! Tap 'Play Again'."; // Specific Quick Pick message
            } else {
              return "${localizations.appTitle}: Finger ID ${chooserState.selectedFinger!.id} chosen!"; // Party Play message
            }
          }
          return "Selection complete!"; // Fallback if selectedFinger is somehow null
        case GamePhase.falseStart:
          return "False Start! All fingers must stay. Try again.";
      }
      return localizations.placeFingersPrompt; // Should ideally not be reached
    }


    return Scaffold(
      appBar: AppBar(
        title: Text(currentIsQuickPlayMode ? "Quick Pick" : localizations.appTitle),
        actions: [
          TextButton(
            onPressed: () => ref.read(localeNotifierProvider.notifier).setLocale(const Locale('en', '')),
            child: const Text('EN', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => ref.read(localeNotifierProvider.notifier).setLocale(const Locale('ar', '')),
            child: const Text('AR', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              getInstructionText(),
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
          if (chooserState.gamePhase == GamePhase.countdownActive)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: chooserState.countdownSecondsRemaining / kCountdownSeconds,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey[300],
                    ),
                    Center(
                      child: Text(
                        '${chooserState.countdownSecondsRemaining}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: Listener(
              onPointerDown: chooserNotifier.addFinger,
              onPointerMove: chooserNotifier.moveFinger,
              onPointerUp: chooserNotifier.removeFinger,
              onPointerCancel: chooserNotifier.removeFinger,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: chooserState.gamePhase == GamePhase.falseStart
                    ? Colors.red.withOpacity(0.1)
                    : Colors.grey[200],
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: FingerPainter(
                        chooserState.activeFingers,
                        chooserState.selectedFinger,
                        (chooserState.gamePhase == GamePhase.selectionComplete &&
                                chooserState.selectedFinger != null)
                            ? _pulseAnimation.value
                            : 1.0,
                      ),
                      size: Size.infinite,
                    );
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: (chooserState.gamePhase == GamePhase.selectionComplete)
                ? ElevatedButton(
                    onPressed: () {
                      _animationController.stop();
                      _animationController.reset();
                      chooserNotifier.resetGame();
                    },
                    child: const Text("Play Again"), 
                  )
                : (chooserState.gamePhase == GamePhase.falseStart
                    ? ElevatedButton(
                        onPressed: chooserNotifier.resetGame,
                        child: const Text("Try Again"),
                      )
                    : ElevatedButton(
                        onPressed: chooserState.canStartCountdown &&
                                chooserState.gamePhase ==
                                    GamePhase.waitingForFingers
                            ? chooserNotifier.startCountdown
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          textStyle: Theme.of(context).textTheme.titleLarge,
                        ),
                        child: Text(localizations.selectButton),
                      )),
          ),
        ],
      ),
    );
  }
}

// FingerPainter class (at the bottom of chooser_screen.dart)
class FingerPainter extends CustomPainter {
  final List<Finger> fingers;
  final Finger? selectedFinger;
  final double selectionScale; 

  FingerPainter(this.fingers, this.selectedFinger, this.selectionScale);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint fingerPaint = Paint()..style = PaintingStyle.fill;
    
    final Paint highlightPaint = Paint() // Renamed from selectedPaint for clarity
      ..style = PaintingStyle.stroke
      ..color = Colors.redAccent; // Persistent highlight color
    
    const double baseRadius = 30.0;
    const double baseHighlightStrokeWidth = 5.0;

    for (final finger in fingers) {
      fingerPaint.color = finger.color;
      
      double currentDisplayRadius = baseRadius;
      
      if (selectedFinger != null && finger.id == selectedFinger!.id) {
        // Apply pulsing scale to the selected finger's display radius for the main circle
        currentDisplayRadius = baseRadius * selectionScale;

        // The highlight will always be drawn if this is the selected finger
        // Its stroke width can also pulse, or remain constant, or be slightly thicker
        final double currentHighlightRadius = baseRadius * selectionScale + (baseHighlightStrokeWidth / 2); // Adjust so stroke is outside scaled radius
        final double currentHighlightStroke = baseHighlightStrokeWidth * selectionScale; // Pulse stroke width too

        // Draw the highlight
        canvas.drawCircle(
            finger.position, 
            currentHighlightRadius, // Highlight radius slightly larger to encompass the finger
            highlightPaint..strokeWidth = currentHighlightStroke, // Apply scaled stroke width
        );
      }
      // Draw the main finger circle
      canvas.drawCircle(finger.position, currentDisplayRadius, fingerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant FingerPainter oldDelegate) {
    return oldDelegate.fingers != fingers || 
           oldDelegate.selectedFinger != selectedFinger || 
           oldDelegate.selectionScale != selectionScale;
  }
}