import 'package:calendar/main.dart';
import 'package:calendar/src/providers/calendar_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:table_calendar/table_calendar.dart';

/// A selected-date notifier pinned to one day, so tests can look at a
/// known date (e.g. the day of the all-day birthday event).
class _FixedDateNotifier extends SelectedDateNotifier {
  _FixedDateNotifier(this.fixed);

  final DateTime fixed;

  @override
  DateTime build() => fixed;
}

DateTime _dayPlus(int days) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return today.add(Duration(days: days));
}

/// Pumps the app with a tall viewport so lists and forms fit on screen
/// without scrolling (the test surface is 800x600 by default).
Future<void> _pumpApp(WidgetTester tester, Widget app) async {
  tester.view.physicalSize = const Size(800, 1800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(app);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('month view renders mock events for today', (tester) async {
    await _pumpApp(tester, const ProviderScope(child: CalendarApp()));

    // Today is selected by default; its events list below the month grid.
    expect(find.text('Team standup'), findsOneWidget);
    expect(find.text('Lunch with Priya'), findsOneWidget);
    expect(find.text('Yoga class'), findsOneWidget);
    // The month grid itself renders.
    expect(
      find.byWidgetPredicate((widget) => widget is TableCalendar),
      findsOneWidget,
    );
  });

  testWidgets('creating an event appears in the agenda', (tester) async {
    await _pumpApp(tester, const ProviderScope(child: CalendarApp()));

    // Open the create form from the FAB.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('New event'), findsOneWidget);

    // The first text field is the title.
    await tester.enterText(find.byType(TextField).first, 'Test event');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Back on the home screen; switch to the agenda view.
    await tester.tap(find.text('Agenda'));
    await tester.pumpAndSettle();
    expect(find.text('Test event'), findsOneWidget);
  });

  testWidgets('all-day events render in the all-day strip', (tester) async {
    // Anaya's birthday is an all-day mock event 3 days from today.
    await _pumpApp(
      tester,
      ProviderScope(
        overrides: [
          selectedDateProvider.overrideWith(
            () => _FixedDateNotifier(_dayPlus(3)),
          ),
        ],
        child: const CalendarApp(),
      ),
    );

    await tester.tap(find.text('Day'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('allDayStrip')), findsOneWidget);
    expect(find.text("Anaya's birthday"), findsOneWidget);
  });

  testWidgets('week view renders the week grid', (tester) async {
    await _pumpApp(tester, const ProviderScope(child: CalendarApp()));

    await tester.tap(find.text('Week'));
    await tester.pumpAndSettle();

    // Today's standup is a weekday recurring event, so it renders once
    // per weekday (Mon–Fri) in the week grid.
    expect(find.text('Team standup'), findsNWidgets(5));
  });
}
