import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../providers/calendar_providers.dart';
import '../widgets/event_details_sheet.dart';

/// Settings: default view, first day of week, default reminder and theme.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(calendarSettingsProvider);
    final viewLabels = <CalendarView, String>{
      CalendarView.day: l10n.calendarDay,
      CalendarView.week: l10n.calendarWeek,
      CalendarView.month: l10n.calendarMonth,
      CalendarView.agenda: l10n.calendarAgenda,
    };
    // Weekday names come from intl so they follow the active locale.
    final weekdayLabels = <int, String>{
      DateTime.monday: DateFormat.E().format(DateTime(2024, 1, 1)),
      DateTime.sunday: DateFormat.E().format(DateTime(2024, 1, 7)),
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenEdge),
        children: [
          DropdownButtonFormField<CalendarView>(
            initialValue: settings.defaultView,
            decoration: InputDecoration(
              labelText: l10n.defaultView,
              border: const OutlineInputBorder(),
            ),
            items: [
              for (final entry in viewLabels.entries)
                DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                ),
            ],
            onChanged: (value) {
              if (value != null) {
                ref
                    .read(calendarSettingsProvider.notifier)
                    .setDefaultView(value);
                ref.read(calendarViewProvider.notifier).set(value);
              }
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<int>(
            initialValue: settings.firstDayOfWeek,
            decoration: InputDecoration(
              labelText: l10n.firstDayOfWeek,
              border: const OutlineInputBorder(),
            ),
            items: [
              for (final entry in weekdayLabels.entries)
                DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                ),
            ],
            onChanged: (value) {
              if (value != null) {
                ref
                    .read(calendarSettingsProvider.notifier)
                    .setFirstDayOfWeek(value);
              }
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<int?>(
            initialValue: settings.defaultReminderMinutes,
            decoration: InputDecoration(
              labelText: l10n.calendarReminder,
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(value: null, child: Text(l10n.reminderNone)),
              for (final minutes in [5, 10, 15, 30, 60, 120, 1440])
                DropdownMenuItem(
                  value: minutes,
                  child: Text(formatReminderMinutes(l10n, minutes)),
                ),
            ],
            onChanged: (value) => ref
                .read(calendarSettingsProvider.notifier)
                .setDefaultReminder(value),
          ),
          const SizedBox(height: AppSpacing.lg),
          const _ThemeModeSegment(),
        ],
      ),
    );
  }
}

class _ThemeModeSegment extends ConsumerWidget {
  const _ThemeModeSegment();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);
    return SegmentedButton<ThemeMode>(
      segments: [
        ButtonSegment(
          value: ThemeMode.system,
          icon: Tooltip(
            message: l10n.themeSystem,
            child: Icon(Icons.brightness_auto_outlined),
          ),
        ),
        ButtonSegment(
          value: ThemeMode.light,
          icon: Tooltip(
            message: l10n.themeLight,
            child: Icon(Icons.light_mode_outlined),
          ),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          icon: Tooltip(
            message: l10n.themeDark,
            child: Icon(Icons.dark_mode_outlined),
          ),
        ),
      ],
      selected: {themeMode},
      onSelectionChanged: (selected) {
        ref.read(themeModeProvider.notifier).set(selected.first);
      },
    );
  }
}
