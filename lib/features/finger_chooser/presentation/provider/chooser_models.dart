// lib/features/finger_chooser/presentation/providers/chooser_models.dart
import 'package:flutter/material.dart'; // For Offset
import '../../../../models/finger_model.dart'; // We'll create/use this from before
import '../../../../models/dare_model.dart';



enum GamePhase {
  waitingForFingers, 
  countdownActive,   
  selectionComplete, 
  falseStart         
}

@immutable 
class ChooserScreenState {
  final List<Finger> activeFingers;
  final int countdownSecondsRemaining;
  final GamePhase gamePhase;
  final Finger? selectedFinger;
  final Dare? selectedDare; 
  final bool canStartCountdown; 

  const ChooserScreenState({
    this.activeFingers = const [],
    this.countdownSecondsRemaining = 5, // Default, will be overridden by Notifier's initial state
    this.gamePhase = GamePhase.waitingForFingers,
    this.selectedFinger,
    this.selectedDare, 
    this.canStartCountdown = false,
  });

  // Ensure this copyWith method includes clearSelectedFinger
  ChooserScreenState copyWith({
    List<Finger>? activeFingers,
    int? countdownSecondsRemaining,
    GamePhase? gamePhase,
    Finger? selectedFinger, // Allows passing a new selected finger
    Dare? selectedDare,
    bool clearSelectedFinger = false, // Flag to explicitly set selectedFinger to null
    bool clearSelectedDare = false, 
    bool? canStartCountdown,
  }) {
    return ChooserScreenState(
      activeFingers: activeFingers ?? this.activeFingers,
      countdownSecondsRemaining: countdownSecondsRemaining ?? this.countdownSecondsRemaining,
      gamePhase: gamePhase ?? this.gamePhase,
      // If clearSelectedFinger is true, selectedFinger becomes null.
      // Otherwise, if a new selectedFinger is provided, use it.
      // Otherwise, keep the existing selectedFinger.
      selectedFinger: clearSelectedFinger ? null : (selectedFinger ?? this.selectedFinger),
      selectedDare: clearSelectedDare ? null : (selectedDare ?? this.selectedDare),
      canStartCountdown: canStartCountdown ?? this.canStartCountdown,
    );
  }
}
