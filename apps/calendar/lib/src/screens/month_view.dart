import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:ui_kit/ui_kit.dart';

import '../data/recurrence.dart';
import '../models/calendar_event.dart';
import '../providers/calendar_providers.dart';
import '../utils/date_format.dart' as df;
import '../widgets/day_events_list.dart';
import 'screen_helpers.dart';

/// Month view (home): a [TableCalendar] with event markers, and the
/// selected day's events listed below it.
class MonthView extends ConsumerWidget {
  const MonthView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final settings = ref.watch(calendarSettingsProvider);
    final eventsAsync = ref.watch(eventsProvider);
    final visibleIds = ref.watch(visibleCalendarIdsProvider);
    final theme = Theme.of(context);

    return eventsAsync.when(
      loading: () => const DusLoadingSkeleton(),
      error: (error, _) => DusErrorState(
        message: error.toString(),
        onRetry: () => ref.invalidate(eventsProvider),
      ),
      data: (stored) {
        // Expand a generous window around the selected month so markers
        // and the day list are cheap to compute.
        final windowStart = DateTime(
          selectedDate.year,
          selectedDate.month - 1,
          1,
        );
        final windowEnd = DateTime(selectedDate.year, selectedDate.month + 2, 0);
        final expanded = expandEvents(stored, windowStart, windowEnd)
            .where((e) => visibleIds.contains(e.calendarId))
            .toList();
        final dayEvents = eventsOnDay(expanded, selectedDate);
        final colors = calendarColorsOf(ref);
        final now = DateTime.now();
        return Column(
          children: [
            TableCalendar<CalendarEvent>(
              firstDay: DateTime(now.year - 1, 1, 1),
              lastDay: DateTime(now.year + 2, 12, 31),
              focusedDay: selectedDate,
              selectedDayPredicate: (day) =>
                  isSameDay(day, selectedDate),
              calendarFormat: CalendarFormat.month,
              headerVisible: false,
              startingDayOfWeek:
                  settings.firstDayOfWeek == DateTime.sunday
                  ? StartingDayOfWeek.sunday
                  : StartingDayOfWeek.monday,
              locale: Localizations.localeOf(context).toString(),
              eventLoader: (day) => eventsOnDay(expanded, day),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isEmpty) return null;
                  return Positioned(
                    bottom: 1,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final event in events.take(3))
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color:
                                  colors[event.calendarId] ??
                                  theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        if (events.length > 3)
                          Padding(
                            padding: const EdgeInsets.only(left: 2),
                            child: Text(
                              '+${events.length - 3}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              onDaySelected: (selectedDay, focusedDay) {
                ref.read(selectedDateProvider.notifier).select(selectedDay);
              },
              onPageChanged: (focusedDay) {
                ref.read(selectedDateProvider.notifier).select(focusedDay);
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenEdge,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Text(
                    df.CalendarFormat.fullDate(selectedDate),
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            Expanded(
              child: DayEventsList(
                day: selectedDate,
                events: dayEvents,
                onEventTap: (event) =>
                    ScreenHelpers.showEventDetails(context, event),
                onAddTap: () => ScreenHelpers.showQuickAdd(
                  context,
                  DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    9,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
