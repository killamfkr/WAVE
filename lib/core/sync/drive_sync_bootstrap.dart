import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'drive_sync_providers.dart';

/// Triggers a Drive pull when the app starts and the user is already signed in.
class DriveSyncBootstrap extends ConsumerStatefulWidget {
  const DriveSyncBootstrap({super.key});

  @override
  ConsumerState<DriveSyncBootstrap> createState() => _DriveSyncBootstrapState();
}

class _DriveSyncBootstrapState extends ConsumerState<DriveSyncBootstrap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sync = ref.read(driveSyncProvider);
      if (sync.isSignedIn) {
        ref.read(driveSyncProvider.notifier).syncNow();
      }
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
