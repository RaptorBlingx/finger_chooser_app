import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';

class RelationshipSelector extends StatelessWidget {
  final String? selectedRelationship;
  final ValueChanged<String> onRelationshipSelected;

  const RelationshipSelector({
    super.key,
    this.selectedRelationship,
    required this.onRelationshipSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final options = [
      ('👥', l10n.friends, 'friends'),
      ('👨‍👩‍👧‍👦', l10n.family, 'family'),
      ('💑', l10n.couple, 'couple'),
      ('👔', l10n.colleagues, 'colleagues'),
      ('🎓', l10n.classmates, 'classmates'),
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.relationship,
          style: AppTheme.headingL,
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: AppTheme.spacingXL),
        Wrap(
          spacing: AppTheme.spacingM,
          runSpacing: AppTheme.spacingM,
          alignment: WrapAlignment.center,
          children: options.asMap().entries.map((entry) {
            final (emoji, label, value) = entry.value;
            final isSelected = selectedRelationship == value;
            return _RelationshipChip(
              label: '$emoji $label',
              isSelected: isSelected,
              onTap: () {
                HapticFeedback.selectionClick();
                onRelationshipSelected(value);
              },
            ).animate().fadeIn(
                  delay: Duration(milliseconds: 100 * entry.key),
                  duration: 300.ms,
                );
          }).toList(),
        ),
      ],
    );
  }
}

class _RelationshipChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RelationshipChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingL,
          vertical: AppTheme.spacingM,
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
        child: Text(
          label,
          style: AppTheme.bodyL.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
