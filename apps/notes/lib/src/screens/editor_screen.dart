import 'dart:async';
import 'dart:convert';

import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../models/note.dart';
import '../providers/notes_providers.dart';

/// Rich-text editor for one note.
///
/// The note title is the first line of the text. Changes autosave to the
/// repository (debounced 800 ms); leaving with an empty note discards it,
/// like Google Keep. Undo/redo go through the Quill controller.
class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key, required this.noteId});

  final String noteId;

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  QuillController? _controller;
  NotesNotifier? _notifier;
  String? _loadedNoteId;
  Timer? _saveTimer;
  bool _saving = false;

  @override
  void dispose() {
    _saveTimer?.cancel();
    // Save once more on exit, or discard the note if it is empty.
    // NOTE: `ref` must not be used in dispose — the notifier was saved
    // in a field when the controller was initialised.
    final controller = _controller;
    final notifier = _notifier;
    if (controller != null && notifier != null && _loadedNoteId != null) {
      final plain = controller.document.toPlainText();
      if (plain.trim().isEmpty) {
        notifier.deleteForever(_loadedNoteId!);
      } else {
        _saveNow();
      }
    }
    _controller?.dispose();
    super.dispose();
  }

  void _initController(Note note) {
    _loadedNoteId = note.id;
    _notifier = ref.read(notesProvider.notifier);
    final decoded = jsonDecode(note.contentDeltaJson) as List<dynamic>;
    final document =
        decoded.isEmpty ? Document() : Document.fromJson(decoded);
    _controller = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );
    _controller!.addListener(_onDocumentChanged);
  }

  void _onDocumentChanged() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 800), _saveNow);
  }

  Future<void> _saveNow() async {
    final controller = _controller;
    final noteId = _loadedNoteId;
    final notifier = _notifier;
    if (controller == null || noteId == null || notifier == null) return;
    if (_saving) return;
    _saving = true;
    try {
      await notifier.updateNoteContent(
            id: noteId,
            plainText: controller.document.toPlainText(),
            deltaJson: jsonEncode(controller.document.toDelta().toJson()),
          );
    } finally {
      _saving = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final notesAsync = ref.watch(notesProvider);
    return notesAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const DusLoadingSkeleton(),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: DusErrorState(
          message: l10n.error,
          onRetry: () => ref.invalidate(notesProvider),
          retryLabel: l10n.retry,
        ),
      ),
      data: (notes) {
        final note =
            notes.where((n) => n.id == widget.noteId).firstOrNull;
        if (note == null) {
          return Scaffold(
            appBar: AppBar(),
            body: DusErrorState(
              message: l10n.error,
              onRetry: () => ref.invalidate(notesProvider),
              retryLabel: l10n.retry,
            ),
          );
        }
        final controller = _controller;
        if (controller == null) {
          // First build with the note loaded: create the controller from
          // the note's saved delta, then rebuild to show the editor. The
          // guard in _initController keeps this from running again.
          _initController(note);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() {});
          });
          return Scaffold(
            appBar: AppBar(),
            body: const DusLoadingSkeleton(),
          );
        }
        final editedDate = MaterialLocalizations.of(context)
            .formatMediumDate(note.updatedAt);
        return Scaffold(
          appBar: AppBar(
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) => _onMenuSelected(value, note),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'pin',
                    child: Text(note.isPinned ? 'Unpin' : 'Pin'),
                  ),
                  PopupMenuItem(
                    value: 'reminder',
                    child: Text(l10n.notesReminders),
                  ),
                  PopupMenuItem(
                    value: 'archive',
                    child: Text(l10n.notesArchive),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(l10n.notesDeleteNote),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              // Single scrollable toolbar row. multiRowsDisplay must stay
              // false: the multi-row toolbar has unbounded height and
              // overflows the AppBar / body.
              QuillSimpleToolbar(
                controller: controller,
                config: const QuillSimpleToolbarConfig(
                  multiRowsDisplay: false,
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.screenEdge),
                  child: QuillEditor.basic(
                    controller: controller,
                    config: QuillEditorConfig(
                      placeholder: l10n.notesNewNote,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenEdge,
                  0,
                  AppSpacing.screenEdge,
                  AppSpacing.md,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${l10n.notesLastEdited} $editedDate',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onMenuSelected(String value, Note note) async {
    final notifier = ref.read(notesProvider.notifier);
    switch (value) {
      case 'pin':
        await notifier.togglePin(note.id);
      case 'reminder':
        await notifier.toggleReminder(note.id);
      case 'archive':
        await notifier.toggleArchive(note.id);
        if (mounted) Navigator.of(context).pop();
      case 'delete':
        await notifier.trashNote(note.id);
        if (mounted) Navigator.of(context).pop();
    }
  }
}
