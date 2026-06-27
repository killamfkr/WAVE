import 'dart:math';

import '../api/models/deezer_track.dart';
import 'personal_dj_service.dart';

/// Short, radio-style spoken lines for the Personal DJ.
class PersonalDjSpeech {
  PersonalDjSpeech._();

  static final _rng = Random();

  static String opener({
    required DeezerTrack seed,
    required bool fromLiked,
    required bool fromRecent,
    required PersonalDjMood mood,
  }) {
    final title = _clean(seed.title);
    final artist = _clean(seed.artist?.name ?? 'one of your favorites');

    return _pick(<String>[
      if (fromLiked) ...<String>[
        'Alright — $title, by $artist. Straight from your likes.',
        'You saved this one. $title, from $artist.',
        'Starting with $title, by $artist.',
      ] else if (fromRecent) ...<String>[
        'You\'ve been on a $artist run. Here\'s $title.',
        'Built this around $artist. First up, $title.',
        'Your recent plays said $artist — so, $title.',
      ] else ...<String>[
        'Here\'s your mix. $title, by $artist, to start.',
        'First track — $title, from $artist.',
        'Let\'s go. $title, by $artist.',
      ],
      ..._moodTag(mood),
    ]);
  }

  static String liner({
    required DeezerTrack track,
    required Set<int> likedIds,
    PersonalDjMood mood = PersonalDjMood.mixed,
  }) {
    final title = _clean(track.title);
    final artist = _clean(track.artist?.name ?? 'this artist');
    final liked = likedIds.contains(track.id);

    if (liked) {
      return _pick(<String>[
        'You know this one — $title.',
        'Back to $title, by $artist.',
        '$title. One of your favorites.',
      ]);
    }

    return _pick(<String>[
      switch (mood) {
        PersonalDjMood.chill => 'Keeping it smooth. $title.',
        PersonalDjMood.hype => 'This one hits. $title, by $artist.',
        PersonalDjMood.discover => 'Something new — $title.',
        PersonalDjMood.mixed => 'Next up, $title, by $artist.',
      },
      'Coming up — $artist.',
      '$title, by $artist.',
    ]);
  }

  static List<String> _moodTag(PersonalDjMood mood) => switch (mood) {
        PersonalDjMood.chill => <String>['Easy vibes tonight.'],
        PersonalDjMood.hype => <String>['Turning it up a little.'],
        PersonalDjMood.discover => <String>['I\'ll dig a little deeper for you.'],
        PersonalDjMood.mixed => <String>['Built from your taste.'],
      };

  static String _clean(String raw) {
    var s = raw.trim();
    s = s.replaceAll(RegExp(r'\s*[\(\[].*?[\)\]]'), '');
    s = s.replaceAll(RegExp(r'\s+feat\.?.*$', caseSensitive: false), '');
    s = s.replaceAll(RegExp(r'\s+ft\.?.*$', caseSensitive: false), '');
    s = s.replaceAll('&', 'and');
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    return s.isEmpty ? raw.trim() : s;
  }

  static String _pick(List<String> options) =>
      options[_rng.nextInt(options.length)];
}
