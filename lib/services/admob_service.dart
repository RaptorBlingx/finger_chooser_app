// lib/services/admob_service.dart
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for AdMob service singleton
final adMobServiceProvider = Provider<AdMobService>((ref) {
  return AdMobService();
});

/// Service to manage AdMob ads across the app
///
/// Handles initialization, ad unit IDs, and banner ad loading.
/// Uses test ad IDs for development - REPLACE with real IDs before production!
class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  bool _isInitialized = false;

  /// Initialize the Mobile Ads SDK
  /// Should be called once at app startup
  Future<void> initialize() async {
    if (_isInitialized) return;

    await MobileAds.instance.initialize();
    _isInitialized = true;
  }

  /// Get the appropriate banner ad unit ID for the current platform
  ///
  /// ⚠️ IMPORTANT: These are TEST ad unit IDs!
  /// Replace with your real AdMob ad unit IDs before publishing to production.
  /// Test IDs from: https://developers.google.com/admob/android/test-ads
  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      // TODO: Replace with your Android ad unit ID from AdMob console
      return 'ca-app-pub-3940256099942544/6300978111'; // Test banner ad unit ID
    } else if (Platform.isIOS) {
      // TODO: Replace with your iOS ad unit ID from AdMob console
      return 'ca-app-pub-3940256099942544/2934735716'; // Test banner ad unit ID
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// Get the appropriate interstitial ad unit ID for the current platform
  ///
  /// ⚠️ IMPORTANT: These are TEST ad unit IDs!
  /// Replace with your real AdMob ad unit IDs before publishing to production.
  String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      // TODO: Replace with your Android interstitial ad unit ID
      return 'ca-app-pub-3940256099942544/1033173712'; // Test interstitial ad unit ID
    } else if (Platform.isIOS) {
      // TODO: Replace with your iOS interstitial ad unit ID
      return 'ca-app-pub-3940256099942544/4411468910'; // Test interstitial ad unit ID
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// Create and load a banner ad
  ///
  /// Returns a configured BannerAd instance.
  /// Call `ad.load()` to start loading the ad.
  ///
  /// Example usage:
  /// ```dart
  /// final ad = adMobService.createBannerAd(
  ///   onAdLoaded: () => setState(() => _isBannerAdReady = true),
  ///   onAdFailedToLoad: (error) => print('Ad failed: $error'),
  /// );
  /// ad.load();
  /// ```
  BannerAd createBannerAd({
    required void Function(Ad ad) onAdLoaded,
    required void Function(Ad ad, LoadAdError error) onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner, // Standard 320x50 banner
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
        onAdOpened: (Ad ad) => print('Ad opened.'),
        onAdClosed: (Ad ad) => print('Ad closed.'),
      ),
    );
  }

  /// Load an interstitial ad
  ///
  /// Interstitial ads are full-screen ads shown at natural transition points.
  /// Common use cases: between game rounds, after completing an action.
  ///
  /// Example usage:
  /// ```dart
  /// adMobService.loadInterstitialAd(
  ///   onAdLoaded: (ad) {
  ///     _interstitialAd = ad;
  ///     ad.show();
  ///   },
  ///   onAdFailedToLoad: (error) => print('Failed: $error'),
  /// );
  /// ```
  void loadInterstitialAd({
    required void Function(InterstitialAd ad) onAdLoaded,
    required void Function(LoadAdError error) onAdFailedToLoad,
  }) {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
  }
}
