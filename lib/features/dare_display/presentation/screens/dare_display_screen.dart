// lib/features/dare_display/presentation/screens/dare_display_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../models/finger_model.dart';
import '../../../../models/dare_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_button.dart';

class DareDisplayScreen extends StatelessWidget {
  final Finger? selectedFinger;
  final Dare? selectedDare;
  final String? loseRule;

  const DareDisplayScreen({
    super.key,
    this.selectedFinger,
    this.selectedDare,
    this.loseRule,
  });

  static const String routeName = '/dare-display';

  Color _getIntensityColor(String? intensity) {
    switch (intensity) {
      case 'mild':
        return AppTheme.success;
      case 'spicy':
        return AppTheme.warning;
      case 'wild':
        return AppTheme.error;
      default:
        return AppTheme.info;
    }
  }

  String _getIntensityLabel(AppLocalizations l10n, String? intensity) {
    switch (intensity) {
      case 'mild':
        return l10n.dareIntensityMild;
      case 'spicy':
        return l10n.dareIntensitySpicy;
      case 'wild':
        return l10n.dareIntensityWild;
      default:
        return '';
    }
  }

  IconData _getIntensityIcon(String? intensity) {
    switch (intensity) {
      case 'mild':
        return Icons.sentiment_satisfied_alt;
      case 'spicy':
        return Icons.local_fire_department;
      case 'wild':
        return Icons.whatshot;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    final String dareText;
    if (selectedDare != null) {
      if (locale.languageCode == 'ar' &&
          selectedDare!.textAr != null &&
          selectedDare!.textAr!.isNotEmpty) {
        dareText = selectedDare!.textAr!;
      } else {
        dareText = selectedDare!.textEn;
      }
    } else {
      dareText = localizations.noDareFound;
    }

    final intensityColor = _getIntensityColor(selectedDare?.intensity);
    final intensityLabel = _getIntensityLabel(localizations, selectedDare?.intensity);
    final intensityIcon = _getIntensityIcon(selectedDare?.intensity);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.close, color: Colors.white),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              children: [
                const Spacer(flex: 1),

                // Finger winner indicator
                if (selectedFinger != null)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selectedFinger!.color,
                      boxShadow: [
                        BoxShadow(
                          color: selectedFinger!.color.withOpacity(0.6),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 40,
                    ),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.0, 0.0),
                        end: const Offset(1.0, 1.0),
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                      )
                      .then()
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(1.0, 1.0),
                        end: const Offset(1.08, 1.08),
                        duration: 1500.ms,
                      ),

                const SizedBox(height: AppTheme.spacingM),

                // "You've been chosen!" heading
                Text(
                  loseRule == 'last'
                      ? localizations.playerLastRemaining
                      : localizations.playerChosen,
                  style: AppTheme.headingL.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(
                      begin: 0.3,
                      end: 0,
                    ),

                const SizedBox(height: AppTheme.spacingXL),

                // Dare card
                GlassCard(
                  padding: const EdgeInsets.all(AppTheme.spacingXL),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Intensity badge
                      if (selectedDare != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingM,
                            vertical: AppTheme.spacingXS + 2,
                          ),
                          decoration: BoxDecoration(
                            color: intensityColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppTheme.radiusCircle),
                            border: Border.all(
                              color: intensityColor.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(intensityIcon, color: intensityColor, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                intensityLabel,
                                style: AppTheme.bodyS.copyWith(
                                  color: intensityColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: AppTheme.spacingL),

                      // "Your Dare" label
                      Text(
                        localizations.yourDare,
                        style: AppTheme.bodyS.copyWith(
                          color: AppTheme.textTertiary,
                          letterSpacing: 2,
                        ),
                      ),

                      const SizedBox(height: AppTheme.spacingM),

                      // Dare text
                      Directionality(
                        textDirection: locale.languageCode == 'ar'
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        child: Text(
                          dareText,
                          style: AppTheme.headingS.copyWith(
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 500.ms, duration: 800.ms).scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.0, 1.0),
                      curve: Curves.easeOutBack,
                    ),

                const Spacer(flex: 2),

                // Play Again button
                GradientButton(
                  text: localizations.playAgainNextRound,
                  icon: Icons.refresh,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.of(context).pop();
                  },
                  gradient: AppTheme.primaryGradient,
                ).animate().fadeIn(delay: 900.ms).slideY(
                      begin: 0.5,
                      end: 0,
                    ),

                const SizedBox(height: AppTheme.spacingL),
              ],
            ),
          ),
        ),
      ),
    );
  }
}