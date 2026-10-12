import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/analytics_point.dart';
import '../../../data/repositories/analytics_repository.dart';

class MetricLineChart extends StatelessWidget {
  final AnalyticsMetric metric;
  final List<AnalyticsPoint> points;

  const MetricLineChart({
    super.key,
    required this.metric,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (points.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('No chart data available.')),
      );
    }

    final spots = List.generate(points.length, (index) {
      return FlSpot(index.toDouble(), points[index].value);
    });

    final maxY = points.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final targetY = points.first.targetValue;
    final topLimit = (maxY > targetY ? maxY : targetY) * 1.2;

    return Container(
      height: 260,
      padding: const EdgeInsets.only(top: 24, bottom: 12, left: 12, right: 20),
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
              Text(
                '${metric.label} Trend',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (targetY > 0)
                Row(
                  children: [
                    Container(width: 12, height: 2, color: Colors.orangeAccent),
                    const SizedBox(width: 6),
                    Text(
                      'Target: ${Formatters.formatValue(targetY)} ${metric.unit}',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < points.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              points[idx].label,
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (points.length - 1).toDouble(),
                minY: 0,
                maxY: topLimit > 0 ? topLimit : 100,
                extraLinesData: ExtraLinesData(
                  horizontalLines: targetY > 0
                      ? [
                          HorizontalLine(
                            y: targetY,
                            color: Colors.orangeAccent,
                            strokeWidth: 1.5,
                            dashArray: [6, 4],
                          ),
                        ]
                      : [],
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: theme.colorScheme.primary,
                    barWidth: 3.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
