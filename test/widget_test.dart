import 'package:flutter_test/flutter_test.dart';
import 'package:fittrack/main.dart';
import 'package:fittrack/data/repositories/activity_repository.dart';
import 'package:fittrack/data/repositories/goal_repository.dart';
import 'package:fittrack/data/repositories/health_tracking_repository.dart';
import 'package:fittrack/data/repositories/notes_repository.dart';
import 'package:fittrack/data/repositories/workout_repository.dart';
import 'package:fittrack/providers/activity_provider.dart';
import 'package:fittrack/providers/goal_provider.dart';
import 'package:fittrack/providers/health_tracking_provider.dart';
import 'package:fittrack/providers/notes_provider.dart';
import 'package:fittrack/providers/theme_provider.dart';
import 'package:fittrack/providers/workout_provider.dart';
import 'package:provider/provider.dart';
import 'activity_repository_test.dart';

void main() {
  testWidgets('FitTrackApp renders main navigation correctly', (WidgetTester tester) async {
    final mockDb = MockInMemoryDatabaseService();
    final activityRepo = ActivityRepository(mockDb);
    final goalRepo = GoalRepository(mockDb);
    final notesRepo = NotesRepository(mockDb);
    final healthRepo = HealthTrackingRepository(mockDb);
    final workoutRepo = WorkoutRepository(mockDb);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => ThemeProvider(mockDb)..initialize(),
          ),
          ChangeNotifierProvider(
            create: (_) => ActivityProvider(activityRepo, mockDb)..initialize(),
          ),
          ChangeNotifierProvider(
            create: (_) => GoalProvider(goalRepo)..initialize(),
          ),
          ChangeNotifierProvider(
            create: (_) => NotesProvider(notesRepo)..initialize(),
          ),
          ChangeNotifierProvider(
            create: (_) => HealthTrackingProvider(healthRepo)..initialize(),
          ),
          ChangeNotifierProvider(
            create: (_) => WorkoutProvider(workoutRepo)..initialize(),
          ),
        ],
        child: const FitTrackApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify main app title / greeting
    expect(find.textContaining('Good'), findsOneWidget);
    expect(find.text("Today's Progress"), findsOneWidget);
  });
}
