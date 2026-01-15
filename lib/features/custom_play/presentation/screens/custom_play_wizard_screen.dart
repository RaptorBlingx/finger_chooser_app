import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../providers/game_setup_provider.dart';
import '../widgets/step_indicator.dart';
import '../widgets/player_count_selector.dart';
import '../widgets/gender_selector.dart';
import '../widgets/relationship_selector.dart';
import '../widgets/location_selector.dart';
import '../widgets/lose_rule_selector.dart';
import '../../../../models/filter_criteria_model.dart';
import '../../../finger_chooser/presentation/screens/chooser_screen_ultra.dart';

class CustomPlayWizardScreen extends ConsumerWidget {
  const CustomPlayWizardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameSetupProvider);
    final notifier = ref.read(gameSetupProvider.notifier);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade700,
              Colors.deepPurple.shade900,
              Colors.indigo.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with step indicator
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (state.currentStep > 0)
                          IconButton(
                            onPressed: () => notifier.previousStep(),
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                          )
                        else
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon:
                                const Icon(Icons.close, color: Colors.white),
                          ),
                        Text(
                          'Custom Game',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(width: 48), // Balance the back button
                      ],
                    ),
                    const SizedBox(height: 16),
                    StepIndicator(
                      currentStep: state.currentStep,
                      totalSteps: 5,
                    ),
                  ],
                ),
              ),

              // Step content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.2, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _buildStepContent(
                      context,
                      state,
                      notifier,
                    ),
                  ),
                ),
              ),

              // Navigation buttons (except for last step)
              if (state.currentStep < 4)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _canProceedToNextStep(state)
                          ? () => notifier.nextStep()
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.purple,
                        disabledBackgroundColor: Colors.white.withOpacity(0.3),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'NEXT',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(
    BuildContext context,
    GameSetupState state,
    GameSetupNotifier notifier,
  ) {
    switch (state.currentStep) {
      case 0:
        return PlayerCountSelector(
          key: const ValueKey('step0'),
          selectedCount: state.playerCount,
          onCountSelected: notifier.setPlayerCount,
        );
      case 1:
        return GenderSelector(
          key: const ValueKey('step1'),
          selectedGender: state.genderMix,
          onGenderSelected: notifier.setGenderMix,
        );
      case 2:
        return RelationshipSelector(
          key: const ValueKey('step2'),
          selectedRelationship: state.relationship,
          onRelationshipSelected: notifier.setRelationship,
        );
      case 3:
        return LocationSelector(
          key: const ValueKey('step3'),
          selectedLocation: state.location,
          onLocationSelected: notifier.setLocation,
        );
      case 4:
        return LoseRuleSelector(
          key: const ValueKey('step4'),
          selectedRule: state.loseRule,
          onRuleSelected: notifier.setLoseRule,
          onStartGame: () => _startGame(context, state, notifier),
          playerCount: state.playerCount,
          genderMix: state.genderMix,
          relationship: state.relationship,
          location: state.location,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  bool _canProceedToNextStep(GameSetupState state) {
    switch (state.currentStep) {
      case 0:
        return state.canProceedToStep2;
      case 1:
        return state.canProceedToStep3;
      case 2:
        return state.canProceedToStep4;
      case 3:
        return state.canProceedToStep5;
      default:
        return false;
    }
  }

  void _startGame(
    BuildContext context,
    GameSetupState state,
    GameSetupNotifier notifier,
  ) {
    if (!state.isComplete) return;

    final gameSetup = state.toGameSetup();

    // Log analytics event
    FirebaseAnalytics.instance.logEvent(
      name: 'custom_game_started',
      parameters: {
        'player_count': gameSetup.playerCount,
        'gender_mix': gameSetup.genderMix,
        'relationship': gameSetup.relationship,
        'location': gameSetup.location,
        'lose_rule': gameSetup.loseRule,
      },
    );

    // Convert GameSetup to FilterCriteria
    final criteria = _gameSetupToFilterCriteria(gameSetup);

    // Navigate to game with criteria
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChooserScreenUltra(
          filterCriteria: criteria,
          loseRule: gameSetup.loseRule,
        ),
      ),
    );

    // Reset wizard for next time
    notifier.reset();
  }

  FilterCriteria _gameSetupToFilterCriteria(gameSetup) {
    return FilterCriteria(
      playerCount: gameSetup.playerCount,
      groupTypes: [gameSetup.relationship],
      places: [gameSetup.location],
      genders: [gameSetup.genderMix],
    );
  }
}
