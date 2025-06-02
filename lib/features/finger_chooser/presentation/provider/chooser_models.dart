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
  final List<String>? customDares; // New field for custom dares

  const ChooserScreenState({
    this.activeFingers = const [],
    this.countdownSecondsRemaining = 5, // Default, will be overridden by Notifier's initial state
    this.gamePhase = GamePhase.waitingForFingers,
    this.selectedFinger,
    this.selectedDare,
    this.canStartCountdown = false,
    this.customDares, // Add to constructor
  });

  ChooserScreenState copyWith({
    List<Finger>? activeFingers,
    int? countdownSecondsRemaining,
    GamePhase? gamePhase,
    Finger? selectedFinger,
    Dare? selectedDare,
    bool clearSelectedFinger = false,
    bool clearSelectedDare = false,
    bool? canStartCountdown,
    List<String>? customDares, // Add to copyWith parameters
    bool clearCustomDares = false, // Flag to explicitly set customDares to null
  }) {
    return ChooserScreenState(
      activeFingers: activeFingers ?? this.activeFingers,
      countdownSecondsRemaining: countdownSecondsRemaining ?? this.countdownSecondsRemaining,
      gamePhase: gamePhase ?? this.gamePhase,
      selectedFinger: clearSelectedFinger ? null : (selectedFinger ?? this.selectedFinger),
      selectedDare: clearSelectedDare ? null : (selectedDare ?? this.selectedDare),
      canStartCountdown: canStartCountdown ?? this.canStartCountdown,
      customDares: clearCustomDares ? null : (customDares ?? this.customDares), // Handle customDares
    );
  }
}
