import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../models/calendar_event.dart';
import '../providers/calendar_providers.dart';
import '../utils/date_format.dart';
import 'event_card.dart';

/// The list of events for one day, shown under the month calendar and
/// reused by the agenda. Shows the empty state when there is nothing.
class DayEventsList extends ConsumerWidget {
  const DayEventsList({
    super.key,
    required this.day,
    required this.events,
    this.onEventTap,
    this.onAddTap,
  });

  final DateTime day;
  final List<CalendarEvent> events;
  final ValueChanged<CalendarEvent>? onEventTap;
  final VoidCallback? onAddTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (events.isEmpty) {
      return DusEmptyState(
        icon: Icons.event_available_outlined,
        title: l10n.calendarNoEvents,
        message: CalendarFormat.fullDate(day),
        actionLabel: l10n.calendarAddEvent,
        onAction: onAddTap,
      );
    }
    final calendars = ref.watch(calendarsProvider).value ?? [];
    final colors = {
      for (final c in calendars) c.id: c.color,
    };
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      itemCount: events.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final event = events[index];
        return EventCard(
          event: event,
          calendarColor:
              colors[event.calendarId] ??
              Theme.of(context).colorScheme.primary,
          onTap: onEventTap == null ? null : () => onEventTap!(event),
        );
      },
    );
  }
}
