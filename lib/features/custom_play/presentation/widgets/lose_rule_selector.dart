import 'package:flutter/material.dart';

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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Who does the dare?',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 32),
        _RuleOption(
          icon: Icons.first_page,
          label: 'First to Remove',
          subtitle: 'First one to lift their finger loses',
          value: 'first',
          isSelected: selectedRule == 'first',
          onTap: () => onRuleSelected('first'),
        ),
        const SizedBox(height: 16),
        _RuleOption(
          icon: Icons.last_page,
          label: 'Last Standing',
          subtitle: 'Last one remaining loses',
          value: 'last',
          isSelected: selectedRule == 'last',
          onTap: () => onRuleSelected('last'),
        ),
        const SizedBox(height: 32),
        if (selectedRule != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📋 Game Summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _SummaryRow(
                  icon: Icons.people,
                  label: 'Players',
                  value: '$playerCount',
                ),
                _SummaryRow(
                  icon: Icons.wc,
                  label: 'Gender',
                  value: _formatGender(genderMix),
                ),
                _SummaryRow(
                  icon: Icons.favorite,
                  label: 'Relationship',
                  value: _capitalize(relationship),
                ),
                _SummaryRow(
                  icon: Icons.location_on,
                  label: 'Location',
                  value: _capitalize(location),
                ),
                _SummaryRow(
                  icon: Icons.emoji_events,
                  label: 'Rule',
                  value: selectedRule == 'first'
                      ? 'First to Remove'
                      : 'Last Standing',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onStartGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.purple,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'START GAME',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 24),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _formatGender(String? gender) {
    if (gender == null) return '';
    switch (gender) {
      case 'boys':
        return 'Boys Only';
      case 'girls':
        return 'Girls Only';
      case 'mixed':
        return 'Mixed';
      default:
        return gender;
    }
  }

  String _capitalize(String? text) {
    if (text == null || text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }
}

class _RuleOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _RuleOption({
    required this.icon,
    required this.label,
    required this.subtitle,
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
        padding: const EdgeInsets.all(20),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.purple : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected
                          ? Colors.purple.withOpacity(0.7)
                          : Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
