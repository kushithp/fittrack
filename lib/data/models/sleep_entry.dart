enum SleepQuality {
  poor('Poor', 1),
  fair('Fair', 2),
  good('Good', 3),
  excellent('Excellent', 4),
  deep('Deep & Restful', 5);

  final String label;
  final int rating;
  const SleepQuality(this.label, this.rating);

  static SleepQuality fromRating(int rating) {
    return SleepQuality.values.firstWhere(
      (q) => q.rating == rating,
      orElse: () => SleepQuality.good,
    );
  }
}

/// Represents a sleep record.
class SleepEntry {
  final String id;
  final String dateKey; // Formatted "YYYY-MM-DD"
  final DateTime sleepTime;
  final DateTime wakeTime;
  final double durationHours;
  final SleepQuality quality;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  SleepEntry({
    required this.id,
    required this.dateKey,
    required this.sleepTime,
    required this.wakeTime,
    double? durationHours,
    this.quality = SleepQuality.good,
    this.notes = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : durationHours = durationHours ?? wakeTime.difference(sleepTime).inMinutes / 60.0,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  SleepEntry copyWith({
    String? id,
    String? dateKey,
    DateTime? sleepTime,
    DateTime? wakeTime,
    double? durationHours,
    SleepQuality? quality,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SleepEntry(
      id: id ?? this.id,
      dateKey: dateKey ?? this.dateKey,
      sleepTime: sleepTime ?? this.sleepTime,
      wakeTime: wakeTime ?? this.wakeTime,
      durationHours: durationHours ?? this.durationHours,
      quality: quality ?? this.quality,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateKey': dateKey,
      'sleepTime': sleepTime.toIso8601String(),
      'wakeTime': wakeTime.toIso8601String(),
      'durationHours': durationHours,
      'quality': quality.rating,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SleepEntry.fromJson(Map<String, dynamic> json) {
    return SleepEntry(
      id: json['id'] as String,
      dateKey: json['dateKey'] as String,
      sleepTime: DateTime.parse(json['sleepTime'] as String),
      wakeTime: DateTime.parse(json['wakeTime'] as String),
      durationHours: (json['durationHours'] as num).toDouble(),
      quality: SleepQuality.fromRating(json['quality'] as int? ?? 3),
      notes: (json['notes'] as String?) ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
