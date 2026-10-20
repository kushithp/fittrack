import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/reminder.dart';
import '../../../providers/reminder_provider.dart';
import 'add_edit_reminder_dialog.dart';

/// Full-screen list of all reminders with add / edit / delete / toggle.
class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  @override
  void initState() {
    super.initState();
    // Load reminders when the screen first opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReminderProvider>().loadReminders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alarm_rounded),
            tooltip: 'Add Reminder',
            onPressed: () => _openAddDialog(context),
          ),
        ],
      ),
      body: Consumer<ReminderProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.reminders.isEmpty) {
            return _EmptyState(onAdd: () => _openAddDialog(context));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.reminders.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final reminder = provider.reminders[index];
              return _ReminderCard(
                reminder: reminder,
                onToggle: () => provider.toggleReminder(reminder.id),
                onEdit: () => _openEditDialog(context, reminder),
                onDelete: () => _confirmDelete(context, provider, reminder),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddDialog(context),
        icon: const Icon(Icons.add_alarm_rounded),
        label: const Text('Add Reminder'),
      ),
    );
  }

  void _openAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AddEditReminderDialog(),
    );
  }

  void _openEditDialog(BuildContext context, Reminder reminder) {
    showDialog(
      context: context,
      builder: (_) => AddEditReminderDialog(initialReminder: reminder),
    );
  }

  Future<void> _confirmDelete(BuildContext context, ReminderProvider provider, Reminder reminder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text('Delete "${reminder.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await provider.deleteReminder(reminder.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${reminder.title}" deleted')),
        );
      }
    }
  }
}

// ─── Reminder card widget ─────────────────────────────────────────────────────

class _ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ReminderCard({
    required this.reminder,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = reminder.isEnabled;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: isEnabled
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.alarm_rounded,
            color: isEnabled ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(
          reminder.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isEnabled
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reminder.scheduleLabel),
            if (reminder.body != null && reminder.body!.isNotEmpty)
              Text(
                reminder.body!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(value: isEnabled, onChanged: (_) => onToggle()),
            PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'edit') onEdit();
                if (val == 'delete') onDelete();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit_rounded), title: Text('Edit'))),
                PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_rounded), title: Text('Delete'))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.alarm_off_rounded, size: 72, color: theme.colorScheme.surfaceContainerHighest),
          const SizedBox(height: 16),
          Text('No reminders yet', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text('Tap the button below to add your first reminder.'),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_alarm_rounded),
            label: const Text('Add Reminder'),
          ),
        ],
      ),
    );
  }
}
