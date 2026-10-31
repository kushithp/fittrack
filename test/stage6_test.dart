import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittrack/data/models/activity.dart';
import 'package:fittrack/data/models/activity_log.dart';
import 'package:fittrack/data/models/daily_note.dart';
import 'package:fittrack/data/models/goal.dart';
import 'package:fittrack/data/models/personal_record.dart';
import 'package:fittrack/data/repositories/activity_repository.dart';
import 'package:fittrack/data/repositories/goal_repository.dart';
import 'package:fittrack/data/repositories/notes_repository.dart';
import 'package:fittrack/data/repositories/reminder_repository.dart';
import 'package:fittrack/data/repositories/workout_repository.dart';
import 'package:fittrack/data/services/notification_service.dart';
import 'package:fittrack/providers/goal_provider.dart';
import 'package:fittrack/providers/notes_provider.dart';
import 'package:fittrack/providers/reminder_provider.dart';
import 'package:fittrack/providers/workout_provider.dart';
import 'package:fittrack/screens/dashboard/widgets/active_goals_spotlight.dart';
import 'package:fittrack/screens/dashboard/widgets/dashboard_quick_hub.dart';
import 'package:fittrack/screens/dashboard/widgets/today_note_spotlight.dart';
import 'package:provider/provider.dart';

import 'activity_repository_test.dart';

void main() {
  group('Stage 6 — Dashboard Hub, PR Tracking & Spotlight Tests', () {
    late MockInMemoryDatabaseService mockDb;
    late ActivityRepository activityRepo;
    late GoalRepository goalRepo;
    late NotesRepository notesRepo;
    late WorkoutRepository workoutRepo;

    setUp(() {
      mockDb = MockInMemoryDatabaseService();
      activityRepo = ActivityRepository(mockDb);
      goalRepo = GoalRepository(mockDb);
      notesRepo = NotesRepository(mockDb);
      workoutRepo = WorkoutRepository(mockDb);
    });

    test('ActivityRepository automatically records PR when new high steps logged', () async {
      final stepsAct = Activity(
        id: 'steps_1',
        name: 'Daily Steps',
        target: 10000,
        unit: ActivityUnit.steps,
        category: ActivityCategory.cardio,
      );
      await mockDb.saveActivity(stepsAct);

      await activityRepo.logActivityProgress(
        activity: stepsAct,
        date: DateTime.now(),
        value: 12500,
      );

      final records = await mockDb.getAllPersonalRecords();
      final stepPr = records.where((r) => r.title == 'Highest Daily Steps');

      expect(stepPr.isNotEmpty, isTrue);
      expect(stepPr.first.recordValue, equals(12500.0));
      expect(stepPr.first.unit, equals('steps'));
      expect(stepPr.first.category, equals(RecordCategory.cardio));
    });

    test('ActivityRepository updates PR when an even higher distance is achieved', () async {
      final distanceAct = Activity(
        id: 'dist_1',
        name: 'Running Distance',
        target: 5.0,
        unit: ActivityUnit.km,
        category: ActivityCategory.cardio,
      );
      await mockDb.saveActivity(distanceAct);

      // First run: 8.5 km
      await activityRepo.logActivityProgress(
        activity: distanceAct,
        date: DateTime.now().subtract(const Duration(days: 1)),
        value: 8.5,
      );

      var records = await mockDb.getAllPersonalRecords();
      var distPr = records.firstWhere((r) => r.title == 'Longest Distance');
      expect(distPr.recordValue, equals(8.5));

      // Second run: 12.0 km beats previous PR
      await activityRepo.logActivityProgress(
        activity: distanceAct,
        date: DateTime.now(),
        value: 12.0,
      );

      records = await mockDb.getAllPersonalRecords();
      distPr = records.firstWhere((r) => r.title == 'Longest Distance');
      expect(distPr.recordValue, equals(12.0));
    });

    test('NotesProvider todayNote accurately returns today\'s reflection', () async {
      final notesProvider = NotesProvider(notesRepo);
      await notesProvider.initialize();

      expect(notesProvider.todayNote, isNull);

      final now = DateTime.now();
      final note = DailyNote(
        id: 'n1',
        dateKey: ActivityLog.formatDateKey(now),
        date: now,
        textNotes: 'Felt energetic and set new bench PR!',
        energyRating: 9,
        moodRating: 9,
        recoveryRating: 8,
        tags: ['bench', 'pr', 'strength'],
      );

      await notesProvider.saveNote(note);

      expect(notesProvider.todayNote, isNotNull);
      expect(notesProvider.todayNote?.textNotes, contains('bench PR'));
      expect(notesProvider.todayNote?.energyRating, equals(9));
    });

    testWidgets('DashboardQuickHub renders navigation shortcuts properly', (tester) async {
      final goalProvider = GoalProvider(goalRepo)..initialize();
      final notesProvider = NotesProvider(notesRepo)..initialize();
      final workoutProvider = WorkoutProvider(workoutRepo)..initialize();
      final reminderProvider =
          ReminderProvider(ReminderRepository(), NotificationService())..loadReminders();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: goalProvider),
                ChangeNotifierProvider.value(value: notesProvider),
                ChangeNotifierProvider.value(value: workoutProvider),
                ChangeNotifierProvider.value(value: reminderProvider),
              ],
              child: const DashboardQuickHub(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Quick Access'), findsOneWidget);
      expect(find.text('Goals'), findsOneWidget);
      expect(find.text('Daily Notes'), findsOneWidget);
      expect(find.text('Records'), findsOneWidget);
      expect(find.text('Reminders'), findsOneWidget);
    });

    testWidgets('ActiveGoalsSpotlight renders goals and empty banner correctly', (tester) async {
      final goalProvider = GoalProvider(goalRepo);
      await goalProvider.initialize();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider.value(
              value: goalProvider,
              child: const ActiveGoalsSpotlight(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Active Goals'), findsOneWidget);
      expect(find.text('No Active Goals'), findsOneWidget);

      // Now add an active goal
      await goalProvider.saveGoal(Goal(
        id: 'g1',
        name: 'Run 50 km this month',
        target: 50.0,
        currentProgress: 22.5,
        unit: ActivityUnit.km,
        timePeriod: GoalTimePeriod.monthly,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider.value(
              value: goalProvider,
              child: const ActiveGoalsSpotlight(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Run 50 km this month'), findsOneWidget);
      expect(find.text('Monthly'), findsOneWidget);
    });

    testWidgets('TodayNoteSpotlight displays note details when logged', (tester) async {
      final notesProvider = NotesProvider(notesRepo);
      await notesProvider.initialize();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider.value(
              value: notesProvider,
              child: const TodayNoteSpotlight(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text("Today's Reflection"), findsOneWidget);
      expect(find.text("No Daily Reflection Yet"), findsOneWidget);

      // Save a note for today
      final now = DateTime.now();
      await notesProvider.saveNote(DailyNote(
        id: 'n2',
        dateKey: ActivityLog.formatDateKey(now),
        date: now,
        textNotes: 'Great chest & triceps workout today.',
        energyRating: 8,
        moodRating: 9,
        recoveryRating: 7,
        tags: ['chest', 'strong'],
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider.value(
              value: notesProvider,
              child: const TodayNoteSpotlight(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Great chest & triceps workout today.'), findsOneWidget);
      expect(find.text('#chest'), findsOneWidget);
      expect(find.text('8/10'), findsOneWidget);
    });
  });
}
