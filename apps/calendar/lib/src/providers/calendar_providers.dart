import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/calendar_repository.dart';
import '../models/calendar_event.dart';

/// The data source. Override in tests with a fresh [MockCalendarRepository].
final calendarRepositoryProvider = Provider<CalendarRepository>(
  (ref) => MockCalendarRepository(),
);

/// The day the user is looking at (local date, day precision).
/// Switching views never changes this — the selected date is preserved.
class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void select(DateTime date) =>
      state = DateTime(date.year, date.month, date.day);

  void goToday() => select(DateTime.now());

  void shiftDays(int days) => select(state.add(Duration(days: days)));

  void shiftWeeks(int weeks) => select(state.add(Duration(days: 7 * weeks)));

  void shiftMonths(int months) {
    var year = state.year;
    var month = state.month + months;
    while (month > 12) {
      month -= 12;
      year++;
    }
    while (month < 1) {
      month += 12;
      year--;
    }
    final day = state.day.clamp(1, _daysInMonth(year, month));
    state = DateTime(year, month, day);
  }

  static int _daysInMonth(int year, int month) {
    final next = month == 12
        ? DateTime(year + 1, 1, 1)
        : DateTime(year, month + 1, 1);
    return next.subtract(const Duration(days: 1)).day;
  }
}

final selectedDateProvider =
    NotifierProvider<SelectedDateNotifier, DateTime>(SelectedDateNotifier.new);

/// Which calendar layout is shown.
enum CalendarView { month, week, day, agenda }

class CalendarViewNotifier extends Notifier<CalendarView> {
  @override
  CalendarView build() => CalendarView.month;

  void set(CalendarView view) => state = view;
}

final calendarViewProvider =
    NotifierProvider<CalendarViewNotifier, CalendarView>(
      CalendarViewNotifier.new,
    );

/// User preferences for the calendar app.
class CalendarSettings {
  const CalendarSettings({
    this.defaultView = CalendarView.month,
    this.firstDayOfWeek = DateTime.monday,
    this.defaultReminderMinutes = 10,
  });

  final CalendarView defaultView;
  final int firstDayOfWeek;
  final int defaultReminderMinutes;

  CalendarSettings copyWith({
    CalendarView? defaultView,
    int? firstDayOfWeek,
    int? defaultReminderMinutes,
  }) {
    return CalendarSettings(
      defaultView: defaultView ?? this.defaultView,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      defaultReminderMinutes:
          defaultReminderMinutes ?? this.defaultReminderMinutes,
    );
  }
}

class CalendarSettingsNotifier extends Notifier<CalendarSettings> {
  @override
  CalendarSettings build() => const CalendarSettings();

  void setDefaultView(CalendarView view) =>
      state = state.copyWith(defaultView: view);

  void setFirstDayOfWeek(int weekday) =>
      state = state.copyWith(firstDayOfWeek: weekday);

  void setDefaultReminder(int? minutes) =>
      state = state.copyWith(defaultReminderMinutes: minutes ?? 10);
}

final calendarSettingsProvider =
    NotifierProvider<CalendarSettingsNotifier, CalendarSettings>(
      CalendarSettingsNotifier.new,
    );

/// All stored events (series records, not expanded occurrences).
class EventsNotifier extends AsyncNotifier<List<CalendarEvent>> {
  @override
  Future<List<CalendarEvent>> build() =>
      ref.watch(calendarRepositoryProvider).getEvents();

  Future<void> addEvent(CalendarEvent event) async {
    await ref.read(calendarRepositoryProvider).saveEvent(event);
    state = AsyncData([...?state.value, event]);
  }

  Future<void> updateEvent(CalendarEvent event) async {
    await ref.read(calendarRepositoryProvider).saveEvent(event);
    state = AsyncData([
      for (final e in state.value ?? [])
        if (e.id == event.id) event else e,
    ]);
  }

  Future<void> deleteEvent(String id) async {
    await ref.read(calendarRepositoryProvider).deleteEvent(id);
    state = AsyncData([
      for (final e in state.value ?? [])
        if (e.id != id) e,
    ]);
  }

  /// Applies an edit to one occurrence of a recurring series.
  /// [occurrence] is the expanded instance the user tapped (its
  /// [CalendarEvent.seriesId] points at the series); [edited] carries the
  /// new field values with the occurrence's date.
  Future<void> applyRecurringEdit({
    required CalendarEvent occurrence,
    required CalendarEvent edited,
    required RecurrenceScope scope,
  }) async {
    final repo = ref.read(calendarRepositoryProvider);
    final events = state.value ?? [];
    final seriesId = occurrence.seriesId ?? occurrence.id;
    final series = events.firstWhere(
      (e) => e.id == seriesId,
      orElse: () => occurrence,
    );
    final occurrenceDay = DateTime(
      occurrence.startLocal.year,
      occurrence.startLocal.month,
      occurrence.startLocal.day,
    );

    switch (scope) {
      case RecurrenceScope.all:
        // Keep the series' original start date; only the time of day
        // (and the other edited fields) change for the whole series.
        final seriesStart = series.startLocal;
        final editedStart = edited.startLocal;
        final duration = edited.endLocal.difference(editedStart);
        final newStart = DateTime(
          seriesStart.year,
          seriesStart.month,
          seriesStart.day,
          editedStart.hour,
          editedStart.minute,
        );
        final updated = edited.copyWith(
          id: seriesId,
          seriesId: null,
          startUtc: newStart.toUtc(),
          endUtc: newStart.add(duration).toUtc(),
          recurrenceEnd: null,
          excludedDates: const [],
        );
        await repo.saveEvent(updated);
        state = AsyncData([
          for (final e in events)
            if (e.id == seriesId) updated else e,
        ]);
      case RecurrenceScope.single:
        final truncated = series.copyWith(
          excludedDates: [...series.excludedDates, occurrenceDay],
        );
        final detached = edited.copyWith(
          id: 'evt-${DateTime.now().millisecondsSinceEpoch}',
          seriesId: null,
          recurrence: RecurrenceType.none,
          recurrenceRule: null,
        );
        await repo.saveEvent(truncated);
        await repo.saveEvent(detached);
        state = AsyncData([
          for (final e in events)
            if (e.id == seriesId) truncated else e,
          detached,
        ]);
      case RecurrenceScope.following:
        final truncated = series.copyWith(
          recurrenceEnd: occurrenceDay.subtract(const Duration(days: 1)),
        );
        final newSeries = edited.copyWith(
          id: 'evt-${DateTime.now().millisecondsSinceEpoch}',
          seriesId: null,
          recurrenceEnd: null,
          excludedDates: const [],
        );
        await repo.saveEvent(truncated);
        await repo.saveEvent(newSeries);
        state = AsyncData([
          for (final e in events)
            if (e.id == seriesId) truncated else e,
          newSeries,
        ]);
    }
  }

  /// Deletes one occurrence, this and following, or the whole series.
  Future<void> applyRecurringDelete({
    required CalendarEvent occurrence,
    required RecurrenceScope scope,
  }) async {
    final repo = ref.read(calendarRepositoryProvider);
    final events = state.value ?? [];
    final seriesId = occurrence.seriesId ?? occurrence.id;
    final series = events.firstWhere(
      (e) => e.id == seriesId,
      orElse: () => occurrence,
    );
    final occurrenceDay = DateTime(
      occurrence.startLocal.year,
      occurrence.startLocal.month,
      occurrence.startLocal.day,
    );

    switch (scope) {
      case RecurrenceScope.all:
        await repo.deleteEvent(seriesId);
        state = AsyncData([
          for (final e in events)
            if (e.id != seriesId) e,
        ]);
      case RecurrenceScope.single:
        final truncated = series.copyWith(
          excludedDates: [...series.excludedDates, occurrenceDay],
        );
        await repo.saveEvent(truncated);
        state = AsyncData([
          for (final e in events)
            if (e.id == seriesId) truncated else e,
        ]);
      case RecurrenceScope.following:
        final truncated = series.copyWith(
          recurrenceEnd: occurrenceDay.subtract(const Duration(days: 1)),
        );
        await repo.saveEvent(truncated);
        state = AsyncData([
          for (final e in events)
            if (e.id == seriesId) truncated else e,
        ]);
    }
  }
}

final eventsProvider =
    AsyncNotifierProvider<EventsNotifier, List<CalendarEvent>>(
      EventsNotifier.new,
    );

/// The user's calendars, with visibility toggles.
class CalendarsNotifier extends AsyncNotifier<List<AppCalendar>> {
  @override
  Future<List<AppCalendar>> build() =>
      ref.watch(calendarRepositoryProvider).getCalendars();

  Future<void> toggleVisibility(String id) async {
    state = AsyncData([
      for (final c in state.value ?? [])
        if (c.id == id) c.copyWith(visible: !c.visible) else c,
    ]);
  }
}

final calendarsProvider =
    AsyncNotifierProvider<CalendarsNotifier, List<AppCalendar>>(
      CalendarsNotifier.new,
    );

/// Ids of calendars that are currently visible.
final visibleCalendarIdsProvider = Provider<Set<String>>((ref) {
  final calendars = ref.watch(calendarsProvider).value ?? [];
  return {for (final c in calendars) if (c.visible) c.id};
});
