import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/activity.dart';
import '../../../data/models/activity_log.dart';

class ActivityTile extends StatelessWidget {
  final Activity activity;
  final ActivityLog? log;
  final VoidCallback onToggle;
  final ValueChanged<double> onUpdateProgress;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ActivityTile({
    super.key,
    required this.activity,
    this.log,
    required this.onToggle,
    required this.onUpdateProgress,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDone = log?.isCompleted ?? false;
    final currentVal = log?.value ?? 0.0;
    final targetVal = activity.target;
    final percent = targetVal > 0 ? (currentVal / targetVal * 100).clamp(0.0, 100.0) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF30363D)
              : const Color(0xFFE9ECEF),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: activity.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(activity.iconData, color: activity.color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              activity.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                decoration: isDone ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: activity.category.defaultColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              activity.category.label,
                              style: TextStyle(
                                color: activity.category.defaultColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${Formatters.formatValue(currentVal)} / ${Formatters.formatValue(targetVal)} ${activity.unit.symbol}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
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
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded, size: 18),
                          SizedBox(width: 10),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_rounded, size: 18, color: Colors.red),
                          SizedBox(width: 10),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: percent / 100.0,
                      minHeight: 8,
                      backgroundColor: activity.color.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDone ? Colors.green : activity.color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                if (activity.unit == ActivityUnit.checkbox)
                  IconButton.filled(
                    onPressed: onToggle,
                    icon: Icon(
                      isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      size: 20,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: isDone ? Colors.green : activity.color,
                    ),
                  )
                else
                  Row(
                    children: [
                      IconButton.outlined(
                        onPressed: () {
                          final step = targetVal > 100 ? 500.0 : (targetVal > 10 ? 1.0 : 0.5);
                          final next = (currentVal - step).clamp(0.0, double.infinity);
                          onUpdateProgress(next);
                        },
                        icon: const Icon(Icons.remove_rounded, size: 18),
                        visualDensity: VisualDensity.compact,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          Formatters.formatPercent(percent),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: () {
                          final step = targetVal > 100 ? 500.0 : (targetVal > 10 ? 1.0 : 0.5);
                          onUpdateProgress(currentVal + step);
                        },
                        icon: const Icon(Icons.add_rounded, size: 18),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
