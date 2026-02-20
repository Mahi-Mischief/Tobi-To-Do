import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tobi_todo/shared/services/tobi_service.dart';

class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> with SingleTickerProviderStateMixin {
  Timer? _timer;
  int _secondsRemaining = 25 * 60; // 25 minute pomodoro
  bool _isRunning = false;
  bool _isBreak = false;
  bool _distractionMode = false;

  int get _sessionTotal => _isBreak ? 5 * 60 : 25 * 60;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    setState(() {
      _isRunning = !_isRunning;
    });

    if (_isRunning) {
      // gentle Tobi acknowledgement when focus starts
      try {
        TobiService.instance.think();
      } catch (_) {}
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _timer?.cancel();
            _isRunning = false;
            // celebrate end of session
            try {
              TobiService.instance.celebrate();
            } catch (_) {}
            _switchMode();
          }
        });
      });
    } else {
      _timer?.cancel();
    }
  }

  void _switchMode() {
    setState(() {
      _isBreak = !_isBreak;
      _secondsRemaining = _isBreak ? 5 * 60 : 25 * 60;
    });
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _isBreak = false;
      _secondsRemaining = 25 * 60;
      _timer?.cancel();
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final bgIdle = const Color(0xFFDEE6F8);
    final bgRunning = const Color(0xFFCDD8F6);

    final progressRatio = _secondsRemaining / _sessionTotal;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        color: _isRunning ? bgRunning : bgIdle,
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Custom header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      children: [
                        const Text('Focus', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2E3A59))),
                        const SizedBox(height: 4),
                        Text(_isBreak ? 'Break — breathe.' : 'Deep work builds your future.', style: const TextStyle(fontSize: 14, color: Color(0xFF6B7A99))),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Animated progress ring (begin 1.0 -> end progressRatio)
                  SizedBox(
                    width: 260,
                    height: 260,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 1.0, end: progressRatio),
                      duration: const Duration(milliseconds: 500),
                      builder: (context, value, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: value,
                              strokeWidth: 12,
                              backgroundColor: Colors.white.withAlpha(40),
                              valueColor: const AlwaysStoppedAnimation(Color(0xFF9B8CFF)),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_formatTime(_secondsRemaining), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(height: 8),
                                Text(_isBreak ? 'Break Time' : 'Pomodoro Session', style: const TextStyle(fontSize: 14, color: Colors.white70)),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Animated pill button
                  GestureDetector(
                    onTap: _toggleTimer,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8C82FF),
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [BoxShadow(color: const Color(0xFF8C82FF).withAlpha(102), blurRadius: 20, spreadRadius: 2)],
                      ),
                      child: Text(_isRunning ? 'Pause Focus' : 'Start Focus', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Session context + distraction mode row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white.withAlpha(51), borderRadius: BorderRadius.circular(20)),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            const Text('What are you working on?', style: TextStyle(color: Colors.white)),
                            Icon(Icons.keyboard_arrow_down, color: Colors.white.withAlpha(153)),
                          ]),
                        ),

                        const SizedBox(height: 10),

                        // Distraction-free switch
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Text('Distraction-Free', style: TextStyle(color: Colors.white70)),
                          const SizedBox(width: 8),
                          Switch(value: _distractionMode, onChanged: (v) => setState(() => _distractionMode = v), activeThumbColor: Colors.white),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),

              // Tobi small avatar bottom-left
              Positioned(
                left: 12,
                bottom: 18,
                child: Opacity(
                  opacity: 0.88,
                  child: GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tobi here — ready to help'))),
                    child: Image.asset('assets/Tobi.png', width: 64, height: 64, fit: BoxFit.contain),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
