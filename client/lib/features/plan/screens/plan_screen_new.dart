import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tobi_todo/core/theme/app_colors.dart';
import 'package:tobi_todo/shared/services/tobi_service.dart';
// removed unused import: task_provider

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedPriority = 'medium';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: ['low', 'medium', 'high']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedPriority = value ?? 'medium');
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _titleController.clear();
              _descriptionController.clear();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Task "${_titleController.text}" added!')),
              );
              Navigator.pop(context);
              _titleController.clear();
              _descriptionController.clear();
            },
            child: const Text('Add Task'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📋 Plan Your Week',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Organize, prioritize, and conquer',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: '📅 Calendar'),
                Tab(text: '📋 Tasks'),
                Tab(text: '⬜ Kanban'),
              ],
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCalendarView(context),
                  _buildTasksView(context),
                  _buildKanbanView(context),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendarView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month Calendar Header
          Card(
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
                        'December 2024',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: () {
                              TobiService.instance.wave();
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Previous month')));
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: () {
                              TobiService.instance.wave();
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Next month')));
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Calendar Grid
                  GridView.count(
                    crossAxisCount: 7,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(35, (index) {
                      int day = index - 3 + 1;
                      bool isCurrentMonth = day > 0 && day <= 31;
                      bool isToday = isCurrentMonth && day == 15;

                      return Container(
                        decoration: BoxDecoration(
                          color: isToday ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            isCurrentMonth ? '$day' : '',
                            style: TextStyle(
                              color: isToday ? Colors.white : Colors.black,
                              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Upcoming Events
          Text(
            'Upcoming Events',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildEventItem('Team Standup', 'Tomorrow, 10:00 AM', '🎥'),
          _buildEventItem('Project Deadline', 'Friday, 5:00 PM', '📌'),
          _buildEventItem('1:1 with Manager', 'Next Monday, 2:00 PM', '👔'),
        ],
      ),
    );
  }

  Widget _buildEventItem(String title, String time, String emoji) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(emoji, style: const TextStyle(fontSize: 20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(time),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Editing $title')),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTasksView(BuildContext context) {
    final tasks = [
      {'title': 'Complete Project Proposal', 'description': 'Finish the Q1 proposal', 'priority': 'high', 'status': 'pending'},
      {'title': 'Review Code', 'description': 'Review PR #123', 'priority': 'medium', 'status': 'in_progress'},
      {'title': 'Update Documentation', 'description': 'API docs update', 'priority': 'low', 'status': 'pending'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // View Toggles
          Row(
            children: [
              Expanded(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(label: Text('List'), value: 'list'),
                    ButtonSegment(label: Text('Eisenhower'), value: 'matrix'),
                  ],
                  selected: {'list'},
                  onSelectionChanged: (value) {
                    TobiService.instance.think();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('View changed')));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Filter Chips
          Wrap(
            spacing: 8,
            children: [
                FilterChip(
                label: const Text('All'),
                selected: true,
                onSelected: (value) {
                  TobiService.instance.think();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Filter: All')));
                },
              ),
              FilterChip(
                label: const Text('High Priority'),
                selected: false,
                onSelected: (value) {
                  TobiService.instance.think();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Filter: High Priority')));
                },
              ),
              FilterChip(
                label: const Text('Due Today'),
                selected: false,
                onSelected: (value) {
                  TobiService.instance.think();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Filter: Due Today')));
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Task List
          ...tasks.take(8).map((task) => _buildTaskCard(context, task)),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, dynamic task) {
    Color priorityColor = task.priority == 'high'
        ? Colors.red
        : task.priority == 'medium'
            ? Colors.orange
            : Colors.blue;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: task.status == 'completed',
          onChanged: (value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Task marked as ${value! ? 'done' : 'pending'}')),
            );
          },
        ),
        title: Text(
          task.title ?? 'Untitled Task',
          style: TextStyle(
            decoration: task.status == 'completed' ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(task.description ?? 'No description'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: priorityColor.withAlpha((0.2 * 255).round()),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            task.priority ?? 'medium',
            style: TextStyle(color: priorityColor, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildKanbanView(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildKanbanColumn('To Do', 3, Colors.red),
          const SizedBox(width: 12),
          _buildKanbanColumn('In Progress', 1, Colors.orange),
          const SizedBox(width: 12),
          _buildKanbanColumn('Done', 4, Colors.green),
        ],
      ),
    );
  }

  Widget _buildKanbanColumn(String title, int count, Color color) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$count items',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  for (int i = 0; i < count; i++)
                    Draggable(
                      data: 'task_$i',
                      feedback: Material(
                        child: Container(
                          width: 260,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: color.withAlpha((0.3 * 255).round()),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Task'),
                        ),
                      ),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text('Task ${i + 1}'),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
