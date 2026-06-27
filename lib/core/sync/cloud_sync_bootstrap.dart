import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cloud_sync_providers.dart';
import 'supabase_sync_config.dart';
import 'wave_cloud_sync_service.dart';

/// Pulls cloud library on startup when a Supabase session exists.
class CloudSyncBootstrap extends ConsumerStatefulWidget {
  const CloudSyncBootstrap({super.key});

  @override
  ConsumerState<CloudSyncBootstrap> createState() => _CloudSyncBootstrapState();
}

class _CloudSyncBootstrapState extends ConsumerState<CloudSyncBootstrap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!SupabaseSyncConfig.isConfigured) return;
      if (!await WaveCloudSyncService.instance.hasStoredSession()) return;
      await ref.read(cloudSyncProvider.notifier).syncNow();
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
