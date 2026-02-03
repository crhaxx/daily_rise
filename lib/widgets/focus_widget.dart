import 'package:daily_rise/main.dart';
import 'package:daily_rise/models/daily_data.dart';
import 'package:flutter/material.dart';

class FocusCard extends StatefulWidget {
  final String initialFocus;

  const FocusCard({required this.initialFocus});

  @override
  State<FocusCard> createState() => _FocusCardState();
}

class _FocusCardState extends State<FocusCard> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialFocus);
  }

  void _save(String value) {
    storage.saveTodayFocus(value);
    final todayKey = _dayKey(DateTime.now());
    final tasks = storage.loadTodayTasks();
    storage.saveDayArchive(todayKey, DailyData(focus: value, tasks: tasks));
  }

  String _dayKey(DateTime day) {
    return '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt, color: Colors.blue, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Focus',
                border: InputBorder.none,
              ),
              style: theme.textTheme.bodyMedium,
              onChanged: _save,
            ),
          ),
        ],
      ),
    );
  }
}
