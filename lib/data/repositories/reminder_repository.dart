import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder.dart';

/// Repository for storing and retrieving reminders via SharedPreferences.
/// Each reminder is stored as JSON in a list under a single key.
class ReminderRepository {
  static const _key = 'fittrack_reminders';

  /// Load all reminders from storage.
  Future<List<Reminder>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((s) => Reminder.fromJson(jsonDecode(s) as Map<String, dynamic>)).toList()
      ..sort((a, b) => a.hour != b.hour ? a.hour.compareTo(b.hour) : a.minute.compareTo(b.minute));
  }

  /// Save (add or replace) a single reminder.
  Future<void> save(Reminder reminder) async {
    final all = await getAll();
    final index = all.indexWhere((r) => r.id == reminder.id);
    if (index >= 0) {
      all[index] = reminder;
    } else {
      all.add(reminder);
    }
    await _persist(all);
  }

  /// Delete a reminder by id.
  Future<void> delete(String id) async {
    final all = await getAll();
    all.removeWhere((r) => r.id == id);
    await _persist(all);
  }

  /// Toggle enabled/disabled state.
  Future<Reminder> toggleEnabled(String id) async {
    final all = await getAll();
    final index = all.indexWhere((r) => r.id == id);
    if (index < 0) throw StateError('Reminder $id not found');
    final updated = all[index].copyWith(isEnabled: !all[index].isEnabled);
    all[index] = updated;
    await _persist(all);
    return updated;
  }

  Future<void> _persist(List<Reminder> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, reminders.map((r) => jsonEncode(r.toJson())).toList());
  }
}
