import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../models/note.dart';
import '../providers/notes_providers.dart';
import '../widgets/masonry_notes.dart';
import '../widgets/note_actions_sheet.dart';
import '../widgets/note_card.dart';

/// Home tab: pinned notes on top, then all notes in a masonry grid
/// (or a plain list, per the view-mode setting).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notesAsync = ref.watch(activeNotesProvider);
    final viewMode = ref.watch(viewModeProvider);
    final notebookId = ref.watch(selectedNotebookProvider);
    final labelId = ref.watch(selectedLabelProvider);
    final labels = ref.watch(notesRepositoryProvider).labels;
    final notebooks = ref.watch(notesRepositoryProvider).notebooks;

    return notesAsync.when(
      loading: () => const DusLoadingSkeleton(),
      error: (error, _) => DusErrorState(
        message: l10n.error,
        onRetry: () => ref.invalidate(notesProvider),
        retryLabel: l10n.retry,
      ),
      data: (notes) {
        final hasFilter = notebookId != null || labelId != null;
        final pinned = notes.where((n) => n.isPinned).toList();
        final others = notes.where((n) => !n.isPinned).toList();

        if (notes.isEmpty && !hasFilter) {
          return DusEmptyState(
            icon: Icons.note_outlined,
            title: l10n.notesEmpty,
            message: l10n.notesCreateFirst,
            actionLabel: l10n.notesNewNote,
            onAction: () => _createNote(context, ref),
          );
        }
        if (notes.isEmpty) {
          return DusEmptyState(
            icon: Icons.search_off_outlined,
            title: l10n.noResults,
          );
        }

        final Widget content;
        if (viewMode == NoteViewMode.list) {
          content = _buildList(context, ref, notes, labels);
        } else if (hasFilter) {
          content = MasonryNotes(
            notes: notes,
            labels: labels,
            onTap: (note) => _openNote(context, note),
            onLongPress: (note) =>
                showNoteActionsSheet(context, ref, note),
          );
        } else {
          content = SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenEdge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (pinned.isNotEmpty) ...[
                  _SectionHeader(title: l10n.notesPinned),
                  const SizedBox(height: AppSpacing.sm),
                  MasonryColumns(
                    notes: pinned,
                    labels: labels,
                    onTap: (note) => _openNote(context, note),
                    onLongPress: (note) =>
                        showNoteActionsSheet(context, ref, note),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _SectionHeader(title: l10n.notesAllNotes),
                  const SizedBox(height: AppSpacing.sm),
                ],
                MasonryColumns(
                  notes: others,
                  labels: labels,
                  onTap: (note) => _openNote(context, note),
                  onLongPress: (note) =>
                      showNoteActionsSheet(context, ref, note),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            if (hasFilter)
              _FilterBar(
                notebookName: notebookId == null
                    ? null
                    : notebooks
                        .where((n) => n.id == notebookId)
                        .firstOrNull
                        ?.name,
                labelName: labelId == null
                    ? null
                    : labels
                        .where((l) => l.id == labelId)
                        .firstOrNull
                        ?.name,
                onClear: () {
                  ref.read(selectedNotebookProvider.notifier).select(null);
                  ref.read(selectedLabelProvider.notifier).select(null);
                },
              ),
            Expanded(child: content),
          ],
        );
      },
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<Note> notes,
    List<Label> labels,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.screenEdge),
      itemCount: notes.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteCard(
          note: note,
          labels: labels,
          onTap: () => _openNote(context, note),
          onLongPress: () => showNoteActionsSheet(context, ref, note),
        );
      },
    );
  }

  void _openNote(BuildContext context, Note note) {
    context.push('/editor/${note.id}');
  }

  Future<void> _createNote(BuildContext context, WidgetRef ref) async {
    final note = await ref.read(notesProvider.notifier).createNote();
    if (context.mounted) context.push('/editor/${note.id}');
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium);
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.notebookName,
    required this.labelName,
    required this.onClear,
  });

  final String? notebookName;
  final String? labelName;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final names = <String>[];
    final notebook = notebookName;
    if (notebook != null) names.add(notebook);
    final label = labelName;
    if (label != null) names.add(label);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        AppSpacing.md,
        AppSpacing.screenEdge,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (final name in names)
                  Chip(
                    label: Text(name),
                    onDeleted: onClear,
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            onPressed: onClear,
          ),
        ],
      ),
    );
  }
}
