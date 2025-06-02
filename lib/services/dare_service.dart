// lib/services/dare_service.dart
import 'dart:convert';
import 'dart:math'; 
import 'package:flutter/services.dart' show rootBundle; // For loading assets
import '../models/dare_model.dart';
import '../models/filter_criteria_model.dart';


class DareService {
  // Cache for loaded dares to avoid reloading from JSON every time
  List<Dare>? _cachedCoreDares;
    final Random _random = Random(); // For selecting a random dare

  Future<List<Dare>> _loadCoreDaresIfNeeded() async {
    if (_cachedCoreDares != null) {
      return _cachedCoreDares!;
    }
    try {
      final String jsonString = await rootBundle.loadString('assets/dares/core_dares.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      final List<Dare> dares = jsonList.map((jsonItem) {
        return Dare.fromJson(jsonItem as Map<String, dynamic>);
      }).toList();
      _cachedCoreDares = dares;
      return dares;
    } catch (e) {
      print('Error loading core dares: $e');
      return [];
    }
  }


  // Method to get a single random dare, potentially filtered
  Future<Dare?> getRandomDare({FilterCriteria? criteria}) async {
    final allDares = await _loadCoreDaresIfNeeded();
    if (allDares.isEmpty) return null;

    List<Dare> suitableDares = allDares;

    if (criteria != null && criteria.isNotEmpty) {
      suitableDares = allDares.where((dare) {
        bool matches = true;

        // Player Count Filter (example)
        if (criteria.playerCount != null) {
          if (dare.minPlayers > criteria.playerCount!) {
            matches = false;
          }
          if (dare.maxPlayers != null && dare.maxPlayers! < criteria.playerCount!) {
            matches = false;
          }
        }

        // Group Type Filter (example - checks if any of dare's groupTypes are in criteria.groupTypes)
        if (criteria.groupTypes != null && criteria.groupTypes!.isNotEmpty) {
          if (!dare.groupType.any((gt) => criteria.groupTypes!.contains(gt))) {
            matches = false;
          }
        }
        
        // TODO: Implement other filters similarly for place, gender, intensity
        // For place:
        // if (criteria.places != null && criteria.places!.isNotEmpty) {
        //   if (!dare.place.any((p) => criteria.places!.contains(p))) {
        //     matches = false;
        //   }
        // }

        // For gender:
        // if (criteria.genders != null && criteria.genders!.isNotEmpty) {
        //   if (!dare.gender.any((g) => criteria.genders!.contains(g))) {
        //     matches = false;
        //   }
        // }
        
        // For intensity:
        // if (criteria.intensities != null && criteria.intensities!.isNotEmpty) {
        //   if (!criteria.intensities!.contains(dare.intensity)) {
        //     matches = false;
        //   }
        // }

        return matches;
      }).toList();
    }

    if (suitableDares.isEmpty) {
      // No dares match the criteria, what to do?
      // Option 1: Return null (as done here)
      // Option 2: Return a random dare from the original list as a fallback
      // Option 3: Return a specific "fallback" dare
      print("No suitable dares found for criteria. Consider fallback.");
      return null; 
    }

    return suitableDares[_random.nextInt(suitableDares.length)];
  }
}
