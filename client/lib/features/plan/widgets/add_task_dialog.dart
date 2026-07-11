import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tobi_todo/core/theme/spacing.dart';
import 'package:tobi_todo/models/task_model.dart';
import 'package:tobi_todo/providers/auth_provider.dart';
import 'package:tobi_todo/providers/task_provider.dart';

class AddTaskDialog extends ConsumerStatefulWidget {
  const AddTaskDialog({super.key});

  @override
  ConsumerState<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends ConsumerState<AddTaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _dueDate;
  TaskPriority _priority = TaskPriority.medium;
  bool _addToOutlook = false;
  bool _addToGoogleCalendar = false;
  bool _repeatEnabled = false;
  String _repeatOption = 'Daily';
  DateTime? _repeatCustomStart;
  DateTime? _repeatCustomEnd;

  final List<String> _repeatOptions = [
    'Daily',
    'Weekly',
    'Monthly',
    'Fixed range',
    'Custom',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (selected != null) {
      setState(() => _dueDate = selected);
    }
  }

  Future<void> _pickRepeatDate({required bool start}) async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: start ? (_repeatCustomStart ?? now) : (_repeatCustomEnd ?? now),
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (selected != null) {
      setState(() {
        if (start) {
          _repeatCustomStart = selected;
          if (_repeatCustomEnd != null && _repeatCustomEnd!.isBefore(selected)) {
            _repeatCustomEnd = selected.add(const Duration(days: 1));
          }
        } else {
          _repeatCustomEnd = selected;
          if (_repeatCustomStart != null && selected.isBefore(_repeatCustomStart!)) {
            _repeatCustomStart = selected.subtract(const Duration(days: 1));
          }
        }
      });
    }
  }

  void _applySmartSchedule() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    setState(() {
      _dueDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0);
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Smart schedule selected: tomorrow at 9:00 AM')));
  }

  String _repeatSummary() {
    if (!_repeatEnabled) return '';
    switch (_repeatOption) {
      case 'Fixed range':
        if (_repeatCustomStart != null && _repeatCustomEnd != null) {
          return 'Repeats from ${DateFormat('MMM d').format(_repeatCustomStart!)} to ${DateFormat('MMM d').format(_repeatCustomEnd!)}';
        }
        return 'Repeats for a fixed range';
      case 'Custom':
        if (_repeatCustomStart != null && _repeatCustomEnd != null) {
          return 'Custom repeat ${DateFormat('MMM d').format(_repeatCustomStart!)} → ${DateFormat('MMM d').format(_repeatCustomEnd!)}';
        }
        return 'Custom repeat range';
      default:
        return 'Repeats $_repeatOption';
    }
  }

  Future<void> _saveTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task name is required')));
      return;
    }

    final authUser = ref.read(authProvider).maybeWhen(data: (u) => u, orElse: () => null);
    final userId = authUser?.id ?? 'anon';
    final now = DateTime.now();
    final taskDescription = [_descriptionController.text.trim(), _repeatEnabled ? _repeatSummary() : null]
        .where((element) => element != null && element.isNotEmpty)
        .join('\n');

    final task = Task(
      id: 't${now.millisecondsSinceEpoch}',
      userId: userId,
      title: title,
      description: taskDescription.isEmpty ? null : taskDescription,
      dueDate: _dueDate,
      priority: _priority,
      category: 'todo',
      status: TaskStatus.todo,
      completed: false,
      createdAt: now,
      updatedAt: now,
    );

    ref.read(taskBoardProvider.notifier).addTask(task);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      title: const Text('Add task'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Task name', hintText: 'Enter task name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _descriptionController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Description', hintText: 'Optional details', border: OutlineInputBorder()),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickDueDate,
                    child: Text(_dueDate == null ? 'Work date' : 'Due ${DateFormat('MMM d').format(_dueDate!)}'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                ElevatedButton(
                  onPressed: _applySmartSchedule,
                  child: const Text('Smart schedule'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Importance', border: OutlineInputBorder()),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<TaskPriority>(
                        value: _priority,
                        items: TaskPriority.values
                            .map(
                              (priority) => DropdownMenuItem(
                                value: priority,
                                child: Text(priority.name.toUpperCase()),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(() {
                          if (value != null) _priority = value;
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('Add to Outlook'),
                  selected: _addToOutlook,
                  onSelected: (value) => setState(() => _addToOutlook = value),
                ),
                FilterChip(
                  label: const Text('Add to Google Calendar'),
                  selected: _addToGoogleCalendar,
                  onSelected: (value) => setState(() => _addToGoogleCalendar = value),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Repeat task'),
              value: _repeatEnabled,
              onChanged: (value) => setState(() => _repeatEnabled = value ?? false),
            ),
            if (_repeatEnabled) ...[
              DropdownButtonFormField<String>(
                value: _repeatOption,
                decoration: const InputDecoration(labelText: 'Repeat pattern', border: OutlineInputBorder()),
                items: _repeatOptions.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
                onChanged: (value) => setState(() {
                  if (value != null) _repeatOption = value;
                }),
              ),
              if (_repeatOption == 'Fixed range' || _repeatOption == 'Custom')
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _pickRepeatDate(start: true),
                          child: Text(_repeatCustomStart == null
                              ? 'Start date'
                              : DateFormat('MMM d').format(_repeatCustomStart!)),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _pickRepeatDate(start: false),
                          child: Text(_repeatCustomEnd == null
                              ? 'End date'
                              : DateFormat('MMM d').format(_repeatCustomEnd!)),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _saveTask, child: const Text('Save')),
      ],
    );
  }
}
