// lib/features/store/presentation/screens/store_screen_premium.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../models/dare_pack_model.dart';
import '../../../../models/filter_criteria_model.dart';
import '../../../../services/dare_pack_service.dart';
import '../../../../services/admob_service.dart';
import '../../../finger_chooser/presentation/screens/chooser_screen_ultra.dart';

class StoreScreenPremium extends ConsumerStatefulWidget {
  const StoreScreenPremium({super.key});

  @override
  ConsumerState<StoreScreenPremium> createState() => _StoreScreenPremiumState();
}

class _StoreScreenPremiumState extends ConsumerState<StoreScreenPremium> {
  final DarePackService _packService = DarePackService();
  List<DarePack> _unlockedPacks = [];
  List<DarePack> _lockedPacks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPacks();
    // Pre-load a rewarded ad for pack unlocks
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adMobServiceProvider).preloadRewarded();
    });
  }

  Future<void> _loadPacks() async {
    setState(() => _isLoading = true);

    final unlocked = await _packService.getUnlockedPacks();
    final locked = await _packService.getLockedPacks();

    setState(() {
      _unlockedPacks = unlocked;
      _lockedPacks = locked;
      _isLoading = false;
    });
  }

  void _playWithPack(DarePack pack) {
    HapticFeedback.mediumImpact();
    final intensities = pack.category == 'all'
        ? null
        : [pack.category];
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ChooserScreenUltra(
          filterCriteria: FilterCriteria(intensities: intensities),
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  Future<void> _handleUnlockPack(DarePack pack) async {
    final l10n = AppLocalizations.of(context)!;
    final adService = ref.read(adMobServiceProvider);

    // Show confirmation dialog with watch-ad option
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
        ),
        title: Text(
          l10n.unlockPackConfirm(pack.name),
          style: AppTheme.headingS,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pack.description,
              style: AppTheme.bodyM.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Row(
              children: [
                const Icon(
                  Icons.casino,
                  color: AppTheme.primaryStart,
                  size: 20,
                ),
                const SizedBox(width: AppTheme.spacingS),
                Text(
                  l10n.daresCount(pack.dareCount),
                  style: AppTheme.bodyS,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingL),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Row(
                children: [
                  const Icon(Icons.play_circle_fill, color: Colors.white),
                  const SizedBox(width: AppTheme.spacingS),
                  Expanded(
                    child: Text(
                      adService.isRewardedAdReady
                          ? l10n.watchAdToUnlock
                          : l10n.adNotReady,
                      style: AppTheme.bodyS.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              l10n.cancel,
              style: AppTheme.bodyM.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: adService.isRewardedAdReady
                ? () => Navigator.pop(context, true)
                : null,
            icon: const Icon(Icons.play_circle_fill, size: 18),
            label: Text(l10n.watchAd),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryStart,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      HapticFeedback.mediumImpact();

      adService.showRewardedAd(
        onRewarded: () async {
          // User watched the full ad — unlock the pack
          await _packService.purchasePack(pack.id);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: Text(
                        l10n.packUnlocked(pack.name),
                        style: AppTheme.bodyM,
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppTheme.successStart,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
              ),
            );
            await _loadPacks();
          }
        },
        onFailedToShow: () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.adNotReady),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      );
    }
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
          localizations.storeScreenTitle,
          style: AppTheme.headingM,
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        _buildHeader(),
                        const SizedBox(height: AppTheme.spacingXL),

                        // Unlocked Packs
                        if (_unlockedPacks.isNotEmpty) ...[
                          Text(
                            localizations.yourPacks(_unlockedPacks.length),
                            style: AppTheme.headingS.copyWith(
                              color: AppTheme.successStart,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingM),
                          ..._unlockedPacks.map((pack) => _buildPackCard(pack, isUnlocked: true)),
                          const SizedBox(height: AppTheme.spacingXL),
                        ],

                        // Locked Packs
                        if (_lockedPacks.isNotEmpty) ...[
                          Text(
                            localizations.availablePacks(_lockedPacks.length),
                            style: AppTheme.headingS.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingM),
                          ..._lockedPacks.map((pack) => _buildPackCard(pack, isUnlocked: false)),
                        ] else ...[
                          Center(
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  size: 80,
                                  color: AppTheme.successStart,
                                ),
                                const SizedBox(height: AppTheme.spacingM),
                                Text(
                                  localizations.youHaveAllPacks,
                                  style: AppTheme.headingM.copyWith(
                                    color: AppTheme.successStart,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: AppTheme.spacingXL),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: const Icon(
              Icons.shopping_bag,
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
                  l10n.dareStore,
                  style: AppTheme.headingS,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.unlockPremiumDarePacks,
                  style: AppTheme.bodyS,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingS,
            ),
            decoration: BoxDecoration(
              color: AppTheme.warning.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
              border: Border.all(
                color: AppTheme.warning,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.science,
                  color: AppTheme.warning,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.beta,
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  Widget _buildPackCard(DarePack pack, {required bool isUnlocked}) {
    final l10n = AppLocalizations.of(context)!;
    final gradient = _getGradientForCategory(pack.category);
    
    // Calculate animation delay based on the pack's position in the appropriate list
    final packIndex = isUnlocked 
        ? _unlockedPacks.indexOf(pack) 
        : _lockedPacks.indexOf(pack);
    // Ensure the index is never negative, default to 0 if pack is not found
    final animationIndex = packIndex >= 0 ? packIndex : 0;
    // Add offset for locked packs so they animate after unlocked ones
    final delayIndex = isUnlocked ? animationIndex : animationIndex + _unlockedPacks.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.colors.first.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    pack.iconData,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              pack.name,
                              style: AppTheme.headingS.copyWith(fontSize: 18),
                            ),
                          ),
                          if (isUnlocked)
                            const Icon(
                              Icons.check_circle,
                              color: AppTheme.successStart,
                              size: 24,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pack.description,
                        style: AppTheme.bodyS,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),

            // Stats
            Row(
              children: [
                _buildStatChip(
                  Icons.casino,
                  l10n.daresCount(pack.dareCount),
                  AppTheme.info,
                ),
                const SizedBox(width: AppTheme.spacingS),
                _buildStatChip(
                  _getCategoryIcon(pack.category),
                  pack.category.toUpperCase(),
                  gradient.colors.first,
                ),
                const Spacer(),
                if (!isUnlocked)
                  Text(
                    pack.price,
                    style: AppTheme.headingS.copyWith(
                      color: AppTheme.primaryStart,
                      fontSize: 20,
                    ),
                  ),
              ],
            ),

            // Action Button
            if (!isUnlocked) ...[
              const SizedBox(height: AppTheme.spacingM),
              GradientButton(
                text: l10n.unlockPack,
                onPressed: () => _handleUnlockPack(pack),
                gradient: gradient,
                icon: Icons.lock_open,
                height: 48,
              ),
            ] else ...[
              const SizedBox(height: AppTheme.spacingM),
              GradientButton(
                text: l10n.playWithPack,
                onPressed: () => _playWithPack(pack),
                gradient: gradient,
                icon: Icons.play_arrow,
                height: 48,
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 100 * delayIndex)).slideX(begin: 0.2, end: 0);
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingS,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTheme.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getGradientForCategory(String category) {
    switch (category) {
      case 'mild':
        return AppTheme.successGradient;
      case 'spicy':
        return AppTheme.accentGradient;
      case 'wild':
        return const LinearGradient(
          colors: [Color(0xFFFF4F4F), Color(0xFFFF1744)],
        );
      case 'all':
        return AppTheme.primaryGradient;
      default:
        return AppTheme.secondaryGradient;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'mild':
        return Icons.sentiment_satisfied;
      case 'spicy':
        return Icons.whatshot;
      case 'wild':
        return Icons.local_fire_department;
      case 'all':
        return Icons.star;
      default:
        return Icons.label;
    }
  }
}
