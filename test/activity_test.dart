import 'package:flutter_test/flutter_test.dart';
import 'package:fittrack/data/models/activity.dart';
import 'package:fittrack/data/models/activity_log.dart';

void main() {
  group('Activity Model Tests', () {
    test('Activity serialization to JSON and back works accurately', () {
      final now = DateTime.now();
      final activity = Activity(
        id: 'test_123',
        name: '10,000 Steps',
        target: 10000,
        unit: ActivityUnit.steps,
        category: ActivityCategory.cardio,
        createdAt: now,
      );

      final json = activity.toJson();
      expect(json['id'], 'test_123');
      expect(json['name'], '10,000 Steps');
      expect(json['target'], 10000.0);
      expect(json['unit'], 'steps');
      expect(json['category'], 'cardio');

      final deserialized = Activity.fromJson(json);
      expect(deserialized.id, activity.id);
      expect(deserialized.name, activity.name);
      expect(deserialized.target, activity.target);
      expect(deserialized.unit, activity.unit);
      expect(deserialized.category, activity.category);
    });

    test('ActivityLog date key formats correctly to YYYY-MM-DD', () {
      final date = DateTime(2026, 9, 24, 14, 30);
      final key = ActivityLog.formatDateKey(date);
      expect(key, '2026-09-24');
    });

    test('ActivityLog completion updates correctly', () {
      final log = ActivityLog(
        id: 'log_1',
        activityId: 'act_1',
        dateKey: '2026-09-24',
        value: 5000,
        isCompleted: false,
      );

      final updated = log.copyWith(value: 10000, isCompleted: true);
      expect(updated.value, 10000.0);
      expect(updated.isCompleted, isTrue);
    });
  });
}
