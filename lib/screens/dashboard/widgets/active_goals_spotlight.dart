import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/goal.dart';
import '../../../providers/goal_provider.dart';
import '../../goals/goals_screen.dart';
import '../../goals/widgets/add_edit_goal_dialog.dart';

/// Spotlight card on the Dashboard highlighting top active goals with progress.
class ActiveGoalsSpotlight extends StatelessWidget {
  const ActiveGoalsSpotlight({super.key});

  @override
  Widget build(BuildContext context) {
    final goalProvider = Provider.of<GoalProvider>(context);
    final theme = Theme.of(context);
    final activeGoals = goalProvider.activeGoals;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Active Goals",
              style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GoalsScreen()),
                );
              },
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text("All Goals"),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (activeGoals.isEmpty)
          _EmptyGoalsBanner(
            onAddGoal: () {
              showDialog(
                context: context,
                builder: (_) => AddEditGoalDialog(
                  onSave: (newGoal) => goalProvider.saveGoal(newGoal),
                ),
              );
            },
          )
        else
          Column(
            children: activeGoals.take(2).map((goal) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _GoalSpotlightCard(
                  goal: goal,
                  onUpdateProgress: (val) {
                    goalProvider.updateGoalProgress(goal.id, val);
                  },
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _GoalSpotlightCard extends StatelessWidget {
  final Goal goal;
  final ValueChanged<double> onUpdateProgress;

  const _GoalSpotlightCard({
    required this.goal,
    required this.onUpdateProgress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final percent = goal.percentageCompleted;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF30363D) : const Color(0xFFE9ECEF),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (goal.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        goal.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: goal.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  goal.timePeriod.label,
                  style: TextStyle(
                    color: goal.color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${Formatters.formatValue(goal.currentProgress)} / ${Formatters.formatValue(goal.target)} ${goal.unit.symbol}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                Formatters.formatPercent(percent),
                style: TextStyle(
                  color: goal.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (percent / 100.0).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: goal.color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(goal.color),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyGoalsBanner extends StatelessWidget {
  final VoidCallback onAddGoal;

  const _EmptyGoalsBanner({required this.onAddGoal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF30363D) : const Color(0xFFE9ECEF),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.track_changes_rounded,
              color: theme.colorScheme.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "No Active Goals",
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Set a weekly or monthly target to stay focused.",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color
                        ?.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          FilledButton.tonal(
            onPressed: onAddGoal,
            child: const Text("Set Goal"),
          ),
        ],
      ),
    );
  }
}
