import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/game_setup_provider.dart';
import '../widgets/step_indicator.dart';
import '../widgets/lose_rule_selector.dart';
import '../../../../models/filter_criteria_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../finger_chooser/presentation/screens/chooser_screen_ultra.dart';

class CustomPlayWizardScreen extends ConsumerWidget {
  const CustomPlayWizardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameSetupProvider);
    final notifier = ref.read(gameSetupProvider.notifier);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with step indicator
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (state.currentStep > 0)
                          IconButton(
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              notifier.previousStep();
                            },
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                            ),
                          )
                        else
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.close,
                                  color: Colors.white),
                            ),
                          ),
                        Text(
                          localizations.custom,
                          style: AppTheme.headingM,
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    StepIndicator(
                      currentStep: state.currentStep,
                      totalSteps: 2,
                    ),
                  ],
                ),
              ),

              // Step content
              Expanded(
                child: AnimatedSwitcher(
                  duration: AppDurations.normal,
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
                  child: state.currentStep == 0
                      ? _buildConfigPage(
                          key: const ValueKey('step0'),
                          state: state,
                          notifier: notifier,
                          localizations: localizations,
                        )
                      : LoseRuleSelector(
                          key: const ValueKey('step1'),
                          selectedRule: state.loseRule,
                          onRuleSelected: notifier.setLoseRule,
                          onStartGame: () =>
                              _startGame(context, state, notifier),
                          playerCount: state.playerCount,
                          genderMix: state.genderMix,
                          relationship: state.relationship,
                          location: state.location,
                        ),
                ),
              ),

              // Navigation button (only on step 0)
              if (state.currentStep == 0)
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: GradientButton(
                    text: localizations.next,
                    icon: Icons.arrow_forward,
                    onPressed: state.canProceedToStep2
                        ? () {
                            HapticFeedback.selectionClick();
                            notifier.nextStep();
                          }
                        : () {},
                    gradient: state.canProceedToStep2
                        ? AppTheme.primaryGradient
                        : LinearGradient(
                            colors: [
                              AppTheme.cardBackground.withOpacity(0.5),
                              AppTheme.cardBackgroundLight.withOpacity(0.5),
                            ],
                          ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// All-in-one config page: player count, gender, relationship, location
  Widget _buildConfigPage({
    Key? key,
    required GameSetupState state,
    required GameSetupNotifier notifier,
    required AppLocalizations localizations,
  }) {
    return SingleChildScrollView(
      key: key,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Player count section
          _SectionHeader(
            icon: Icons.people,
            label: localizations.howManyPlayers,
          ),
          const SizedBox(height: AppTheme.spacingM),
          _CompactPlayerCount(
            selectedCount: state.playerCount,
            onCountSelected: notifier.setPlayerCount,
          ),

          const SizedBox(height: AppTheme.spacingXL),

          // Gender section
          _SectionHeader(
            icon: Icons.wc,
            label: localizations.genderMix,
          ),
          const SizedBox(height: AppTheme.spacingM),
          _CompactChipRow(
            options: [
              ('boys', localizations.boysOnly, Icons.male),
              ('girls', localizations.girlsOnly, Icons.female),
              ('mixed', localizations.mixedGroup, Icons.people),
            ],
            selected: state.genderMix,
            onSelected: notifier.setGenderMix,
          ),

          const SizedBox(height: AppTheme.spacingXL),

          // Relationship section
          _SectionHeader(
            icon: Icons.favorite,
            label: localizations.relationship,
          ),
          const SizedBox(height: AppTheme.spacingM),
          _CompactChipRow(
            options: [
              ('friends', '👥 ${localizations.friends}', null),
              ('family', '👨‍👩‍👧‍👦 ${localizations.family}', null),
              ('couple', '💑 ${localizations.couple}', null),
              ('colleagues', '👔 ${localizations.colleagues}', null),
              ('classmates', '🎓 ${localizations.classmates}', null),
            ],
            selected: state.relationship,
            onSelected: notifier.setRelationship,
          ),

          const SizedBox(height: AppTheme.spacingXL),

          // Location section
          _SectionHeader(
            icon: Icons.location_on,
            label: localizations.location,
          ),
          const SizedBox(height: AppTheme.spacingM),
          _CompactChipRow(
            options: [
              ('home', localizations.home, Icons.home_rounded),
              ('college', localizations.college, Icons.school_rounded),
              ('public', localizations.publicPlace, Icons.public_rounded),
              ('party', localizations.party, Icons.celebration_rounded),
            ],
            selected: state.location,
            onSelected: notifier.setLocation,
          ),

          const SizedBox(height: AppTheme.spacingL),
        ],
      ),
    );
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
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ChooserScreenUltra(
          filterCriteria: criteria,
          loseRule: gameSetup.loseRule,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: AppDurations.normal,
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

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryStart, size: 20),
        const SizedBox(width: AppTheme.spacingS),
        Text(label, style: AppTheme.headingS),
      ],
    );
  }
}

class _CompactPlayerCount extends StatelessWidget {
  final int? selectedCount;
  final ValueChanged<int> onCountSelected;

  const _CompactPlayerCount({
    required this.selectedCount,
    required this.onCountSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppTheme.spacingS,
      runSpacing: AppTheme.spacingS,
      children: List.generate(9, (index) {
        final count = index + 2;
        final isSelected = selectedCount == count;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onCountSelected(count);
          },
          child: AnimatedContainer(
            duration: AppDurations.fast,
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: isSelected ? AppTheme.primaryGradient : null,
              color: isSelected ? null : AppTheme.cardBackground.withOpacity(0.6),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryStart
                    : Colors.white.withOpacity(0.1),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(
                '$count',
                style: AppTheme.headingS.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _CompactChipRow extends StatelessWidget {
  final List<(String value, String label, IconData? icon)> options;
  final String? selected;
  final ValueChanged<String> onSelected;

  const _CompactChipRow({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppTheme.spacingS,
      runSpacing: AppTheme.spacingS,
      children: options.map((option) {
        final (value, label, icon) = option;
        final isSelected = selected == value;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onSelected(value);
          },
          child: AnimatedContainer(
            duration: AppDurations.fast,
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingS + 4,
            ),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        AppTheme.primaryStart.withOpacity(0.3),
                        AppTheme.primaryEnd.withOpacity(0.2),
                      ],
                    )
                  : null,
              color: isSelected ? null : AppTheme.cardBackground.withOpacity(0.6),
              borderRadius: BorderRadius.circular(AppTheme.radiusXL),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryStart.withOpacity(0.5)
                    : Colors.white.withOpacity(0.1),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 18,
                    color: isSelected ? AppTheme.primaryStart : AppTheme.textSecondary,
                  ),
                  const SizedBox(width: AppTheme.spacingXS),
                ],
                Text(
                  label,
                  style: AppTheme.bodyM.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
