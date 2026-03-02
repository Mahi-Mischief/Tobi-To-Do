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
    final card = Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.fromBorderSide(border ?? const BorderSide(color: AppColors.cardOutline)),
        boxShadow: const [
          BoxShadow(color: AppColors.shadowSoft, blurRadius: 18, offset: Offset(0, 10)),
        ],
      ),
      padding: padding,
      child: child,
    );

    if (onTap == null) return card;
    return InkWell(borderRadius: BorderRadius.circular(AppRadius.large), onTap: onTap, child: card);
  }
}
