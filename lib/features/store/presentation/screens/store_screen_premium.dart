// lib/features/store/presentation/screens/store_screen_premium.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../models/dare_pack_model.dart';
import '../../../../services/dare_pack_service.dart';

class StoreScreenPremium extends StatefulWidget {
  const StoreScreenPremium({super.key});

  @override
  State<StoreScreenPremium> createState() => _StoreScreenPremiumState();
}

class _StoreScreenPremiumState extends State<StoreScreenPremium> {
  final DarePackService _packService = DarePackService();
  List<DarePack> _unlockedPacks = [];
  List<DarePack> _lockedPacks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPacks();
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

  Future<void> _handleUnlockPack(DarePack pack) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
        ),
        title: Text(
          'Unlock ${pack.name}?',
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
                  '${pack.dareCount} dares',
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
                  const Icon(Icons.info_outline, color: Colors.white),
                  const SizedBox(width: AppTheme.spacingS),
                  Expanded(
                    child: Text(
                      'Beta Testing: All packs are FREE to unlock!',
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
              'Cancel',
              style: AppTheme.bodyM.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryStart,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
            ),
            child: const Text('Unlock Now'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      HapticFeedback.mediumImpact();

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Simulate purchase
      await _packService.purchasePack(pack.id);
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        // Show success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Text(
                    '${pack.name} unlocked! 🎉',
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

        // Reload packs
        await _loadPacks();
      }
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
                            'Your Packs (${_unlockedPacks.length})',
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
                            'Available Packs (${_lockedPacks.length})',
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
                                  'You have all packs!',
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
                  'Dare Store',
                  style: AppTheme.headingS,
                ),
                const SizedBox(height: 4),
                Text(
                  'Unlock premium dare packs',
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
                  'BETA',
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
                  '${pack.dareCount} dares',
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
                text: 'Unlock Pack',
                onPressed: () => _handleUnlockPack(pack),
                gradient: gradient,
                icon: Icons.lock_open,
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
