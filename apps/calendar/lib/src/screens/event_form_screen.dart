import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../data/recurrence.dart';
import '../models/calendar_event.dart';
import '../providers/calendar_providers.dart';
import '../utils/date_format.dart';
import '../widgets/event_details_sheet.dart';
import '../widgets/recurrence_dialog.dart';

/// Create / edit an event.
///
/// Create mode takes [initialDate]; edit mode takes [eventId], which may
/// be a stored id or an expanded occurrence id (`<seriesId>@2026-11-9`).
class EventFormScreen extends ConsumerStatefulWidget {
  const EventFormScreen({super.key, this.eventId, this.initialDate});

  final String? eventId;
  final DateTime? initialDate;

  @override
  ConsumerState<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends ConsumerState<EventFormScreen> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  CalendarEvent? _original;
  bool _ready = false;
  bool _isAllDay = false;
  late DateTime _start;
  late DateTime _end;
  RecurrenceType _recurrence = RecurrenceType.none;
  String? _recurrenceRule;
  String _calendarId = 'personal';
  int? _reminderMinutes;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _initFromEvent(CalendarEvent event) {
    _original = event;
    _titleController.text = event.title;
    _locationController.text = event.location ?? '';
    _notesController.text = event.notes ?? '';
    _isAllDay = event.isAllDay;
    _start = event.startLocal;
    _end = event.endLocal;
    _recurrence = event.recurrence;
    _recurrenceRule = event.recurrenceRule;
    _calendarId = event.calendarId;
    _reminderMinutes = event.reminderMinutes;
    _ready = true;
  }

  void _initForCreate() {
    final settings = ref.read(calendarSettingsProvider);
    final initial = widget.initialDate ?? DateTime.now();
    _start = DateTime(initial.year, initial.month, initial.day, 9);
    _end = _start.add(const Duration(hours: 1));
    _reminderMinutes = settings.defaultReminderMinutes;
    final calendars = ref.read(calendarsProvider).value ?? [];
    if (calendars.isNotEmpty) _calendarId = calendars.first.id;
    _ready = true;
  }

  CalendarEvent _buildEvent() {
    final start = _isAllDay
        ? DateTime(_start.year, _start.month, _start.day)
        : _start;
    final end = _isAllDay
        ? DateTime(_end.year, _end.month, _end.day, 23, 59)
        : _end;
    return CalendarEvent(
      id:
          _original?.id ??
          'evt-${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      startUtc: start.toUtc(),
      endUtc: end.toUtc(),
      isAllDay: _isAllDay,
      calendarId: _calendarId,
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      recurrence: _recurrence,
      recurrenceRule: _recurrence == RecurrenceType.custom
          ? _recurrenceRule
          : null,
      reminderMinutes: _reminderMinutes,
      seriesId: _original?.seriesId,
    );
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) return;
    final edited = _buildEvent();
    final notifier = ref.read(eventsProvider.notifier);
    final original = _original;
    if (original != null &&
        (original.isRecurring || original.seriesId != null)) {
      final scope = await showRecurrenceScopeDialog(context);
      if (scope == null) return;
      await notifier.applyRecurringEdit(
        occurrence: original,
        edited: edited,
        scope: scope,
      );
    } else if (original != null) {
      await notifier.updateEvent(edited);
    } else {
      await notifier.addEvent(edited);
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final current = isStart ? _start : _end;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked == null) return;
    setState(() {
      final updated = DateTime(
        picked.year,
        picked.month,
        picked.day,
        current.hour,
        current.minute,
      );
      if (isStart) {
        _start = updated;
        if (_end.isBefore(_start)) {
          _end = _start.add(const Duration(hours: 1));
        }
      } else {
        _end = updated;
        if (_end.isBefore(_start)) {
          _start = _end.subtract(const Duration(hours: 1));
        }
      }
    });
  }

  Future<void> _pickTime({required bool isStart}) async {
    final current = isStart ? _start : _end;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (picked == null) return;
    setState(() {
      final updated = DateTime(
        current.year,
        current.month,
        current.day,
        picked.hour,
        picked.minute,
      );
      if (isStart) {
        _start = updated;
        if (_end.isBefore(_start)) {
          _end = _start.add(const Duration(hours: 1));
        }
      } else {
        _end = updated;
        if (_end.isBefore(_start)) {
          _start = _end.subtract(const Duration(hours: 1));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final eventsAsync = ref.watch(eventsProvider);

    if (widget.eventId != null && !_ready) {
      return eventsAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: Text(l10n.calendarEditEvent)),
          body: const DusLoadingSkeleton(),
        ),
        error: (error, _) => Scaffold(
          appBar: AppBar(title: Text(l10n.calendarEditEvent)),
          body: DusErrorState(
            message: l10n.error,
            onRetry: () => ref.invalidate(eventsProvider),
          ),
        ),
        data: (stored) {
          final event = resolveEventForEdit(stored, widget.eventId!);
          if (event == null) {
            return Scaffold(
              appBar: AppBar(title: Text(l10n.calendarEditEvent)),
              body: DusEmptyState(
                icon: Icons.event_busy_outlined,
                title: l10n.error,
              ),
            );
          }
          _initFromEvent(event);
          return _buildForm(context);
        },
      );
    }
    if (!_ready) _initForCreate();
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final calendars = ref.watch(calendarsProvider).value ?? [];
    // The dropdown's value must always be one of its items, even while
    // calendars are still loading.
    final calendarItems = calendars.isEmpty
        ? [
            AppCalendar(
              id: _calendarId,
              name: _calendarId,
              color: theme.colorScheme.primary,
            ),
          ]
        : calendars;
    final reminderOptions = <int?>{
      null,
      5,
      10,
      15,
      30,
      60,
      120,
      1440,
      _reminderMinutes,
    }.toList()..sort((a, b) => (a ?? -1).compareTo(b ?? -1));
    final isEditing = _original != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? l10n.calendarEditEvent : l10n.calendarNewEvent,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenEdge),
        children: [
          DusTextField(
            controller: _titleController,
            label: l10n.eventTitle,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.lg),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.calendarAllDay),
            value: _isAllDay,
            onChanged: (value) => setState(() => _isAllDay = value),
          ),
          const Divider(),
          _DateTimeRow(
            label: l10n.eventStart,
            date: _start,
            showTime: !_isAllDay,
            onDateTap: () => _pickDate(isStart: true),
            onTimeTap: () => _pickTime(isStart: true),
          ),
          _DateTimeRow(
            label: l10n.eventEnd,
            date: _end,
            showTime: !_isAllDay,
            onDateTap: () => _pickDate(isStart: false),
            onTimeTap: () => _pickTime(isStart: false),
          ),
          const Divider(),
          DropdownButtonFormField<RecurrenceType>(
            initialValue: _recurrence,
            decoration: InputDecoration(
              labelText: l10n.calendarRepeat,
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(
                value: RecurrenceType.none,
                child: Text(l10n.repeatNever),
              ),
              DropdownMenuItem(
                value: RecurrenceType.daily,
                child: Text(l10n.calendarDaily),
              ),
              DropdownMenuItem(
                value: RecurrenceType.weekly,
                child: Text(l10n.calendarWeekly),
              ),
              DropdownMenuItem(
                value: RecurrenceType.monthly,
                child: Text(l10n.calendarMonthly),
              ),
              DropdownMenuItem(
                value: RecurrenceType.yearly,
                child: Text(l10n.calendarYearly),
              ),
              DropdownMenuItem(
                value: RecurrenceType.custom,
                child: Text(l10n.calendarCustom),
              ),
            ],
            onChanged: (value) async {
              if (value == null) return;
              if (value == RecurrenceType.custom) {
                final rule = await showCustomRecurrenceDialog(
                  context,
                  initialRule: _recurrenceRule,
                );
                if (rule == null) return;
                setState(() {
                  _recurrence = RecurrenceType.custom;
                  _recurrenceRule = rule;
                });
              } else {
                setState(() {
                  _recurrence = value;
                  _recurrenceRule = null;
                });
              }
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<String>(
            initialValue: _calendarId,
            decoration: InputDecoration(
              labelText: l10n.calendarCalendars,
              border: const OutlineInputBorder(),
            ),
            items: [
              for (final c in calendarItems)
                DropdownMenuItem(value: c.id, child: Text(c.name)),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _calendarId = value);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          DusTextField(
            controller: _locationController,
            label: l10n.calendarLocation,
            prefixIcon: Icons.place_outlined,
          ),
          const SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<int?>(
            initialValue: _reminderMinutes,
            decoration: InputDecoration(
              labelText: l10n.calendarReminder,
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(value: null, child: Text(l10n.reminderNone)),
              for (final minutes in reminderOptions.whereType<int>())
                DropdownMenuItem(
                  value: minutes,
                  child: Text(formatReminderMinutes(l10n, minutes)),
                ),
            ],
            onChanged: (value) =>
                setState(() => _reminderMinutes = value),
          ),
          const SizedBox(height: AppSpacing.lg),
          DusTextField(
            controller: _notesController,
            label: l10n.eventNotes,
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.xl),
          DusButton(
            label: l10n.save,
            icon: Icons.check,
            expanded: true,
            onPressed: _titleController.text.trim().isEmpty ? null : _save,
          ),
        ],
      ),
    );
  }
}

class _DateTimeRow extends StatelessWidget {
  const _DateTimeRow({
    required this.label,
    required this.date,
    required this.showTime,
    required this.onDateTap,
    required this.onTimeTap,
  });

  final String label;
  final DateTime date;
  final bool showTime;
  final VoidCallback onDateTap;
  final VoidCallback onTimeTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(label, style: theme.textTheme.titleSmall),
          ),
          Expanded(
            child: OutlinedButton(
              onPressed: onDateTap,
              child: Text(DateFormat.yMd().format(date)),
            ),
          ),
          if (showTime) ...[
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: OutlinedButton(
                onPressed: onTimeTap,
                child: Text(CalendarFormat.time(date)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
