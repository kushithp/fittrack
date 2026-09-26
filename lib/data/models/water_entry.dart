/// Represents an individual water intake log entry (in Liters or ml).
class WaterEntry {
  final String id;
  final String dateKey; // Formatted "YYYY-MM-DD"
  final DateTime date;
  final double amountLiters; // In Liters (e.g. 0.25, 0.50, 0.75)
  final DateTime createdAt;

  WaterEntry({
    required this.id,
    required this.dateKey,
    required this.date,
    required this.amountLiters,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateKey': dateKey,
      'date': date.toIso8601String(),
      'amountLiters': amountLiters,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WaterEntry.fromJson(Map<String, dynamic> json) {
    return WaterEntry(
      id: json['id'] as String,
      dateKey: json['dateKey'] as String,
      date: DateTime.parse(json['date'] as String),
      amountLiters: (json['amountLiters'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
