import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Incremented when local library data changes and a Drive sync may be needed.
class SyncTriggerNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final syncTriggerProvider = NotifierProvider<SyncTriggerNotifier, int>(
  SyncTriggerNotifier.new,
);
