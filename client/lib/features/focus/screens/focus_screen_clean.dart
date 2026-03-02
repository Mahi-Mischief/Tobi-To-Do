import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tobi_todo/shared/services/tobi_service.dart';

class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> {
  Timer? _timer;
  int _focusMinutes = 25;
  int _breakMinutes = 5;
  int _secondsRemaining = 25 * 60;
  bool _isRunning = false;
  bool _isBreak = false;
  bool _deepFocus = false;
  bool _distractionFree = false;
  double _energyLevel = 0.7; // 0-1 slider
  String _workingOnType = 'Task';
  String _workingOnLabel = 'Untitled';
  bool _aiEstimating = false;
  int _longestStreak = 3;
  int _currentStreak = 0;
  int _xpEarned = 0;
  final List<_SessionLog> _history = [];
  final Map<String, int> _distractionPatterns = {'Phone': 0, 'Tabs': 0, 'Chat': 0};

  int get _sessionTotal => _isBreak ? _breakMinutes * 60 : _focusMinutes * 60;

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
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _timer?.cancel();
            _isRunning = false;
            _onSessionComplete();
            _switchMode();
          }
        });
      });
      try {
        TobiService.instance.think();
      } catch (_) {}
    } else {
      _timer?.cancel();
    }
  }

  void _switchMode() {
    setState(() {
      _isBreak = !_isBreak;
      _secondsRemaining = _isBreak ? _breakMinutes * 60 : _focusMinutes * 60;
    });
  }

  void _onSessionComplete() {
    final session = _SessionLog(
      startedAt: DateTime.now().subtract(Duration(seconds: _sessionTotal)),
      durationSeconds: _sessionTotal,
      deepFocus: _deepFocus,
      workingOnType: _workingOnType,
      workingOnLabel: _workingOnLabel,
      interruptions: _distractionPatterns.values.fold<int>(0, (a, b) => a + b),
    );
    setState(() {
      _history.insert(0, session);
      _currentStreak += 1;
      if (_currentStreak > _longestStreak) _longestStreak = _currentStreak;
      _xpEarned += (_isBreak ? 5 : 15) + (_deepFocus ? 10 : 0);
    });

    // Placeholder hooks for analytics, XP, reflection, AI consistency
    try {
      TobiService.instance.logEvent('focus_session_complete', metadata: {
        'duration': _sessionTotal,
        'deep_focus': _deepFocus,
        'working_on': _workingOnType,
      });
      TobiService.instance.celebrate();
    } catch (_) {}

    _showReflectionPrompt();
  }

  void _showReflectionPrompt() {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Session complete', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('How did it go? Quick reflection helps the AI consistency model learn.'),
            const SizedBox(height: 12),
            TextField(maxLines: 2, decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Save & continue'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _burnoutIndicator() {
    final recent = _history.take(5).fold<int>(0, (sum, h) => sum + h.durationSeconds);
    if (recent > 4 * 60 * 60) return 'Elevated — take a longer break soon';
    if (recent > 2 * 60 * 60) return 'Monitor — hydrate and stretch';
    return 'Healthy — keep steady pace';
  }

  String _energySuggestion() {
    if (_energyLevel >= 0.75) return 'High energy — try deep focus x50 min';
    if (_energyLevel >= 0.45) return 'Moderate — standard 25/5 cycles';
    return 'Low — do a 15-min micro focus and stretch';
  }

  Future<void> _runAiEstimate() async {
    setState(() => _aiEstimating = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _aiEstimating = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI estimates 38 minutes to finish')));
  }

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFF0E1A2B);
    final progressRatio = _secondsRemaining / _sessionTotal;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                    Text('Focus', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 4),
                    Text('Pure execution. No calendar. No goal edits.', style: TextStyle(color: Colors.white70)),
                  ]),
                  IconButton(
                    icon: Icon(_distractionFree ? Icons.shield : Icons.shield_outlined, color: Colors.white),
                    onPressed: () => setState(() => _distractionFree = !_distractionFree),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _focusTimerCard(progressRatio),

              const SizedBox(height: 12),

              _sessionContextCard(),

              const SizedBox(height: 12),

              _statusRow(),

              const SizedBox(height: 12),

              _historySection(),

              const SizedBox(height: 12),

              _distractionSection(),

              const SizedBox(height: 12),

              _burnoutSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _focusTimerCard(double progressRatio) {
    return Card(
      color: const Color(0xFF122844),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_isBreak ? 'Break' : 'Pomodoro', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 4),
                  Text(_isBreak ? 'Rest & recharge' : 'Deep work session', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                ]),
                Row(children: [
                  Switch(
                    value: _deepFocus,
                    onChanged: (v) => setState(() {
                      _deepFocus = v;
                      _focusMinutes = v ? 50 : 25;
                      _breakMinutes = v ? 10 : 5;
                      _secondsRemaining = _focusMinutes * 60;
                    }),
                    thumbColor: WidgetStateProperty.resolveWith(
                      (states) => states.contains(WidgetState.selected) ? Colors.greenAccent : null,
                    ),
                  ),
                  const Text('Deep focus', style: TextStyle(color: Colors.white70)),
                ]),
              ],
            ),
            const SizedBox(height: 12),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CircularProgressIndicator(
                    value: progressRatio,
                    strokeWidth: 10,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation(_isBreak ? Colors.tealAccent : Colors.blueAccent),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_formatTime(_secondsRemaining), style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(_isBreak ? 'Break' : 'Focus', style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _toggleTimer,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                    child: Text(_isRunning ? 'Pause' : 'Start'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _switchMode,
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                    child: Text(_isBreak ? 'Skip break' : 'Skip to break'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sessionContextCard() {
    return Card(
      color: const Color(0xFF122844),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('What are you working on?', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              _chip('Task'),
              _chip('Project'),
              _chip('Goal'),
            ]),
            const SizedBox(height: 12),
            TextField(
              onChanged: (v) => setState(() => _workingOnLabel = v.isEmpty ? 'Untitled' : v),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _aiEstimating ? null : _runAiEstimate,
                  icon: _aiEstimating ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.auto_awesome),
                  label: const Text('AI time estimate'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Energy level', style: TextStyle(color: Colors.white70)),
                      Slider(
                        value: _energyLevel,
                        onChanged: (v) => setState(() => _energyLevel = v),
                        activeColor: Colors.greenAccent,
                        inactiveColor: Colors.white24,
                      ),
                      Text(_energySuggestion(), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusRow() {
    return Row(
      children: [
        Expanded(
          child: _statCard('Longest streak', '$_longestStreak sessions'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statCard('Current streak', '$_currentStreak today'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statCard('XP earned', '+$_xpEarned XP'),
        ),
      ],
    );
  }

  Widget _historySection() {
    return Card(
      color: const Color(0xFF122844),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Session history', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (_history.isEmpty)
              const Text('No sessions yet', style: TextStyle(color: Colors.white70))
            else
              ..._history.take(5).map((h) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(h.deepFocus ? Icons.lock_clock : Icons.timer, color: Colors.white70),
                    title: Text('${h.workingOnType}: ${h.workingOnLabel}', style: const TextStyle(color: Colors.white)),
                    subtitle: Text('${h.durationSeconds ~/ 60} min • ${h.interruptions} distractions', style: const TextStyle(color: Colors.white60)),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _distractionSection() {
    return Card(
      color: const Color(0xFF122844),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Distraction patterns', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _distractionPatterns.keys.map((k) => ActionChip(
                    label: Text('$k (${_distractionPatterns[k]})'),
                    onPressed: () => setState(() => _distractionPatterns[k] = (_distractionPatterns[k] ?? 0) + 1),
                  )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _burnoutSection() {
    return Card(
      color: const Color(0xFF122844),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Burnout indicator', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(_burnoutIndicator(), style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, String value) {
    return Card(
      color: const Color(0xFF122844),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  Widget _chip(String label) {
    final selected = _workingOnType == label;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _workingOnType = label),
      selectedColor: Colors.blueAccent,
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.white70),
      backgroundColor: Colors.white12,
    );
  }
}

class _SessionLog {
  final DateTime startedAt;
  final int durationSeconds;
  final bool deepFocus;
  final String workingOnType;
  final String workingOnLabel;
  final int interruptions;

  _SessionLog({
    required this.startedAt,
    required this.durationSeconds,
    required this.deepFocus,
    required this.workingOnType,
    required this.workingOnLabel,
    required this.interruptions,
  });
}
