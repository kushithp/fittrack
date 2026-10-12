import 'package:flutter/material.dart';

class ContributionHeatmap extends StatelessWidget {
  final Map<String, double> heatmapData; // dateKey -> 0.0..1.0 intensity

  const ContributionHeatmap({
    super.key,
    required this.heatmapData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = heatmapData.entries.toList();

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
              Text('Activity Heatmap (GitHub Style)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  const Text('Less', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  const SizedBox(width: 4),
                  _buildLegendBox(Colors.green.withValues(alpha: 0.1)),
                  _buildLegendBox(Colors.green.withValues(alpha: 0.35)),
                  _buildLegendBox(Colors.green.withValues(alpha: 0.65)),
                  _buildLegendBox(Colors.green),
                  const SizedBox(width: 4),
                  const Text('More', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, // 7 days of the week columns
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final intensity = entries[index].value;
              return Tooltip(
                message: '${entries[index].key}: ${(intensity * 100).toInt()}% completed',
                child: Container(
                  decoration: BoxDecoration(
                    color: _getColorForIntensity(intensity, theme),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegendBox(Color color) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
    );
  }

  Color _getColorForIntensity(double intensity, ThemeData theme) {
    if (intensity <= 0) {
      return theme.brightness == Brightness.dark ? const Color(0xFF21262D) : const Color(0xFFEBEDF0);
    }
    if (intensity < 0.35) return Colors.green.withValues(alpha: 0.35);
    if (intensity < 0.70) return Colors.green.withValues(alpha: 0.65);
    return Colors.green;
  }
}
