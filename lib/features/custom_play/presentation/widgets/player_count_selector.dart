import 'package:flutter/material.dart';

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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'How many players?',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: List.generate(9, (index) {
            final count = index + 2; // 2 to 10 players
            final isSelected = selectedCount == count;

            return _PlayerCountButton(
              count: count,
              isSelected: isSelected,
              onTap: () => onCountSelected(count),
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
        duration: const Duration(milliseconds: 200),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.purple : Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.purple : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
