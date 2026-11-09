import 'dart:convert';

import '../models/note.dart';

/// Builds the Quill Delta JSON for a plain-text note body.
String deltaJsonFromPlain(String plain) {
  final text = plain.endsWith('\n') ? plain : '$plain\n';
  return jsonEncode([
    {'insert': text},
  ]);
}

/// The data source behind the notes list.
///
/// The app is frontend-first: this interface is the seam the real backend
/// (local database, then sync) plugs into later without touching the UI.
abstract class NotesRepository {
  Future<List<Note>> fetchNotes();
  List<Notebook> get notebooks;
  List<Label> get labels;

  Future<Note> createNote();
  Future<void> updateNote(Note note);
  Future<void> trashNote(String id);
  Future<void> restoreNote(String id);
  Future<void> deleteForever(String id);
  Future<void> emptyTrash();
}

/// In-memory mock data so the frontend can be built and tested locally.
class MockNotesRepository implements NotesRepository {
  MockNotesRepository() : _notes = _seedNotes();

  final List<Note> _notes;

  @override
  List<Notebook> get notebooks => const [
        Notebook(id: 'nb-personal', name: 'Personal', colorIndex: 0),
        Notebook(id: 'nb-work', name: 'Work', colorIndex: 1),
        Notebook(id: 'nb-ideas', name: 'Ideas', colorIndex: 2),
      ];

  @override
  List<Label> get labels => const [
        Label(id: 'label-work', name: 'Work'),
        Label(id: 'label-personal', name: 'Personal'),
        Label(id: 'label-ideas', name: 'Ideas'),
      ];

  @override
  Future<List<Note>> fetchNotes() async => List<Note>.unmodifiable(_notes);

  @override
  Future<Note> createNote() async {
    final now = DateTime.now();
    final note = Note(
      id: 'note-${now.microsecondsSinceEpoch}',
      title: '',
      contentPlain: '',
      contentDeltaJson: deltaJsonFromPlain(''),
      notebookId: 'nb-personal',
      createdAt: now,
      updatedAt: now,
    );
    _notes.insert(0, note);
    return note;
  }

  @override
  Future<void> updateNote(Note note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) _notes[index] = note;
  }

  @override
  Future<void> trashNote(String id) async {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(
        isTrashed: true,
        isPinned: false,
        trashedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> restoreNote(String id) async {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(
        isTrashed: false,
        isArchived: false,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> deleteForever(String id) async {
    _notes.removeWhere((n) => n.id == id);
  }

  @override
  Future<void> emptyTrash() async {
    _notes.removeWhere((n) => n.isTrashed);
  }

  static List<Note> _seedNotes() {
    final now = DateTime.now();
    DateTime daysAgo(int days, [int hours = 0]) =>
        now.subtract(Duration(days: days, hours: hours));

    Note seed({
      required String id,
      required String title,
      required String body,
      required String notebookId,
      List<String> labelIds = const [],
      bool isPinned = false,
      bool isArchived = false,
      bool isTrashed = false,
      DateTime? reminderAt,
      required DateTime updatedAt,
    }) {
      final plain = '$title\n$body';
      return Note(
        id: id,
        title: title,
        contentPlain: plain,
        contentDeltaJson: deltaJsonFromPlain(plain),
        notebookId: notebookId,
        labelIds: labelIds,
        isPinned: isPinned,
        isArchived: isArchived,
        isTrashed: isTrashed,
        trashedAt: isTrashed ? daysAgo(2) : null,
        reminderAt: reminderAt,
        createdAt: daysAgo(12),
        updatedAt: updatedAt,
      );
    }

    return [
      seed(
        id: 'note-1',
        title: 'Grocery list',
        body: 'Milk, eggs, bread\nRice 5kg\nSpinach and tomatoes\nCoffee beans',
        notebookId: 'nb-personal',
        labelIds: const ['label-personal'],
        isPinned: true,
        updatedAt: daysAgo(0, 2),
      ),
      seed(
        id: 'note-2',
        title: 'Sprint planning notes',
        body:
            'Focus: offline sync for notes\nCapacity: 3 devs, 2 weeks\nRisks: migration of old delta format\nRetro on Friday 4pm',
        notebookId: 'nb-work',
        labelIds: const ['label-work'],
        isPinned: true,
        updatedAt: daysAgo(0, 5),
      ),
      seed(
        id: 'note-3',
        title: 'Trip to Jaipur plan',
        body:
            'Day 1: Amber Fort and Hawa Mahal\nDay 2: City Palace, bazaar walk\nBook train tickets by Friday\nHotel budget: 3000 per night',
        notebookId: 'nb-personal',
        labelIds: const ['label-personal'],
        reminderAt: DateTime(now.year, now.month, now.day + 1, 9),
        updatedAt: daysAgo(1),
      ),
      seed(
        id: 'note-4',
        title: 'Q4 goals',
        body:
            'Ship notes, chat, calendar and drive frontends\nWrite widget tests for every screen\nKeep the bundle size under control',
        notebookId: 'nb-work',
        labelIds: const ['label-work'],
        updatedAt: daysAgo(1, 4),
      ),
      seed(
        id: 'note-5',
        title: 'App idea — habit tracker',
        body:
            'Streaks with a forgiving rest day\nOne-tap check-in from a widget\nWeekly review with a simple chart',
        notebookId: 'nb-ideas',
        labelIds: const ['label-ideas'],
        updatedAt: daysAgo(2),
      ),
      seed(
        id: 'note-6',
        title: 'Books to read',
        body:
            'The Design of Everyday Things\nRefactoring UI\nA Philosophy of Software Design',
        notebookId: 'nb-personal',
        labelIds: const ['label-personal'],
        updatedAt: daysAgo(3),
      ),
      seed(
        id: 'note-7',
        title: 'Meeting notes — design review',
        body:
            'Agreed: one shared ui_kit for all apps\nIcons: Material Symbols as primary set\nNext: audit touch targets on small screens',
        notebookId: 'nb-work',
        labelIds: const ['label-work'],
        updatedAt: daysAgo(3, 6),
      ),
      seed(
        id: 'note-8',
        title: 'Morning routine',
        body: 'Wake 6:30\n20 min walk\nRead 10 pages\nPlan the top 3 tasks',
        notebookId: 'nb-personal',
        labelIds: const ['label-personal'],
        updatedAt: daysAgo(4),
      ),
      seed(
        id: 'note-9',
        title: 'API migration checklist',
        body:
            'List all v1 endpoints\nAdd v2 behind a flag\nMigrate clients one by one\nRemove v1 after 30 days',
        notebookId: 'nb-work',
        labelIds: const ['label-work'],
        updatedAt: daysAgo(5),
      ),
      seed(
        id: 'note-10',
        title: 'Blog post draft',
        body:
            'Why offline-first matters for notes apps\nDraft outline: problem, approach, trade-offs\nAdd screenshots once the UI lands',
        notebookId: 'nb-ideas',
        labelIds: const ['label-ideas'],
        updatedAt: daysAgo(6),
      ),
      seed(
        id: 'note-11',
        title: 'Old project retrospective',
        body: 'What went well, what did not, and what to change next time.',
        notebookId: 'nb-work',
        labelIds: const ['label-work'],
        isArchived: true,
        updatedAt: daysAgo(9),
      ),
      seed(
        id: 'note-12',
        title: 'Duplicate shopping list',
        body: 'An old copy of the grocery list, no longer needed.',
        notebookId: 'nb-personal',
        labelIds: const ['label-personal'],
        isTrashed: true,
        updatedAt: daysAgo(8),
      ),
    ];
  }
}
