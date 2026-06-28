import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/api/models/player_state.dart';
import '../../core/audio/personal_dj_providers.dart';
import '../../core/audio/personal_dj_service.dart';
import '../../core/audio/player_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/player/play_pause_button.dart';
import '../../widgets/player/progress_bar.dart';
import '../../widgets/player/waveform_bars.dart';

/// Spotify-style Personal DJ — personalized mix with liner commentary.
class PersonalDjScreen extends ConsumerStatefulWidget {
  const PersonalDjScreen({super.key});

  @override
  ConsumerState<PersonalDjScreen> createState() => _PersonalDjScreenState();
}

class _PersonalDjScreenState extends ConsumerState<PersonalDjScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = AppThemeScope.of(context);
    final dj = ref.watch(personalDjProvider);
    final player = ref.watch(playerSnapshotProvider);

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: dj.isActive
            ? _ActiveDjView(
                theme: theme,
                dj: dj,
                player: player,
                onEnd: () async {
                  await ref.read(personalDjProvider.notifier).endSession();
                  if (context.mounted) context.pop();
                },
                onMood: (mood) =>
                    ref.read(personalDjProvider.notifier).setMood(mood),
              )
            : _StartDjView(
                theme: theme,
                dj: dj,
                onStart: (mood) async {
                  final ok = await ref
                      .read(personalDjProvider.notifier)
                      .startSession(mood: mood);
                  if (!ok && context.mounted) {
                    final msg = ref.read(personalDjProvider).errorMessage;
                    if (msg != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(msg)),
                      );
                    }
                  }
                },
              ),
      ),
    );
  }
}

class _StartDjView extends StatefulWidget {
  const _StartDjView({
    required this.theme,
    required this.dj,
    required this.onStart,
  });

  final AppTheme theme;
  final PersonalDjState dj;
  final Future<void> Function(PersonalDjMood mood) onStart;

  @override
  State<_StartDjView> createState() => _StartDjViewState();
}

class _StartDjViewState extends State<_StartDjView> {
  PersonalDjMood _mood = PersonalDjMood.mixed;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    return Column(
      children: <Widget>[
        _TopBar(
          theme: theme,
          title: 'Personal DJ',
          onClose: () => context.pop(),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        theme.accent,
                        theme.accent.withValues(alpha: 0.55),
                      ],
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: theme.accent.withValues(alpha: 0.35),
                        blurRadius: 32,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    PhosphorIconsFill.headphones,
                    color: theme.background,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Your Personal DJ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.onSurface,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'A continuous mix from your taste — your DJ talks between tracks.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.onSurfaceMuted,
                    fontSize: 14,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                _VoiceToggle(theme: theme, voiceEnabled: widget.dj.voiceEnabled),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'MOOD',
                    style: TextStyle(
                      color: theme.onSurfaceMuted,
                      fontSize: 10,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _MoodPicker(
                  theme: theme,
                  selected: _mood,
                  onSelected: (m) => setState(() => _mood = m),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: widget.dj.isLoading
                  ? null
                  : () => widget.onStart(_mood),
              style: FilledButton.styleFrom(
                backgroundColor: theme.accent,
                foregroundColor: theme.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    theme.cardRadius == 0 ? 0 : 28,
                  ),
                ),
              ),
              child: widget.dj.isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: theme.background,
                      ),
                    )
                  : const Text(
                      'Start DJ session',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActiveDjView extends ConsumerWidget {
  const _ActiveDjView({
    required this.theme,
    required this.dj,
    required this.player,
    required this.onEnd,
    required this.onMood,
  });

  final AppTheme theme;
  final PersonalDjState dj;
  final PlayerState player;
  final VoidCallback onEnd;
  final ValueChanged<PersonalDjMood> onMood;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final track = player.currentTrack;
    final cover = track?.album?.coverXl ?? track?.album?.coverBig;
    final isPlaying = player.status == PlaybackStatus.playing;

    return Column(
      children: <Widget>[
        _TopBar(
          theme: theme,
          title: 'Personal DJ',
          onClose: () => context.pop(),
          trailing: TextButton(
            onPressed: onEnd,
            child: Text(
              'End DJ',
              style: TextStyle(
                color: theme.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 16),
                _DjArtwork(
                  theme: theme,
                  cover: cover,
                  isSpeaking: dj.isSpeaking,
                ),
                const SizedBox(height: 24),
                if (track != null) ...<Widget>[
                  Text(
                    track.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.onSurface,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    track.artist?.name ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.onSurfaceMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                WaveformBars(
                  isPlaying: isPlaying || dj.isSpeaking,
                  height: 72,
                  color: dj.isSpeaking ? theme.accent : theme.accent,
                ),
                const SizedBox(height: 16),
                WaveProgressBar(
                  position: player.position,
                  duration: player.duration,
                  buffered: player.buffered,
                  onSeek: (d) =>
                      ref.read(playerControlsProvider).seek(d),
                ),
                const SizedBox(height: 20),
                _VoiceToggle(
                  theme: theme,
                  voiceEnabled: dj.voiceEnabled,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'MOOD',
                    style: TextStyle(
                      color: theme.onSurfaceMuted,
                      fontSize: 10,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _MoodPicker(
                  theme: theme,
                  selected: dj.mood,
                  onSelected: onMood,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _SkipButton(
                theme: theme,
                icon: PhosphorIconsFill.skipBack,
                onTap: () => ref.read(playerControlsProvider).skipPrevious(),
              ),
              const SizedBox(width: 20),
              PlayPauseButton(
                isPlaying: isPlaying,
                size: 68,
                onTap: () {
                  final controls = ref.read(playerControlsProvider);
                  if (isPlaying) {
                    controls.pause();
                  } else {
                    controls.play();
                  }
                },
              ),
              const SizedBox(width: 20),
              _SkipButton(
                theme: theme,
                icon: PhosphorIconsFill.skipForward,
                onTap: () => ref.read(playerControlsProvider).skipNext(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DjArtwork extends StatefulWidget {
  const _DjArtwork({
    required this.theme,
    required this.cover,
    required this.isSpeaking,
  });

  final AppTheme theme;
  final String? cover;
  final bool isSpeaking;

  @override
  State<_DjArtwork> createState() => _DjArtworkState();
}

class _DjArtworkState extends State<_DjArtwork>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void initState() {
    super.initState();
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant _DjArtwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPulse();
  }

  void _syncPulse() {
    if (widget.isSpeaking) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          if (widget.isSpeaking)
            AnimatedBuilder(
              animation: _pulse,
              builder: (context, _) {
                return Transform.scale(
                  scale: 1.0 + (_pulse.value * 0.1),
                  child: Container(
                    width: 236,
                    height: 236,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.accent.withValues(
                          alpha: 0.35 + (_pulse.value * 0.35),
                        ),
                        width: 2.5,
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: theme.accent.withValues(
                            alpha: 0.2 + (_pulse.value * 0.25),
                          ),
                          blurRadius: 28,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(
              theme.cardRadius == 0 ? 0 : 16,
            ),
            child: SizedBox(
              width: 220,
              height: 220,
              child: widget.cover != null
                  ? CachedNetworkImage(
                      imageUrl: widget.cover!,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          ColoredBox(color: theme.surface),
                      errorWidget: (_, _, _) =>
                          ColoredBox(color: theme.surface),
                    )
                  : ColoredBox(
                      color: theme.surface,
                      child: Icon(
                        PhosphorIconsRegular.musicNote,
                        size: 64,
                        color: theme.onSurfaceMuted,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.theme,
    required this.title,
    required this.onClose,
    this.trailing,
  });

  final AppTheme theme;
  final String title;
  final VoidCallback onClose;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: onClose,
            icon: Icon(PhosphorIconsRegular.caretDown, color: theme.onSurface),
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                Text(
                  'WAVE',
                  style: TextStyle(
                    color: theme.onSurfaceMuted,
                    fontSize: 9,
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    color: theme.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 72,
            child: Align(
              alignment: Alignment.centerRight,
              child: trailing ??
                  const SizedBox(width: 48), // balance close button
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceToggle extends ConsumerWidget {
  const _VoiceToggle({
    required this.theme,
    required this.voiceEnabled,
  });

  final AppTheme theme;
  final bool voiceEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(personalDjProvider.notifier).toggleVoice(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(theme.cardRadius == 0 ? 0 : 20),
          border: Border.all(color: theme.onSurface.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              voiceEnabled
                  ? PhosphorIconsFill.speakerHigh
                  : PhosphorIconsFill.speakerSlash,
              size: 18,
              color: voiceEnabled ? theme.accent : theme.onSurfaceMuted,
            ),
            const SizedBox(width: 8),
            Text(
              voiceEnabled ? 'DJ voice on' : 'DJ voice off',
              style: TextStyle(
                color: voiceEnabled ? theme.onSurface : theme.onSurfaceMuted,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodPicker extends StatelessWidget {
  const _MoodPicker({
    required this.theme,
    required this.selected,
    required this.onSelected,
  });

  final AppTheme theme;
  final PersonalDjMood selected;
  final ValueChanged<PersonalDjMood> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: PersonalDjMood.values.map((mood) {
            final isSelected = mood == selected;
            return GestureDetector(
              onTap: () => onSelected(mood),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.accent.withValues(alpha: 0.18)
                      : theme.surface,
                  borderRadius: BorderRadius.circular(
                    theme.cardRadius == 0 ? 0 : 20,
                  ),
                  border: Border.all(
                    color: isSelected
                        ? theme.accent
                        : theme.onSurface.withValues(alpha: 0.08),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  PersonalDjService.moodLabel(mood),
                  style: TextStyle(
                    color: isSelected ? theme.accent : theme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Text(
          PersonalDjService.moodDescription(selected),
          style: TextStyle(
            color: theme.onSurfaceMuted,
            fontSize: 12,
            height: 1.4,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({
    required this.theme,
    required this.icon,
    required this.onTap,
  });

  final AppTheme theme;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: theme.surface,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: theme.onSurface, size: 22),
      ),
    );
  }
}
