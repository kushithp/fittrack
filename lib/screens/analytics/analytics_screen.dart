import 'package:flutter/material.dart';
import '../../widgets/empty_state.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics & Trends')),
      body: EmptyState(
        title: 'Interactive Analytics',
        message: 'Charts, progress trends, streaks, and GitHub-style contribution heatmaps will arrive in Stage 4.',
        icon: Icons.show_chart_rounded,
        actionLabel: 'Stage 4 Feature',
        onActionPressed: () {},
      ),
    );
  }
}
