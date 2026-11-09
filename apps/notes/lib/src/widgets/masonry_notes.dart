import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

import '../models/note.dart';
import 'note_card.dart';

double _estimatedHeight(Note note) {
  final textLength = note.title.length + note.excerpt.length;
  return 110 + textLength * 0.45;
}

/// The masonry columns themselves (no scrolling). Used by [MasonryNotes]
/// and by the home screen's pinned / all-notes sections.
class MasonryColumns extends StatelessWidget {
  const MasonryColumns({
    super.key,
    required this.notes,
    required this.labels,
    required this.onTap,
    required this.onLongPress,
  });

  final List<Note> notes;
  final List<Label> labels;
  final ValueChanged<Note> onTap;
  final ValueChanged<Note> onLongPress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = constraints.maxWidth >= 600 ? 3 : 2;
        final columns = List<List<Note>>.generate(columnCount, (_) => []);
        final heights = List<double>.filled(columnCount, 0);
        for (final note in notes) {
          var shortest = 0;
          for (var i = 1; i < columnCount; i++) {
            if (heights[i] < heights[shortest]) shortest = i;
          }
          columns[shortest].add(note);
          heights[shortest] += _estimatedHeight(note);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < columnCount; i++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: i == 0 ? 0 : AppSpacing.md / 2,
                    right: i == columnCount - 1 ? 0 : AppSpacing.md / 2,
                  ),
                  child: Column(
                    children: [
                      for (final note in columns[i])
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.md),
                          child: NoteCard(
                            note: note,
                            labels: labels,
                            onTap: () => onTap(note),
                            onLongPress: () => onLongPress(note),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// A lightweight two-column masonry built from built-in widgets only.
///
/// `flutter_staggered_grid_view` is incompatible with Dart 3.13, so cards
/// are distributed across columns by estimated height (title + excerpt
/// length) and the shortest column always takes the next card.
class MasonryNotes extends StatelessWidget {
  const MasonryNotes({
    super.key,
    required this.notes,
    required this.labels,
    required this.onTap,
    required this.onLongPress,
  });

  final List<Note> notes;
  final List<Label> labels;
  final ValueChanged<Note> onTap;
  final ValueChanged<Note> onLongPress;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenEdge),
      child: MasonryColumns(
        notes: notes,
        labels: labels,
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}
