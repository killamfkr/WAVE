import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../storage/hive_boxes.dart';
import '../storage/library_providers.dart';
import '../storage/user_profile_providers.dart';
import '../utils/app_logger.dart';
import 'supabase_sync_config.dart';
import 'sync_metadata.dart';
import 'sync_trigger_providers.dart';
import 'wave_cloud_sync_service.dart';
import 'wave_library_bundle.dart';

const String _kLastSyncedKey = 'cloud_last_synced_at';

enum CloudSyncPhase { signedOut, signingIn, signedIn, syncing, error }

class CloudSyncState {
  const CloudSyncState({
    this.phase = CloudSyncPhase.signedOut,
    this.accountEmail,
    this.lastSyncedAt,
    this.errorMessage,
  });

  final CloudSyncPhase phase;
  final String? accountEmail;
  final DateTime? lastSyncedAt;
  final String? errorMessage;

  bool get isSignedIn =>
      phase == CloudSyncPhase.signedIn || phase == CloudSyncPhase.syncing;

  CloudSyncState copyWith({
    CloudSyncPhase? phase,
    String? accountEmail,
    DateTime? lastSyncedAt,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CloudSyncState(
      phase: phase ?? this.phase,
      accountEmail: accountEmail ?? this.accountEmail,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class CloudSyncNotifier extends Notifier<CloudSyncState> {
  final _service = WaveCloudSyncService.instance;
  Timer? _debounce;
  bool _syncInFlight = false;

  @override
  CloudSyncState build() {
    ref.listen<int>(syncTriggerProvider, (previous, next) {
      if (next > 0 && state.isSignedIn) {
        scheduleSync();
      }
    });

    final lastSyncedRaw = Hive.box<dynamic>(HiveBoxes.settings).get(_kLastSyncedKey);
    final lastSynced = lastSyncedRaw is String
        ? DateTime.tryParse(lastSyncedRaw)?.toUtc()
        : null;

    if (SupabaseSyncConfig.isConfigured) {
      Future.microtask(_restoreSessionState);
    }

    return CloudSyncState(lastSyncedAt: lastSynced);
  }

  Future<void> _restoreSessionState() async {
    if (!await _service.hasStoredSession()) return;
    final email = await _service.signedInEmail();
    state = state.copyWith(
      phase: CloudSyncPhase.signedIn,
      accountEmail: email,
      clearError: true,
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      phase: CloudSyncPhase.signingIn,
      clearError: true,
    );
    try {
      await _service.signInWithPassword(email: email, password: password);
      state = state.copyWith(
        phase: CloudSyncPhase.signedIn,
        accountEmail: email.trim(),
        clearError: true,
      );
      await ref.read(userProfileProvider.notifier).setEmail(email.trim());
      await syncNow();
    } on WaveCloudException catch (e) {
      state = state.copyWith(
        phase: CloudSyncPhase.error,
        errorMessage: e.message,
      );
      rethrow;
    } catch (e, st) {
      appLogger.e('Cloud sign-in failed', error: e, stackTrace: st);
      state = state.copyWith(
        phase: CloudSyncPhase.error,
        errorMessage: 'Sign-in failed. Check your email and password.',
      );
      rethrow;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      phase: CloudSyncPhase.signingIn,
      clearError: true,
    );
    try {
      await _service.signUpWithPassword(email: email, password: password);
      state = state.copyWith(
        phase: CloudSyncPhase.signedIn,
        accountEmail: email.trim(),
        clearError: true,
      );
      await ref.read(userProfileProvider.notifier).setEmail(email.trim());
      await syncNow();
    } on WaveCloudException catch (e) {
      state = state.copyWith(
        phase: CloudSyncPhase.error,
        errorMessage: e.message,
      );
      rethrow;
    } catch (e, st) {
      appLogger.e('Cloud sign-up failed', error: e, stackTrace: st);
      state = state.copyWith(
        phase: CloudSyncPhase.error,
        errorMessage: 'Could not create account.',
      );
      rethrow;
    }
  }

  Future<void> signOut() async {
    _debounce?.cancel();
    await _service.signOut();
    state = const CloudSyncState(phase: CloudSyncPhase.signedOut);
  }

  void scheduleSync() {
    if (!state.isSignedIn || _syncInFlight) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 4), () {
      unawaited(syncNow());
    });
  }

  Future<void> syncNow() async {
    if (!SupabaseSyncConfig.isConfigured) return;
    if (_syncInFlight) return;
    if (!await _service.hasStoredSession()) {
      state = state.copyWith(phase: CloudSyncPhase.signedOut);
      return;
    }

    _syncInFlight = true;
    state = state.copyWith(phase: CloudSyncPhase.syncing, clearError: true);

    try {
      await _runSync();
      final now = DateTime.now().toUtc();
      await Hive.box<dynamic>(HiveBoxes.settings)
          .put(_kLastSyncedKey, now.toIso8601String());
      final email = await _service.signedInEmail();
      state = state.copyWith(
        phase: CloudSyncPhase.signedIn,
        accountEmail: email ?? state.accountEmail,
        lastSyncedAt: now,
        clearError: true,
      );
    } on WaveCloudException catch (e) {
      state = state.copyWith(
        phase: CloudSyncPhase.error,
        errorMessage: e.message,
      );
    } catch (e, st) {
      appLogger.e('Cloud sync failed', error: e, stackTrace: st);
      state = state.copyWith(
        phase: CloudSyncPhase.error,
        errorMessage: 'Sync failed. Try again when you are online.',
      );
    } finally {
      _syncInFlight = false;
    }
  }

  Future<void> _runSync() async {
    final localBundle = WaveLibraryBundle.fromLocal(
      profile: ref.read(userProfileProvider),
      playlists: ref.read(userPlaylistsProvider),
      tracksByPlaylistId: ref.read(localPlaylistTracksProvider),
    );
    final remoteBundle = await _service.pullWaveLibrary();

    if (remoteBundle == null) {
      await _service.pushWaveLibrary(localBundle);
      return;
    }

    if (remoteBundle.updatedAt.isAfter(localBundle.updatedAt)) {
      await _applyBundle(remoteBundle);
      await SyncMetadata.setProfileUpdatedAt(remoteBundle.updatedAt);
      return;
    }

    if (localBundle.updatedAt.isAfter(remoteBundle.updatedAt)) {
      await _service.pushWaveLibrary(localBundle);
      return;
    }

    await _service.pushWaveLibrary(localBundle);
  }

  Future<void> _applyBundle(WaveLibraryBundle bundle) async {
    await ref.read(userProfileProvider.notifier).applyFromSync(bundle.profile);

    for (final deletedId in bundle.deletedPlaylistIds) {
      final id = int.tryParse(deletedId);
      if (id != null) {
        await ref.read(userPlaylistsProvider.notifier).removeFromSync(id);
      }
    }

    for (final playlist in bundle.playlists) {
      if (bundle.deletedPlaylistIds.contains(playlist.id.toString())) {
        continue;
      }
      await ref.read(userPlaylistsProvider.notifier).upsertFromSync(
            playlist: playlist,
            tracks: bundle.tracksByPlaylistId[playlist.id] ?? const [],
          );
      await SyncMetadata.setPlaylistUpdatedAt(
        playlist.id,
        bundle.updatedAt,
      );
    }

    await ref.read(userPlaylistsProvider.notifier).syncCreatorFromProfile();
  }
}

final cloudSyncProvider =
    NotifierProvider<CloudSyncNotifier, CloudSyncState>(
  CloudSyncNotifier.new,
);
