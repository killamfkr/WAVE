import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'personal_dj_providers.dart';
import 'player_providers.dart';

/// Keeps Personal DJ liner text in sync when the current track changes.
class PersonalDjBootstrap extends ConsumerWidget {
  const PersonalDjBootstrap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(playerSnapshotProvider, (previous, next) {
      final track = next.currentTrack;
      final prevTrack = previous?.currentTrack;
      if (track?.id != prevTrack?.id) {
        ref.read(personalDjProvider.notifier).onTrackChanged(track);
      }
    });
    ref.listen(queueSnapshotProvider, (previous, next) {
      final count = next.upcoming.length;
      final prevCount = previous?.upcoming.length;
      if (count != prevCount) {
        ref.read(personalDjProvider.notifier).maybeRefillQueue(count);
      }
    });
    return const SizedBox.shrink();
  }
}
