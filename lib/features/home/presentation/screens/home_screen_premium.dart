// lib/features/home/presentation/screens/home_screen_premium.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../finger_chooser/presentation/screens/chooser_screen.dart';
import '../../../store/presentation/screens/store_screen_premium.dart';
import '../../../../services/admob_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/glass_card.dart';

class HomeScreenPremium extends StatefulWidget {
  const HomeScreenPremium({super.key});

  static const String routeName = '/home';

  @override
  State<HomeScreenPremium> createState() => _HomeScreenPremiumState();
}

class _HomeScreenPremiumState extends State<HomeScreenPremium>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _buttonClickPlayer = AudioPlayer();
  final AdMobService _adMobService = AdMobService();

  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _initPulseAnimation();
  }

  void _initPulseAnimation() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  void _loadBannerAd() {
    _bannerAd = _adMobService.createBannerAd(
      onAdLoaded: (ad) {
        setState(() => _isBannerAdReady = true);
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
    _pulseController.dispose();
    super.dispose();
  }

  void _playButtonClickSound() {
    _buttonClickPlayer.play(AssetSource('sounds/button_click.mp3'));
  }

  void _handleNavigation(
    BuildContext context,
    Widget screen, {
    String? eventName,
    Map<String, Object>? parameters,
  }) {
    HapticFeedback.mediumImpact();
    _playButtonClickSound();

    if (eventName != null) {
      FirebaseAnalytics.instance.logEvent(
        name: eventName,
        parameters: parameters,
      );
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: AppDurations.normal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          localizations.appTitle,
          style: AppTheme.headingM.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ).animate(onPlay: (controller) => controller.repeat()).shimmer(
              duration: 3000.ms,
              color: AppTheme.primaryEnd.withOpacity(0.3),
            ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.settings_outlined),
            ),
            tooltip: localizations.settings,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings - Coming Soon!')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppTheme.spacingL),

                  // Hero Section
                  _buildHeroSection(localizations),

                  const SizedBox(height: AppTheme.spacingXXL),

                  // Game Modes
                  _buildGameModesSection(localizations),

                  const SizedBox(height: AppTheme.spacingXL),

                  // Secondary Actions
                  _buildSecondaryActions(localizations),

                  const SizedBox(height: AppTheme.spacingXL),

                  // Stats Card (placeholder for now)
                  _buildStatsCard(localizations),

                  const SizedBox(height: AppTheme.spacingXL),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _isBannerAdReady && _bannerAd != null
          ? Container(
              height: _bannerAd!.size.height.toDouble(),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.backgroundDark.withOpacity(0.9),
                    AppTheme.backgroundLight.withOpacity(0.9),
                  ],
                ),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: AdWidget(ad: _bannerAd!),
            )
          : null,
    );
  }

  Widget _buildHeroSection(AppLocalizations localizations) {
    return Column(
      children: [
        // Animated Logo
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.primaryGradient,
            boxShadow: AppTheme.glowShadow,
          ),
          child: const Icon(
            Icons.touch_app,
            size: 60,
            color: Colors.white,
          ),
        )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.1, 1.1),
              duration: 2000.ms,
              curve: Curves.easeInOut,
            ),

        const SizedBox(height: AppTheme.spacingL),

        // Title
        ShaderMask(
          shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
          child: Text(
            'Finger Chooser',
            style: GoogleFonts.poppins(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(
              begin: -0.3,
              end: 0,
            ),

        const SizedBox(height: AppTheme.spacingS),

        // Subtitle
        Text(
          'The Ultimate Party Game',
          style: AppTheme.bodyM.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
      ],
    );
  }

  Widget _buildGameModesSection(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Mode',
          style: AppTheme.headingS.copyWith(
            color: AppTheme.textSecondary,
          ),
        ).animate().fadeIn(delay: 600.ms),

        const SizedBox(height: AppTheme.spacingM),

        // Party Play - Main mode
        _buildGameModeCard(
          title: '🎉 Party Play',
          subtitle: 'Finger selection + Dares',
          gradient: AppTheme.primaryGradient,
          onTap: () => _handleNavigation(
            context,
            const ChooserScreen(isQuickPlayMode: false),
            eventName: 'party_play_started',
            parameters: {'mode': 'party_dares'},
          ),
          delay: 700,
        ),

        const SizedBox(height: AppTheme.spacingM),

        // Quick Pick
        _buildGameModeCard(
          title: '👆 Quick Pick',
          subtitle: 'Fingers only, no dares',
          gradient: AppTheme.secondaryGradient,
          onTap: () => _handleNavigation(
            context,
            const ChooserScreen(isQuickPlayMode: true),
            eventName: 'quick_pick_started',
            parameters: {'mode': 'quick_pick_fingers_only'},
          ),
          delay: 800,
        ),
      ],
    );
  }

  Widget _buildGameModeCard({
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
    required int delay,
  }) {
    return GlassCard(
      onTap: onTap,
      gradient: LinearGradient(
        colors: [
          AppTheme.cardBackground.withOpacity(0.8),
          AppTheme.cardBackgroundLight.withOpacity(0.6),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.headingS,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTheme.bodyS,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: AppTheme.textSecondary,
            size: 20,
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(
          begin: 0.3,
          end: 0,
        );
  }

  Widget _buildSecondaryActions(AppLocalizations localizations) {
    return Row(
      children: [
        Expanded(
          child: GradientButton(
            text: '🛠️ Custom',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Custom Play Wizard - Coming Soon!')),
              );
            },
            gradient: AppTheme.accentGradient,
            height: 50,
          ).animate().fadeIn(delay: 900.ms).slideX(begin: -0.2, end: 0),
        ),
        const SizedBox(width: AppTheme.spacingM),
        Expanded(
          child: GradientButton(
            text: '🛍️ Store',
            onPressed: () => _handleNavigation(
              context,
              const StoreScreenPremium(),
              eventName: 'store_opened',
            ),
            gradient: AppTheme.successGradient,
            height: 50,
          ).animate().fadeIn(delay: 1000.ms).slideX(begin: 0.2, end: 0),
        ),
      ],
    );
  }

  Widget _buildStatsCard(AppLocalizations localizations) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.analytics_outlined,
                color: AppTheme.info,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                'Your Stats',
                style: AppTheme.headingS,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('0', 'Games', Icons.gamepad_outlined),
              _buildStatItem('0', 'Dares', Icons.task_alt_outlined),
              _buildStatItem('0', 'Wins', Icons.emoji_events_outlined),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 1100.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryStart,
          size: 28,
        ),
        const SizedBox(height: AppTheme.spacingS),
        Text(
          value,
          style: AppTheme.headingM.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTheme.caption,
        ),
      ],
    );
  }
}
