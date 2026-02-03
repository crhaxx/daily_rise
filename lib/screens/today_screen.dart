import 'package:daily_rise/widgets/focus_widget.dart';
import 'package:daily_rise/widgets/today_tasks.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/task_item.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final focus = storage.loadTodayFocus();
    final tasks = storage.loadTodayTasks();
    final completed = tasks.where((t) => t.done).length;

    final currentStreak = storage.loadCurrentStreak();
    final bestStreak = storage.loadBestStreak();

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Rise'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // STREAK
            _InfoCard(
              icon: Icons.local_fire_department,
              title: '$currentStreak day streak',
              subtitle: currentStreak == 0
                  ? 'Let’s get started!'
                  : currentStreak == 1
                  ? 'Nice start, keep going'
                  : '🔥 Keep it up!',
              color: Colors.orange,
            ),

            const SizedBox(height: 16),

            // FOCUS
            FocusCard(initialFocus: focus),

            const SizedBox(height: 16),

            TodayTasksCard(),

            const SizedBox(height: 16),

            // TASKS
            _InfoCard(
              icon: Icons.check_circle,
              title: '$completed of ${tasks.length} completed',
              subtitle: tasks.isEmpty
                  ? 'No tasks today'
                  : '$completed/${tasks.length} completed',
              color: Colors.green,
            ),

            const SizedBox(height: 16),

            // STATS
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Best streak',
                    value: '$bestStreak',
                    icon: Icons.emoji_events,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Tasks this week',
                    value: '-', // zatím placeholder
                    icon: Icons.calendar_today,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // QUOTE
            Text(
              'You showed up. That’s what matters.',
              style: textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// WIDGETS
// ------------------------------------------------------------

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: cs.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodyMedium),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
