import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/activity.dart';
import '../models/activity_log.dart';
import '../models/daily_note.dart';
import '../models/exercise.dart';
import '../models/goal.dart';
import '../models/personal_record.dart';
import '../models/reminder.dart';
import '../models/sleep_entry.dart';
import '../models/water_entry.dart';
import '../models/weight_entry.dart';
import '../models/workout_session.dart';
import '../models/workout_template.dart';
import '../repositories/reminder_repository.dart';
import 'database_service.dart';

/// Full JSON Backup and Restore service for FitTrack.
/// Packages all activities, logs, goals, notes, workouts, routines, PRs,
/// body metrics (weight, water, sleep), and reminders into a single versioned payload.
class BackupService {
  static const int currentSchemaVersion = 1;

  /// Generates a complete, pretty-printed JSON backup string across all entities.
  Future<String> generateBackupJson(
    IDatabaseService db, [
    ReminderRepository? reminderRepo,
  ]) async {
    final activities = await db.getAllActivities();
    final logs = await db.getAllLogs();
    final goals = await db.getAllGoals();
    final notes = await db.getAllDailyNotes();
    final sessions = await db.getAllWorkoutSessions();
    final templates = await db.getAllWorkoutTemplates();
    final exercises = await db.getAllExercises();
    final prs = await db.getAllPersonalRecords();
    final weights = await db.getAllWeightEntries();
    final waters = await db.getAllWaterEntries();
    final sleeps = await db.getAllSleepEntries();

    List<Reminder> reminders = [];
    if (reminderRepo != null) {
      reminders = await reminderRepo.getAll();
    }

    final Map<String, dynamic> payload = {
      'appName': 'FitTrack',
      'version': currentSchemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'data': {
        'activities': activities.map((e) => e.toJson()).toList(),
        'activityLogs': logs.map((e) => e.toJson()).toList(),
        'goals': goals.map((e) => e.toJson()).toList(),
        'dailyNotes': notes.map((e) => e.toJson()).toList(),
        'workoutSessions': sessions.map((e) => e.toJson()).toList(),
        'workoutTemplates': templates.map((e) => e.toJson()).toList(),
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'personalRecords': prs.map((e) => e.toJson()).toList(),
        'weightEntries': weights.map((e) => e.toJson()).toList(),
        'waterEntries': waters.map((e) => e.toJson()).toList(),
        'sleepEntries': sleeps.map((e) => e.toJson()).toList(),
        'reminders': reminders.map((e) => e.toJson()).toList(),
      },
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// Exports the full backup to a JSON file in the app documents directory.
  /// Returns the absolute file path, or null on web.
  Future<String?> exportBackupToFile(
    IDatabaseService db, [
    ReminderRepository? reminderRepo,
  ]) async {
    if (kIsWeb) {
      debugPrint('[BackupService] File export not supported on web.');
      return null;
    }

    final jsonContent = await generateBackupJson(db, reminderRepo);
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    final file = File('${dir.path}/fittrack_backup_$timestamp.json');
    await file.writeAsString(jsonContent);
    debugPrint('[BackupService] Full backup saved to: ${file.path}');
    return file.path;
  }

  /// Restores all entities from a JSON backup string into the database and reminders repo.
  /// Returns the total count of entities restored.
  Future<int> restoreBackupFromJson(
    IDatabaseService db,
    String jsonString, [
    ReminderRepository? reminderRepo,
  ]) async {
    final Map<String, dynamic> parsed =
        jsonDecode(jsonString) as Map<String, dynamic>;

    if (!parsed.containsKey('data')) {
      throw const FormatException('Invalid backup file: missing "data" node.');
    }

    final data = parsed['data'] as Map<String, dynamic>;
    int restoredCount = 0;

    // 1. Activities
    if (data['activities'] is List) {
      for (final item in data['activities'] as List) {
        final a = Activity.fromJson(item as Map<String, dynamic>);
        await db.saveActivity(a);
        restoredCount++;
      }
    }

    // 2. Activity Logs
    if (data['activityLogs'] is List) {
      for (final item in data['activityLogs'] as List) {
        final l = ActivityLog.fromJson(item as Map<String, dynamic>);
        await db.saveActivityLog(l);
        restoredCount++;
      }
    }

    // 3. Goals
    if (data['goals'] is List) {
      for (final item in data['goals'] as List) {
        final g = Goal.fromJson(item as Map<String, dynamic>);
        await db.saveGoal(g);
        restoredCount++;
      }
    }

    // 4. Daily Notes
    if (data['dailyNotes'] is List) {
      for (final item in data['dailyNotes'] as List) {
        final n = DailyNote.fromJson(item as Map<String, dynamic>);
        await db.saveDailyNote(n);
        restoredCount++;
      }
    }

    // 5. Exercises Catalog
    if (data['exercises'] is List) {
      for (final item in data['exercises'] as List) {
        final ex = Exercise.fromJson(item as Map<String, dynamic>);
        await db.saveExercise(ex);
        restoredCount++;
      }
    }

    // 6. Workout Templates
    if (data['workoutTemplates'] is List) {
      for (final item in data['workoutTemplates'] as List) {
        final t = WorkoutTemplate.fromJson(item as Map<String, dynamic>);
        await db.saveWorkoutTemplate(t);
        restoredCount++;
      }
    }

    // 7. Workout Sessions
    if (data['workoutSessions'] is List) {
      for (final item in data['workoutSessions'] as List) {
        final w = WorkoutSession.fromJson(item as Map<String, dynamic>);
        await db.saveWorkoutSession(w);
        restoredCount++;
      }
    }

    // 8. Personal Records
    if (data['personalRecords'] is List) {
      for (final item in data['personalRecords'] as List) {
        final pr = PersonalRecord.fromJson(item as Map<String, dynamic>);
        await db.savePersonalRecord(pr);
        restoredCount++;
      }
    }

    // 9. Weight Entries
    if (data['weightEntries'] is List) {
      for (final item in data['weightEntries'] as List) {
        final we = WeightEntry.fromJson(item as Map<String, dynamic>);
        await db.saveWeightEntry(we);
        restoredCount++;
      }
    }

    // 10. Water Entries
    if (data['waterEntries'] is List) {
      for (final item in data['waterEntries'] as List) {
        final wa = WaterEntry.fromJson(item as Map<String, dynamic>);
        await db.saveWaterEntry(wa);
        restoredCount++;
      }
    }

    // 11. Sleep Entries
    if (data['sleepEntries'] is List) {
      for (final item in data['sleepEntries'] as List) {
        final sl = SleepEntry.fromJson(item as Map<String, dynamic>);
        await db.saveSleepEntry(sl);
        restoredCount++;
      }
    }

    // 12. Reminders
    if (reminderRepo != null && data['reminders'] is List) {
      for (final item in data['reminders'] as List) {
        final r = Reminder.fromJson(item as Map<String, dynamic>);
        await reminderRepo.save(r);
        restoredCount++;
      }
    }

    return restoredCount;
  }
}
