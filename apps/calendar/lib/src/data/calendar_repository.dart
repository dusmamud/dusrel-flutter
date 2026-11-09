import 'package:flutter/material.dart';

import '../models/calendar_event.dart';

/// Data source behind the calendar screens.
///
/// The UI only talks to this interface, so the mock implementation can be
/// swapped for a local database or a sync backend later without touching
/// any screen.
abstract class CalendarRepository {
  Future<List<AppCalendar>> getCalendars();
  Future<List<CalendarEvent>> getEvents();
  Future<void> saveEvent(CalendarEvent event);
  Future<void> deleteEvent(String id);
}

/// In-memory mock data: ~15 events across 3 calendars, anchored to today
/// so the app always has something to show. Mix of timed, all-day,
/// multi-day and recurring events.
class MockCalendarRepository implements CalendarRepository {
  MockCalendarRepository() {
    _calendars = [
      const AppCalendar(id: 'personal', name: 'Personal', color: Colors.blue),
      const AppCalendar(id: 'work', name: 'Work', color: Colors.green),
      const AppCalendar(id: 'family', name: 'Family', color: Colors.orange),
    ];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime at(int dayOffset, int hour, [int minute = 0]) =>
        today.add(Duration(days: dayOffset, hours: hour, minutes: minute));

    _events = [
      CalendarEvent(
        id: 'standup',
        title: 'Team standup',
        startUtc: at(0, 9).toUtc(),
        endUtc: at(0, 9, 30).toUtc(),
        calendarId: 'work',
        location: 'Google Meet',
        recurrence: RecurrenceType.weekly,
        recurrenceRule: 'FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,TU,WE,TH,FR',
        reminderMinutes: 10,
      ),
      CalendarEvent(
        id: 'lunch-priya',
        title: 'Lunch with Priya',
        startUtc: at(0, 12, 30).toUtc(),
        endUtc: at(0, 13, 30).toUtc(),
        calendarId: 'personal',
        location: 'Cafe Aaram',
        reminderMinutes: 30,
      ),
      CalendarEvent(
        id: 'yoga',
        title: 'Yoga class',
        startUtc: at(0, 18).toUtc(),
        endUtc: at(0, 19).toUtc(),
        calendarId: 'personal',
        location: 'Wellness Studio',
        recurrence: RecurrenceType.weekly,
        recurrenceRule: 'FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,WE,FR',
        reminderMinutes: 60,
      ),
      CalendarEvent(
        id: 'school-pickup',
        title: 'School pickup',
        startUtc: at(0, 15, 30).toUtc(),
        endUtc: at(0, 16).toUtc(),
        calendarId: 'family',
        reminderMinutes: 15,
      ),
      CalendarEvent(
        id: 'deadline-review',
        title: 'Project deadline review',
        startUtc: at(1, 10).toUtc(),
        endUtc: at(1, 11).toUtc(),
        calendarId: 'work',
        notes: 'Bring the milestone checklist.',
        reminderMinutes: 10,
      ),
      CalendarEvent(
        id: 'dentist',
        title: 'Dentist appointment',
        startUtc: at(1, 16).toUtc(),
        endUtc: at(1, 17).toUtc(),
        calendarId: 'personal',
        location: 'Smile Clinic',
        reminderMinutes: 60,
      ),
      CalendarEvent(
        id: 'client-call',
        title: 'Client call',
        startUtc: at(1, 15).toUtc(),
        endUtc: at(1, 15, 30).toUtc(),
        calendarId: 'work',
        location: 'Google Meet',
        reminderMinutes: 5,
      ),
      CalendarEvent(
        id: 'family-dinner',
        title: 'Family dinner',
        startUtc: at(2, 19).toUtc(),
        endUtc: at(2, 21).toUtc(),
        calendarId: 'family',
        location: 'Home',
        reminderMinutes: 60,
      ),
      CalendarEvent(
        id: 'anaya-birthday',
        title: "Anaya's birthday",
        startUtc: at(3, 0).toUtc(),
        endUtc: at(3, 23, 59).toUtc(),
        isAllDay: true,
        calendarId: 'family',
        reminderMinutes: 1440,
      ),
      CalendarEvent(
        id: 'jaipur-trip',
        title: 'Trip to Jaipur',
        startUtc: at(4, 0).toUtc(),
        endUtc: at(6, 23, 59).toUtc(),
        isAllDay: true,
        calendarId: 'personal',
        notes: 'Hotel booked, train tickets in Drive.',
      ),
      CalendarEvent(
        id: 'book-club',
        title: 'Book club',
        startUtc: at(5, 17).toUtc(),
        endUtc: at(5, 18, 30).toUtc(),
        calendarId: 'personal',
        location: 'City Library',
      ),
      CalendarEvent(
        id: 'budget-review',
        title: 'Monthly budget review',
        startUtc: at(7, 20).toUtc(),
        endUtc: at(7, 21).toUtc(),
        calendarId: 'personal',
        recurrence: RecurrenceType.monthly,
        reminderMinutes: 30,
      ),
      CalendarEvent(
        id: 'sprint-planning',
        title: 'Sprint planning',
        startUtc: at(-1, 10).toUtc(),
        endUtc: at(-1, 12).toUtc(),
        calendarId: 'work',
        location: 'Office — Room 3',
        reminderMinutes: 10,
      ),
      CalendarEvent(
        id: 'gym',
        title: 'Gym',
        startUtc: at(-2, 7).toUtc(),
        endUtc: at(-2, 8).toUtc(),
        calendarId: 'personal',
        recurrence: RecurrenceType.weekly,
        recurrenceRule: 'FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,WE,FR',
      ),
      CalendarEvent(
        id: 'doctor',
        title: 'Doctor checkup',
        startUtc: at(-3, 11).toUtc(),
        endUtc: at(-3, 12).toUtc(),
        calendarId: 'personal',
        location: 'City Hospital',
        reminderMinutes: 60,
      ),
    ];
  }

  late List<AppCalendar> _calendars;
  late List<CalendarEvent> _events;

  @override
  Future<List<AppCalendar>> getCalendars() async => List.of(_calendars);

  @override
  Future<List<CalendarEvent>> getEvents() async => List.of(_events);

  @override
  Future<void> saveEvent(CalendarEvent event) async {
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index >= 0) {
      _events[index] = event;
    } else {
      _events.add(event);
    }
  }

  @override
  Future<void> deleteEvent(String id) async {
    _events.removeWhere((e) => e.id == id);
  }
}
