import 'package:flutter/material.dart';
import '../../../data/models/activity.dart';

class AddEditActivityDialog extends StatefulWidget {
  final Activity? initialActivity;
  final ValueChanged<Activity> onSave;

  const AddEditActivityDialog({
    super.key,
    this.initialActivity,
    required this.onSave,
  });

  @override
  State<AddEditActivityDialog> createState() => _AddEditActivityDialogState();
}

class _AddEditActivityDialogState extends State<AddEditActivityDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  late double _target;
  late ActivityUnit _unit;
  late ActivityCategory _category;
  late bool _isDailyChecklist;
  late bool _contributesToDailyScore;

  @override
  void initState() {
    super.initState();
    final act = widget.initialActivity;
    _name = act?.name ?? '';
    _description = act?.description ?? '';
    _target = act?.target ?? 10.0;
    _unit = act?.unit ?? ActivityUnit.steps;
    _category = act?.category ?? ActivityCategory.cardio;
    _isDailyChecklist = act?.isDailyChecklist ?? true;
    _contributesToDailyScore = act?.contributesToDailyScore ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialActivity != null;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(isEditing ? 'Edit Activity' : 'New Activity'),
      content: SingleChildScrollView(
        child: Container(
          width: 450,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: _name,
                  decoration: InputDecoration(
                    labelText: 'Activity Name *',
                    hintText: 'e.g. 10,000 steps, Drink 3L water',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Please enter a name' : null,
                  onSaved: (val) => _name = val!.trim(),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  initialValue: _description,
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSaved: (val) => _description = val?.trim() ?? '',
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        initialValue: _target.toString(),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Daily Target *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Required';
                          final num = double.tryParse(value);
                          if (num == null || num < 0) return 'Invalid';
                          return null;
                        },
                        onSaved: (val) => _target = double.parse(val!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<ActivityUnit>(
                        value: _unit,
                        decoration: InputDecoration(
                          labelText: 'Unit',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: ActivityUnit.values.map((u) {
                          return DropdownMenuItem(
                            value: u,
                            child: Text(u.label),
                          );
                        }).toList(),
                        onChanged: (u) => setState(() => _unit = u!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<ActivityCategory>(
                  value: _category,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: ActivityCategory.values.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Row(
                        children: [
                          Icon(c.icon, size: 20, color: c.defaultColor),
                          const SizedBox(width: 10),
                          Text(c.label),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (c) => setState(() => _category = c!),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Include in Daily Checklist'),
                  subtitle: const Text('Display on today checklist widget'),
                  value: _isDailyChecklist,
                  onChanged: (val) => setState(() => _isDailyChecklist = val),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('Contributes to Daily Score'),
                  subtitle: const Text('Factor this into daily completion percentage'),
                  value: _contributesToDailyScore,
                  onChanged: (val) => setState(() => _contributesToDailyScore = val),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Update' : 'Create'),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final activity = (widget.initialActivity ?? Activity(
        id: '',
        name: _name,
        target: _target,
        unit: _unit,
        category: _category,
      )).copyWith(
        name: _name,
        description: _description,
        target: _target,
        unit: _unit,
        category: _category,
        isDailyChecklist: _isDailyChecklist,
        contributesToDailyScore: _contributesToDailyScore,
      );
      widget.onSave(activity);
      Navigator.pop(context);
    }
  }
}
