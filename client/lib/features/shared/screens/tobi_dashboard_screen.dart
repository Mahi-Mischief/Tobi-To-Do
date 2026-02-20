import 'package:flutter/material.dart';
import 'package:tobi_todo/shared/widgets/tobi_widget.dart';
import 'package:tobi_todo/shared/services/tobi_service.dart';
import 'package:tobi_todo/shared/services/tobi_controller.dart';

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
            ],
          ),
        ),
      ),
    );
  }
}
