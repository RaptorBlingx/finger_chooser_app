// lib/models/finger_model.dart
import 'package:flutter/material.dart'; // For Offset and Color

class Finger {
  final int id; // The unique pointer ID
  Offset position;
  final Color color; 

  Finger({
    required this.id,
    required this.position,
    required this.color,
  });

  // Optional: Add copyWith for easier state updates if Finger becomes more complex
  // This is used in ChooserStateNotifier
  Finger copyWith({
    int? id,
    Offset? position,
    Color? color,
  }) {
    return Finger(
      id: id ?? this.id,
      position: position ?? this.position,
      color: color ?? this.color,
    );
  }

  // Optional: For debugging or if you need to compare Finger objects
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Finger &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}