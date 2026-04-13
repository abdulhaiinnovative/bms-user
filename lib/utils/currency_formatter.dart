import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat('#,##0', 'en_US');

  /// Format number with PKR currency and commas
  /// Example: 1000 -> "PKR 1,000"
  static String formatCurrency(num amount) {
    return 'PKR ${_formatter.format(amount)}';
  }

  /// Format number with Rs currency (short form) and commas
  /// Example: 1000 -> "Rs 1,000"
  static String formatCurrencyShort(num amount) {
    return 'Rs ${_formatter.format(amount)}';
  }

  /// Format number with commas only (no currency symbol)
  /// Example: 1000 -> "1,000"
  static String formatNumber(num amount) {
    return _formatter.format(amount);
  }
}
