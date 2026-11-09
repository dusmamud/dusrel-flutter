import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../models/note.dart';
import '../providers/notes_providers.dart';
import 'home_screen.dart';
import 'notebooks_screen.dart';
import 'reminders_screen.dart';

/// The app shell: bottom tabs (Notes, Notebooks, Reminders) on narrow
/// screens, a side rail on wide screens — both from the shared ui_kit.
/// Search, Archive, Trash, Labels and Settings live in the app bar.
class NotesShell extends ConsumerStatefulWidget {
  const NotesShell({super.key});

  @override
  ConsumerState<NotesShell> createState() => _NotesShellState();
}

class _NotesShellState extends ConsumerState<NotesShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewMode = ref.watch(viewModeProvider);
    final titles = [
      l10n.notesAppTitle,
      l10n.notesNotebooks,
      l10n.notesReminders,
    ];

    return DusAppShell(
      destinations: [
        DusDestination(
          icon: Icons.note_outlined,
          selectedIcon: Icons.note,
          label: l10n.notesAppTitle,
        ),
        DusDestination(
          icon: Icons.book_outlined,
          selectedIcon: Icons.book,
          label: l10n.notesNotebooks,
        ),
        DusDestination(
          icon: Icons.notifications_outlined,
          selectedIcon: Icons.notifications,
          label: l10n.notesReminders,
        ),
      ],
      selectedIndex: _index,
      onDestinationSelected: (index) => setState(() => _index = index),
      title: titles[_index],
      actions: [
        if (_index == 0)
          IconButton(
            icon: Icon(
              viewMode == NoteViewMode.grid
                  ? Icons.view_list_outlined
                  : Icons.grid_view_outlined,
            ),
            tooltip: viewMode == NoteViewMode.grid
                ? l10n.notesListView
                : l10n.notesGridView,
            onPressed: () => ref.read(viewModeProvider.notifier).toggle(),
          ),
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: l10n.search,
          onPressed: () => context.push('/search'),
        ),
        PopupMenuButton<String>(
          onSelected: (value) => context.push(value),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: '/archive',
              child: Text(l10n.notesArchive),
            ),
            PopupMenuItem(
              value: '/trash',
              child: Text(l10n.notesTrash),
            ),
            PopupMenuItem(
              value: '/labels',
              child: Text(l10n.notesLabels),
            ),
            PopupMenuItem(
              value: '/settings',
              child: Text(l10n.settings),
            ),
          ],
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: _createNote,
        tooltip: l10n.notesNewNote,
        child: const Icon(Icons.add),
      ),
      body: IndexedStack(
        index: _index,
        children: [
          const HomeScreen(),
          NotebooksScreen(
            onSelectNotebook: (id) {
              ref.read(selectedNotebookProvider.notifier).select(id);
              setState(() => _index = 0);
            },
          ),
          const RemindersScreen(),
        ],
      ),
    );
  }

  Future<void> _createNote() async {
    final note = await ref.read(notesProvider.notifier).createNote();
    if (mounted) context.push('/editor/${note.id}');
  }
}
