import 'package:flutter/material.dart';
import '../main.dart';
import '../models/daily_data.dart';
import '../models/task_item.dart';

class TodayTasksCard extends StatefulWidget {
  const TodayTasksCard({super.key});

  @override
  State<TodayTasksCard> createState() => _TodayTasksCardState();
}

class _TodayTasksCardState extends State<TodayTasksCard> {
  late List<TaskItem> tasks;

  @override
  void initState() {
    super.initState();
    tasks = storage.loadTodayTasks();
  }

  void _save() {
    storage.saveTodayTasks(tasks);

    final todayKey = _dayKey(DateTime.now());
    final focus = storage.loadTodayFocus();
    storage.saveDayArchive(todayKey, DailyData(focus: focus, tasks: tasks));
  }

  String _dayKey(DateTime day) {
    return '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
  }

  void _addTask() {
    setState(() {
      tasks.add(TaskItem(text: '', done: false, color: Colors.black));
    });
    _save();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(width: 12),
              Text(
                "Tasks",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // TASK LIST
          ...tasks.asMap().entries.map((entry) {
            final index = entry.key;
            final task = entry.value;

            final controller = TextEditingController(text: task.text);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  // DONE CHECKBOX
                  GestureDetector(
                    onTap: () {
                      setState(() => task.done = !task.done);
                      _save();
                    },
                    child: Icon(
                      task.done ? Icons.check_circle : Icons.circle_outlined,
                      color: task.done ? Colors.green : Colors.grey,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // EDITABLE TEXT
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Task...",
                      ),
                      onChanged: (value) {
                        task.text = value;
                        _save();
                      },
                    ),
                  ),

                  // DELETE
                  GestureDetector(
                    onTap: () {
                      setState(() => tasks.removeAt(index));
                      _save();
                    },
                    child: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 12),

          // ADD TASK BUTTON
          GestureDetector(
            onTap: _addTask,
            child: Row(
              children: [
                const Icon(Icons.add, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  "Add task",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
