import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:tobi_todo/shared/models/tobi_state.dart';

/// Singleton controller for Tobi animations using a ValueNotifier so UI can
/// listen via `ValueListenableBuilder` without forcing Riverpod usage.
class TobiController {
  TobiController._internal();
  static final TobiController instance = TobiController._internal();

  final ValueNotifier<TobiState> state = ValueNotifier(const TobiState(animationName: 'idle'));
  Timer? _revertTimer;

  void _setState(TobiState s) {
    state.value = s;
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
    state.dispose();
  }
}
