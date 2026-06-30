import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tobi_todo/core/theme/app_theme.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.border,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final BorderSide? border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.large),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(AppRadius.large),
            boxShadow: [
              BoxShadow(color: const Color(0xFFD4C1EC).withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 8)),
            ],
          ),
          padding: padding,
          child: child,
        ),
      ),
    );

    if (onTap == null) return card;
    return InkWell(borderRadius: BorderRadius.circular(AppRadius.large), onTap: onTap, child: card);
  }
}
