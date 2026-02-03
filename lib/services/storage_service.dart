import 'dart:convert';

import 'package:daily_rise/models/daily_data.dart';
import 'package:daily_rise/models/task_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final SharedPreferences prefs;

  StorageService(this.prefs);

  static const _todayFocusKey = 'today_focus';
  static const _todayTasksKey = 'today_tasks';
  static const _archivePrefix = 'archive_';
  static const _streakDataKey = 'streak_data';

  // ---------------------------
  // ARCHIVE (synchronní load)
  // ---------------------------

  Future<void> saveDayArchive(String dateKey, DailyData data) async {
    print("SAVING ARCHIVE: $_archivePrefix$dateKey");
    print("DATA: tasks=${data.tasks.length}, focus='${data.focus}'");

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_archivePrefix$dateKey', jsonEncode(data.toJson()));
  }

  DailyData? loadDayArchive(String dateKey) {
    final raw = prefs.getString('$_archivePrefix$dateKey');
    if (raw == null) return null;

    final map = jsonDecode(raw) as Map<String, dynamic>;
    return DailyData.fromJson(map);
  }

  List<String> loadAllArchiveKeys() {
    return prefs
        .getKeys()
        .where((k) => k.startsWith(_archivePrefix))
        .map((k) => k.substring(_archivePrefix.length))
        .toList();
  }

  // ---------------------------
  // TODAY
  // ---------------------------

  Future<void> saveTodayFocus(String focus) async {
    await prefs.setString(_todayFocusKey, focus);
  }

  String loadTodayFocus() {
    return prefs.getString(_todayFocusKey) ?? '';
  }

  Future<void> saveTodayTasks(List<TaskItem> tasks) async {
    final jsonList = tasks.map((t) => t.toJson()).toList();
    await prefs.setString(_todayTasksKey, jsonEncode(jsonList));
  }

  List<TaskItem> loadTodayTasks() {
    final raw = prefs.getString(_todayTasksKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => TaskItem.fromJson(e)).toList();
  }

  // ---------------------------
  // STREAK + BADGES (async)
  // ---------------------------

  Future<void> _saveStreakData(Map<String, dynamic> data) async {
    await prefs.setString(_streakDataKey, jsonEncode(data));
  }

  Map<String, dynamic> _loadStreakDataRaw() {
    final raw = prefs.getString(_streakDataKey);
    if (raw == null) {
      return {
        'currentStreak': 0,
        'bestStreak': 0,
        'lastCompletedDay': null,
        'unlockedBadges': <String>[],
      };
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return {
        'currentStreak': decoded['currentStreak'] ?? 0,
        'bestStreak': decoded['bestStreak'] ?? 0,
        'lastCompletedDay': decoded['lastCompletedDay'],
        'unlockedBadges': (decoded['unlockedBadges'] as List<dynamic>? ?? [])
            .cast<String>(),
      };
    } catch (_) {
      return {
        'currentStreak': 0,
        'bestStreak': 0,
        'lastCompletedDay': null,
        'unlockedBadges': <String>[],
      };
    }
  }

  int loadCurrentStreak() {
    return _loadStreakDataRaw()['currentStreak'];
  }

  int loadBestStreak() {
    return _loadStreakDataRaw()['bestStreak'];
  }

  String? loadLastCompletedDay() {
    return _loadStreakDataRaw()['lastCompletedDay'];
  }

  List<String> loadUnlockedBadges() {
    return _loadStreakDataRaw()['unlockedBadges'];
  }

  Future<void> saveStreakState({
    required int currentStreak,
    required int bestStreak,
    required String? lastCompletedDay,
    required List<String> unlockedBadges,
  }) async {
    await _saveStreakData({
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'lastCompletedDay': lastCompletedDay,
      'unlockedBadges': unlockedBadges,
    });
  }
}
