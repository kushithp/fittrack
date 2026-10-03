import 'package:flutter_test/flutter_test.dart';
import 'package:fittrack/data/models/exercise.dart';
import 'package:fittrack/data/models/workout_exercise.dart';
import 'package:fittrack/data/models/workout_session.dart';
import 'package:fittrack/data/models/workout_set.dart';
import 'package:fittrack/data/repositories/workout_repository.dart';

import 'activity_repository_test.dart';

void main() {
  group('Stage 3 Workout & Personal Record Tests', () {
    late MockInMemoryDatabaseService mockDb;

    setUp(() {
      mockDb = MockInMemoryDatabaseService();
    });

    test('WorkoutExercise calculates max weight and total volume correctly', () {
      final ex = WorkoutExercise(
        exerciseId: 'e1',
        exerciseName: 'Bench Press',
        category: ExerciseCategory.chest,
        sets: [
          WorkoutSet(setNumber: 1, weightKg: 60.0, reps: 10), // 600 kg
          WorkoutSet(setNumber: 2, weightKg: 60.0, reps: 8),  // 480 kg
          WorkoutSet(setNumber: 3, weightKg: 65.0, reps: 6),  // 390 kg
        ],
      );

      expect(ex.maxWeightKg, 65.0);
      expect(ex.totalVolumeKg, 1470.0);
    });

    test('WorkoutSession calculates total volume and total sets across exercises', () {
      final session = WorkoutSession(
        id: 's1',
        title: 'CHEST + TRICEPS',
        date: DateTime.now(),
        durationMinutes: 45,
        exercises: [
          WorkoutExercise(
            exerciseId: 'e1',
            exerciseName: 'Bench Press',
            category: ExerciseCategory.chest,
            sets: [
              WorkoutSet(setNumber: 1, weightKg: 60.0, reps: 10),
              WorkoutSet(setNumber: 2, weightKg: 65.0, reps: 6),
            ],
          ),
          WorkoutExercise(
            exerciseId: 'e2',
            exerciseName: 'Cable Fly',
            category: ExerciseCategory.chest,
            sets: [
              WorkoutSet(setNumber: 1, weightKg: 15.0, reps: 12),
            ],
          ),
        ],
      );

      expect(session.totalSets, 3);
      expect(session.totalVolumeKg, (60.0 * 10) + (65.0 * 6) + (15.0 * 12));
    });

    test('WorkoutRepository automatically creates Personal Record when max weight is set', () async {
      final repo = WorkoutRepository(mockDb);
      final session = WorkoutSession(
        id: 's2',
        title: 'Heavy Chest Day',
        date: DateTime.now(),
        durationMinutes: 50,
        exercises: [
          WorkoutExercise(
            exerciseId: 'e1',
            exerciseName: 'Bench Press',
            category: ExerciseCategory.chest,
            sets: [
              WorkoutSet(setNumber: 1, weightKg: 100.0, reps: 5),
            ],
          ),
        ],
      );

      await repo.saveWorkoutSession(session);

      final prs = await repo.getAllPersonalRecords();
      final benchPr = prs.firstWhere((r) => r.title == 'Heaviest Bench Press');

      expect(benchPr.recordValue, 100.0);
      expect(benchPr.unit, 'kg');
      expect(benchPr.exerciseName, 'Bench Press');
    });

    test('WorkoutRepository updates Personal Record if new max weight beats old PR', () async {
      final repo = WorkoutRepository(mockDb);

      // Session 1 with 80kg bench
      await repo.saveWorkoutSession(WorkoutSession(
        id: 's1',
        title: 'Bench 1',
        date: DateTime.now(),
        exercises: [
          WorkoutExercise(
            exerciseId: 'e1',
            exerciseName: 'Bench Press',
            category: ExerciseCategory.chest,
            sets: [WorkoutSet(setNumber: 1, weightKg: 80.0, reps: 5)],
          ),
        ],
      ));

      // Session 2 with 90kg bench
      await repo.saveWorkoutSession(WorkoutSession(
        id: 's2',
        title: 'Bench 2',
        date: DateTime.now(),
        exercises: [
          WorkoutExercise(
            exerciseId: 'e1',
            exerciseName: 'Bench Press',
            category: ExerciseCategory.chest,
            sets: [WorkoutSet(setNumber: 1, weightKg: 90.0, reps: 5)],
          ),
        ],
      ));

      final prs = await repo.getAllPersonalRecords();
      final benchPr = prs.firstWhere((r) => r.title == 'Heaviest Bench Press');

      expect(benchPr.recordValue, 90.0);
    });
  });
}
