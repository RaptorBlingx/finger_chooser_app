// lib/models/filter_criteria_model.dart
import 'package:flutter/foundation.dart';

@immutable
class FilterCriteria {
  final int? playerCount;
  final List<String>? groupTypes; // e.g., ["friends", "family"]
  final List<String>? places;     // e.g., ["home", "public"]
  final List<String>? genders;    // e.g., ["boys", "girls", "mixed"]
  final List<String>? intensities; // e.g., ["mild", "spicy"]
  // Add other criteria as needed from your Dare model

  const FilterCriteria({
    this.playerCount,
    this.groupTypes,
    this.places,
    this.genders,
    this.intensities,
  });

  // You can add a method to check if any criteria are set
  bool get isNotEmpty =>
      playerCount != null ||
      (groupTypes != null && groupTypes!.isNotEmpty) ||
      (places != null && places!.isNotEmpty) ||
      (genders != null && genders!.isNotEmpty) ||
      (intensities != null && intensities!.isNotEmpty);
}