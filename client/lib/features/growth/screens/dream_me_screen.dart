import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tobi_todo/core/theme/app_colors.dart';
import 'package:tobi_todo/models/avatar_config.dart';
import 'package:tobi_todo/providers/auth_provider.dart';
import 'package:tobi_todo/providers/avatar_provider.dart';
import 'package:tobi_todo/providers/dream_me_provider.dart';
import 'package:tobi_todo/shared/widgets/avatar_widget.dart';

class DreamMeScreen extends ConsumerStatefulWidget {
  const DreamMeScreen({super.key});

  @override
  ConsumerState<DreamMeScreen> createState() => _DreamMeScreenState();
}

class _DreamMeScreenState extends ConsumerState<DreamMeScreen> {
  final _visionController = TextEditingController();
  final _valuesController = TextEditingController();
  final _goalController = TextEditingController();
  final _reflectionController = TextEditingController();
  final _moodController = TextEditingController();
  final _insightsController = TextEditingController();

  final List<String> _identities = [];
  bool _hydratedFromProfile = false;

  @override
  void dispose() {
    _visionController.dispose();
    _valuesController.dispose();
    _goalController.dispose();
    _reflectionController.dispose();
    _moodController.dispose();
    _insightsController.dispose();
    super.dispose();
  }

  void _hydrateFromProfile(DreamProfile? profile) {
    if (_hydratedFromProfile || profile == null) return;
    _visionController.text = profile.visionStatement ?? '';
    _valuesController.text = profile.coreValues ?? '';
    _goalController.text = profile.threeYearGoal ?? '';
    _identities
      ..clear()
      ..addAll(profile.identityStatements);
    _hydratedFromProfile = true;
  }

  Future<void> _saveProfile() async {
    final controller = ref.read(dreamMeControllerProvider);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await controller.saveProfile(
        visionStatement: _visionController.text.trim(),
        coreValues: _valuesController.text.trim(),
        threeYearGoal: _goalController.text.trim(),
        identityStatements: List<String>.from(_identities),
      );
      messenger.showSnackBar(const SnackBar(content: Text('Dream Me updated')));
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not save Dream Me: $e')),
      );
    }
  }

  Future<void> _submitReflection() async {
    final controller = ref.read(dreamMeControllerProvider);
    final messenger = ScaffoldMessenger.of(context);

    if (_reflectionController.text.trim().isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Write a reflection first')),
      );
      return;
    }

    try {
      await controller.addReflection(
        content: _reflectionController.text.trim(),
        mood: _moodController.text.trim().isEmpty ? null : _moodController.text.trim(),
        insights: _insightsController.text.trim().isEmpty ? null : _insightsController.text.trim(),
      );

      _reflectionController.clear();
      _moodController.clear();
      _insightsController.clear();
      messenger.showSnackBar(const SnackBar(content: Text('Reflection saved')));
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not save reflection: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final avatarConfig = ref.watch(avatarProvider);
    final profileAsync = ref.watch(dreamProfileProvider);
    final alignmentAsync = ref.watch(alignmentScoreProvider);
    final gapAsync = ref.watch(gapAnalysisProvider);
    final milestonesAsync = ref.watch(milestoneProgressProvider);
    final reflectionsAsync = ref.watch(reflectionsProvider);

    profileAsync.whenData(_hydrateFromProfile);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dream Me'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dreamProfileProvider);
          ref.invalidate(alignmentScoreProvider);
          ref.invalidate(gapAnalysisProvider);
          ref.invalidate(milestoneProgressProvider);
          ref.invalidate(reflectionsProvider);
          await Future.wait([
            ref.refresh(dreamProfileProvider.future),
            ref.refresh(alignmentScoreProvider.future),
            ref.refresh(gapAnalysisProvider.future),
            ref.refresh(milestoneProgressProvider.future),
            ref.refresh(reflectionsProvider.future),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroCard(context, authState, avatarConfig, profileAsync),
              const SizedBox(height: 16),
              _buildProfileForm(context),
              const SizedBox(height: 16),
              _buildAlignmentCard(context, alignmentAsync),
              const SizedBox(height: 16),
              _buildGapCard(context, gapAsync),
              const SizedBox(height: 16),
              _buildMilestonesCard(context, milestonesAsync),
              const SizedBox(height: 16),
              _buildReflectionsCard(context, reflectionsAsync),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, AsyncValue<DreamProfile?> profileAsync) {
    return const SizedBox.shrink();
  }

  Widget _buildHeroCard(
    BuildContext context,
    AsyncValue<dynamic> authState,
    AvatarConfig avatarConfig,
    AsyncValue<DreamProfile?> profileAsync,
  ) {
    final completion = ref.watch(profileCompletionProvider);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 260,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final avatarSize = 64.0;
            // Position avatar relative to image size so it sits by the flag.
            final dx = constraints.maxWidth * 0.62;
            final dy = constraints.maxHeight * 0.23;

            return Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/dream_me_background.png',
                    fit: BoxFit.cover,
                  ),
                ),
                // Soft overlay for readability
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.35)],
                      ),
                    ),
                  ),
                ),
                // Title row
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Row(
                    children: [
                      const Text(
                        'Dream Me',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const Spacer(),
                      Chip(
                        label: Text('${completion.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.black87)),
                        backgroundColor: Colors.white.withOpacity(0.8),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ],
                  ),
                ),
                // Mini avatar near the flag
                Positioned(
                  left: dx - (avatarSize / 2),
                  top: dy - (avatarSize / 2),
                  child: SizedBox(
                    height: avatarSize,
                    width: avatarSize,
                    child: authState.when(
                      data: (user) {
                        if (user != null) {
                          ref.read(avatarProvider.notifier).ensureLoaded(user.id);
                        }
                        return AvatarWidget(config: avatarConfig, size: avatarSize, background: Colors.transparent);
                      },
                      loading: () => const SizedBox(),
                      error: (_, __) => AvatarWidget(config: avatarConfig, size: avatarSize, background: Colors.transparent),
                    ),
                  ),
                ),
                // Footer details
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            profileAsync.when(
                              data: (profile) => Text(
                                profile == null
                                    ? 'Define who you want to become.'
                                    : 'Last updated: ${profile.updatedAt.toLocal().toString().split(' ').first}',
                                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                              ),
                              loading: () => const Text('Loading profile...', style: TextStyle(color: Colors.black54)),
                              error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.red)),
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: LinearProgressIndicator(
                                value: completion / 100,
                                minHeight: 8,
                                backgroundColor: Colors.white.withOpacity(0.5),
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.9)),
                        onPressed: () => _saveProfile(),
                        icon: const Icon(Icons.flag, color: Colors.black87),
                        label: const Text('Update', style: TextStyle(color: Colors.black87)),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileForm(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dream Me Profile',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                FilledButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _visionController,
              decoration: const InputDecoration(
                labelText: 'Vision statement (who you want to become)',
                border: OutlineInputBorder(),
              ),
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _valuesController,
              decoration: const InputDecoration(
                labelText: 'Core values / principles',
                border: OutlineInputBorder(),
              ),
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _goalController,
              decoration: const InputDecoration(
                labelText: '3-year target (headline goal)',
                border: OutlineInputBorder(),
              ),
              minLines: 2,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._identities.map(
                    (id) => Chip(
                      label: Text(id),
                      deleteIcon: const Icon(Icons.close),
                      onDeleted: () => setState(() => _identities.remove(id)),
                    ),
                  ),
                  ActionChip(
                    label: const Text('Add identity'),
                    avatar: const Icon(Icons.add, size: 18),
                    onPressed: () async {
                      final newValue = await _promptForIdentity(context);
                      if (newValue != null && newValue.trim().isNotEmpty) {
                        setState(() => _identities.add(newValue.trim()));
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tip: Identity statements anchor habits. Example: "I am the kind of person who ships something small every week."',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _promptForIdentity(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add identity statement'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g., I am a consistent builder'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(controller.text), child: const Text('Add')),
        ],
      ),
    );
  }

  Widget _buildAlignmentCard(BuildContext context, AsyncValue<AlignmentScore> alignmentAsync) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: alignmentAsync.when(
          data: (alignment) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Alignment Score', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Chip(
                    label: Text('${alignment.score}/100'),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: alignment.score / 100,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: 8),
              Text('Habits consistency: ${alignment.breakdown['habitConsistency']?.round() ?? 0}'),
              Text('Goals count: ${alignment.breakdown['goalCount']?.round() ?? 0}'),
              Text('Progress realization: ${alignment.breakdown['progressRealization']?.round() ?? 0}'),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Could not load alignment: $e'),
        ),
      ),
    );
  }

  Widget _buildGapCard(BuildContext context, AsyncValue<GapAnalysis> gapAsync) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: gapAsync.when(
          data: (gap) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Mental Contrasting', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  if (gap.alignmentScore != null)
                    Chip(label: Text('Alignment ${gap.alignmentScore}')), 
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Obstacles',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              ...gap.gaps.map((g) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    title: Text(g),
                  )),
              const SizedBox(height: 8),
              Text(
                'Strategies',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              ...gap.suggestions.map((s) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                    title: Text(s),
                  )),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Could not load gaps: $e'),
        ),
      ),
    );
  }

  Widget _buildMilestonesCard(BuildContext context, AsyncValue<Map<String, dynamic>?> milestonesAsync) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: milestonesAsync.when(
          data: (data) {
            if (data == null) {
              return const Text('Set your 3-year goal to see milestones.');
            }
            final goals = (data['goals'] as List?) ?? [];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Milestones', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Chip(label: Text('${data['overallProgress'] ?? 0}%')),
                  ],
                ),
                const SizedBox(height: 6),
                Text('3-year goal: ${data['threeYearGoal']}'),
                Text('Completed goals: ${data['completedGoals']} / ${data['totalGoals']}'),
                const SizedBox(height: 8),
                ...goals.take(4).map((g) => ListTile(
                      dense: true,
                      title: Text(g['title'] ?? ''),
                      subtitle: Text('Progress ${g['progress_percent']}%'),
                      trailing: g['daysUntilDeadline'] != null
                          ? Text('${g['daysUntilDeadline']}d left')
                          : null,
                    )),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Could not load milestones: $e'),
        ),
      ),
    );
  }

  Widget _buildReflectionsCard(BuildContext context, AsyncValue<List<Reflection>> reflectionsAsync) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Monthly Reflection', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  onPressed: () => ref.invalidate(reflectionsProvider),
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reflectionController,
              decoration: const InputDecoration(
                labelText: 'Reflection prompt or insights',
                border: OutlineInputBorder(),
              ),
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _moodController,
                    decoration: const InputDecoration(
                      labelText: 'Mood (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _insightsController,
                    decoration: const InputDecoration(
                      labelText: 'Insight / next step (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _submitReflection,
                icon: const Icon(Icons.send),
                label: const Text('Log Reflection'),
              ),
            ),
            const SizedBox(height: 8),
            reflectionsAsync.when(
              data: (items) => Column(
                children: items.take(6).map((r) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.menu_book),
                      title: Text(r.content),
                      subtitle: Text(
                        [
                          if (r.mood != null) 'Mood: ${r.mood}',
                          if (r.insights != null) 'Insight: ${r.insights}',
                          'On ${r.createdAt.toLocal().toString().split(' ').first}',
                        ].join(' • '),
                      ),
                    )).toList(),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Could not load reflections: $e'),
            ),
          ],
        ),
      ),
    );
  }
}
