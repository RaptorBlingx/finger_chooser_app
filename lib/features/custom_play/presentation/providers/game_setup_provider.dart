import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/game_setup_model.dart';

/// State for the wizard wizard
class GameSetupState {
  final int currentStep;
  final int? playerCount;
  final String? genderMix;
  final String? relationship;
  final String? location;
  final String? loseRule;

  const GameSetupState({
    this.currentStep = 0,
    this.playerCount,
    this.genderMix,
    this.relationship,
    this.location,
    this.loseRule,
  });

  GameSetupState copyWith({
    int? currentStep,
    int? playerCount,
    String? genderMix,
    String? relationship,
    String? location,
    String? loseRule,
  }) {
    return GameSetupState(
      currentStep: currentStep ?? this.currentStep,
      playerCount: playerCount ?? this.playerCount,
      genderMix: genderMix ?? this.genderMix,
      relationship: relationship ?? this.relationship,
      location: location ?? this.location,
      loseRule: loseRule ?? this.loseRule,
    );
  }

  bool get canProceedToStep2 => playerCount != null;
  bool get canProceedToStep3 => canProceedToStep2 && genderMix != null;
  bool get canProceedToStep4 => canProceedToStep3 && relationship != null;
  bool get canProceedToStep5 => canProceedToStep4 && location != null;
  bool get isComplete => canProceedToStep5 && loseRule != null;

  GameSetup toGameSetup() {
    if (!isComplete) {
      throw StateError('Game setup is incomplete');
    }
    return GameSetup(
      playerCount: playerCount!,
      genderMix: genderMix!,
      relationship: relationship!,
      location: location!,
      loseRule: loseRule!,
    );
  }
}

/// Notifier for managing wizard state
class GameSetupNotifier extends StateNotifier<GameSetupState> {
  GameSetupNotifier() : super(const GameSetupState());

  void nextStep() {
    if (state.currentStep < 4) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void setPlayerCount(int count) {
    state = state.copyWith(playerCount: count);
  }

  void setGenderMix(String gender) {
    state = state.copyWith(genderMix: gender);
  }

  void setRelationship(String rel) {
    state = state.copyWith(relationship: rel);
  }

  void setLocation(String loc) {
    state = state.copyWith(location: loc);
  }

  void setLoseRule(String rule) {
    state = state.copyWith(loseRule: rule);
  }

  void reset() {
    state = const GameSetupState();
  }
}

/// Provider for the game setup wizard
final gameSetupProvider =
    StateNotifierProvider<GameSetupNotifier, GameSetupState>((ref) {
  return GameSetupNotifier();
});
