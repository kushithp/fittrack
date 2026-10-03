/// Represents a single set performed in an exercise.
class WorkoutSet {
  final int setNumber;
  final double weightKg;
  final int reps;
  final int durationSeconds;
  final double distanceKm;
  final int restTimeSeconds;
  final bool isCompleted;

  WorkoutSet({
    required this.setNumber,
    this.weightKg = 0.0,
    this.reps = 0,
    this.durationSeconds = 0,
    this.distanceKm = 0.0,
    this.restTimeSeconds = 60,
    this.isCompleted = true,
  });

  WorkoutSet copyWith({
    int? setNumber,
    double? weightKg,
    int? reps,
    int? durationSeconds,
    double? distanceKm,
    int? restTimeSeconds,
    bool? isCompleted,
  }) {
    return WorkoutSet(
      setNumber: setNumber ?? this.setNumber,
      weightKg: weightKg ?? this.weightKg,
      reps: reps ?? this.reps,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      distanceKm: distanceKm ?? this.distanceKm,
      restTimeSeconds: restTimeSeconds ?? this.restTimeSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'setNumber': setNumber,
      'weightKg': weightKg,
      'reps': reps,
      'durationSeconds': durationSeconds,
      'distanceKm': distanceKm,
      'restTimeSeconds': restTimeSeconds,
      'isCompleted': isCompleted,
    };
  }

  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    return WorkoutSet(
      setNumber: json['setNumber'] as int,
      weightKg: (json['weightKg'] as num? ?? 0.0).toDouble(),
      reps: json['reps'] as int? ?? 0,
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      distanceKm: (json['distanceKm'] as num? ?? 0.0).toDouble(),
      restTimeSeconds: json['restTimeSeconds'] as int? ?? 60,
      isCompleted: json['isCompleted'] as bool? ?? true,
    );
  }
}
