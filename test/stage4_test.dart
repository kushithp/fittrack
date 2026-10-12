import 'package:flutter_test/flutter_test.dart';
import 'package:fittrack/data/models/activity_log.dart';
import 'package:fittrack/data/models/score_config.dart';
import 'package:fittrack/data/repositories/analytics_repository.dart';

import 'activity_repository_test.dart';

void main() {
  group('Stage 4 Analytics, Streaks & Fitness Score Tests', () {
    late MockInMemoryDatabaseService mockDb;

    setUp(() {
      mockDb = MockInMemoryDatabaseService();
    });

    test('AnalyticsRepository calculates daily fitness score based on custom weights', () async {
      final repo = AnalyticsRepository(mockDb);
      final today = DateTime.now();

      // Log 10,000 steps (100% score for steps)
      await mockDb.saveActivityLog(ActivityLog(
        id: 'l1',
        activityId: 'act_steps_1',
        dateKey: ActivityLog.formatDateKey(today),
        value: 10000,
        isCompleted: true,
      ));

      const config = ScoreConfig(
        stepsWeight: 50.0,
        workoutWeight: 0.0,
        waterWeight: 0.0,
        sleepWeight: 0.0,
        habitsWeight: 0.0,
      );

      final score = await repo.calculateDailyFitnessScore(today, config);
      expect(score, 100.0);
    });

    test('AnalyticsRepository generates chart points for selected metrics', () async {
      final repo = AnalyticsRepository(mockDb);

      final points = await repo.getChartDataPoints(
        metric: AnalyticsMetric.steps,
        timeframe: AnalyticsTimeframe.daily,
      );

      expect(points.length, 7);
      expect(points.first.targetValue, 10000.0);
    });

    test('AnalyticsRepository generates heatmap intensity data for specified days', () async {
      final repo = AnalyticsRepository(mockDb);

      final heatmap = await repo.getHeatmapIntensityData(14);
      expect(heatmap.length, 14);
    });

    test('StreakInfo calculates weekly and monthly consistency', () async {
      final repo = AnalyticsRepository(mockDb);

      final streaks = await repo.calculateStreaks();
      expect(streaks.currentStreakDays, greaterThanOrEqualTo(0));
      expect(streaks.longestStreakDays, greaterThanOrEqualTo(0));
    });
  });
}
