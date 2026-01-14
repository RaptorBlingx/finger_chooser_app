// lib/services/dare_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../models/dare_model.dart';
import '../models/filter_criteria_model.dart';


class DareService {
  // Cache for loaded dares to avoid reloading from JSON every time
  List<Dare>? _cachedCoreDares;
  final Random _random = Random();

  /// Instance of Firebase Remote Config.
  FirebaseRemoteConfig? _remoteConfig;
  /// Flag to track if Remote Config has been initialized.
  bool _isRemoteConfigInitialized = false;

  /// Key used for fetching the dares JSON string from Firebase Remote Config.
  static const String _remoteConfigKeyDares = 'core_dares_json';

  /// Initializes Firebase Remote Config.
  ///
  /// Sets default values (from local `core_dares.json` asset) and then
  /// attempts to fetch and activate the latest configuration from the Firebase backend.
  /// This method is called lazily when dares are first requested.
  Future<void> _initializeRemoteConfig() async {
    if (_isRemoteConfigInitialized) return;

    _remoteConfig = FirebaseRemoteConfig.instance;

    // Load default values from local asset
    String localDaresJsonString = "[]"; // Default to empty list if asset load fails
    try {
      localDaresJsonString = await rootBundle.loadString('assets/dares/core_dares.json');
    } catch (e) {
      debugPrint('Error loading local dares for Remote Config defaults: $e');
    }

    await _remoteConfig!.setDefaults({
      _remoteConfigKeyDares: localDaresJsonString,
    });

    // Attempt to fetch and activate
    try {
      await _remoteConfig!.fetchAndActivate();
      debugPrint('Remote Config fetched and activated.');
    } catch (e) {
      debugPrint('Error fetching or activating Remote Config: $e. Defaults will be used.');
    }
    _isRemoteConfigInitialized = true;
  }

  /// Parses a JSON string containing a list of dares into a `List<Dare>`.
  ///
  /// - [jsonString]: The JSON string to parse.
  /// Returns a list of [Dare] objects. Returns an empty list if parsing fails.
  Future<List<Dare>> _parseDares(String jsonString) {
    try {
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      final List<Dare> dares = jsonList.map((jsonItem) {
        return Dare.fromJson(jsonItem as Map<String, dynamic>);
      }).toList();
      return Future.value(dares);
    } catch (e) {
      debugPrint('Error parsing dares JSON: $e');
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
        debugPrint('Loading dares from Firebase Remote Config.');
        loadedFromRemote = true;
      } else {
        // Fallback if Remote Config string is empty or still the initial "[]" default (if asset loading failed during setDefaults)
        debugPrint('Remote Config dares string is empty or default. Falling back to local asset.');
        daresJsonString = await rootBundle.loadString('assets/dares/core_dares.json');
      }
    } else {
      // Should not happen if _initializeRemoteConfig was awaited
      debugPrint('Remote Config instance is null. Falling back to local asset.');
      daresJsonString = await rootBundle.loadString('assets/dares/core_dares.json');
    }

    _cachedCoreDares = await _parseDares(daresJsonString);
    if (loadedFromRemote && _cachedCoreDares!.isEmpty) {
        // If remote config was supposed to be used but parsing failed or it was empty JSON array,
        // this could be an indication of bad remote data.
        // For robustness, one might consider a final fallback to local assets here too.
        debugPrint('Warning: Loaded from Remote Config but resulted in empty dare list. Check Remote Config data format.');
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

        // Group Type Filter - checks if any of dare's groupTypes are in criteria.groupTypes
        if (criteria.groupTypes != null && criteria.groupTypes!.isNotEmpty) {
          if (!dare.groupType.any((gt) => criteria.groupTypes!.contains(gt))) {
            matches = false;
          }
        }

        // Place Filter - checks if any of dare's places match criteria or if dare supports 'any' place
        if (criteria.places != null && criteria.places!.isNotEmpty) {
          if (!dare.place.contains('any') && !dare.place.any((p) => criteria.places!.contains(p))) {
            matches = false;
          }
        }

        // Gender Filter - checks if any of dare's genders match criteria
        if (criteria.genders != null && criteria.genders!.isNotEmpty) {
          if (!dare.gender.any((g) => criteria.genders!.contains(g))) {
            matches = false;
          }
        }

        // Intensity Filter - checks if dare's intensity level is in criteria
        if (criteria.intensities != null && criteria.intensities!.isNotEmpty) {
          if (!criteria.intensities!.contains(dare.intensity)) {
            matches = false;
          }
        }

        return matches;
      }).toList();
    }

    if (suitableDares.isEmpty) {
      // No dares match the criteria - fallback to a random dare from all dares
      // This ensures the game never fails due to overly restrictive filtering
      debugPrint("No suitable dares found for criteria. Using fallback to all dares.");
      return allDares[_random.nextInt(allDares.length)];
    }

    return suitableDares[_random.nextInt(suitableDares.length)];
  }
}
