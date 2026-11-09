import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:ui_kit/ui_kit.dart';

import '../providers/drive_providers.dart';
import '../widgets/file_widgets.dart';

/// Search screen: query filters all non-trashed files by name.
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
    final filesAsync = ref.watch(filesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.search)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenEdge),
            child: DusSearchBar(
              controller: _controller,
              hintText: l10n.driveSearchFiles,
              autofocus: true,
              onChanged: (value) =>
                  ref.read(searchQueryProvider.notifier).set(value),
            ),
          ),
          Expanded(
            child: filesAsync.when(
              loading: () => const DusLoadingSkeleton(),
              error: (error, _) => DusErrorState(
                message: l10n.error,
                onRetry: () => ref.invalidate(filesProvider),
              ),
              data: (files) {
                final needle = query.trim().toLowerCase();
                final results = needle.isEmpty
                    ? files.where((f) => !f.isTrashed).toList()
                    : files
                        .where(
                          (f) =>
                              !f.isTrashed &&
                              f.name.toLowerCase().contains(needle),
                        )
                        .toList();
                if (results.isEmpty) {
                  return DusEmptyState(
                    icon: Symbols.search,
                    title: l10n.noResults,
                  );
                }
                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final file = results[index];
                    return FileListTile(
                      file: file,
                      onTap: () => context.push('/preview/${file.id}'),
                      onStar: () => ref
                          .read(filesProvider.notifier)
                          .toggleStar(file.id),
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
