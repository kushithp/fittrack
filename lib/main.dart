import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/activity_repository.dart';
import 'data/repositories/goal_repository.dart';
import 'data/repositories/health_tracking_repository.dart';
import 'data/repositories/notes_repository.dart';
import 'data/repositories/workout_repository.dart';
import 'data/services/database_service.dart';
import 'navigation/main_navigation.dart';
import 'providers/activity_provider.dart';
import 'providers/goal_provider.dart';
import 'providers/health_tracking_provider.dart';
import 'providers/notes_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/workout_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Local Database Service
  final dbService = LocalDatabaseService();
  await dbService.init();

  // Initialize Repositories
  final activityRepository = ActivityRepository(dbService);
  final goalRepository = GoalRepository(dbService);
  final notesRepository = NotesRepository(dbService);
  final healthRepository = HealthTrackingRepository(dbService);
  final workoutRepository = WorkoutRepository(dbService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(dbService)..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => ActivityProvider(activityRepository, dbService)..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => GoalProvider(goalRepository)..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => NotesProvider(notesRepository)..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => HealthTrackingProvider(healthRepository)..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => WorkoutProvider(workoutRepository)..initialize(),
        ),
      ],
      child: const FitTrackApp(),
    ),
  );
}

class FitTrackApp extends StatelessWidget {
  const FitTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'FitTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.flutterThemeMode,
      home: const MainNavigation(),
    );
  }
}
