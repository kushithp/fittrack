import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/analytics_repository.dart';
import '../../providers/analytics_provider.dart';
import 'widgets/contribution_heatmap.dart';
import 'widgets/daily_score_card.dart';
import 'widgets/metric_line_chart.dart';
import 'widgets/score_config_dialog.dart';
import 'widgets/streak_overview_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final analyticsProvider = Provider.of<AnalyticsProvider>(context);
    final theme = Theme.of(context);

    if (analyticsProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Analytics',
            onPressed: () => analyticsProvider.refreshAnalytics(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Daily Fitness Score Card
              DailyScoreCard(
                score: analyticsProvider.todayFitnessScore,
                onConfigure: () => _showScoreConfigDialog(context, analyticsProvider),
              ),
              const SizedBox(height: 20),

              // Timeframe Filter Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Timeframe', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  SegmentedButton<AnalyticsTimeframe>(
                    segments: const [
                      ButtonSegment(value: AnalyticsTimeframe.daily, label: Text('Daily')),
                      ButtonSegment(value: AnalyticsTimeframe.weekly, label: Text('Weekly')),
                      ButtonSegment(value: AnalyticsTimeframe.monthly, label: Text('Monthly')),
                    ],
                    selected: {analyticsProvider.timeframe},
                    onSelectionChanged: (selected) {
                      analyticsProvider.setTimeframe(selected.first);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Metric Selector Dropdown
              DropdownButtonFormField<AnalyticsMetric>(
                value: analyticsProvider.selectedMetric,
                decoration: InputDecoration(
                  labelText: 'Select Chart Metric',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  prefixIcon: const Icon(Icons.show_chart_rounded),
                ),
                items: AnalyticsMetric.values.map((m) {
                  return DropdownMenuItem(value: m, child: Text(m.label));
                }).toList(),
                onChanged: (m) {
                  if (m != null) analyticsProvider.setSelectedMetric(m);
                },
              ),
              const SizedBox(height: 16),

              // Interactive Line Chart
              MetricLineChart(
                metric: analyticsProvider.selectedMetric,
                points: analyticsProvider.chartPoints,
              ),
              const SizedBox(height: 20),

              // Streaks Overview Card
              if (analyticsProvider.streakInfo != null) ...[
                StreakOverviewCard(streakInfo: analyticsProvider.streakInfo!),
                const SizedBox(height: 20),
              ],

              // GitHub-style Contribution Heatmap Grid
              ContributionHeatmap(heatmapData: analyticsProvider.heatmapData),
            ],
          ),
        ),
      ),
    );
  }

  void _showScoreConfigDialog(BuildContext context, AnalyticsProvider provider) {
    showDialog(
      context: context,
      builder: (_) => ScoreConfigDialog(
        currentConfig: provider.scoreConfig,
        onSave: (config) => provider.saveScoreConfig(config),
      ),
    );
  }
}
