import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../providers/calendar_providers.dart';

/// The calendars manager: every calendar with its color dot, name and a
/// visibility toggle. Hidden calendars' events stop rendering.
class CalendarsScreen extends ConsumerWidget {
  const CalendarsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final calendarsAsync = ref.watch(calendarsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.calendarCalendars)),
      body: calendarsAsync.when(
        loading: () => const DusLoadingSkeleton(),
        error: (error, _) => DusErrorState(
          message: l10n.error,
          onRetry: () => ref.invalidate(calendarsProvider),
        ),
        data: (calendars) {
          if (calendars.isEmpty) {
            return DusEmptyState(
              icon: Icons.event_outlined,
              title: l10n.calendarCalendars,
            );
          }
          return ListView.separated(
            itemCount: calendars.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final calendar = calendars[index];
              return SwitchListTile(
                secondary: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: calendar.color,
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(
                  calendar.name,
                  style: theme.textTheme.titleMedium,
                ),
                value: calendar.visible,
                onChanged: (_) => ref
                    .read(calendarsProvider.notifier)
                    .toggleVisibility(calendar.id),
              );
            },
          );
        },
      ),
    );
  }
}
