import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workout_provider.dart';
import '../../widgets/empty_state.dart';
import 'widgets/record_card.dart';

class PersonalRecordsScreen extends StatelessWidget {
  const PersonalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Records (PRs)'),
      ),
      body: SafeArea(
        child: workoutProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : workoutProvider.personalRecords.isEmpty
                ? EmptyState(
                    title: 'No Personal Records Yet',
                    message: 'Log your workouts, lifts, daily steps, and runs to automatically trigger PR badges.',
                    icon: Icons.emoji_events_rounded,
                    actionLabel: 'Log Workout',
                    onActionPressed: () => Navigator.pop(context),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: workoutProvider.personalRecords.length,
                    itemBuilder: (context, index) {
                      final record = workoutProvider.personalRecords[index];
                      return RecordCard(record: record);
                    },
                  ),
      ),
    );
  }
}
