import 'package:flutter/material.dart';

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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Gender Mix',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 32),
        _GenderOption(
          icon: Icons.male,
          label: 'Boys Only',
          value: 'boys',
          isSelected: selectedGender == 'boys',
          onTap: () => onGenderSelected('boys'),
        ),
        const SizedBox(height: 16),
        _GenderOption(
          icon: Icons.female,
          label: 'Girls Only',
          value: 'girls',
          isSelected: selectedGender == 'girls',
          onTap: () => onGenderSelected('girls'),
        ),
        const SizedBox(height: 16),
        _GenderOption(
          icon: Icons.people,
          label: 'Mixed Group',
          value: 'mixed',
          isSelected: selectedGender == 'mixed',
          onTap: () => onGenderSelected('mixed'),
        ),
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
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.purple : Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.purple : Colors.white,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.purple : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
