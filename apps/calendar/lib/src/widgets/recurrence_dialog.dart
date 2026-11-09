import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../data/recurrence.dart';
import '../models/calendar_event.dart';

/// Asks which occurrences an edit/delete of a recurring event applies to.
/// Returns null when the user cancels.
Future<RecurrenceScope?> showRecurrenceScopeDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showDialog<RecurrenceScope>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.calendarRepeat),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ScopeOption(
            label: l10n.scopeThisEvent,
            value: RecurrenceScope.single,
          ),
          _ScopeOption(
            label: l10n.scopeThisAndFollowing,
            value: RecurrenceScope.following,
          ),
          _ScopeOption(
            label: l10n.scopeAllEvents,
            value: RecurrenceScope.all,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
      ],
    ),
  );
}

class _ScopeOption extends StatelessWidget {
  const _ScopeOption({required this.label, required this.value});

  final String label;
  final RecurrenceScope value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      onTap: () => Navigator.of(context).pop(value),
    );
  }
}

enum _EndRule { never, onDate, afterOccurrences }

/// The "Custom…" repeat dialog: frequency, interval, weekdays and an end
/// rule. Returns the RRULE-style rule string, or null on cancel.
Future<String?> showCustomRecurrenceDialog(
  BuildContext context, {
  String? initialRule,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _CustomRecurrenceDialog(initialRule: initialRule),
  );
}

class _CustomRecurrenceDialog extends StatefulWidget {
  const _CustomRecurrenceDialog({this.initialRule});

  final String? initialRule;

  @override
  State<_CustomRecurrenceDialog> createState() =>
      _CustomRecurrenceDialogState();
}

class _CustomRecurrenceDialogState extends State<_CustomRecurrenceDialog> {
  late String _frequency;
  late TextEditingController _intervalController;
  late Set<int> _weekdays;
  _EndRule _endRule = _EndRule.never;
  DateTime? _untilDate;
  late TextEditingController _countController;

  @override
  void initState() {
    super.initState();
    final parsed = RecurrenceRule.parse(widget.initialRule, RecurrenceType.custom);
    _frequency = parsed.frequency;
    _intervalController = TextEditingController(
      text: '${parsed.interval}',
    );
    _weekdays = parsed.byWeekdays.isEmpty
        ? {DateTime.now().weekday}
        : parsed.byWeekdays.toSet();
    _countController = TextEditingController(
      text: parsed.count != null ? '${parsed.count}' : '10',
    );
    if (parsed.until != null) {
      _endRule = _EndRule.onDate;
      _untilDate = parsed.until;
    } else if (parsed.count != null) {
      _endRule = _EndRule.afterOccurrences;
    }
  }

  @override
  void dispose() {
    _intervalController.dispose();
    _countController.dispose();
    super.dispose();
  }

  String _buildRule() {
    return RecurrenceRule.build(
      frequency: _frequency,
      interval: int.tryParse(_intervalController.text) ?? 1,
      byWeekdays: _frequency == 'WEEKLY' ? _weekdays.toList() : const [],
      until: _endRule == _EndRule.onDate ? _untilDate : null,
      count: _endRule == _EndRule.afterOccurrences
          ? int.tryParse(_countController.text)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final frequencies = <String, String>{
      'DAILY': l10n.calendarDaily,
      'WEEKLY': l10n.calendarWeekly,
      'MONTHLY': l10n.calendarMonthly,
      'YEARLY': l10n.calendarYearly,
    };
    return AlertDialog(
      title: Text(l10n.calendarCustom),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _frequency,
              decoration: InputDecoration(
                labelText: l10n.calendarRepeat,
                border: const OutlineInputBorder(),
              ),
              items: [
                for (final entry in frequencies.entries)
                  DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _frequency = value);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _intervalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.recurrenceInterval,
                border: const OutlineInputBorder(),
              ),
            ),
            if (_frequency == 'WEEKLY') ...[
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.xs,
                children: [
                  for (var i = 0; i < 7; i++)
                    FilterChip(
                      label: Text(
                        DateFormat.E().format(
                          DateTime(2024, 1, 1).add(Duration(days: i)),
                        ),
                      ),
                      selected: _weekdays.contains(DateTime.monday + i),
                      onSelected: (selected) {
                        setState(() {
                          final weekday = DateTime.monday + i;
                          if (selected) {
                            _weekdays.add(weekday);
                          } else {
                            _weekdays.remove(weekday);
                          }
                        });
                      },
                    ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            RadioGroup<_EndRule>(
              groupValue: _endRule,
              onChanged: (value) {
                if (value != null) setState(() => _endRule = value);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<_EndRule>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.endsNever),
                    value: _EndRule.never,
                  ),
                  RadioListTile<_EndRule>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.endsOnDate),
                    value: _EndRule.onDate,
                  ),
                  if (_endRule == _EndRule.onDate)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _untilDate == null
                            ? l10n.calendarToday
                            : DateFormat.yMd().format(_untilDate!),
                      ),
                      trailing: const Icon(Icons.calendar_today_outlined),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _untilDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365 * 5),
                          ),
                        );
                        if (picked != null) {
                          setState(() => _untilDate = picked);
                        }
                      },
                    ),
                  RadioListTile<_EndRule>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.endsAfterOccurrences),
                    value: _EndRule.afterOccurrences,
                  ),
                  if (_endRule == _EndRule.afterOccurrences)
                    TextField(
                      controller: _countController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.recurrenceOccurrences,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_buildRule()),
          child: Text(l10n.done),
        ),
      ],
    );
  }
}
