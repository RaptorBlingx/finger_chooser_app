import 'package:flutter/foundation.dart';

/// Represents the complete game setup configuration from the wizard
@immutable
class GameSetup {
  final int playerCount;
  final String genderMix; // 'boys', 'girls', 'mixed'
  final String relationship; // 'friends', 'family', 'couple', etc.
  final String location; // 'home', 'college', 'public', 'party'
  final String loseRule; // 'first', 'last'

  const GameSetup({
    required this.playerCount,
    required this.genderMix,
    required this.relationship,
    required this.location,
    required this.loseRule,
  });

  GameSetup copyWith({
    int? playerCount,
    String? genderMix,
    String? relationship,
    String? location,
    String? loseRule,
  }) {
    return GameSetup(
      playerCount: playerCount ?? this.playerCount,
      genderMix: genderMix ?? this.genderMix,
      relationship: relationship ?? this.relationship,
      location: location ?? this.location,
      loseRule: loseRule ?? this.loseRule,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerCount': playerCount,
      'genderMix': genderMix,
      'relationship': relationship,
      'location': location,
      'loseRule': loseRule,
    };
  }

  @override
  String toString() {
    return 'GameSetup(playerCount: $playerCount, genderMix: $genderMix, relationship: $relationship, location: $location, loseRule: $loseRule)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GameSetup &&
        other.playerCount == playerCount &&
        other.genderMix == genderMix &&
        other.relationship == relationship &&
        other.location == location &&
        other.loseRule == loseRule;
  }

  @override
  int get hashCode {
    return playerCount.hashCode ^
        genderMix.hashCode ^
        relationship.hashCode ^
        location.hashCode ^
        loseRule.hashCode;
  }
}
