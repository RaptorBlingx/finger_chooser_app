// lib/models/dare_model.dart
import 'package:flutter/foundation.dart'; // For @required and immutable

@immutable
class Dare {
  final String id;
  final String textEn;
  final String? textAr; // Optional for now
  final List<String> groupType; // e.g., ["friends", "family", "couple"]
  final List<String> place;     // e.g., ["home", "public", "college"]
  final List<String> gender;    // e.g., ["boys", "girls", "mixed"]
  final String intensity;       // e.g., "mild", "spicy", "wild"
  final int minPlayers;
  final int? maxPlayers;        // Max players can be optional (e.g., for 2+ players)

  const Dare({
    required this.id,
    required this.textEn,
    this.textAr,
    required this.groupType,
    required this.place,
    required this.gender,
    required this.intensity,
    required this.minPlayers,
    this.maxPlayers,
  });

  // Factory constructor to create a Dare from JSON
  factory Dare.fromJson(Map<String, dynamic> json) {
    return Dare(
      id: json['id'] as String,
      textEn: json['text_en'] as String,
      textAr: json['text_ar'] as String?,
      // Ensure lists are correctly parsed from JSON (List<dynamic> to List<String>)
      groupType: List<String>.from(json['groupType'] as List<dynamic>),
      place: List<String>.from(json['place'] as List<dynamic>),
      gender: List<String>.from(json['gender'] as List<dynamic>),
      intensity: json['intensity'] as String,
      minPlayers: json['minPlayers'] as int,
      maxPlayers: json['maxPlayers'] as int?,
    );
  }

  // Method to convert a Dare instance to JSON (useful for Firestore later)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text_en': textEn,
      'text_ar': textAr,
      'groupType': groupType,
      'place': place,
      'gender': gender,
      'intensity': intensity,
      'minPlayers': minPlayers,
      'maxPlayers': maxPlayers,
    };
  }
}