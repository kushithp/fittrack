import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/activity_log.dart';
import '../models/water_entry.dart';
import '../models/weight_entry.dart';
import '../models/sleep_entry.dart';
import '../models/workout_session.dart';

/// Exports FitTrack data to CSV files.
/// On mobile/desktop, files are saved to the app's documents directory.
/// On web, this service is a no-op (downloads not supported in this implementation).
class ExportService {
  /// Export activity logs to CSV.
  /// Returns the file path on success, or null on unsupported platform.
  Future<String?> exportActivityLogs(List<ActivityLog> logs) async {
    if (kIsWeb) {
      debugPrint('[ExportService] CSV export not supported on web.');
      return null;
    }

    final rows = [
      // Header row
      ['Date', 'Activity ID', 'Value', 'Is Completed', 'Notes'],
      ...logs.map((l) => [
            l.dateKey,
            l.activityId,
            l.value.toString(),
            l.isCompleted ? 'Yes' : 'No',
            l.notes,
          ]),
    ];

    return _writeFile('activity_logs', rows);
  }

  /// Export weight entries to CSV.
  Future<String?> exportWeightEntries(List<WeightEntry> entries) async {
    if (kIsWeb) return null;

    final rows = [
      ['Date', 'Weight (kg)', 'Notes'],
      ...entries.map((e) => [
            e.dateKey,
            e.weightKg.toStringAsFixed(1),
            e.notes,
          ]),
    ];

    return _writeFile('weight_log', rows);
  }

  /// Export water entries to CSV.
  Future<String?> exportWaterEntries(List<WaterEntry> entries) async {
    if (kIsWeb) return null;

    final rows = [
      ['Date', 'Amount (L)', 'Time'],
      ...entries.map((e) => [
            e.dateKey,
            e.amountLiters.toStringAsFixed(2),
            e.createdAt.toIso8601String(),
          ]),
    ];

    return _writeFile('water_log', rows);
  }

  /// Export sleep entries to CSV.
  Future<String?> exportSleepEntries(List<SleepEntry> entries) async {
    if (kIsWeb) return null;

    final rows = [
      ['Date', 'Sleep Time', 'Wake Time', 'Duration (hrs)', 'Quality'],
      ...entries.map((e) => [
            e.dateKey,
            e.sleepTime.toIso8601String(),
            e.wakeTime.toIso8601String(),
            e.durationHours.toStringAsFixed(1),
            e.quality.toString(),
          ]),
    ];

    return _writeFile('sleep_log', rows);
  }

  /// Export workout sessions to CSV.
  Future<String?> exportWorkouts(List<WorkoutSession> sessions) async {
    if (kIsWeb) return null;

    final rows = <List<dynamic>>[
      ['Date', 'Session Name', 'Exercise', 'Set #', 'Reps', 'Weight (kg)', 'Duration (s)', 'Notes'],
    ];

    for (final session in sessions) {
      for (final exercise in session.exercises) {
        for (var i = 0; i < exercise.sets.length; i++) {
          final s = exercise.sets[i];
          rows.add([
            session.date.toIso8601String().split('T').first,
            session.title,               // 'title' not 'name'
            exercise.exerciseName,
            (i + 1).toString(),
            s.reps.toString(),           // non-nullable int
            s.weightKg.toStringAsFixed(1), // non-nullable double
            s.durationSeconds.toString(), // non-nullable int
            '',                          // WorkoutSet has no notes field
          ]);
        }
      }
    }

    return _writeFile('workout_log', rows);
  }

  // ─── private helper ────────────────────────────────────────────────────────

  Future<String> _writeFile(String baseName, List<List<dynamic>> rows) async {
    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
    final file = File('${dir.path}/fittrack_${baseName}_$timestamp.csv');
    await file.writeAsString(csv);
    debugPrint('[ExportService] Saved: ${file.path}');
    return file.path;
  }
}
