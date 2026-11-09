import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:ui_kit/ui_kit.dart';

import '../models/drive_file.dart';
import '../providers/drive_providers.dart';
import '../widgets/file_widgets.dart';

/// Trash: trashed files with restore and delete-forever.
/// Items are auto-deleted after 30 days.
class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filesAsync = ref.watch(filesProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.driveTrash),
        actions: [
          IconButton(
            icon: const Icon(Symbols.delete_forever),
            tooltip: l10n.driveEmptyTrash,
            onPressed: () =>
                ref.read(filesProvider.notifier).emptyTrash(),
            constraints: const BoxConstraints(
              minWidth: AppSizes.minTouchTarget,
              minHeight: AppSizes.minTouchTarget,
            ),
          ),
        ],
      ),
      body: filesAsync.when(
        loading: () => const DusLoadingSkeleton(),
        error: (error, _) => DusErrorState(
          message: l10n.error,
          onRetry: () => ref.invalidate(filesProvider),
        ),
        data: (files) {
          final trashed = files.where((f) => f.isTrashed).toList()
            ..sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
          if (trashed.isEmpty) {
            return DusEmptyState(
              icon: Symbols.delete,
              title: l10n.driveEmpty,
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenEdge,
                  AppSpacing.md,
                  AppSpacing.screenEdge,
                  AppSpacing.sm,
                ),
                child: Text(
                  l10n.driveTrashRetention,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: trashed.length,
                  itemBuilder: (context, index) {
                    final file = trashed[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenEdge,
                      ),
                      leading: FileTypeIcon(file: file),
                      title: Text(
                        file.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${formatFileSize(file.sizeBytes)} · ${formatDriveDate(file.modifiedAt)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Symbols.restore_from_trash),
                            tooltip: l10n.driveRestore,
                            onPressed: () => ref
                                .read(filesProvider.notifier)
                                .restore(file.id),
                            constraints: const BoxConstraints(
                              minWidth: AppSizes.minTouchTarget,
                              minHeight: AppSizes.minTouchTarget,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Symbols.delete_forever),
                            tooltip: l10n.driveDeleteForever,
                            onPressed: () => ref
                                .read(filesProvider.notifier)
                                .deleteForever(file.id),
                            constraints: const BoxConstraints(
                              minWidth: AppSizes.minTouchTarget,
                              minHeight: AppSizes.minTouchTarget,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
