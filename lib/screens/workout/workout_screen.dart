import 'package:flutter/material.dart';
import '../../widgets/empty_state.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Tracking')),
      body: EmptyState(
        title: 'Workout Logging',
        message: 'Exercise routines, sets, reps, weight tracking, and personal records will arrive in Stage 3.',
        icon: Icons.fitness_center_rounded,
        actionLabel: 'Stage 3 Feature',
        onActionPressed: () {},
      ),
    );
  }
}
