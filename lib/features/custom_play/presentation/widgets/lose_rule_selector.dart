import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_button.dart';

class LoseRuleSelector extends StatelessWidget {
  final String? selectedRule;
  final ValueChanged<String> onRuleSelected;
  final VoidCallback onStartGame;
  final int? playerCount;
  final String? genderMix;
  final String? relationship;
  final String? location;

  const LoseRuleSelector({
    super.key,
    this.selectedRule,
    required this.onRuleSelected,
    required this.onStartGame,
    this.playerCount,
    this.genderMix,
    this.relationship,
    this.location,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.loseRule,
            style: AppTheme.headingL,
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: AppTheme.spacingXL),
          _RuleOption(
            icon: Icons.first_page,
            label: l10n.firstChosen,
            subtitle: selectedRule == 'first' ? '✓' : '',
            isSelected: selectedRule == 'first',
            onTap: () {
              HapticFeedback.selectionClick();
              onRuleSelected('first');
            },
          ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1, end: 0),
          const SizedBox(height: AppTheme.spacingM),
          _RuleOption(
            icon: Icons.last_page,
            label: l10n.lastRemaining,
            subtitle: selectedRule == 'last' ? '✓' : '',
            isSelected: selectedRule == 'last',
            onTap: () {
              HapticFeedback.selectionClick();
              onRuleSelected('last');
            },
          ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1, end: 0),
          const SizedBox(height: AppTheme.spacingXL),
          if (selectedRule != null) ...[
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.summarize, color: AppTheme.info, size: 20),
                      const SizedBox(width: AppTheme.spacingS),
                      Text(l10n.gameSummary, style: AppTheme.headingS),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  _SummaryRow(
                    icon: Icons.people,
                    label: l10n.players,
                    value: '$playerCount',
                  ),
                  _SummaryRow(
                    icon: Icons.wc,
                    label: l10n.genderMix,
                    value: _formatGender(l10n, genderMix),
                  ),
                  _SummaryRow(
                    icon: Icons.favorite,
                    label: l10n.relationship,
                    value: _formatRelationship(l10n, relationship),
                  ),
                  _SummaryRow(
                    icon: Icons.location_on,
                    label: l10n.location,
                    value: _formatLocation(l10n, location),
                  ),
                  _SummaryRow(
                    icon: Icons.emoji_events,
                    label: l10n.loseRule,
                    value: selectedRule == 'first'
                        ? l10n.firstChosen
                        : l10n.lastRemaining,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1.0, 1.0),
                ),
            const SizedBox(height: AppTheme.spacingXL),
            GradientButton(
              text: l10n.startGame,
              icon: Icons.play_arrow,
              onPressed: () {
                HapticFeedback.heavyImpact();
                onStartGame();
              },
              gradient: AppTheme.primaryGradient,
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3, end: 0),
          ],
        ],
      ),
    );
  }

  String _formatGender(AppLocalizations l10n, String? gender) {
    switch (gender) {
      case 'boys': return l10n.boysOnly;
      case 'girls': return l10n.girlsOnly;
      case 'mixed': return l10n.mixedGroup;
      default: return '';
    }
  }

  String _formatRelationship(AppLocalizations l10n, String? rel) {
    switch (rel) {
      case 'friends': return l10n.friends;
      case 'family': return l10n.family;
      case 'couple': return l10n.couple;
      case 'colleagues': return l10n.colleagues;
      case 'classmates': return l10n.classmates;
      default: return '';
    }
  }

  String _formatLocation(AppLocalizations l10n, String? loc) {
    switch (loc) {
      case 'home': return l10n.home;
      case 'college': return l10n.college;
      case 'public': return l10n.publicPlace;
      case 'party': return l10n.party;
      default: return '';
    }
  }
}

class _RuleOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _RuleOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.spacingL),
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
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryStart.withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppTheme.primaryStart : AppTheme.textSecondary,
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Text(
                label,
                style: AppTheme.headingS.copyWith(
                  color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.success, size: 24),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXS),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.textTertiary),
          const SizedBox(width: AppTheme.spacingS),
          Text(
            '$label:',
            style: AppTheme.bodyS,
          ),
          const SizedBox(width: AppTheme.spacingS),
          Text(
            value,
            style: AppTheme.bodyM.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
