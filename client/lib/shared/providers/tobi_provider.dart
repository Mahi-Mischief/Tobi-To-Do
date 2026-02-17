import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TobiState {
  final String animationName;
  final int frameCount;
  final int fps;
  final bool loop;

  const TobiState({
    required this.animationName,
    this.frameCount = 36,
    this.fps = 12,
    this.loop = true,
  });
}

class TobiController {
  final Ref ref;
  Timer? _revertTimer;

  TobiController(this.ref);

  void _setState(TobiState s) {
    ref.read(tobiStateProvider.notifier).state = s;
  }

  void play(String animationName, {int frameCount = 36, int fps = 12, bool loop = false, int? durationMs}) {
    _revertTimer?.cancel();
    _setState(TobiState(animationName: animationName, frameCount: frameCount, fps: fps, loop: loop));

    if (!loop) {
      final ms = durationMs ?? (1000 * (frameCount / fps)).round();
      _revertTimer = Timer(Duration(milliseconds: ms + 200), () {
        _setState(const TobiState(animationName: 'idle'));
      });
    }
  }

  void idle() {
    _revertTimer?.cancel();
    _setState(const TobiState(animationName: 'idle'));
  }

  void dispose() {
    _revertTimer?.cancel();
  }
}

// Reactive state provider for Tobi's visual state
final tobiStateProvider = StateProvider<TobiState>((ref) {
  return const TobiState(animationName: 'idle');
});

final tobiControllerProvider = Provider<TobiController>((ref) {
  final controller = TobiController(ref);
  ref.onDispose(() => controller.dispose());
  return controller;
});
