import 'package:intl/intl.dart';

/// Number and date formatting, in one place so every screen shows prices the same way.
abstract final class Formatters {
  // DummyJSON prices are US dollars whatever the app language is.
  static final NumberFormat _money = NumberFormat.currency(
    locale: 'en_US',
    symbol: r'$',
  );

  static String money(double value) => _money.format(value);

  /// One decimal place: `4.5`.
  static String rating(double value) => value.toStringAsFixed(1);

  static String date(DateTime value, String locale) =>
      DateFormat.yMMMd(locale).format(value.toLocal());
}
