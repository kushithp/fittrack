import 'package:uuid/uuid.dart';
import '../models/activity_log.dart';
import '../models/sleep_entry.dart';
import '../models/water_entry.dart';
import '../models/weight_entry.dart';
import '../services/database_service.dart';

class HealthTrackingRepository {
  final IDatabaseService _db;
  final Uuid _uuid = const Uuid();

  HealthTrackingRepository(this._db);

  // --- Water ---
  Future<List<WaterEntry>> getWaterEntriesForDate(DateTime date) async {
    final dateKey = ActivityLog.formatDateKey(date);
    return await _db.getWaterEntriesForDate(dateKey);
  }

  Future<double> getTotalWaterIntakeLitersForDate(DateTime date) async {
    final entries = await getWaterEntriesForDate(date);
    return entries.fold<double>(0.0, (double sum, entry) => sum + entry.amountLiters);
  }

  Future<WaterEntry> addWaterEntry({
    required DateTime date,
    required double amountLiters,
  }) async {
    final dateKey = ActivityLog.formatDateKey(date);
    final entry = WaterEntry(
      id: _uuid.v4(),
      dateKey: dateKey,
      date: date,
      amountLiters: amountLiters,
    );
    await _db.saveWaterEntry(entry);
    return entry;
  }

  Future<void> deleteWaterEntry(String id) async {
    await _db.deleteWaterEntry(id);
  }

  // --- Weight ---
  Future<List<WeightEntry>> getAllWeightEntries() async {
    return await _db.getAllWeightEntries();
  }

  Future<WeightEntry?> getLatestWeightEntry() async {
    final entries = await getAllWeightEntries();
    return entries.isNotEmpty ? entries.first : null;
  }

  Future<WeightEntry> logWeight({
    required DateTime date,
    required double weightKg,
    String notes = '',
  }) async {
    final dateKey = ActivityLog.formatDateKey(date);
    final entry = WeightEntry(
      id: _uuid.v4(),
      dateKey: dateKey,
      date: date,
      weightKg: weightKg,
      notes: notes,
    );
    await _db.saveWeightEntry(entry);
    return entry;
  }

  Future<void> deleteWeightEntry(String id) async {
    await _db.deleteWeightEntry(id);
  }

  // --- Sleep ---
  Future<List<SleepEntry>> getAllSleepEntries() async {
    return await _db.getAllSleepEntries();
  }

  Future<SleepEntry?> getSleepEntryForDate(DateTime date) async {
    final dateKey = ActivityLog.formatDateKey(date);
    return await _db.getSleepEntryForDate(dateKey);
  }

  Future<SleepEntry> logSleep({
    required DateTime date,
    required DateTime sleepTime,
    required DateTime wakeTime,
    SleepQuality quality = SleepQuality.good,
    String notes = '',
  }) async {
    final dateKey = ActivityLog.formatDateKey(date);
    final entry = SleepEntry(
      id: _uuid.v4(),
      dateKey: dateKey,
      sleepTime: sleepTime,
      wakeTime: wakeTime,
      quality: quality,
      notes: notes,
    );
    await _db.saveSleepEntry(entry);
    return entry;
  }

  Future<void> deleteSleepEntry(String id) async {
    await _db.deleteSleepEntry(id);
  }
}
