import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

import '../models/calendar_event.dart';
import '../utils/date_format.dart';

/// One row in a list of events: color bar, title, time and location.
class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.calendarColor,
    this.onTap,
  });

  final CalendarEvent event;
  final Color calendarColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final start = event.startLocal;
    final end = event.endLocal;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenEdge,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: AppSizes.minTouchTarget,
                decoration: BoxDecoration(
                  color: calendarColor,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          event.isAllDay
                              ? Icons.event
                              : Icons.schedule,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            event.isAllDay
                                ? l10n.calendarAllDay
                                : CalendarFormat.timeRange(start, end),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        if (event.isRecurring) ...[
                          const SizedBox(width: AppSpacing.xs),
                          Icon(
                            Icons.repeat,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                            semanticLabel: l10n.calendarRepeat,
                          ),
                        ],
                      ],
                    ),
                    if (event.location != null &&
                        event.location!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Icon(
                            Icons.place_outlined,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              event.location!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
