/// Note, notebook and label models for the Notes app.
///
/// Content is stored as a Quill Delta JSON string plus a plain-text
/// excerpt used for the card preview, search and the title (first line).
class Note {
  const Note({
    required this.id,
    required this.title,
    required this.contentPlain,
    required this.contentDeltaJson,
    required this.notebookId,
    this.labelIds = const [],
    this.isPinned = false,
    this.isArchived = false,
    this.isTrashed = false,
    this.trashedAt,
    this.reminderAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String contentPlain;
  final String contentDeltaJson;
  final String notebookId;
  final List<String> labelIds;
  final bool isPinned;
  final bool isArchived;
  final bool isTrashed;
  final DateTime? trashedAt;
  final DateTime? reminderAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Excerpt shown on the card: everything after the title line.
  String get excerpt {
    final lines = contentPlain.trim().split('\n');
    if (lines.length <= 1) return '';
    return lines.skip(1).join('\n').trim();
  }

  Note copyWith({
    String? id,
    String? title,
    String? contentPlain,
    String? contentDeltaJson,
    String? notebookId,
    List<String>? labelIds,
    bool? isPinned,
    bool? isArchived,
    bool? isTrashed,
    DateTime? trashedAt,
    DateTime? reminderAt,
    bool clearReminder = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      contentPlain: contentPlain ?? this.contentPlain,
      contentDeltaJson: contentDeltaJson ?? this.contentDeltaJson,
      notebookId: notebookId ?? this.notebookId,
      labelIds: labelIds ?? this.labelIds,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      isTrashed: isTrashed ?? this.isTrashed,
      trashedAt: trashedAt ?? this.trashedAt,
      reminderAt: clearReminder ? null : (reminderAt ?? this.reminderAt),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// A notebook groups notes. The color is an index into the theme's
/// primary / secondary / tertiary colors — never a raw color value.
class Notebook {
  const Notebook({required this.id, required this.name, this.colorIndex = 0});

  final String id;
  final String name;
  final int colorIndex;
}

/// A free-form label that can be attached to any note.
class Label {
  const Label({required this.id, required this.name});

  final String id;
  final String name;
}

/// Grid or list layout for the home screen.
enum NoteViewMode { grid, list }
