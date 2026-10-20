import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/reminder.dart';
import '../../../providers/reminder_provider.dart';

/// Dialog for adding or editing a reminder.
class AddEditReminderDialog extends StatefulWidget {
  final Reminder? initialReminder;
  const AddEditReminderDialog({super.key, this.initialReminder});

  @override
  State<AddEditReminderDialog> createState() => _AddEditReminderDialogState();
}

class _AddEditReminderDialogState extends State<AddEditReminderDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _bodyCtrl;
  late int _hour;
  late int _minute;
  late ReminderFrequency _frequency;
  late Set<Weekday> _weekdays;

  bool get _isEditing => widget.initialReminder != null;

  @override
  void initState() {
    super.initState();
    final r = widget.initialReminder;
    _titleCtrl = TextEditingController(text: r?.title ?? '');
    _bodyCtrl = TextEditingController(text: r?.body ?? '');
    _hour = r?.hour ?? 8;
    _minute = r?.minute ?? 0;
    _frequency = r?.frequency ?? ReminderFrequency.daily;
    _weekdays = Set.from(r?.weekdays ?? []);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _hour, minute: _minute),
    );
    if (picked != null) {
      setState(() {
        _hour = picked.hour;
        _minute = picked.minute;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ReminderProvider>();

    if (_isEditing) {
      final updated = widget.initialReminder!.copyWith(
        title: _titleCtrl.text.trim(),
        body: _bodyCtrl.text.trim().isEmpty ? null : _bodyCtrl.text.trim(),
        hour: _hour,
        minute: _minute,
        frequency: _frequency,
        weekdays: _weekdays.toList(),
      );
      await provider.updateReminder(updated);
    } else {
      final reminder = Reminder.create(
        title: _titleCtrl.text.trim(),
        body: _bodyCtrl.text.trim().isEmpty ? null : _bodyCtrl.text.trim(),
        hour: _hour,
        minute: _minute,
        frequency: _frequency,
        weekdays: _weekdays.toList(),
      );
      await provider.addReminder(reminder);
    }

    if (mounted) Navigator.pop(context);
  }

  String get _timeLabel {
    final h = _hour.toString().padLeft(2, '0');
    final m = _minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(_isEditing ? 'Edit Reminder' : 'New Reminder'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 420,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Reminder title *',
                    prefixIcon: Icon(Icons.alarm_rounded),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 12),

                // Optional body / note
                TextFormField(
                  controller: _bodyCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),

                // Time picker row
                Text('Time', style: theme.textTheme.labelLarge),
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  onPressed: _pickTime,
                  icon: const Icon(Icons.schedule_rounded),
                  label: Text(_timeLabel, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 16),

                // Frequency
                Text('Frequency', style: theme.textTheme.labelLarge),
                const SizedBox(height: 6),
                SegmentedButton<ReminderFrequency>(
                  segments: ReminderFrequency.values
                      .map((f) => ButtonSegment(value: f, label: Text(f.label)))
                      .toList(),
                  selected: {_frequency},
                  onSelectionChanged: (val) => setState(() => _frequency = val.first),
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                ),

                // Weekday selector (only when weekly is selected)
                if (_frequency == ReminderFrequency.weekly) ...[
                  const SizedBox(height: 16),
                  Text('Days of week', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: Weekday.values.map((day) {
                      final selected = _weekdays.contains(day);
                      return FilterChip(
                        label: Text(day.label),
                        selected: selected,
                        onSelected: (val) => setState(() {
                          if (val) {
                            _weekdays.add(day);
                          } else {
                            _weekdays.remove(day);
                          }
                        }),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: Text(_isEditing ? 'Save' : 'Add')),
      ],
    );
  }
}
