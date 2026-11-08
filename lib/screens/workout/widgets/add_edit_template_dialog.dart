import 'package:flutter/material.dart';
import '../../../data/models/workout_template.dart';
import '../../../data/models/exercise.dart';

class AddEditTemplateDialog extends StatefulWidget {
  final List<Exercise> availableExercises;
  final WorkoutTemplate? initialTemplate;
  final Function(WorkoutTemplate) onSave;

  const AddEditTemplateDialog({
    super.key,
    required this.availableExercises,
    this.initialTemplate,
    required this.onSave,
  });

  @override
  State<AddEditTemplateDialog> createState() => _AddEditTemplateDialogState();
}

class _AddEditTemplateDialogState extends State<AddEditTemplateDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _durationController;

  final List<TemplateExercise> _selectedExercises = [];

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.initialTemplate?.title ?? '');
    _descController =
        TextEditingController(text: widget.initialTemplate?.description ?? '');
    _durationController = TextEditingController(
      text: (widget.initialTemplate?.estimatedDurationMinutes ?? 45).toString(),
    );

    if (widget.initialTemplate != null) {
      _selectedExercises.addAll(widget.initialTemplate!.exercises);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _addExercise(Exercise ex) {
    if (_selectedExercises.any((e) => e.exerciseId == ex.id)) return;
    setState(() {
      _selectedExercises.add(
        TemplateExercise(
          exerciseId: ex.id,
          exerciseName: ex.name,
          defaultSets: 3,
          targetReps: 10,
          defaultWeightKg: 40.0,
        ),
      );
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _selectedExercises.removeAt(index);
    });
  }

  void _showExercisePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Select Exercise for Routine',
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: widget.availableExercises.isEmpty
                    ? const Center(child: Text('No exercises in catalog'))
                    : ListView.builder(
                        itemCount: widget.availableExercises.length,
                        itemBuilder: (context, index) {
                          final ex = widget.availableExercises[index];
                          final isAlreadyAdded =
                              _selectedExercises.any((e) => e.exerciseId == ex.id);

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  ex.category.color.withValues(alpha: 0.15),
                              child: Icon(
                                ex.category.icon,
                                color: ex.category.color,
                                size: 18,
                              ),
                            ),
                            title: Text(ex.name),
                            subtitle: Text(ex.category.label),
                            trailing: isAlreadyAdded
                                ? const Icon(Icons.check_circle_rounded,
                                    color: Colors.green)
                                : const Icon(Icons.add_circle_outline_rounded),
                            enabled: !isAlreadyAdded,
                            onTap: () {
                              _addExercise(ex);
                              Navigator.pop(sheetContext);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one exercise to this routine.'),
        ),
      );
      return;
    }

    final duration = int.tryParse(_durationController.text.trim()) ?? 45;
    final template = WorkoutTemplate(
      id: widget.initialTemplate?.id ??
          'template_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      exercises: _selectedExercises,
      estimatedDurationMinutes: duration,
      createdAt: widget.initialTemplate?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(template);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(
        widget.initialTemplate == null ? 'Create Routine' : 'Edit Routine',
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Routine Name',
                    hintText: 'e.g. Upper Body Hypertrophy',
                    prefixIcon: Icon(Icons.fitness_center_rounded),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Routine name is required'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: 'Description / Notes',
                    hintText: 'e.g. Focus on progressive overload and form',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(
                    labelText: 'Estimated Duration (minutes)',
                    prefixIcon: Icon(Icons.timer_outlined),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Exercises (${_selectedExercises.length})',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _showExercisePicker,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add Exercise'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (_selectedExercises.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'No exercises added yet.\nTap "Add Exercise" to choose from catalog.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  )
                else
                  ...List.generate(_selectedExercises.length, (idx) {
                    final e = _selectedExercises[idx];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.exerciseName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${e.defaultSets} sets × ${e.targetReps} reps @ ${e.defaultWeightKg.toStringAsFixed(1)} kg',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded,
                                  size: 18, color: Colors.red),
                              onPressed: () => _removeExercise(idx),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
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
          child: const Text('Save Routine'),
        ),
      ],
    );
  }
}
