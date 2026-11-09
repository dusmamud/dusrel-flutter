import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../providers/notes_providers.dart';
import '../widgets/note_actions_sheet.dart';
import '../widgets/note_card.dart';

/// Full-text search over titles and note bodies.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(searchQueryProvider),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = ref.watch(searchQueryProvider);
    final resultsAsync = ref.watch(searchResultsProvider);
    final labels = ref.watch(notesRepositoryProvider).labels;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.search)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenEdge),
            child: DusSearchBar(
              controller: _controller,
              hintText: l10n.notesSearchNotes,
              autofocus: true,
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).set(value);
              },
            ),
          ),
          Expanded(
            child: query.trim().isEmpty
                ? DusEmptyState(
                    icon: Icons.search,
                    title: l10n.search,
                    message: l10n.notesSearchNotes,
                  )
                : resultsAsync.when(
                    loading: () => const DusLoadingSkeleton(),
                    error: (error, _) => DusErrorState(
                      message: l10n.error,
                      onRetry: () => ref.invalidate(notesProvider),
                      retryLabel: l10n.retry,
                    ),
                    data: (results) {
                      if (results.isEmpty) {
                        return DusEmptyState(
                          icon: Icons.search_off_outlined,
                          title: l10n.noResults,
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.screenEdge),
                        itemCount: results.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final note = results[index];
                          return NoteCard(
                            note: note,
                            labels: labels,
                            onTap: () =>
                                context.push('/editor/${note.id}'),
                            onLongPress: () =>
                                showNoteActionsSheet(context, ref, note),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
