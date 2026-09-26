import 'package:flutter/foundation.dart';
import '../data/models/sleep_entry.dart';
import '../data/models/water_entry.dart';
import '../data/models/weight_entry.dart';
import '../data/repositories/health_tracking_repository.dart';

class HealthTrackingProvider extends ChangeNotifier {
  final HealthTrackingRepository _repository;

  List<WaterEntry> _todayWaterEntries = [];
  double _todayWaterTotalLiters = 0.0;
  double _dailyWaterTargetLiters = 3.0;

  List<WeightEntry> _weightEntries = [];
  double _targetWeightKg = 75.0;
  WeightGoalType _weightGoalType = WeightGoalType.lose;

  List<SleepEntry> _sleepEntries = [];
  SleepEntry? _todaySleepEntry;
  double _dailySleepTargetHours = 8.0;

  bool _isLoading = false;
  String? _errorMessage;

  HealthTrackingProvider(this._repository);

  // Getters
  List<WaterEntry> get todayWaterEntries => _todayWaterEntries;
  double get todayWaterTotalLiters => _todayWaterTotalLiters;
  double get dailyWaterTargetLiters => _dailyWaterTargetLiters;
  double get waterCompletionPercentage =>
      _dailyWaterTargetLiters > 0 ? (_todayWaterTotalLiters / _dailyWaterTargetLiters * 100.0).clamp(0.0, 100.0) : 0.0;

  List<WeightEntry> get weightEntries => _weightEntries;
  WeightEntry? get latestWeightEntry => _weightEntries.isNotEmpty ? _weightEntries.first : null;
  WeightEntry? get startingWeightEntry => _weightEntries.isNotEmpty ? _weightEntries.last : null;
  double get targetWeightKg => _targetWeightKg;
  WeightGoalType get weightGoalType => _weightGoalType;

  List<SleepEntry> get sleepEntries => _sleepEntries;
  SleepEntry? get todaySleepEntry => _todaySleepEntry;
  double get dailySleepTargetHours => _dailySleepTargetHours;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    _setLoading(true);
    try {
      await loadTodayHealthData();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load health tracking data: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadTodayHealthData() async {
    final now = DateTime.now();
    _todayWaterEntries = await _repository.getWaterEntriesForDate(now);
    _todayWaterTotalLiters = await _repository.getTotalWaterIntakeLitersForDate(now);

    _weightEntries = await _repository.getAllWeightEntries();
    _sleepEntries = await _repository.getAllSleepEntries();
    _todaySleepEntry = await _repository.getSleepEntryForDate(now);

    notifyListeners();
  }

  // --- Water Methods ---
  Future<void> addWater(double amountLiters) async {
    try {
      await _repository.addWaterEntry(
        date: DateTime.now(),
        amountLiters: amountLiters,
      );
      await loadTodayHealthData();
    } catch (e) {
      _errorMessage = 'Failed to log water: $e';
      notifyListeners();
    }
  }

  Future<void> deleteWaterEntry(String id) async {
    try {
      await _repository.deleteWaterEntry(id);
      await loadTodayHealthData();
    } catch (e) {
      _errorMessage = 'Failed to delete water log: $e';
      notifyListeners();
    }
  }

  void setWaterTarget(double targetLiters) {
    _dailyWaterTargetLiters = targetLiters;
    notifyListeners();
  }

  // --- Weight Methods ---
  Future<void> logWeight(double weightKg, {String notes = ''}) async {
    try {
      await _repository.logWeight(
        date: DateTime.now(),
        weightKg: weightKg,
        notes: notes,
      );
      await loadTodayHealthData();
    } catch (e) {
      _errorMessage = 'Failed to log weight: $e';
      notifyListeners();
    }
  }

  Future<void> deleteWeightEntry(String id) async {
    try {
      await _repository.deleteWeightEntry(id);
      await loadTodayHealthData();
    } catch (e) {
      _errorMessage = 'Failed to delete weight entry: $e';
      notifyListeners();
    }
  }

  void setWeightTarget(double targetKg, WeightGoalType goalType) {
    _targetWeightKg = targetKg;
    _weightGoalType = goalType;
    notifyListeners();
  }

  // --- Sleep Methods ---
  Future<void> logSleep({
    required DateTime sleepTime,
    required DateTime wakeTime,
    SleepQuality quality = SleepQuality.good,
    String notes = '',
  }) async {
    try {
      await _repository.logSleep(
        date: DateTime.now(),
        sleepTime: sleepTime,
        wakeTime: wakeTime,
        quality: quality,
        notes: notes,
      );
      await loadTodayHealthData();
    } catch (e) {
      _errorMessage = 'Failed to log sleep: $e';
      notifyListeners();
    }
  }

  Future<void> deleteSleepEntry(String id) async {
    try {
      await _repository.deleteSleepEntry(id);
      await loadTodayHealthData();
    } catch (e) {
      _errorMessage = 'Failed to delete sleep entry: $e';
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
