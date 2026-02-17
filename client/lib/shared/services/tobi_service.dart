import 'dart:convert';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tobi_todo/shared/providers/tobi_provider.dart';

class TobiService {
  final Ref ref;
  final Map<String, int> _frameCounts = {};

  TobiService(this.ref) {
    _init();
  }

  Future<void> _init() async {
    try {
      final manifest = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> map = json.decode(manifest) as Map<String, dynamic>;
      for (final key in map.keys) {
        // keys are asset paths like 'assets/tobi_animations/<anim>/frame_000.png'
        if (key.contains('assets/tobi_animations/')) {
          final parts = key.split('/');
          // parts: ['assets','tobi_animations','<anim>','frame_000.png']
          if (parts.length >= 4) {
            final anim = parts[2];
            _frameCounts[anim] = (_frameCounts[anim] ?? 0) + 1;
          }
        }
      }
    } catch (e) {
      // ignore, we'll fallback to defaults
    }
  }

  int getFrameCount(String name, {int fallback = 36}) {
    return _frameCounts[name] ?? fallback;
  }

  /// Play a raw animation by name.
  void play(String name, {int? fps, bool loop = false}) {
    final count = getFrameCount(name);
    ref.read(tobiControllerProvider).play(name, frameCount: count, fps: fps ?? 12, loop: loop);
  }

  // Convenience reactions
  void celebrate() => play('jump_celebrate', fps: 14, loop: false);
  void punchCelebrate() => play('punch_celebrate', fps: 14, loop: false);
  void sad() => play('sad', fps: 12, loop: false);
  void think() => play('think', fps: 12, loop: false);
  void wave() => play('wave', fps: 12, loop: false);
  void dance() => play('dance', fps: 14, loop: false);

  /// Return whether Tobi should appear on a given navigation index.
  bool shouldShowOnIndex(int index) {
    // Default: show on Dashboard, Plan, Focus, Growth (0..3), hide on Profile (4)
    return index >= 0 && index <= 3;
  }
}

final tobiServiceProvider = Provider<TobiService>((ref) {
  return TobiService(ref);
});
