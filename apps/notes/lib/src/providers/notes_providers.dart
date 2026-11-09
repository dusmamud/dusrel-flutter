import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/notes_repository.dart';
import '../models/note.dart';

/// The data source. Swap [MockNotesRepository] for the real one here and
/// nothing in the UI changes.
final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return MockNotesRepository();
});

/// Owns the notes list. All mutations go through the repository and then
/// refresh the state, so the UI always renders repository truth.
class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() async {
    return ref.read(notesRepositoryProvider).fetchNotes();
  }

  Future<void> _refresh() async {
    final notes = await ref.read(notesRepositoryProvider).fetchNotes();
    state = AsyncValue.data(notes);
  }

  Future<Note> createNote() async {
    final note = await ref.read(notesRepositoryProvider).createNote();
    await _refresh();
    return note;
  }

  /// Saves editor content. The title is always the first line of the text.
  Future<void> updateNoteContent({
    required String id,
    required String plainText,
    required String deltaJson,
  }) async {
    final current = state.value;
    final existing = current?.where((n) => n.id == id).firstOrNull;
    if (existing == null) return;
    final firstLine = plainText
        .trim()
        .split('\n')
        .firstWhere((line) => line.trim().isNotEmpty, orElse: () => '');
    await ref.read(notesRepositoryProvider).updateNote(
          existing.copyWith(
            title: firstLine.trim(),
            contentPlain: plainText,
            contentDeltaJson: deltaJson,
            updatedAt: DateTime.now(),
          ),
        );
    await _refresh();
  }

  Future<void> togglePin(String id) async {
    final note = _find(id);
    if (note == null) return;
    await ref.read(notesRepositoryProvider).updateNote(
          note.copyWith(isPinned: !note.isPinned, updatedAt: DateTime.now()),
        );
    await _refresh();
  }

  Future<void> toggleArchive(String id) async {
    final note = _find(id);
    if (note == null) return;
    await ref.read(notesRepositoryProvider).updateNote(
          note.copyWith(
            isArchived: !note.isArchived,
            isPinned: false,
            updatedAt: DateTime.now(),
          ),
        );
    await _refresh();
  }

  Future<void> trashNote(String id) async {
    await ref.read(notesRepositoryProvider).trashNote(id);
    await _refresh();
  }

  Future<void> restoreNote(String id) async {
    await ref.read(notesRepositoryProvider).restoreNote(id);
    await _refresh();
  }

  Future<void> deleteForever(String id) async {
    await ref.read(notesRepositoryProvider).deleteForever(id);
    await _refresh();
  }

  Future<void> emptyTrash() async {
    await ref.read(notesRepositoryProvider).emptyTrash();
    await _refresh();
  }

  Future<void> toggleLabel(String noteId, String labelId) async {
    final note = _find(noteId);
    if (note == null) return;
    final labels = List<String>.from(note.labelIds);
    if (labels.contains(labelId)) {
      labels.remove(labelId);
    } else {
      labels.add(labelId);
    }
    await ref.read(notesRepositoryProvider).updateNote(
          note.copyWith(labelIds: labels, updatedAt: DateTime.now()),
        );
    await _refresh();
  }

  Future<void> toggleReminder(String id) async {
    final note = _find(id);
    if (note == null) return;
    if (note.reminderAt != null) {
      await ref.read(notesRepositoryProvider).updateNote(
            note.copyWith(clearReminder: true, updatedAt: DateTime.now()),
          );
    } else {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      await ref.read(notesRepositoryProvider).updateNote(
            note.copyWith(
              reminderAt: DateTime(tomorrow.year, tomorrow.month,
                  tomorrow.day, 9),
              updatedAt: DateTime.now(),
            ),
          );
    }
    await _refresh();
  }

  Note? _find(String id) =>
      state.value?.where((n) => n.id == id).firstOrNull;
}

final notesProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>(NotesNotifier.new);

/// Search text typed in the search screen.
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
  void clear() => state = '';
}

final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

/// Notebook the home list is filtered by, or null for all notebooks.
class SelectedNotebookNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}

final selectedNotebookProvider =
    NotifierProvider<SelectedNotebookNotifier, String?>(
  SelectedNotebookNotifier.new,
);

/// Label the home list is filtered by, or null for all labels.
class SelectedLabelNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}

final selectedLabelProvider =
    NotifierProvider<SelectedLabelNotifier, String?>(SelectedLabelNotifier.new);

/// Home layout preference; also changed from Settings.
class ViewModeNotifier extends Notifier<NoteViewMode> {
  @override
  NoteViewMode build() => NoteViewMode.grid;

  void set(NoteViewMode mode) => state = mode;
  void toggle() =>
      state = state == NoteViewMode.grid ? NoteViewMode.list : NoteViewMode.grid;
}

final viewModeProvider =
    NotifierProvider<ViewModeNotifier, NoteViewMode>(ViewModeNotifier.new);

/// Active notes (not archived, not trashed) with the home filters applied.
final activeNotesProvider = Provider<AsyncValue<List<Note>>>((ref) {
  final notes = ref.watch(notesProvider);
  final notebookId = ref.watch(selectedNotebookProvider);
  final labelId = ref.watch(selectedLabelProvider);
  return notes.whenData(
    (list) => list
        .where((n) => !n.isArchived && !n.isTrashed)
        .where((n) => notebookId == null || n.notebookId == notebookId)
        .where((n) => labelId == null || n.labelIds.contains(labelId))
        .toList(),
  );
});

/// Notes matching the search query (active notes only).
final searchResultsProvider = Provider<AsyncValue<List<Note>>>((ref) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final notes = ref.watch(notesProvider);
  return notes.whenData((list) {
    final active = list.where((n) => !n.isArchived && !n.isTrashed);
    if (query.isEmpty) return <Note>[];
    return active
        .where((n) =>
            n.title.toLowerCase().contains(query) ||
            n.contentPlain.toLowerCase().contains(query))
        .toList();
  });
});
