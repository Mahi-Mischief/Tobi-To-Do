import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tobi_todo/core/theme/app_theme.dart';

class XPProgressBar extends StatelessWidget {
  const XPProgressBar({
    super.key,
    required this.progress,
    this.label,
    this.starAsset = 'assets/icons/star_cap_large.svg',
  }) : assert(progress >= 0 && progress <= 1, 'progress must be 0..1');

  final double progress;
  final String? label;
  final String starAsset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              label!,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
            ),
          ),
        LayoutBuilder(
          builder: (context, constraints) {
            final safeProgress = progress.clamp(0.0, 1.0);
            final starX = (constraints.maxWidth * safeProgress).clamp(0, constraints.maxWidth - 16);

            return SizedBox(
              height: 22,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.cardOutline.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: safeProgress,
                    alignment: Alignment.centerLeft,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.starLight, AppColors.starDark]),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ),
                  Positioned(
                    left: starX,
                    child: SvgPicture.asset(starAsset, height: 22),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
