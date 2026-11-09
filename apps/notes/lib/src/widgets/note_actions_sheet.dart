import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../models/note.dart';
import '../providers/notes_providers.dart';

/// Bottom sheet with the actions for one note: pin, labels, reminder,
/// archive, delete and share.
Future<void> showNoteActionsSheet(
  BuildContext context,
  WidgetRef ref,
  Note note,
) {
  final l10n = AppLocalizations.of(context);
  return showDusBottomSheet<void>(
    context,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        AppSpacing.md,
        AppSpacing.screenEdge,
        AppSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title.isEmpty ? l10n.notesNewNote : note.title,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              leading: Icon(
                note.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
              ),
              title: Text(note.isPinned ? l10n.unpin : l10n.pin),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                Navigator.of(context).pop();
                ref.read(notesProvider.notifier).togglePin(note.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: Text(l10n.notesReminders),
              trailing: note.reminderAt != null
                  ? Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              contentPadding: EdgeInsets.zero,
              onTap: () {
                Navigator.of(context).pop();
                ref.read(notesProvider.notifier).toggleReminder(note.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: Text(l10n.notesArchive),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                Navigator.of(context).pop();
                ref.read(notesProvider.notifier).toggleArchive(note.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: Text(l10n.share),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                // Share is a placeholder in v1 — no share plugin is wired
                // yet. The sheet just closes.
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                l10n.notesDeleteNote,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                Navigator.of(context).pop();
                ref.read(notesProvider.notifier).trashNote(note.id);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Text(l10n.addLabel, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Consumer(
              builder: (context, ref, _) {
                final labels =
                    ref.read(notesRepositoryProvider).labels;
                final current = ref
                    .watch(notesProvider)
                    .value
                    ?.where((n) => n.id == note.id)
                    .firstOrNull;
                final selected = current?.labelIds ?? note.labelIds;
                return Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    for (final label in labels)
                      FilterChip(
                        label: Text(label.name),
                        selected: selected.contains(label.id),
                        onSelected: (_) {
                          ref
                              .read(notesProvider.notifier)
                              .toggleLabel(note.id, label.id);
                        },
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}
