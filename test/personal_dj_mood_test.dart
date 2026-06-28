import 'package:flutter_test/flutter_test.dart';
import 'package:wave/core/api/models/deezer_track.dart';
import 'package:wave/core/audio/personal_dj_service.dart';

DeezerTrack _track({required int id, int? duration, int? rank, double? bpm}) =>
    DeezerTrack(
      id: id,
      title: 'Track $id',
      duration: duration,
      rank: rank,
      bpm: bpm,
    );

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

  group('chillScore', () {
    test('rejects short chart hits', () {
      expect(
        PersonalDjService.chillScore(_track(id: 1, duration: 180, rank: 800000)),
        lessThan(0),
      );
      expect(
        PersonalDjService.chillScore(_track(id: 2, duration: 150, rank: 200000)),
        lessThan(0),
      );
    });

    test('prefers longer deep cuts over chart singles', () {
      final deepCut = PersonalDjService.chillScore(
        _track(id: 3, duration: 300, rank: 120000),
      );
      final chartHit = PersonalDjService.chillScore(
        _track(id: 4, duration: 300, rank: 700000),
      );
      final shortSingle = PersonalDjService.chillScore(
        _track(id: 5, duration: 200, rank: 150000),
      );

      expect(deepCut, greaterThan(personalDjChillMinScore));
      expect(chartHit, lessThan(0));
      expect(deepCut, greaterThan(shortSingle));
    });

    test('prefers slower BPM when tempo is known', () {
      final slow = PersonalDjService.chillScore(
        _track(id: 6, duration: 300, rank: 120000, bpm: 78),
      );
      final mid = PersonalDjService.chillScore(
        _track(id: 7, duration: 300, rank: 120000, bpm: 108),
      );
      final fast = PersonalDjService.chillScore(
        _track(id: 8, duration: 300, rank: 120000, bpm: 128),
      );

      expect(slow, greaterThan(mid));
      expect(fast, lessThan(0));
    });
  });

  group('hypeScore', () {
    test('rejects slow tracks when BPM is known', () {
      expect(
        PersonalDjService.hypeScore(
          _track(id: 10, duration: 200, rank: 700000, bpm: 82),
        ),
        lessThan(0),
      );
    });

    test('prefers faster chart tracks over slow deep cuts', () {
      final fastHit = PersonalDjService.hypeScore(
        _track(id: 11, duration: 210, rank: 750000, bpm: 132),
      );
      final slowCut = PersonalDjService.hypeScore(
        _track(id: 12, duration: 320, rank: 120000, bpm: 88),
      );

      expect(fastHit, greaterThan(personalDjHypeMinScore));
      expect(slowCut, lessThan(0));
      expect(fastHit, greaterThan(slowCut));
    });
  });
}