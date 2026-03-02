import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tobi_todo/core/theme/app_theme.dart';

class PastelButton extends StatefulWidget {
  const PastelButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.gradient,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onTap;
  final Widget? icon;
  final Gradient? gradient;
  final bool expand;

  @override
  State<PastelButton> createState() => _PastelButtonState();
}

class _PastelButtonState extends State<PastelButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final content = DecoratedBox(
      decoration: BoxDecoration(
        gradient: widget.gradient ?? const LinearGradient(colors: [AppColors.primaryDark, AppColors.primaryButtonBlue]),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              widget.icon!,
              const SizedBox(width: AppSpacing.sm),
            ],
            Flexible(
              child: Text(
                widget.label,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: 120.ms,
        child: widget.expand ? SizedBox(width: double.infinity, child: content) : content,
      ),
    );
  }
}
