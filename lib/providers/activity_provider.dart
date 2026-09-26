import 'package:flutter/foundation.dart';
import '../data/models/activity.dart';
import '../data/models/activity_log.dart';
import '../data/repositories/activity_repository.dart';
import '../data/services/database_service.dart';
import '../data/services/demo_data_service.dart';

class ActivityProvider extends ChangeNotifier {
  final ActivityRepository _repository;
  final IDatabaseService _db;

  List<Activity> _activities = [];
  Map<String, ActivityLog> _todayLogsMap = {};
  DateTime _selectedDate = DateTime.now();
  double _todayCompletionPercentage = 0.0;
  bool _isLoading = false;
  String? _errorMessage;

  ActivityProvider(this._repository, this._db);

  List<Activity> get activities => _activities;
  List<Activity> get enabledActivities => _activities.where((a) => a.isEnabled).toList();
  List<Activity> get checklistActivities => _activities.where((a) => a.isEnabled && a.isDailyChecklist).toList();
  DateTime get selectedDate => _selectedDate;
  double get todayCompletionPercentage => _todayCompletionPercentage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ActivityLog? getLogForActivity(String activityId) {
    return _todayLogsMap[activityId];
  }

  /// Initialize and load activities and logs from local database
  Future<void> initialize() async {
    _setLoading(true);
    try {
      var loaded = await _repository.getAllActivities();
      
      // If database is empty on first boot, populate initial demo data
      if (loaded.isEmpty) {
        await DemoDataService.populateDemoData(_db);
        final settings = await _db.getUserSettings();
        await _db.saveUserSettings(settings.copyWith(hasLoadedDemoData: true));
        loaded = await _repository.getAllActivities();
      }

      _activities = loaded;
      await loadLogsForSelectedDate();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load activities: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Change selected date (defaults to today)
  Future<void> setSelectedDate(DateTime date) async {
    _selectedDate = date;
    await loadLogsForSelectedDate();
  }

  /// Load logs for the active selected date
  Future<void> loadLogsForSelectedDate() async {
    final logs = await _repository.getLogsForDate(_selectedDate);
    _todayLogsMap = {for (var log in logs) log.activityId: log};
    _todayCompletionPercentage = await _repository.calculateDailyCompletionPercentage(_selectedDate);
    notifyListeners();
  }

  /// Add or Edit an Activity definition
  Future<void> saveActivity(Activity activity) async {
    _setLoading(true);
    try {
      final saved = await _repository.saveActivity(activity);
      final index = _activities.indexWhere((a) => a.id == saved.id);
      if (index >= 0) {
        _activities[index] = saved;
      } else {
        _activities.add(saved);
      }
      await loadLogsForSelectedDate();
    } catch (e) {
      _errorMessage = 'Failed to save activity: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Delete an activity
  Future<void> deleteActivity(String id) async {
    _setLoading(true);
    try {
      await _repository.deleteActivity(id);
      _activities.removeWhere((a) => a.id == id);
      _todayLogsMap.remove(id);
      await loadLogsForSelectedDate();
    } catch (e) {
      _errorMessage = 'Failed to delete activity: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Toggle checkbox status for an activity
  Future<void> toggleChecklist(Activity activity) async {
    try {
      final updatedLog = await _repository.toggleActivityChecklist(
        activity: activity,
        date: _selectedDate,
      );
      _todayLogsMap[activity.id] = updatedLog;
      _todayCompletionPercentage = await _repository.calculateDailyCompletionPercentage(_selectedDate);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update progress: $e';
      notifyListeners();
    }
  }

  /// Update numeric progress value for an activity
  Future<void> updateProgressValue(Activity activity, double newValue, {String? notes}) async {
    try {
      final updatedLog = await _repository.logActivityProgress(
        activity: activity,
        date: _selectedDate,
        value: newValue,
        notes: notes,
      );
      _todayLogsMap[activity.id] = updatedLog;
      _todayCompletionPercentage = await _repository.calculateDailyCompletionPercentage(_selectedDate);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to log progress: $e';
      notifyListeners();
    }
  }

  /// Reload demo data on demand
  Future<void> resetDemoData() async {
    _setLoading(true);
    try {
      await _db.clearAllData();
      await DemoDataService.populateDemoData(_db);
      _activities = await _repository.getAllActivities();
      await loadLogsForSelectedDate();
    } catch (e) {
      _errorMessage = 'Failed to reset demo data: $e';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
