import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tobi_todo/core/theme/app_colors.dart';
import 'package:tobi_todo/shared/services/tobi_service.dart';

enum PlanView { calendar, tasks, projects }

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  PlanView _view = PlanView.calendar;
  bool _tasksPanelExpanded = true;
  final DateTime _selectedDate = DateTime.now();

  final List<Map<String, dynamic>> _sampleTasks = List.generate(
    5,
    (i) => {
      'id': i,
      'title': 'Task ${i + 1}',
      'time': '${9 + i}:00',
      'subtasks': i % 2 == 0 ? 2 : 0,
      'priority': i == 0 ? 'high' : (i == 1 ? 'medium' : 'low'),
    },
  );

  void _openAiScheduler() {
    TobiService.instance.think();
    showDialog(context: context, builder: (_) => AlertDialog(title: const Text('AI Scheduler'), content: const Text('AI suggestions would appear here.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))]));
  }

  void _showAddMenu() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: const Icon(Icons.task), title: const Text('New Task'), onTap: () => Navigator.pop(context)),
          ListTile(leading: const Icon(Icons.event), title: const Text('New Event'), onTap: () => Navigator.pop(context)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFFFAF8FF);
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: const Text('Plan'), backgroundColor: AppColors.plan, elevation: 0),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8)]),
            child: Row(children: [
              _ToggleOption(label: 'Calendar', active: _view == PlanView.calendar, onTap: () => setState(() => _view = PlanView.calendar)),
              _ToggleOption(label: 'Tasks', active: _view == PlanView.tasks, onTap: () => setState(() => _view = PlanView.tasks)),
              _ToggleOption(label: 'Projects', active: _view == PlanView.projects, onTap: () => setState(() => _view = PlanView.projects)),
            ]),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: _view == PlanView.calendar
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(DateFormat('EEEE, MMM d').format(_selectedDate)), const SizedBox(height: 12), ElevatedButton(onPressed: _openAiScheduler, child: const Text('Run AI Scheduler'))]))
                : (_view == PlanView.tasks
                    ? ListView.builder(itemCount: _sampleTasks.length, itemBuilder: (context, idx) => ListTile(title: Text(_sampleTasks[idx]['title']), subtitle: Text(_sampleTasks[idx]['time'])))
                    : GridView.count(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, children: List.generate(4, (i) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.purple.shade50), child: Text('Project ${i + 1}'))))),
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(backgroundColor: AppColors.plan, onPressed: _showAddMenu, child: const Icon(Icons.add)),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ToggleOption({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: active ? AppColors.plan : Colors.transparent, borderRadius: BorderRadius.circular(24)),
          child: Center(child: Text(label, style: TextStyle(color: active ? Colors.white : const Color(0xFF3B4658), fontWeight: FontWeight.w600))),
        ),
      ),
    );
  }
}

class _SmallFilter extends StatelessWidget {
  final String label;
  final bool active;

  const _SmallFilter({required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: active ? AppColors.plan : Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 6)]),
      child: Text(label, style: TextStyle(color: active ? Colors.white : const Color(0xFF556178), fontWeight: FontWeight.w600)),
    );
  }
}


