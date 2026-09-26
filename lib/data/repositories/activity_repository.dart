import 'package:uuid/uuid.dart';
import '../models/activity.dart';
import '../models/activity_log.dart';
import '../services/database_service.dart';

class ActivityRepository {
  final IDatabaseService _db;
  final Uuid _uuid = const Uuid();

  ActivityRepository(this._db);

  /// Fetch all configured activities
  Future<List<Activity>> getAllActivities() async {
    return await _db.getAllActivities();
  }

  /// Create or update an activity definition
  Future<Activity> saveActivity(Activity activity) async {
    final activityToSave = activity.id.isEmpty
        ? activity.copyWith(id: _uuid.v4(), createdAt: DateTime.now())
        : activity.copyWith(updatedAt: DateTime.now());
    
    await _db.saveActivity(activityToSave);
    return activityToSave;
  }

  /// Delete activity by ID
  Future<void> deleteActivity(String id) async {
    await _db.deleteActivity(id);
  }

  /// Fetch logs for a specific date (formatted "yyyy-MM-dd")
  Future<List<ActivityLog>> getLogsForDate(DateTime date) async {
    final dateKey = ActivityLog.formatDateKey(date);
    return await _db.getLogsForDate(dateKey);
  }

  /// Log or update progress for a specific activity on a given date
  Future<ActivityLog> logActivityProgress({
    required Activity activity,
    required DateTime date,
    required double value,
    String? notes,
    bool? overrideCompleted,
  }) async {
    final dateKey = ActivityLog.formatDateKey(date);
    final existingLogs = await _db.getLogsForDate(dateKey);
    final existing = existingLogs.firstWhere(
      (l) => l.activityId == activity.id,
      orElse: () => ActivityLog(
        id: _uuid.v4(),
        activityId: activity.id,
        dateKey: dateKey,
        value: 0.0,
        isCompleted: false,
      ),
    );

    // Calculate completion: checkbox uses completed status; numeric checks value >= target
    final isCompleted = overrideCompleted ??
        (activity.unit == ActivityUnit.checkbox
            ? value > 0
            : value >= activity.target);

    final updatedLog = existing.copyWith(
      value: value,
      isCompleted: isCompleted,
      notes: notes ?? existing.notes,
      updatedAt: DateTime.now(),
    );

    await _db.saveActivityLog(updatedLog);
    return updatedLog;
  }

  /// Toggle checkbox completion status for an activity
  Future<ActivityLog> toggleActivityChecklist({
    required Activity activity,
    required DateTime date,
  }) async {
    final dateKey = ActivityLog.formatDateKey(date);
    final existingLogs = await _db.getLogsForDate(dateKey);
    final existing = existingLogs.firstWhere(
      (l) => l.activityId == activity.id,
      orElse: () => ActivityLog(
        id: _uuid.v4(),
        activityId: activity.id,
        dateKey: dateKey,
        value: 0.0,
        isCompleted: false,
      ),
    );

    final nextStatus = !existing.isCompleted;
    final nextValue = nextStatus ? (activity.target > 0 ? activity.target : 1.0) : 0.0;

    final updatedLog = existing.copyWith(
      value: nextValue,
      isCompleted: nextStatus,
      updatedAt: DateTime.now(),
    );

    await _db.saveActivityLog(updatedLog);
    return updatedLog;
  }

  /// Calculate daily score and completion percentage for a given date.
  /// Score considers activities where [contributesToDailyScore] is true and activity is enabled.
  Future<double> calculateDailyCompletionPercentage(DateTime date) async {
    final activities = await getAllActivities();
    final enabledActivities = activities.where((a) => a.isEnabled && a.contributesToDailyScore).toList();
    if (enabledActivities.isEmpty) return 0.0;

    final logs = await getLogsForDate(date);
    double totalProgress = 0.0;

    for (final act in enabledActivities) {
      final log = logs.firstWhere(
        (l) => l.activityId == act.id,
        orElse: () => ActivityLog(
          id: '',
          activityId: act.id,
          dateKey: ActivityLog.formatDateKey(date),
          value: 0,
          isCompleted: false,
        ),
      );

      if (act.unit == ActivityUnit.checkbox) {
        if (log.isCompleted) totalProgress += 1.0;
      } else if (act.target > 0) {
        final ratio = (log.value / act.target).clamp(0.0, 1.0);
        totalProgress += ratio;
      }
    }

    return (totalProgress / enabledActivities.length) * 100.0;
  }
}
