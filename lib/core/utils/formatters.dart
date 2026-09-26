import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _numberFormat = NumberFormat('#,##0.#');
  static final NumberFormat _integerFormat = NumberFormat('#,##0');

  /// Formats double or int values cleanly with commas (e.g. 10,000 or 5.7)
  static String formatValue(double value, {bool isInteger = false}) {
    if (isInteger || value == value.roundToDouble()) {
      return _integerFormat.format(value.round());
    }
    return _numberFormat.format(value);
  }

  /// Formats percentage (e.g. "82%")
  static String formatPercent(double percent) {
    return '${percent.clamp(0.0, 100.0).toStringAsFixed(0)}%';
  }
}
