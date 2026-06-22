import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/api/models/deezer_track.dart';
import '../../core/storage/library_providers.dart';
import '../../core/theme/app_theme.dart';

void showAddToPlaylistSheet(BuildContext context, DeezerTrack track) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _AddToPlaylistSheet(track: track),
  );
}

class _AddToPlaylistSheet extends ConsumerStatefulWidget {
  const _AddToPlaylistSheet({required this.track});

  final DeezerTrack track;

  @override
  ConsumerState<_AddToPlaylistSheet> createState() => _AddToPlaylistSheetState();
}

class _AddToPlaylistSheetState extends ConsumerState<_AddToPlaylistSheet> {
  final _controller = TextEditingController();
  bool _creating = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _createAndAdd() async {
    final title = _controller.text.trim();
    if (title.isEmpty) return;

    final pl = await ref.read(userPlaylistsProvider.notifier).create(
          title: title,
          coverUrl: widget.track.album?.coverBig ?? widget.track.album?.cover,
        );
    await ref.read(localPlaylistTracksProvider.notifier).addTrack(pl.id, widget.track);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeScope.of(context);
    final playlists = ref.watch(userPlaylistsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (ctx, controller) {
        return Container(
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.onSurfaceMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Add to Playlist',
                style: TextStyle(
                  color: theme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              if (_creating)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          autofocus: true,
                          style: TextStyle(color: theme.onSurface),
                          decoration: InputDecoration(
                            hintText: 'Playlist name',
                            hintStyle: TextStyle(color: theme.onSurfaceMuted),
                            filled: true,
                            fillColor: theme.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (_) => _createAndAdd(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(PhosphorIconsRegular.check, color: theme.accent),
                        onPressed: _createAndAdd,
                      ),
                    ],
                  ),
                )
              else
                ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(PhosphorIconsRegular.plus, color: theme.accent),
                  ),
                  title: Text(
                    'New Playlist',
                    style: TextStyle(color: theme.onSurface, fontWeight: FontWeight.w600),
                  ),
                  onTap: () => setState(() => _creating = true),
                ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: playlists.length,
                  itemBuilder: (ctx, i) {
                    final pl = playlists[i];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: pl.pictureBig != null
                            ? CachedNetworkImage(
                                imageUrl: pl.pictureBig!,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 48,
                                height: 48,
                                color: theme.background,
                                child: Icon(PhosphorIconsRegular.musicNotes, color: theme.onSurfaceMuted),
                              ),
                      ),
                      title: Text(
                        pl.title,
                        style: TextStyle(color: theme.onSurface, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${pl.nbTracks ?? 0} tracks',
                        style: TextStyle(color: theme.onSurfaceMuted, fontSize: 13),
                      ),
                      onTap: () async {
                        final nav = Navigator.of(context);
                        await ref.read(localPlaylistTracksProvider.notifier).addTrack(pl.id, widget.track);
                        nav.pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
