import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../models/calendar_event.dart';
import '../providers/calendar_providers.dart';
import '../utils/date_format.dart';
import 'recurrence_dialog.dart';

/// The bottom sheet shown when an event is tapped: title, time, location,
/// calendar, reminder and Edit / Duplicate / Delete actions.
class EventDetailsSheet extends ConsumerWidget {
  const EventDetailsSheet({super.key, required this.event});

  final CalendarEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final calendars = ref.watch(calendarsProvider).value ?? [];
    final calendar = calendars.firstWhere(
      (c) => c.id == event.calendarId,
      orElse: () => calendars.isNotEmpty
          ? calendars.first
          : const AppCalendar(id: '', name: '', color: Colors.blue),
    );
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenEdge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: calendar.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(event.title, style: theme.textTheme.titleLarge),
              ),
              if (event.isRecurring)
                Icon(
                  Icons.repeat,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                  semanticLabel: l10n.calendarRepeat,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _DetailRow(
            icon: Icons.schedule,
            text: event.isAllDay
                ? '${CalendarFormat.fullDate(event.startLocal)} · ${l10n.calendarAllDay}'
                : '${CalendarFormat.fullDate(event.startLocal)} · ${CalendarFormat.timeRange(event.startLocal, event.endLocal)}',
          ),
          if (event.location != null && event.location!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _DetailRow(icon: Icons.place_outlined, text: event.location!),
          ],
          const SizedBox(height: AppSpacing.sm),
          _DetailRow(
            icon: Icons.event,
            text: calendar.name,
          ),
          if (event.reminderMinutes != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _DetailRow(
              icon: Icons.notifications_outlined,
              text:
                  '${l10n.calendarReminder}: ${formatReminderMinutes(l10n, event.reminderMinutes!)}',
            ),
          ],
          if (event.notes != null && event.notes!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _DetailRow(icon: Icons.notes, text: event.notes!),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: DusButton(
                  label: l10n.edit,
                  icon: Icons.edit_outlined,
                  variant: DusButtonVariant.tonal,
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push('/event/${event.id}/edit');
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: DusButton(
                  label: l10n.duplicate,
                  icon: Icons.copy_outlined,
                  variant: DusButtonVariant.outlined,
                  onPressed: () async {
                    Navigator.of(context).pop();
                    final copy = event.copyWith(
                      id: 'evt-${DateTime.now().millisecondsSinceEpoch}',
                      seriesId: null,
                      recurrence: RecurrenceType.none,
                      recurrenceRule: null,
                      startUtc: event.startUtc.add(const Duration(days: 1)),
                      endUtc: event.endUtc.add(const Duration(days: 1)),
                    );
                    await ref.read(eventsProvider.notifier).addEvent(copy);
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: DusButton(
                  label: l10n.delete,
                  icon: Icons.delete_outline,
                  variant: DusButtonVariant.outlined,
                  onPressed: () => _onDelete(context, ref),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _onDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    RecurrenceScope scope = RecurrenceScope.all;
    if (event.isRecurring || event.seriesId != null) {
      final chosen = await showRecurrenceScopeDialog(context);
      if (chosen == null) return;
      scope = chosen;
    } else {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.delete),
          content: Text(event.title),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.delete),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    if (!context.mounted) return;
    Navigator.of(context).pop();
    final notifier = ref.read(eventsProvider.notifier);
    if (event.isRecurring || event.seriesId != null) {
      await notifier.applyRecurringDelete(occurrence: event, scope: scope);
    } else {
      await notifier.deleteEvent(event.id);
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
      ],
    );
  }
}

/// Human-readable reminder duration for the values used in the
/// reminder pickers. Other minute counts fall back to a plain number.
String formatReminderMinutes(AppLocalizations l10n, int minutes) {
  if (minutes == 1440) return l10n.reminder1day;
  if (minutes == 60) return l10n.reminder1hour;
  if (minutes == 5) return l10n.reminder5min;
  if (minutes < 60) return '$minutes min';
  if (minutes % 60 == 0) {
    final hours = minutes ~/ 60;
    return '$hours hours';
  }
  return '$minutes min';
}
