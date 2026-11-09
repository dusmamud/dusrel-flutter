import '../models/calendar_event.dart';

/// Minimal RRULE-style parsing/expansion for display only.
///
/// Supports `FREQ=DAILY|WEEKLY|MONTHLY|YEARLY`, `INTERVAL=n`, `BYDAY=MO,TU…`,
/// `UNTIL=yyyymmdd` and `COUNT=n`. Full RFC 5545 is out of scope for v1:
/// anything unparseable falls back to the series' [RecurrenceType] with
/// interval 1. Expansion only covers the requested visible range.
class RecurrenceRule {
  RecurrenceRule({
    required this.frequency,
    this.interval = 1,
    this.byWeekdays = const [],
    this.until,
    this.count,
  });

  factory RecurrenceRule.parse(String? rule, RecurrenceType type) {
    var frequency = switch (type) {
      RecurrenceType.daily => 'DAILY',
      RecurrenceType.weekly => 'WEEKLY',
      RecurrenceType.monthly => 'MONTHLY',
      RecurrenceType.yearly => 'YEARLY',
      _ => 'DAILY',
    };
    var interval = 1;
    var byWeekdays = <int>[];
    DateTime? until;
    int? count;
    if (rule != null) {
      for (final part in rule.split(';')) {
        final kv = part.split('=');
        if (kv.length != 2) continue;
        switch (kv[0]) {
          case 'FREQ':
            frequency = kv[1];
          case 'INTERVAL':
            interval = int.tryParse(kv[1]) ?? 1;
          case 'BYDAY':
            byWeekdays = kv[1]
                .split(',')
                .map(_weekdayFromCode)
                .whereType<int>()
                .toList();
          case 'UNTIL':
            until = _parseUntil(kv[1]);
          case 'COUNT':
            count = int.tryParse(kv[1]);
        }
      }
    }
    return RecurrenceRule(
      frequency: frequency,
      interval: interval,
      byWeekdays: byWeekdays,
      until: until,
      count: count,
    );
  }

  final String frequency;
  final int interval;
  final List<int> byWeekdays;
  final DateTime? until;
  final int? count;

  static int? _weekdayFromCode(String code) => switch (code.trim()) {
    'MO' => DateTime.monday,
    'TU' => DateTime.tuesday,
    'WE' => DateTime.wednesday,
    'TH' => DateTime.thursday,
    'FR' => DateTime.friday,
    'SA' => DateTime.saturday,
    'SU' => DateTime.sunday,
    _ => null,
  };

  static DateTime? _parseUntil(String value) {
    if (value.length < 8) return null;
    final year = int.tryParse(value.substring(0, 4));
    final month = int.tryParse(value.substring(4, 6));
    final day = int.tryParse(value.substring(6, 8));
    if (year == null || month == null || day == null) return null;
    return DateTime(year, month, day);
  }

  static String codeForWeekday(int weekday) => switch (weekday) {
    DateTime.monday => 'MO',
    DateTime.tuesday => 'TU',
    DateTime.wednesday => 'WE',
    DateTime.thursday => 'TH',
    DateTime.friday => 'FR',
    DateTime.saturday => 'SA',
    DateTime.sunday => 'SU',
    _ => '',
  };

  /// Builds the rule string for the custom recurrence dialog.
  static String build({
    required String frequency,
    required int interval,
    List<int> byWeekdays = const [],
    DateTime? until,
    int? count,
  }) {
    final parts = <String>['FREQ=$frequency', 'INTERVAL=$interval'];
    if (byWeekdays.isNotEmpty) {
      parts.add(
        'BYDAY=${byWeekdays.map(codeForWeekday).join(',')}',
      );
    }
    if (until != null) {
      parts.add(
        'UNTIL=${until.year}${until.month.toString().padLeft(2, '0')}${until.day.toString().padLeft(2, '0')}',
      );
    }
    if (count != null) parts.add('COUNT=$count');
    return parts.join(';');
  }
}

DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Expands [events] into occurrences overlapping [rangeStart]..[rangeEnd]
/// (local dates). One-off events pass through unchanged; recurring series
/// expand day by day inside the range only.
List<CalendarEvent> expandEvents(
  List<CalendarEvent> events,
  DateTime rangeStart,
  DateTime rangeEnd,
) {
  final result = <CalendarEvent>[];
  final startDay = _dayOnly(rangeStart);
  final endDay = _dayOnly(rangeEnd);
  for (final event in events) {
    if (!event.isRecurring) {
      final s = _dayOnly(event.startLocal);
      final e = _dayOnly(event.endLocal);
      if (!e.isBefore(startDay) && !s.isAfter(endDay)) result.add(event);
      continue;
    }
    final rule = RecurrenceRule.parse(event.recurrenceRule, event.recurrence);
    final seriesStartDay = _dayOnly(event.startLocal);
    final seriesEndDay = event.recurrenceEnd != null
        ? _dayOnly(event.recurrenceEnd!)
        : endDay;
    final effectiveEnd = seriesEndDay.isBefore(endDay) ? seriesEndDay : endDay;
    final duration = event.endLocal.difference(event.startLocal);
    var emitted = 0;
    var day = seriesStartDay.isAfter(startDay) ? seriesStartDay : startDay;
    // Walk day by day; cheap for the few-week ranges the UI requests.
    while (!day.isAfter(effectiveEnd)) {
      if (rule.until != null && day.isAfter(_dayOnly(rule.until!))) break;
      if (rule.count != null && emitted >= rule.count!) break;
      if (!_matchesRule(day, seriesStartDay, rule)) {
        day = day.add(const Duration(days: 1));
        continue;
      }
      if (event.excludedDates.any((d) => _dayOnly(d) == day)) {
        day = day.add(const Duration(days: 1));
        continue;
      }
      final start = DateTime(
        day.year,
        day.month,
        day.day,
        event.startLocal.hour,
        event.startLocal.minute,
      );
      final end = start.add(duration);
      result.add(
        event.copyWith(
          id: '${event.id}@${day.year}-${day.month}-${day.day}',
          startUtc: start.toUtc(),
          endUtc: end.toUtc(),
          seriesId: event.id,
          recurrence: RecurrenceType.none,
        ),
      );
      emitted++;
      day = day.add(const Duration(days: 1));
    }
  }
  result.sort((a, b) {
    final byStart = a.startLocal.compareTo(b.startLocal);
    return byStart != 0 ? byStart : a.title.compareTo(b.title);
  });
  return result;
}

bool _matchesRule(DateTime day, DateTime seriesStart, RecurrenceRule rule) {
  final daysSinceStart = day.difference(seriesStart).inDays;
  if (daysSinceStart < 0) return false;
  switch (rule.frequency) {
    case 'DAILY':
      return daysSinceStart % rule.interval == 0;
    case 'WEEKLY':
      final weeksSinceStart = daysSinceStart ~/ 7;
      if (weeksSinceStart % rule.interval != 0) return false;
      final weekdays = rule.byWeekdays.isEmpty
          ? [seriesStart.weekday]
          : rule.byWeekdays;
      return weekdays.contains(day.weekday);
    case 'MONTHLY':
      if (day.day != seriesStart.day) return false;
      final monthsSinceStart =
          (day.year - seriesStart.year) * 12 + (day.month - seriesStart.month);
      return monthsSinceStart % rule.interval == 0;
    case 'YEARLY':
      if (day.month != seriesStart.month || day.day != seriesStart.day) {
        return false;
      }
      return (day.year - seriesStart.year) % rule.interval == 0;
    default:
      return false;
  }
}

/// Events of [events] that touch the local [day].
List<CalendarEvent> eventsOnDay(List<CalendarEvent> events, DateTime day) {
  final d = _dayOnly(day);
  return events.where((e) {
    final s = _dayOnly(e.startLocal);
    final e2 = _dayOnly(e.endLocal);
    return !d.isBefore(s) && !d.isAfter(e2);
  }).toList();
}

/// Resolves an event id from the edit route to an editable instance.
///
/// A plain id matches a stored record directly. An occurrence id looks
/// like `<seriesId>@2026-11-9` — the series is expanded for that day and
/// the matching occurrence is returned.
CalendarEvent? resolveEventForEdit(List<CalendarEvent> events, String id) {
  for (final event in events) {
    if (event.id == id) return event;
  }
  final at = id.indexOf('@');
  if (at <= 0) return null;
  final seriesId = id.substring(0, at);
  final dayPart = id.substring(at + 1).split('-');
  if (dayPart.length != 3) return null;
  final year = int.tryParse(dayPart[0]);
  final month = int.tryParse(dayPart[1]);
  final day = int.tryParse(dayPart[2]);
  if (year == null || month == null || day == null) return null;
  final series = events.where((e) => e.id == seriesId).toList();
  if (series.isEmpty) return null;
  final date = DateTime(year, month, day);
  final expanded = expandEvents(series, date, date);
  return expanded.isEmpty ? null : expanded.first;
}
