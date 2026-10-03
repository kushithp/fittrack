import 'package:flutter/material.dart';

enum RecordCategory {
  exercise('Exercise PR', Icons.fitness_center_rounded, Color(0xFFE91E63)),
  cardio('Cardio PR', Icons.directions_run_rounded, Color(0xFF4CAF50)),
  consistency('Streak PR', Icons.local_fire_department_rounded, Color(0xFFFF9800)),
  workout('Workout PR', Icons.timer_rounded, Color(0xFF9C27B0));

  final String label;
  final IconData icon;
  final Color color;

  const RecordCategory(this.label, this.icon, this.color);

  static RecordCategory fromString(String value) {
    return RecordCategory.values.firstWhere(
      (c) => c.name == value || c.label.toLowerCase() == value.toLowerCase(),
      orElse: () => RecordCategory.exercise,
    );
  }
}

/// Personal Record (PR) entry in FitTrack.
class PersonalRecord {
  final String id;
  final String title; // e.g. "Heaviest Bench Press", "Highest Squat", "Longest Workout"
  final double recordValue;
  final String unit; // e.g. "kg", "km", "min", "days", "steps"
  final DateTime date;
  final RecordCategory category;
  final String exerciseName;
  final DateTime createdAt;

  PersonalRecord({
    required this.id,
    required this.title,
    required this.recordValue,
    required this.unit,
    required this.date,
    this.category = RecordCategory.exercise,
    this.exerciseName = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'recordValue': recordValue,
      'unit': unit,
      'date': date.toIso8601String(),
      'category': category.name,
      'exerciseName': exerciseName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PersonalRecord.fromJson(Map<String, dynamic> json) {
    return PersonalRecord(
      id: json['id'] as String,
      title: json['title'] as String,
      recordValue: (json['recordValue'] as num).toDouble(),
      unit: json['unit'] as String,
      date: DateTime.parse(json['date'] as String),
      category: RecordCategory.fromString(json['category'] as String),
      exerciseName: (json['exerciseName'] as String?) ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
