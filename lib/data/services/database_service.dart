import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity.dart';
import '../models/activity_log.dart';
import '../models/daily_note.dart';
import '../models/exercise.dart';
import '../models/goal.dart';
import '../models/personal_record.dart';
import '../models/sleep_entry.dart';
import '../models/user_settings.dart';
import '../models/water_entry.dart';
import '../models/weight_entry.dart';
import '../models/workout_session.dart';

/// Local database contract for FitTrack.
abstract class IDatabaseService {
  Future<void> init();
  
  // Activities
  Future<List<Activity>> getAllActivities();
  Future<void> saveActivity(Activity activity);
  Future<void> deleteActivity(String id);
  
  // Activity Logs
  Future<List<ActivityLog>> getLogsForDate(String dateKey);
  Future<List<ActivityLog>> getAllLogs();
  Future<void> saveActivityLog(ActivityLog log);
  Future<void> deleteActivityLog(String id);

  // Goals
  Future<List<Goal>> getAllGoals();
  Future<void> saveGoal(Goal goal);
  Future<void> deleteGoal(String id);

  // Daily Notes
  Future<List<DailyNote>> getAllDailyNotes();
  Future<DailyNote?> getDailyNoteForDate(String dateKey);
  Future<void> saveDailyNote(DailyNote note);
  Future<void> deleteDailyNote(String id);

  // Weight Entries
  Future<List<WeightEntry>> getAllWeightEntries();
  Future<void> saveWeightEntry(WeightEntry entry);
  Future<void> deleteWeightEntry(String id);

  // Water Entries
  Future<List<WaterEntry>> getWaterEntriesForDate(String dateKey);
  Future<List<WaterEntry>> getAllWaterEntries();
  Future<void> saveWaterEntry(WaterEntry entry);
  Future<void> deleteWaterEntry(String id);

  // Sleep Entries
  Future<List<SleepEntry>> getAllSleepEntries();
  Future<SleepEntry?> getSleepEntryForDate(String dateKey);
  Future<void> saveSleepEntry(SleepEntry entry);
  Future<void> deleteSleepEntry(String id);

  // Exercises Library
  Future<List<Exercise>> getAllExercises();
  Future<void> saveExercise(Exercise exercise);
  Future<void> deleteExercise(String id);

  // Workout Sessions
  Future<List<WorkoutSession>> getAllWorkoutSessions();
  Future<void> saveWorkoutSession(WorkoutSession session);
  Future<void> deleteWorkoutSession(String id);

  // Personal Records
  Future<List<PersonalRecord>> getAllPersonalRecords();
  Future<void> savePersonalRecord(PersonalRecord record);
  Future<void> deletePersonalRecord(String id);

  // Settings
  Future<UserSettings> getUserSettings();
  Future<void> saveUserSettings(UserSettings settings);

  // Clear data
  Future<void> clearAllData();
}

/// Robust Local Data Storage using SharedPreferences + JSON Serialization.
class LocalDatabaseService implements IDatabaseService {
  static const String _activitiesKey = 'fittrack_activities_v1';
  static const String _activityLogsKey = 'fittrack_activity_logs_v1';
  static const String _goalsKey = 'fittrack_goals_v1';
  static const String _dailyNotesKey = 'fittrack_daily_notes_v1';
  static const String _weightKey = 'fittrack_weight_v1';
  static const String _waterKey = 'fittrack_water_v1';
  static const String _sleepKey = 'fittrack_sleep_v1';
  static const String _exercisesKey = 'fittrack_exercises_v1';
  static const String _workoutsKey = 'fittrack_workouts_v1';
  static const String _recordsKey = 'fittrack_records_v1';
  static const String _settingsKey = 'fittrack_settings_v1';

  SharedPreferences? _prefs;

  @override
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _instance {
    if (_prefs == null) {
      throw StateError('DatabaseService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // --- Activities ---
  @override
  Future<List<Activity>> getAllActivities() async {
    try {
      final rawJson = _instance.getString(_activitiesKey);
      if (rawJson == null || rawJson.isEmpty) return [];
      final List<dynamic> list = jsonDecode(rawJson);
      return list.map((e) => Activity.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveActivity(Activity activity) async {
    final list = await getAllActivities();
    final index = list.indexWhere((a) => a.id == activity.id);
    if (index >= 0) {
      list[index] = activity;
    } else {
      list.add(activity);
    }
    await _instance.setString(_activitiesKey, jsonEncode(list.map((a) => a.toJson()).toList()));
  }

  @override
  Future<void> deleteActivity(String id) async {
    final list = await getAllActivities();
    list.removeWhere((a) => a.id == id);
    await _instance.setString(_activitiesKey, jsonEncode(list.map((a) => a.toJson()).toList()));

    final logs = await getAllLogs();
    logs.removeWhere((l) => l.activityId == id);
    await _instance.setString(_activityLogsKey, jsonEncode(logs.map((l) => l.toJson()).toList()));
  }

  // --- Activity Logs ---
  @override
  Future<List<ActivityLog>> getAllLogs() async {
    try {
      final rawJson = _instance.getString(_activityLogsKey);
      if (rawJson == null || rawJson.isEmpty) return [];
      final List<dynamic> list = jsonDecode(rawJson);
      return list.map((e) => ActivityLog.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ActivityLog>> getLogsForDate(String dateKey) async {
    final all = await getAllLogs();
    return all.where((l) => l.dateKey == dateKey).toList();
  }

  @override
  Future<void> saveActivityLog(ActivityLog log) async {
    final logs = await getAllLogs();
    final index = logs.indexWhere((l) => l.id == log.id);
    if (index >= 0) {
      logs[index] = log;
    } else {
      logs.add(log);
    }
    await _instance.setString(_activityLogsKey, jsonEncode(logs.map((l) => l.toJson()).toList()));
  }

  @override
  Future<void> deleteActivityLog(String id) async {
    final logs = await getAllLogs();
    logs.removeWhere((l) => l.id == id);
    await _instance.setString(_activityLogsKey, jsonEncode(logs.map((l) => l.toJson()).toList()));
  }

  // --- Goals ---
  @override
  Future<List<Goal>> getAllGoals() async {
    try {
      final rawJson = _instance.getString(_goalsKey);
      if (rawJson == null || rawJson.isEmpty) return [];
      final List<dynamic> list = jsonDecode(rawJson);
      return list.map((e) => Goal.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveGoal(Goal goal) async {
    final list = await getAllGoals();
    final index = list.indexWhere((g) => g.id == goal.id);
    if (index >= 0) {
      list[index] = goal;
    } else {
      list.add(goal);
    }
    await _instance.setString(_goalsKey, jsonEncode(list.map((g) => g.toJson()).toList()));
  }

  @override
  Future<void> deleteGoal(String id) async {
    final list = await getAllGoals();
    list.removeWhere((g) => g.id == id);
    await _instance.setString(_goalsKey, jsonEncode(list.map((g) => g.toJson()).toList()));
  }

  // --- Daily Notes ---
  @override
  Future<List<DailyNote>> getAllDailyNotes() async {
    try {
      final rawJson = _instance.getString(_dailyNotesKey);
      if (rawJson == null || rawJson.isEmpty) return [];
      final List<dynamic> list = jsonDecode(rawJson);
      return list.map((e) => DailyNote.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<DailyNote?> getDailyNoteForDate(String dateKey) async {
    final all = await getAllDailyNotes();
    final matches = all.where((n) => n.dateKey == dateKey);
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  Future<void> saveDailyNote(DailyNote note) async {
    final list = await getAllDailyNotes();
    final index = list.indexWhere((n) => n.id == note.id || n.dateKey == note.dateKey);
    if (index >= 0) {
      list[index] = note;
    } else {
      list.add(note);
    }
    await _instance.setString(_dailyNotesKey, jsonEncode(list.map((n) => n.toJson()).toList()));
  }

  @override
  Future<void> deleteDailyNote(String id) async {
    final list = await getAllDailyNotes();
    list.removeWhere((n) => n.id == id);
    await _instance.setString(_dailyNotesKey, jsonEncode(list.map((n) => n.toJson()).toList()));
  }

  // --- Weight Entries ---
  @override
  Future<List<WeightEntry>> getAllWeightEntries() async {
    try {
      final rawJson = _instance.getString(_weightKey);
      if (rawJson == null || rawJson.isEmpty) return [];
      final List<dynamic> list = jsonDecode(rawJson);
      final entries = list.map((e) => WeightEntry.fromJson(e as Map<String, dynamic>)).toList();
      entries.sort((a, b) => b.date.compareTo(a.date));
      return entries;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveWeightEntry(WeightEntry entry) async {
    final list = await getAllWeightEntries();
    final index = list.indexWhere((w) => w.id == entry.id || w.dateKey == entry.dateKey);
    if (index >= 0) {
      list[index] = entry;
    } else {
      list.add(entry);
    }
    await _instance.setString(_weightKey, jsonEncode(list.map((w) => w.toJson()).toList()));
  }

  @override
  Future<void> deleteWeightEntry(String id) async {
    final list = await getAllWeightEntries();
    list.removeWhere((w) => w.id == id);
    await _instance.setString(_weightKey, jsonEncode(list.map((w) => w.toJson()).toList()));
  }

  // --- Water Entries ---
  @override
  Future<List<WaterEntry>> getAllWaterEntries() async {
    try {
      final rawJson = _instance.getString(_waterKey);
      if (rawJson == null || rawJson.isEmpty) return [];
      final List<dynamic> list = jsonDecode(rawJson);
      return list.map((e) => WaterEntry.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<WaterEntry>> getWaterEntriesForDate(String dateKey) async {
    final all = await getAllWaterEntries();
    return all.where((w) => w.dateKey == dateKey).toList();
  }

  @override
  Future<void> saveWaterEntry(WaterEntry entry) async {
    final list = await getAllWaterEntries();
    list.add(entry);
    await _instance.setString(_waterKey, jsonEncode(list.map((w) => w.toJson()).toList()));
  }

  @override
  Future<void> deleteWaterEntry(String id) async {
    final list = await getAllWaterEntries();
    list.removeWhere((w) => w.id == id);
    await _instance.setString(_waterKey, jsonEncode(list.map((w) => w.toJson()).toList()));
  }

  // --- Sleep Entries ---
  @override
  Future<List<SleepEntry>> getAllSleepEntries() async {
    try {
      final rawJson = _instance.getString(_sleepKey);
      if (rawJson == null || rawJson.isEmpty) return [];
      final List<dynamic> list = jsonDecode(rawJson);
      final entries = list.map((e) => SleepEntry.fromJson(e as Map<String, dynamic>)).toList();
      entries.sort((a, b) => b.dateKey.compareTo(a.dateKey));
      return entries;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<SleepEntry?> getSleepEntryForDate(String dateKey) async {
    final all = await getAllSleepEntries();
    final matches = all.where((s) => s.dateKey == dateKey);
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  Future<void> saveSleepEntry(SleepEntry entry) async {
    final list = await getAllSleepEntries();
    final index = list.indexWhere((s) => s.id == entry.id || s.dateKey == entry.dateKey);
    if (index >= 0) {
      list[index] = entry;
    } else {
      list.add(entry);
    }
    await _instance.setString(_sleepKey, jsonEncode(list.map((s) => s.toJson()).toList()));
  }

  @override
  Future<void> deleteSleepEntry(String id) async {
    final list = await getAllSleepEntries();
    list.removeWhere((s) => s.id == id);
    await _instance.setString(_sleepKey, jsonEncode(list.map((s) => s.toJson()).toList()));
  }

  // --- Exercises Catalog ---
  @override
  Future<List<Exercise>> getAllExercises() async {
    try {
      final rawJson = _instance.getString(_exercisesKey);
      if (rawJson == null || rawJson.isEmpty) return [];
      final List<dynamic> list = jsonDecode(rawJson);
      return list.map((e) => Exercise.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveExercise(Exercise exercise) async {
    final list = await getAllExercises();
    final index = list.indexWhere((e) => e.id == exercise.id);
    if (index >= 0) {
      list[index] = exercise;
    } else {
      list.add(exercise);
    }
    await _instance.setString(_exercisesKey, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  @override
  Future<void> deleteExercise(String id) async {
    final list = await getAllExercises();
    list.removeWhere((e) => e.id == id);
    await _instance.setString(_exercisesKey, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  // --- Workout Sessions ---
  @override
  Future<List<WorkoutSession>> getAllWorkoutSessions() async {
    try {
      final rawJson = _instance.getString(_workoutsKey);
      if (rawJson == null || rawJson.isEmpty) return [];
      final List<dynamic> list = jsonDecode(rawJson);
      final sessions = list.map((e) => WorkoutSession.fromJson(e as Map<String, dynamic>)).toList();
      sessions.sort((a, b) => b.date.compareTo(a.date));
      return sessions;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveWorkoutSession(WorkoutSession session) async {
    final list = await getAllWorkoutSessions();
    final index = list.indexWhere((w) => w.id == session.id);
    if (index >= 0) {
      list[index] = session;
    } else {
      list.add(session);
    }
    await _instance.setString(_workoutsKey, jsonEncode(list.map((w) => w.toJson()).toList()));
  }

  @override
  Future<void> deleteWorkoutSession(String id) async {
    final list = await getAllWorkoutSessions();
    list.removeWhere((w) => w.id == id);
    await _instance.setString(_workoutsKey, jsonEncode(list.map((w) => w.toJson()).toList()));
  }

  // --- Personal Records ---
  @override
  Future<List<PersonalRecord>> getAllPersonalRecords() async {
    try {
      final rawJson = _instance.getString(_recordsKey);
      if (rawJson == null || rawJson.isEmpty) return [];
      final List<dynamic> list = jsonDecode(rawJson);
      return list.map((e) => PersonalRecord.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> savePersonalRecord(PersonalRecord record) async {
    final list = await getAllPersonalRecords();
    final index = list.indexWhere((r) => r.id == record.id || r.title == record.title);
    if (index >= 0) {
      list[index] = record;
    } else {
      list.add(record);
    }
    await _instance.setString(_recordsKey, jsonEncode(list.map((r) => r.toJson()).toList()));
  }

  @override
  Future<void> deletePersonalRecord(String id) async {
    final list = await getAllPersonalRecords();
    list.removeWhere((r) => r.id == id);
    await _instance.setString(_recordsKey, jsonEncode(list.map((r) => r.toJson()).toList()));
  }

  // --- Settings ---
  @override
  Future<UserSettings> getUserSettings() async {
    try {
      final rawJson = _instance.getString(_settingsKey);
      if (rawJson == null || rawJson.isEmpty) return UserSettings();
      return UserSettings.fromJson(jsonDecode(rawJson));
    } catch (e) {
      return UserSettings();
    }
  }

  @override
  Future<void> saveUserSettings(UserSettings settings) async {
    await _instance.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  @override
  Future<void> clearAllData() async {
    await _instance.remove(_activitiesKey);
    await _instance.remove(_activityLogsKey);
    await _instance.remove(_goalsKey);
    await _instance.remove(_dailyNotesKey);
    await _instance.remove(_weightKey);
    await _instance.remove(_waterKey);
    await _instance.remove(_sleepKey);
    await _instance.remove(_exercisesKey);
    await _instance.remove(_workoutsKey);
    await _instance.remove(_recordsKey);
    await _instance.remove(_settingsKey);
  }
}
