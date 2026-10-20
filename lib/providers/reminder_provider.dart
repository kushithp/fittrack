import 'package:flutter/foundation.dart';
import '../data/models/reminder.dart';
import '../data/repositories/reminder_repository.dart';
import '../data/services/notification_service.dart';

/// Manages reminder state and coordinates with NotificationService.
class ReminderProvider extends ChangeNotifier {
  final ReminderRepository _repo;
  final NotificationService _notifications;

  List<Reminder> _reminders = [];
  bool _loading = false;
  String? _error;

  ReminderProvider(this._repo, this._notifications);

  List<Reminder> get reminders => List.unmodifiable(_reminders);
  bool get isLoading => _loading;
  String? get error => _error;

  List<Reminder> get enabledReminders => _reminders.where((r) => r.isEnabled).toList();

  /// Load all reminders from storage.
  Future<void> loadReminders() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _reminders = await _repo.getAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Add a new reminder and schedule its notification.
  Future<void> addReminder(Reminder reminder) async {
    await _repo.save(reminder);
    await _notifications.schedule(reminder);
    await loadReminders();
  }

  /// Update an existing reminder and reschedule.
  Future<void> updateReminder(Reminder reminder) async {
    await _notifications.cancel(reminder);
    await _repo.save(reminder);
    if (reminder.isEnabled) {
      await _notifications.schedule(reminder);
    }
    await loadReminders();
  }

  /// Delete a reminder and cancel its notification.
  Future<void> deleteReminder(String id) async {
    final reminder = _reminders.firstWhere((r) => r.id == id, orElse: () => throw StateError('Not found'));
    await _notifications.cancel(reminder);
    await _repo.delete(id);
    await loadReminders();
  }

  /// Toggle enabled state and reschedule or cancel accordingly.
  Future<void> toggleReminder(String id) async {
    final updated = await _repo.toggleEnabled(id);
    if (updated.isEnabled) {
      await _notifications.schedule(updated);
    } else {
      await _notifications.cancel(updated);
    }
    await loadReminders();
  }
}
