import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/streak_info.dart';

class StreakOverviewCard extends StatelessWidget {
  final StreakInfo streakInfo;

  const StreakOverviewCard({
    super.key,
    required this.streakInfo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 26),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Consistency & Streaks', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const Text('Daily activity streak momentum', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCol('Current Streak', '${streakInfo.currentStreakDays} days', Colors.orange, theme),
              const VerticalDivider(width: 1),
              _buildStatCol('Longest Streak', '${streakInfo.longestStreakDays} days', Colors.amber, theme),
              const VerticalDivider(width: 1),
              _buildStatCol('Weekly', Formatters.formatPercent(streakInfo.weeklyConsistencyPercent), Colors.green, theme),
              const VerticalDivider(width: 1),
              _buildStatCol('Monthly', Formatters.formatPercent(streakInfo.monthlyConsistencyPercent), theme.colorScheme.primary, theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCol(String label, String val, Color color, ThemeData theme) {
    return Column(
      children: [
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6))),
        const SizedBox(height: 4),
        Text(
          val,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
