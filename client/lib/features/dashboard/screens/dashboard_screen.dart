import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tobi_todo/core/theme/app_theme.dart';
import 'package:tobi_todo/features/shared/widgets/app_card.dart';
import 'package:tobi_todo/features/shared/widgets/floating_cloud_decoration.dart';
import 'package:tobi_todo/features/shared/widgets/pastel_button.dart';
import 'package:tobi_todo/features/shared/widgets/section_header.dart';
import 'package:tobi_todo/features/shared/widgets/xp_progress_bar.dart';
import 'package:tobi_todo/providers/auth_provider.dart';
import 'package:tobi_todo/providers/gamification_provider.dart';
import 'package:tobi_todo/shared/services/tobi_service.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final gamificationStats = ref.watch(gamificationStatsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = AppBreakpoints.isDesktop(constraints);
        final isTablet = AppBreakpoints.isTablet(constraints);
        final horizontal = isDesktop ? AppSpacing.xxl : isTablet ? AppSpacing.xl : AppSpacing.md;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Layer 1: background image + gradient
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/backgrounds/background_default.png'),
                      fit: BoxFit.cover,
                    ),
                    gradient: AppColors.defaultBackgroundGradient,
                  ),
                ),
              ),
              // Layer 2: clouds and blobs
              FloatingCloudDecoration(
                asset: 'assets/clouds/cloud_1.svg',
                opacity: isDesktop ? 0.25 : 0.18,
                top: 40,
                left: 24,
                width: isDesktop ? 240 : 160,
              ),
              FloatingCloudDecoration(
                asset: 'assets/clouds/cloud_3.svg',
                opacity: 0.18,
                top: isDesktop ? 160 : 120,
                right: 12,
                width: isDesktop ? 260 : 180,
              ),
              FloatingCloudDecoration(
                asset: 'assets/blobs/blob_pink.svg',
                opacity: 0.12,
                bottom: 80,
                left: -40,
                width: isDesktop ? 260 : 200,
              ),
              FloatingCloudDecoration(
                asset: 'assets/blobs/blob_yellow.svg',
                opacity: 0.12,
                bottom: 40,
                right: -30,
                width: isDesktop ? 240 : 180,
              ),
              // Layer 3: content
              SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: AppSpacing.xl),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Header(authState: authState),
                          const SizedBox(height: AppSpacing.lg),
                          PastelButton(
                            label: 'AI Daily Briefing',
                            icon: SvgPicture.asset('assets/icons/star_xp.svg', height: 18, colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn)),
                            onTap: () {
                              TobiService.instance.think();
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Launching AI briefing...')));
                            },
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          SectionHeader(
                            title: 'Today',
                            action: Text('All synced', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _ResponsiveGrid(
                            children: [
                              AppCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Tasks', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                                    const SizedBox(height: AppSpacing.sm),
                                    _MetricRow(label: 'Due today', value: '7'),
                                    _MetricRow(label: 'Completed', value: '3'),
                                    _MetricRow(label: 'Blocked', value: '1'),
                                  ],
                                ),
                              ),
                              AppCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Habits', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                                    const SizedBox(height: AppSpacing.sm),
                                    _MetricRow(label: 'Scheduled', value: '5'),
                                    _MetricRow(label: 'Done', value: '2'),
                                    _MetricRow(label: 'Streak', value: '23d'),
                                  ],
                                ),
                              ),
                              AppCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Calendar', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                                    const SizedBox(height: AppSpacing.sm),
                                    _MetricRow(label: 'Events today', value: '2'),
                                    _MetricRow(label: 'Conflicts', value: '0'),
                                    _MetricRow(label: 'Next focus', value: '2:00 PM'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          gamificationStats.when(
                            data: (stats) {
                              final xp = stats.xp ?? 0;
                              final progress = (xp % 10000) / 10000;
                              return AppCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text('Level ${stats.level}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                                        const SizedBox(width: AppSpacing.sm),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                                          decoration: BoxDecoration(
                                            color: AppColors.pastelPinkLight,
                                            borderRadius: BorderRadius.circular(AppRadius.pill),
                                          ),
                                          child: Text('+${xp % 1000} XP today', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textPrimary)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    XPProgressBar(progress: progress, label: 'Next level • ${(progress * 100).toStringAsFixed(0)}%'),
                                  ],
                                ),
                              );
                            },
                            loading: () => const AppCard(child: SizedBox(height: 64, child: Center(child: CircularProgressIndicator()))),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          SectionHeader(
                            title: 'Quick actions',
                            action: PastelButton(
                              expand: false,
                              label: 'Start Focus',
                              onTap: () => TobiService.instance.think(),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _ResponsiveGrid(
                            children: const [
                              _QuickActionCard(icon: Icons.add_task, title: 'Add task', subtitle: 'Capture and schedule'),
                              _QuickActionCard(icon: Icons.play_arrow_rounded, title: 'Focus session', subtitle: 'Start 25/5 Pomodoro'),
                              _QuickActionCard(icon: Icons.auto_awesome, title: 'Breakdown with AI', subtitle: 'Turn vague into steps'),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          SectionHeader(title: 'Upcoming'),
                          const SizedBox(height: AppSpacing.md),
                          AppCard(
                            child: Column(
                              children: const [
                                _UpcomingRow(title: 'Data Structures quiz', time: 'Today • 3:00 PM', chip: 'Exam prep'),
                                SizedBox(height: AppSpacing.sm),
                                _UpcomingRow(title: 'AI project sync', time: 'Tomorrow • 9:00 AM', chip: 'Team'),
                                SizedBox(height: AppSpacing.sm),
                                _UpcomingRow(title: 'Habit check-in', time: 'Tomorrow • 7:00 PM', chip: 'Habits'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.authState});
  final AsyncValue<dynamic> authState;

  @override
  Widget build(BuildContext context) {
    return authState.when(
      data: (user) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dashboard', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.xs),
          Text('Welcome back, ${user?.fullName ?? 'Tobi friend'}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => Text('Dashboard', style: Theme.of(context).textTheme.headlineSmall),
    );
  }
}

class _ResponsiveGrid extends StatelessWidget {
  const _ResponsiveGrid({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = AppBreakpoints.isMobile(constraints);
        final crossAxisCount = isMobile ? 1 : 3;
        final spacing = isMobile ? AppSpacing.md : AppSpacing.lg;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children
              .map((c) => SizedBox(
                    width: isMobile ? double.infinity : (constraints.maxWidth - spacing * 2) / 3,
                    child: c,
                  ))
              .toList(),
        );
      },
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary))),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Icon(icon, color: AppColors.primaryButtonBlue),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  const _UpcomingRow({required this.title, required this.time, required this.chip});
  final String title;
  final String time;
  final String chip;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSpacing.xs),
              Text(time, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            color: AppColors.pastelYellowLight,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: const Border.fromBorderSide(BorderSide(color: AppColors.cardOutline)),
          ),
          child: Text(chip, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textPrimary)),
        ),
      ],
    );
  }
}
