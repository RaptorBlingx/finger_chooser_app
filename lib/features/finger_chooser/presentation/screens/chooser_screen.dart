// lib/features/finger_chooser/presentation/screens/chooser_screen.dart

/// This screen is the core of the finger choosing game.
///
/// It allows users to place multiple fingers on the screen. After a countdown,
/// one finger is randomly selected. Depending on the game mode (`isQuickPlayMode`
/// or if `customDares` are provided), it may navigate to the `DareDisplayScreen`
/// to show a dare for the selected person.
///
/// It handles different game phases:
/// - Waiting for fingers.
/// - Countdown active.
/// - Selection complete.
/// - False start (if a finger is lifted during countdown).
///
/// It uses Riverpod for state management via `ChooserStateNotifier` and
/// includes animations for the selected finger, haptic feedback, and sound effects.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'dart:math' as math;

import '../../../dare_display/presentation/screens/dare_display_screen.dart';

// import '../../../../providers/locale_provider.dart'; // No longer needed here
import '../provider/chooser_state_provider.dart'; // Our new state provider
import '../provider/chooser_models.dart';      // For GamePhase, ChooserScreenState
import '../../../../models/finger_model.dart';  // For Finger model

class ChooserScreen extends ConsumerStatefulWidget {
  final bool isQuickPlayMode;
  final List<String>? customDares; // New field for custom dares

  const ChooserScreen({
    super.key,
    this.isQuickPlayMode = false,
    this.customDares, // Add to constructor
  });


  @override
  ConsumerState<ChooserScreen> createState() => _ChooserScreenState();

}

class _ChooserScreenState extends ConsumerState<ChooserScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late ConfettiController _confettiController;

  // Audio players
  final AudioPlayer _countdownStartPlayer = AudioPlayer();
  final AudioPlayer _selectionPlayer = AudioPlayer();
  final AudioPlayer _falseStartPlayer = AudioPlayer();
  final AudioPlayer _buttonClickPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    // Configure audio players - typically you might set release mode, etc.
    // For simplicity, we'll just use them as is.
    // It's good practice to set the source for players if you intend to play them multiple times
    // but for one-shot plays, player.play(AssetSource(...)) is fine.

    // Pass customDares to the notifier if they exist
    // This needs to be done after the first build or in a way that notifier is available
    // Or, the provider itself needs to be a family provider if customDares is known at provider creation
    // For simplicity, if customDares is passed, we can call a method on the notifier.
    // This should ideally be done once.
    // TODO: Implement setCustomDares method in ChooserStateNotifier when custom dares feature is needed
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (widget.customDares != null && widget.customDares!.isNotEmpty) {
    //     ref.read(chooserStateProvider.notifier).setCustomDares(widget.customDares!);
    //   }
    // });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Initialize confetti controller
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();
    // Release audio players
    _countdownStartPlayer.dispose();
    _selectionPlayer.dispose();
    _falseStartPlayer.dispose();
    _buttonClickPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final chooserState = ref.watch(chooserStateProvider);
    final chooserNotifier = ref.read(chooserStateProvider.notifier);
    // Determine if we are in a mode that should display dares.
    // This is true if it's not quickPlayMode OR if customDares are provided.
    final bool shouldDisplayDares = !widget.isQuickPlayMode || (widget.customDares != null && widget.customDares!.isNotEmpty);
    final bool currentIsQuickPlayModeEffective = widget.isQuickPlayMode && (widget.customDares == null || widget.customDares!.isEmpty);


    ref.listen<ChooserScreenState>(chooserStateProvider, (previous, next) {
      // Handle sounds and haptics based on game phase changes
      if (previous?.gamePhase != next.gamePhase) {
        if (next.gamePhase == GamePhase.countdownActive) {
          HapticFeedback.mediumImpact();
          _countdownStartPlayer.play(AssetSource('sounds/tick.mp3'));
        } else if (next.gamePhase == GamePhase.selectionComplete && next.selectedFinger != null) {
          // Heavy haptic is already in Notifier
          _selectionPlayer.play(AssetSource('sounds/selection_winner.mp3'));
          _animationController.repeat(reverse: true);
          // Trigger confetti celebration!
          _confettiController.play();
        } else if (next.gamePhase == GamePhase.falseStart) {
          // Light haptic is already in Notifier
          _falseStartPlayer.play(AssetSource('sounds/false_start.mp3'));
          _animationController.stop();
          _animationController.reset();
        }
      }

      // Original logic for navigation and animation reset
      if (next.gamePhase == GamePhase.selectionComplete && next.selectedFinger != null) {
        // Navigate to DareDisplayScreen if not in effective Quick Play mode (i.e., if dares should be shown)
        if (shouldDisplayDares) {
          Future.delayed(const Duration(milliseconds: 2000), () {
            if (mounted) { // Ensure widget is still mounted before stopping animation or navigating
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
            }
          });
        } else {
          // In effective Quick Play mode (no dares to show), just show the result on ChooserScreen
          // The animation will play. The "Play Again" button will allow reset.
          Future.delayed(const Duration(milliseconds: 2000), () {
            if (mounted && _animationController.isAnimating) {
              _animationController.stop();
              _animationController.reset();
            }
          });
        }
      } else if (previous?.gamePhase == GamePhase.selectionComplete && next.gamePhase != GamePhase.selectionComplete) {
        if (mounted) {
          _animationController.stop();
          _animationController.reset();
        }
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
            if (currentIsQuickPlayModeEffective) {
              return "Finger ID ${chooserState.selectedFinger!.id} is it! Tap 'Play Again'.";
            } else {
              // This message will show briefly before navigating to DareDisplayScreen if dares are active
              return "${localizations.appTitle}: Finger ID ${chooserState.selectedFinger!.id} chosen!";
            }
          }
          return "Selection complete!";
        case GamePhase.falseStart:
          return "False Start! All fingers must stay. Try again.";
      }
      return localizations.placeFingersPrompt; // Should ideally not be reached
    }


    return Scaffold(
      appBar: AppBar(
        title: Text(currentIsQuickPlayModeEffective ? "Quick Pick" : (widget.customDares != null && widget.customDares!.isNotEmpty ? "Custom Game" : localizations.appTitle)),
        actions: const[], // Removed language toggle buttons
      ),
      body: Stack(
        children: [
          Column(
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
                      HapticFeedback.selectionClick();
                      _buttonClickPlayer.play(AssetSource('sounds/button_click.mp3'));
                      _animationController.stop();
                      _animationController.reset();
                      chooserNotifier.resetGame();
                    },
                    child: Text(localizations.playAgainButtonChooser),
                  )
                : (chooserState.gamePhase == GamePhase.falseStart
                    ? ElevatedButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          _buttonClickPlayer.play(AssetSource('sounds/button_click.mp3'));
                          chooserNotifier.resetGame();
                        },
                        child: Text(localizations.tryAgainButtonChooser),
                      )
                    : ElevatedButton(
                        onPressed: chooserState.canStartCountdown &&
                                chooserState.gamePhase ==
                                    GamePhase.waitingForFingers
                            ? () {
                                HapticFeedback.selectionClick();
                                _buttonClickPlayer.play(AssetSource('sounds/button_click.mp3'));
                                chooserNotifier.startCountdown();
                              }
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
      // Confetti overlay
      Align(
        alignment: Alignment.topCenter,
        child: ConfettiWidget(
          confettiController: _confettiController,
          blastDirection: math.pi / 2, // downward
          blastDirectionality: BlastDirectionality.explosive,
          particleDrag: 0.05,
          emissionFrequency: 0.02,
          numberOfParticles: 50,
          gravity: 0.2,
          shouldLoop: false,
          colors: const [
            Colors.green,
            Colors.blue,
            Colors.pink,
            Colors.orange,
            Colors.purple,
            Colors.yellow,
          ],
        ),
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