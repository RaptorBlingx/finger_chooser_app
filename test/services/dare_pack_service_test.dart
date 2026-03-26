import 'package:flutter_test/flutter_test.dart';
import 'package:finger_chooser_app/services/dare_pack_service.dart';

void main() {
  late DarePackService service;

  setUp(() {
    service = DarePackService();
  });

  group('DarePackService.getAllPacks', () {
    test('returns non-empty list of packs', () {
      final packs = service.getAllPacks();
      expect(packs, isNotEmpty);
    });

    test('all packs have unique IDs', () {
      final packs = service.getAllPacks();
      final ids = packs.map((p) => p.id).toSet();
      expect(ids.length, packs.length);
    });

    test('contains at least one free pack', () {
      final packs = service.getAllPacks();
      expect(packs.any((p) => p.isFree), isTrue);
    });

    test('contains at least one premium pack', () {
      final packs = service.getAllPacks();
      expect(packs.any((p) => !p.isFree), isTrue);
    });

    test('all packs have valid dare counts', () {
      final packs = service.getAllPacks();
      for (final pack in packs) {
        expect(pack.dareCount, greaterThan(0),
            reason: 'Pack ${pack.id} has 0 dares');
      }
    });

    test('all packs have valid categories', () {
      const validCategories = {'mild', 'spicy', 'wild', 'all'};
      final packs = service.getAllPacks();
      for (final pack in packs) {
        expect(validCategories.contains(pack.category), isTrue,
            reason: 'Pack ${pack.id} has invalid category: ${pack.category}');
      }
    });

    test('all packs have non-empty names and descriptions', () {
      final packs = service.getAllPacks();
      for (final pack in packs) {
        expect(pack.name, isNotEmpty, reason: 'Pack ${pack.id} has empty name');
        expect(pack.description, isNotEmpty,
            reason: 'Pack ${pack.id} has empty description');
      }
    });
  });
}
