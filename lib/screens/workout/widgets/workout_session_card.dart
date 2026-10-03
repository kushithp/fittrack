import 'package:flutter/material.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/workout_session.dart';

class WorkoutSessionCard extends StatelessWidget {
  final WorkoutSession session;
  final VoidCallback onDelete;

  const WorkoutSessionCard({
    super.key,
    required this.session,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = AppDateUtils.formatHeaderDate(session.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF30363D)
              : const Color(0xFFE9ECEF),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.fitness_center_rounded, color: theme.colorScheme.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(session.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text('$dateStr • ${session.durationMinutes} min', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.delete_rounded, size: 20, color: Colors.red),
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          ...session.exercises.map((ex) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(ex.exerciseName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('Max: ${Formatters.formatValue(ex.maxWeightKg)} kg', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: ex.sets.map((set) {
                      return Chip(
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        label: Text('Set ${set.setNumber}: ${Formatters.formatValue(set.weightKg)}kg × ${set.reps}'),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }),
          if (session.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Note: "${session.notes}"',
              style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }
}
