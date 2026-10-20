import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/user_settings.dart';
import '../../data/services/export_service.dart';
import '../../providers/activity_provider.dart';
import '../../providers/health_tracking_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/workout_provider.dart';
import '../reminders/reminders_screen.dart';

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
          // ── Profile ────────────────────────────────────────────────────
          _sectionLabel(context, 'Profile'),
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_rounded)),
              title: Text(
                themeProvider.userName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Tap to edit your name'),
              trailing: IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: () => _editUserName(context, themeProvider),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Appearance ─────────────────────────────────────────────────
          _sectionLabel(context, 'Appearance'),
          Card(
            child: Column(
              children: [
                RadioListTile<AppThemeMode>(
                  title: const Text('System Default'),
                  subtitle: const Text('Follow system colour scheme'),
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

          // ── Reminders & Notifications ──────────────────────────────────
          _sectionLabel(context, 'Reminders & Notifications'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.alarm_rounded),
                  title: const Text('Manage Reminders'),
                  subtitle: const Text('Add, edit, and schedule reminders'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RemindersScreen()),
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_rounded),
                  title: const Text('Enable Notifications'),
                  subtitle: const Text('Allow FitTrack to send reminders'),
                  value: themeProvider.notificationsEnabled,
                  onChanged: (val) => themeProvider.setNotificationsEnabled(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Export ─────────────────────────────────────────────────────
          _sectionLabel(context, 'Export Data'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download_rounded),
                  title: const Text('Export Activity Logs'),
                  subtitle: const Text('Save as CSV to Documents folder'),
                  onTap: () => _exportData(context, 'activity'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.fitness_center_rounded),
                  title: const Text('Export Workouts'),
                  subtitle: const Text('Save as CSV to Documents folder'),
                  onTap: () => _exportData(context, 'workout'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.monitor_weight_rounded),
                  title: const Text('Export Weight Log'),
                  subtitle: const Text('Save as CSV to Documents folder'),
                  onTap: () => _exportData(context, 'weight'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Data Management ────────────────────────────────────────────
          _sectionLabel(context, 'Data & Management'),
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
                  title: Text('Apple Health'),
                  subtitle: Text('Integration prepared for a future stage'),
                  trailing: Chip(label: Text('Offline')),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.cloud_sync_rounded),
                  title: Text('Cloud Sync'),
                  subtitle: Text('Local-first (prepared for a future stage)'),
                  trailing: Chip(label: Text('Local')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Version footer ─────────────────────────────────────────────
          Center(
            child: Text(
              'FitTrack v1.5.0 • Stage 5',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ─── helpers ───────────────────────────────────────────────────────────────

  Widget _sectionLabel(BuildContext context, String label) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _editUserName(BuildContext context, ThemeProvider provider) {
    final controller = TextEditingController(text: provider.userName);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Profile Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Your name'),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
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
      ),
    );
  }

  Future<void> _exportData(BuildContext context, String type) async {
    final service = ExportService();
    String? path;

    // Grab the needed provider data.
    // We use context.read since this is in a callback, not a build method.
    try {
      switch (type) {
        case 'activity':
          final logs = context.read<ActivityProvider>().todayLogs;
          path = await service.exportActivityLogs(logs);
          break;
        case 'workout':
          final sessions = context.read<WorkoutProvider>().workoutHistory;
          path = await service.exportWorkouts(sessions);
          break;
        case 'weight':
          final entries = context.read<HealthTrackingProvider>().weightEntries;
          path = await service.exportWeightEntries(entries);
          break;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
      return;
    }

    if (context.mounted) {
      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved to: $path'),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(label: 'OK', onPressed: () {}),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export not supported on this platform.')),
        );
      }
    }
  }
}
