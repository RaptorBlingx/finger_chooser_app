// lib/services/admob_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for AdMob service singleton
final adMobServiceProvider = Provider<AdMobService>((ref) {
  return AdMobService();
});

/// Service to manage AdMob ads across the app
///
/// Handles initialization, ad unit IDs, and ad loading for banner, interstitial, and rewarded ads.
/// Uses test ad IDs for development - REPLACE with real IDs before production!
class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  bool _isInitialized = false;

  // Interstitial frequency cap: minimum 3 minutes between interstitials
  DateTime? _lastInterstitialShown;
  static const _interstitialCooldown = Duration(minutes: 3);

  // Pre-loaded ads
  InterstitialAd? _preloadedInterstitial;
  RewardedAd? _preloadedRewarded;

  /// Initialize the Mobile Ads SDK
  Future<void> initialize() async {
    if (_isInitialized) return;
    await MobileAds.instance.initialize();
    _isInitialized = true;
  }

  // ─── Ad Unit IDs ───────────────────────────────────────────────

  /// Banner ad unit ID
  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3283345858983273/5644310235';
    } else if (Platform.isIOS) {
      // TODO: Replace with your iOS banner ad unit ID
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// Interstitial ad unit ID
  String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3283345858983273/6107344665';
    } else if (Platform.isIOS) {
      // TODO: Replace with your iOS interstitial ad unit ID
      return 'ca-app-pub-3940256099942544/4411468910';
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// Rewarded ad unit ID
  String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3283345858983273/3049936487';
    } else if (Platform.isIOS) {
      // TODO: Replace with your iOS rewarded ad unit ID
      return 'ca-app-pub-3940256099942544/1712485313';
    }
    throw UnsupportedError('Unsupported platform');
  }

  // ─── Banner Ads ────────────────────────────────────────────────

  BannerAd createBannerAd({
    required void Function(Ad ad) onAdLoaded,
    required void Function(Ad ad, LoadAdError error) onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
  }

  // ─── Interstitial Ads ─────────────────────────────────────────

  /// Whether an interstitial can be shown (respects frequency cap)
  bool get canShowInterstitial {
    if (_lastInterstitialShown == null) return true;
    return DateTime.now().difference(_lastInterstitialShown!) >= _interstitialCooldown;
  }

  /// Pre-load an interstitial ad for later use
  void preloadInterstitial() {
    if (_preloadedInterstitial != null) return;
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _preloadedInterstitial = ad,
        onAdFailedToLoad: (_) => _preloadedInterstitial = null,
      ),
    );
  }

  /// Show a pre-loaded interstitial ad (respects frequency cap)
  /// Returns true if ad was shown, false if skipped (cooldown or not loaded)
  Future<bool> showInterstitialIfReady({VoidCallback? onDismissed}) async {
    if (!canShowInterstitial || _preloadedInterstitial == null) {
      onDismissed?.call();
      return false;
    }

    _preloadedInterstitial!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _preloadedInterstitial = null;
        _lastInterstitialShown = DateTime.now();
        preloadInterstitial(); // Pre-load next one
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _preloadedInterstitial = null;
        preloadInterstitial();
        onDismissed?.call();
      },
    );

    await _preloadedInterstitial!.show();
    return true;
  }

  /// Load an interstitial ad (legacy callback-based API)
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

  // ─── Rewarded Ads ─────────────────────────────────────────────

  /// Pre-load a rewarded ad for later use
  void preloadRewarded() {
    if (_preloadedRewarded != null) return;
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _preloadedRewarded = ad,
        onAdFailedToLoad: (_) => _preloadedRewarded = null,
      ),
    );
  }

  /// Whether a rewarded ad is ready to show
  bool get isRewardedAdReady => _preloadedRewarded != null;

  /// Show a rewarded ad. Calls [onRewarded] when user earns the reward.
  /// Calls [onDismissed] when the ad is closed (whether reward was earned or not).
  /// Returns false if no ad was available.
  bool showRewardedAd({
    required void Function() onRewarded,
    VoidCallback? onDismissed,
    VoidCallback? onFailedToShow,
  }) {
    if (_preloadedRewarded == null) {
      onFailedToShow?.call();
      return false;
    }

    _preloadedRewarded!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _preloadedRewarded = null;
        preloadRewarded(); // Pre-load next one
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _preloadedRewarded = null;
        preloadRewarded();
        onFailedToShow?.call();
      },
    );

    _preloadedRewarded!.show(
      onUserEarnedReward: (_, __) => onRewarded(),
    );
    return true;
  }

  /// Dispose all loaded ads
  void dispose() {
    _preloadedInterstitial?.dispose();
    _preloadedRewarded?.dispose();
  }
}
