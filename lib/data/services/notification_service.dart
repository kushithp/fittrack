import 'package:flutter/foundation.dart';
// ignore: unused_import
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../models/reminder.dart';

// ---------------------------------------------------------------------------
// NotificationService
//
// This service wraps flutter_local_notifications and provides a clean API
// for scheduling / cancelling reminders.
//
// PLATFORM SETUP REQUIRED (one-time manual steps):
//
// Android:
//   In android/app/src/main/AndroidManifest.xml, inside <manifest>:
//     <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
//     <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
//     <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
//   Inside <application>:
//     <receiver android:exported="false"
//       android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
//       <intent-filter>
//         <action android:name="android.intent.action.BOOT_COMPLETED"/>
//         <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
//       </intent-filter>
//     </receiver>
//
// iOS/macOS:
//   In ios/Runner/AppDelegate.swift, add:
//     UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
//   And request permissions in application(_:didFinishLaunchingWithOptions:).
//
// Web & Desktop (Windows/Linux/macOS):
//   flutter_local_notifications does NOT support web or Windows natively.
//   The service gracefully no-ops on these platforms.
// ---------------------------------------------------------------------------

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Call once at app startup (in main.dart).
  Future<void> initialize() async {
    // Skip on platforms that don't support local notifications.
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) {
      debugPrint('[NotificationService] Platform not supported — skipping init.');
      return;
    }

    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios, macOS: ios);

    await _plugin.initialize(settings);
    _initialized = true;
    debugPrint('[NotificationService] Initialized successfully.');
  }

  /// Schedule (or reschedule) a reminder. Safe to call even if not initialized.
  Future<void> schedule(Reminder reminder) async {
    if (!_initialized || !reminder.isEnabled) return;

    // Use a stable integer id derived from the reminder uuid.
    final notifId = reminder.id.hashCode.abs() % 100000;

    final details = NotificationDetails(
      android: const AndroidNotificationDetails(
        'fittrack_reminders',
        'FitTrack Reminders',
        channelDescription: 'Reminders from FitTrack',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    // Cancel any existing notification for this reminder first.
    await _plugin.cancel(notifId);

    switch (reminder.frequency) {
      case ReminderFrequency.oneTime:
        final scheduledDate = _nextOccurrence(reminder.hour, reminder.minute);
        await _plugin.zonedSchedule(
          notifId,
          reminder.title,
          reminder.body,
          scheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        break;

      case ReminderFrequency.daily:
        await _plugin.zonedSchedule(
          notifId,
          reminder.title,
          reminder.body,
          _nextOccurrence(reminder.hour, reminder.minute),
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
        break;

      case ReminderFrequency.weekly:
        // Schedule one notification per selected weekday.
        for (final weekday in reminder.weekdays) {
          final dayNotifId = (notifId + weekday.isoWeekday) % 100000;
          await _plugin.zonedSchedule(
            dayNotifId,
            reminder.title,
            reminder.body,
            _nextWeekdayOccurrence(reminder.hour, reminder.minute, weekday.isoWeekday),
            details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          );
        }
        break;
    }
    debugPrint('[NotificationService] Scheduled: ${reminder.title} (${reminder.scheduleLabel})');
  }

  /// Cancel all notifications for a reminder.
  Future<void> cancel(Reminder reminder) async {
    if (!_initialized) return;
    final notifId = reminder.id.hashCode.abs() % 100000;
    await _plugin.cancel(notifId);
    // Also cancel any per-weekday notifications.
    for (final weekday in reminder.weekdays) {
      await _plugin.cancel((notifId + weekday.isoWeekday) % 100000);
    }
    debugPrint('[NotificationService] Cancelled: ${reminder.title}');
  }

  /// Cancel ALL scheduled notifications (e.g. on logout / reset).
  Future<void> cancelAll() async {
    if (!_initialized) return;
    await _plugin.cancelAll();
  }

  // --------------- helpers ---------------

  tz.TZDateTime _nextOccurrence(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  tz.TZDateTime _nextWeekdayOccurrence(int hour, int minute, int isoWeekday) {
    var date = _nextOccurrence(hour, minute);
    // Advance until we land on the correct weekday.
    while (date.weekday != isoWeekday) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }
}
