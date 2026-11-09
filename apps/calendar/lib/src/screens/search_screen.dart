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

/// Search events by title or location. Results are grouped by date;
/// tapping one jumps the calendar to that date.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final eventsAsync = ref.watch(eventsProvider);
    final visibleIds = ref.watch(visibleCalendarIdsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.search)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenEdge),
            child: DusSearchBar(
              controller: _controller,
              hintText: l10n.search,
              autofocus: true,
              onChanged: (value) =>
                  setState(() => _query = value.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: eventsAsync.when(
              loading: () => const DusLoadingSkeleton(),
              error: (error, _) => DusErrorState(
                message: l10n.error,
                onRetry: () => ref.invalidate(eventsProvider),
              ),
              data: (stored) {
                if (_query.isEmpty) {
                  return DusEmptyState(
                    icon: Icons.search,
                    title: l10n.search,
                  );
                }
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                final expanded = expandEvents(
                  stored,
                  today.subtract(const Duration(days: 30)),
                  today.add(const Duration(days: 90)),
                ).where((e) => visibleIds.contains(e.calendarId)).where((e) {
                  final haystack =
                      '${e.title} ${e.location ?? ''}'.toLowerCase();
                  return haystack.contains(_query);
                }).toList();
                if (expanded.isEmpty) {
                  return DusEmptyState(
                    icon: Icons.search_off_outlined,
                    title: l10n.noResults,
                  );
                }
                final colors = calendarColorsOf(ref);
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
                        for (final event in byDay[day]!)
                          EventCard(
                            event: event,
                            calendarColor:
                                colors[event.calendarId] ??
                                theme.colorScheme.primary,
                            onTap: () {
                              ref
                                  .read(selectedDateProvider.notifier)
                                  .select(event.startLocal);
                              Navigator.of(context).pop();
                            },
                          ),
                        const Divider(height: 1),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
