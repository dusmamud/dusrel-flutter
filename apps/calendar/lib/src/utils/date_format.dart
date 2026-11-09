import 'package:intl/intl.dart';

/// Locale-aware date/time formatting for the calendar app.
/// All formatting goes through intl so en_US / hi_IN both render correctly.
class CalendarFormat {
  CalendarFormat._();

  /// "November 2026" — the app bar title.
  static String monthYear(DateTime date) => DateFormat.yMMMM().format(date);

  /// "Mon 12 Nov" style short date.
  static String shortDate(DateTime date) => DateFormat('EEE d MMM').format(date);

  /// "Monday, 12 November" — full date for headers.
  static String fullDate(DateTime date) => DateFormat('EEEE, d MMMM').format(date);

  /// "Mon" — short weekday name.
  static String weekdayShort(DateTime date) => DateFormat.E().format(date);

  /// Locale-aware time, e.g. "9:00 AM" / "09:00".
  static String time(DateTime date) => DateFormat.jm().format(date);

  /// "9:00 AM – 10:30 AM" for a timed event; empty for all-day.
  static String timeRange(DateTime start, DateTime end) =>
      '${time(start)} – ${time(end)}';

  /// "9 AM" — compact hour label for the time grid gutter.
  static String hourLabel(DateTime date) => DateFormat.j().format(date);
}

/// True when [a] and [b] are the same calendar day (local time).
bool isSameLocalDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// The Monday (or first day of week) that starts the week containing [date].
DateTime startOfWeek(DateTime date, int firstDayOfWeek) {
  final day = DateTime(date.year, date.month, date.day);
  final offset = (day.weekday - firstDayOfWeek + 7) % 7;
  return day.subtract(Duration(days: offset));
}
