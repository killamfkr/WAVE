import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../api/models/deezer_track.dart';
import '../storage/hive_boxes.dart';

class DownloadedTracksNotifier extends Notifier<List<DeezerTrack>> {
  @override
  List<DeezerTrack> build() {
    _box.watch().listen((_) => _load());
    return _getTracks();
  }

  Box<dynamic> get _box => Hive.box<dynamic>(HiveBoxes.downloads);

  List<DeezerTrack> _getTracks() {
    final list = <DeezerTrack>[];
    for (final val in _box.values) {
      if (val is Map) {
        try {
          final map = Map<String, dynamic>.from(val);
          final deepMap = jsonDecode(jsonEncode(map)) as Map<String, dynamic>;
          list.add(DeezerTrack.fromJson(deepMap));
        } catch (_) {}
      }
    }
    return list;
  }

  void _load() {
    state = _getTracks();
  }
}

final downloadedTracksProvider =
    NotifierProvider<DownloadedTracksNotifier, List<DeezerTrack>>(
  DownloadedTracksNotifier.new,
);
