/// Daily note entry for tracking energy, mood, recovery, text notes, and tags.
class DailyNote {
  final String id;
  final String dateKey; // Formatted "YYYY-MM-DD"
  final DateTime date;
  final int energyRating; // 1 to 10
  final int moodRating; // 1 to 10
  final int recoveryRating; // 1 to 10
  final String textNotes;
  final List<String> tags;
  final String? attachedWorkoutId;
  final String? attachedActivityId;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyNote({
    required this.id,
    required this.dateKey,
    required this.date,
    this.energyRating = 5,
    this.moodRating = 5,
    this.recoveryRating = 5,
    this.textNotes = '',
    List<String>? tags,
    this.attachedWorkoutId,
    this.attachedActivityId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : tags = tags ?? const [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  DailyNote copyWith({
    String? id,
    String? dateKey,
    DateTime? date,
    int? energyRating,
    int? moodRating,
    int? recoveryRating,
    String? textNotes,
    List<String>? tags,
    String? attachedWorkoutId,
    String? attachedActivityId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyNote(
      id: id ?? this.id,
      dateKey: dateKey ?? this.dateKey,
      date: date ?? this.date,
      energyRating: energyRating ?? this.energyRating,
      moodRating: moodRating ?? this.moodRating,
      recoveryRating: recoveryRating ?? this.recoveryRating,
      textNotes: textNotes ?? this.textNotes,
      tags: tags ?? this.tags,
      attachedWorkoutId: attachedWorkoutId ?? this.attachedWorkoutId,
      attachedActivityId: attachedActivityId ?? this.attachedActivityId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateKey': dateKey,
      'date': date.toIso8601String(),
      'energyRating': energyRating,
      'moodRating': moodRating,
      'recoveryRating': recoveryRating,
      'textNotes': textNotes,
      'tags': tags,
      'attachedWorkoutId': attachedWorkoutId,
      'attachedActivityId': attachedActivityId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DailyNote.fromJson(Map<String, dynamic> json) {
    return DailyNote(
      id: json['id'] as String,
      dateKey: json['dateKey'] as String,
      date: DateTime.parse(json['date'] as String),
      energyRating: json['energyRating'] as int? ?? 5,
      moodRating: json['moodRating'] as int? ?? 5,
      recoveryRating: json['recoveryRating'] as int? ?? 5,
      textNotes: (json['textNotes'] as String?) ?? '',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      attachedWorkoutId: json['attachedWorkoutId'] as String?,
      attachedActivityId: json['attachedActivityId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
