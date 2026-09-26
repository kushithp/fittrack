import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/goal.dart';
import '../../providers/goal_provider.dart';
import '../../widgets/empty_state.dart';
import 'widgets/add_edit_goal_dialog.dart';
import 'widgets/goal_card.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final goalProvider = Provider.of<GoalProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Goals'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddEditDialog(context, goalProvider),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Goal'),
      ),
      body: SafeArea(
        child: goalProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : goalProvider.goals.isEmpty
                ? EmptyState(
                    title: 'No Goals Set Yet',
                    message: 'Set personal targets (e.g. 10k steps/day, 30 km/week, Gym 4x/week) to track long-term progress.',
                    icon: Icons.flag_rounded,
                    actionLabel: 'Create Your First Goal',
                    onActionPressed: () => _openAddEditDialog(context, goalProvider),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: goalProvider.goals.length,
                    itemBuilder: (context, index) {
                      final goal = goalProvider.goals[index];
                      return GoalCard(
                        goal: goal,
                        onUpdateProgress: (newProgress) {
                          goalProvider.updateGoalProgress(goal.id, newProgress);
                        },
                        onEdit: () => _openAddEditDialog(
                          context,
                          goalProvider,
                          goal: goal,
                        ),
                        onDelete: () => _confirmDeleteGoal(context, goalProvider, goal),
                      );
                    },
                  ),
      ),
    );
  }

  void _openAddEditDialog(
    BuildContext context,
    GoalProvider provider, {
    Goal? goal,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AddEditGoalDialog(
          initialGoal: goal,
          onSave: (savedGoal) {
            provider.saveGoal(savedGoal);
          },
        );
      },
    );
  }

  void _confirmDeleteGoal(
    BuildContext context,
    GoalProvider provider,
    Goal goal,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Goal?'),
          content: Text('Are you sure you want to delete goal "${goal.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                provider.deleteGoal(goal.id);
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
