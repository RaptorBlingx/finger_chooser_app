// lib/services/dare_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle; // For loading assets
import 'package:firebase_remote_config/firebase_remote_config.dart'; // Added
import '../models/dare_model.dart';
import '../models/filter_criteria_model.dart';

class DareService {
  List<Dare>? _cachedCoreDares;
  final Random _random = Random();
  FirebaseRemoteConfig? _remoteConfig; // Added
  bool _isRemoteConfigInitialized = false; // Flag to ensure init runs once

  static const String _remoteConfigKeyDares = 'core_dares_json';

  // Initialize Remote Config and set defaults
  Future<void> _initializeRemoteConfig() async {
    if (_isRemoteConfigInitialized) return;

    _remoteConfig = FirebaseRemoteConfig.instance;

    // Load default values from local asset
    String localDaresJsonString = "[]"; // Default to empty list if asset load fails
    try {
      localDaresJsonString = await rootBundle.loadString('assets/dares/core_dares.json');
    } catch (e) {
      print('Error loading local dares for Remote Config defaults: $e');
    }

    await _remoteConfig!.setDefaults({
      _remoteConfigKeyDares: localDaresJsonString,
    });

    // Attempt to fetch and activate
    try {
      await _remoteConfig!.fetchAndActivate();
      print('Remote Config fetched and activated.');
    } catch (e) {
      print('Error fetching or activating Remote Config: $e. Defaults will be used.');
    }
    _isRemoteConfigInitialized = true;
  }

  Future<List<Dare>> _parseDares(String jsonString) {
    try {
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      final List<Dare> dares = jsonList.map((jsonItem) {
        return Dare.fromJson(jsonItem as Map<String, dynamic>);
      }).toList();
      return Future.value(dares);
    } catch (e) {
      print('Error parsing dares JSON: $e');
      return Future.value([]); // Return empty list on parsing error
    }
  }

  Future<List<Dare>> _loadCoreDaresIfNeeded() async {
    if (_cachedCoreDares != null) {
      return _cachedCoreDares!;
    }

    await _initializeRemoteConfig(); // Ensure Remote Config is initialized

    String daresJsonString;
    bool loadedFromRemote = false;

    if (_remoteConfig != null) {
      daresJsonString = _remoteConfig!.getString(_remoteConfigKeyDares);
      if (daresJsonString.isNotEmpty && daresJsonString != "[]") { // Check if not empty or default empty
        print('Loading dares from Firebase Remote Config.');
        loadedFromRemote = true;
      } else {
        // Fallback if Remote Config string is empty or still the initial "[]" default (if asset loading failed during setDefaults)
        print('Remote Config dares string is empty or default. Falling back to local asset.');
        daresJsonString = await rootBundle.loadString('assets/dares/core_dares.json');
      }
    } else {
      // Should not happen if _initializeRemoteConfig was awaited
      print('Remote Config instance is null. Falling back to local asset.');
      daresJsonString = await rootBundle.loadString('assets/dares/core_dares.json');
    }
    
    _cachedCoreDares = await _parseDares(daresJsonString);
    if (loadedFromRemote && _cachedCoreDares!.isEmpty) {
        // If remote config was supposed to be used but parsing failed or it was empty JSON array,
        // this could be an indication of bad remote data.
        // For robustness, one might consider a final fallback to local assets here too.
        print('Warning: Loaded from Remote Config but resulted in empty dare list. Check Remote Config data format.');
    }
    return _cachedCoreDares!;
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
