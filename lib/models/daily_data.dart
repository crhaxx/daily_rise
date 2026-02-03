import 'dart:convert';
import 'task_item.dart';

class DailyData {
  final String focus;
  final List<TaskItem> tasks;

  DailyData({required this.focus, required this.tasks});

  factory DailyData.fromJson(Map<String, dynamic> json) {
    final tasksJson = json['tasks'] as List<dynamic>? ?? [];
    return DailyData(
      focus: json['focus'] as String? ?? '',
      tasks: tasksJson
          .map((item) => TaskItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'focus': focus, 'tasks': tasks.map((t) => t.toJson()).toList()};
  }

  static DailyData fromJsonString(String jsonString) {
    return DailyData.fromJson(jsonDecode(jsonString));
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
