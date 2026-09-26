import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/formatters.dart';
import '../../providers/health_tracking_provider.dart';

class WaterTrackingWidget extends StatelessWidget {
  const WaterTrackingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final healthProvider = Provider.of<HealthTrackingProvider>(context);
    final theme = Theme.of(context);

    final currentLiters = healthProvider.todayWaterTotalLiters;
    final targetLiters = healthProvider.dailyWaterTargetLiters;
    final percentage = healthProvider.waterCompletionPercentage;

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
                      color: const Color(0xFF0077B6).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.water_drop_rounded, color: Color(0xFF0077B6), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Water Tracker', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text('Daily Target: ${targetLiters.toStringAsFixed(1)} L', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0077B6).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  Formatters.formatPercent(percentage),
                  style: const TextStyle(color: Color(0xFF0077B6), fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${currentLiters.toStringAsFixed(2)} / ${targetLiters.toStringAsFixed(1)} L',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.edit_rounded, size: 18),
                tooltip: 'Edit Water Target',
                onPressed: () => _showTargetDialog(context, healthProvider),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: const Color(0xFF0077B6).withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0077B6)),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Quick Add Intake:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildQuickAddButton(context, healthProvider, '+250 ml', 0.25)),
              const SizedBox(width: 8),
              Expanded(child: _buildQuickAddButton(context, healthProvider, '+500 ml', 0.50)),
              const SizedBox(width: 8),
              Expanded(child: _buildQuickAddButton(context, healthProvider, '+750 ml', 0.75)),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                icon: const Icon(Icons.add_rounded),
                tooltip: 'Custom Water Amount',
                onPressed: () => _showCustomWaterDialog(context, healthProvider),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddButton(BuildContext context, HealthTrackingProvider provider, String label, double liters) {
    return FilledButton.tonal(
      onPressed: () => provider.addWater(liters),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  void _showTargetDialog(BuildContext context, HealthTrackingProvider provider) {
    final controller = TextEditingController(text: provider.dailyWaterTargetLiters.toString());
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Daily Water Target'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Target (Liters)', suffixText: 'L'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final val = double.tryParse(controller.text);
                if (val != null && val > 0) provider.setWaterTarget(val);
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showCustomWaterDialog(BuildContext context, HealthTrackingProvider provider) {
    final controller = TextEditingController(text: '0.35');
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Custom Water Intake'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Amount (Liters)', hintText: '0.35'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final val = double.tryParse(controller.text);
                if (val != null && val > 0) provider.addWater(val);
                Navigator.pop(dialogContext);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
