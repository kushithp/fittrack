import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workout_provider.dart';
import '../../widgets/empty_state.dart';
import '../records/personal_records_screen.dart';
import 'widgets/active_workout_dialog.dart';
import 'widgets/add_edit_exercise_dialog.dart';
import 'widgets/workout_session_card.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Workout Logging'),
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
            tabs: [
              Tab(icon: Icon(Icons.history_rounded), text: 'Workout Sessions'),
              Tab(icon: Icon(Icons.library_books_rounded), text: 'Exercise Library'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _startNewWorkout(context, workoutProvider),
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
                          onActionPressed: () => _startNewWorkout(context, workoutProvider),
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

              // Tab 2: Exercise Library Catalog
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

  void _startNewWorkout(BuildContext context, WorkoutProvider provider) {
    provider.startWorkout('CHEST + TRICEPS');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ActiveWorkoutDialog(),
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
