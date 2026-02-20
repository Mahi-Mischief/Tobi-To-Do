import 'package:flutter/material.dart';
import 'package:tobi_todo/shared/widgets/tobi_widget.dart';
import 'package:tobi_todo/shared/services/tobi_service.dart';
import 'package:tobi_todo/shared/services/tobi_controller.dart';
import 'package:tobi_todo/features/plan/screens/plan_screen.dart';
import 'package:tobi_todo/features/focus/screens/focus_screen_clean.dart' as focus_clean;
import 'package:tobi_todo/features/growth/screens/growth_screen.dart';
import 'package:tobi_todo/features/profile/screens/profile_screen.dart';

class TobiDashboardScreen extends StatefulWidget {
  const TobiDashboardScreen({super.key});

  @override
  State<TobiDashboardScreen> createState() => _TobiDashboardScreenState();
}

class _TobiDashboardScreenState extends State<TobiDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // When opening the dashboard, play an intro animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TobiService.instance.play('dance', fps: 14, loop: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Tobi Dashboard'),
      ),
      body: Center(
        child: SizedBox(
          width: 360,
          height: 480,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Show Tobi animation full-size with transparent background
              ValueListenableBuilder(
                valueListenable: TobiController.instance.state,
                builder: (context, value, _) {
                  final s = value as dynamic;
                  return TobiWidget(
                    animationName: s.animationName,
                    size: 360,
                    frameCount: s.frameCount ?? TobiService.instance.getFrameCount('idle'),
                    fps: s.fps ?? 12,
                    loop: s.loop ?? true,
                  );
                },
              ),
              // Controls / actions
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                TobiService.instance.think();
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const focus_clean.FocusScreen()));
                              },
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Start Focus'),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                TobiService.instance.wave();
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlanScreen()));
                              },
                              icon: const Icon(Icons.calendar_month),
                              label: const Text('Open Plan'),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                TobiService.instance.think();
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GrowthScreen()));
                              },
                              icon: const Icon(Icons.trending_up),
                              label: const Text('Insights'),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                TobiService.instance.celebrate();
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
                              },
                              icon: const Icon(Icons.person),
                              label: const Text('Profile'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () => TobiService.instance.dance(),
                              child: const Text('Dance'),
                            ),
                            const SizedBox(width: 12),
                            TextButton(
                              onPressed: () => TobiService.instance.wave(),
                              child: const Text('Wave'),
                            ),
                            const SizedBox(width: 12),
                            TextButton(
                              onPressed: () => TobiService.instance.sad(),
                              child: const Text('Sad'),
                            ),
                          ],
                        ),
                      ],
                    ),
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
