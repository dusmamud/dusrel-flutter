import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../data/recurrence.dart';
import '../providers/calendar_providers.dart';
import '../utils/date_format.dart';
import '../widgets/time_grid.dart';
import 'screen_helpers.dart';

/// Week view: a 7-column time grid for the week containing the selected
/// date, with an all-day strip on top.
class WeekView extends ConsumerWidget {
  const WeekView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final settings = ref.watch(calendarSettingsProvider);
    final eventsAsync = ref.watch(eventsProvider);
    final visibleIds = ref.watch(visibleCalendarIdsProvider);

    return eventsAsync.when(
      loading: () => const DusLoadingSkeleton(),
      error: (error, _) => DusErrorState(
        message: error.toString(),
        onRetry: () => ref.invalidate(eventsProvider),
      ),
      data: (stored) {
        final weekStart = startOfWeek(selectedDate, settings.firstDayOfWeek);
        final days = List.generate(
          7,
          (i) => weekStart.add(Duration(days: i)),
        );
        final expanded = expandEvents(
          stored,
          weekStart,
          weekStart.add(const Duration(days: 6)),
        ).where((e) => visibleIds.contains(e.calendarId)).toList();
        return TimeGrid(
          days: days,
          events: expanded.where((e) => !e.isAllDay).toList(),
          allDayEvents: expanded.where((e) => e.isAllDay).toList(),
          calendarColors: calendarColorsOf(ref),
          onSlotTap: (slot) => ScreenHelpers.showQuickAdd(context, slot),
          onEventTap: (event) =>
              ScreenHelpers.showEventDetails(context, event),
        );
      },
    );
  }
}

/// Day view: a 24-hour vertical grid with a "now" line, an all-day strip
/// on top, and tap-to-create on any slot.
class DayView extends ConsumerWidget {
  const DayView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final eventsAsync = ref.watch(eventsProvider);
    final visibleIds = ref.watch(visibleCalendarIdsProvider);

    return eventsAsync.when(
      loading: () => const DusLoadingSkeleton(),
      error: (error, _) => DusErrorState(
        message: error.toString(),
        onRetry: () => ref.invalidate(eventsProvider),
      ),
      data: (stored) {
        final expanded = expandEvents(stored, selectedDate, selectedDate)
            .where((e) => visibleIds.contains(e.calendarId))
            .toList();
        return TimeGrid(
          days: [selectedDate],
          events: expanded.where((e) => !e.isAllDay).toList(),
          allDayEvents: expanded.where((e) => e.isAllDay).toList(),
          calendarColors: calendarColorsOf(ref),
          onSlotTap: (slot) => ScreenHelpers.showQuickAdd(context, slot),
          onEventTap: (event) =>
              ScreenHelpers.showEventDetails(context, event),
        );
      },
    );
  }
}
