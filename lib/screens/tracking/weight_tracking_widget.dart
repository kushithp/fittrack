import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/health_tracking_provider.dart';

class WeightTrackingWidget extends StatelessWidget {
  const WeightTrackingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final healthProvider = Provider.of<HealthTrackingProvider>(context);
    final theme = Theme.of(context);

    final latest = healthProvider.latestWeightEntry;
    final starting = healthProvider.startingWeightEntry;
    final currentWeight = latest?.weightKg ?? 78.5;
    final startWeight = starting?.weightKg ?? currentWeight;
    final goalWeight = healthProvider.targetWeightKg;

    final diffFromGoal = currentWeight - goalWeight;
    final diffFromStart = currentWeight - startWeight;

    return Container(
      padding: const EdgeInsets.all(20),
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
                      color: Colors.purple.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.monitor_weight_rounded, color: Colors.purple, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Weight Tracker', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text('${healthProvider.weightGoalType.label} (Goal: $goalWeight kg)', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
              FilledButton.icon(
                onPressed: () => _showLogWeightDialog(context, healthProvider, currentWeight),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Log'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricColumn('Current', '${currentWeight.toStringAsFixed(1)} kg', theme),
              const VerticalDivider(width: 1),
              _buildMetricColumn('Start (${diffFromStart >= 0 ? '+' : ''}${diffFromStart.toStringAsFixed(1)} kg)', '${startWeight.toStringAsFixed(1)} kg', theme),
              const VerticalDivider(width: 1),
              _buildMetricColumn(
                'To Goal',
                '${diffFromGoal > 0 ? '+' : ''}${diffFromGoal.toStringAsFixed(1)} kg',
                theme,
                color: diffFromGoal.abs() < 0.5 ? Colors.green : Colors.purple,
              ),
            ],
          ),
          if (latest?.notes.isNotEmpty ?? false) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Note: "${latest!.notes}"',
                style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, ThemeData theme, {Color? color}) {
    return Column(
      children: [
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6))),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color ?? theme.textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  void _showLogWeightDialog(BuildContext context, HealthTrackingProvider provider, double current) {
    final weightController = TextEditingController(text: current.toString());
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Log Weight'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Weight (kg)', suffixText: 'kg'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes (Optional)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final w = double.tryParse(weightController.text);
                if (w != null && w > 0) {
                  provider.logWeight(w, notes: notesController.text.trim());
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
