import 'package:flutter_test/flutter_test.dart';
import 'package:wave/core/audio/personal_dj_service.dart';

void main() {
  group('PersonalDjMood copy', () {
    test('every mood has a label and description', () {
      for (final mood in PersonalDjMood.values) {
        expect(PersonalDjService.moodLabel(mood), isNotEmpty);
        expect(PersonalDjService.moodDescription(mood), isNotEmpty);
      }
    });

    test('descriptions differ by mood', () {
      final descriptions = PersonalDjMood.values
          .map(PersonalDjService.moodDescription)
          .toSet();
      expect(descriptions.length, PersonalDjMood.values.length);
    });
  });
}
