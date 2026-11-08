import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

import 'package:fittrack/data/models/activity.dart';
import 'package:fittrack/data/models/activity_log.dart';
import 'package:fittrack/data/models/daily_note.dart';
import 'package:fittrack/data/models/exercise.dart';
import 'package:fittrack/data/models/goal.dart';
import 'package:fittrack/data/models/personal_record.dart';
import 'package:fittrack/data/models/score_config.dart';
import 'package:fittrack/data/models/sleep_entry.dart';
import 'package:fittrack/data/models/user_settings.dart';
import 'package:fittrack/data/models/water_entry.dart';
import 'package:fittrack/data/models/weight_entry.dart';
import 'package:fittrack/data/models/workout_session.dart';
import 'package:fittrack/data/models/workout_template.dart';
import 'package:fittrack/data/repositories/workout_repository.dart';
import 'package:fittrack/data/services/backup_service.dart';
import 'package:fittrack/data/services/database_service.dart';
import 'package:fittrack/providers/workout_provider.dart';

class MockDatabaseServiceForStage7 implements IDatabaseService {
  final Map<String, Activity> _activities = {};
  final Map<String, ActivityLog> _logs = {};
  final Map<String, Goal> _goals = {};
  final Map<String, DailyNote> _notes = {};
  final Map<String, WeightEntry> _weight = {};
  final List<WaterEntry> _water = [];
  final Map<String, SleepEntry> _sleep = {};
  final Map<String, Exercise> _exercises = {};
  final Map<String, WorkoutSession> _workouts = {};
  final Map<String, WorkoutTemplate> _templates = {};
  final Map<String, PersonalRecord> _records = {};
  ScoreConfig _scoreConfig = const ScoreConfig();
  UserSettings _settings = UserSettings();

  @override
  Future<void> init() async {}

  @override
  Future<List<Activity>> getAllActivities() async => _activities.values.toList();
  @override
  Future<void> saveActivity(Activity activity) async => _activities[activity.id] = activity;
  @override
  Future<void> deleteActivity(String id) async => _activities.remove(id);

  @override
  Future<List<ActivityLog>> getAllLogs() async => _logs.values.toList();
  @override
  Future<List<ActivityLog>> getLogsForDate(String dateKey) async =>
      _logs.values.where((l) => l.dateKey == dateKey).toList();
  @override
  Future<void> saveActivityLog(ActivityLog log) async => _logs[log.id] = log;
  @override
  Future<void> deleteActivityLog(String id) async => _logs.remove(id);

  @override
  Future<List<Goal>> getAllGoals() async => _goals.values.toList();
  @override
  Future<void> saveGoal(Goal goal) async => _goals[goal.id] = goal;
  @override
  Future<void> deleteGoal(String id) async => _goals.remove(id);

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

  @override
  Future<List<WeightEntry>> getAllWeightEntries() async => _weight.values.toList();
  @override
  Future<void> saveWeightEntry(WeightEntry entry) async => _weight[entry.id] = entry;
  @override
  Future<void> deleteWeightEntry(String id) async => _weight.remove(id);

  @override
  Future<List<WaterEntry>> getAllWaterEntries() async => List.from(_water);
  @override
  Future<List<WaterEntry>> getWaterEntriesForDate(String dateKey) async =>
      _water.where((w) => w.dateKey == dateKey).toList();
  @override
  Future<void> saveWaterEntry(WaterEntry entry) async => _water.add(entry);
  @override
  Future<void> deleteWaterEntry(String id) async => _water.removeWhere((w) => w.id == id);

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

  @override
  Future<List<Exercise>> getAllExercises() async => _exercises.values.toList();
  @override
  Future<void> saveExercise(Exercise exercise) async => _exercises[exercise.id] = exercise;
  @override
  Future<void> deleteExercise(String id) async => _exercises.remove(id);

  @override
  Future<List<WorkoutSession>> getAllWorkoutSessions() async => _workouts.values.toList();
  @override
  Future<void> saveWorkoutSession(WorkoutSession session) async => _workouts[session.id] = session;
  @override
  Future<void> deleteWorkoutSession(String id) async => _workouts.remove(id);

  @override
  Future<List<WorkoutTemplate>> getAllWorkoutTemplates() async => _templates.values.toList();
  @override
  Future<void> saveWorkoutTemplate(WorkoutTemplate template) async =>
      _templates[template.id] = template;
  @override
  Future<void> deleteWorkoutTemplate(String id) async => _templates.remove(id);

  @override
  Future<List<PersonalRecord>> getAllPersonalRecords() async => _records.values.toList();
  @override
  Future<void> savePersonalRecord(PersonalRecord record) async => _records[record.id] = record;
  @override
  Future<void> deletePersonalRecord(String id) async => _records.remove(id);

  @override
  Future<ScoreConfig> getScoreConfig() async => _scoreConfig;
  @override
  Future<void> saveScoreConfig(ScoreConfig config) async => _scoreConfig = config;

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
    _templates.clear();
    _records.clear();
  }
}

void main() {
  group('Stage 7: Workout Routines & Templates Tests', () {
    test('WorkoutTemplate and TemplateExercise JSON serialization round-trip', () {
      final template = WorkoutTemplate(
        id: 'tmpl_100',
        title: 'Push Hypertrophy',
        description: 'Focus on progressive chest & delts overload',
        estimatedDurationMinutes: 60,
        exercises: [
          const TemplateExercise(
            exerciseId: 'ex_bench',
            exerciseName: 'Barbell Bench Press',
            defaultSets: 4,
            targetReps: 8,
            defaultWeightKg: 80.0,
          ),
          const TemplateExercise(
            exerciseId: 'ex_incline',
            exerciseName: 'Incline Dumbbell Press',
            defaultSets: 3,
            targetReps: 12,
            defaultWeightKg: 28.0,
          ),
        ],
        createdAt: DateTime(2026, 11, 8, 10, 0),
        updatedAt: DateTime(2026, 11, 8, 10, 0),
      );

      final json = template.toJson();
      final reconstructed = WorkoutTemplate.fromJson(json);

      expect(reconstructed.id, equals('tmpl_100'));
      expect(reconstructed.title, equals('Push Hypertrophy'));
      expect(reconstructed.estimatedDurationMinutes, equals(60));
      expect(reconstructed.exercises.length, equals(2));
      expect(reconstructed.exercises[0].exerciseName, equals('Barbell Bench Press'));
      expect(reconstructed.exercises[0].defaultSets, equals(4));
      expect(reconstructed.exercises[0].targetReps, equals(8));
      expect(reconstructed.exercises[0].defaultWeightKg, equals(80.0));
      expect(reconstructed.exercises[1].exerciseName, equals('Incline Dumbbell Press'));
    });

    test('WorkoutProvider starts workout from routine template accurately', () async {
      final mockDb = MockDatabaseServiceForStage7();
      final workoutRepo = WorkoutRepository(mockDb);
      final provider = WorkoutProvider(workoutRepo);

      final template = WorkoutTemplate(
        id: 'tmpl_pull',
        title: 'Pull Power Routine',
        description: 'Heavy back and biceps',
        exercises: [
          const TemplateExercise(
            exerciseId: 'ex_deadlift',
            exerciseName: 'Barbell Deadlift',
            defaultSets: 3,
            targetReps: 5,
            defaultWeightKg: 140.0,
          ),
        ],
        estimatedDurationMinutes: 50,
      );

      await provider.saveTemplate(template);
      expect(provider.templates.length, equals(1));

      // Start workout from template
      provider.startWorkoutFromTemplate(template);
      expect(provider.isWorkoutInProgress, isTrue);
      expect(provider.activeSession, isNotNull);
      expect(provider.activeSession!.title, equals('Pull Power Routine'));
      expect(provider.activeSession!.exercises.length, equals(1));

      final activeEx = provider.activeSession!.exercises.first;
      expect(activeEx.exerciseName, equals('Barbell Deadlift'));
      expect(activeEx.sets.length, equals(3));
      expect(activeEx.sets[0].reps, equals(5));
      expect(activeEx.sets[0].weightKg, equals(140.0));
      expect(activeEx.sets[0].isCompleted, isFalse);

      // Toggle set completion (in-flight check off)
      provider.toggleSetCompleted(0, 0);
      expect(provider.activeSession!.exercises.first.sets[0].isCompleted, isTrue);

      // Remove a set
      provider.removeSetFromExercise(0, 2);
      expect(provider.activeSession!.exercises.first.sets.length, equals(2));

      // Remove entire exercise
      provider.removeExerciseFromActiveWorkout(0);
      expect(provider.activeSession!.exercises.isEmpty, isTrue);

      provider.cancelWorkout();
      expect(provider.isWorkoutInProgress, isFalse);
    });
  });

  group('Stage 7: Full System Backup & Restore Tests', () {
    test('BackupService generates complete JSON and restores all entities round-trip', () async {
      final mockDb = MockDatabaseServiceForStage7();
      final backupService = BackupService();

      // Seed mock data
      await mockDb.saveActivity(
        Activity(
          id: 'act_run',
          name: 'Running',
          target: 5.0,
          unit: ActivityUnit.km,
          category: ActivityCategory.cardio,
          createdAt: DateTime.now(),
        ),
      );

      await mockDb.saveActivityLog(
        ActivityLog(
          id: 'log_run_1',
          activityId: 'act_run',
          dateKey: '2026-11-08',
          value: 6.2,
          isCompleted: true,
        ),
      );

      await mockDb.saveGoal(
        Goal(
          id: 'goal_run_100k',
          name: 'Run 100km this month',
          target: 100.0,
          unit: ActivityUnit.km,
          startDate: DateTime(2026, 11, 1),
          endDate: DateTime(2026, 11, 30),
          createdAt: DateTime.now(),
        ),
      );

      await mockDb.saveDailyNote(
        DailyNote(
          id: 'note_today',
          dateKey: '2026-11-08',
          date: DateTime(2026, 11, 8),
          energyRating: 9,
          moodRating: 8,
          recoveryRating: 8,
          textNotes: 'Crushed my routine today!',
        ),
      );

      await mockDb.saveWorkoutTemplate(
        WorkoutTemplate(
          id: 'tmpl_legs',
          title: 'Leg Day Strength',
          description: 'Squats and lunges',
          exercises: const [
            TemplateExercise(
              exerciseId: 'ex_squat',
              exerciseName: 'Barbell Back Squat',
              defaultSets: 4,
              targetReps: 6,
              defaultWeightKg: 100.0,
            ),
          ],
          estimatedDurationMinutes: 60,
        ),
      );

      await mockDb.saveWeightEntry(
        WeightEntry(
          id: 'wt_1',
          dateKey: '2026-11-08',
          date: DateTime(2026, 11, 8),
          weightKg: 78.5,
        ),
      );

      // Generate full backup JSON
      final jsonString = await backupService.generateBackupJson(mockDb);
      expect(jsonString, isNotEmpty);

      final parsed = jsonDecode(jsonString) as Map<String, dynamic>;
      expect(parsed['appName'], equals('FitTrack'));
      expect(parsed['version'], equals(1));
      expect(parsed.containsKey('data'), isTrue);

      final dataNode = parsed['data'] as Map<String, dynamic>;
      expect((dataNode['activities'] as List).length, equals(1));
      expect((dataNode['activityLogs'] as List).length, equals(1));
      expect((dataNode['goals'] as List).length, equals(1));
      expect((dataNode['dailyNotes'] as List).length, equals(1));
      expect((dataNode['workoutTemplates'] as List).length, equals(1));
      expect((dataNode['weightEntries'] as List).length, equals(1));

      // Wipe the database completely
      await mockDb.clearAllData();
      expect((await mockDb.getAllActivities()).isEmpty, isTrue);
      expect((await mockDb.getAllLogs()).isEmpty, isTrue);
      expect((await mockDb.getAllGoals()).isEmpty, isTrue);
      expect((await mockDb.getAllDailyNotes()).isEmpty, isTrue);
      expect((await mockDb.getAllWorkoutTemplates()).isEmpty, isTrue);
      expect((await mockDb.getAllWeightEntries()).isEmpty, isTrue);

      // Restore from backup JSON
      final restoredCount = await backupService.restoreBackupFromJson(mockDb, jsonString);
      expect(restoredCount, equals(6));

      // Verify restored content matches
      final restoredActivities = await mockDb.getAllActivities();
      expect(restoredActivities.length, equals(1));
      expect(restoredActivities.first.name, equals('Running'));

      final restoredLogs = await mockDb.getAllLogs();
      expect(restoredLogs.length, equals(1));
      expect(restoredLogs.first.value, equals(6.2));

      final restoredGoals = await mockDb.getAllGoals();
      expect(restoredGoals.length, equals(1));
      expect(restoredGoals.first.name, equals('Run 100km this month'));

      final restoredNotes = await mockDb.getAllDailyNotes();
      expect(restoredNotes.length, equals(1));
      expect(restoredNotes.first.textNotes, equals('Crushed my routine today!'));

      final restoredTemplates = await mockDb.getAllWorkoutTemplates();
      expect(restoredTemplates.length, equals(1));
      expect(restoredTemplates.first.title, equals('Leg Day Strength'));

      final restoredWeights = await mockDb.getAllWeightEntries();
      expect(restoredWeights.length, equals(1));
      expect(restoredWeights.first.weightKg, equals(78.5));
    });
  });
}
