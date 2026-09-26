import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/activity.dart';
import '../models/activity_log.dart';
import '../models/daily_note.dart';
import '../models/goal.dart';
import '../models/sleep_entry.dart';
import '../models/water_entry.dart';
import '../models/weight_entry.dart';
import 'database_service.dart';

class DemoDataService {
  static final _uuid = const Uuid();

  /// Initial default activities list for FitTrack.
  static List<Activity> get defaultActivities {
    final now = DateTime.now();
    return [
      Activity(
        id: 'act_steps_1',
        name: '10,000 Steps',
        description: 'Walk or run to reach 10,000 daily steps',
        target: 10000,
        unit: ActivityUnit.steps,
        category: ActivityCategory.cardio,
        iconCodePoint: Icons.directions_walk_rounded.codePoint,
        colorValue: const Color(0xFF00B4D8).value,
        isDailyChecklist: true,
        contributesToDailyScore: true,
        createdAt: now,
      ),
      Activity(
        id: 'act_distance_2',
        name: '5 km Distance',
        description: 'Daily outdoor walking or running distance',
        target: 5.0,
        unit: ActivityUnit.km,
        category: ActivityCategory.cardio,
        iconCodePoint: Icons.route_rounded.codePoint,
        colorValue: const Color(0xFF4CAF50).value,
        isDailyChecklist: true,
        contributesToDailyScore: true,
        createdAt: now,
      ),
      Activity(
        id: 'act_gym_3',
        name: 'Gym Workout',
        description: 'Complete scheduled gym workout session',
        target: 1.0,
        unit: ActivityUnit.workouts,
        category: ActivityCategory.strength,
        iconCodePoint: Icons.fitness_center_rounded.codePoint,
        colorValue: const Color(0xFFE91E63).value,
        isDailyChecklist: true,
        contributesToDailyScore: true,
        createdAt: now,
      ),
      Activity(
        id: 'act_water_4',
        name: 'Drink 3L Water',
        description: 'Stay hydrated throughout the day',
        target: 3.0,
        unit: ActivityUnit.liters,
        category: ActivityCategory.nutrition,
        iconCodePoint: Icons.water_drop_rounded.codePoint,
        colorValue: const Color(0xFF0077B6).value,
        isDailyChecklist: true,
        contributesToDailyScore: true,
        createdAt: now,
      ),
      Activity(
        id: 'act_protein_5',
        name: 'Protein Target',
        description: 'Consume 160g protein',
        target: 160,
        unit: ActivityUnit.grams,
        category: ActivityCategory.nutrition,
        iconCodePoint: Icons.restaurant_rounded.codePoint,
        colorValue: const Color(0xFFFF9800).value,
        isDailyChecklist: true,
        contributesToDailyScore: true,
        createdAt: now,
      ),
      Activity(
        id: 'act_sleep_6',
        name: 'Sleep 8 Hours',
        description: 'Restful sleep for recovery',
        target: 8.0,
        unit: ActivityUnit.hours,
        category: ActivityCategory.sleep,
        iconCodePoint: Icons.bedtime_rounded.codePoint,
        colorValue: const Color(0xFF6C5CE7).value,
        isDailyChecklist: true,
        contributesToDailyScore: true,
        createdAt: now,
      ),
      Activity(
        id: 'act_stretch_7',
        name: 'Stretching & Mobility',
        description: '15 minutes daily flexibility mobility session',
        target: 15,
        unit: ActivityUnit.minutes,
        category: ActivityCategory.wellness,
        iconCodePoint: Icons.self_improvement_rounded.codePoint,
        colorValue: const Color(0xFF00ACC1).value,
        isDailyChecklist: true,
        contributesToDailyScore: true,
        createdAt: now,
      ),
      Activity(
        id: 'act_meditation_8',
        name: 'Mindful Meditation',
        description: '10 minutes mindfulness & focus session',
        target: 10,
        unit: ActivityUnit.minutes,
        category: ActivityCategory.wellness,
        iconCodePoint: Icons.spa_rounded.codePoint,
        colorValue: const Color(0xFF9C27B0).value,
        isDailyChecklist: true,
        contributesToDailyScore: false,
        createdAt: now,
      ),
    ];
  }

  /// Initial sample Goals.
  static List<Goal> get defaultGoals {
    final now = DateTime.now();
    return [
      Goal(
        id: 'goal_steps_1',
        name: '10,000 steps per day',
        description: 'Maintain daily activity consistency',
        target: 10000,
        currentProgress: 8240,
        unit: ActivityUnit.steps,
        timePeriod: GoalTimePeriod.daily,
        startDate: now.subtract(const Duration(days: 7)),
        endDate: now.add(const Duration(days: 23)),
        colorValue: const Color(0xFF00B4D8).value,
      ),
      Goal(
        id: 'goal_walk_2',
        name: '30 km walking per week',
        description: 'Weekly aerobic cardio target',
        target: 30.0,
        currentProgress: 24.5,
        unit: ActivityUnit.km,
        timePeriod: GoalTimePeriod.weekly,
        startDate: now.subtract(const Duration(days: 5)),
        endDate: now.add(const Duration(days: 2)),
        colorValue: const Color(0xFF4CAF50).value,
      ),
      Goal(
        id: 'goal_gym_3',
        name: 'Gym 4 times per week',
        description: 'Consistent strength workouts',
        target: 4.0,
        currentProgress: 3.0,
        unit: ActivityUnit.workouts,
        timePeriod: GoalTimePeriod.weekly,
        startDate: now.subtract(const Duration(days: 5)),
        endDate: now.add(const Duration(days: 2)),
        colorValue: const Color(0xFFE91E63).value,
      ),
      Goal(
        id: 'goal_weight_4',
        name: 'Reach 75 kg weight',
        description: 'Target body weight goal',
        target: 75.0,
        currentProgress: 78.5,
        unit: ActivityUnit.kg,
        timePeriod: GoalTimePeriod.monthly,
        startDate: now.subtract(const Duration(days: 14)),
        endDate: now.add(const Duration(days: 46)),
        colorValue: const Color(0xFF9C27B0).value,
      ),
    ];
  }

  /// Populates initial demo activities, goals, notes, weight, water, and sleep.
  static Future<void> populateDemoData(IDatabaseService db) async {
    final activities = defaultActivities;
    for (final act in activities) {
      await db.saveActivity(act);
    }

    final goals = defaultGoals;
    for (final g in goals) {
      await db.saveGoal(g);
    }

    final today = DateTime.now();

    // Generate 7 days of sample data
    for (int dayOffset = 6; dayOffset >= 0; dayOffset--) {
      final date = today.subtract(Duration(days: dayOffset));
      final dateKey = ActivityLog.formatDateKey(date);
      final isToday = dayOffset == 0;

      // Activity Logs
      for (final act in activities) {
        double val = 0;
        bool completed = false;

        switch (act.id) {
          case 'act_steps_1':
            val = isToday ? 8240 : (8500 + (dayOffset * 320) % 3000).toDouble();
            completed = val >= act.target;
            break;
          case 'act_distance_2':
            val = isToday ? 5.7 : (4.5 + (dayOffset * 0.4) % 3.0);
            val = double.parse(val.toStringAsFixed(1));
            completed = val >= act.target;
            break;
          case 'act_gym_3':
            val = (dayOffset % 2 == 0) ? 1.0 : 0.0;
            completed = val >= 1.0;
            break;
          case 'act_water_4':
            val = isToday ? 2.25 : (2.5 + (dayOffset % 2) * 0.5);
            val = double.parse(val.toStringAsFixed(2));
            completed = val >= act.target;
            break;
          case 'act_protein_5':
            val = isToday ? 145 : (150 + (dayOffset * 5) % 25).toDouble();
            completed = val >= act.target;
            break;
          case 'act_sleep_6':
            val = isToday ? 7.5 : (7.0 + (dayOffset % 3) * 0.5);
            val = double.parse(val.toStringAsFixed(1));
            completed = val >= act.target;
            break;
          case 'act_stretch_7':
            val = (dayOffset != 3) ? 15.0 : 0.0;
            completed = val >= act.target;
            break;
          case 'act_meditation_8':
            val = 10.0;
            completed = true;
            break;
        }

        final log = ActivityLog(
          id: _uuid.v4(),
          activityId: act.id,
          dateKey: dateKey,
          value: val,
          isCompleted: completed,
          notes: isToday && act.id == 'act_gym_3' ? 'Chest and Triceps session' : '',
          createdAt: date,
        );
        await db.saveActivityLog(log);
      }

      // Water Entries
      await db.saveWaterEntry(WaterEntry(
        id: _uuid.v4(),
        dateKey: dateKey,
        date: date,
        amountLiters: isToday ? 2.25 : 3.0,
      ));

      // Weight Logs
      await db.saveWeightEntry(WeightEntry(
        id: _uuid.v4(),
        dateKey: dateKey,
        date: date,
        weightKg: double.parse((79.2 - (dayOffset * 0.1)).toStringAsFixed(1)),
        notes: isToday ? 'Morning weigh in after hydration' : '',
      ));

      // Sleep Logs
      final sleepTime = date.subtract(const Duration(hours: 8));
      await db.saveSleepEntry(SleepEntry(
        id: _uuid.v4(),
        dateKey: dateKey,
        sleepTime: sleepTime,
        wakeTime: date,
        durationHours: isToday ? 7.5 : 8.0,
        quality: SleepQuality.good,
      ));

      // Daily Notes
      if (dayOffset % 2 == 0) {
        await db.saveDailyNote(DailyNote(
          id: _uuid.v4(),
          dateKey: dateKey,
          date: date,
          energyRating: 8,
          moodRating: 9,
          recoveryRating: 7,
          textNotes: isToday
              ? 'Felt strong today. Increased bench press by 5kg.'
              : 'Great energy level throughout the afternoon session.',
          tags: ['workout', 'benchpress', 'strong'],
        ));
      }
    }
  }
}
