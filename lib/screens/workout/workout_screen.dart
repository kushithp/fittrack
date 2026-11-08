import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/workout_template.dart';
import '../../providers/workout_provider.dart';
import '../../widgets/empty_state.dart';
import '../records/personal_records_screen.dart';
import 'widgets/active_workout_dialog.dart';
import 'widgets/add_edit_exercise_dialog.dart';
import 'widgets/add_edit_template_dialog.dart';
import 'widgets/workout_session_card.dart';
import 'widgets/workout_template_card.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Workout & Routines'),
          actions: [
            IconButton(
              icon: const Icon(Icons.emoji_events_rounded, color: Colors.amber),
              tooltip: 'Personal Records',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PersonalRecordsScreen()),
                );
              },
            ),
          ],
          bottom: const TabBar(
            isScrollable: false,
            tabs: [
              Tab(icon: Icon(Icons.history_rounded), text: 'History'),
              Tab(icon: Icon(Icons.fitness_center_rounded), text: 'Routines'),
              Tab(icon: Icon(Icons.library_books_rounded), text: 'Library'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showStartOptions(context, workoutProvider),
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Start Workout'),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              // Tab 1: Workout History
              workoutProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : workoutProvider.workoutHistory.isEmpty
                      ? EmptyState(
                          title: 'No Workouts Logged Yet',
                          message: 'Log your gym routines (e.g. Chest + Triceps, Bench Press 60kg x 10) to track progress.',
                          icon: Icons.fitness_center_rounded,
                          actionLabel: 'Start First Workout',
                          onActionPressed: () => _startBlankWorkout(context, workoutProvider),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: workoutProvider.workoutHistory.length,
                          itemBuilder: (context, index) {
                            final session = workoutProvider.workoutHistory[index];
                            return WorkoutSessionCard(
                              session: session,
                              onDelete: () => _confirmDeleteWorkout(context, workoutProvider, session.id),
                            );
                          },
                        ),

              // Tab 2: Routines & Templates
              workoutProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pre-Built & Custom Routines',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: () => _showAddTemplateDialog(context, workoutProvider),
                              icon: const Icon(Icons.add_rounded, size: 16),
                              label: const Text('New Routine'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (workoutProvider.templates.isEmpty)
                          EmptyState(
                            title: 'No Routines Found',
                            message: 'Create routine templates with predefined sets, reps, and weights to jumpstart your workouts with 1 tap.',
                            icon: Icons.format_list_bulleted_rounded,
                            actionLabel: 'Create Routine',
                            onActionPressed: () => _showAddTemplateDialog(context, workoutProvider),
                          )
                        else
                          ...workoutProvider.templates.map(
                            (template) => WorkoutTemplateCard(
                              template: template,
                              onStart: () => _startTemplateWorkout(context, workoutProvider, template),
                              onDelete: () => _confirmDeleteTemplate(context, workoutProvider, template.id),
                            ),
                          ),
                      ],
                    ),

              // Tab 3: Exercise Library Catalog
              ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: workoutProvider.exerciseCatalog.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Reusable Exercise Catalog', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          OutlinedButton.icon(
                            onPressed: () => _showAddExerciseDialog(context, workoutProvider),
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: const Text('New Exercise'),
                          ),
                        ],
                      ),
                    );
                  }

                  final ex = workoutProvider.exerciseCatalog[index - 1];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: ex.category.color.withValues(alpha: 0.15),
                        child: Icon(ex.category.icon, color: ex.category.color, size: 20),
                      ),
                      title: Text(ex.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${ex.category.label} • Default Unit: ${ex.defaultUnit}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_rounded, size: 18, color: Colors.red),
                        onPressed: () => workoutProvider.deleteExercise(ex.id),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStartOptions(BuildContext context, WorkoutProvider provider) {
    if (provider.templates.isEmpty) {
      _startBlankWorkout(context, provider);
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Start a Workout Session',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.edit_note_rounded, color: Colors.white),
                  ),
                  title: const Text('Blank Workout Session', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Start from scratch and add exercises on the fly'),
                  onTap: () {
                    Navigator.pop(bottomSheetCtx);
                    _startBlankWorkout(context, provider);
                  },
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                  child: Text(
                    'Or Launch From Routine',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                ...provider.templates.take(3).map(
                  (t) => ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.fitness_center_rounded, color: Colors.white, size: 20),
                    ),
                    title: Text(t.title),
                    subtitle: Text('${t.exercises.length} exercises • ~${t.estimatedDurationMinutes}m'),
                    onTap: () {
                      Navigator.pop(bottomSheetCtx);
                      _startTemplateWorkout(context, provider, t);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _startBlankWorkout(BuildContext context, WorkoutProvider provider) {
    provider.startWorkout('CHEST + TRICEPS');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ActiveWorkoutDialog(),
    );
  }

  void _startTemplateWorkout(BuildContext context, WorkoutProvider provider, WorkoutTemplate template) {
    provider.startWorkoutFromTemplate(template);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ActiveWorkoutDialog(),
    );
  }

  void _showAddTemplateDialog(BuildContext context, WorkoutProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AddEditTemplateDialog(
        availableExercises: provider.exerciseCatalog,
        onSave: (template) => provider.saveTemplate(template),
      ),
    );
  }

  void _confirmDeleteTemplate(BuildContext context, WorkoutProvider provider, String id) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Routine?'),
          content: const Text('Are you sure you want to delete this workout routine template?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                provider.deleteTemplate(id);
                Navigator.pop(dialogContext);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showAddExerciseDialog(BuildContext context, WorkoutProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AddEditExerciseDialog(
        onSave: (saved) => provider.saveExercise(saved),
      ),
    );
  }

  void _confirmDeleteWorkout(BuildContext context, WorkoutProvider provider, String id) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Workout Log?'),
          content: const Text('Are you sure you want to delete this workout session record?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                provider.deleteWorkoutSession(id);
                Navigator.pop(dialogContext);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
