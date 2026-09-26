import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/user_settings.dart';
import '../../providers/activity_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final activityProvider = Provider.of<ActivityProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person_rounded),
              ),
              title: Text(themeProvider.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Personalized Profile'),
              trailing: IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: () => _editUserName(context, themeProvider),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Appearance',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                RadioListTile<AppThemeMode>(
                  title: const Text('System Default'),
                  subtitle: const Text('Follow system color scheme'),
                  value: AppThemeMode.system,
                  groupValue: themeProvider.themeMode,
                  onChanged: (val) => themeProvider.setThemeMode(val!),
                ),
                RadioListTile<AppThemeMode>(
                  title: const Text('Light Mode'),
                  value: AppThemeMode.light,
                  groupValue: themeProvider.themeMode,
                  onChanged: (val) => themeProvider.setThemeMode(val!),
                ),
                RadioListTile<AppThemeMode>(
                  title: const Text('Dark Mode (Obsidian)'),
                  value: AppThemeMode.dark,
                  groupValue: themeProvider.themeMode,
                  onChanged: (val) => themeProvider.setThemeMode(val!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Data & Management',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.restart_alt_rounded),
                  title: const Text('Reset Demo Data'),
                  subtitle: const Text('Re-populate sample activities and history'),
                  onTap: () => activityProvider.resetDemoData(),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.health_and_safety_rounded),
                  title: Text('Apple Health Status'),
                  subtitle: Text('Manual Mode (Prepared for Stage 7)'),
                  trailing: Chip(label: Text('Offline')),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.cloud_sync_rounded),
                  title: Text('Cloud Sync Status'),
                  subtitle: Text('Local-first (Prepared for Stage 8)'),
                  trailing: Chip(label: Text('Local')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'FitTrack v1.0.0 (Stage 1)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editUserName(BuildContext context, ThemeProvider provider) {
    final controller = TextEditingController(text: provider.userName);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Profile Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Name'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  provider.setUserName(controller.text.trim());
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
