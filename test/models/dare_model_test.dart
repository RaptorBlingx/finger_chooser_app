import 'package:flutter_test/flutter_test.dart';
import 'package:finger_chooser_app/models/dare_model.dart';

void main() {
  group('Dare.fromJson', () {
    test('parses a valid JSON dare correctly', () {
      final json = {
        'id': 'test_001',
        'text_en': 'Do something fun',
        'text_ar': 'اعمل شي ممتع',
        'groupType': ['friends', 'family'],
        'place': ['home', 'party'],
        'gender': ['mixed', 'boys'],
        'intensity': 'mild',
        'minPlayers': 2,
        'maxPlayers': 6,
      };

      final dare = Dare.fromJson(json);

      expect(dare.id, 'test_001');
      expect(dare.textEn, 'Do something fun');
      expect(dare.textAr, 'اعمل شي ممتع');
      expect(dare.groupType, ['friends', 'family']);
      expect(dare.place, ['home', 'party']);
      expect(dare.gender, ['mixed', 'boys']);
      expect(dare.intensity, 'mild');
      expect(dare.minPlayers, 2);
      expect(dare.maxPlayers, 6);
    });

    test('handles null maxPlayers', () {
      final json = {
        'id': 'test_002',
        'text_en': 'Open dare',
        'text_ar': null,
        'groupType': ['friends'],
        'place': ['any'],
        'gender': ['mixed'],
        'intensity': 'wild',
        'minPlayers': 3,
        'maxPlayers': null,
      };

      final dare = Dare.fromJson(json);

      expect(dare.maxPlayers, isNull);
      expect(dare.textAr, isNull);
      expect(dare.minPlayers, 3);
    });

    test('toJson round-trips correctly', () {
      final original = Dare(
        id: 'rt_001',
        textEn: 'Round trip test',
        textAr: 'اختبار',
        groupType: ['friends'],
        place: ['home'],
        gender: ['mixed'],
        intensity: 'spicy',
        minPlayers: 2,
        maxPlayers: 4,
      );

      final json = original.toJson();
      final restored = Dare.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.textEn, original.textEn);
      expect(restored.textAr, original.textAr);
      expect(restored.groupType, original.groupType);
      expect(restored.intensity, original.intensity);
      expect(restored.minPlayers, original.minPlayers);
      expect(restored.maxPlayers, original.maxPlayers);
    });
  });
}
