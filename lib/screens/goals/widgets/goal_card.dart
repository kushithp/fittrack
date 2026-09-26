import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/goal.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final ValueChanged<double> onUpdateProgress;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const GoalCard({
    super.key,
    required this.goal,
    required this.onUpdateProgress,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = goal.percentageCompleted;
    final isDone = goal.isCompleted || percent >= 100.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDone
              ? Colors.green.withValues(alpha: 0.5)
              : (theme.brightness == Brightness.dark ? const Color(0xFF30363D) : const Color(0xFFE9ECEF)),
          width: isDone ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (isDone ? Colors.green : goal.color).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isDone ? Icons.emoji_events_rounded : Icons.flag_rounded,
                        color: isDone ? Colors.green : goal.color,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
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
                          Text(
                            '${goal.timePeriod.label} Goal',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (val) {
                  if (val == 'edit') onEdit();
                  if (val == 'delete') onDelete();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [Icon(Icons.edit_rounded, size: 18), SizedBox(width: 8), Text('Edit')]),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [Icon(Icons.delete_rounded, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))]),
                  ),
                ],
              ),
            ],
          ),
          if (goal.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              goal.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${Formatters.formatValue(goal.currentProgress)} / ${Formatters.formatValue(goal.target)} ${goal.unit.symbol}',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                Formatters.formatPercent(percent),
                style: TextStyle(
                  color: isDone ? Colors.green : goal.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percent / 100.0,
              minHeight: 10,
              backgroundColor: goal.color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(
                isDone ? Colors.green : goal.color,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton.outlined(
                onPressed: () {
                  final step = goal.target > 100 ? 5.0 : 1.0;
                  onUpdateProgress((goal.currentProgress - step).clamp(0.0, double.infinity));
                },
                icon: const Icon(Icons.remove_rounded, size: 16),
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: () {
                  final step = goal.target > 100 ? 5.0 : 1.0;
                  onUpdateProgress(goal.currentProgress + step);
                },
                icon: const Icon(Icons.add_rounded, size: 16),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
