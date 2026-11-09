import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../data/recurrence.dart';
import '../models/calendar_event.dart';
import '../providers/calendar_providers.dart';
import '../utils/date_format.dart';
import '../widgets/event_card.dart';
import 'screen_helpers.dart';

/// Agenda view: a chronological list of upcoming events for the next 30
/// days, grouped by date ("Today" for today, full date otherwise).
class AgendaView extends ConsumerWidget {
  const AgendaView({super.key});

  static const int _rangeDays = 30;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final eventsAsync = ref.watch(eventsProvider);
    final visibleIds = ref.watch(visibleCalendarIdsProvider);

    return eventsAsync.when(
      loading: () => const DusLoadingSkeleton(),
      error: (error, _) => DusErrorState(
        message: error.toString(),
        onRetry: () => ref.invalidate(eventsProvider),
      ),
      data: (stored) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final end = today.add(const Duration(days: _rangeDays - 1));
        final expanded = expandEvents(stored, today, end)
            .where((e) => visibleIds.contains(e.calendarId))
            .toList();
        if (expanded.isEmpty) {
          return DusEmptyState(
            icon: Icons.event_available_outlined,
            title: l10n.calendarNoEvents,
          );
        }
        final colors = calendarColorsOf(ref);
        // Group by local day, keeping chronological order.
        final byDay = <DateTime, List<CalendarEvent>>{};
        for (final event in expanded) {
          final day = DateTime(
            event.startLocal.year,
            event.startLocal.month,
            event.startLocal.day,
          );
          (byDay[day] ??= []).add(event);
        }
        final days = byDay.keys.toList()..sort();
        return ListView.builder(
          itemCount: days.length,
          itemBuilder: (context, index) {
            final day = days[index];
            final dayEvents = byDay[day]!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenEdge,
                    AppSpacing.lg,
                    AppSpacing.screenEdge,
                    AppSpacing.sm,
                  ),
                  child: Text(
                    isSameLocalDay(day, today)
                        ? l10n.calendarToday
                        : CalendarFormat.fullDate(day),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                for (final event in dayEvents)
                  EventCard(
                    event: event,
                    calendarColor:
                        colors[event.calendarId] ??
                        theme.colorScheme.primary,
                    onTap: () =>
                        ScreenHelpers.showEventDetails(context, event),
                  ),
                const Divider(height: 1),
              ],
            );
          },
        );
      },
    );
  }
}
