import 'package:flutter/material.dart';

/// Supported measurement units for activities.
enum ActivityUnit {
  checkbox('Checkbox', ''),
  steps('Steps', 'steps'),
  km('Kilometers', 'km'),
  miles('Miles', 'mi'),
  minutes('Minutes', 'min'),
  hours('Hours', 'hrs'),
  liters('Liters', 'L'),
  ml('Milliliters', 'ml'),
  kg('Kilograms', 'kg'),
  lbs('Pounds', 'lbs'),
  grams('Grams', 'g'),
  reps('Reps', 'reps'),
  workouts('Workouts', 'sessions'),
  calories('Calories', 'kcal');

  final String label;
  final String symbol;

  const ActivityUnit(this.label, this.symbol);

  static ActivityUnit fromString(String value) {
    return ActivityUnit.values.firstWhere(
      (e) => e.name == value || e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => ActivityUnit.checkbox,
    );
  }
}

/// Categories for organizing activities.
enum ActivityCategory {
  cardio('Cardio', Icons.directions_run_rounded, Color(0xFF4CAF50)),
  strength('Strength', Icons.fitness_center_rounded, Color(0xFFE91E63)),
  nutrition('Nutrition', Icons.restaurant_rounded, Color(0xFFFF9800)),
  wellness('Wellness', Icons.spa_rounded, Color(0xFF9C27B0)),
  sleep('Sleep', Icons.bedtime_rounded, Color(0xFF3F51B5)),
  custom('Custom', Icons.stars_rounded, Color(0xFF00BCD4));

  final String label;
  final IconData icon;
  final Color defaultColor;

  const ActivityCategory(this.label, this.icon, this.defaultColor);

  static ActivityCategory fromString(String value) {
    return ActivityCategory.values.firstWhere(
      (e) => e.name == value || e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => ActivityCategory.custom,
    );
  }
}

/// Represents a trackable activity/habit definition in FitTrack.
class Activity {
  final String id;
  final String name;
  final String description;
  final double target;
  final ActivityUnit unit;
  final ActivityCategory category;
  final int iconCodePoint;
  final int colorValue;
  final bool isDailyChecklist;
  final bool contributesToDailyScore;
  final bool isEnabled;
  final String? reminderTime; // Format "HH:mm"
  final DateTime createdAt;
  final DateTime updatedAt;

  Activity({
    required this.id,
    required this.name,
    this.description = '',
    required this.target,
    required this.unit,
    required this.category,
    int? iconCodePoint,
    int? colorValue,
    this.isDailyChecklist = true,
    this.contributesToDailyScore = true,
    this.isEnabled = true,
    this.reminderTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : iconCodePoint = iconCodePoint ?? category.icon.codePoint,
        colorValue = colorValue ?? category.defaultColor.value,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Utility to get IconData from stored codePoint
  IconData get iconData => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  /// Utility to get Color object
  Color get color => Color(colorValue);

  /// Create a copy of Activity with updated fields
  Activity copyWith({
    String? id,
    String? name,
    String? description,
    double? target,
    ActivityUnit? unit,
    ActivityCategory? category,
    int? iconCodePoint,
    int? colorValue,
    bool? isDailyChecklist,
    bool? contributesToDailyScore,
    bool? isEnabled,
    String? reminderTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Activity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      target: target ?? this.target,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      isDailyChecklist: isDailyChecklist ?? this.isDailyChecklist,
      contributesToDailyScore: contributesToDailyScore ?? this.contributesToDailyScore,
      isEnabled: isEnabled ?? this.isEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
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
      'unit': unit.name,
      'category': category.name,
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
      'isDailyChecklist': isDailyChecklist,
      'contributesToDailyScore': contributesToDailyScore,
      'isEnabled': isEnabled,
      'reminderTime': reminderTime,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      name: json['name'] as String,
      description: (json['description'] as String?) ?? '',
      target: (json['target'] as num).toDouble(),
      unit: ActivityUnit.fromString(json['unit'] as String),
      category: ActivityCategory.fromString(json['category'] as String),
      iconCodePoint: json['iconCodePoint'] as int?,
      colorValue: json['colorValue'] as int?,
      isDailyChecklist: json['isDailyChecklist'] as bool? ?? true,
      contributesToDailyScore: json['contributesToDailyScore'] as bool? ?? true,
      isEnabled: json['isEnabled'] as bool? ?? true,
      reminderTime: json['reminderTime'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
