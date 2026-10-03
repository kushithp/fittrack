import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/activity.dart';
import '../models/activity_log.dart';
import '../models/daily_note.dart';
import '../models/exercise.dart';
import '../models/goal.dart';
import '../models/personal_record.dart';
import '../models/sleep_entry.dart';
import '../models/water_entry.dart';
import '../models/weight_entry.dart';
import '../models/workout_exercise.dart';
import '../models/workout_session.dart';
import '../models/workout_set.dart';
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

  /// Initial Exercise Catalog.
  static List<Exercise> get defaultExercises {
    return [
      Exercise(id: 'ex_bench', name: 'Bench Press', category: ExerciseCategory.chest),
      Exercise(id: 'ex_incline_db', name: 'Incline Dumbbell Press', category: ExerciseCategory.chest),
      Exercise(id: 'ex_cable_fly', name: 'Cable Fly', category: ExerciseCategory.chest),
      Exercise(id: 'ex_squat', name: 'Barbell Squat', category: ExerciseCategory.legs),
      Exercise(id: 'ex_deadlift', name: 'Deadlift', category: ExerciseCategory.back),
      Exercise(id: 'ex_overhead', name: 'Overhead Press', category: ExerciseCategory.shoulders),
      Exercise(id: 'ex_lat_pulldown', name: 'Lat Pulldown', category: ExerciseCategory.back),
      Exercise(id: 'ex_db_curl', name: 'Dumbbell Curl', category: ExerciseCategory.biceps),
      Exercise(id: 'ex_tricep_pushdown', name: 'Tricep Pushdown', category: ExerciseCategory.triceps),
      Exercise(id: 'ex_run', name: 'Outdoor Running', category: ExerciseCategory.cardio, defaultUnit: 'km'),
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

  /// Initial sample Personal Records.
  static List<PersonalRecord> get defaultPersonalRecords {
    final now = DateTime.now();
    return [
      PersonalRecord(
        id: 'pr_1',
        title: 'Heaviest Bench Press',
        recordValue: 65.0,
        unit: 'kg',
        date: now.subtract(const Duration(days: 2)),
        category: RecordCategory.exercise,
        exerciseName: 'Bench Press',
      ),
      PersonalRecord(
        id: 'pr_2',
        title: 'Highest Squat',
        recordValue: 100.0,
        unit: 'kg',
        date: now.subtract(const Duration(days: 4)),
        category: RecordCategory.exercise,
        exerciseName: 'Barbell Squat',
      ),
      PersonalRecord(
        id: 'pr_3',
        title: 'Highest Deadlift',
        recordValue: 120.0,
        unit: 'kg',
        date: now.subtract(const Duration(days: 6)),
        category: RecordCategory.exercise,
        exerciseName: 'Deadlift',
      ),
      PersonalRecord(
        id: 'pr_4',
        title: 'Longest Workout Session',
        recordValue: 55.0,
        unit: 'min',
        date: now.subtract(const Duration(days: 2)),
        category: RecordCategory.workout,
      ),
    ];
  }

  /// Populates initial demo activities, exercises, workouts, goals, notes, weight, water, sleep, and PRs.
  static Future<void> populateDemoData(IDatabaseService db) async {
    for (final act in defaultActivities) {
      await db.saveActivity(act);
    }
    for (final ex in defaultExercises) {
      await db.saveExercise(ex);
    }
    for (final g in defaultGoals) {
      await db.saveGoal(g);
    }
    for (final pr in defaultPersonalRecords) {
      await db.savePersonalRecord(pr);
    }

    final today = DateTime.now();

    // Sample Workout Session: Chest + Triceps
    final chestTricepsWorkout = WorkoutSession(
      id: 'ws_chest_triceps_1',
      title: 'CHEST + TRICEPS',
      date: today.subtract(const Duration(days: 2)),
      durationMinutes: 50,
      notes: 'Felt strong today. Increased bench press by 5kg.',
      exercises: [
        WorkoutExercise(
          exerciseId: 'ex_bench',
          exerciseName: 'Bench Press',
          category: ExerciseCategory.chest,
          sets: [
            WorkoutSet(setNumber: 1, weightKg: 60.0, reps: 10),
            WorkoutSet(setNumber: 2, weightKg: 60.0, reps: 8),
            WorkoutSet(setNumber: 3, weightKg: 65.0, reps: 6),
          ],
        ),
        WorkoutExercise(
          exerciseId: 'ex_incline_db',
          exerciseName: 'Incline Dumbbell Press',
          category: ExerciseCategory.chest,
          sets: [
            WorkoutSet(setNumber: 1, weightKg: 22.5, reps: 10),
            WorkoutSet(setNumber: 2, weightKg: 22.5, reps: 10),
            WorkoutSet(setNumber: 3, weightKg: 22.5, reps: 8),
          ],
        ),
        WorkoutExercise(
          exerciseId: 'ex_cable_fly',
          exerciseName: 'Cable Fly',
          category: ExerciseCategory.chest,
          sets: [
            WorkoutSet(setNumber: 1, weightKg: 15.0, reps: 12),
            WorkoutSet(setNumber: 2, weightKg: 15.0, reps: 12),
            WorkoutSet(setNumber: 3, weightKg: 15.0, reps: 12),
          ],
        ),
      ],
    );
    await db.saveWorkoutSession(chestTricepsWorkout);

    // Generate 7 days of sample logs
    for (int dayOffset = 6; dayOffset >= 0; dayOffset--) {
      final date = today.subtract(Duration(days: dayOffset));
      final dateKey = ActivityLog.formatDateKey(date);
      final isToday = dayOffset == 0;

      for (final act in defaultActivities) {
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

      await db.saveWaterEntry(WaterEntry(
        id: _uuid.v4(),
        dateKey: dateKey,
        date: date,
        amountLiters: isToday ? 2.25 : 3.0,
      ));

      await db.saveWeightEntry(WeightEntry(
        id: _uuid.v4(),
        dateKey: dateKey,
        date: date,
        weightKg: double.parse((79.2 - (dayOffset * 0.1)).toStringAsFixed(1)),
        notes: isToday ? 'Morning weigh in after hydration' : '',
      ));

      final sleepTime = date.subtract(const Duration(hours: 8));
      await db.saveSleepEntry(SleepEntry(
        id: _uuid.v4(),
        dateKey: dateKey,
        sleepTime: sleepTime,
        wakeTime: date,
        durationHours: isToday ? 7.5 : 8.0,
        quality: SleepQuality.good,
      ));

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
