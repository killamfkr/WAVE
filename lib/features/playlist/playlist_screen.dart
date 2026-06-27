import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/api/deezer_providers.dart';
import '../../core/api/models/deezer_playlist.dart';
import '../../core/api/models/deezer_track.dart';
import '../../core/audio/player_providers.dart';
import '../../core/storage/library_providers.dart';
import '../../core/utils/playlist_exchange.dart';
import '../../core/theme/app_theme.dart';
import '../../core/app_messenger.dart' show scaffoldMessengerKey;
import '../../widgets/detail_track_row.dart';
import '../../widgets/inline_error.dart';
import '../../widgets/play_shuffle_pair.dart';
import '../../widgets/shimmer.dart';

class PlaylistScreen extends ConsumerStatefulWidget {
  const PlaylistScreen({super.key, required this.playlistId});
  final int playlistId;

  @override
  ConsumerState<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends ConsumerState<PlaylistScreen> {
  bool _editing = false;
  bool _showCoverViewer = false;
  late final TextEditingController _titleCtrl = TextEditingController();
  late final TextEditingController _descCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  bool get _isUserPlaylist => widget.playlistId < 0;

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeScope.of(context);
    final asyncPl = ref.watch(playlistProvider(widget.playlistId));
    final likedPlaylists = ref.watch(likedPlaylistsProvider);
    final isLiked = likedPlaylists.any((p) => p.id == widget.playlistId);

    List<DeezerTrack>? directTracks;
    AsyncValue<List<DeezerTrack>>? asyncTracks;

    if (_isUserPlaylist) {
      directTracks = ref.watch(localPlaylistTracksProvider)[widget.playlistId] ?? const <DeezerTrack>[];
    } else {
      asyncTracks = ref.watch(playlistTracksProvider(widget.playlistId));
    }

    return Scaffold(
      backgroundColor: theme.background,
      body: Stack(
        children: <Widget>[
          SafeArea(
            child: asyncPl.when(
              loading: () => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: <Widget>[
                      const ShimmerSquare(size: 200),
                      const SizedBox(height: 16),
                      ShimmerBox(
                        width: MediaQuery.of(context).size.width - 48,
                        height: 24,
                      ),
                    ],
                  ),
                ),
              ),
              error: (e, _) => Center(
                child: InlineError(
                  message: 'Could not load playlist',
                  onRetry: () =>
                      ref.invalidate(playlistProvider(widget.playlistId)),
                ),
              ),
              data: (pl) => _buildBody(theme, pl, asyncTracks, directTracks, isLiked),
            ),
          ),
          if (_showCoverViewer)
            _CoverViewer(
              imageUrl: asyncPl.maybeWhen(
                data: (p) => p.pictureXl ?? p.pictureBig ?? p.picture,
                orElse: () => null,
              ),
              onClose: () => setState(() => _showCoverViewer = false),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(
    AppTheme theme,
    DeezerPlaylist pl,
    AsyncValue<List<DeezerTrack>>? asyncTracks,
    List<DeezerTrack>? directTracks,
    bool isLiked,
  ) {
    final cover =
        pl.pictureBig ?? pl.pictureXl ?? pl.pictureMedium ?? pl.picture;
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: <Widget>[
        SliverToBoxAdapter(child: _topBar(theme, pl, isLiked)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: <Widget>[
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 260),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.65,
                      child: GestureDetector(
                        onTap: () => setState(() => _showCoverViewer = true),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                                theme.cardRadius == 0 ? 0 : 12),
                            child: cover != null
                                ? CachedNetworkImage(
                                    imageUrl: cover,
                                    fit: BoxFit.cover,
                                    placeholder: (_, _) =>
                                        ColoredBox(color: theme.surface),
                                    errorWidget: (_, _, _) =>
                                        ColoredBox(color: theme.surface),
                                  )
                                : ColoredBox(color: theme.surface),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _editing
                    ? _editableHeader(theme, pl)
                    : _staticHeader(theme, pl),
                const SizedBox(height: 14),
                if (_isUserPlaylist) _editToggle(theme, pl),
                const SizedBox(height: 8),
                PlayShufflePair(
                  onPlay: () {
                    final tracks = directTracks ?? asyncTracks?.maybeWhen(
                      data: (t) => t,
                      orElse: () => const <DeezerTrack>[],
                    ) ?? const <DeezerTrack>[];
                    if (tracks.isNotEmpty) {
                      ref.read(playerControlsProvider).playTracks(tracks);
                    }
                  },
                  onShuffle: () async {
                    final tracks = directTracks ?? asyncTracks?.maybeWhen(
                      data: (t) => t,
                      orElse: () => const <DeezerTrack>[],
                    ) ?? const <DeezerTrack>[];
                    if (tracks.isEmpty) return;
                    final controls = ref.read(playerControlsProvider);
                    await controls.setShuffle(true);
                    await controls.playTracks(tracks);
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        if (directTracks != null)
          ...(_isUserPlaylist
              ? <Widget>[_userReorderableList(directTracks)]
              : <Widget>[_staticList(directTracks)])
        else
          ...(asyncTracks!.hasValue
              ? (_isUserPlaylist
                  ? <Widget>[_userReorderableList(asyncTracks.value!)]
                  : <Widget>[_staticList(asyncTracks.value!)])
              : asyncTracks.when(
                  loading: () => <Widget>[
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, _) => Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          child: ShimmerBox(
                            width: MediaQuery.of(context).size.width - 32,
                            height: 56,
                          ),
                        ),
                        childCount: 8,
                      ),
                    ),
                  ],
                  error: (e, _) => <Widget>[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: InlineError(
                          message: 'Could not load tracks',
                          onRetry: () => ref.invalidate(
                              playlistTracksProvider(widget.playlistId)),
                        ),
                      ),
                    ),
                  ],
                  data: (_) => const <Widget>[],
                )),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _topBar(AppTheme theme, DeezerPlaylist pl, bool isLiked) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 14),
      child: Row(
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                PhosphorIconsRegular.caretLeft,
                color: theme.onSurface,
                size: 22,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'PLAYLIST',
            style: TextStyle(
              color: theme.onSurfaceMuted,
              fontSize: 11,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _exportPlaylist(pl),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    PhosphorIconsRegular.export,
                    color: theme.onSurface,
                    size: 22,
                  ),
                ),
              ),
              if (!_isUserPlaylist)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => ref.read(likedPlaylistsProvider.notifier).toggle(pl),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 12, right: 12),
                    child: Icon(
                      isLiked ? PhosphorIconsFill.heart : PhosphorIconsRegular.heart,
                      color: isLiked ? theme.accent : theme.onSurface,
                      size: 22,
                    ),
                  ),
                )
              else
                const SizedBox(width: 12),
            ],
          ),
        ],
      ),
    );
  }

  Widget _staticHeader(AppTheme theme, DeezerPlaylist pl) {
    final mins = (pl.duration ?? 0) ~/ 60;
    return Column(
      children: <Widget>[
        Text(
          pl.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        if ((pl.description ?? '').isNotEmpty) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            pl.description!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.onSurfaceMuted,
              fontSize: 12,
            ),
          ),
        ],
        const SizedBox(height: 6),
        Text(
          <String>[
            if ((pl.creator?.name ?? '').isNotEmpty) 'by ${pl.creator!.name}',
            if ((pl.fans ?? 0) > 0) '${pl.fans} followers',
            if ((pl.nbTracks ?? 0) > 0) '${pl.nbTracks} tracks',
            if (mins > 0) '${mins}m',
          ].join('  ·  '),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.onSurfaceMuted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _editableHeader(AppTheme theme, DeezerPlaylist pl) {
    return Column(
      children: <Widget>[
        _UnderlineField(
          controller: _titleCtrl..text = _titleCtrl.text.isEmpty
              ? pl.title
              : _titleCtrl.text,
          hint: 'Title',
          fontSize: 20,
        ),
        const SizedBox(height: 10),
        _UnderlineField(
          controller: _descCtrl..text = _descCtrl.text.isEmpty
              ? (pl.description ?? '')
              : _descCtrl.text,
          hint: 'Description',
          fontSize: 12,
        ),
      ],
    );
  }

  Widget _editToggle(AppTheme theme, DeezerPlaylist pl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (_editing) ...<Widget>[
          _PillButton(
            label: 'CANCEL',
            background: Colors.transparent,
            border: theme.onSurface.withValues(alpha: 0.2),
            color: theme.onSurface,
            onTap: () => setState(() => _editing = false),
          ),
          const SizedBox(width: 10),
          _PillButton(
            label: 'SAVE',
            background: theme.accent,
            color: theme.background,
            onTap: () async {
              await ref.read(userPlaylistsProvider.notifier).updatePlaylist(
                    pl.id,
                    title: _titleCtrl.text.trim(),
                    description: _descCtrl.text.trim().isEmpty
                        ? null
                        : _descCtrl.text.trim(),
                  );
              setState(() => _editing = false);
            },
          ),
        ] else ...<Widget>[
          _PillButton(
            label: 'EDIT',
            background: Colors.transparent,
            border: theme.onSurface.withValues(alpha: 0.2),
            color: theme.onSurface,
            onTap: () => setState(() => _editing = true),
          ),
          const SizedBox(width: 10),
          _PillButton(
            label: 'DELETE',
            background: theme.error.withValues(alpha: 0.1),
            border: theme.error,
            color: theme.error,
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: theme.surface,
                  title: Text(
                    'Delete Playlist',
                    style: TextStyle(color: theme.onSurface, fontWeight: FontWeight.bold),
                  ),
                  content: Text(
                    'Are you sure you want to delete "${pl.title}"? This cannot be undone.',
                    style: TextStyle(color: theme.onSurfaceMuted),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'CANCEL',
                        style: TextStyle(color: theme.onSurfaceMuted),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        'DELETE',
                        style: TextStyle(color: theme.error),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                if (!mounted) return;
                final nav = Navigator.of(context);
                await ref.read(userPlaylistsProvider.notifier).delete(pl.id);
                nav.pop();
              }
            },
          ),
        ],
      ],
    );
  }

  Widget _staticList(List<DeezerTrack> tracks) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, i) => DetailTrackRow(
          track: tracks[i],
          queue: tracks,
          indexInQueue: i,
          position: i + 1,
        ),
        childCount: tracks.length,
      ),
    );
  }

  Widget _userReorderableList(List<DeezerTrack> tracks) {
    final theme = AppThemeScope.of(context);
    return SliverReorderableList(
      itemBuilder: (context, i) => Material(
        key: ValueKey<int>(tracks[i].id),
        color: theme.background,
        child: DetailTrackRow(
          track: tracks[i],
          queue: tracks,
          indexInQueue: i,
          position: i + 1,
          dragHandle: true,
        ),
      ),
      itemCount: tracks.length,
      onReorder: (oldIndex, newIndex) {
        ref.read(localPlaylistTracksProvider.notifier).reorderTrack(
              widget.playlistId,
              oldIndex,
              newIndex,
            );
      },
    );
  }

  Future<void> _exportPlaylist(DeezerPlaylist pl) async {
    // Safe snackbar helper — crash-proof regardless of context lifecycle.
    void snack(String msg) {
      try {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text(msg)),
        );
      } catch (_) {}
    }

    final tracksAsync = ref.read(playlistTracksProvider(pl.id));
    List<DeezerTrack> tracks = [];
    if (_isUserPlaylist) {
      tracks = ref.read(localPlaylistTracksProvider)[pl.id] ?? [];
    } else {
      tracks = tracksAsync.maybeWhen(
        data: (t) => t,
        orElse: () => const <DeezerTrack>[],
      );
    }

    if (tracks.isEmpty) {
      snack('Cannot export an empty playlist.');
      return;
    }

    final safeTitle = pl.title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    final suggestedName = 'wave_playlist_$safeTitle.json';
    final jsonStr = PlaylistExchange.serialize(pl, tracks);
    final bytes = utf8.encode(jsonStr);

    // Open native save-file dialog — user picks location, no permissions needed.
    // Pass bytes so FilePicker writes the file itself on all platforms.
    final savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Export "${pl.title}"',
      fileName: suggestedName,
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: bytes,
    );

    if (savePath == null) return; // user cancelled or platform handled write

    // On desktop, FilePicker returns the path but doesn't write — do it here.
    try {
      await File(savePath).writeAsBytes(bytes);
      snack('Saved to: $savePath');
    } catch (_) {
      snack('Playlist exported successfully!');
    }
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.background,
    required this.color,
    required this.onTap,
    this.border,
  });
  final String label;
  final Color background;
  final Color color;
  final Color? border;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeScope.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(theme.cardRadius == 0 ? 0 : 999),
          border: border != null ? Border.all(color: border!) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.6,
          ),
        ),
      ),
    );
  }
}

class _UnderlineField extends StatelessWidget {
  const _UnderlineField({
    required this.controller,
    required this.hint,
    required this.fontSize,
  });
  final TextEditingController controller;
  final String hint;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeScope.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.onSurface.withValues(alpha: 0.25),
          ),
        ),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: theme.onSurface,
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
        ),
        cursorColor: theme.accent,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: theme.onSurfaceMuted,
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}

class _CoverViewer extends StatelessWidget {
  const _CoverViewer({required this.imageUrl, required this.onClose});
  final String? imageUrl;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onClose,
        child: ColoredBox(
          color: Colors.black.withValues(alpha: 0.92),
          child: SafeArea(
            child: Stack(
              children: <Widget>[
                if (imageUrl != null)
                  Center(
                    child: InteractiveViewer(
                      maxScale: 4,
                      child: CachedNetworkImage(
                        imageUrl: imageUrl!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onClose,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        PhosphorIconsRegular.x,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
