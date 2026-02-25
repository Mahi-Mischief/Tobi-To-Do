import 'package:flutter/material.dart';
import 'package:tobi_todo/models/avatar_config.dart';

class AvatarWidget extends StatelessWidget {
  final AvatarConfig config;
  final double size;
  final double scale;
  final Color? background;

  const AvatarWidget({
    super.key,
    required this.config,
    this.size = 180,
    this.scale = 1.0,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? Colors.transparent,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Transform.scale(
        scale: scale,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _layer(config.hairBack), // behind face/body
            _layer(config.body),
            _layer(config.extras), // overlays (wings, tattoos, etc.)
            _layer(config.top),
            _layer(config.dress),
            _layer(config.bottom),
            _layer(config.gloves),
            _layer(config.shoes),
            _layer(config.beard),
            _layer(config.eyebrows),
            _layer(config.pupils),
            _layer(config.eyelashes),
            _layer(config.mouth),
            _layer(config.bangs),
            _layer(config.hairBonus),
            _layer(config.hairFront),
          ],
        ),
      ),
    );
  }

  Widget _layer(String path) {
    if (path.isEmpty) return const SizedBox.shrink();
    return Positioned.fill(
      child: Image.asset(
        path,
        fit: BoxFit.contain,
        key: ValueKey(path), // Force rebuild when path changes on web
        gaplessPlayback: true,
        errorBuilder: (context, error, stack) {
          // Visible fallback so we can spot missing assets on web.
          return Container(
            color: Colors.red.withValues(alpha: 0.1),
            alignment: Alignment.center,
            child: Text(
              path,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: Colors.red),
            ),
          );
        },
      ),
    );
  }
}
