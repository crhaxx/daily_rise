import 'package:daily_rise/models/daily_data.dart';
import 'package:daily_rise/screens/stats_screen.dart';
import 'package:daily_rise/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controllers/theme_controller.dart';
import 'screens/today_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/settings_screen.dart';

class DailyRiseApp extends StatefulWidget {
  const DailyRiseApp({super.key});

  @override
  State<DailyRiseApp> createState() => _DailyRiseAppState();
}

class _DailyRiseAppState extends State<DailyRiseApp> {
  final ThemeController themeController = ThemeController();

  StorageService? storage;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    themeController.load();
    _initStorage();
    _checkForNewDay();
  }

  Future<void> _initStorage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      storage = StorageService(prefs);
    });
  }

  Future<void> _checkForNewDay() async {
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(prefs);

    final lastDate = prefs.getString('last_open_date');
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';

    if (lastDate == null) {
      prefs.setString('last_open_date', todayKey);
      return;
    }

    if (lastDate != todayKey) {
      final focus = storage.loadTodayFocus();
      final tasks = storage.loadTodayTasks();

      storage.saveDayArchive(lastDate, DailyData(focus: focus, tasks: tasks));

      storage.saveTodayFocus('');
      storage.saveTodayTasks([]);

      prefs.setString('last_open_date', todayKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: themeController,
      child: Consumer<ThemeController>(
        builder: (context, theme, _) {
          final highContrast = theme.highContrast;

          return MaterialApp(
            title: 'DailyRise',
            debugShowCheckedModeBanner: false,

            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: theme.seedColor,
              brightness: Brightness.light,
            ),

            darkTheme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: theme.seedColor,
              brightness: Brightness.dark,
            ),

            highContrastTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              colorScheme: const ColorScheme.highContrastLight(),
            ),

            themeMode: highContrast ? ThemeMode.light : theme.mode,

            home: storage == null
                ? const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  )
                : Scaffold(
                    body: _buildScreen(),
                    bottomNavigationBar: NavigationBar(
                      selectedIndex: _currentIndex,
                      onDestinationSelected: (index) {
                        setState(() => _currentIndex = index);
                      },
                      destinations: const [
                        NavigationDestination(
                          icon: Icon(Icons.today_outlined),
                          selectedIcon: Icon(Icons.today),
                          label: 'Today',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.calendar_month_outlined),
                          selectedIcon: Icon(Icons.calendar_month),
                          label: 'Calendar',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.bar_chart_rounded),
                          label: "Stats",
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.settings_outlined),
                          selectedIcon: Icon(Icons.settings),
                          label: 'Settings',
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildScreen() {
    switch (_currentIndex) {
      case 0:
        return const TodayScreen();
      case 1:
        return CalendarScreen();
      case 2:
        return StatsScreen();
      case 3:
        return const SettingsScreen();
      default:
        return const TodayScreen();
    }
  }
}
