import 'package:flutter/material.dart';
import '../../../data/models/exercise.dart';

class AddEditExerciseDialog extends StatefulWidget {
  final Exercise? initialExercise;
  final ValueChanged<Exercise> onSave;

  const AddEditExerciseDialog({
    super.key,
    this.initialExercise,
    required this.onSave,
  });

  @override
  State<AddEditExerciseDialog> createState() => _AddEditExerciseDialogState();
}

class _AddEditExerciseDialogState extends State<AddEditExerciseDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late ExerciseCategory _category;
  late String _description;

  @override
  void initState() {
    super.initState();
    final ex = widget.initialExercise;
    _name = ex?.name ?? '';
    _category = ex?.category ?? ExerciseCategory.chest;
    _description = ex?.description ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialExercise != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Exercise' : 'Add New Exercise'),
      content: SingleChildScrollView(
        child: Container(
          width: 400,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: _name,
                  decoration: InputDecoration(
                    labelText: 'Exercise Name *',
                    hintText: 'e.g. Bench Press, Squats, Pull Ups',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a name' : null,
                  onSaved: (val) => _name = val!.trim(),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<ExerciseCategory>(
                  value: _category,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: ExerciseCategory.values.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Row(
                        children: [
                          Icon(c.icon, size: 20, color: c.color),
                          const SizedBox(width: 8),
                          Text(c.label),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (c) => setState(() => _category = c!),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  initialValue: _description,
                  decoration: InputDecoration(
                    labelText: 'Notes / Target Muscle',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onSaved: (val) => _description = val?.trim() ?? '',
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
      final exercise = (widget.initialExercise ?? Exercise(
        id: '',
        name: _name,
        category: _category,
      )).copyWith(
        name: _name,
        category: _category,
        description: _description,
      );
      widget.onSave(exercise);
      Navigator.pop(context);
    }
  }
}
