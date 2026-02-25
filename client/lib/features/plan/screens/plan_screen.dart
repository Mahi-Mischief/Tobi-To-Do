import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tobi_todo/core/theme/app_colors.dart';
import 'package:tobi_todo/models/goal_model.dart';
import 'package:tobi_todo/models/habit_model.dart';
import 'package:tobi_todo/models/task_model.dart';
import 'package:tobi_todo/providers/auth_provider.dart';

enum _TaskFilter { all, today, overdue, upcoming, week, month }
enum TaskView { list, matrix, kanban }

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _selectedDay;
  final _taskSearchController = TextEditingController();
  _TaskFilter _taskFilter = _TaskFilter.all;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _selectedDay = DateTime.now();
    _loadInitialTaskView();
  }

  Future<void> _loadInitialTaskView() async {
    final notifier = ref.read(taskViewPreferenceProvider.notifier);
    await notifier.ensureLoaded();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _taskSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskBoardProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan'),
        backgroundColor: AppColors.plan,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Calendar', icon: Icon(Icons.calendar_today)),
            Tab(text: 'To-Do', icon: Icon(Icons.checklist)),
            Tab(text: 'Habits', icon: Icon(Icons.grid_view)),
            Tab(text: 'Goals', icon: Icon(Icons.flag)),
            Tab(text: 'Projects', icon: Icon(Icons.work_outline)),
            Tab(text: 'Involvement', icon: Icon(Icons.groups)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCalendarTab(tasks),
          _buildTasksTab(tasks),
          const _HabitsTab(),
          const _GoalsTab(),
          const _ProjectsTab(),
          const _InvolvementTab(),
        ],
      ),
    );
  }

  Widget _buildCalendarTab(List<Task> tasks) {
    final todayDue = tasks.where((t) => _isSameDay(t.dueDate, _selectedDay)).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalendarDatePicker(
            initialDate: _selectedDay,
            firstDate: DateTime.now().subtract(const Duration(days: 30)),
            lastDate: DateTime.now().add(const Duration(days: 3650)),
            onDateChanged: (d) => setState(() => _selectedDay = d),
          ),
          const SizedBox(height: 12),
          Text('Due on ${DateFormat('EEE, MMM d').format(_selectedDay)}', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (todayDue.isEmpty)
            const Text('Nothing due on this date.')
          else
            ...todayDue.map((t) => Card(
                  child: ListTile(
                    leading: _PriorityDot(priority: t.priority),
                    title: Text(t.title),
                    subtitle: Text(t.dueDate != null ? DateFormat('h:mma').format(t.dueDate!) : 'All day'),
                    trailing: _StatusChip(status: t.status),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildTasksTab(List<Task> tasks) {
    final view = ref.watch(taskViewPreferenceProvider).maybeWhen(data: (v) => v, orElse: () => TaskView.list);
    final filtered = _filterTasks(tasks, _taskFilter, _taskSearchController.text);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _taskSearchController,
            decoration: InputDecoration(
              hintText: 'Search tasks by name... (fuzzy contains)',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        _TaskFilterChips(
          active: _taskFilter,
          onChanged: (f) => setState(() => _taskFilter = f),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: _TaskViewToggle(
            active: view,
            onChanged: (v) => ref.read(taskViewPreferenceProvider.notifier).setView(v),
          ),
        ),
        Expanded(
          child: view == TaskView.list
              ? _TaskList(tasks: filtered)
              : view == TaskView.matrix
                  ? _EisenhowerMatrix(tasks: filtered)
                  : _KanbanBoard(tasks: filtered),
        ),
        const Divider(height: 1),
        const SizedBox(height: 8),
        const Text('Quick Eisenhower view'),
        SizedBox(height: 200, child: _EisenhowerMatrix(tasks: filtered, dense: true)),
      ],
    );
  }

  List<Task> _filterTasks(List<Task> tasks, _TaskFilter filter, String query) {
    final now = DateTime.now();
    final lower = query.trim().toLowerCase();

    bool matchesFilter(Task t) {
      final due = t.dueDate;
      switch (filter) {
        case _TaskFilter.all:
          return true;
        case _TaskFilter.today:
          return _isSameDay(due, now);
        case _TaskFilter.overdue:
          return due != null && due.isBefore(now);
        case _TaskFilter.upcoming:
          return due != null && due.isAfter(now);
        case _TaskFilter.week:
          return due != null && due.isAfter(now) && due.isBefore(now.add(const Duration(days: 7)));
        case _TaskFilter.month:
          return due != null && due.isAfter(now) && due.isBefore(now.add(const Duration(days: 31)));
      }
    }

    bool matchesQuery(Task t) {
      if (lower.isEmpty) return true;
      final title = t.title.toLowerCase();
      return title.contains(lower) || _levenshteinDistance(title, lower) <= 3;
    }

    return tasks.where((t) => matchesFilter(t) && matchesQuery(t)).toList();
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  int _levenshteinDistance(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;
    final v0 = List<int>.generate(t.length + 1, (i) => i);
    final v1 = List<int>.filled(t.length + 1, 0);
    for (var i = 0; i < s.length; i++) {
      v1[0] = i + 1;
      for (var j = 0; j < t.length; j++) {
        final cost = s[i] == t[j] ? 0 : 1;
        v1[j + 1] = [v1[j] + 1, v0[j + 1] + 1, v0[j] + cost].reduce((a, b) => a < b ? a : b);
      }
      for (var j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v1[t.length];
  }
}

class _TaskFilterChips extends StatelessWidget {
  final _TaskFilter active;
  final ValueChanged<_TaskFilter> onChanged;

  const _TaskFilterChips({required this.active, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final items = [
      (_TaskFilter.all, 'All'),
      (_TaskFilter.today, 'Today'),
      (_TaskFilter.overdue, 'Overdue'),
      (_TaskFilter.upcoming, 'Upcoming'),
      (_TaskFilter.week, 'This week'),
      (_TaskFilter.month, 'This month'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(item.$2),
                  selected: active == item.$1,
                  onSelected: (_) => onChanged(item.$1),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _TaskViewToggle extends StatelessWidget {
  final TaskView active;
  final ValueChanged<TaskView> onChanged;

  const _TaskViewToggle({required this.active, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TaskView.values
          .map(
            (v) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(v == TaskView.list
                      ? 'List'
                      : v == TaskView.matrix
                          ? 'Eisenhower'
                          : 'Kanban'),
                  selected: active == v,
                  onSelected: (_) => onChanged(v),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _TaskList extends ConsumerWidget {
  final List<Task> tasks;
  const _TaskList({required this.tasks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: _PriorityDot(priority: task.priority),
            title: Text(task.title),
            subtitle: Text(task.dueDate != null ? 'Due ${DateFormat('MMM d, h:mm a').format(task.dueDate!)}' : 'No due date'),
            trailing: _StatusChip(status: task.status),
            onTap: () => ref.read(taskBoardProvider.notifier).toggleStatus(task.id),
          ),
        );
      },
    );
  }
}

class _EisenhowerMatrix extends ConsumerWidget {
  final List<Task> tasks;
  final bool dense;
  const _EisenhowerMatrix({required this.tasks, this.dense = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quadrants = [
      ('Do now', Colors.red.shade100, (Task t) => _quadrant(t) == 1),
      ('Schedule', Colors.orange.shade100, (Task t) => _quadrant(t) == 2),
      ('Delegate', Colors.blue.shade100, (Task t) => _quadrant(t) == 3),
      ('Eliminate', Colors.green.shade100, (Task t) => _quadrant(t) == 4),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: dense ? const NeverScrollableScrollPhysics() : null,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      padding: const EdgeInsets.all(12),
      childAspectRatio: dense ? 2 : 1.2,
      children: quadrants.map((q) {
        final items = tasks.where(q.$3).toList();
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: q.$2, borderRadius: BorderRadius.circular(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(q.$1, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (items.isEmpty) const Text('No tasks here')
              else
                ...items.map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        _PriorityDot(priority: t.priority),
                        const SizedBox(width: 8),
                        Expanded(child: Text(t.title, maxLines: 2, overflow: TextOverflow.ellipsis)),
                        IconButton(
                          icon: const Icon(Icons.open_in_new, size: 18),
                          onPressed: () => ref.read(taskBoardProvider.notifier).cycleQuadrant(t.id),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  int _quadrant(Task t) {
    final dueSoon = t.dueDate != null && t.dueDate!.difference(DateTime.now()).inDays <= 2;
    final important = t.priority == TaskPriority.high || t.category.toLowerCase().contains('exam');
    if (important && dueSoon) return 1;
    if (important && !dueSoon) return 2;
    if (!important && dueSoon) return 3;
    return 4;
  }
}

class _KanbanBoard extends ConsumerWidget {
  final List<Task> tasks;
  const _KanbanBoard({required this.tasks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final columns = [
      ('To Do', TaskStatus.todo),
      ('In Progress', TaskStatus.inProgress),
      ('Done', TaskStatus.completed),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: columns.map((c) {
          final items = tasks.where((t) => t.status == c.$2).toList();
          return SizedBox(
            width: 260,
            child: Card(
              margin: const EdgeInsets.fromLTRB(12, 0, 0, 12),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.$1, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...items.map(
                      (t) => Card(
                        child: ListTile(
                          dense: true,
                          title: Text(t.title),
                          subtitle: Text(t.dueDate != null ? 'Due ${DateFormat('MMM d').format(t.dueDate!)}' : 'No due'),
                          leading: _PriorityDot(priority: t.priority),
                          trailing: PopupMenuButton<TaskStatus>(
                            onSelected: (s) => ref.read(taskBoardProvider.notifier).setStatus(t.id, s),
                            itemBuilder: (_) => TaskStatus.values
                                .map((s) => PopupMenuItem(value: s, child: Text(s.name)))
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PriorityDot extends StatelessWidget {
  final TaskPriority priority;

  const _PriorityDot({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (priority) {
      case TaskPriority.high:
        color = Colors.red;
        break;
      case TaskPriority.medium:
        color = Colors.orange;
        break;
      case TaskPriority.low:
        color = Colors.green;
        break;
    }
    return CircleAvatar(radius: 6, backgroundColor: color);
  }
}

class _StatusChip extends StatelessWidget {
  final TaskStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final map = {
      TaskStatus.todo: (label: 'To do', color: Colors.grey.shade300),
      TaskStatus.inProgress: (label: 'In progress', color: Colors.blue.shade100),
      TaskStatus.completed: (label: 'Done', color: Colors.green.shade200),
    };
    final cfg = map[status]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: cfg.color, borderRadius: BorderRadius.circular(12)),
      child: Text(cfg.label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

// Habits tab
class _HabitsTab extends ConsumerWidget {
  const _HabitsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitTrackerProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _showHabitDialog(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Add habit'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showHabitDialog(context, ref, isBad: true),
                icon: const Icon(Icons.block),
                label: const Text('Add bad habit'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(habit.title, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(width: 8),
                          if (habit.isBad) const Chip(label: Text('Bad habit')),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _HabitGrid(habit: habit),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showHabitDialog(BuildContext context, WidgetRef ref, {bool isBad = false}) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isBad ? 'Add bad habit' : 'Add habit'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(habitTrackerProvider.notifier).addHabit(controller.text, isBad: isBad);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _HabitGrid extends ConsumerWidget {
  final HabitEntry habit;
  const _HabitGrid({required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final start = DateTime.now().subtract(const Duration(days: 6));
    final days = List.generate(7, (i) => start.add(Duration(days: i)));
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: days.map((d) {
        final key = _dateKey(d);
        final done = habit.completedDates.contains(key);
        return FilterChip(
          label: Text(DateFormat('E').format(d)),
          selected: done,
          onSelected: (_) => ref.read(habitTrackerProvider.notifier).toggle(habit.id, key),
        );
      }).toList(),
    );
  }
}

// Goals tab
class _GoalsTab extends ConsumerWidget {
  const _GoalsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalBoardProvider);
    final shortTerm = goals.where((g) => g.isLongTerm == false).toList();
    final longTerm = goals.where((g) => g.isLongTerm).toList();

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text('Short term', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...shortTerm.map((g) => _GoalCard(goal: g)),
        const SizedBox(height: 16),
        Text('Long term', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...longTerm.map((g) => _GoalCard(goal: g)),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => _addGoalDialog(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Add goal'),
        ),
      ],
    );
  }

  Future<void> _addGoalDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    bool longTerm = false;
    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: const Text('Add goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: controller, decoration: const InputDecoration(hintText: 'Goal title')),
              CheckboxListTile(
                value: longTerm,
                onChanged: (v) => setState(() => longTerm = v ?? false),
                title: const Text('Long term'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                ref.read(goalBoardProvider.notifier).addGoal(controller.text, isLongTerm: longTerm);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      }),
    );
  }
}

class _GoalCard extends ConsumerWidget {
  final GoalEntry goal;
  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(goal.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (goal.targetDate != null) Text('Target ${DateFormat('MMM d, y').format(goal.targetDate!)}'),
            Slider(
              value: goal.progress.toDouble(),
              onChanged: (v) => ref.read(goalBoardProvider.notifier).setProgress(goal.id, v.round()),
              min: 0,
              max: 100,
              divisions: 20,
              label: '${goal.progress}% ',
            ),
          ],
        ),
        trailing: Text(goal.isLongTerm ? 'Long' : 'Short'),
      ),
    );
  }
}

// Projects tab
class _ProjectsTab extends ConsumerWidget {
  const _ProjectsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectBoardProvider);
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        ...projects.map(
          (p) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(p.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (p.dueDate != null) Text('Due ${DateFormat('MMM d').format(p.dueDate!)}'),
                  LinearProgressIndicator(value: p.progress / 100),
                  Text('${p.tasksDone}/${p.tasksTotal} tasks done'),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.add_task),
                onPressed: () => ref.read(projectBoardProvider.notifier).bumpProgress(p.id, 10),
              ),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => ref.read(projectBoardProvider.notifier).addProject('New project'),
          icon: const Icon(Icons.add),
          label: const Text('Add project'),
        ),
      ],
    );
  }
}

// Involvement tab
class _InvolvementTab extends ConsumerWidget {
  const _InvolvementTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(involvementProvider);
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        ...items.map(
          (i) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              title: Text(i.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Type: ${i.type} • When: ${DateFormat('MMM d, h:mma').format(i.when)}'),
                  if (i.trackHours)
                    Text('Hours ${i.hoursCompleted}/${i.hoursRequired} (${i.hoursProspective} prospective)'),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.add_chart),
                onPressed: () => _addHourLog(context, ref, i.id),
              ),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _addInvolvement(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Add involvement'),
        ),
      ],
    );
  }

  Future<void> _addInvolvement(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    final hoursController = TextEditingController();
    bool track = false;
    String type = 'Club';
    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: const Text('Add involvement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(hintText: 'Title')),
              DropdownButton<String>(
                value: type,
                items: const [DropdownMenuItem(value: 'Club', child: Text('Club')), DropdownMenuItem(value: 'Volunteering', child: Text('Volunteering')), DropdownMenuItem(value: 'Extracurricular', child: Text('Extracurricular'))],
                onChanged: (v) => setState(() => type = v ?? 'Club'),
              ),
              CheckboxListTile(
                value: track,
                onChanged: (v) => setState(() => track = v ?? false),
                title: const Text('Track hours'),
              ),
              if (track)
                TextField(
                  controller: hoursController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Required hours'),
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                ref.read(involvementProvider.notifier).addItem(
                      title: titleController.text,
                      type: type,
                      trackHours: track,
                      requiredHours: double.tryParse(hoursController.text) ?? 0,
                    );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _addHourLog(BuildContext context, WidgetRef ref, String id) async {
    final hoursController = TextEditingController();
    final noteController = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add hour log'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: hoursController, decoration: const InputDecoration(hintText: 'Hours'), keyboardType: TextInputType.number),
            TextField(controller: noteController, decoration: const InputDecoration(hintText: 'Activity')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(involvementProvider.notifier).addHourLog(
                    id: id,
                    hours: double.tryParse(hoursController.text) ?? 0,
                    note: noteController.text,
                  );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// Providers and state notifiers
final taskBoardProvider = StateNotifierProvider<TaskBoardNotifier, List<Task>>((ref) {
  return TaskBoardNotifier(ref);
});

class TaskBoardNotifier extends StateNotifier<List<Task>> {
  final Ref ref;
  TaskBoardNotifier(this.ref)
      : super([
          Task(
            id: 't1',
            userId: 'demo',
            title: 'Finish chemistry lab',
            description: 'Lab report submission',
            dueDate: DateTime.now().add(const Duration(hours: 6)),
            priority: TaskPriority.high,
            category: 'school',
            status: TaskStatus.todo,
            completed: false,
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            updatedAt: DateTime.now(),
          ),
          Task(
            id: 't2',
            userId: 'demo',
            title: 'Outline history essay',
            description: 'Draft outline',
            dueDate: DateTime.now().add(const Duration(days: 2)),
            priority: TaskPriority.medium,
            category: 'essay',
            status: TaskStatus.inProgress,
            completed: false,
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
            updatedAt: DateTime.now(),
          ),
          Task(
            id: 't3',
            userId: 'demo',
            title: 'Weekly review',
            description: 'Plan next week',
            dueDate: DateTime.now().add(const Duration(days: 5)),
            priority: TaskPriority.low,
            category: 'planning',
            status: TaskStatus.todo,
            completed: false,
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
            updatedAt: DateTime.now(),
          ),
          Task(
            id: 't4',
            userId: 'demo',
            title: 'CS project integration',
            description: 'Merge feature branch',
            dueDate: DateTime.now().add(const Duration(days: 1)),
            priority: TaskPriority.high,
            category: 'project',
            status: TaskStatus.inProgress,
            completed: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ]);

  void setStatus(String id, TaskStatus status) {
    state = state.map((t) => t.id == id ? t.copyWith(status: status, updatedAt: DateTime.now()) : t).toList();
  }

  void toggleStatus(String id) {
    state = state.map((t) {
      if (t.id != id) return t;
      final next = t.status == TaskStatus.completed
          ? TaskStatus.todo
          : t.status == TaskStatus.todo
              ? TaskStatus.inProgress
              : TaskStatus.completed;
      return t.copyWith(status: next, completed: next == TaskStatus.completed, updatedAt: DateTime.now());
    }).toList();
  }

  void cycleQuadrant(String id) {
    state = state.map((t) {
      if (t.id != id) return t;
      final nextPriority = t.priority == TaskPriority.high
          ? TaskPriority.medium
          : t.priority == TaskPriority.medium
              ? TaskPriority.low
              : TaskPriority.high;
      return t.copyWith(priority: nextPriority, updatedAt: DateTime.now());
    }).toList();
  }
}

final taskViewPreferenceProvider = AsyncNotifierProvider<TaskViewPreferenceNotifier, TaskView>(() {
  return TaskViewPreferenceNotifier();
});

class TaskViewPreferenceNotifier extends AsyncNotifier<TaskView> {
  SharedPreferences? _prefs;

  @override
  Future<TaskView> build() async {
    return TaskView.list;
  }

  Future<void> ensureLoaded() async {
    _prefs ??= await SharedPreferences.getInstance();
    final key = await _storageKey();
    final stored = _prefs!.getString(key);
    if (stored != null) {
      state = AsyncValue.data(TaskView.values.firstWhere((v) => v.name == stored, orElse: () => TaskView.list));
    } else {
      state = const AsyncValue.data(TaskView.list);
    }
  }

  Future<void> setView(TaskView view) async {
    await ensureLoaded();
    final key = await _storageKey();
    await _prefs!.setString(key, view.name);
    state = AsyncValue.data(view);
  }

  Future<String> _storageKey() async {
    final user = ref.read(authProvider).maybeWhen(data: (u) => u?.id, orElse: () => null);
    return 'task_view_${user ?? 'anon'}';
  }
}

// Habit tracking
class HabitEntry {
  final String id;
  final String title;
  final bool isBad;
  final Set<String> completedDates;

  HabitEntry({required this.id, required this.title, this.isBad = false, Set<String>? completedDates})
      : completedDates = completedDates ?? <String>{};
}

final habitTrackerProvider = StateNotifierProvider<HabitTrackerNotifier, List<HabitEntry>>((ref) {
  return HabitTrackerNotifier();
});

class HabitTrackerNotifier extends StateNotifier<List<HabitEntry>> {
  HabitTrackerNotifier()
      : super([
          HabitEntry(id: 'h1', title: 'Morning run'),
          HabitEntry(id: 'h2', title: 'Read 10 pages'),
          HabitEntry(id: 'h3', title: 'No soda', isBad: true),
        ]);

  void addHabit(String title, {bool isBad = false}) {
    if (title.trim().isEmpty) return;
    state = [...state, HabitEntry(id: 'h${DateTime.now().millisecondsSinceEpoch}', title: title.trim(), isBad: isBad)];
  }

  void toggle(String id, String dayKey) {
    state = state
        .map((h) => h.id == id
            ? HabitEntry(
                id: h.id,
                title: h.title,
                isBad: h.isBad,
                completedDates: h.completedDates.contains(dayKey)
                    ? (Set<String>.from(h.completedDates)..remove(dayKey))
                    : (Set<String>.from(h.completedDates)..add(dayKey)),
              )
            : h)
        .toList();
  }
}

String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

// Goals
class GoalEntry {
  final String id;
  final String title;
  final bool isLongTerm;
  final DateTime? targetDate;
  final int progress;

  GoalEntry({required this.id, required this.title, required this.isLongTerm, this.targetDate, this.progress = 0});
}

final goalBoardProvider = StateNotifierProvider<GoalBoardNotifier, List<GoalEntry>>((ref) {
  return GoalBoardNotifier();
});

class GoalBoardNotifier extends StateNotifier<List<GoalEntry>> {
  GoalBoardNotifier()
      : super([
          GoalEntry(id: 'g1', title: 'Finish semester strong', isLongTerm: false, targetDate: DateTime.now().add(const Duration(days: 30)), progress: 30),
          GoalEntry(id: 'g2', title: 'Publish app', isLongTerm: true, targetDate: DateTime.now().add(const Duration(days: 180)), progress: 10),
        ]);

  void addGoal(String title, {required bool isLongTerm}) {
    state = [...state, GoalEntry(id: 'g${DateTime.now().millisecondsSinceEpoch}', title: title, isLongTerm: isLongTerm)];
  }

  void setProgress(String id, int progress) {
    state = state.map((g) => g.id == id ? GoalEntry(id: g.id, title: g.title, isLongTerm: g.isLongTerm, targetDate: g.targetDate, progress: progress) : g).toList();
  }
}

// Projects
class ProjectEntry {
  final String id;
  final String name;
  final DateTime? dueDate;
  final int progress;
  final int tasksDone;
  final int tasksTotal;

  ProjectEntry({required this.id, required this.name, this.dueDate, this.progress = 0, this.tasksDone = 0, this.tasksTotal = 5});
}

final projectBoardProvider = StateNotifierProvider<ProjectBoardNotifier, List<ProjectEntry>>((ref) {
  return ProjectBoardNotifier();
});

class ProjectBoardNotifier extends StateNotifier<List<ProjectEntry>> {
  ProjectBoardNotifier()
      : super([
          ProjectEntry(id: 'p1', name: 'Mobile app', dueDate: DateTime.now().add(const Duration(days: 40)), progress: 40, tasksDone: 8, tasksTotal: 12),
          ProjectEntry(id: 'p2', name: 'Science fair', dueDate: DateTime.now().add(const Duration(days: 15)), progress: 20, tasksDone: 2, tasksTotal: 10),
        ]);

  void addProject(String name) {
    state = [...state, ProjectEntry(id: 'p${DateTime.now().millisecondsSinceEpoch}', name: name, tasksTotal: 5)];
  }

  void bumpProgress(String id, int delta) {
    state = state
        .map((p) => p.id == id
            ? ProjectEntry(
                id: p.id,
                name: p.name,
                dueDate: p.dueDate,
                progress: (p.progress + delta).clamp(0, 100),
                tasksDone: (p.tasksDone + 1).clamp(0, p.tasksTotal),
                tasksTotal: p.tasksTotal,
              )
            : p)
        .toList();
  }
}

// Involvement
class InvolvementItem {
  final String id;
  final String title;
  final String type; // Club, Volunteering, Extracurricular
  final bool trackHours;
  final double hoursRequired;
  final double hoursCompleted;
  final double hoursProspective;
  final DateTime when;

  InvolvementItem({
    required this.id,
    required this.title,
    required this.type,
    required this.when,
    this.trackHours = false,
    this.hoursRequired = 0,
    this.hoursCompleted = 0,
    this.hoursProspective = 0,
  });
}

final involvementProvider = StateNotifierProvider<InvolvementNotifier, List<InvolvementItem>>((ref) {
  return InvolvementNotifier();
});

class InvolvementNotifier extends StateNotifier<List<InvolvementItem>> {
  InvolvementNotifier()
      : super([
          InvolvementItem(id: 'c1', title: 'Robotics club', type: 'Club', when: DateTime.now().add(const Duration(days: 1)), trackHours: true, hoursRequired: 40, hoursCompleted: 12, hoursProspective: 6),
          InvolvementItem(id: 'v1', title: 'Food bank shift', type: 'Volunteering', when: DateTime.now().add(const Duration(days: 3)), trackHours: true, hoursRequired: 20, hoursCompleted: 5, hoursProspective: 4),
        ]);

  void addItem({required String title, required String type, required bool trackHours, double requiredHours = 0}) {
    state = [
      ...state,
      InvolvementItem(
        id: 'inv${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        type: type,
        when: DateTime.now().add(const Duration(days: 2)),
        trackHours: trackHours,
        hoursRequired: requiredHours,
        hoursCompleted: 0,
        hoursProspective: 0,
      ),
    ];
  }

  void addHourLog({required String id, required double hours, required String note}) {
    state = state
        .map((i) => i.id == id
            ? InvolvementItem(
                id: i.id,
                title: i.title,
                type: i.type,
                when: i.when,
                trackHours: i.trackHours,
                hoursRequired: i.hoursRequired,
                hoursCompleted: i.hoursCompleted + hours,
                hoursProspective: (i.hoursProspective - hours).clamp(0, double.infinity),
              )
            : i)
        .toList();
  }
}
