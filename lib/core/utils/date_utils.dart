import 'package:intl/intl.dart';

class AppDateUtils {
  /// Returns contextual time of day greeting (e.g. "Good morning", "Good afternoon", "Good evening")
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  /// Formats date to readable string "Thursday, September 24"
  static String formatHeaderDate(DateTime date) {
    return DateFormat('EEEE, MMMM d').format(date);
  }

  /// Short formatted date "Sep 24"
  static String formatShortDate(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  /// True if given date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}
