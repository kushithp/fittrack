/// Data point for analytics charts (e.g. date, actual value, target value).
class AnalyticsPoint {
  final DateTime date;
  final String label; // e.g. "Mon", "Sep 24"
  final double value;
  final double targetValue;

  const AnalyticsPoint({
    required this.date,
    required this.label,
    required this.value,
    this.targetValue = 0.0,
  });
}
