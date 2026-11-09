import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../models/calendar_event.dart';
import '../providers/calendar_providers.dart';

/// Minimal quick-add: tap a time slot, type a title, save.
/// Creates a 1-hour event at the tapped slot; the full form is one tap
/// away from the event details sheet.
class QuickAddSheet extends ConsumerStatefulWidget {
  const QuickAddSheet({super.key, required this.start});

  final DateTime start;

  @override
  ConsumerState<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<QuickAddSheet> {
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    final settings = ref.read(calendarSettingsProvider);
    final calendars = ref.read(calendarsProvider).value ?? [];
    final calendarId = calendars.isNotEmpty ? calendars.first.id : 'personal';
    final event = CalendarEvent(
      id: 'evt-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      startUtc: widget.start.toUtc(),
      endUtc: widget.start.add(const Duration(hours: 1)).toUtc(),
      calendarId: calendarId,
      reminderMinutes: settings.defaultReminderMinutes,
    );
    await ref.read(eventsProvider.notifier).addEvent(event);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.screenEdge,
        right: AppSpacing.screenEdge,
        top: AppSpacing.screenEdge,
        bottom:
            AppSpacing.screenEdge + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DusTextField(
            controller: _titleController,
            hintText: l10n.eventTitle,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.lg),
          DusButton(
            label: l10n.save,
            expanded: true,
            onPressed: _titleController.text.trim().isEmpty ? null : _save,
          ),
        ],
      ),
    );
  }
}
