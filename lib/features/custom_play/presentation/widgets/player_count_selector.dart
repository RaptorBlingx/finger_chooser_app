import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';

class PlayerCountSelector extends StatelessWidget {
  final int? selectedCount;
  final ValueChanged<int> onCountSelected;

  const PlayerCountSelector({
    super.key,
    this.selectedCount,
    required this.onCountSelected,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          localizations.howManyPlayers,
          style: AppTheme.headingL,
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: AppTheme.spacingXL),
        Wrap(
          spacing: AppTheme.spacingM,
          runSpacing: AppTheme.spacingM,
          alignment: WrapAlignment.center,
          children: List.generate(9, (index) {
            final count = index + 2;
            final isSelected = selectedCount == count;

            return _PlayerCountButton(
              count: count,
              isSelected: isSelected,
              onTap: () {
                HapticFeedback.selectionClick();
                onCountSelected(count);
              },
            ).animate().fadeIn(
                  delay: Duration(milliseconds: 50 * index),
                  duration: 300.ms,
                );
          }),
        ),
      ],
    );
  }
}

class _PlayerCountButton extends StatelessWidget {
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlayerCountButton({
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected ? null : AppTheme.cardBackground.withOpacity(0.6),
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryStart
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppTheme.buttonShadow : null,
        ),
        child: Center(
          child: Text(
            '$count',
            style: AppTheme.headingM.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
