/// Represents user-configured activity weightings for calculating Daily Fitness Score (0-100).
class ScoreConfig {
  final double stepsWeight;      // Default: 25%
  final double workoutWeight;    // Default: 25%
  final double waterWeight;      // Default: 15%
  final double sleepWeight;      // Default: 20%
  final double habitsWeight;     // Default: 15%

  const ScoreConfig({
    this.stepsWeight = 25.0,
    this.workoutWeight = 25.0,
    this.waterWeight = 15.0,
    this.sleepWeight = 20.0,
    this.habitsWeight = 15.0,
  });

  double get totalWeight => stepsWeight + workoutWeight + waterWeight + sleepWeight + habitsWeight;

  ScoreConfig copyWith({
    double? stepsWeight,
    double? workoutWeight,
    double? waterWeight,
    double? sleepWeight,
    double? habitsWeight,
  }) {
    return ScoreConfig(
      stepsWeight: stepsWeight ?? this.stepsWeight,
      workoutWeight: workoutWeight ?? this.workoutWeight,
      waterWeight: waterWeight ?? this.waterWeight,
      sleepWeight: sleepWeight ?? this.sleepWeight,
      habitsWeight: habitsWeight ?? this.habitsWeight,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stepsWeight': stepsWeight,
      'workoutWeight': workoutWeight,
      'waterWeight': waterWeight,
      'sleepWeight': sleepWeight,
      'habitsWeight': habitsWeight,
    };
  }

  factory ScoreConfig.fromJson(Map<String, dynamic> json) {
    return ScoreConfig(
      stepsWeight: (json['stepsWeight'] as num? ?? 25.0).toDouble(),
      workoutWeight: (json['workoutWeight'] as num? ?? 25.0).toDouble(),
      waterWeight: (json['waterWeight'] as num? ?? 15.0).toDouble(),
      sleepWeight: (json['sleepWeight'] as num? ?? 20.0).toDouble(),
      habitsWeight: (json['habitsWeight'] as num? ?? 15.0).toDouble(),
    );
  }
}
