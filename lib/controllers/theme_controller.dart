import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const String modeKey = 'theme_mode';
  static const String colorKey = 'theme_color';

  ThemeMode _mode = ThemeMode.system;
  bool _highContrast = false;
  Color _seedColor = Colors.deepPurple;

  ThemeMode get mode => _mode;
  bool get highContrast => _highContrast;
  Color get seedColor => _seedColor;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    // Load theme mode
    final modeValue = prefs.getString(modeKey);
    if (modeValue == 'high_contrast') {
      _highContrast = true;
      _mode = ThemeMode.light;
    } else {
      switch (modeValue) {
        case 'light':
          _mode = ThemeMode.light;
          break;
        case 'dark':
          _mode = ThemeMode.dark;
          break;
        default:
          _mode = ThemeMode.system;
      }
    }

    // Load color
    final colorValue = prefs.getInt(colorKey);
    if (colorValue != null) {
      _seedColor = Color(colorValue);
    }

    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    _highContrast = false;
    _mode = mode;

    final prefs = await SharedPreferences.getInstance();
    switch (mode) {
      case ThemeMode.light:
        await prefs.setString(modeKey, 'light');
        break;
      case ThemeMode.dark:
        await prefs.setString(modeKey, 'dark');
        break;
      default:
        await prefs.setString(modeKey, 'system');
    }

    notifyListeners();
  }

  Future<void> setHighContrast(bool enabled) async {
    _highContrast = enabled;

    final prefs = await SharedPreferences.getInstance();
    if (enabled) {
      await prefs.setString(modeKey, 'high_contrast');
      _mode = ThemeMode.light;
    } else {
      await prefs.setString(modeKey, 'system');
      _mode = ThemeMode.system;
    }

    notifyListeners();
  }

  Future<void> setSeedColor(Color color) async {
    _seedColor = color;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(colorKey, color.value);

    notifyListeners();
  }
}
