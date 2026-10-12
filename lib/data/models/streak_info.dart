/// Contains streak and consistency statistics.
class StreakInfo {
  final String title;
  final int currentStreakDays;
  final int longestStreakDays;
  final double weeklyConsistencyPercent;
  final double monthlyConsistencyPercent;

  const StreakInfo({
    required this.title,
    required this.currentStreakDays,
    required this.longestStreakDays,
    required this.weeklyConsistencyPercent,
    required this.monthlyConsistencyPercent,
  });
}
