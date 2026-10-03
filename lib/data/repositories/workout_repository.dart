import 'package:uuid/uuid.dart';
import '../models/exercise.dart';
import '../models/personal_record.dart';
import '../models/workout_session.dart';
import '../services/database_service.dart';

class WorkoutRepository {
  final IDatabaseService _db;
  final Uuid _uuid = const Uuid();

  WorkoutRepository(this._db);

  // --- Exercises Library ---
  Future<List<Exercise>> getAllExercises() async {
    return await _db.getAllExercises();
  }

  Future<Exercise> saveExercise(Exercise exercise) async {
    final toSave = exercise.id.isEmpty
        ? exercise.copyWith(id: _uuid.v4(), createdAt: DateTime.now())
        : exercise;
    await _db.saveExercise(toSave);
    return toSave;
  }

  Future<void> deleteExercise(String id) async {
    await _db.deleteExercise(id);
  }

  // --- Workout Sessions ---
  Future<List<WorkoutSession>> getAllWorkoutSessions() async {
    return await _db.getAllWorkoutSessions();
  }

  Future<WorkoutSession> saveWorkoutSession(WorkoutSession session) async {
    final toSave = session.id.isEmpty
        ? session.copyWith(id: _uuid.v4(), createdAt: DateTime.now())
        : session.copyWith(updatedAt: DateTime.now());

    await _db.saveWorkoutSession(toSave);
    await checkAndUpdatePersonalRecords(toSave);
    return toSave;
  }

  Future<void> deleteWorkoutSession(String id) async {
    await _db.deleteWorkoutSession(id);
  }

  // --- Personal Records ---
  Future<List<PersonalRecord>> getAllPersonalRecords() async {
    return await _db.getAllPersonalRecords();
  }

  /// Evaluates completed workout session for new Personal Records
  Future<void> checkAndUpdatePersonalRecords(WorkoutSession session) async {
    final existingRecords = await _db.getAllPersonalRecords();

    for (final exercise in session.exercises) {
      final maxWeight = exercise.maxWeightKg;
      if (maxWeight <= 0) continue;

      final prTitle = 'Heaviest ${exercise.exerciseName}';
      final existingIndex = existingRecords.indexWhere((r) => r.title == prTitle);

      if (existingIndex >= 0) {
        final currentPr = existingRecords[existingIndex];
        if (maxWeight > currentPr.recordValue) {
          final updatedPr = PersonalRecord(
            id: currentPr.id,
            title: prTitle,
            recordValue: maxWeight,
            unit: 'kg',
            date: session.date,
            category: RecordCategory.exercise,
            exerciseName: exercise.exerciseName,
          );
          await _db.savePersonalRecord(updatedPr);
        }
      } else {
        final newPr = PersonalRecord(
          id: _uuid.v4(),
          title: prTitle,
          recordValue: maxWeight,
          unit: 'kg',
          date: session.date,
          category: RecordCategory.exercise,
          exerciseName: exercise.exerciseName,
        );
        await _db.savePersonalRecord(newPr);
      }
    }

    // Longest Workout PR
    const durationTitle = 'Longest Workout Session';
    final durationPr = existingRecords.firstWhere(
      (r) => r.title == durationTitle,
      orElse: () => PersonalRecord(
        id: '',
        title: durationTitle,
        recordValue: 0,
        unit: 'min',
        date: session.date,
        category: RecordCategory.workout,
      ),
    );

    if (session.durationMinutes > durationPr.recordValue) {
      await _db.savePersonalRecord(PersonalRecord(
        id: durationPr.id.isEmpty ? _uuid.v4() : durationPr.id,
        title: durationTitle,
        recordValue: session.durationMinutes.toDouble(),
        unit: 'min',
        date: session.date,
        category: RecordCategory.workout,
      ));
    }
  }
}
