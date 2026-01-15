import 'package:flutter/material.dart';

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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Where are you playing?',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 32),
        _LocationOption(
          icon: Icons.home,
          label: 'Home',
          value: 'home',
          isSelected: selectedLocation == 'home',
          onTap: () => onLocationSelected('home'),
        ),
        const SizedBox(height: 16),
        _LocationOption(
          icon: Icons.school,
          label: 'College/School',
          value: 'college',
          isSelected: selectedLocation == 'college',
          onTap: () => onLocationSelected('college'),
        ),
        const SizedBox(height: 16),
        _LocationOption(
          icon: Icons.public,
          label: 'Public Place',
          value: 'public',
          isSelected: selectedLocation == 'public',
          onTap: () => onLocationSelected('public'),
        ),
        const SizedBox(height: 16),
        _LocationOption(
          icon: Icons.celebration,
          label: 'Party/Event',
          value: 'party',
          isSelected: selectedLocation == 'party',
          onTap: () => onLocationSelected('party'),
        ),
      ],
    );
  }
}

class _LocationOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _LocationOption({
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
