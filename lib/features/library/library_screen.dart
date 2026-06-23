import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../core/api/models/deezer_playlist.dart';
import '../../core/api/models/deezer_track.dart';
import '../../core/audio/player_providers.dart';
import '../../core/utils/playlist_exchange.dart';
import '../../core/router/app_router.dart';
import '../../core/storage/library_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/downloads/download_providers.dart';
import '../../core/utils/app_breakpoints.dart';
import '../../main.dart' show scaffoldMessengerKey;
import '../../widgets/content_cards.dart';
import '../../widgets/context_menu.dart';
import '../../widgets/player/add_to_playlist_sheet.dart';
import '../../widgets/section_header.dart';
import '../../widgets/sub_tabs.dart';
import '../../widgets/swipe_action_row.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  int _tab = 0;

  static const List<String> _labels = <String>[
    'Liked',
    'Albums',
    'Playlists',
    'Following',
    'Downloads',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeScope.of(context);
    return ColoredBox(
      color: theme.background,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Text(
              'Your library',
              style: TextStyle(
                color: theme.onSurface,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ),
          WaveSubTabs(
            labels: _labels,
            active: _tab,
            onTap: (i) => setState(() => _tab = i),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: theme.normalDuration,
              switchInCurve: theme.defaultCurve,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.04),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: switch (_tab) {
                0 => const KeyedSubtree(
                    key: ValueKey<String>('liked'),
                    child: _LikedTracksTab(),
                  ),
                1 => const KeyedSubtree(
                    key: ValueKey<String>('albums'),
                    child: _LikedAlbumsTab(),
                  ),
                2 => const KeyedSubtree(
                    key: ValueKey<String>('playlists'),
                    child: _PlaylistsTab(),
                  ),
                3 => const KeyedSubtree(
                    key: ValueKey<String>('following'),
                    child: _FollowingTab(),
                  ),
                _ => const KeyedSubtree(
                    key: ValueKey<String>('downloads'),
                    child: _DownloadsTab(),
                  ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Liked tracks ------------------------------------------------------------

class _LikedTracksTab extends ConsumerWidget {
  const _LikedTracksTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref.watch(likedTracksSortedProvider);
    final sort = ref.watch(likedSortProvider);
    final theme = AppThemeScope.of(context);

    if (tracks.isEmpty) {
      return _EmptyHint(
        icon: PhosphorIconsRegular.heart,
        title: 'Nothing liked yet',
        subtitle: 'Tap the heart on any song to save it here.',
      );
    }

    final totalSecs = tracks.fold<int>(0, (s, t) => s + (t.duration ?? 0));

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${tracks.length} songs · ${_durationText(totalSecs)}',
                        style: TextStyle(
                          color: theme.onSurfaceMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                _PillButton(
                  label: 'Shuffle',
                  icon: PhosphorIconsRegular.shuffle,
                  onTap: () async {
                    final controls = ref.read(playerControlsProvider);
                    await controls.setShuffle(true);
                    await controls.playTracks(tracks);
                  },
                ),
                const SizedBox(width: 8),
                _PillButton(
                  label: 'Play',
                  icon: PhosphorIconsFill.play,
                  filled: true,
                  onTap: () async {
                    final controls = ref.read(playerControlsProvider);
                    await controls.playTracks(tracks);
                  },
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _openSortSheet(context, ref, sort),
              child: Row(
                children: <Widget>[
                  Icon(
                    PhosphorIconsRegular.funnel,
                    size: 14,
                    color: theme.onSurfaceMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _sortLabel(sort),
                    style: TextStyle(
                      color: theme.onSurfaceMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              final t = tracks[i];
              return SwipeActionRow(
                trailingIcon: PhosphorIconsRegular.heartBreak,
                trailingColor: theme.error,
                trailingLabel: 'Unlike',
                onTrailing: () =>
                    ref.read(likedTracksProvider.notifier).remove(t.id),
                leadingIcon: PhosphorIconsRegular.queue,
                leadingColor: theme.accent,
                leadingLabel: 'Queue',
                onLeading: () async {
                  await ref.read(playerControlsProvider).addToQueueLast(t);
                },
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onLongPressStart: (d) => _openTrackMenu(
                    context,
                    ref,
                    t,
                    d.globalPosition,
                  ),
                  child: TrackRow(
                    track: t,
                    queue: tracks,
                    indexInQueue: i,
                  ),
                ),
              );
            },
            childCount: tracks.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  void _openTrackMenu(
    BuildContext context,
    WidgetRef ref,
    DeezerTrack t,
    Offset origin,
  ) {
    showWaveContextMenu(
      context: context,
      origin: origin,
      items: <ContextMenuItem>[
        ContextMenuItem(
          icon: PhosphorIconsRegular.queue,
          label: 'Add to queue',
          onTap: () => ref.read(playerControlsProvider).addToQueueLast(t),
        ),
        ContextMenuItem(
          icon: PhosphorIconsRegular.playlist,
          label: 'Add to playlist',
          onTap: () {
            showAddToPlaylistSheet(context, t);
          },
        ),
        if (t.album != null)
          ContextMenuItem(
            icon: PhosphorIconsRegular.vinylRecord,
            label: 'Go to album',
            onTap: () => context.push(AppRoutes.albumPath(t.album!.id)),
          ),
        if (t.artist != null)
          ContextMenuItem(
            icon: PhosphorIconsRegular.user,
            label: 'Go to artist',
            onTap: () => context.push(AppRoutes.artistPath(t.artist!.id)),
          ),
        ContextMenuItem(
          icon: PhosphorIconsRegular.shareNetwork,
          label: 'Share',
          onTap: () {},
        ),
        ContextMenuItem(
          icon: PhosphorIconsRegular.heartBreak,
          label: 'Remove from liked',
          destructive: true,
          onTap: () => ref.read(likedTracksProvider.notifier).remove(t.id),
        ),
      ],
    );
  }

  Future<void> _openSortSheet(
    BuildContext context,
    WidgetRef ref,
    LikedSort current,
  ) async {
    final theme = AppThemeScope.of(context);
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'sort',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: theme.normalDuration,
      pageBuilder: (_, _, _) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(
                  theme.cardRadius == 0 ? 0 : 18,
                ),
                border: Border.all(
                  color: theme.onSurface.withValues(alpha: 0.06),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: theme.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    'Sort by',
                    style: TextStyle(
                      color: theme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final s in LikedSort.values)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        ref.read(likedSortProvider.notifier).set(s);
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              s == current
                                  ? PhosphorIconsFill.checkCircle
                                  : PhosphorIconsRegular.circle,
                              color: s == current
                                  ? theme.accent
                                  : theme.onSurfaceMuted,
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _sortLabel(s),
                              style: TextStyle(
                                color: theme.onSurface,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, _, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          ),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
    );
  }
}

String _sortLabel(LikedSort s) {
  switch (s) {
    case LikedSort.recent:
      return 'Recently liked';
    case LikedSort.alphabetical:
      return 'Title (A–Z)';
    case LikedSort.artist:
      return 'Artist';
    case LikedSort.duration:
      return 'Duration';
  }
}

String _durationText(int totalSecs) {
  final h = totalSecs ~/ 3600;
  final m = (totalSecs % 3600) ~/ 60;
  if (h > 0) return '${h}h ${m}m';
  return '${m}m';
}

// ---------------------------------------------------------------------------
// Liked albums ------------------------------------------------------------

class _LikedAlbumsTab extends ConsumerWidget {
  const _LikedAlbumsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albums = ref.watch(likedAlbumsProvider);
    if (albums.isEmpty) {
      return _EmptyHint(
        icon: PhosphorIconsRegular.vinylRecord,
        title: 'No saved albums',
        subtitle: 'Albums you save will appear here.',
      );
    }
    final cols = AppBreakpoints.isDesktop(context)
        ? 4
        : AppBreakpoints.isTablet(context)
            ? 3
            : 2;
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.74,
      ),
      itemCount: albums.length,
      itemBuilder: (context, i) =>
          AlbumCard(album: albums[i], size: double.infinity),
    );
  }
}

// ---------------------------------------------------------------------------
// User playlists ----------------------------------------------------------

class _PlaylistsTab extends ConsumerWidget {
  const _PlaylistsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localLists = ref.watch(userPlaylistsProvider);
    final likedLists = ref.watch(likedPlaylistsProvider);
    final theme = AppThemeScope.of(context);

    final buttonsRow = Row(
      children: <Widget>[
        Expanded(child: _buildCreateButton(context, theme, ref)),
        const SizedBox(width: 12),
        Expanded(child: _buildImportButton(context, theme, ref)),
      ],
    );

    if (localLists.isEmpty && likedLists.isEmpty) {
      return Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: buttonsRow,
          ),
          Expanded(
            child: _EmptyHint(
              icon: PhosphorIconsRegular.playlist,
              title: 'No playlists yet',
              subtitle: 'Tap "Create playlist" or like a playlist to save it here.',
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: <Widget>[
        buttonsRow,
        const SizedBox(height: 12),
        if (localLists.isNotEmpty) ...<Widget>[
          const SectionHeader(title: 'My Playlists'),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: localLists.length,
            itemBuilder: (context, i) {
              final p = localLists[i];
              return SwipeActionRow(
                key: ValueKey<int>(p.id),
                trailingIcon: PhosphorIconsRegular.trash,
                trailingColor: theme.error,
                trailingLabel: 'Delete',
                onTrailing: () => ref.read(userPlaylistsProvider.notifier).delete(p.id),
                child: _buildPlaylistRow(context, theme, p, isLocal: true, index: i),
              );
            },
            onReorder: (a, b) => ref.read(userPlaylistsProvider.notifier).reorder(a, b),
          ),
        ],
        if (likedLists.isNotEmpty) ...<Widget>[
          const SectionHeader(title: 'Liked Playlists'),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: likedLists.length,
            itemBuilder: (context, i) {
              final p = likedLists[i];
              return SwipeActionRow(
                key: ValueKey<String>('liked_${p.id}'),
                trailingIcon: PhosphorIconsRegular.heartBreak,
                trailingColor: theme.error,
                trailingLabel: 'Unlike',
                onTrailing: () => ref.read(likedPlaylistsProvider.notifier).toggle(p),
                child: _buildPlaylistRow(context, theme, p, isLocal: false),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildCreateButton(BuildContext context, AppTheme theme, WidgetRef ref) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openCreate(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: theme.accent,
          borderRadius: BorderRadius.circular(
            theme.cardRadius == 0 ? 0 : 12,
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              PhosphorIconsRegular.plus,
              color: theme.background,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              'Create playlist',
              style: TextStyle(
                color: theme.background,
                fontWeight: FontWeight.w800,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistRow(
    BuildContext context,
    AppTheme theme,
    DeezerPlaylist p, {
    required bool isLocal,
    int? index,
  }) {
    final hasCover = (p.pictureMedium ?? p.picture) != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push(AppRoutes.playlistPath(p.id)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(
            theme.cardRadius == 0 ? 0 : 10,
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 56,
              height: 56,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: theme.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: hasCover
                  ? CachedNetworkImage(
                      imageUrl: p.pictureMedium ?? p.picture!,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => ColoredBox(color: theme.surface),
                      errorWidget: (_, _, _) => Icon(
                        PhosphorIconsRegular.musicNotes,
                        color: theme.onSurfaceMuted,
                      ),
                    )
                  : Icon(
                      PhosphorIconsRegular.musicNotes,
                      color: theme.onSurfaceMuted,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    p.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isLocal
                        ? '${p.nbTracks ?? 0} tracks'
                        : 'Playlist · by ${p.creator?.name ?? 'Deezer'}',
                    style: TextStyle(
                      color: theme.onSurfaceMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isLocal && index != null)
              ReorderableDragStartListener(
                index: index,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Icon(
                    PhosphorIconsRegular.dotsSixVertical,
                    color: theme.onSurfaceMuted,
                    size: 18,
                  ),
                ),
              )
            else if (isLocal)
              Icon(
                PhosphorIconsRegular.dotsSixVertical,
                color: theme.onSurfaceMuted,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCreate(BuildContext context, WidgetRef ref) async {
    final theme = AppThemeScope.of(context);
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'create',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: theme.normalDuration,
      pageBuilder: (_, _, _) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            child: StatefulBuilder(
              builder: (context, setLocal) => Container(
                margin: const EdgeInsets.fromLTRB(12, 80, 12, 24),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(
                    theme.cardRadius == 0 ? 0 : 18,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: theme.onSurface.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      'New playlist',
                      style: TextStyle(
                        color: theme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _UnderlineField(
                      controller: nameCtrl,
                      hint: 'Playlist name',
                    ),
                    const SizedBox(height: 14),
                    _UnderlineField(
                      controller: descCtrl,
                      hint: 'Description (optional)',
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pop(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            child: Text(
                              'CANCEL',
                              style: TextStyle(
                                color: theme.onSurfaceMuted,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.4,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () async {
                            if (nameCtrl.text.trim().isEmpty) return;
                            await ref
                                .read(userPlaylistsProvider.notifier)
                                .create(
                                  title: nameCtrl.text.trim(),
                                  description: descCtrl.text.trim().isEmpty
                                      ? null
                                      : descCtrl.text.trim(),
                                  public: true,
                                );
                            if (context.mounted) {
                              Navigator.of(
                                context,
                                rootNavigator: true,
                              ).pop();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: theme.accent,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'CREATE',
                              style: TextStyle(
                                color: theme.background,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.4,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, _, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
          ),
          child: child,
        );
      },
    );
  }

  Widget _buildImportButton(BuildContext context, AppTheme theme, WidgetRef ref) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openImport(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: theme.surface,
          border: Border.all(color: theme.onSurface.withValues(alpha: 0.12)),
          borderRadius: BorderRadius.circular(
            theme.cardRadius == 0 ? 0 : 12,
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              PhosphorIconsRegular.downloadSimple,
              color: theme.onSurface,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              'Import playlist',
              style: TextStyle(
                color: theme.onSurface,
                fontWeight: FontWeight.w800,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openImport(BuildContext context, WidgetRef ref) async {
    // Safe snackbar helper — swallows any Flutter internal assertion.
    void snack(String msg) {
      try {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text(msg)),
        );
      } catch (_) {}
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return;

    final path = result.files.single.path;
    if (path == null) return;

    String? successTitle;
    String? errorMsg;
    try {
      final jsonStr = await File(path).readAsString();
      final pl = await PlaylistExchange.importFromJson(
        jsonStr,
        ref.read(userPlaylistsProvider.notifier),
        ref.read(localPlaylistTracksProvider.notifier),
      );
      successTitle = pl.title;
    } catch (e) {
      errorMsg = e.toString();
    }

    if (successTitle != null) {
      snack('Successfully imported "$successTitle"');
    } else {
      snack('Import failed: $errorMsg');
    }
  }
}

// ---------------------------------------------------------------------------
// Following ---------------------------------------------------------------

class _FollowingTab extends ConsumerWidget {
  const _FollowingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artists = ref.watch(followedArtistsProvider);
    if (artists.isEmpty) {
      return _EmptyHint(
        icon: PhosphorIconsRegular.user,
        title: 'No artists followed',
        subtitle: 'Follow an artist to see them here.',
      );
    }
    final cols = AppBreakpoints.isDesktop(context)
        ? 5
        : AppBreakpoints.isTablet(context)
            ? 4
            : 3;
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.70,
      ),
      itemCount: artists.length,
      itemBuilder: (context, i) =>
          ArtistCircle(artist: artists[i], size: double.infinity),
    );
  }
}

// ---------------------------------------------------------------------------
// Downloads ---------------------------------------------------------------

class _DownloadsTab extends ConsumerWidget {
  const _DownloadsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloaded = ref.watch(downloadedTracksProvider);
    
    if (downloaded.isEmpty) {
      return _EmptyHint(
        icon: PhosphorIconsRegular.cloudArrowDown,
        title: 'No downloads',
        subtitle: 'Downloaded tracks for offline play will appear here.',
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: downloaded.length,
      itemBuilder: (context, i) {
        final t = downloaded[i];
        return Stack(
          children: <Widget>[
            TrackRow(track: t, queue: downloaded, indexInQueue: i),
            Positioned(
              top: 8,
              right: 12,
              child: Icon(
                PhosphorIconsFill.cloudCheck,
                color: AppThemeScope.of(context).accent,
                size: 14,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers -----------------------------------------------------------------

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeScope.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: theme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.accent.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Icon(icon, color: theme.accent, size: 36),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: TextStyle(
                color: theme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(color: theme.onSurfaceMuted, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeScope.of(context);
    final fg = filled ? theme.background : theme.onSurface;
    final bg = filled ? theme.accent : theme.surface;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: filled
                ? theme.accent
                : theme.onSurface.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnderlineField extends StatelessWidget {
  const _UnderlineField({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeScope.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.onSurface.withValues(alpha: 0.2),
            width: 1.4,
          ),
        ),
      ),
      child: TextField(
        controller: controller,
        cursorColor: theme.accent,
        cursorWidth: 1.5,
        style: TextStyle(
          color: theme.onSurface,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(
            color: theme.onSurfaceMuted,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
