import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/api/deezer_providers.dart';
import '../core/api/lastfm_providers.dart';
import '../core/api/models/deezer_album.dart';
import '../core/api/models/deezer_artist.dart';
import '../core/api/models/deezer_playlist.dart';
import '../core/api/models/deezer_track.dart';
import '../core/app_version_provider.dart';
import '../core/audio/music_player_service.dart';
import '../core/audio/personal_dj_providers.dart';
import '../core/audio/stub_music_player_service.dart';
import '../core/storage/hive_boxes.dart';
import '../core/storage/recently_played.dart';
import '../core/storage/settings_providers.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/themes.dart';
import '../features/dj/personal_dj_screen.dart';
import '../features/home/home_screen.dart';
import '../features/player/now_playing_screen.dart';
import '../features/settings/settings_screen.dart';

/// Web entry for README screenshots. Build with:
/// `flutter build web -t lib/tool/readme_screenshots_app.dart`
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await HiveBoxes.openAll();

  final player = StubMusicPlayerService();
  await player.playTracks(_tracks().take(1).toList());
  final tracks = _tracks();
  final albums = _albums();

  runApp(
    ProviderScope(
      overrides: [
        musicPlayerServiceProvider.overrideWithValue(player),
        chartTracksProvider.overrideWith((ref) async => tracks),
        chartAlbumsProvider.overrideWith((ref) async => albums),
        chartArtistsProvider.overrideWith((ref) async => _artists()),
        chartPlaylistsProvider.overrideWith((ref) async => _playlists()),
        newReleasesProvider.overrideWith((ref) async => albums),
        madeForYouAlbumsProvider.overrideWith((ref) async => albums),
        recommendedTracksProvider.overrideWith((ref) async => tracks),
        recentlyPlayedProvider.overrideWith(_FakeRecentNotifier.new),
        personalDjProvider.overrideWith(_IdleDjNotifier.new),
        appSettingsProvider.overrideWith(_FakeSettingsNotifier.new),
        appVersionProvider.overrideWith(
          (ref) async => const AppVersionInfo(version: '1.2.1', buildNumber: '21'),
        ),
      ],
      child: const _ReadmeScreenshotApp(),
    ),
  );
}

class _ReadmeScreenshotApp extends StatelessWidget {
  const _ReadmeScreenshotApp();

  @override
  Widget build(BuildContext context) {
    final theme = AppThemes.obsidian;
    final screen = Uri.base.queryParameters['screen'] ?? 'home';
    final child = switch (screen) {
      'dj' => const PersonalDjScreen(),
      'settings' => const _ScrolledSettings(),
      'now-playing' => const NowPlayingScreen(),
      _ => const HomeScreen(),
    };

    return AppThemeScope(
      theme: theme,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme.toMaterialTheme(),
        home: _PhoneFrame(child: child),
      ),
    );
  }
}

class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppThemes.obsidian.background,
      child: Center(
        child: SizedBox(
          width: 390,
          height: 844,
          child: child,
        ),
      ),
    );
  }
}

class _ScrolledSettings extends StatefulWidget {
  const _ScrolledSettings();

  @override
  State<_ScrolledSettings> createState() => _ScrolledSettingsState();
}

class _ScrolledSettingsState extends State<_ScrolledSettings> {
  final _controller = ScrollController(initialScrollOffset: 600);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScrollController(
      controller: _controller,
      child: const SettingsScreen(),
    );
  }
}

class _FakeRecentNotifier extends RecentlyPlayedNotifier {
  @override
  List<RecentEntry> build() => <RecentEntry>[
        RecentEntry(
          kind: 'track',
          id: 1,
          title: 'Stronger',
          subtitle: 'Kanye West',
          atMillis: 0,
        ),
        RecentEntry(
          kind: 'track',
          id: 2,
          title: 'Desire',
          subtitle: 'Fil Bo Riva',
          atMillis: 0,
        ),
        RecentEntry(
          kind: 'track',
          id: 3,
          title: "Why'd You Only Call Me When You're High?",
          subtitle: 'Arctic Monkeys',
          atMillis: 0,
        ),
      ];
}

class _FakeSettingsNotifier extends AppSettingsNotifier {
  @override
  AppSettings build() => const AppSettings();
}

class _IdleDjNotifier extends PersonalDjNotifier {
  @override
  PersonalDjState build() => const PersonalDjState();
}

List<DeezerTrack> _tracks() => <DeezerTrack>[
      const DeezerTrack(
        id: 1,
        title: 'Stronger',
        duration: 312,
        rank: 900000,
        artist: DeezerArtist(id: 1, name: 'Kanye West'),
        album: DeezerAlbum(id: 1, title: 'Graduation'),
      ),
      const DeezerTrack(
        id: 2,
        title: 'Desire',
        duration: 185,
        rank: 850000,
        artist: DeezerArtist(id: 2, name: 'Fil Bo Riva'),
        album: DeezerAlbum(id: 2, title: 'Desire'),
      ),
      const DeezerTrack(
        id: 3,
        title: "Why'd You Only Call Me When You're High?",
        duration: 161,
        rank: 800000,
        artist: DeezerArtist(id: 3, name: 'Arctic Monkeys'),
        album: DeezerAlbum(id: 3, title: 'AM'),
      ),
      const DeezerTrack(
        id: 4,
        title: 'Worth It',
        duration: 224,
        rank: 780000,
        artist: DeezerArtist(id: 4, name: 'Fifth Harmony'),
      ),
      const DeezerTrack(
        id: 5,
        title: 'Cheap Thrills',
        duration: 224,
        rank: 760000,
        artist: DeezerArtist(id: 5, name: 'Sia'),
      ),
      const DeezerTrack(
        id: 6,
        title: 'Locked Away',
        duration: 227,
        rank: 740000,
        artist: DeezerArtist(id: 6, name: 'R. City'),
      ),
      const DeezerTrack(
        id: 7,
        title: 'Sahara',
        duration: 183,
        rank: 720000,
        artist: DeezerArtist(id: 7, name: 'SOL.'),
      ),
    ];

List<DeezerAlbum> _albums() => <DeezerAlbum>[
      const DeezerAlbum(
        id: 10,
        title: 'Graduation',
        artist: DeezerArtist(id: 1, name: 'Kanye West'),
      ),
      const DeezerAlbum(
        id: 11,
        title: 'AM',
        artist: DeezerArtist(id: 3, name: 'Arctic Monkeys'),
      ),
      const DeezerAlbum(
        id: 12,
        title: 'Random Access Memories',
        artist: DeezerArtist(id: 8, name: 'Daft Punk'),
      ),
    ];

List<DeezerArtist> _artists() => <DeezerArtist>[
      const DeezerArtist(id: 1, name: 'Kanye West'),
      const DeezerArtist(id: 3, name: 'Arctic Monkeys'),
      const DeezerArtist(id: 8, name: 'Daft Punk'),
    ];

List<DeezerPlaylist> _playlists() => <DeezerPlaylist>[
      const DeezerPlaylist(id: 100, title: 'Hip-Hop Classics', nbTracks: 50),
      const DeezerPlaylist(id: 101, title: 'Chill Vibes', nbTracks: 42),
    ];
