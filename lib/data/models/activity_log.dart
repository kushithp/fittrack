/// Represents a logged entry for a specific activity on a specific date.
class ActivityLog {
  final String id;
  final String activityId;
  final String dateKey; // Formatted as "YYYY-MM-DD" for fast indexing & querying
  final double value;
  final bool isCompleted;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ActivityLog({
    required this.id,
    required this.activityId,
    required this.dateKey,
    required this.value,
    required this.isCompleted,
    this.notes = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Format DateTime to standard date key "yyyy-MM-dd"
  static String formatDateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  ActivityLog copyWith({
    String? id,
    String? activityId,
    String? dateKey,
    double? value,
    bool? isCompleted,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ActivityLog(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      dateKey: dateKey ?? this.dateKey,
      value: value ?? this.value,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activityId': activityId,
      'dateKey': dateKey,
      'value': value,
      'isCompleted': isCompleted,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'] as String,
      activityId: json['activityId'] as String,
      dateKey: json['dateKey'] as String,
      value: (json['value'] as num).toDouble(),
      isCompleted: json['isCompleted'] as bool,
      notes: (json['notes'] as String?) ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
