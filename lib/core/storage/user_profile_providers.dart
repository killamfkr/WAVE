import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../api/models/deezer_user.dart';
import 'hive_boxes.dart';

/// Local device profile — not tied to Deezer or any remote auth.
class LocalUserProfile {
  const LocalUserProfile({
    required this.id,
    required this.displayName,
    this.email,
  });

  final String id;
  final String displayName;
  final String? email;

  static const String defaultDisplayName = 'You';
  static const String defaultEmail = 'local@wave.app';

  LocalUserProfile copyWith({
    String? id,
    String? displayName,
    String? email,
    bool clearEmail = false,
  }) {
    return LocalUserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: clearEmail ? null : (email ?? this.email),
    );
  }

  DeezerUser toDeezerUser() {
    return DeezerUser(
      id: id.hashCode,
      name: displayName,
      email: email ?? defaultEmail,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'displayName': displayName,
        if (email != null) 'email': email,
      };

  factory LocalUserProfile.fromJson(Map<String, dynamic> json) {
    return LocalUserProfile(
      id: json['id'] as String? ?? _generateId(),
      displayName:
          (json['displayName'] as String?)?.trim().isNotEmpty == true
              ? json['displayName'] as String
              : defaultDisplayName,
      email: (json['email'] as String?)?.trim().isNotEmpty == true
          ? json['email'] as String
          : defaultEmail,
    );
  }

  factory LocalUserProfile.initial() {
    return LocalUserProfile(
      id: _generateId(),
      displayName: defaultDisplayName,
      email: defaultEmail,
    );
  }
}

String _generateId() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

const String _kUserProfileKey = 'local_user_profile';

class UserProfileNotifier extends Notifier<LocalUserProfile> {
  @override
  LocalUserProfile build() {
    final box = Hive.box<dynamic>(HiveBoxes.settings);
    final raw = box.get(_kUserProfileKey);
    if (raw is String && raw.isNotEmpty) {
      try {
        final json = jsonDecode(raw);
        if (json is Map<String, dynamic>) {
          return LocalUserProfile.fromJson(json);
        }
      } catch (_) {}
    }
    if (raw is Map) {
      return LocalUserProfile.fromJson(raw.cast<String, dynamic>());
    }
    final initial = LocalUserProfile.initial();
    // Persist the generated profile on first launch.
    box.put(_kUserProfileKey, jsonEncode(initial.toJson()));
    return initial;
  }

  Future<void> _persist() async {
    await Hive.box<dynamic>(HiveBoxes.settings)
        .put(_kUserProfileKey, jsonEncode(state.toJson()));
  }

  Future<void> setDisplayName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    state = state.copyWith(displayName: trimmed);
    await _persist();
  }

  Future<void> setEmail(String? email) async {
    final trimmed = email?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      state = state.copyWith(clearEmail: true);
    } else {
      state = state.copyWith(email: trimmed);
    }
    await _persist();
  }
}

final userProfileProvider =
    NotifierProvider<UserProfileNotifier, LocalUserProfile>(
  UserProfileNotifier.new,
);
