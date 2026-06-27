import 'dart:async';
import 'dart:convert';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:hive/hive.dart';

import '../api/models/deezer_playlist.dart';
import '../api/models/deezer_track.dart';
import '../storage/hive_boxes.dart';
import '../storage/library_providers.dart';
import '../storage/user_profile_providers.dart';
import '../utils/app_logger.dart';
import 'drive_sync_config.dart';
import 'google_drive_sync_service.dart';
import 'sync_metadata.dart';
import 'sync_trigger_providers.dart';

const String _kLastSyncedKey = 'drive_last_synced_at';
const String _kGoogleAccountKey = 'drive_google_account_email';

enum DriveSyncPhase { signedOut, signingIn, signedIn, syncing, error }

class DriveSyncState {
  const DriveSyncState({
    this.phase = DriveSyncPhase.signedOut,
    this.accountEmail,
    this.accountName,
    this.accountPhotoUrl,
    this.lastSyncedAt,
    this.errorMessage,
  });

  final DriveSyncPhase phase;
  final String? accountEmail;
  final String? accountName;
  final String? accountPhotoUrl;
  final DateTime? lastSyncedAt;
  final String? errorMessage;

  bool get isSignedIn =>
      phase == DriveSyncPhase.signedIn || phase == DriveSyncPhase.syncing;

  DriveSyncState copyWith({
    DriveSyncPhase? phase,
    String? accountEmail,
    String? accountName,
    String? accountPhotoUrl,
    DateTime? lastSyncedAt,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DriveSyncState(
      phase: phase ?? this.phase,
      accountEmail: accountEmail ?? this.accountEmail,
      accountName: accountName ?? this.accountName,
      accountPhotoUrl: accountPhotoUrl ?? this.accountPhotoUrl,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class DriveSyncNotifier extends Notifier<DriveSyncState> {
  GoogleSignIn? _googleSignIn;
  Timer? _debounce;
  bool _syncInFlight = false;

  @override
  DriveSyncState build() {
    ref.listen<int>(syncTriggerProvider, (previous, next) {
      if (next > 0 && state.isSignedIn) {
        scheduleSync();
      }
    });

    final box = Hive.box<dynamic>(HiveBoxes.settings);
    final email = box.get(_kGoogleAccountKey) as String?;
    final lastSynced = SyncMetadataBox.parseDate(box.get(_kLastSyncedKey));

    if (email != null && email.isNotEmpty && DriveSyncConfig.isConfigured) {
      _ensureGoogleSignIn();
      return DriveSyncState(
        phase: DriveSyncPhase.signedIn,
        accountEmail: email,
        lastSyncedAt: lastSynced,
      );
    }

    return DriveSyncState(lastSyncedAt: lastSynced);
  }

  GoogleSignIn _ensureGoogleSignIn() {
    return _googleSignIn ??= GoogleSignIn(
      scopes: <String>[drive.DriveApi.driveAppdataScope],
      serverClientId: DriveSyncConfig.webClientId,
    );
  }

  Future<void> signIn() async {
    if (!DriveSyncConfig.isConfigured) {
      state = state.copyWith(
        phase: DriveSyncPhase.error,
        errorMessage:
            'Add GOOGLE_WEB_CLIENT_ID to .env to enable Google Drive sync.',
      );
      return;
    }

    state = state.copyWith(
      phase: DriveSyncPhase.signingIn,
      clearError: true,
    );

    try {
      final googleSignIn = _ensureGoogleSignIn();
      final account = await googleSignIn.signIn();
      if (account == null) {
        state = state.copyWith(phase: DriveSyncPhase.signedOut, clearError: true);
        return;
      }

      await _persistAccount(account);
      state = state.copyWith(
        phase: DriveSyncPhase.signedIn,
        accountEmail: account.email,
        accountName: account.displayName,
        accountPhotoUrl: account.photoUrl,
        clearError: true,
      );

      if (account.email.isNotEmpty) {
        await ref.read(userProfileProvider.notifier).setEmail(account.email);
      }
      if ((account.displayName ?? '').trim().isNotEmpty) {
        final current = ref.read(userProfileProvider).displayName;
        if (current == LocalUserProfile.defaultDisplayName) {
          await ref
              .read(userProfileProvider.notifier)
              .setDisplayName(account.displayName!.trim());
        }
      }

      await syncNow();
    } catch (e, st) {
      appLogger.e('Google sign-in failed', error: e, stackTrace: st);
      state = state.copyWith(
        phase: DriveSyncPhase.error,
        errorMessage: 'Sign-in failed. Check your Google OAuth setup.',
      );
    }
  }

  Future<void> signOut() async {
    _debounce?.cancel();
    try {
      await _ensureGoogleSignIn().signOut();
    } catch (_) {}
    await Hive.box<dynamic>(HiveBoxes.settings).delete(_kGoogleAccountKey);
    state = const DriveSyncState(phase: DriveSyncPhase.signedOut);
  }

  void scheduleSync() {
    if (!state.isSignedIn || _syncInFlight) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), () {
      unawaited(syncNow());
    });
  }

  Future<void> syncNow() async {
    if (!DriveSyncConfig.isConfigured) return;
    if (_syncInFlight) return;

    final googleSignIn = _ensureGoogleSignIn();
    var account = googleSignIn.currentUser;
    account ??= await googleSignIn.signInSilently();
    if (account == null) {
      state = state.copyWith(phase: DriveSyncPhase.signedOut);
      return;
    }

    _syncInFlight = true;
    state = state.copyWith(phase: DriveSyncPhase.syncing, clearError: true);

    try {
      final client = await googleSignIn.authenticatedClient();
      if (client == null) {
        throw StateError('Could not authenticate Google Drive client.');
      }

      final service = GoogleDriveSyncService(drive.DriveApi(client));
      await _runSync(service);

      final now = DateTime.now().toUtc();
      await Hive.box<dynamic>(HiveBoxes.settings)
          .put(_kLastSyncedKey, now.toIso8601String());

      state = state.copyWith(
        phase: DriveSyncPhase.signedIn,
        accountEmail: account.email,
        accountName: account.displayName,
        accountPhotoUrl: account.photoUrl,
        lastSyncedAt: now,
        clearError: true,
      );
    } catch (e, st) {
      appLogger.e('Drive sync failed', error: e, stackTrace: st);
      state = state.copyWith(
        phase: DriveSyncPhase.error,
        errorMessage: 'Sync failed. Try again when you are online.',
      );
    } finally {
      _syncInFlight = false;
    }
  }

  Future<void> _runSync(GoogleDriveSyncService service) async {
    final profile = ref.read(userProfileProvider);
    final playlists = ref.read(userPlaylistsProvider);
    final tracksByPlaylist = ref.read(localPlaylistTracksProvider);

    final remoteProfile = await service.downloadProfile();
    final localProfileUpdated = SyncMetadata.profileUpdatedAt();
    if (remoteProfile == null ||
        remoteProfile.updatedAt.isBefore(localProfileUpdated)) {
      await service.uploadProfile(
        profile: profile,
        updatedAt: localProfileUpdated,
      );
    } else if (remoteProfile.updatedAt.isAfter(localProfileUpdated)) {
      await ref
          .read(userProfileProvider.notifier)
          .applyFromSync(remoteProfile.profile);
      await SyncMetadata.setProfileUpdatedAt(remoteProfile.updatedAt);
      await ref.read(userPlaylistsProvider.notifier).syncCreatorFromProfile();
    }

    final remotePlaylists = await service.downloadPlaylists();
    final localIds = playlists.map((p) => p.id).toSet();
    final remoteIds = remotePlaylists.keys.toSet();
    final allIds = <int>{...localIds, ...remoteIds};

    for (final id in allIds) {
      final localUpdated = SyncMetadata.playlistUpdatedAt(id);
      final remote = remotePlaylists[id];
      final isLocallyDeleted = SyncMetadata.deletedPlaylistIds().contains(
        id.toString(),
      );

      if (remote != null && remote.deleted) {
        if (!isLocallyDeleted) {
          await ref.read(userPlaylistsProvider.notifier).removeFromSync(id);
        }
        await service.deletePlaylistFile(id);
        await SyncMetadata.clearPlaylistDeleted(id);
        continue;
      }

      if (isLocallyDeleted) {
        if (remote != null) {
          await service.uploadPlaylist(
            playlist: remote.playlist,
            tracks: remote.tracks,
            updatedAt: remote.updatedAt,
            deleted: true,
          );
        } else {
          final localPlaylist = playlists.where((p) => p.id == id).firstOrNull;
          if (localPlaylist != null) {
            await service.uploadPlaylist(
              playlist: localPlaylist,
              tracks: tracksByPlaylist[id] ?? const <DeezerTrack>[],
              updatedAt: SyncMetadata.playlistUpdatedAt(id) ?? DateTime.now().toUtc(),
              deleted: true,
            );
          }
        }
        continue;
      }

      final localPlaylist = playlists.where((p) => p.id == id).firstOrNull;
      final localTracks = tracksByPlaylist[id] ?? const <DeezerTrack>[];

      if (remote == null && localPlaylist != null) {
        await service.uploadPlaylist(
          playlist: localPlaylist,
          tracks: localTracks,
          updatedAt: localUpdated ?? DateTime.now().toUtc(),
        );
        continue;
      }

      if (localPlaylist == null && remote != null) {
        await ref.read(userPlaylistsProvider.notifier).upsertFromSync(
              playlist: remote.playlist,
              tracks: remote.tracks,
            );
        await SyncMetadata.setPlaylistUpdatedAt(id, remote.updatedAt);
        continue;
      }

      if (localPlaylist != null && remote != null) {
        final remoteUpdated = remote.updatedAt;
        final localTime = localUpdated ?? DateTime.fromMillisecondsSinceEpoch(0);
        if (remoteUpdated.isAfter(localTime)) {
          await ref.read(userPlaylistsProvider.notifier).upsertFromSync(
                playlist: remote.playlist,
                tracks: remote.tracks,
              );
          await SyncMetadata.setPlaylistUpdatedAt(id, remoteUpdated);
        } else if (localTime.isAfter(remoteUpdated)) {
          await service.uploadPlaylist(
            playlist: localPlaylist,
            tracks: localTracks,
            updatedAt: localTime,
          );
        }
      }
    }
  }

  Future<void> _persistAccount(GoogleSignInAccount account) async {
    await Hive.box<dynamic>(HiveBoxes.settings)
        .put(_kGoogleAccountKey, account.email);
  }
}

final driveSyncProvider =
    NotifierProvider<DriveSyncNotifier, DriveSyncState>(
  DriveSyncNotifier.new,
);

/// Small helper so [DriveSyncNotifier] can parse stored sync timestamps.
class SyncMetadataBox {
  SyncMetadataBox._();

  static DateTime? parseDate(Object? raw) {
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw)?.toUtc();
    }
    return null;
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}
