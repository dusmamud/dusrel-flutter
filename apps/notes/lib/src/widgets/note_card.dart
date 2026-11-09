import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

import '../models/note.dart';

/// One note in the home grid/list, archive, trash and search results.
class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.labels,
    this.onTap,
    this.onLongPress,
    this.trailing,
  });

  final Note note;
  final List<Label> labels;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Optional trailing action (e.g. restore in archive/trash).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final title =
        note.title.isEmpty ? l10n.notesNewNote : note.title;
    final noteLabels =
        labels.where((l) => note.labelIds.contains(l.id)).toList();
    final editedDate =
        MaterialLocalizations.of(context).formatMediumDate(note.updatedAt);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (note.isPinned) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Icon(
                      Icons.push_pin,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                      semanticLabel: l10n.notesPinned,
                    ),
                  ],
                ],
              ),
              if (note.excerpt.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  note.excerpt,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (noteLabels.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    for (final label in noteLabels.take(2))
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius:
                              BorderRadius.circular(AppRadii.full),
                        ),
                        child: Text(
                          label.name,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${l10n.notesLastEdited} $editedDate',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (note.reminderAt != null)
                    Icon(
                      Icons.notifications_outlined,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                      semanticLabel: l10n.notesReminders,
                    ),
                  if (trailing != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    trailing!,
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
