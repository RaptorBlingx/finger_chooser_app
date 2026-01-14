// lib/services/dare_pack_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dare_pack_model.dart';

/// Service to manage dare pack unlocking and availability
class DarePackService {
  static const String _unlockedPacksKey = 'unlocked_dare_packs';

  /// Get all available dare packs
  List<DarePack> getAllPacks() {
    return [
      // FREE PACKS
      DarePack(
        id: 'starter',
        name: 'Starter Dares',
        description: '60 fun dares to get the party started!',
        price: 'Free',
        iconData: Icons.rocket_launch,
        isFree: true,
        dareCount: 60,
        category: 'mild',
      ),
      DarePack(
        id: 'family_fun',
        name: 'Family Fun Pack',
        description: 'Perfect for family gatherings and kids',
        price: 'Free',
        iconData: Icons.family_restroom,
        isFree: true,
        dareCount: 30,
        category: 'mild',
      ),
      DarePack(
        id: 'quick_picks',
        name: 'Quick Picks',
        description: 'Fast and easy challenges for any occasion',
        price: 'Free',
        iconData: Icons.flash_on,
        isFree: true,
        dareCount: 25,
        category: 'mild',
      ),

      // PREMIUM PACKS
      DarePack(
        id: 'extreme_challenge',
        name: 'Extreme Challenge Pack',
        description: '50 wild dares that push the limits!',
        price: '\$1.99',
        iconData: Icons.whatshot,
        isFree: false,
        dareCount: 50,
        category: 'wild',
      ),
      DarePack(
        id: 'hilarious_pranks',
        name: 'Hilarious Pranks',
        description: '40 laugh-out-loud prank challenges',
        price: '\$0.99',
        iconData: Icons.emoji_emotions,
        isFree: false,
        dareCount: 40,
        category: 'spicy',
      ),
      DarePack(
        id: 'truth_or_dare',
        name: 'Truth or Dare Classics',
        description: 'Classic truth questions + dares combo',
        price: '\$1.49',
        iconData: Icons.psychology,
        isFree: false,
        dareCount: 60,
        category: 'spicy',
      ),
      DarePack(
        id: 'college_edition',
        name: 'College Edition',
        description: 'Dares made for campus life and dorm parties',
        price: '\$1.49',
        iconData: Icons.school,
        isFree: false,
        dareCount: 45,
        category: 'spicy',
      ),
      DarePack(
        id: 'couples_romance',
        name: 'Couples & Romance',
        description: 'Romantic and playful dares for two',
        price: '\$1.99',
        iconData: Icons.favorite,
        isFree: false,
        dareCount: 35,
        category: 'spicy',
      ),
      DarePack(
        id: 'ultimate_bundle',
        name: 'Ultimate Party Bundle',
        description: 'ALL premium packs + 50 exclusive dares!',
        price: '\$4.99',
        iconData: Icons.star,
        isFree: false,
        dareCount: 280,
        category: 'all',
      ),
    ];
  }

  /// Check if a pack is unlocked
  Future<bool> isPackUnlocked(String packId) async {
    // All free packs are always unlocked
    final pack = getAllPacks().firstWhere((p) => p.id == packId);
    if (pack.isFree) return true;

    final prefs = await SharedPreferences.getInstance();
    final unlockedPacks = prefs.getStringList(_unlockedPacksKey) ?? [];
    return unlockedPacks.contains(packId);
  }

  /// Unlock a pack (for premium packs after purchase)
  Future<void> unlockPack(String packId) async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedPacks = prefs.getStringList(_unlockedPacksKey) ?? [];

    if (!unlockedPacks.contains(packId)) {
      unlockedPacks.add(packId);
      await prefs.setStringList(_unlockedPacksKey, unlockedPacks);
    }
  }

  /// Get all unlocked packs
  Future<List<DarePack>> getUnlockedPacks() async {
    final allPacks = getAllPacks();
    final List<DarePack> unlocked = [];

    for (final pack in allPacks) {
      if (await isPackUnlocked(pack.id)) {
        unlocked.add(pack);
      }
    }

    return unlocked;
  }

  /// Get locked (not purchased) packs
  Future<List<DarePack>> getLockedPacks() async {
    final allPacks = getAllPacks();
    final List<DarePack> locked = [];

    for (final pack in allPacks) {
      if (!await isPackUnlocked(pack.id)) {
        locked.add(pack);
      }
    }

    return locked;
  }

  /// Simulate purchase (for beta - in production, integrate with IAP)
  Future<bool> purchasePack(String packId) async {
    // In production, this would:
    // 1. Initiate IAP flow
    // 2. Verify purchase with app store
    // 3. Unlock pack on success

    // For beta/testing, just unlock immediately
    await unlockPack(packId);
    return true;
  }

  /// Reset all purchases (for testing)
  Future<void> resetPurchases() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_unlockedPacksKey);
  }
}
