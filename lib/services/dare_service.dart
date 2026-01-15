// lib/services/dare_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
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

    // Apply filtering if criteria is provided
    if (criteria != null && criteria.isNotEmpty) {
      suitableDares = _filterDaresByCriteria(allDares, criteria);
      
      // If no exact matches, try progressive fallback
      if (suitableDares.isEmpty) {
        suitableDares = _fallbackFiltering(allDares, criteria);
      }

      // Log filtering stats
      _logFilteringStats(allDares.length, suitableDares.length, criteria);
    }

    // Always return a dare (fallback to all if needed)
    if (suitableDares.isEmpty) {
      debugPrint("No suitable dares found even after fallback. Using all dares.");
      suitableDares = allDares;
    }

    return suitableDares[_random.nextInt(suitableDares.length)];
  }

  /// Filters dares based on the provided criteria.
  /// Returns matching dares or empty list if none match.
  List<Dare> _filterDaresByCriteria(List<Dare> dares, FilterCriteria criteria) {
    return dares.where((dare) => _matchesCriteria(dare, criteria)).toList();
  }

  /// Checks if a single dare matches the filter criteria.
  bool _matchesCriteria(Dare dare, FilterCriteria criteria) {
    // Player Count Filter
    if (criteria.playerCount != null) {
      if (criteria.playerCount! < dare.minPlayers) {
        return false;
      }
      if (dare.maxPlayers != null && criteria.playerCount! > dare.maxPlayers!) {
        return false;
      }
    }

    // Group Type Filter - checks if any of dare's groupTypes are in criteria.groupTypes
    if (criteria.groupTypes != null && criteria.groupTypes!.isNotEmpty) {
      if (!dare.groupType.any((type) => criteria.groupTypes!.contains(type))) {
        return false;
      }
    }

    // Place Filter - checks if dare supports 'any' place or matches criteria
    if (criteria.places != null && criteria.places!.isNotEmpty) {
      if (!dare.place.any((p) => p == 'any' || criteria.places!.contains(p))) {
        return false;
      }
    }

    // Gender Filter - checks if any of dare's genders match criteria
    if (criteria.genders != null && criteria.genders!.isNotEmpty) {
      if (!dare.gender.any((g) => criteria.genders!.contains(g))) {
        return false;
      }
    }

    // Intensity Filter - checks if dare's intensity level is in criteria
    if (criteria.intensities != null && criteria.intensities!.isNotEmpty) {
      if (!criteria.intensities!.contains(dare.intensity)) {
        return false;
      }
    }

    return true;
  }

  /// Progressive fallback filtering - relaxes constraints step by step
  /// Priority: Keep player count & group type, relax place, then gender
  List<Dare> _fallbackFiltering(List<Dare> dares, FilterCriteria criteria) {
    debugPrint("Applying fallback filtering...");

    // Level 1: Relax place constraint (keep player count, group, gender)
    var fallback = dares.where((dare) {
      return _matchesCriteria(
        dare,
        FilterCriteria(
          playerCount: criteria.playerCount,
          groupTypes: criteria.groupTypes,
          genders: criteria.genders,
          // places: null, // Relaxed
          intensities: criteria.intensities,
        ),
      );
    }).toList();

    if (fallback.isNotEmpty) {
      debugPrint("Fallback Level 1 (relaxed place): Found ${fallback.length} dares");
      return fallback;
    }

    // Level 2: Relax gender constraint (keep player count, group)
    fallback = dares.where((dare) {
      return _matchesCriteria(
        dare,
        FilterCriteria(
          playerCount: criteria.playerCount,
          groupTypes: criteria.groupTypes,
          // genders: null, // Relaxed
          // places: null, // Relaxed
          intensities: criteria.intensities,
        ),
      );
    }).toList();

    if (fallback.isNotEmpty) {
      debugPrint("Fallback Level 2 (relaxed gender & place): Found ${fallback.length} dares");
      return fallback;
    }

    // Level 3: Keep only player count
    fallback = dares.where((dare) {
      return _matchesCriteria(
        dare,
        FilterCriteria(
          playerCount: criteria.playerCount,
          // All other constraints relaxed
        ),
      );
    }).toList();

    if (fallback.isNotEmpty) {
      debugPrint("Fallback Level 3 (player count only): Found ${fallback.length} dares");
      return fallback;
    }

    // Level 4: Use dares that support 'any' location
    fallback = dares.where((dare) => dare.place.contains('any')).toList();
    
    if (fallback.isNotEmpty) {
      debugPrint("Fallback Level 4 (any location dares): Found ${fallback.length} dares");
      return fallback;
    }

    return []; // Return empty, caller will use all dares
  }

  /// Logs filtering statistics to Firebase Analytics
  void _logFilteringStats(int totalDares, int matchingDares, FilterCriteria criteria) {
    FirebaseAnalytics.instance.logEvent(
      name: 'dare_filtering_applied',
      parameters: {
        'total_dares': totalDares,
        'matching_dares': matchingDares,
        'filter_success': matchingDares > 0,
        'player_count': criteria.playerCount ?? 0,
        'has_group_filter': criteria.groupTypes?.isNotEmpty ?? false,
        'has_place_filter': criteria.places?.isNotEmpty ?? false,
        'has_gender_filter': criteria.genders?.isNotEmpty ?? false,
      },
    );
  }
}
