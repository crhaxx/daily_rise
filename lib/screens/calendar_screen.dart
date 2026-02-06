import 'package:flutter/material.dart';
import '../main.dart';
import '../models/daily_data.dart';
import '../models/task_item.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDay = DateTime.now();
  bool showDay = false;

  late DateTime currentMonth;

  // uložené úkoly pro každý den
  final Map<String, List<TaskItem>> tasks = {};

  @override
  void initState() {
    super.initState();
    currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    _loadMonth(currentMonth);
  }

  // ------------------------------------------------------------
  // LOAD DATA (sync)
  // ------------------------------------------------------------

  void _loadMonth(DateTime month) {
    tasks.clear();

    final year = month.year;
    final m = month.month;
    final daysInMonth = DateTime(year, m + 1, 0).day;

    for (int d = 1; d <= daysInMonth; d++) {
      final day = DateTime(year, m, d);
      final key = _dayKey(day);
      _loadDay(key);
    }
  }

  void _loadDay(String key) {
    final data = storage.loadDayArchive(key);

    print("LOAD DAY: $key → ${data != null ? 'FOUND' : 'NULL'}");

    if (data == null) return;

    print("TASKS: ${data.tasks.length}, FOCUS: '${data.focus}'");

    tasks[key] = data.tasks;
  }

  String _dayKey(DateTime day) {
    return '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar'), centerTitle: true),
      body: Column(
        children: [
          const SizedBox(height: 12),

          // MONTH HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    currentMonth = DateTime(
                      currentMonth.year,
                      currentMonth.month - 1,
                      1,
                    );
                    _loadMonth(currentMonth);
                  });
                },
              ),
              Text(
                '${_monthName(currentMonth.month)} ${currentMonth.year}',
                style: textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    currentMonth = DateTime(
                      currentMonth.year,
                      currentMonth.month + 1,
                      1,
                    );
                    _loadMonth(currentMonth);
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 8),

          // WEEKDAY LABELS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Text("Mo"),
              Text("Tu"),
              Text("We"),
              Text("Th"),
              Text("Fr"),
              Text("Sa"),
              Text("Su"),
            ],
          ),

          const SizedBox(height: 8),

          // MONTH GRID
          Expanded(child: _buildMonthGrid(currentMonth, textTheme)),

          // DAY VIEW
          if (showDay)
            Container(
              padding: const EdgeInsets.all(16),
              height: 260,
              child: _buildDayView(selectedDay, textTheme),
            ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // MONTH GRID
  // ------------------------------------------------------------

  Widget _buildMonthGrid(DateTime month, TextTheme textTheme) {
    final year = month.year;
    final m = month.month;

    final firstDay = DateTime(year, m, 1);
    final firstWeekday = firstDay.weekday;
    final offset = firstWeekday - 1;
    final daysInMonth = DateTime(year, m + 1, 0).day;

    final List<Widget> cells = [];

    // previous month padding
    for (int i = offset; i > 0; i--) {
      final prevDate = firstDay.subtract(Duration(days: i));
      cells.add(_buildDayCell(prevDate, textTheme, faded: true));
    }

    // current month
    for (int d = 1; d <= daysInMonth; d++) {
      final day = DateTime(year, m, d);
      cells.add(_buildDayCell(day, textTheme));
    }

    // next month padding
    while (cells.length < 42) {
      final nextDate = DateTime(
        year,
        m,
        daysInMonth + (cells.length - offset) + 1,
      );
      cells.add(_buildDayCell(nextDate, textTheme, faded: true));
    }

    return GridView.count(
      crossAxisCount: 7,
      childAspectRatio: 1,
      physics: const NeverScrollableScrollPhysics(),
      children: cells,
    );
  }

  // ------------------------------------------------------------
  // DAY CELL
  // ------------------------------------------------------------

  Widget _buildDayCell(
    DateTime day,
    TextTheme textTheme, {
    bool faded = false,
  }) {
    final key = _dayKey(day);

    final hasTasks = tasks[key]?.isNotEmpty ?? false;
    final dotColor = hasTasks ? Colors.green : Colors.transparent;

    final isToday = _isSameDay(day, DateTime.now());
    final isSelected = _isSameDay(day, selectedDay);

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDay = day;
          showDay = true;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                color: faded
                    ? Colors.grey
                    : (isToday ? Colors.blue : Colors.black),
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // DAY VIEW
  // ------------------------------------------------------------

  Widget _buildDayView(DateTime day, TextTheme textTheme) {
    final key = _dayKey(day);
    final data = storage.loadDayArchive(key);

    final focus = data?.focus ?? '';
    final dayTasks = data?.tasks ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${_weekdayName(day.weekday)}, ${day.day}. ${day.month}. ${day.year}",
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),

        if (focus.isNotEmpty) Text("Focus: $focus", style: textTheme.bodyLarge),

        const SizedBox(height: 12),

        if (dayTasks.isEmpty) const Text("No tasks"),

        ...dayTasks.map(
          (t) => Row(
            children: [
              Icon(
                t.done ? Icons.check_box : Icons.check_box_outline_blank,
                size: 20,
                color: t.done ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(t.text),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // HELPERS
  // ------------------------------------------------------------

  String _weekdayName(int weekday) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[weekday - 1];
  }

  String _monthName(int m) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[m - 1];
  }
}
