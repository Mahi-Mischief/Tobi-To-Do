import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_colors.dart';

class SoftBackground extends StatelessWidget {
  const SoftBackground({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.showOverlay = true,
    this.gradient,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final bool showOverlay;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? const LinearGradient(
          colors: AppColors.backgroundGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          if (showOverlay)
            Positioned(
              right: -60,
              top: -40,
              child: _SoftBlob(
                size: 180,
                colors: const [AppColors.accentPink, AppColors.accentBlue],
              ),
            ),
          if (showOverlay)
            Positioned(
              left: -50,
              bottom: -30,
              child: _SoftBlob(
                size: 200,
                colors: const [AppColors.accentMint, AppColors.accentPeach],
              ),
            ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

class SoftCard extends StatelessWidget {
  const SoftCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin,
    this.gradient,
    this.backgroundColor,
    this.onTap,
    this.borderColor = AppColors.border,
    this.elevation = 14,
    this.showShadow = true,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final Gradient? gradient;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final Color borderColor;
  final double elevation;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        gradient: gradient ?? (backgroundColor == null ? const LinearGradient(colors: [AppColors.surface, AppColors.surfaceSoft]) : null),
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: borderColor),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: AppColors.shadowSoft,
                  blurRadius: elevation,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.large),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        borderRadius: BorderRadius.circular(AppRadius.large),
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}

class PillButton extends StatelessWidget {
  const PillButton({
    required this.label,
    this.onPressed,
    this.prefix,
    this.suffix,
    this.isPrimary = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? prefix;
  final Widget? suffix;
  final bool isPrimary;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final bg = isPrimary ? AppColors.primary : AppColors.accentBlue;
    final fg = isPrimary ? Colors.white : AppColors.textPrimary;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
        elevation: 0,
        padding: padding,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (prefix != null) ...[prefix!, const SizedBox(width: 8)],
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          if (suffix != null) ...[const SizedBox(width: 8), suffix!],
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    subtitle!,
                    style: theme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                  ),
                ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    ).animate().fadeIn(duration: 300.ms).slide(begin: const Offset(0, 0.04));
  }
}

class _SoftBlob extends StatelessWidget {
  const _SoftBlob({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        gradient: RadialGradient(colors: colors),
        borderRadius: BorderRadius.circular(size),
      ),
    );
  }
}
