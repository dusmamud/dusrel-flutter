import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../models/calendar_event.dart';
import '../providers/calendar_providers.dart';
import '../widgets/event_details_sheet.dart';
import '../widgets/quick_add_sheet.dart';

/// Shared helpers for the calendar screens.
class ScreenHelpers {
  ScreenHelpers._();

  /// Opens the event details bottom sheet for [event].
  static Future<void> showEventDetails(
    BuildContext context,
    CalendarEvent event,
  ) {
    return showDusBottomSheet<void>(
      context,
      child: EventDetailsSheet(event: event),
    );
  }

  /// Opens the quick-add sheet for a tapped time slot.
  static Future<void> showQuickAdd(BuildContext context, DateTime start) {
    return showDusBottomSheet<void>(
      context,
      child: QuickAddSheet(start: start),
    );
  }
}

/// Reads the visible calendars' colors for event rendering.
Map<String, Color> calendarColorsOf(WidgetRef ref) {
  final calendars = ref.watch(calendarsProvider).value ?? [];
  return {for (final c in calendars) c.id: c.color};
}
