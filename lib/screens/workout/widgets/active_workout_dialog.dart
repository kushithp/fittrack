import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/workout_provider.dart';
import 'rest_timer_widget.dart';

class ActiveWorkoutDialog extends StatefulWidget {
  const ActiveWorkoutDialog({super.key});

  @override
  State<ActiveWorkoutDialog> createState() => _ActiveWorkoutDialogState();
}

class _ActiveWorkoutDialogState extends State<ActiveWorkoutDialog> {
  final _notesController = TextEditingController();
  final int _durationMinutes = 45;
  bool _showRestTimer = false;

  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final active = workoutProvider.activeSession;
    final theme = Theme.of(context);

    if (active == null) return const SizedBox.shrink();

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Active Workout: ${active.title}'),
          actions: [
            IconButton(
              icon: Icon(
                Icons.timer_rounded,
                color: _showRestTimer ? theme.colorScheme.primary : null,
              ),
              tooltip: 'Rest Timer',
              onPressed: () => setState(() => _showRestTimer = !_showRestTimer),
            ),
            TextButton.icon(
              onPressed: () {
                workoutProvider.finishWorkout(
                  durationMinutes: _durationMinutes,
                  notes: _notesController.text.trim(),
                );
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check_circle_rounded, color: Colors.green),
              label: const Text('Finish Workout', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.timer_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text('Duration: $_durationMinutes min', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text('Total Volume: ${Formatters.formatValue(active.totalVolumeKg)} kg', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              ),
              if (_showRestTimer)
                RestTimerWidget(
                  initialSeconds: 90,
                  onDismiss: () => setState(() => _showRestTimer = false),
                ),
              Expanded(
                child: active.exercises.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.fitness_center_rounded, size: 48, color: Colors.grey),
                            const SizedBox(height: 12),
                            const Text('No exercises added yet to this workout.'),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: () => _showAddExercisePicker(context, workoutProvider),
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Add Exercise'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: active.exercises.length,
                        itemBuilder: (context, exIdx) {
                          final ex = active.exercises[exIdx];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          ex.exerciseName,
                                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: () => workoutProvider.addSetToExercise(exIdx),
                                        icon: const Icon(Icons.add_rounded, size: 16),
                                        label: const Text('Add Set'),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close_rounded, size: 18),
                                        tooltip: 'Remove exercise',
                                        onPressed: () => workoutProvider.removeExerciseFromActiveWorkout(exIdx),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  ...List.generate(ex.sets.length, (setIdx) {
                                    final set = ex.sets[setIdx];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8.0),
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: set.isCompleted
                                            ? Colors.green.withValues(alpha: 0.1)
                                            : null,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              set.isCompleted
                                                  ? Icons.check_circle_rounded
                                                  : Icons.radio_button_unchecked_rounded,
                                              color: set.isCompleted ? Colors.green : Colors.grey,
                                              size: 20,
                                            ),
                                            tooltip: set.isCompleted ? 'Mark incomplete' : 'Mark done & rest',
                                            onPressed: () {
                                              workoutProvider.toggleSetCompleted(exIdx, setIdx);
                                              if (!set.isCompleted && !_showRestTimer) {
                                                setState(() => _showRestTimer = true);
                                              }
                                            },
                                          ),
                                          Text('Set ${set.setNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                          const SizedBox(width: 8),
                                          SizedBox(
                                            width: 76,
                                            child: TextFormField(
                                              initialValue: set.weightKg.toString(),
                                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                              decoration: const InputDecoration(labelText: 'Weight', isDense: true),
                                              onChanged: (val) {
                                                final w = double.tryParse(val) ?? set.weightKg;
                                                workoutProvider.updateSet(exIdx, setIdx, weightKg: w);
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text('×'),
                                          const SizedBox(width: 8),
                                          SizedBox(
                                            width: 68,
                                            child: TextFormField(
                                              initialValue: set.reps.toString(),
                                              keyboardType: TextInputType.number,
                                              decoration: const InputDecoration(labelText: 'Reps', isDense: true),
                                              onChanged: (val) {
                                                final r = int.tryParse(val) ?? set.reps;
                                                workoutProvider.updateSet(exIdx, setIdx, reps: r);
                                              },
                                            ),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            icon: const Icon(Icons.remove_circle_outline_rounded, size: 18),
                                            tooltip: 'Remove set',
                                            onPressed: () => workoutProvider.removeSetFromExercise(exIdx, setIdx),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showAddExercisePicker(context, workoutProvider),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add Exercise'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        workoutProvider.cancelWorkout();
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel Workout'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddExercisePicker(BuildContext context, WorkoutProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.exerciseCatalog.length,
          itemBuilder: (context, index) {
            final ex = provider.exerciseCatalog[index];
            return ListTile(
              leading: Icon(ex.category.icon, color: ex.category.color),
              title: Text(ex.name),
              subtitle: Text(ex.category.label),
              onTap: () {
                provider.addExerciseToActiveWorkout(ex);
                Navigator.pop(sheetContext);
              },
            );
          },
        );
      },
    );
  }
}
