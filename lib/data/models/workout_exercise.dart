import 'exercise.dart';
import 'workout_set.dart';

/// An exercise instance with logged sets performed inside a workout session.
class WorkoutExercise {
  final String exerciseId;
  final String exerciseName;
  final ExerciseCategory category;
  final List<WorkoutSet> sets;
  final String notes;

  WorkoutExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.category,
    required this.sets,
    this.notes = '',
  });

  /// Max weight lifted in this exercise session
  double get maxWeightKg {
    if (sets.isEmpty) return 0.0;
    return sets.map((s) => s.weightKg).reduce((a, b) => a > b ? a : b);
  }

  /// Total volume lifted in kg (weight * reps across all sets)
  double get totalVolumeKg {
    return sets.fold(0.0, (sum, s) => sum + (s.weightKg * s.reps));
  }

  WorkoutExercise copyWith({
    String? exerciseId,
    String? exerciseName,
    ExerciseCategory? category,
    List<WorkoutSet>? sets,
    String? notes,
  }) {
    return WorkoutExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      category: category ?? this.category,
      sets: sets ?? this.sets,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'category': category.name,
      'sets': sets.map((s) => s.toJson()).toList(),
      'notes': notes,
    };
  }

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      category: ExerciseCategory.fromString(json['category'] as String),
      sets: (json['sets'] as List<dynamic>)
          .map((s) => WorkoutSet.fromJson(s as Map<String, dynamic>))
          .toList(),
      notes: (json['notes'] as String?) ?? '',
    );
  }
}
