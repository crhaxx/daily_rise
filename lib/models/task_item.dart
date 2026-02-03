import 'package:flutter/material.dart';

class TaskItem {
  String text;
  bool done;
  Color color;

  TaskItem({required this.text, required this.done, required this.color});

  Map<String, dynamic> toJson() {
    return {'text': text, 'done': done, 'color': color.value};
  }

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      text: json['text'] ?? '',
      done: json['done'] ?? false,
      color: Color(json['color'] ?? Colors.blue.value),
    );
  }
}
