import 'package:flutter_test/flutter_test.dart';
import 'package:fittrack/data/models/activity.dart';
import 'package:fittrack/data/models/activity_log.dart';
import 'package:fittrack/data/models/daily_note.dart';
import 'package:fittrack/data/models/exercise.dart';
import 'package:fittrack/data/models/goal.dart';
import 'package:fittrack/data/models/personal_record.dart';
import 'package:fittrack/data/models/sleep_entry.dart';
import 'package:fittrack/data/models/user_settings.dart';
import 'package:fittrack/data/models/water_entry.dart';
import 'package:fittrack/data/models/weight_entry.dart';
import 'package:fittrack/data/models/workout_session.dart';
import 'package:fittrack/data/repositories/activity_repository.dart';
import 'package:fittrack/data/services/database_service.dart';

class MockInMemoryDatabaseService implements IDatabaseService {
  final Map<String, Activity> _activities = {};
  final Map<String, ActivityLog> _logs = {};
  final Map<String, Goal> _goals = {};
  final Map<String, DailyNote> _notes = {};
  final Map<String, WeightEntry> _weight = {};
  final List<WaterEntry> _water = [];
  final Map<String, SleepEntry> _sleep = {};
  final Map<String, Exercise> _exercises = {};
  final Map<String, WorkoutSession> _workouts = {};
  final Map<String, PersonalRecord> _records = {};
  UserSettings _settings = UserSettings();

  @override
  Future<void> init() async {}

  @override
  Future<List<Activity>> getAllActivities() async => _activities.values.toList();

  @override
  Future<void> saveActivity(Activity activity) async => _activities[activity.id] = activity;

  @override
  Future<void> deleteActivity(String id) async {
    _activities.remove(id);
    _logs.removeWhere((k, v) => v.activityId == id);
  }

  @override
  Future<List<ActivityLog>> getAllLogs() async => _logs.values.toList();

  @override
  Future<List<ActivityLog>> getLogsForDate(String dateKey) async =>
      _logs.values.where((l) => l.dateKey == dateKey).toList();

  @override
  Future<void> saveActivityLog(ActivityLog log) async => _logs[log.id] = log;

  @override
  Future<void> deleteActivityLog(String id) async => _logs.remove(id);

  // --- Goals ---
  @override
  Future<List<Goal>> getAllGoals() async => _goals.values.toList();

  @override
  Future<void> saveGoal(Goal goal) async => _goals[goal.id] = goal;

  @override
  Future<void> deleteGoal(String id) async => _goals.remove(id);

  // --- Daily Notes ---
  @override
  Future<List<DailyNote>> getAllDailyNotes() async => _notes.values.toList();

  @override
  Future<DailyNote?> getDailyNoteForDate(String dateKey) async {
    final matches = _notes.values.where((n) => n.dateKey == dateKey);
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  Future<void> saveDailyNote(DailyNote note) async => _notes[note.id] = note;

  @override
  Future<void> deleteDailyNote(String id) async => _notes.remove(id);

  // --- Weight Entries ---
  @override
  Future<List<WeightEntry>> getAllWeightEntries() async {
    final list = _weight.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  @override
  Future<void> saveWeightEntry(WeightEntry entry) async => _weight[entry.id] = entry;

  @override
  Future<void> deleteWeightEntry(String id) async => _weight.remove(id);

  // --- Water Entries ---
  @override
  Future<List<WaterEntry>> getAllWaterEntries() async => List.from(_water);

  @override
  Future<List<WaterEntry>> getWaterEntriesForDate(String dateKey) async =>
      _water.where((w) => w.dateKey == dateKey).toList();

  @override
  Future<void> saveWaterEntry(WaterEntry entry) async => _water.add(entry);

  @override
  Future<void> deleteWaterEntry(String id) async => _water.removeWhere((w) => w.id == id);

  // --- Sleep Entries ---
  @override
  Future<List<SleepEntry>> getAllSleepEntries() async => _sleep.values.toList();

  @override
  Future<SleepEntry?> getSleepEntryForDate(String dateKey) async {
    final matches = _sleep.values.where((s) => s.dateKey == dateKey);
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  Future<void> saveSleepEntry(SleepEntry entry) async => _sleep[entry.id] = entry;

  @override
  Future<void> deleteSleepEntry(String id) async => _sleep.remove(id);

  // --- Exercises Library ---
  @override
  Future<List<Exercise>> getAllExercises() async => _exercises.values.toList();

  @override
  Future<void> saveExercise(Exercise exercise) async => _exercises[exercise.id] = exercise;

  @override
  Future<void> deleteExercise(String id) async => _exercises.remove(id);

  // --- Workout Sessions ---
  @override
  Future<List<WorkoutSession>> getAllWorkoutSessions() async => _workouts.values.toList();

  @override
  Future<void> saveWorkoutSession(WorkoutSession session) async => _workouts[session.id] = session;

  @override
  Future<void> deleteWorkoutSession(String id) async => _workouts.remove(id);

  // --- Personal Records ---
  @override
  Future<List<PersonalRecord>> getAllPersonalRecords() async => _records.values.toList();

  @override
  Future<void> savePersonalRecord(PersonalRecord record) async => _records[record.id] = record;

  @override
  Future<void> deletePersonalRecord(String id) async => _records.remove(id);

  @override
  Future<UserSettings> getUserSettings() async => _settings;

  @override
  Future<void> saveUserSettings(UserSettings settings) async => _settings = settings;

  @override
  Future<void> clearAllData() async {
    _activities.clear();
    _logs.clear();
    _goals.clear();
    _notes.clear();
    _weight.clear();
    _water.clear();
    _sleep.clear();
    _exercises.clear();
    _workouts.clear();
    _records.clear();
  }
}

void main() {
  group('ActivityRepository Tests', () {
    late MockInMemoryDatabaseService mockDb;
    late ActivityRepository repo;

    setUp(() {
      mockDb = MockInMemoryDatabaseService();
      repo = ActivityRepository(mockDb);
    });

    test('Daily completion percentage calculates correctly', () async {
      final act1 = Activity(
        id: '1',
        name: 'Steps',
        target: 10000,
        unit: ActivityUnit.steps,
        category: ActivityCategory.cardio,
        contributesToDailyScore: true,
      );
      final act2 = Activity(
        id: '2',
        name: 'Water',
        target: 2.0,
        unit: ActivityUnit.liters,
        category: ActivityCategory.nutrition,
        contributesToDailyScore: true,
      );

      await repo.saveActivity(act1);
      await repo.saveActivity(act2);

      final date = DateTime(2026, 9, 24);

      await repo.logActivityProgress(activity: act1, date: date, value: 5000);
      await repo.logActivityProgress(activity: act2, date: date, value: 2.0);

      final percentage = await repo.calculateDailyCompletionPercentage(date);
      expect(percentage, 75.0);
    });

    test('Toggling checklist updates completion status', () async {
      final act = Activity(
        id: 'chk_1',
        name: 'Meditation',
        target: 1,
        unit: ActivityUnit.checkbox,
        category: ActivityCategory.wellness,
      );
      await repo.saveActivity(act);

      final date = DateTime(2026, 9, 24);
      final log1 = await repo.toggleActivityChecklist(activity: act, date: date);
      expect(log1.isCompleted, isTrue);

      final log2 = await repo.toggleActivityChecklist(activity: act, date: date);
      expect(log2.isCompleted, isFalse);
    });
  });
}
