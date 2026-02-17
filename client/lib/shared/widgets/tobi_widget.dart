import 'dart:async';

import 'package:flutter/material.dart';

/// Simple image-sequence player for Tobi animations.
///
/// Usage:
/// - Copy the `tobi-animations` folder into `client/assets/tobi_animations`.
/// - Each animation is a folder named e.g. `idle`, `dance`, `wave`, etc.
/// - Frames should be named `frame_000.png`, `frame_001.png`, ...
class TobiWidget extends StatefulWidget {
  final String animationName;
  final double size;
  final int frameCount;
  final int fps;
  final bool loop;

  const TobiWidget({
    Key? key,
    this.animationName = 'idle',
    this.size = 120,
    this.frameCount = 36,
    this.fps = 12,
    this.loop = true,
  }) : super(key: key);

  @override
  State<TobiWidget> createState() => _TobiWidgetState();
}

class _TobiWidgetState extends State<TobiWidget> {
  late int _index;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _index = 0;
    _start();
  }

  @override
  void didUpdateWidget(covariant TobiWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationName != widget.animationName || oldWidget.fps != widget.fps) {
      _restart();
    }
  }

  void _start() {
    final period = Duration(milliseconds: (1000 / widget.fps).round());
    _timer = Timer.periodic(period, (t) {
      setState(() {
        _index++;
        if (_index >= widget.frameCount) {
          if (widget.loop) {
            _index = 0;
          } else {
            _index = widget.frameCount - 1;
            _timer?.cancel();
          }
        }
      });
    });
  }

  void _restart() {
    _timer?.cancel();
    _index = 0;
    _start();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _framePath(int i) {
    final idx = i.toString().padLeft(3, '0');
    return 'assets/tobi_animations/${widget.animationName}/frame_$idx.png';
  }

  @override
  Widget build(BuildContext context) {
    final path = _framePath(_index);
    return SizedBox(
      height: widget.size,
      width: widget.size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          path,
          fit: BoxFit.contain,
          errorBuilder: (c, e, s) {
            // Fallback: show emoji if asset not found / not yet copied.
            return Container(
              color: Colors.white,
              alignment: Alignment.center,
              child: const Text('🤖', style: TextStyle(fontSize: 56)),
            );
          },
        ),
      ),
    );
  }
}
