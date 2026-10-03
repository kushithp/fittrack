import 'package:flutter/material.dart';

enum ExerciseCategory {
  chest('Chest', Icons.fitness_center_rounded, Color(0xFFE91E63)),
  back('Back', Icons.sports_gymnastics_rounded, Color(0xFF9C27B0)),
  shoulders('Shoulders', Icons.accessibility_new_rounded, Color(0xFF3F51B5)),
  biceps('Biceps', Icons.fitness_center_rounded, Color(0xFF2196F3)),
  triceps('Triceps', Icons.fitness_center_rounded, Color(0xFF00BCD4)),
  legs('Legs', Icons.directions_run_rounded, Color(0xFF4CAF50)),
  core('Core', Icons.self_improvement_rounded, Color(0xFFFF9800)),
  cardio('Cardio', Icons.directions_bike_rounded, Color(0xFFFF5722)),
  other('Other', Icons.category_rounded, Color(0xFF607D8B));

  final String label;
  final IconData icon;
  final Color color;

  const ExerciseCategory(this.label, this.icon, this.color);

  static ExerciseCategory fromString(String value) {
    return ExerciseCategory.values.firstWhere(
      (e) => e.name == value || e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => ExerciseCategory.other,
    );
  }
}

/// Catalog item representing a reusable exercise definition in FitTrack.
class Exercise {
  final String id;
  final String name;
  final ExerciseCategory category;
  final String description;
  final String defaultUnit; // kg, lbs, bodyweight, etc.
  final DateTime createdAt;

  Exercise({
    required this.id,
    required this.name,
    required this.category,
    this.description = '',
    this.defaultUnit = 'kg',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Exercise copyWith({
    String? id,
    String? name,
    ExerciseCategory? category,
    String? description,
    String? defaultUnit,
    DateTime? createdAt,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      defaultUnit: defaultUnit ?? this.defaultUnit,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.name,
      'description': description,
      'defaultUnit': defaultUnit,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      category: ExerciseCategory.fromString(json['category'] as String),
      description: (json['description'] as String?) ?? '',
      defaultUnit: (json['defaultUnit'] as String?) ?? 'kg',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
