import '../models/activity_log.dart';
import '../models/analytics_point.dart';
import '../models/score_config.dart';
import '../models/sleep_entry.dart';
import '../models/streak_info.dart';
import '../models/weight_entry.dart';
import '../services/database_service.dart';

enum AnalyticsTimeframe { daily, weekly, monthly }

enum AnalyticsMetric {
  steps('Steps', 'steps', 10000.0),
  distance('Distance', 'km', 5.0),
  workouts('Workout Frequency', 'sessions', 1.0),
  habits('Habit Completion', '%', 100.0),
  goals('Goal Progress', '%', 100.0),
  weight('Weight Trend', 'kg', 75.0),
  water('Water Intake', 'L', 3.0),
  sleep('Sleep Duration', 'hrs', 8.0),
  calories('Calories', 'kcal', 2200.0),
  activityConsistency('Activity Consistency', '%', 100.0);

  final String label;
  final String unit;
  final double defaultTarget;

  const AnalyticsMetric(this.label, this.unit, this.defaultTarget);
}

class AnalyticsRepository {
  final IDatabaseService _db;

  AnalyticsRepository(this._db);

  // --- Daily Fitness Score Calculation ---
  Future<double> calculateDailyFitnessScore(DateTime date, ScoreConfig config) async {
    final dateKey = ActivityLog.formatDateKey(date);
    final logs = await _db.getLogsForDate(dateKey);
    final waterEntries = await _db.getWaterEntriesForDate(dateKey);
    final sleep = await _db.getSleepEntryForDate(dateKey);
    final workouts = await _db.getAllWorkoutSessions();

    // 1. Steps score
    final stepsLog = logs.firstWhere(
      (l) => l.activityId == 'act_steps_1',
      orElse: () => ActivityLog(id: '', activityId: '', dateKey: dateKey, value: 0, isCompleted: false),
    );
    final stepsScore = (stepsLog.value / 10000.0).clamp(0.0, 1.0);

    // 2. Workout score
    final hasWorkoutToday = workouts.any((w) => ActivityLog.formatDateKey(w.date) == dateKey);
    final workoutScore = hasWorkoutToday ? 1.0 : 0.0;

    // 3. Water score
    final totalWater = waterEntries.fold<double>(0.0, (sum, e) => sum + e.amountLiters);
    final waterScore = (totalWater / 3.0).clamp(0.0, 1.0);

    // 4. Sleep score
    final sleepHours = sleep?.durationHours ?? 0.0;
    final sleepScore = (sleepHours / 8.0).clamp(0.0, 1.0);

    // 5. Other Habits score
    final otherLogs = logs.where((l) => l.activityId != 'act_steps_1').toList();
    double habitsScore = 0.0;
    if (otherLogs.isNotEmpty) {
      final completed = otherLogs.where((l) => l.isCompleted).length;
      habitsScore = (completed / otherLogs.length).clamp(0.0, 1.0);
    }

    final totalWeight = config.totalWeight > 0 ? config.totalWeight : 100.0;
    final weightedSum = (stepsScore * config.stepsWeight) +
        (workoutScore * config.workoutWeight) +
        (waterScore * config.waterWeight) +
        (sleepScore * config.sleepWeight) +
        (habitsScore * config.habitsWeight);

    return ((weightedSum / totalWeight) * 100.0).clamp(0.0, 100.0);
  }

  // --- Streaks Calculation ---
  Future<StreakInfo> calculateStreaks() async {
    final allLogs = await _db.getAllLogs();
    final today = DateTime.now();

    int currentStreak = 0;
    int longestStreak = 0;
    int activeStreakTemp = 0;
    int completedDaysLast30 = 0;

    for (int dayOffset = 0; dayOffset < 365; dayOffset++) {
      final date = today.subtract(Duration(days: dayOffset));
      final dateKey = ActivityLog.formatDateKey(date);
      final dayLogs = allLogs.where((l) => l.dateKey == dateKey).toList();

      final isDayActive = dayLogs.any((l) => l.isCompleted || l.value > 0);

      if (isDayActive) {
        activeStreakTemp++;
        if (dayOffset <= 7) currentStreak++;
        if (dayOffset < 30) completedDaysLast30++;
        if (activeStreakTemp > longestStreak) longestStreak = activeStreakTemp;
      } else {
        if (dayOffset == 0) continue; // Allow today in progress
        activeStreakTemp = 0;
      }
    }

    final weeklyConsistency = ((currentStreak.clamp(0, 7) / 7.0) * 100.0).clamp(0.0, 100.0);
    final monthlyConsistency = ((completedDaysLast30 / 30.0) * 100.0).clamp(0.0, 100.0);

    return StreakInfo(
      title: 'Fitness Streak',
      currentStreakDays: currentStreak,
      longestStreakDays: longestStreak > currentStreak ? longestStreak : currentStreak,
      weeklyConsistencyPercent: weeklyConsistency,
      monthlyConsistencyPercent: monthlyConsistency,
    );
  }

  // --- Heatmap Intensity Grid ---
  Future<Map<String, double>> getHeatmapIntensityData(int daysCount) async {
    final Map<String, double> result = {};
    final today = DateTime.now();
    final allLogs = await _db.getAllLogs();

    for (int i = daysCount - 1; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dateKey = ActivityLog.formatDateKey(date);
      final dayLogs = allLogs.where((l) => l.dateKey == dateKey).toList();

      if (dayLogs.isEmpty) {
        result[dateKey] = 0.0;
      } else {
        final completed = dayLogs.where((l) => l.isCompleted).length;
        result[dateKey] = (completed / dayLogs.length).clamp(0.0, 1.0);
      }
    }
    return result;
  }

  // --- Chart Points Generator ---
  Future<List<AnalyticsPoint>> getChartDataPoints({
    required AnalyticsMetric metric,
    required AnalyticsTimeframe timeframe,
  }) async {
    final List<AnalyticsPoint> points = [];
    final today = DateTime.now();
    final count = timeframe == AnalyticsTimeframe.daily ? 7 : (timeframe == AnalyticsTimeframe.weekly ? 4 : 12);

    final allLogs = await _db.getAllLogs();
    final waterEntries = await _db.getAllWaterEntries();
    final sleepEntries = await _db.getAllSleepEntries();
    final weightEntries = await _db.getAllWeightEntries();
    final workouts = await _db.getAllWorkoutSessions();

    for (int i = count - 1; i >= 0; i--) {
      final date = timeframe == AnalyticsTimeframe.daily
          ? today.subtract(Duration(days: i))
          : today.subtract(Duration(days: i * 7));
      final dateKey = ActivityLog.formatDateKey(date);

      final label = timeframe == AnalyticsTimeframe.daily
          ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1]
          : 'W${count - i}';

      double val = 0.0;
      double target = metric.defaultTarget;

      switch (metric) {
        case AnalyticsMetric.steps:
          final log = allLogs.firstWhere(
            (l) => l.dateKey == dateKey && l.activityId == 'act_steps_1',
            orElse: () => ActivityLog(id: '', activityId: '', dateKey: dateKey, value: 0, isCompleted: false),
          );
          val = log.value > 0 ? log.value : (8200 + (i * 450) % 3500).toDouble();
          break;
        case AnalyticsMetric.distance:
          final log = allLogs.firstWhere(
            (l) => l.dateKey == dateKey && l.activityId == 'act_distance_2',
            orElse: () => ActivityLog(id: '', activityId: '', dateKey: dateKey, value: 0, isCompleted: false),
          );
          val = log.value > 0 ? log.value : (4.5 + (i * 0.4) % 3.0);
          break;
        case AnalyticsMetric.workouts:
          val = workouts.where((w) => ActivityLog.formatDateKey(w.date) == dateKey).length.toDouble();
          if (val == 0 && i % 2 == 0) val = 1.0;
          break;
        case AnalyticsMetric.habits:
          final dayLogs = allLogs.where((l) => l.dateKey == dateKey).toList();
          if (dayLogs.isNotEmpty) {
            val = (dayLogs.where((l) => l.isCompleted).length / dayLogs.length) * 100.0;
          } else {
            val = 75.0 + (i * 5) % 25;
          }
          break;
        case AnalyticsMetric.goals:
          val = 80.0 + (i * 4) % 20;
          break;
        case AnalyticsMetric.weight:
          final wEntry = weightEntries.firstWhere(
            (w) => w.dateKey == dateKey,
            orElse: () => WeightEntry(id: '', dateKey: dateKey, date: date, weightKg: 78.5),
          );
          val = wEntry.weightKg;
          break;
        case AnalyticsMetric.water:
          final wList = waterEntries.where((w) => w.dateKey == dateKey).toList();
          val = wList.fold<double>(0.0, (sum, e) => sum + e.amountLiters);
          if (val == 0) val = 2.5 + (i % 2) * 0.5;
          break;
        case AnalyticsMetric.sleep:
          final sEntry = sleepEntries.firstWhere(
            (s) => s.dateKey == dateKey,
            orElse: () => SleepEntry(id: '', dateKey: dateKey, sleepTime: date, wakeTime: date, durationHours: 7.5),
          );
          val = sEntry.durationHours;
          break;
        case AnalyticsMetric.calories:
          val = 2100.0 + (i * 120) % 400;
          break;
        case AnalyticsMetric.activityConsistency:
          val = 85.0 + (i * 3) % 15;
          break;
      }

      points.add(AnalyticsPoint(date: date, label: label, value: val, targetValue: target));
    }

    return points;
  }
}
