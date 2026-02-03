import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final textTheme = Theme.of(context).textTheme;

    final colors = [
      Colors.deepPurple,
      Colors.blue,
      Colors.teal,
      Colors.green,
      Colors.amber,
      Colors.orange,
      Colors.pink,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card.outlined(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DailyRise',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version 1.0.0',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Appearance',
            style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          Card.outlined(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('High‑contrast mode'),
                  subtitle: const Text('Improves readability with bold colors'),
                  value: theme.highContrast,
                  onChanged: (value) => theme.setHighContrast(value),
                ),

                const Divider(height: 1),

                RadioListTile<ThemeMode>(
                  title: const Text('System default'),
                  value: ThemeMode.system,
                  groupValue: theme.mode,
                  onChanged: theme.highContrast
                      ? null
                      : (value) => theme.setMode(value!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Light'),
                  value: ThemeMode.light,
                  groupValue: theme.mode,
                  onChanged: theme.highContrast
                      ? null
                      : (value) => theme.setMode(value!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Dark'),
                  value: ThemeMode.dark,
                  groupValue: theme.mode,
                  onChanged: theme.highContrast
                      ? null
                      : (value) => theme.setMode(value!),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Accent Color',
            style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: colors.map((c) {
                final selected = theme.seedColor.value == c.value;

                return GestureDetector(
                  onTap: () => theme.setSeedColor(c),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? Colors.black : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'About',
            style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          Card.outlined(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('What is DailyRise?'),
              subtitle: const Text(
                'A minimal daily focus and task system designed to help you stay aligned with what matters.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
