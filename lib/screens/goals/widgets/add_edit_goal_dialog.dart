import 'package:flutter/material.dart';
import '../../../data/models/activity.dart';
import '../../../data/models/goal.dart';

class AddEditGoalDialog extends StatefulWidget {
  final Goal? initialGoal;
  final ValueChanged<Goal> onSave;

  const AddEditGoalDialog({
    super.key,
    this.initialGoal,
    required this.onSave,
  });

  @override
  State<AddEditGoalDialog> createState() => _AddEditGoalDialogState();
}

class _AddEditGoalDialogState extends State<AddEditGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  late double _target;
  late double _currentProgress;
  late ActivityUnit _unit;
  late GoalTimePeriod _timePeriod;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    final g = widget.initialGoal;
    _name = g?.name ?? '';
    _description = g?.description ?? '';
    _target = g?.target ?? 30.0;
    _currentProgress = g?.currentProgress ?? 0.0;
    _unit = g?.unit ?? ActivityUnit.km;
    _timePeriod = g?.timePeriod ?? GoalTimePeriod.weekly;
    _startDate = g?.startDate ?? DateTime.now();
    _endDate = g?.endDate ?? DateTime.now().add(const Duration(days: 30));
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialGoal != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Goal' : 'Create New Goal'),
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
                    labelText: 'Goal Title *',
                    hintText: 'e.g. 30 km walking per week, Reach 75 kg',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a title' : null,
                  onSaved: (val) => _name = val!.trim(),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  initialValue: _description,
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                          labelText: 'Target *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Required';
                          final num = double.tryParse(val);
                          if (num == null || num <= 0) return 'Invalid';
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
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: ActivityUnit.values.map((u) {
                          return DropdownMenuItem(value: u, child: Text(u.label));
                        }).toList(),
                        onChanged: (u) => setState(() => _unit = u!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<GoalTimePeriod>(
                        value: _timePeriod,
                        decoration: InputDecoration(
                          labelText: 'Time Period',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: GoalTimePeriod.values.map((t) {
                          return DropdownMenuItem(value: t, child: Text(t.label));
                        }).toList(),
                        onChanged: (t) => setState(() => _timePeriod = t!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        initialValue: _currentProgress.toString(),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Current Progress',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onSaved: (val) => _currentProgress = double.tryParse(val ?? '') ?? 0.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _submit, child: Text(isEditing ? 'Update' : 'Create')),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final goal = (widget.initialGoal ?? Goal(
        id: '',
        name: _name,
        target: _target,
        unit: _unit,
        startDate: _startDate,
        endDate: _endDate,
      )).copyWith(
        name: _name,
        description: _description,
        target: _target,
        currentProgress: _currentProgress,
        unit: _unit,
        timePeriod: _timePeriod,
        startDate: _startDate,
        endDate: _endDate,
        isCompleted: _currentProgress >= _target,
      );
      widget.onSave(goal);
      Navigator.pop(context);
    }
  }
}
