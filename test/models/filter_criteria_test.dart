import 'package:flutter_test/flutter_test.dart';
import 'package:finger_chooser_app/models/filter_criteria_model.dart';

void main() {
  group('FilterCriteria', () {
    test('isNotEmpty returns false for empty criteria', () {
      const criteria = FilterCriteria();
      expect(criteria.isNotEmpty, isFalse);
    });

    test('isNotEmpty returns true when playerCount is set', () {
      const criteria = FilterCriteria(playerCount: 4);
      expect(criteria.isNotEmpty, isTrue);
    });

    test('isNotEmpty returns true when groupTypes is set', () {
      const criteria = FilterCriteria(groupTypes: ['friends']);
      expect(criteria.isNotEmpty, isTrue);
    });

    test('isNotEmpty returns false with empty lists', () {
      const criteria = FilterCriteria(
        groupTypes: [],
        places: [],
        genders: [],
        intensities: [],
      );
      expect(criteria.isNotEmpty, isFalse);
    });

    test('isNotEmpty returns true when places is set', () {
      const criteria = FilterCriteria(places: ['home']);
      expect(criteria.isNotEmpty, isTrue);
    });

    test('isNotEmpty returns true when genders is set', () {
      const criteria = FilterCriteria(genders: ['mixed']);
      expect(criteria.isNotEmpty, isTrue);
    });

    test('isNotEmpty returns true when intensities is set', () {
      const criteria = FilterCriteria(intensities: ['mild', 'spicy']);
      expect(criteria.isNotEmpty, isTrue);
    });

    test('isNotEmpty returns true with multiple criteria', () {
      const criteria = FilterCriteria(
        playerCount: 3,
        groupTypes: ['friends'],
        places: ['home'],
        genders: ['mixed'],
        intensities: ['spicy'],
      );
      expect(criteria.isNotEmpty, isTrue);
    });
  });
}
