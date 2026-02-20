import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tobi_todo/shared/models/tobi_state.dart';
import 'package:tobi_todo/shared/services/tobi_service.dart';

/// A Riverpod Notifier that mirrors the Tobi visual state. This lets other
/// widgets subscribe via `ref.watch(tobiNotifierProvider)` while the
/// `TobiService`/`TobiController` singletons can still be used directly.
class TobiNotifier extends Notifier<TobiState> {
  Timer? _revertTimer;

  @override
  TobiState build() {
    return const TobiState(animationName: 'idle');
  }

  void _setState(TobiState s) {
    state = s;
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

final tobiNotifierProvider = NotifierProvider<TobiNotifier, TobiState>(TobiNotifier.new);

/// Provide access to the singleton `TobiService` for any remaining call-sites
/// that use a provider instead of the direct singleton API.
final tobiServiceProvider = Provider<TobiService>((ref) => TobiService.instance);
