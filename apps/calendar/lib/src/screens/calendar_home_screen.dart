import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../providers/calendar_providers.dart';
import '../utils/date_format.dart';
import 'agenda_view.dart';
import 'month_view.dart';
import 'week_day_views.dart';

/// The calendar home: top app bar (month/year title — tap to jump to a
/// date, Today button, prev/next chevrons), a segmented view switcher
/// that preserves the selected date, and a FAB to create an event.
class CalendarHomeScreen extends ConsumerWidget {
  const CalendarHomeScreen({super.key});

  void _shift(WidgetRef ref, CalendarView view, int direction) {
    final notifier = ref.read(selectedDateProvider.notifier);
    switch (view) {
      case CalendarView.month:
        notifier.shiftMonths(direction);
      case CalendarView.week:
        notifier.shiftWeeks(direction);
      case CalendarView.day:
        notifier.shiftDays(direction);
      case CalendarView.agenda:
        notifier.shiftDays(7 * direction);
    }
  }

  Future<void> _jumpToDate(BuildContext context, WidgetRef ref) async {
    final selectedDate = ref.read(selectedDateProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      ref.read(selectedDateProvider.notifier).select(picked);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selectedDate = ref.watch(selectedDateProvider);
    final view = ref.watch(calendarViewProvider);
    final viewLabels = <CalendarView, String>{
      CalendarView.day: l10n.calendarDay,
      CalendarView.week: l10n.calendarWeek,
      CalendarView.month: l10n.calendarMonth,
      CalendarView.agenda: l10n.calendarAgenda,
    };

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              tooltip: MaterialLocalizations.of(context).previousPageTooltip,
              onPressed: () => _shift(ref, view, -1),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => _jumpToDate(context, ref),
                child: Text(
                  CalendarFormat.monthYear(selectedDate),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              tooltip: MaterialLocalizations.of(context).nextPageTooltip,
              onPressed: () => _shift(ref, view, 1),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                ref.read(selectedDateProvider.notifier).goToday(),
            child: Text(l10n.calendarToday),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: l10n.search,
            onPressed: () => context.push('/search'),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'calendars') {
                context.push('/calendars');
              } else if (value == 'settings') {
                context.push('/settings');
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'calendars',
                child: Text(l10n.calendarCalendars),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Text(l10n.settings),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenEdge,
              AppSpacing.sm,
              AppSpacing.screenEdge,
              AppSpacing.sm,
            ),
            child: SegmentedButton<CalendarView>(
              segments: [
                for (final entry in viewLabels.entries)
                  ButtonSegment(
                    value: entry.key,
                    label: Text(entry.value),
                  ),
              ],
              selected: {view},
              onSelectionChanged: (selected) {
                ref.read(calendarViewProvider.notifier).set(selected.first);
              },
            ),
          ),
          Expanded(
            child: switch (view) {
              CalendarView.month => const MonthView(),
              CalendarView.week => const WeekView(),
              CalendarView.day => const DayView(),
              CalendarView.agenda => const AgendaView(),
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(
          '/event/new?date=${selectedDate.toIso8601String()}',
        ),
        tooltip: l10n.calendarAddEvent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
