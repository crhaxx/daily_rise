import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DailyResetService {
  final SharedPreferences prefs;

  DailyResetService(this.prefs);

  static const String keyLastOpenDate = 'last_open_date';
  static const String keyTodayTasks = 'today_tasks';
  static const String keyTodayFocus = 'today_focus';

  Future<void> handleDailyReset() async {
    final now = DateTime.now();
    final todayString = _formatDate(now);

    final lastOpen = prefs.getString(keyLastOpenDate);

    // First launch or same day → nothing to reset
    if (lastOpen == todayString) {
      return;
    }

    // If lastOpen exists, archive yesterday's data
    if (lastOpen != null) {
      await _archiveDay(lastOpen);
    }

    // Reset today's data
    await prefs.setString(keyTodayTasks, jsonEncode([]));
    await prefs.setString(keyTodayFocus, '');
    await prefs.setString(keyLastOpenDate, todayString);
  }

  Future<void> _archiveDay(String dateKey) async {
    final tasksJson = prefs.getString(keyTodayTasks);
    final focus = prefs.getString(keyTodayFocus) ?? '';

    final archiveData = {
      'tasks': tasksJson != null ? jsonDecode(tasksJson) : [],
      'focus': focus,
    };

    await prefs.setString(dateKey, jsonEncode(archiveData));
  }

  String _formatDate(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')}';
  }
}
