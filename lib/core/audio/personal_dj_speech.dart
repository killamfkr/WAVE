import 'dart:math';

import '../api/models/deezer_track.dart';
import 'personal_dj_service.dart';

/// On-screen copy and spoken script for a DJ line.
class DjLine {
  const DjLine({required this.display, required this.spoken});

  final String display;
  final String spoken;
}

/// Natural-sounding DJ scripts and TTS delivery helpers.
class PersonalDjSpeech {
  PersonalDjSpeech._();

  static final _rng = Random();

  static DjLine opener({
    required DeezerTrack seed,
    required bool fromLiked,
    required bool fromRecent,
    required PersonalDjMood mood,
  }) {
    final title = _clean(seed.title);
    final artist = _clean(seed.artist?.name ?? 'one of your favorites');
    final hook = _pick(_moodSpokenHooks(mood));
    final body = _pick(<String>[
      if (fromLiked) ...<String>[
        'I\'m pulling from your liked songs. First up — $title, by $artist.',
        'You saved this one. $title, from $artist. Let\'s go.',
        'Starting with $title, by $artist.',
      ] else if (fromRecent) ...<String>[
        'You\'ve had $artist on repeat. We open on $title.',
        'Your recent plays led me here. $title, by $artist, kicks it off.',
        'Built around $artist — starting with $title.',
      ] else ...<String>[
        'First track — $title, by $artist.',
        'Here we go. $title, from $artist.',
        'Kicking off with $title, by $artist.',
      ],
    ]);
    final spoken = '$hook $body';

    final display = _displayOpener(
      seed: seed,
      fromLiked: fromLiked,
      fromRecent: fromRecent,
      mood: mood,
      title: title,
      artist: artist,
    );

    return DjLine(display: display, spoken: spoken);
  }

  static DjLine liner({
    required DeezerTrack track,
    required Set<int> likedIds,
    PersonalDjMood mood = PersonalDjMood.mixed,
  }) {
    final title = _clean(track.title);
    final artist = _clean(track.artist?.name ?? 'this artist');
    final liked = likedIds.contains(track.id);

    final spoken = _pick(<String>[
      if (liked) ...<String>[
        'You know this one. $title, by $artist.',
        'Back to a favorite — $title, from $artist.',
        'This one\'s in your likes. $title, $artist.',
      ] else ...<String>[
        switch (mood) {
          PersonalDjMood.chill =>
            'Keeping it smooth. $title, by $artist.',
          PersonalDjMood.hype =>
            'This should hit. $title, from $artist.',
          PersonalDjMood.discover =>
            'Found something fresh for you. $title, by $artist.',
          PersonalDjMood.mixed =>
            'This fits where you\'ve been. $title, by $artist.',
        },
        'Coming up — $title, from $artist.',
        'Next on the mix — $artist, with $title.',
        'Let\'s keep it moving. $title, by $artist.',
      ],
    ]);

    final display = liked
        ? 'You\'ve liked this one — $title.'
        : switch (mood) {
            PersonalDjMood.chill => 'Keeping it mellow — $title, by $artist.',
            PersonalDjMood.hype => 'This should hit — $title.',
            PersonalDjMood.discover => 'Something new — $title, by $artist.',
            PersonalDjMood.mixed => 'Up next: $title, by $artist.',
          };

    return DjLine(display: display, spoken: spoken);
  }

  /// Splits spoken lines into short phrases for paced, human delivery.
  static List<String> phrasesForDelivery(String spoken) {
    final normalized = spoken
        .replaceAll('—', ', ')
        .replaceAll(' - ', ', ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    final sentences = normalized
        .split(RegExp(r'(?<=[.!?])\s+'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    final out = <String>[];
    for (final sentence in sentences) {
      final trimmed = sentence.trim();
      if (trimmed.length <= 72) {
        out.add(trimmed);
        continue;
      }

      final parts = trimmed.split(RegExp(r',\s*'));
      var buffer = '';
      for (final part in parts) {
        final next = buffer.isEmpty ? part : '$buffer, $part';
        if (next.length > 72 && buffer.isNotEmpty) {
          out.add(buffer);
          buffer = part;
        } else {
          buffer = next;
        }
      }
      if (buffer.isNotEmpty) out.add(buffer);
    }

    return out.isEmpty ? <String>[normalized] : out;
  }

  static List<String> _moodSpokenHooks(PersonalDjMood mood) => switch (mood) {
        PersonalDjMood.chill => <String>[
          'We\'re keeping it low-key tonight.',
          'Easy energy on this one.',
        ],
        PersonalDjMood.hype => <String>[
          'Turning the energy up for you.',
          'Let\'s run something with a little more bounce.',
        ],
        PersonalDjMood.discover => <String>[
          'I\'m leaning into some new lanes for you.',
          'Let\'s stretch your taste a little.',
        ],
        PersonalDjMood.mixed => <String>[
          'I built this straight from your taste.',
          'This mix is all you.',
        ],
      };

  static String _displayOpener({
    required DeezerTrack seed,
    required bool fromLiked,
    required bool fromRecent,
    required PersonalDjMood mood,
    required String title,
    required String artist,
  }) {
    final moodLine = switch (mood) {
      PersonalDjMood.chill => "Let's ease in with something smooth.",
      PersonalDjMood.hype => 'Turning the energy up for you.',
      PersonalDjMood.discover =>
        "I'll lean into fresh picks you haven't heard here yet.",
      PersonalDjMood.mixed => 'I built a mix from your taste.',
    };
    if (fromLiked) {
      return '$moodLine Starting from your liked songs — $title by $artist.';
    }
    if (fromRecent) {
      return "$moodLine You've had $artist on repeat — here's a set that matches.";
    }
    return '$moodLine First up: $title by $artist.';
  }

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
