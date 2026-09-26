import 'package:flutter/material.dart';
import 'activity.dart';

enum GoalTimePeriod {
  daily('Daily'),
  weekly('Weekly'),
  monthly('Monthly'),
  custom('Custom');

  final String label;
  const GoalTimePeriod(this.label);

  static GoalTimePeriod fromString(String value) {
    return GoalTimePeriod.values.firstWhere(
      (e) => e.name == value || e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => GoalTimePeriod.weekly,
    );
  }
}

/// Goal definition in FitTrack (e.g. 10,000 steps/day, 30 km/week, Gym 4x/week, Reach 75kg).
class Goal {
  final String id;
  final String name;
  final String description;
  final double target;
  final double currentProgress;
  final ActivityUnit unit;
  final GoalTimePeriod timePeriod;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCompleted;
  final int colorValue;
  final DateTime createdAt;
  final DateTime updatedAt;

  Goal({
    required this.id,
    required this.name,
    this.description = '',
    required this.target,
    this.currentProgress = 0.0,
    required this.unit,
    this.timePeriod = GoalTimePeriod.weekly,
    required this.startDate,
    required this.endDate,
    this.isCompleted = false,
    int? colorValue,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : colorValue = colorValue ?? const Color(0xFF00B4D8).value,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Color get color => Color(colorValue);

  double get percentageCompleted {
    if (target <= 0) return 0.0;
    return (currentProgress / target * 100.0).clamp(0.0, 100.0);
  }

  Goal copyWith({
    String? id,
    String? name,
    String? description,
    double? target,
    double? currentProgress,
    ActivityUnit? unit,
    GoalTimePeriod? timePeriod,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCompleted,
    int? colorValue,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      target: target ?? this.target,
      currentProgress: currentProgress ?? this.currentProgress,
      unit: unit ?? this.unit,
      timePeriod: timePeriod ?? this.timePeriod,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCompleted: isCompleted ?? this.isCompleted,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'target': target,
      'currentProgress': currentProgress,
      'unit': unit.name,
      'timePeriod': timePeriod.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isCompleted': isCompleted,
      'colorValue': colorValue,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      name: json['name'] as String,
      description: (json['description'] as String?) ?? '',
      target: (json['target'] as num).toDouble(),
      currentProgress: (json['currentProgress'] as num? ?? 0.0).toDouble(),
      unit: ActivityUnit.fromString(json['unit'] as String),
      timePeriod: GoalTimePeriod.fromString(json['timePeriod'] as String),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
      colorValue: json['colorValue'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
