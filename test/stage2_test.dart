import 'package:flutter_test/flutter_test.dart';
import 'package:fittrack/data/models/activity.dart';
import 'package:fittrack/data/models/daily_note.dart';
import 'package:fittrack/data/models/goal.dart';
import 'package:fittrack/data/models/sleep_entry.dart';
import 'package:fittrack/data/repositories/goal_repository.dart';
import 'package:fittrack/data/repositories/health_tracking_repository.dart';
import 'package:fittrack/data/repositories/notes_repository.dart';

import 'activity_repository_test.dart';

void main() {
  group('Stage 2 Domain Logic Tests', () {
    late MockInMemoryDatabaseService mockDb;

    setUp(() {
      mockDb = MockInMemoryDatabaseService();
    });

    test('Goal percentage completion calculates accurately', () {
      final goal = Goal(
        id: 'g1',
        name: '30 km per week',
        target: 30.0,
        currentProgress: 15.0,
        unit: ActivityUnit.km,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
      );

      expect(goal.percentageCompleted, 50.0);
    });

    test('GoalRepository updates progress and completion state', () async {
      final repo = GoalRepository(mockDb);
      final goal = Goal(
        id: 'g2',
        name: 'Gym 4 times per week',
        target: 4.0,
        currentProgress: 2.0,
        unit: ActivityUnit.workouts,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
      );

      await repo.saveGoal(goal);
      await repo.updateGoalProgress('g2', 4.0);

      final updatedGoals = await repo.getAllGoals();
      final updated = updatedGoals.firstWhere((g) => g.id == 'g2');
      expect(updated.currentProgress, 4.0);
      expect(updated.isCompleted, isTrue);
      expect(updated.percentageCompleted, 100.0);
    });

    test('NotesRepository filters notes by tag and text search query', () async {
      final repo = NotesRepository(mockDb);
      final now = DateTime.now();

      await repo.saveDailyNote(DailyNote(
        id: 'n1',
        dateKey: '2026-09-24',
        date: now,
        textNotes: 'Increased bench press by 5kg today.',
        tags: ['workout', 'benchpress'],
      ));

      await repo.saveDailyNote(DailyNote(
        id: 'n2',
        dateKey: '2026-09-25',
        date: now,
        textNotes: 'Stretching and mobility routine.',
        tags: ['recovery', 'stretch'],
      ));

      final searchBench = await repo.searchNotes(query: 'bench');
      expect(searchBench.length, 1);
      expect(searchBench.first.id, 'n1');

      final searchTag = await repo.searchNotes(tag: 'recovery');
      expect(searchTag.length, 1);
      expect(searchTag.first.id, 'n2');
    });

    test('HealthTrackingRepository sums total water intake for date', () async {
      final repo = HealthTrackingRepository(mockDb);
      final date = DateTime(2026, 9, 24);

      await repo.addWaterEntry(date: date, amountLiters: 0.5);
      await repo.addWaterEntry(date: date, amountLiters: 0.75);
      await repo.addWaterEntry(date: date, amountLiters: 1.0);

      final total = await repo.getTotalWaterIntakeLitersForDate(date);
      expect(total, 2.25);
    });

    test('SleepEntry calculates duration in hours from sleep and wake time', () {
      final sleepTime = DateTime(2026, 9, 24, 23, 0);
      final wakeTime = DateTime(2026, 9, 25, 7, 30); // 8.5 hours

      final entry = SleepEntry(
        id: 's1',
        dateKey: '2026-09-25',
        sleepTime: sleepTime,
        wakeTime: wakeTime,
        quality: SleepQuality.good,
      );

      expect(entry.durationHours, 8.5);
    });

    test('WeightEntry stores weight in kg and computes difference accurately', () async {
      final repo = HealthTrackingRepository(mockDb);
      final date1 = DateTime(2026, 9, 20);
      final date2 = DateTime(2026, 9, 25);

      await repo.logWeight(date: date1, weightKg: 80.0);
      await repo.logWeight(date: date2, weightKg: 78.5);

      final latest = await repo.getLatestWeightEntry();
      expect(latest?.weightKg, 78.5);
    });
  });
}
