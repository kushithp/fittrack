import 'package:flutter_test/flutter_test.dart';
import 'package:fittrack/data/models/reminder.dart';

void main() {
  group('Stage 5 — Reminders & Notifications Tests', () {
    // ── Reminder Model ───────────────────────────────────────────────────────

    test('Reminder.create assigns a unique id and defaults isEnabled=true', () {
      final r = Reminder.create(title: 'Drink Water', hour: 8, minute: 0);
      expect(r.id, isNotEmpty);
      expect(r.isEnabled, isTrue);
      expect(r.title, equals('Drink Water'));
    });

    test('Reminder timeLabel formats hour and minute with padding', () {
      final r = Reminder.create(title: 'Gym', hour: 6, minute: 5);
      expect(r.timeLabel, equals('06:05'));
    });

    test('Daily reminder produces correct scheduleLabel', () {
      final r = Reminder.create(
        title: 'Stretch',
        hour: 7,
        minute: 30,
        frequency: ReminderFrequency.daily,
      );
      expect(r.scheduleLabel, equals('Daily at 07:30'));
    });

    test('One-time reminder produces correct scheduleLabel', () {
      final r = Reminder.create(
        title: 'Race day',
        hour: 9,
        minute: 0,
        frequency: ReminderFrequency.oneTime,
      );
      expect(r.scheduleLabel, equals('Once at 09:00'));
    });

    test('Weekly reminder with weekdays formats correctly', () {
      final r = Reminder.create(
        title: 'Gym',
        hour: 18,
        minute: 0,
        frequency: ReminderFrequency.weekly,
        weekdays: [Weekday.monday, Weekday.wednesday, Weekday.friday],
      );
      expect(r.scheduleLabel, equals('Mon, Wed, Fri at 18:00'));
    });

    test('Reminder copyWith updates only specified fields', () {
      final original = Reminder.create(title: 'Original', hour: 8, minute: 0);
      final updated = original.copyWith(title: 'Updated', hour: 10);
      expect(updated.id, equals(original.id)); // id unchanged
      expect(updated.title, equals('Updated'));
      expect(updated.hour, equals(10));
      expect(updated.minute, equals(0)); // unchanged
    });

    test('Reminder serialises to JSON and deserialises back without data loss', () {
      final original = Reminder.create(
        title: 'Log workout',
        body: 'Don\'t forget to log today\'s session',
        hour: 20,
        minute: 45,
        frequency: ReminderFrequency.weekly,
        weekdays: [Weekday.tuesday, Weekday.thursday],
      );

      final json = original.toJson();
      final restored = Reminder.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.title, equals(original.title));
      expect(restored.body, equals(original.body));
      expect(restored.hour, equals(original.hour));
      expect(restored.minute, equals(original.minute));
      expect(restored.frequency, equals(original.frequency));
      expect(restored.weekdays, containsAll([Weekday.tuesday, Weekday.thursday]));
      expect(restored.isEnabled, equals(original.isEnabled));
    });

    test('Reminder copyWith toggles isEnabled independently', () {
      final r = Reminder.create(title: 'Morning Run', hour: 6, minute: 0);
      expect(r.isEnabled, isTrue);
      final disabled = r.copyWith(isEnabled: false);
      expect(disabled.isEnabled, isFalse);
      expect(disabled.id, equals(r.id));
    });

    // ── ReminderFrequency enum ────────────────────────────────────────────────

    test('ReminderFrequency has correct labels', () {
      expect(ReminderFrequency.oneTime.label, equals('One-time'));
      expect(ReminderFrequency.daily.label, equals('Daily'));
      expect(ReminderFrequency.weekly.label, equals('Weekly'));
    });

    // ── Weekday enum ─────────────────────────────────────────────────────────

    test('Weekday isoWeekday values match DateTime constants', () {
      expect(Weekday.monday.isoWeekday, equals(1));
      expect(Weekday.sunday.isoWeekday, equals(7));
      expect(Weekday.saturday.isoWeekday, equals(6));
    });

    test('All Weekday values have short labels', () {
      for (final day in Weekday.values) {
        expect(day.label.length, equals(3));
      }
    });
  });
}
