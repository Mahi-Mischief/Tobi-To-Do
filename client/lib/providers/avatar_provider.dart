import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tobi_todo/models/avatar_config.dart';
import 'package:tobi_todo/services/avatar_remote_service.dart';

class AvatarNotifier extends Notifier<AvatarConfig> {
  String? _loadedUserId;

  @override
  AvatarConfig build() {
    return AvatarConfig.defaults;
  }

  AvatarRemoteService get _remote => AvatarRemoteService(Supabase.instance.client);

  void updatePart({
    String? body,
    String? hairBack,
    String? hairFront,
    String? bangs,
    String? eyebrows,
    String? eyelashes,
    String? pupils,
    String? mouth,
    String? top,
    String? dress,
    String? bottom,
    String? gloves,
    String? shoes,
    String? beard,
    String? hairBonus,
    String? extras,
  }) {
    state = state.copyWith(
      body: body,
      hairBack: hairBack,
      hairFront: hairFront,
      bangs: bangs,
      eyebrows: eyebrows,
      eyelashes: eyelashes,
      pupils: pupils,
      mouth: mouth,
      top: top,
      dress: dress,
      bottom: bottom,
      gloves: gloves,
      shoes: shoes,
      beard: beard,
      hairBonus: hairBonus,
      extras: extras,
    );
  }

  void setConfig(AvatarConfig config) {
    state = config;
  }

  void reset() {
    state = AvatarConfig.defaults;
  }

  Future<void> ensureLoaded(String userId) async {
    if (_loadedUserId == userId) return;

    // First, hydrate from local cache so reloads feel instant even if remote is slow.
    final local = await _loadLocal(userId);
    if (local != null) {
      state = local;
    }

    // Then try Supabase; if it returns data, prefer it over local.
    final remote = await _remote.fetch(userId);
    if (remote != null) {
      state = remote;
      await _saveLocal(userId, remote);
    }

    _loadedUserId = userId;
  }

  Future<void> save(String userId) async {
    await _remote.save(userId, state);
    await _saveLocal(userId, state);
  }

  Future<void> _saveLocal(String userId, AvatarConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatar_config_$userId', jsonEncode(config.toJson()));
  }

  Future<AvatarConfig?> _loadLocal(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('avatar_config_$userId');
    if (raw == null) return null;
    try {
      return AvatarConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}

final avatarProvider = NotifierProvider<AvatarNotifier, AvatarConfig>(AvatarNotifier.new);
