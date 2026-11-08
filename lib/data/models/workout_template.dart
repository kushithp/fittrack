import 'package:uuid/uuid.dart';

/// Single exercise within a workout template.
class TemplateExercise {
  final String exerciseId;
  final String exerciseName;
  final int defaultSets;
  final int targetReps;
  final double defaultWeightKg;

  const TemplateExercise({
    required this.exerciseId,
    required this.exerciseName,
    this.defaultSets = 3,
    this.targetReps = 10,
    this.defaultWeightKg = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'defaultSets': defaultSets,
        'targetReps': targetReps,
        'defaultWeightKg': defaultWeightKg,
      };

  factory TemplateExercise.fromJson(Map<String, dynamic> json) =>
      TemplateExercise(
        exerciseId: json['exerciseId'] as String,
        exerciseName: json['exerciseName'] as String,
        defaultSets: json['defaultSets'] as int? ?? 3,
        targetReps: json['targetReps'] as int? ?? 10,
        defaultWeightKg: (json['defaultWeightKg'] as num?)?.toDouble() ?? 0.0,
      );
}

/// Reusable workout template / routine.
class WorkoutTemplate {
  final String id;
  final String title;
  final String description;
  final List<TemplateExercise> exercises;
  final int estimatedDurationMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkoutTemplate({
    required this.id,
    required this.title,
    this.description = '',
    required this.exercises,
    this.estimatedDurationMinutes = 45,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory WorkoutTemplate.create({
    required String title,
    String description = '',
    required List<TemplateExercise> exercises,
    int estimatedDurationMinutes = 45,
  }) {
    final now = DateTime.now();
    return WorkoutTemplate(
      id: const Uuid().v4(),
      title: title,
      description: description,
      exercises: exercises,
      estimatedDurationMinutes: estimatedDurationMinutes,
      createdAt: now,
      updatedAt: now,
    );
  }

  WorkoutTemplate copyWith({
    String? id,
    String? title,
    String? description,
    List<TemplateExercise>? exercises,
    int? estimatedDurationMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutTemplate(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'estimatedDurationMinutes': estimatedDurationMinutes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json) =>
      WorkoutTemplate(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        exercises: (json['exercises'] as List<dynamic>?)
                ?.map((e) =>
                    TemplateExercise.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        estimatedDurationMinutes:
            json['estimatedDurationMinutes'] as int? ?? 45,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}
