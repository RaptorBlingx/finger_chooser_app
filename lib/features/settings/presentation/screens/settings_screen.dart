// lib/features/settings/presentation/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../providers/locale_provider.dart';
import 'package:url_launcher/url_launcher.dart';

const String _prefSoundEnabled = 'settings_sound_enabled';
const String _prefVibrationEnabled = 'settings_vibration_enabled';

// Providers for settings
final soundEnabledProvider = StateProvider<bool>((ref) => true);
final vibrationEnabledProvider = StateProvider<bool>((ref) => true);

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      ref.read(soundEnabledProvider.notifier).state =
          prefs.getBool(_prefSoundEnabled) ?? true;
      ref.read(vibrationEnabledProvider.notifier).state =
          prefs.getBool(_prefVibrationEnabled) ?? true;
    }
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeNotifierProvider);
    final soundEnabled = ref.watch(soundEnabledProvider);
    final vibrationEnabled = ref.watch(vibrationEnabledProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          localizations.settingsTitle,
          style: AppTheme.headingM,
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppTheme.spacingM),

                // Language Section
                _buildSectionTitle(localizations.language, Icons.language),

                const SizedBox(height: AppTheme.spacingM),

                _buildLanguageSelector(context, currentLocale),

                const SizedBox(height: AppTheme.spacingXL),

                // Sound Section
                _buildSectionTitle(localizations.sound, Icons.volume_up),

                const SizedBox(height: AppTheme.spacingM),

                GlassCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            soundEnabled ? Icons.volume_up : Icons.volume_off,
                            color: soundEnabled
                                ? AppTheme.primaryStart
                                : AppTheme.textTertiary,
                            size: 24,
                          ),
                          const SizedBox(width: AppTheme.spacingM),
                          Text(
                            localizations.sound,
                            style: AppTheme.bodyL,
                          ),
                        ],
                      ),
                      Switch(
                        value: soundEnabled,
                        onChanged: (value) {
                          ref.read(soundEnabledProvider.notifier).state = value;
                          _saveBool(_prefSoundEnabled, value);
                          if (value) HapticFeedback.lightImpact();
                        },
                        activeColor: AppTheme.primaryStart,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0),

                const SizedBox(height: AppTheme.spacingXL),

                // Vibration Section
                _buildSectionTitle(localizations.vibration, Icons.vibration),

                const SizedBox(height: AppTheme.spacingM),

                GlassCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            vibrationEnabled
                                ? Icons.vibration
                                : Icons.phone_android,
                            color: vibrationEnabled
                                ? AppTheme.primaryStart
                                : AppTheme.textTertiary,
                            size: 24,
                          ),
                          const SizedBox(width: AppTheme.spacingM),
                          Text(
                            localizations.vibration,
                            style: AppTheme.bodyL,
                          ),
                        ],
                      ),
                      Switch(
                        value: vibrationEnabled,
                        onChanged: (value) {
                          ref.read(vibrationEnabledProvider.notifier).state =
                              value;
                          _saveBool(_prefVibrationEnabled, value);
                          if (value) HapticFeedback.lightImpact();
                        },
                        activeColor: AppTheme.primaryStart,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1, end: 0),

                const SizedBox(height: AppTheme.spacingXL),

                // About Section
                _buildSectionTitle(localizations.about, Icons.info_outline),

                const SizedBox(height: AppTheme.spacingM),

                GlassCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusM),
                            ),
                            child: const Icon(
                              Icons.touch_app,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingM),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localizations.appTitle,
                                style: AppTheme.headingS,
                              ),
                              Text(
                                localizations.appVersion('1.0.0'),
                                style: AppTheme.bodyS,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      Text(
                        localizations.theUltimatePartyGame,
                        style: AppTheme.bodyS.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1, end: 0),

                const SizedBox(height: AppTheme.spacingL),

                // Privacy Policy
                GlassCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.privacy_tip_outlined,
                      color: AppTheme.primaryStart,
                    ),
                    title: Text(
                      localizations.privacyPolicy,
                      style: AppTheme.bodyL,
                    ),
                    trailing: const Icon(
                      Icons.open_in_new,
                      color: AppTheme.textTertiary,
                      size: 18,
                    ),
                    onTap: () {
                      // TODO: Replace with your actual privacy policy URL
                      launchUrl(
                        Uri.parse('https://your-privacy-policy-url.com'),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                  ),
                ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.1, end: 0),

                const SizedBox(height: AppTheme.spacingM),

                // Rate App
                GlassCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.star_rate_rounded,
                      color: Colors.amber,
                    ),
                    title: Text(
                      localizations.rateApp,
                      style: AppTheme.bodyL,
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppTheme.textTertiary,
                    ),
                    onTap: () {
                      // TODO: Replace with your actual Play Store URL
                      launchUrl(
                        Uri.parse('https://play.google.com/store/apps/details?id=com.raptorblingx.fingerchoser'),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                  ),
                ).animate().fadeIn(delay: 800.ms).slideX(begin: 0.1, end: 0),

                const SizedBox(height: AppTheme.spacingXXL),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 20),
        const SizedBox(width: AppTheme.spacingS),
        Text(
          title,
          style: AppTheme.headingS.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildLanguageSelector(BuildContext context, Locale? currentLocale) {
    final isEnglish = currentLocale?.languageCode != 'ar';

    return Row(
      children: [
        Expanded(
          child: _buildLanguageOption(
            'English',
            '🇬🇧',
            isEnglish,
            () {
              ref
                  .read(localeNotifierProvider.notifier)
                  .setLocale(const Locale('en'));
              HapticFeedback.selectionClick();
            },
          ),
        ),
        const SizedBox(width: AppTheme.spacingM),
        Expanded(
          child: _buildLanguageOption(
            'العربية',
            '🇸🇦',
            !isEnglish,
            () {
              ref
                  .read(localeNotifierProvider.notifier)
                  .setLocale(const Locale('ar'));
              HapticFeedback.selectionClick();
            },
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildLanguageOption(
    String label,
    String flag,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.normal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingL,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppTheme.primaryStart.withOpacity(0.3),
                    AppTheme.primaryEnd.withOpacity(0.2),
                  ],
                )
              : LinearGradient(
                  colors: [
                    AppTheme.cardBackground.withOpacity(0.6),
                    AppTheme.cardBackgroundLight.withOpacity(0.4),
                  ],
                ),
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryStart.withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(flag, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              label,
              style: AppTheme.bodyM.copyWith(
                color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
