// lib/features/finger_chooser/presentation/providers/chooser_state_provider.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart'; // For PointerEvent, Offset, Color
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chooser_models.dart'; // Your GamePhase and ChooserScreenState
import '../../../../models/finger_model.dart'; // Your Finger model
import 'package:flutter/services.dart'; // For HapticFeedback

import '../../../../models/dare_model.dart';      // Import Dare model
import '../../../../services/dare_service.dart'; // Import DareService
import '../../../../models/filter_criteria_model.dart';

/// Default duration for the countdown in seconds.
const int kCountdownSeconds = 5;
/// Minimum number of fingers required on the screen to start the countdown.
const int kMinFingersToStart = 2;

/// Manages the state for the [ChooserScreen].
///
/// This notifier handles the game logic, including:
/// - Tracking active fingers on the screen.
/// - Managing the countdown timer.
/// - Selecting a winner finger.
/// - Fetching and assigning dares (or using custom dares).
/// - Handling false starts.
/// - Resetting the game state.
class ChooserStateNotifier extends StateNotifier<ChooserScreenState> {
  /// Initializes the notifier with a default [ChooserScreenState].
  ChooserStateNotifier() : super(ChooserScreenState(countdownSecondsRemaining: kCountdownSeconds));

  /// Timer for the countdown. Null if no countdown is active.
  Timer? _countdownTimer;
  /// Random number generator for selecting a winner and dares.
  final Random _random = Random();
  /// Service to fetch dare objects.
  final DareService _dareService = DareService();

  /// Sets a list of custom dares to be used for the game.
  ///
  /// When custom dares are provided, the [DareService] will be bypassed
  /// during winner selection, and a random dare from this list will be chosen.
  /// - [dares]: A list of strings, where each string is a custom dare.
  void setCustomDares(List<String> dares) {
    if (!mounted) return;
    state = state.copyWith(customDares: dares);
  }

  /// Generates a random vibrant color for a new finger.
  Color _getRandomColor() {
    return Color.fromARGB(
      255, // Alpha
      _random.nextInt(200) + 55, // Red (avoiding very dark colors)
      _random.nextInt(200) + 55,
      _random.nextInt(200) + 55,
    );
  }

  /// Adds a new finger to the screen.
  ///
  /// If the game was previously completed or in a false start state, it resets the game.
  /// Cancels any active countdown.
  /// Adds the new finger with a unique ID, its initial position, and a random color.
  /// Updates the game phase to [GamePhase.waitingForFingers] and checks if countdown can start.
  /// - [event]: The [PointerDownEvent] triggered by the user.
  void addFinger(PointerDownEvent event) {
    if (state.gamePhase == GamePhase.selectionComplete || state.gamePhase == GamePhase.falseStart) {
      resetGame();
    }
    
    _cancelCountdown();

    final newFingers = List<Finger>.from(state.activeFingers);
    if (!newFingers.any((f) => f.id == event.pointer)) {
      newFingers.add(Finger( // This should now resolve correctly
        id: event.pointer,
        position: event.localPosition,
        color: _getRandomColor(),
      ));
    }

    state = state.copyWith(
      activeFingers: newFingers,
      clearSelectedFinger: true, // Explicitly clear selected finger
      gamePhase: GamePhase.waitingForFingers, 
      countdownSecondsRemaining: kCountdownSeconds, 
      canStartCountdown: newFingers.length >= kMinFingersToStart, 
    );
  }

  /// Updates the position of an existing finger on the screen.
  ///
  /// This is ignored if a countdown is currently active to prevent changes during selection.
  /// - [event]: The [PointerMoveEvent] triggered by the user.
  void moveFinger(PointerMoveEvent event) {
    // Do not allow finger movement during active countdown to ensure fairness.
    if (state.gamePhase == GamePhase.countdownActive) return;

    final index = state.activeFingers.indexWhere((f) => f.id == event.pointer);
    if (index != -1) {
      final updatedFingers = List<Finger>.from(state.activeFingers);
      // Assuming Finger has copyWith
      updatedFingers[index] = updatedFingers[index].copyWith(position: event.localPosition);
      state = state.copyWith(activeFingers: updatedFingers);
    }
  }

  /// Removes a finger from the screen.
  ///
  /// If a finger is removed during an active countdown, it triggers a "false start".
  /// Otherwise, it updates the list of active fingers and checks if the game phase
  /// or ability to start a countdown needs to change.
  /// - [event]: The [PointerEvent] (e.g., `PointerUpEvent`, `PointerCancelEvent`) for the removed finger.
  void removeFinger(PointerEvent event) {
    final remainingFingers = state.activeFingers.where((f) => f.id != event.pointer).toList();

    if (state.gamePhase == GamePhase.countdownActive) {
      // If a finger is lifted during countdown, it's a false start.
      _handleFalseStart();
      // Update active fingers list even on false start, but canStartCountdown might change
      state = state.copyWith(
          activeFingers: remainingFingers,
          canStartCountdown: remainingFingers.length >= kMinFingersToStart
      );
      return;
    }

    // Standard finger removal when not in countdown
    state = state.copyWith(
      activeFingers: remainingFingers,
      canStartCountdown: remainingFingers.length >= kMinFingersToStart,
      // If all fingers are removed, reset to waiting, otherwise keep current phase (likely waitingForFingers)
      gamePhase: remainingFingers.isEmpty ? GamePhase.waitingForFingers : state.gamePhase,
    );
  }

  /// Starts the countdown process if enough fingers are on the screen
  /// and no countdown is already active.
  ///
  /// Sets the game phase to [GamePhase.countdownActive] and initializes the timer.
  void startCountdown() {
    if (state.activeFingers.length < kMinFingersToStart || state.gamePhase == GamePhase.countdownActive) {
      return;
    }
    _cancelCountdown(); // Ensure any previous timer is stopped.

    state = state.copyWith(
      gamePhase: GamePhase.countdownActive,
      countdownSecondsRemaining: kCountdownSeconds,
    );

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => _tickCountdown());
  }

  /// Called periodically by the countdown timer.
  ///
  /// Decrements the remaining countdown seconds. If the countdown reaches zero,
  /// it cancels the timer and triggers the winner selection process.
  void _tickCountdown() {
    if (!mounted) return;
    if (state.countdownSecondsRemaining > 1) {
      state = state.copyWith(countdownSecondsRemaining: state.countdownSecondsRemaining - 1);
    } else {
      _cancelCountdown();
      _selectWinner(); // Selects winner when countdown finishes
    }
  }

  /// Selects a random winning finger from the active fingers.
  ///
  /// If custom dares are provided in the state, a random custom dare is chosen.
  /// Otherwise, a random dare is fetched using the [DareService].
  /// Updates the game phase to [GamePhase.selectionComplete] and sets the
  /// [selectedFinger] and [selectedDare] in the state.
  /// Triggers haptic feedback for winner selection.
  Future<void> _selectWinner() async {
    if (!mounted) return;
    if (state.activeFingers.isEmpty) {
      // Should not happen if countdown started correctly, but as a safeguard.
      state = state.copyWith(gamePhase: GamePhase.waitingForFingers);
      return;
    }
    HapticFeedback.heavyImpact(); // Haptic feedback for winner selection.

    final randomIndex = _random.nextInt(state.activeFingers.length);
    final winnerFinger = state.activeFingers[randomIndex];

    Dare? selectedDare;
    
    try {
      if (state.customDares != null && state.customDares!.isNotEmpty) {
        // Use custom dare
        final randomDareText = state.customDares![_random.nextInt(state.customDares!.length)];
        // Assuming Dare model can be created with just text, or adjust as needed
        // If Dare needs an ID or other fields, those might need to be mocked or handled.
        // For simplicity, creating a Dare object with the text.
        // The ID 'custom' is arbitrary. Category might also be 'custom'.
        selectedDare = Dare(id: 'custom_${_random.nextInt(10000)}', text: randomDareText, category: 'Custom');
      } else {
        // Use DareService for default dares
        // TODO: When Custom Play wizard exists, construct FilterCriteria based on user choices.
        // For now, no criteria are passed, so all dares are considered.
        // Example of how you might use criteria later:
        // final criteria = FilterCriteria(playerCount: state.activeFingers.length, genders: ["mixed"]);
        // selectedDare = await _dareService.getRandomDare(criteria: criteria);
        selectedDare = await _dareService.getRandomDare(); // No criteria for now
      }
    } catch (e) {
      print("Error selecting dare: $e");
      // Optionally set a default/error dare or handle error state
      selectedDare = const Dare(id: 'error', text: 'Oops! Could not load a dare.', category: 'Error');
    }
    
    if (!mounted) return; 
    state = state.copyWith(
      selectedFinger: winnerFinger,
      selectedDare: selectedDare,
      gamePhase: GamePhase.selectionComplete,
    );
  }

  /// Handles a "false start" event, typically when a finger is lifted during countdown.
  ///
  /// Cancels the countdown, sets the game phase to [GamePhase.falseStart],
  /// and triggers haptic feedback.
  void _handleFalseStart() {
    if (!mounted) return;
    _cancelCountdown();
    // First update to false start phase and clear selection
    state = state.copyWith(
      gamePhase: GamePhase.falseStart,
      countdownSecondsRemaining: kCountdownSeconds,
      clearSelectedFinger: true,
      clearSelectedDare: true, // Also clear dare on false start
    );
    HapticFeedback.lightImpact(); // Haptic feedback for false start.
    // Note: The timer is already cancelled by _cancelCountdown.
    // No need to call it again or update state further for this specific action's core logic.
  }

  /// Cancels the active countdown timer, if any.
  void _cancelCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  /// Resets the game to its initial state.
  ///
  /// Cancels any active countdown and clears all game-related data like
  /// active fingers, selected winner, selected dare, and custom dares.
  /// Sets the game phase to [GamePhase.waitingForFingers].
  void resetGame() {
    if (!mounted) return;
    _cancelCountdown();
    state = const ChooserScreenState(
        canStartCountdown: false,
        countdownSecondsRemaining: kCountdownSeconds,
        customDares: null // Explicitly clear custom dares
        // selectedFinger and selectedDare will be null by default constructor
    );
  }


  @override
  void dispose() {
    _cancelCountdown();
    super.dispose();
  }
}

final chooserStateProvider = StateNotifierProvider<ChooserStateNotifier, ChooserScreenState>((ref) {
  return ChooserStateNotifier();
});
