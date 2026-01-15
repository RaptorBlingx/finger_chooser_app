import 'package:flutter/material.dart';

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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'What\'s your relationship?',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            _RelationshipChip(
              label: '👥 Friends',
              value: 'friends',
              isSelected: selectedRelationship == 'friends',
              onTap: () => onRelationshipSelected('friends'),
            ),
            _RelationshipChip(
              label: '👨‍👩‍👧‍👦 Family',
              value: 'family',
              isSelected: selectedRelationship == 'family',
              onTap: () => onRelationshipSelected('family'),
            ),
            _RelationshipChip(
              label: '💑 Couple',
              value: 'couple',
              isSelected: selectedRelationship == 'couple',
              onTap: () => onRelationshipSelected('couple'),
            ),
            _RelationshipChip(
              label: '👔 Colleagues',
              value: 'colleagues',
              isSelected: selectedRelationship == 'colleagues',
              onTap: () => onRelationshipSelected('colleagues'),
            ),
            _RelationshipChip(
              label: '🎓 Classmates',
              value: 'classmates',
              isSelected: selectedRelationship == 'classmates',
              onTap: () => onRelationshipSelected('classmates'),
            ),
          ],
        ),
      ],
    );
  }
}

class _RelationshipChip extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _RelationshipChip({
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.purple : Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.purple : Colors.white,
          ),
        ),
      ),
    );
  }
}
