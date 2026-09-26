import 'package:flutter/material.dart';
import '../../../data/models/activity_log.dart';
import '../../../data/models/daily_note.dart';

class AddEditNoteDialog extends StatefulWidget {
  final DailyNote? initialNote;
  final DateTime defaultDate;
  final ValueChanged<DailyNote> onSave;

  const AddEditNoteDialog({
    super.key,
    this.initialNote,
    required this.defaultDate,
    required this.onSave,
  });

  @override
  State<AddEditNoteDialog> createState() => _AddEditNoteDialogState();
}

class _AddEditNoteDialogState extends State<AddEditNoteDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _textNotes;
  late double _energyRating;
  late double _moodRating;
  late double _recoveryRating;
  late String _tagsInput;

  @override
  void initState() {
    super.initState();
    final note = widget.initialNote;
    _textNotes = note?.textNotes ?? '';
    _energyRating = (note?.energyRating ?? 8).toDouble();
    _moodRating = (note?.moodRating ?? 8).toDouble();
    _recoveryRating = (note?.recoveryRating ?? 8).toDouble();
    _tagsInput = note?.tags.join(', ') ?? 'workout, gym, strong';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialNote != null;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(isEditing ? 'Edit Daily Note' : 'New Journal Note'),
      content: SingleChildScrollView(
        child: Container(
          width: 480,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: _textNotes,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Notes / Thoughts *',
                    hintText: 'e.g. Felt strong today. Increased bench press by 5kg.',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter notes' : null,
                  onSaved: (val) => _textNotes = val!.trim(),
                ),
                const SizedBox(height: 16),
                Text('Energy Level: ${_energyRating.toInt()}/10', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                Slider(
                  value: _energyRating,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  activeColor: Colors.amber,
                  label: _energyRating.toInt().toString(),
                  onChanged: (val) => setState(() => _energyRating = val),
                ),
                const SizedBox(height: 8),
                Text('Mood Level: ${_moodRating.toInt()}/10', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                Slider(
                  value: _moodRating,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  activeColor: Colors.blue,
                  label: _moodRating.toInt().toString(),
                  onChanged: (val) => setState(() => _moodRating = val),
                ),
                const SizedBox(height: 8),
                Text('Recovery Rating: ${_recoveryRating.toInt()}/10', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                Slider(
                  value: _recoveryRating,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  activeColor: Colors.green,
                  label: _recoveryRating.toInt().toString(),
                  onChanged: (val) => setState(() => _recoveryRating = val),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  initialValue: _tagsInput,
                  decoration: InputDecoration(
                    labelText: 'Tags (comma separated)',
                    hintText: 'workout, gym, legday',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onSaved: (val) => _tagsInput = val ?? '',
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _submit, child: Text(isEditing ? 'Update' : 'Save')),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final tagList = _tagsInput
          .split(',')
          .map((t) => t.trim().replaceAll('#', ''))
          .where((t) => t.isNotEmpty)
          .toList();

      final noteDate = widget.initialNote?.date ?? widget.defaultDate;
      final dateKey = ActivityLog.formatDateKey(noteDate);

      final note = (widget.initialNote ?? DailyNote(
        id: '',
        dateKey: dateKey,
        date: noteDate,
      )).copyWith(
        textNotes: _textNotes,
        energyRating: _energyRating.toInt(),
        moodRating: _moodRating.toInt(),
        recoveryRating: _recoveryRating.toInt(),
        tags: tagList,
      );

      widget.onSave(note);
      Navigator.pop(context);
    }
  }
}
