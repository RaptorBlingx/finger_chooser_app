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

const int kCountdownSeconds = 5; // Changed to kCamelCase
const int kMinFingersToStart = 2;  // Changed to kCamelCase

class ChooserStateNotifier extends StateNotifier<ChooserScreenState> {
  ChooserStateNotifier() : super(const ChooserScreenState(countdownSecondsRemaining: kCountdownSeconds));

  Timer? _countdownTimer;
  final Random _random = Random();
  final DareService _dareService = DareService(); // Instantiate DareService

  Color _getRandomColor() {
    return Color.fromARGB(
      255,
      _random.nextInt(200) + 55,
      _random.nextInt(200) + 55,
      _random.nextInt(200) + 55,
    );
  }

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

  void moveFinger(PointerMoveEvent event) {
    if (state.gamePhase == GamePhase.countdownActive) return; 

    final index = state.activeFingers.indexWhere((f) => f.id == event.pointer);
    if (index != -1) {
      final updatedFingers = List<Finger>.from(state.activeFingers);
      // Assuming Finger has copyWith
      updatedFingers[index] = updatedFingers[index].copyWith(position: event.localPosition);
      state = state.copyWith(activeFingers: updatedFingers);
    }
  }

  void removeFinger(PointerEvent event) {
    final remainingFingers = state.activeFingers.where((f) => f.id != event.pointer).toList();

    if (state.gamePhase == GamePhase.countdownActive) {
      _handleFalseStart();
      state = state.copyWith(
          activeFingers: remainingFingers,
          canStartCountdown: remainingFingers.length >= kMinFingersToStart);
      return;
    }

    state = state.copyWith(
      activeFingers: remainingFingers,
      canStartCountdown: remainingFingers.length >= kMinFingersToStart,
      gamePhase: remainingFingers.isEmpty ? GamePhase.waitingForFingers : state.gamePhase,
    );
  }

  void startCountdown() {
    if (state.activeFingers.length < kMinFingersToStart || state.gamePhase == GamePhase.countdownActive) {
      return; 
    }
    _cancelCountdown(); 

    state = state.copyWith(
      gamePhase: GamePhase.countdownActive,
      countdownSecondsRemaining: kCountdownSeconds,
    );

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => _tickCountdown());
  }

  void _tickCountdown() {
    if (!mounted) return; // Check if notifier is still mounted
    if (state.countdownSecondsRemaining > 1) {
      state = state.copyWith(countdownSecondsRemaining: state.countdownSecondsRemaining - 1);
    } else {
      _cancelCountdown();
      _selectWinner();
    }
  }

  

  Future<void> _selectWinner() async { // Make it async
    if (!mounted) return;
    if (state.activeFingers.isEmpty) {
      state = state.copyWith(gamePhase: GamePhase.waitingForFingers);
      return;
    }
    HapticFeedback.mediumImpact();

    final randomIndex = _random.nextInt(state.activeFingers.length);
    final winnerFinger = state.activeFingers[randomIndex];

    Dare? selectedDare;
    // Let's assume for now ChooserScreen always gets a selectedDare if one is found,
    // and ChooserScreen decides whether to use it based on isQuickPlayMode.
    // OR, we can pass isQuickPlayMode to this notifier.
    // For now, let's keep it simple: always try to get a dare.
    
    try {
      // TODO: When Custom Play wizard exists, construct FilterCriteria based on user choices.
      // For now, no criteria are passed, so all dares are considered.
      // Example of how you might use criteria later:
      // final criteria = FilterCriteria(playerCount: state.activeFingers.length, genders: ["mixed"]);
      // selectedDare = await _dareService.getRandomDare(criteria: criteria);
      
      selectedDare = await _dareService.getRandomDare(); // No criteria for now

    } catch (e) {
      print("Error selecting dare: $e");
    }
    
    if (!mounted) return; 
    state = state.copyWith(
      selectedFinger: winnerFinger,
      selectedDare: selectedDare, 
      gamePhase: GamePhase.selectionComplete,
    );
  }



  void _handleFalseStart() {
    if (!mounted) return;
    _cancelCountdown();
    state = state.copyWith(
      gamePhase: GamePhase.falseStart,
      countdownSecondsRemaining: kCountdownSeconds, 
      clearSelectedFinger: true,
    );
    HapticFeedback.heavyImpact(); 
    _cancelCountdown();
    state = state.copyWith(
      gamePhase: GamePhase.falseStart,
      countdownSecondsRemaining: kCountdownSeconds, 
      clearSelectedFinger: true,
      clearSelectedDare: true, // Also clear dare on false start
    );
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  void resetGame() {
    if (!mounted) return;
    _cancelCountdown();
    state = const ChooserScreenState(
        canStartCountdown: false, 
        countdownSecondsRemaining: kCountdownSeconds
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
