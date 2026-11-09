import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

import '../data/recurrence.dart';
import '../models/calendar_event.dart';
import '../utils/date_format.dart';

/// Where one timed event sits inside a day column.
class PlacedEvent {
  const PlacedEvent({
    required this.event,
    required this.column,
    required this.columnCount,
  });

  final CalendarEvent event;
  final int column;
  final int columnCount;
}

/// Lays out a day's timed events into side-by-side columns.
///
/// Events that overlap (transitively) form a cluster; inside a cluster
/// each event gets the first free column, and every event in the cluster
/// shares the cluster's column count so widths stay consistent.
List<PlacedEvent> layoutDayEvents(List<CalendarEvent> dayEvents) {
  final sorted = List.of(dayEvents)
    ..sort((a, b) {
      final byStart = a.startLocal.compareTo(b.startLocal);
      return byStart != 0
          ? byStart
          : a.endLocal.compareTo(b.endLocal);
    });
  final result = <PlacedEvent>[];
  var i = 0;
  while (i < sorted.length) {
    var j = i;
    var clusterEnd = sorted[i].endLocal;
    while (j + 1 < sorted.length &&
        sorted[j + 1].startLocal.isBefore(clusterEnd)) {
      j++;
      if (sorted[j].endLocal.isAfter(clusterEnd)) {
        clusterEnd = sorted[j].endLocal;
      }
    }
    final cluster = sorted.sublist(i, j + 1);
    final columnEnds = <DateTime>[];
    final placed = <PlacedEvent>[];
    for (final event in cluster) {
      var column = columnEnds.indexWhere(
        (end) => !event.startLocal.isBefore(end),
      );
      if (column == -1) {
        column = columnEnds.length;
        columnEnds.add(event.endLocal);
      } else {
        columnEnds[column] = event.endLocal;
      }
      placed.add(PlacedEvent(event: event, column: column, columnCount: 0));
    }
    final count = columnEnds.length;
    result.addAll([
      for (final p in placed)
        PlacedEvent(event: p.event, column: p.column, columnCount: count),
    ]);
    i = j + 1;
  }
  return result;
}

/// A scrollable time grid for one or seven days.
///
/// Hour rows with event blocks sized by duration, overlapping events side
/// by side, an all-day strip on top and a "now" line on today's column.
/// Tapping an empty slot calls [onSlotTap] with the tapped hour.
class TimeGrid extends StatelessWidget {
  const TimeGrid({
    super.key,
    required this.days,
    required this.events,
    required this.allDayEvents,
    required this.calendarColors,
    required this.onSlotTap,
    required this.onEventTap,
    this.hourHeight = 60,
    this.initialHour = 7,
  });

  final List<DateTime> days;
  final List<CalendarEvent> events;
  final List<CalendarEvent> allDayEvents;
  final Map<String, Color> calendarColors;
  final ValueChanged<DateTime> onSlotTap;
  final ValueChanged<CalendarEvent> onEventTap;
  final double hourHeight;
  final int initialHour;

  static const double _gutterWidth = 52;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final controller = ScrollController(
      initialScrollOffset: initialHour * hourHeight,
    );
    final totalHeight = 24 * hourHeight;
    return Column(
      children: [
        _DayHeaderRow(days: days),
        _AllDayStrip(
          days: days,
          allDayEvents: allDayEvents,
          calendarColors: calendarColors,
          label: l10n.calendarAllDay,
          onEventTap: onEventTap,
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: controller,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: _gutterWidth,
                  height: totalHeight,
                  child: Stack(
                    children: [
                      for (var hour = 0; hour < 24; hour++)
                        Positioned(
                          top: hour * hourHeight - 7,
                          right: AppSpacing.sm,
                          child: Text(
                            CalendarFormat.hourLabel(
                              DateTime(2000, 1, 1, hour),
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                for (final day in days)
                  Expanded(
                    child: _DayColumn(
                      day: day,
                      events: eventsOnDay(events, day)
                          .where((e) => !e.isAllDay)
                          .toList(),
                      calendarColors: calendarColors,
                      hourHeight: hourHeight,
                      totalHeight: totalHeight,
                      onSlotTap: onSlotTap,
                      onEventTap: onEventTap,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DayHeaderRow extends StatelessWidget {
  const _DayHeaderRow({required this.days});

  final List<DateTime> days;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    return Row(
      children: [
        const SizedBox(width: TimeGrid._gutterWidth),
        for (final day in days)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Column(
                children: [
                  Text(
                    CalendarFormat.weekdayShort(day).toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isSameLocalDay(day, today)
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSameLocalDay(day, today)
                          ? theme.colorScheme.primary
                          : null,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${day.day}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isSameLocalDay(day, today)
                            ? theme.colorScheme.onPrimary
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _AllDayStrip extends StatelessWidget {
  const _AllDayStrip({
    required this.days,
    required this.allDayEvents,
    required this.calendarColors,
    required this.label,
    required this.onEventTap,
  });

  final List<DateTime> days;
  final List<CalendarEvent> allDayEvents;
  final Map<String, Color> calendarColors;
  final String label;
  final ValueChanged<CalendarEvent> onEventTap;

  @override
  Widget build(BuildContext context) {
    // Keyed for tests: the all-day strip must be findable.
    final visible = <CalendarEvent>[];
    for (final event in allDayEvents) {
      if (days.any((d) => eventsOnDay([event], d).isNotEmpty)) {
        visible.add(event);
      }
    }
    if (visible.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Container(
      key: const ValueKey('allDayStrip'),
      padding: const EdgeInsets.only(
        right: AppSpacing.sm,
        bottom: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: TimeGrid._gutterWidth,
            child: Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.xs,
                right: AppSpacing.sm,
              ),
              child: Text(
                label,
                textAlign: TextAlign.right,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final event in visible)
                  GestureDetector(
                    onTap: () => onEventTap(event),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (calendarColors[event.calendarId] ??
                                    theme.colorScheme.primary)
                                .withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                      child: Text(
                        event.title,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.day,
    required this.events,
    required this.calendarColors,
    required this.hourHeight,
    required this.totalHeight,
    required this.onSlotTap,
    required this.onEventTap,
  });

  final DateTime day;
  final List<CalendarEvent> events;
  final Map<String, Color> calendarColors;
  final double hourHeight;
  final double totalHeight;
  final ValueChanged<DateTime> onSlotTap;
  final ValueChanged<CalendarEvent> onEventTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final placed = layoutDayEvents(events);
    final now = DateTime.now();
    final showNowLine = isSameLocalDay(day, now);
    final nowOffset =
        (now.hour + now.minute / 60 + now.second / 3600) * hourHeight;
    return SizedBox(
      height: totalHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) {
                final hour = (details.localPosition.dy / hourHeight)
                    .floor()
                    .clamp(0, 23);
                onSlotTap(DateTime(day.year, day.month, day.day, hour));
              },
              child: Column(
                children: [
                  for (var hour = 0; hour < 24; hour++)
                    Container(
                      height: hourHeight,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (showNowLine)
            Positioned(
              top: nowOffset,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          for (final p in placed)
            _EventBlock(
              placed: p,
              calendarColor:
                  calendarColors[p.event.calendarId] ??
                  theme.colorScheme.primary,
              hourHeight: hourHeight,
              onTap: () => onEventTap(p.event),
            ),
        ],
      ),
    );
  }
}

class _EventBlock extends StatelessWidget {
  const _EventBlock({
    required this.placed,
    required this.calendarColor,
    required this.hourHeight,
    required this.onTap,
  });

  final PlacedEvent placed;
  final Color calendarColor;
  final double hourHeight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final event = placed.event;
    final start = event.startLocal;
    final end = event.endLocal;
    final dayStart = DateTime(start.year, start.month, start.day);
    final startMinutes = start.difference(dayStart).inMinutes.toDouble();
    final durationMinutes = end.difference(start).inMinutes.toDouble();
    final top = startMinutes / 60 * hourHeight;
    final height = (durationMinutes / 60 * hourHeight).clamp(24.0, 24 * 60.0);
    final widthFraction = 1 / placed.columnCount;
    // FractionallySizedBox alignment is in [-1, 1]; the x that puts the
    // block's left edge at column c of n is 2c/(n-1) - 1.
    final alignmentX = placed.columnCount <= 1
        ? -1.0
        : 2 * placed.column / (placed.columnCount - 1) - 1;
    return Positioned(
      top: top,
      height: height,
      left: 0,
      right: 0,
      child: FractionallySizedBox(
        alignment: Alignment(alignmentX, 0),
        widthFactor: widthFraction,
        child: Padding(
          padding: const EdgeInsets.only(right: 2),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: calendarColor.withValues(alpha: 0.16),
                border: Border(
                  left: BorderSide(color: calendarColor, width: 3),
                ),
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              // A single Text with maxLines can never overflow the block,
              // however short it is; the container clips any glyph spill.
              clipBehavior: Clip.hardEdge,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: event.title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (height >= 44)
                      TextSpan(
                        text:
                            '\n${CalendarFormat.timeRange(start, end)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                maxLines: height >= 44 ? 2 : 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
