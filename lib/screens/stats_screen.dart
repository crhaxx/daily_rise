import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../main.dart';
import '../models/daily_data.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool showWeek = true;

  late DateTime currentWeekStart;
  late DateTime currentMonth;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    currentMonth = DateTime(now.year, now.month, 1);
    currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
  }

  // ------------------------------------------------------------
  // LOAD DAILY DATA (sync)
  // ------------------------------------------------------------

  DailyData? _loadDailyData(DateTime day) {
    final key = _dayKey(day);

    // archiv
    final archived = storage.loadDayArchive(key);
    if (archived != null) return archived;

    // dnešek
    final now = DateTime.now();
    final isToday =
        day.year == now.year && day.month == now.month && day.day == now.day;

    if (isToday) {
      final tasks = storage.loadTodayTasks();
      final focus = storage.loadTodayFocus();
      return DailyData(focus: focus, tasks: tasks);
    }

    return null;
  }

  String _dayKey(DateTime day) {
    return '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
  }

  // ------------------------------------------------------------
  // WEEK STATS
  // ------------------------------------------------------------

  _PeriodStats _computeWeekStats(DateTime weekStart) {
    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    int totalTasks = 0;
    int totalCompleted = 0;
    int focusDays = 0;

    DateTime? bestDay;
    int bestCompleted = 0;

    final dailyCompleted = <int>[];

    for (final day in days) {
      final data = _loadDailyData(day);

      final total = data?.tasks.length ?? 0;
      final completed = data?.tasks.where((t) => t.done).length ?? 0;
      final focusFilled = (data?.focus ?? '').trim().isNotEmpty;

      totalTasks += total;
      totalCompleted += completed;
      if (focusFilled) focusDays++;

      dailyCompleted.add(completed);

      if (completed > bestCompleted) {
        bestCompleted = completed;
        bestDay = day;
      }
    }

    return _PeriodStats(
      totalTasks: totalTasks,
      totalCompleted: totalCompleted,
      focusDays: focusDays,
      bestDay: bestDay,
      bestCompleted: bestCompleted,
      dailyCompleted: dailyCompleted,
    );
  }

  // ------------------------------------------------------------
  // MONTH STATS
  // ------------------------------------------------------------

  _PeriodStats _computeMonthStats(DateTime month) {
    final year = month.year;
    final m = month.month;
    final daysInMonth = DateTime(year, m + 1, 0).day;

    final days = List.generate(daysInMonth, (i) => DateTime(year, m, i + 1));

    int totalTasks = 0;
    int totalCompleted = 0;
    int focusDays = 0;

    DateTime? bestDay;
    int bestCompleted = 0;

    final weeklyBuckets = <int, int>{};

    for (final day in days) {
      final data = _loadDailyData(day);

      final total = data?.tasks.length ?? 0;
      final completed = data?.tasks.where((t) => t.done).length ?? 0;
      final focusFilled = (data?.focus ?? '').trim().isNotEmpty;

      totalTasks += total;
      totalCompleted += completed;
      if (focusFilled) focusDays++;

      if (completed > bestCompleted) {
        bestCompleted = completed;
        bestDay = day;
      }

      final weekOfMonth = ((day.day - 1) ~/ 7);
      weeklyBuckets[weekOfMonth] =
          (weeklyBuckets[weekOfMonth] ?? 0) + completed;
    }

    return _PeriodStats(
      totalTasks: totalTasks,
      totalCompleted: totalCompleted,
      focusDays: focusDays,
      bestDay: bestDay,
      bestCompleted: bestCompleted,
      dailyCompleted: weeklyBuckets.values.toList(),
    );
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final weekStats = _computeWeekStats(currentWeekStart);
    final monthStats = _computeMonthStats(currentMonth);

    final currentStreak = storage.loadCurrentStreak();
    final bestStreak = storage.loadBestStreak();

    return Scaffold(
      appBar: AppBar(title: const Text('Stats'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // TOP CARDS
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Weekly',
                    value: weekStats.totalTasks == 0
                        ? '0%'
                        : '${((weekStats.totalCompleted / weekStats.totalTasks) * 100).round()}%',
                    subtitle: '',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Focus',
                    value: '${weekStats.focusDays} days',
                    subtitle: '',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Best day',
                    value: weekStats.bestDay == null
                        ? '-'
                        : _weekdayName(weekStats.bestDay!.weekday),
                    subtitle: '${weekStats.bestCompleted} tasks',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Streak',
                    value: '$currentStreak days',
                    subtitle: '🔥',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Best streak',
                    value: '$bestStreak days',
                    subtitle: '',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // SWITCHER
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('Week'),
                  selected: showWeek,
                  onSelected: (_) => setState(() => showWeek = true),
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('Month'),
                  selected: !showWeek,
                  onSelected: (_) => setState(() => showWeek = false),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // PERIOD TITLE
            Text(
              showWeek
                  ? 'Week of ${currentWeekStart.day}.${currentWeekStart.month}.'
                  : '${currentMonth.month}.${currentMonth.year}',
              style: textTheme.titleMedium,
            ),

            const SizedBox(height: 16),

            // BAR CHART
            _buildBarChart(
              showWeek ? weekStats.dailyCompleted : monthStats.dailyCompleted,
            ),

            const SizedBox(height: 32),

            // COMPLETION PIE
            _buildCompletionPie(
              showWeek ? weekStats.totalCompleted : monthStats.totalCompleted,
              showWeek ? weekStats.totalTasks : monthStats.totalTasks,
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // WIDGETS
  // ------------------------------------------------------------

  Widget _buildBarChart(List<int> values) {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barGroups: values
              .asMap()
              .entries
              .map(
                (e) => BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: e.value.toDouble(),
                      color: Colors.blue,
                      width: 14,
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildCompletionPie(int completed, int total) {
    final remaining = total - completed;
    final percent = total == 0 ? 0 : (completed / total * 100).round();

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: completed.toDouble(),
                  color: Colors.green,
                  title: '',
                ),
                PieChartSectionData(
                  value: remaining.toDouble(),
                  color: Colors.grey.shade300,
                  title: '',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '$percent%',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text('Completed ($completed) • Remaining ($remaining)'),
      ],
    );
  }

  String _weekdayName(int weekday) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[weekday - 1];
  }
}

// ------------------------------------------------------------
// Helper classes
// ------------------------------------------------------------

class _PeriodStats {
  final int totalTasks;
  final int totalCompleted;
  final int focusDays;
  final DateTime? bestDay;
  final int bestCompleted;
  final List<int> dailyCompleted;

  _PeriodStats({
    required this.totalTasks,
    required this.totalCompleted,
    required this.focusDays,
    required this.bestDay,
    required this.bestCompleted,
    required this.dailyCompleted,
  });
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(color: cs.primary),
            ),
        ],
      ),
    );
  }
}
