import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../providers/notes_providers.dart';
import '../widgets/note_actions_sheet.dart';
import '../widgets/note_card.dart';

/// Archived notes, with a restore action on each card.
class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notesAsync = ref.watch(notesProvider);
    final labels = ref.watch(notesRepositoryProvider).labels;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notesArchive)),
      body: notesAsync.when(
        loading: () => const DusLoadingSkeleton(),
        error: (error, _) => DusErrorState(
          message: l10n.error,
          onRetry: () => ref.invalidate(notesProvider),
          retryLabel: l10n.retry,
        ),
        data: (notes) {
          final archived =
              notes.where((n) => n.isArchived && !n.isTrashed).toList();
          if (archived.isEmpty) {
            return DusEmptyState(
              icon: Icons.archive_outlined,
              title: l10n.notesArchive,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.screenEdge),
            itemCount: archived.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final note = archived[index];
              return NoteCard(
                note: note,
                labels: labels,
                onTap: () => context.push('/editor/${note.id}'),
                onLongPress: () =>
                    showNoteActionsSheet(context, ref, note),
                trailing: IconButton(
                  icon: const Icon(Icons.unarchive_outlined),
                  tooltip: l10n.notesRestore,
                  onPressed: () {
                    ref.read(notesProvider.notifier).restoreNote(note.id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
