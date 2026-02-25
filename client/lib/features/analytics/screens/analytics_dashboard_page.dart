import 'dart:math';
import 'package:csv/csv.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/soft_ui.dart';

class AnalyticsDashboardPage extends StatefulWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  State<AnalyticsDashboardPage> createState() => _AnalyticsDashboardPageState();
}

class _AnalyticsDashboardPageState extends State<AnalyticsDashboardPage> {
  String _selectedPeriod = 'Weekly';
  final Map<String, bool> _visibility = {
    'productivity': true,
    'tasks': true,
    'habits': true,
    'focus': true,
    'balance': true,
    'heatmap': true,
    'streaks': true,
    'ai': true,
    'procrastination': true,
    'gratitude': true,
    'goals': true,
    'passion': true,
  };
  final List<String> _cardOrder = [
    'productivity',
    'tasks',
    'habits',
    'focus',
    'balance',
    'heatmap',
    'streaks',
    'ai',
    'procrastination',
    'gratitude',
    'goals',
    'passion',
  ];

  List<FlSpot> get _productivitySpots {
    switch (_selectedPeriod) {
      case 'Daily':
        // Daily: show intra-week daily rhythm.
        return const [FlSpot(0, 0.55), FlSpot(1, 0.62), FlSpot(2, 0.68), FlSpot(3, 0.72), FlSpot(4, 0.75), FlSpot(5, 0.78), FlSpot(6, 0.83)];
      case 'Weekly':
      default:
        // Weekly: show weekly aggregates across four weeks.
        return List.generate(4, (i) => FlSpot(i.toDouble(), 0.6 + (sin(i) * 0.1)));
    }
  }

  List<BarChartGroupData> get _taskBars {
    final values = _selectedPeriod == 'Weekly'
        ? [72, 81, 76, 84]
        : [68, 74, 79, 82, 76, 88, 91];
    return List.generate(values.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: values[i].toDouble(),
            width: 16,
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: _barGradient,
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ],
      );
    });
  }

  List<PieChartSectionData> get _focusSections {
    final palette = const [
      [Color(0xFFB8C6FF), Color(0xFF9EE6CF)],
      [Color(0xFFFFC6E0), Color(0xFFB8C6FF)],
      [Color(0xFF9EE6CF), Color(0xFFA0E7E5)],
      [Color(0xFFFFD6A5), Color(0xFFFFC6E0)],
    ];
    final titles = ['Study', 'Health', 'Social', 'Other'];
    final values = [40.0, 25.0, 20.0, 15.0];

    return List.generate(values.length, (i) {
      return PieChartSectionData(
        value: values[i],
        title: titles[i],
        radius: 60,
        color: Colors.transparent,
        gradient: LinearGradient(colors: palette[i]),
        titleStyle: GoogleFonts.nunito(
          fontWeight: FontWeight.w700,
          color: Colors.white,
          fontSize: 12,
        ),
      );
    });
  }

  List<Color> get _barGradient => const [Color(0xFFB8C6FF), Color(0xFFFFC6E0)];

  final List<String> _habitDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  final List<Map<String, dynamic>> _habitRows = [
    {'name': 'Hydrate', 'data': [true, true, true, false, true, true, false], 'streak': 4},
    {'name': 'Read', 'data': [false, true, true, true, true, false, true], 'streak': 3},
    {'name': 'Workout', 'data': [true, false, false, true, true, true, true], 'streak': 2},
    {'name': 'Journal', 'data': [true, true, true, true, false, false, true], 'streak': 5},
  ];

  Future<void> _exportCsv() async {
    final rows = [
      ['Metric', 'Value'],
      ['Completion Rate %', '82'],
      ['Discipline Score', '78'],
      ['Goal Probability %', '74'],
      ['Task Velocity', '12 tasks/week'],
      ['Longest Focus Streak', '7 days'],
      ['Average Session Length', '42 min'],
    ];
    final csvData = const ListToCsvConverter().convert(rows);
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Tobi Analytics CSV Export', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 12),
            pw.Text(csvData),
          ],
        ),
      ),
    );
    await Printing.sharePdf(bytes: await doc.save(), filename: 'analytics.csv.pdf');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV exported (embedded in PDF preview for sharing)')));
    }
  }

  Future<void> _exportPdf() async {
    final doc = pw.Document();

    final taskValues = _taskBars.map((g) => g.barRods.first.toY).toList();
    final focusValues = _focusSections.map((s) => (s.title, s.value.toDouble())).toList();
    final habitSummaries = _habitRows
        .map((row) {
          final data = List<bool>.from(row['data'] as List);
          final completed = data.where((d) => d).length;
          return (row['name'] as String, completed, data.length, row['streak'] as int);
        })
        .toList();

    final lifeBalance = [
      ('Work', 0.76),
      ('Health', 0.64),
      ('Social', 0.52),
      ('Learning', 0.70),
    ];

    final streaks = [
      ('Focus', '7 days', true),
      ('Habits', '12 days', false),
      ('Tasks', '9 days', false),
    ];

    final procrastination = [
      ('Inbox Zero', 3),
      ('Deep Work', 5),
      ('Email Sweep', 2),
      ('Exercise', 4),
    ];

    final goals = [
      ('Launch MVP', 0.82),
      ('Grow newsletter', 0.63),
      ('Fitness plan', 0.55),
    ];

    final projects = [
      ('Tobi mascot pack', 0.78),
      ('Calm UI kit', 0.52),
      ('Wellness bot', 0.35),
    ];

    final heatmapValues = List.generate(35, (i) => (i + 1, (i % 7) + 1));
    final heatAvg = heatmapValues.map((e) => e.$2).reduce((a, b) => a + b) / heatmapValues.length;

    doc.addPage(
      pw.MultiPage(
        build: (pw.Context ctx) => [
          pw.Text('Tobi Analytics Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text('Period: $_selectedPeriod'),
          pw.SizedBox(height: 12),

          // Productivity trend
          pw.Text('Productivity Trend', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Bullet(text: 'Points: ${_productivitySpots.map((e) => (e.y * 100).toStringAsFixed(0)).join('% , ')}%'),
          pw.SizedBox(height: 12),

          // Task completion
          pw.Text('Task Completion', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Bullet(text: 'Values: ${taskValues.map((v) => v.toStringAsFixed(0)).join('% , ')}%'),
          pw.Bullet(text: 'Current completion pill: 84% (vs last ${_selectedPeriod.toLowerCase()} +6%)'),
          pw.SizedBox(height: 12),

          // Focus distribution
          pw.Text('Focus Distribution', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: focusValues
              .map((f) => pw.Bullet(text: '${f.$1}: ${f.$2.toStringAsFixed(0)} sessions (total focus 12.4h, +9% vs last ${_selectedPeriod.toLowerCase()})'))
              .toList(),
          ),
          pw.SizedBox(height: 12),

          // Habit tracker
          pw.Text('Habit Tracker', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: ['Habit', 'Done', 'Total', 'Streak'],
            data: habitSummaries.map((h) => [h.$1, h.$2, h.$3, '${h.$4}d']).toList(),
          ),
          pw.SizedBox(height: 12),

          // Life balance
          pw.Text('Life Balance', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: ['Area', 'Score %'],
            data: lifeBalance.map((l) => [l.$1, (l.$2 * 100).toStringAsFixed(0)]).toList(),
          ),
          pw.SizedBox(height: 12),

          // Heatmap summary
          pw.Text('Productivity Heatmap', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Bullet(text: '5-week cells: ${heatmapValues.length}'),
          pw.Bullet(text: 'Average intensity: ${heatAvg.toStringAsFixed(2)} of 7'),
          pw.SizedBox(height: 12),

          // Streaks
          pw.Text('Streaks', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: ['Type', 'Length', 'Longest'],
            data: streaks.map((s) => [s.$1, s.$2, s.$3 ? 'Yes' : 'No']).toList(),
          ),
          pw.SizedBox(height: 12),

          // Procrastination
          pw.Text('Procrastination', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: ['Task', 'Delays'],
            data: procrastination.map((p) => [p.$1, p.$2]).toList(),
          ),
          pw.Bullet(text: 'Total procrastinated: ${procrastination.fold<int>(0, (p, e) => p + e.$2)} tasks'),
          pw.Bullet(text: 'Worst offender: ${procrastination.reduce((a, b) => a.$2 >= b.$2 ? a : b).$1}'),
          pw.SizedBox(height: 12),

          // Gratitude
          pw.Text('Gratitude Journal', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Bullet(text: 'Entries this week: 5 / 7'),
          pw.Bullet(text: 'Consistency: 71%'),
          pw.SizedBox(height: 12),

          // Goals
          pw.Text('Goals Tracker', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: ['Goal', 'Progress %'],
            data: goals.map((g) => [g.$1, (g.$2 * 100).toStringAsFixed(0)]).toList(),
          ),
          pw.SizedBox(height: 12),

          // Passion projects
          pw.Text('Passion Projects', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: ['Project', 'Progress %'],
            data: projects.map((p) => [p.$1, (p.$2 * 100).toStringAsFixed(0)]).toList(),
          ),
          pw.SizedBox(height: 12),

          // AI insight
          pw.Text('AI Insight', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Text('Afternoon sessions show higher drop-off. Move deep work to mornings, block 90-minute focus sprints, and insert a 10-minute walk after each session.'),
        ],
      ),
    );
    await Printing.sharePdf(bytes: await doc.save(), filename: 'tobi-analytics.pdf');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF export ready')));
    }
  }

  void _toggleVisibility(String key) {
    setState(() => _visibility[key] = !(_visibility[key] ?? true));
  }

  void _reorderCards(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _cardOrder.removeAt(oldIndex);
      _cardOrder.insert(newIndex, item);
    });
  }

  void _openManageSheet() {
    const titles = {
      'productivity': 'Productivity trend',
      'tasks': 'Task completion',
      'habits': 'Habit tracker',
      'focus': 'Focus distribution',
      'balance': 'Life balance',
      'heatmap': 'Productivity heatmap',
      'streaks': 'Streak summary',
      'ai': 'AI insight',
      'procrastination': 'Procrastination',
      'gratitude': 'Gratitude journal',
      'goals': 'Goals tracker',
      'passion': 'Passion projects',
    };

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Manage stats cards',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 360,
                    child: ReorderableListView(
                      buildDefaultDragHandles: false,
                      onReorder: (oldIndex, newIndex) {
                        _reorderCards(oldIndex, newIndex);
                        setSheetState(() {});
                      },
                      children: [
                        for (var i = 0; i < _cardOrder.length; i++)
                          ListTile(
                            key: ValueKey(_cardOrder[i]),
                            leading: Checkbox(
                              value: _visibility[_cardOrder[i]] ?? true,
                              onChanged: (v) {
                                setSheetState(() => _visibility[_cardOrder[i]] = v ?? true);
                                setState(() {});
                              },
                            ),
                            title: Text(titles[_cardOrder[i]] ?? _cardOrder[i]),
                            trailing: ReorderableDragStartListener(
                              index: i,
                              child: const Icon(Icons.drag_handle),
                            ),
                            onTap: () {
                              final current = _visibility[_cardOrder[i]] ?? true;
                              setSheetState(() => _visibility[_cardOrder[i]] = !current);
                              setState(() {});
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Long-press to drag and reorder. Uncheck to hide.', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildOrderedCards() {
    final widgets = <Widget>[];
    for (final key in _cardOrder) {
      if (!(_visibility[key] ?? true)) continue;
      switch (key) {
        case 'productivity':
          widgets.add(_buildProductivityCard());
          break;
        case 'tasks':
          widgets.add(_buildTaskCompletionCard());
          break;
        case 'habits':
          widgets.add(_buildHabitConsistencyCard());
          break;
        case 'focus':
          widgets.add(_buildFocusDistributionCard());
          break;
        case 'balance':
          widgets.add(_buildLifeBalanceCard());
          break;
        case 'heatmap':
          widgets.add(_buildHeatmapCard());
          break;
        case 'streaks':
          widgets.add(_buildStreakCard());
          break;
        case 'ai':
          widgets.add(_buildAiInsightCard());
          break;
        case 'procrastination':
          widgets.add(_buildProcrastinationCard());
          break;
        case 'gratitude':
          widgets.add(_buildGratitudeCard());
          break;
        case 'goals':
          widgets.add(_buildGoalTrackerCard());
          break;
        case 'passion':
          widgets.add(_buildPassionProjectsCard());
          break;
        default:
          break;
      }
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: const Text('Analytics & Reports'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _toggleVisibility,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'productivity', child: Text('Productivity')),
              PopupMenuItem(value: 'tasks', child: Text('Tasks')),
              PopupMenuItem(value: 'habits', child: Text('Habits')),
              PopupMenuItem(value: 'focus', child: Text('Focus')),
              PopupMenuItem(value: 'balance', child: Text('Life Balance')),
              PopupMenuItem(value: 'heatmap', child: Text('Productivity Heatmap')),
              PopupMenuItem(value: 'streaks', child: Text('Streaks')),
              PopupMenuItem(value: 'ai', child: Text('AI Insight')),
            ],
          ),
        ],
      ),
      body: SoftBackground(
        padding: const EdgeInsets.all(AppSpacing.lg),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF3D9), Color(0xFFFFD6E8), Color(0xFFC5F5FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: PillButton(
                    label: 'Manage cards',
                    prefix: const Icon(Icons.tune, size: 18),
                    isPrimary: false,
                    onPressed: _openManageSheet,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildHeader(),
                const SizedBox(height: AppSpacing.md),
                _buildPeriodSelector(),
                const SizedBox(height: AppSpacing.md),
                ..._buildOrderedCards(),
                const SizedBox(height: AppSpacing.lg),
                _buildExportRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SoftCard(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.lg),
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Quest Analytics',
            subtitle: 'Gamified view • $_selectedPeriod mode',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.auto_awesome, size: 16, color: AppColors.textPrimary),
                  SizedBox(width: 6),
                  Text('Season live', style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [Color(0xFFFFB74D), Color(0xFFFF8A65)]),
                  boxShadow: [
                    BoxShadow(color: Colors.orange.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 6)),
                  ],
                ),
                child: const Icon(Icons.sports_esports, color: Colors.white, size: 26),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Level 12 • Tobi Explorer', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: LinearProgressIndicator(
                        minHeight: 10,
                        value: 0.78,
                        backgroundColor: AppColors.surfaceSoft,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF8A65)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('820 XP / 1050 XP to Level 13', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0D7),
                      borderRadius: BorderRadius.circular(AppRadius.large),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.stars, color: Color(0xFFFFB74D), size: 18),
                        SizedBox(width: 6),
                        Text('2,450 coins', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F7FF),
                      borderRadius: BorderRadius.circular(AppRadius.large),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.local_fire_department, color: Color(0xFFFF7043), size: 18),
                        SizedBox(width: 6),
                        Text('Streak 12d', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _statPill('Completion Rate', '82%', AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              _statPill('Discipline Score', '78', AppColors.info),
              const SizedBox(width: AppSpacing.sm),
              _statPill('Goal Probability', '74%', AppColors.success),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slide(begin: const Offset(0, 0.02));
  }

  Widget _statPill(String label, String value, Color accent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.large),
          color: Colors.white.withValues(alpha: 0.65),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Align(
      alignment: Alignment.centerRight,
      child: SoftCard(
        showShadow: false,
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Wrap(
          spacing: AppSpacing.sm,
          children: ['Daily', 'Weekly'].map((period) {
            final selected = _selectedPeriod == period;
            return PillButton(
              label: period,
              isPrimary: selected,
              onPressed: () => setState(() => _selectedPeriod = period),
            );
          }).toList(),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slide(begin: const Offset(0, 0.02));
  }

  Widget _buildProductivityCard() {
    return SoftCard(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.lg),
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Productivity Completion',
            subtitle: 'Curved trend with area fill',
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    barWidth: 4,
                    gradient: LinearGradient(colors: _barGradient),
                    spots: _productivitySpots,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(colors: _barGradient.map((c) => c.withValues(alpha: 0.15)).toList()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 320.ms).slide(begin: const Offset(0, 0.03));
  }

  Widget _buildTaskCompletionCard() {
    return SoftCard(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.lg),
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Task Completion Rate',
            subtitle: 'Daily / Weekly overview',
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  height: 240,
                  child: BarChart(
                    BarChartData(
                      maxY: 100,
                      minY: 0,
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: Colors.black.withValues(alpha: 0.06),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 34,
                            getTitlesWidget: (value, _) => Text(
                              value.toInt().toString(),
                              style: GoogleFonts.nunito(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) {
                                final labels = _selectedPeriod == 'Weekly'
                                  ? ['W1', 'W2', 'W3', 'W4']
                                  : ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                              if (value < 0 || value >= labels.length) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  labels[value.toInt()],
                                  style: GoogleFonts.nunito(
                                    color: AppColors.textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      barGroups: _taskBars,
                    ),
                    swapAnimationDuration: const Duration(milliseconds: 800),
                    swapAnimationCurve: Curves.easeOutBack,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoPill(
                    title: 'Completion',
                    value: '84%',
                    color: const Color(0xFFD6E4FF),
                    textColor: AppColors.textPrimary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _infoPill(
                    title: 'vs last ${_selectedPeriod.toLowerCase()}',
                    value: '+6%',
                    color: const Color(0xFFFFE0EC),
                    textColor: AppColors.textPrimary,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 340.ms).slide(begin: const Offset(0, 0.03));
  }

  Widget _buildHabitConsistencyCard() {
    return SoftCard(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.lg),
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Habit Tracker',
            subtitle: 'Weekly grid with streaks',
          ),
          const SizedBox(height: AppSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 90),
                    ..._habitDays.map((d) => SizedBox(
                          width: 40,
                          child: Center(
                            child: Text(
                              d,
                              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                            ),
                          ),
                        )),
                  ],
                ),
                const SizedBox(height: 8),
                ..._habitRows.map((row) {
                  final data = List<bool>.from(row['data'] as List);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 90,
                          child: Text(
                            row['name'] as String,
                            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                        ),
                        ...data.map((done) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: done ? const Color(0xFFDFF7F2) : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: done ? const Color(0xFF7CD992) : AppColors.border),
                                ),
                                child: done
                                    ? const Icon(Icons.check, size: 16, color: Color(0xFF2E7D32))
                                    : const SizedBox.shrink(),
                              ).animate().scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)).fadeIn(),
                            )),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            const Icon(Icons.local_fire_department, size: 16, color: Color(0xFFFFA726)),
                            const SizedBox(width: 4),
                            Text('${row['streak']}d', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 360.ms).slide(begin: const Offset(0, 0.03));
  }

  Widget _buildFocusDistributionCard() {
    return SoftCard(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.lg),
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Focus Sessions',
            subtitle: 'Distribution by type',
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  height: 220,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: _focusSections,
                    ),
                    swapAnimationDuration: const Duration(milliseconds: 800),
                    swapAnimationCurve: Curves.easeOutBack,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoPill(
                    title: 'Total focus',
                    value: '12.4h',
                    color: const Color(0xFFD6E4FF),
                    textColor: AppColors.textPrimary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _infoPill(
                    title: 'vs last ${_selectedPeriod.toLowerCase()}',
                    value: '+9%',
                    color: const Color(0xFFFFE0EC),
                    textColor: AppColors.textPrimary,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _focusSections.map((s) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: s.gradient,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(s.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text('${s.value.toInt()} sessions', style: const TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 380.ms).slide(begin: const Offset(0, 0.03));
  }

  Widget _buildLifeBalanceCard() {
    final items = [
      ('Work', 0.76, const Color(0xFF8E8BE6)),
      ('Health', 0.64, const Color(0xFF9AC6F3)),
      ('Social', 0.52, const Color(0xFFF3A5C0)),
      ('Learning', 0.70, const Color(0xFFD7C5F5)),
    ];
    return SoftCard(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.lg),
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Life Balance Score',
            subtitle: 'Balance by domain',
          ),
          const SizedBox(height: AppSpacing.md),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    SizedBox(width: 80, child: Text(item.$1, style: const TextStyle(color: AppColors.textPrimary))),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                        child: LinearProgressIndicator(
                          minHeight: 12,
                          value: item.$2,
                          backgroundColor: Colors.white.withValues(alpha: 0.5),
                          valueColor: AlwaysStoppedAnimation<Color>(item.$3),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('${(item.$2 * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              )),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slide(begin: const Offset(0, 0.03));
  }

  Widget _buildHeatmapCard() {
    final data = List.generate(35, (i) => (i + 1, (i % 7) + 1));
    return SoftCard(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.lg),
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Productivity Heatmap',
            subtitle: '5 weeks at a glance',
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, crossAxisSpacing: 6, mainAxisSpacing: 6),
            itemCount: data.length,
            itemBuilder: (_, i) {
              final intensity = data[i].$2 / 7;
              return Container(
                decoration: BoxDecoration(
                  color: Color.lerp(AppColors.primaryLight, AppColors.primary, intensity),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 420.ms).slide(begin: const Offset(0, 0.03));
  }

  Widget _buildStreakCard() {
    final rows = [
      ('Focus', '7 days', Icons.local_fire_department, true),
      ('Habits', '12 days', Icons.check_circle, false),
      ('Tasks', '9 days', Icons.assignment_turned_in, false),
    ];
    return SoftCard(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.lg),
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Streaks',
            subtitle: 'Momentum signals',
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: rows.map((r) {
              final isLongest = r.$4;
              return Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isLongest ? const Color(0xFFD6E4FF) : Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(r.$3, size: 18, color: AppColors.textPrimary),
                    const SizedBox(width: 8),
                    Text(r.$1, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(width: 10),
                    Text(r.$2, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 440.ms).slide(begin: const Offset(0, 0.03));
  }

  Widget _buildAiInsightCard() {
    return SoftCard(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.lg),
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'AI Insight',
            subtitle: 'Suggested next moves',
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(AppRadius.large),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text(
              'Afternoon sessions show higher drop-off. Move deep work to mornings, block 90-minute focus sprints, and insert a 10-minute walk after each session.',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 460.ms).slide(begin: const Offset(0, 0.03));
  }

  Widget _buildProcrastinationCard() {
    final tasks = [
      ('Inbox Zero', 3),
      ('Deep Work', 5),
      ('Email Sweep', 2),
      ('Exercise', 4),
    ];
    return SoftCard(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.lg),
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Procrastination',
            subtitle: 'Where delays happen',
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  height: 220,
                  child: BarChart(
                    BarChartData(
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(color: Colors.black.withValues(alpha: 0.06), strokeWidth: 1),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) {
                              if (value < 0 || value >= tasks.length) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(tasks[value.toInt()].$1, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: tasks.asMap().entries.map((e) {
                        return BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: e.value.$2.toDouble(),
                              width: 18,
                              borderRadius: BorderRadius.circular(10),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFC6E0), Color(0xFFFFD6A5)],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                    swapAnimationDuration: const Duration(milliseconds: 800),
                    swapAnimationCurve: Curves.easeOutBack,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoPill(
                    title: 'Total procrastinated',
                    value: '${tasks.fold<int>(0, (p, e) => p + e.$2)} tasks',
                    color: const Color(0xFFFFE0EC),
                    textColor: AppColors.textPrimary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _infoPill(
                    title: 'Worst offender',
                    value: tasks.reduce((a, b) => a.$2 >= b.$2 ? a : b).$1,
                    color: const Color(0xFFD6E4FF),
                    textColor: AppColors.textPrimary,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 480.ms).slide(begin: const Offset(0, 0.03));
  }

  Widget _buildGratitudeCard() {
    final sparkSpots = List.generate(7, (i) => FlSpot(i.toDouble(), (sin(i.toDouble()) * 2) + 6));
    return SoftCard(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.lg),
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Gratitude Journal',
            subtitle: 'Entries and consistency',
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 120,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          barWidth: 3,
                          gradient: const LinearGradient(colors: [Color(0xFFB8C6FF), Color(0xFF9EE6CF)]),
                          spots: sparkSpots,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(colors: [Color(0xFFB8C6FF), Color(0xFF9EE6CF)], begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: [0, 1]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoPill(
                    title: 'Entries this week',
                    value: '5 / 7',
                    color: const Color(0xFFFFE0EC),
                    textColor: AppColors.textPrimary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _infoPill(
                    title: 'Consistency',
                    value: '71%',
                    color: const Color(0xFFD6E4FF),
                    textColor: AppColors.textPrimary,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slide(begin: const Offset(0, 0.03));
  }

  Widget _buildGoalTrackerCard() {
    final goals = [
      ('Launch MVP', 0.82),
      ('Grow newsletter', 0.63),
      ('Fitness plan', 0.55),
    ];
    return SoftCard(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.lg),
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Goal Tracker',
            subtitle: 'Rounded progress bars',
          ),
          const SizedBox(height: AppSpacing.md),
          ...goals.map((g) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(g.$1, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        Text('${(g.$2 * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: LinearProgressIndicator(
                        minHeight: 12,
                        value: g.$2,
                        backgroundColor: AppColors.surfaceSoft,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFB8C6FF)),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    ).animate().fadeIn(duration: 520.ms).slide(begin: const Offset(0, 0.03));
  }

  Widget _buildPassionProjectsCard() {
    final projects = [
      ('Tobi mascot pack', 0.78),
      ('Calm UI kit', 0.52),
      ('Wellness bot', 0.35),
    ];
    return SoftCard(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.lg),
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Passion Projects',
            subtitle: 'Progress and hours',
          ),
          const SizedBox(height: AppSpacing.md),
          ...projects.map((p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(p.$1, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        Text('${(p.$2 * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: LinearProgressIndicator(
                        minHeight: 12,
                        value: p.$2,
                        backgroundColor: AppColors.surfaceSoft,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFC6E0)),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    ).animate().fadeIn(duration: 540.ms).slide(begin: const Offset(0, 0.03));
  }

  Widget _infoPill({
    required String title,
    required String value,
    required Color color,
    Color textColor = AppColors.textPrimary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: textColor.withValues(alpha: 0.8), fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildExportRow() {
    return Row(
      children: [
        Expanded(
          child: PillButton(
            label: 'Export PDF',
            prefix: const Icon(Icons.picture_as_pdf, size: 18),
            onPressed: _exportPdf,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PillButton(
            label: 'Export CSV',
            prefix: const Icon(Icons.table_chart, size: 18),
            onPressed: _exportCsv,
            isPrimary: false,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms).slide(begin: const Offset(0, 0.03));
  }
}
