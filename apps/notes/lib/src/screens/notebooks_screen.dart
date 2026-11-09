import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../providers/notes_providers.dart';

/// Notebooks tab: every notebook with its note count. Tapping one
/// filters the home list to that notebook.
class NotebooksScreen extends ConsumerWidget {
  const NotebooksScreen({super.key, required this.onSelectNotebook});

  final ValueChanged<String> onSelectNotebook;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notebooks = ref.watch(notesRepositoryProvider).notebooks;
    final notesAsync = ref.watch(notesProvider);
    final selectedId = ref.watch(selectedNotebookProvider);
    final theme = Theme.of(context);

    return notesAsync.when(
      loading: () => const DusLoadingSkeleton(),
      error: (error, _) => DusErrorState(
        message: l10n.error,
        onRetry: () => ref.invalidate(notesProvider),
        retryLabel: l10n.retry,
      ),
      data: (notes) {
        if (notebooks.isEmpty) {
          return DusEmptyState(
            icon: Icons.book_outlined,
            title: l10n.notesNotebooks,
          );
        }
        final notebookColors = <Color>[
          theme.colorScheme.primary,
          theme.colorScheme.secondary,
          theme.colorScheme.tertiary,
        ];
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.screenEdge),
          itemCount: notebooks.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final notebook = notebooks[index];
            final count = notes
                .where((n) =>
                    n.notebookId == notebook.id &&
                    !n.isArchived &&
                    !n.isTrashed)
                .length;
            final color = notebookColors[
                notebook.colorIndex % notebookColors.length];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color,
                  child: Icon(
                    Icons.book_outlined,
                    color: theme.colorScheme.onPrimary,
                    semanticLabel: notebook.name,
                  ),
                ),
                title: Text(notebook.name),
                subtitle: Text('$count'),
                trailing: selectedId == notebook.id
                    ? Icon(Icons.check, color: theme.colorScheme.primary)
                    : const Icon(Icons.chevron_right),
                onTap: () => onSelectNotebook(notebook.id),
              ),
            );
          },
        );
      },
    );
  }
}
