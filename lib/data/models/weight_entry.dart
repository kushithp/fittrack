enum WeightGoalType {
  lose('Lose Weight'),
  gain('Gain Weight'),
  maintain('Maintain Weight');

  final String label;
  const WeightGoalType(this.label);

  static WeightGoalType fromString(String value) {
    return WeightGoalType.values.firstWhere(
      (e) => e.name == value || e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => WeightGoalType.maintain,
    );
  }
}

/// Represents a single weight log entry.
class WeightEntry {
  final String id;
  final String dateKey; // Formatted "YYYY-MM-DD"
  final DateTime date;
  final double weightKg;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  WeightEntry({
    required this.id,
    required this.dateKey,
    required this.date,
    required this.weightKg,
    this.notes = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  WeightEntry copyWith({
    String? id,
    String? dateKey,
    DateTime? date,
    double? weightKg,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WeightEntry(
      id: id ?? this.id,
      dateKey: dateKey ?? this.dateKey,
      date: date ?? this.date,
      weightKg: weightKg ?? this.weightKg,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateKey': dateKey,
      'date': date.toIso8601String(),
      'weightKg': weightKg,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory WeightEntry.fromJson(Map<String, dynamic> json) {
    return WeightEntry(
      id: json['id'] as String,
      dateKey: json['dateKey'] as String,
      date: DateTime.parse(json['date'] as String),
      weightKg: (json['weightKg'] as num).toDouble(),
      notes: (json['notes'] as String?) ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
