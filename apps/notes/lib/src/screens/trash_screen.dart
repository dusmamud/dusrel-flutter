import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../providers/notes_providers.dart';
import '../widgets/note_card.dart';

/// Trash: trashed notes with restore, delete-forever and empty-trash.
/// Notes are kept for 30 days before permanent deletion.
class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notesAsync = ref.watch(notesProvider);
    final labels = ref.watch(notesRepositoryProvider).labels;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notesTrash),
        actions: [
          TextButton(
            onPressed: () => _confirmEmptyTrash(context, ref),
            child: Text(l10n.notesEmptyTrash),
          ),
        ],
      ),
      body: notesAsync.when(
        loading: () => const DusLoadingSkeleton(),
        error: (error, _) => DusErrorState(
          message: l10n.error,
          onRetry: () => ref.invalidate(notesProvider),
          retryLabel: l10n.retry,
        ),
        data: (notes) {
          final trashed = notes.where((n) => n.isTrashed).toList();
          if (trashed.isEmpty) {
            return DusEmptyState(
              icon: Icons.delete_outline,
              title: l10n.notesTrash,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.screenEdge),
            itemCount: trashed.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Text(
                  l10n.notesTrashRetention,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                );
              }
              final note = trashed[index - 1];
              return NoteCard(
                note: note,
                labels: labels,
                onTap: () => context.push('/editor/${note.id}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.restore_outlined),
                      tooltip: l10n.notesRestore,
                      onPressed: () {
                        ref
                            .read(notesProvider.notifier)
                            .restoreNote(note.id);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_forever_outlined),
                      tooltip: l10n.notesDeleteForever,
                      onPressed: () {
                        ref
                            .read(notesProvider.notifier)
                            .deleteForever(note.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmEmptyTrash(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.notesEmptyTrash),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(notesProvider.notifier).emptyTrash();
    }
  }
}
