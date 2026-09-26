import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/sleep_entry.dart';
import '../../providers/health_tracking_provider.dart';

class SleepTrackingWidget extends StatelessWidget {
  const SleepTrackingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final healthProvider = Provider.of<HealthTrackingProvider>(context);
    final theme = Theme.of(context);

    final sleep = healthProvider.todaySleepEntry;
    final duration = sleep?.durationHours ?? 7.5;
    final target = healthProvider.dailySleepTargetHours;
    final quality = sleep?.quality ?? SleepQuality.good;

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
                      color: const Color(0xFF6C5CE7).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.bedtime_rounded, color: Color(0xFF6C5CE7), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sleep Tracker', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text('Target: ${target.toStringAsFixed(1)} hrs', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
              FilledButton.icon(
                onPressed: () => _showLogSleepDialog(context, healthProvider),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Log Sleep'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${duration.toStringAsFixed(1)} hours',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Quality: ${quality.label}',
                  style: const TextStyle(color: Color(0xFF6C5CE7), fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (duration / target).clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: const Color(0xFF6C5CE7).withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogSleepDialog(BuildContext context, HealthTrackingProvider provider) {
    double duration = 8.0;
    SleepQuality quality = SleepQuality.good;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Log Sleep Duration'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Duration: ${duration.toStringAsFixed(1)} hours', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Slider(
                    value: duration,
                    min: 1.0,
                    max: 14.0,
                    divisions: 26,
                    label: '${duration.toStringAsFixed(1)} hrs',
                    onChanged: (val) => setState(() => duration = val),
                  ),
                  const SizedBox(height: 12),
                  const Text('Sleep Quality:', style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<SleepQuality>(
                    value: quality,
                    isExpanded: true,
                    items: SleepQuality.values.map((q) {
                      return DropdownMenuItem(value: q, child: Text(q.label));
                    }).toList(),
                    onChanged: (q) => setState(() => quality = q!),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
                FilledButton(
                  onPressed: () {
                    final now = DateTime.now();
                    final sleepTime = now.subtract(Duration(minutes: (duration * 60).round()));
                    provider.logSleep(sleepTime: sleepTime, wakeTime: now, quality: quality);
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
