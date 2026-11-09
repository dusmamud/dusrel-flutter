import 'package:flutter/material.dart';

/// How an event repeats. `custom` carries its rule in [CalendarEvent.recurrenceRule].
enum RecurrenceType { none, daily, weekly, monthly, yearly, custom }

/// A calendar the user owns (Personal / Work / Family in the mock data).
///
/// Colors come from the Material palette (never raw hex) so they work in
/// both light and dark themes.
class AppCalendar {
  const AppCalendar({
    required this.id,
    required this.name,
    required this.color,
    this.visible = true,
  });

  final String id;
  final String name;
  final Color color;
  final bool visible;

  AppCalendar copyWith({String? id, String? name, Color? color, bool? visible}) {
    return AppCalendar(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      visible: visible ?? this.visible,
    );
  }
}

/// One calendar event.
///
/// Times are stored in UTC ([startUtc]/[endUtc]) and rendered in the
/// device's local timezone. A recurring event is a single series record:
/// [recurrenceEnd] truncates the series and [excludedDates] (day precision,
/// local dates) lists occurrences the user deleted or detached.
class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.startUtc,
    required this.endUtc,
    this.isAllDay = false,
    required this.calendarId,
    this.location,
    this.notes,
    this.recurrence = RecurrenceType.none,
    this.recurrenceRule,
    this.reminderMinutes,
    this.seriesId,
    this.recurrenceEnd,
    this.excludedDates = const [],
  });

  final String id;
  final String title;
  final DateTime startUtc;
  final DateTime endUtc;
  final bool isAllDay;
  final String calendarId;
  final String? location;
  final String? notes;
  final RecurrenceType recurrence;
  final String? recurrenceRule;
  final int? reminderMinutes;

  /// Set on expanded occurrences: the id of the series this came from.
  /// Null on the series record itself and on standalone events.
  final String? seriesId;

  /// Last local date (inclusive) the series expands to, if truncated.
  final DateTime? recurrenceEnd;

  /// Local dates (day precision) of occurrences that were removed.
  final List<DateTime> excludedDates;

  /// Local start time for display.
  DateTime get startLocal => startUtc.toLocal();

  /// Local end time for display.
  DateTime get endLocal => endUtc.toLocal();

  /// True when this record is a series (not a one-off event).
  bool get isRecurring => recurrence != RecurrenceType.none;

  CalendarEvent copyWith({
    String? id,
    String? title,
    DateTime? startUtc,
    DateTime? endUtc,
    bool? isAllDay,
    String? calendarId,
    String? location,
    String? notes,
    RecurrenceType? recurrence,
    String? recurrenceRule,
    int? reminderMinutes,
    String? seriesId,
    DateTime? recurrenceEnd,
    List<DateTime>? excludedDates,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      startUtc: startUtc ?? this.startUtc,
      endUtc: endUtc ?? this.endUtc,
      isAllDay: isAllDay ?? this.isAllDay,
      calendarId: calendarId ?? this.calendarId,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      recurrence: recurrence ?? this.recurrence,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      seriesId: seriesId ?? this.seriesId,
      recurrenceEnd: recurrenceEnd ?? this.recurrenceEnd,
      excludedDates: excludedDates ?? this.excludedDates,
    );
  }
}

/// Which occurrences an edit/delete of a recurring event applies to.
enum RecurrenceScope { single, following, all }
