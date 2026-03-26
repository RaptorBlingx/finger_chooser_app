import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';

class LocationSelector extends StatelessWidget {
  final String? selectedLocation;
  final ValueChanged<String> onLocationSelected;

  const LocationSelector({
    super.key,
    this.selectedLocation,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final options = [
      (Icons.home_rounded, l10n.home, 'home'),
      (Icons.school_rounded, l10n.college, 'college'),
      (Icons.public_rounded, l10n.publicPlace, 'public'),
      (Icons.celebration_rounded, l10n.party, 'party'),
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.location,
          style: AppTheme.headingL,
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: AppTheme.spacingXL),
        ...options.asMap().entries.map((entry) {
          final (icon, label, value) = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
            child: _LocationOption(
              icon: icon,
              label: label,
              isSelected: selectedLocation == value,
              onTap: () {
                HapticFeedback.selectionClick();
                onLocationSelected(value);
              },
            ).animate().fadeIn(
                  delay: Duration(milliseconds: 100 * entry.key),
                  duration: 300.ms,
                ).slideX(begin: 0.1, end: 0),
          );
        }),
      ],
    );
  }
}

class _LocationOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LocationOption({
    required this.icon,
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
