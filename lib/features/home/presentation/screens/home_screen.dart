// lib/features/home/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../finger_chooser/presentation/screens/chooser_screen_ultra.dart';
import '../../../store/presentation/screens/store_screen.dart';
import '../../../../services/admob_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioPlayer _buttonClickPlayer = AudioPlayer();
  final AdMobService _adMobService = AdMobService();

  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = _adMobService.createBannerAd(
      onAdLoaded: (ad) {
        setState(() {
          _isBannerAdReady = true;
        });
      },
      onAdFailedToLoad: (ad, error) {
        debugPrint('Banner ad failed to load: $error');
        ad.dispose();
      },
    );
    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _buttonClickPlayer.dispose();
    super.dispose();
  }

  void _playButtonClickSound() {
    _buttonClickPlayer.play(AssetSource('sounds/button_click.mp3'));
  }

  void _handleNavigation(BuildContext context, Widget screen, {String? eventName, Map<String, Object>? parameters}) {
    HapticFeedback.selectionClick();
    _playButtonClickSound();

    if (eventName != null) {
      FirebaseAnalytics.instance.logEvent(name: eventName, parameters: parameters);
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appTitle),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const FlutterLogo(size: 80.0),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  _handleNavigation(
                    context,
                    const ChooserScreenUltra(isQuickPlayMode: false),
                    eventName: 'party_play_opened',
                  );
                },
                child: const Text("🎉 Party Play (with Dares)"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  _handleNavigation(
                    context,
                    const ChooserScreenUltra(isQuickPlayMode: true),
                    eventName: 'quick_pick_opened',
                  );
                },
                child: const Text("👆 Quick Pick (Fingers Only)"),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Custom Play Wizard - Coming Soon!")),
                  );
                },
                child: const Text("🛠️ Custom Play (Wizard)"),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.storefront_outlined),
                label: Text(localizations.darePacksButtonLabel),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: () => _handleNavigation(
                  context,
                  const StoreScreen(),
                  eventName: 'store_opened',
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _isBannerAdReady && _bannerAd != null
          ? SizedBox(
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : null,
    );
  }
}