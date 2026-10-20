import 'package:uuid/uuid.dart';

/// Frequency for how often a reminder repeats.
enum ReminderFrequency {
  oneTime('One-time'),
  daily('Daily'),
  weekly('Weekly');

  final String label;
  const ReminderFrequency(this.label);
}

/// Days of the week (used when frequency is weekly).
enum Weekday {
  monday('Mon', 1),
  tuesday('Tue', 2),
  wednesday('Wed', 3),
  thursday('Thu', 4),
  friday('Fri', 5),
  saturday('Sat', 6),
  sunday('Sun', 7);

  final String label;
  final int isoWeekday; // matches DateTime.weekday
  const Weekday(this.label, this.isoWeekday);
}

/// A single user-configured reminder entry.
class Reminder {
  final String id;
  final String title;
  final String? body;         // Optional extra detail shown in the notification
  final int hour;             // 0-23
  final int minute;           // 0-59
  final ReminderFrequency frequency;
  final List<Weekday> weekdays; // used when frequency == weekly
  final bool isEnabled;
  final DateTime createdAt;

  Reminder({
    required this.id,
    required this.title,
    this.body,
    required this.hour,
    required this.minute,
    this.frequency = ReminderFrequency.daily,
    this.weekdays = const [],
    this.isEnabled = true,
    required this.createdAt,
  });

  /// Factory constructor for creating a brand-new reminder.
  factory Reminder.create({
    required String title,
    String? body,
    required int hour,
    required int minute,
    ReminderFrequency frequency = ReminderFrequency.daily,
    List<Weekday> weekdays = const [],
  }) {
    return Reminder(
      id: const Uuid().v4(),
      title: title,
      body: body,
      hour: hour,
      minute: minute,
      frequency: frequency,
      weekdays: weekdays,
      isEnabled: true,
      createdAt: DateTime.now(),
    );
  }

  Reminder copyWith({
    String? title,
    String? body,
    int? hour,
    int? minute,
    ReminderFrequency? frequency,
    List<Weekday>? weekdays,
    bool? isEnabled,
  }) {
    return Reminder(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      frequency: frequency ?? this.frequency,
      weekdays: weekdays ?? this.weekdays,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt,
    );
  }

  /// Formatted time string, e.g. "08:30"
  String get timeLabel {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Human-readable schedule label, e.g. "Daily at 08:30"
  String get scheduleLabel {
    switch (frequency) {
      case ReminderFrequency.oneTime:
        return 'Once at $timeLabel';
      case ReminderFrequency.daily:
        return 'Daily at $timeLabel';
      case ReminderFrequency.weekly:
        if (weekdays.isEmpty) return 'Weekly at $timeLabel';
        final days = weekdays.map((d) => d.label).join(', ');
        return '$days at $timeLabel';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'hour': hour,
      'minute': minute,
      'frequency': frequency.name,
      'weekdays': weekdays.map((d) => d.name).toList(),
      'isEnabled': isEnabled,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String?,
      hour: json['hour'] as int,
      minute: json['minute'] as int,
      frequency: ReminderFrequency.values.firstWhere(
        (e) => e.name == json['frequency'],
        orElse: () => ReminderFrequency.daily,
      ),
      weekdays: (json['weekdays'] as List<dynamic>? ?? [])
          .map((d) => Weekday.values.firstWhere(
                (e) => e.name == d,
                orElse: () => Weekday.monday,
              ))
          .toList(),
      isEnabled: json['isEnabled'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
