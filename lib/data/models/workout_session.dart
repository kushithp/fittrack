import 'workout_exercise.dart';

/// Represents a completed or active workout session in FitTrack.
class WorkoutSession {
  final String id;
  final String title; // e.g. "CHEST + TRICEPS", "LEGS DAY"
  final DateTime date;
  final int durationMinutes;
  final List<WorkoutExercise> exercises;
  final String notes;
  final int energyRating; // 1-10
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkoutSession({
    required this.id,
    required this.title,
    required this.date,
    this.durationMinutes = 45,
    required this.exercises,
    this.notes = '',
    this.energyRating = 8,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Total workout volume across all exercises
  double get totalVolumeKg {
    return exercises.fold(0.0, (sum, e) => sum + e.totalVolumeKg);
  }

  /// Total number of completed sets
  int get totalSets {
    return exercises.fold(0, (sum, e) => sum + e.sets.length);
  }

  WorkoutSession copyWith({
    String? id,
    String? title,
    DateTime? date,
    int? durationMinutes,
    List<WorkoutExercise>? exercises,
    String? notes,
    int? energyRating,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      exercises: exercises ?? this.exercises,
      notes: notes ?? this.notes,
      energyRating: energyRating ?? this.energyRating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'durationMinutes': durationMinutes,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'notes': notes,
      'energyRating': energyRating,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      durationMinutes: json['durationMinutes'] as int? ?? 45,
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: (json['notes'] as String?) ?? '',
      energyRating: json['energyRating'] as int? ?? 8,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
