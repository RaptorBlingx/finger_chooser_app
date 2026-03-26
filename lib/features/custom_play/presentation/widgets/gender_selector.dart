import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';

class GenderSelector extends StatelessWidget {
  final String? selectedGender;
  final ValueChanged<String> onGenderSelected;

  const GenderSelector({
    super.key,
    this.selectedGender,
    required this.onGenderSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.genderMix,
          style: AppTheme.headingL,
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: AppTheme.spacingXL),
        _GenderOption(
          icon: Icons.male,
          label: l10n.boysOnly,
          value: 'boys',
          isSelected: selectedGender == 'boys',
          onTap: () {
            HapticFeedback.selectionClick();
            onGenderSelected('boys');
          },
        ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1, end: 0),
        const SizedBox(height: AppTheme.spacingM),
        _GenderOption(
          icon: Icons.female,
          label: l10n.girlsOnly,
          value: 'girls',
          isSelected: selectedGender == 'girls',
          onTap: () {
            HapticFeedback.selectionClick();
            onGenderSelected('girls');
          },
        ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1, end: 0),
        const SizedBox(height: AppTheme.spacingM),
        _GenderOption(
          icon: Icons.people,
          label: l10n.mixedGroup,
          value: 'mixed',
          isSelected: selectedGender == 'mixed',
          onTap: () {
            HapticFeedback.selectionClick();
            onGenderSelected('mixed');
          },
        ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0),
      ],
    );
  }
}

class _GenderOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.icon,
    required this.label,
    required this.value,
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
        padding: const EdgeInsets.symmetric(
          vertical: AppTheme.spacingL,
          horizontal: AppTheme.spacingL,
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
            Text(
              label,
              style: AppTheme.headingS.copyWith(
                color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
