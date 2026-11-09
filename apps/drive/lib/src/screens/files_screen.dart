import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:ui_kit/ui_kit.dart';

import '../providers/drive_providers.dart';
import '../widgets/file_sheets.dart';
import '../widgets/file_widgets.dart';

/// Files tab (My Drive): folders pinned above files, grid/list toggle,
/// multi-select with a contextual action bar, and the uploads queue.
class FilesScreen extends ConsumerWidget {
  const FilesScreen({super.key, this.folderId});

  /// Null = root of My Drive.
  final String? folderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filesAsync = ref.watch(filesProvider);
    final isGrid = ref.watch(viewModeProvider);
    final selection = ref.watch(selectionProvider);
    final uploads = ref.watch(uploadsProvider);
    return filesAsync.when(
      loading: () => const DusLoadingSkeleton(),
      error: (error, _) => DusErrorState(
        message: l10n.error,
        onRetry: () => ref.invalidate(filesProvider),
      ),
      data: (files) {
        final inFolder = files
            .where((f) => !f.isTrashed && f.parentId == folderId)
            .toList();
        final selectedFiles =
            files.where((f) => selection.contains(f.id)).toList();
        return Column(
          children: [
            if (selection.isNotEmpty)
              _SelectionBar(
                count: selection.length,
                onStar: () async {
                  for (final file in selectedFiles) {
                    await ref.read(filesProvider.notifier).toggleStar(file.id);
                  }
                  ref.read(selectionProvider.notifier).clear();
                },
                onShare: () {
                  if (selectedFiles.isNotEmpty) {
                    showShareSheet(context, selectedFiles.first);
                  }
                  ref.read(selectionProvider.notifier).clear();
                },
                onTrash: () async {
                  for (final file in selectedFiles) {
                    await ref.read(filesProvider.notifier).moveToTrash(file.id);
                  }
                  ref.read(selectionProvider.notifier).clear();
                },
                onClose: () =>
                    ref.read(selectionProvider.notifier).clear(),
              ),
            if (folderId != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Symbols.arrow_back),
                  label: Text(l10n.back),
                ),
              ),
            if (uploads.isNotEmpty)
              UploadQueueCard(
                uploads: uploads,
                onDismiss: (id) =>
                    ref.read(uploadsProvider.notifier).dismiss(id),
              ),
            Expanded(
              child: inFolder.isEmpty
                  ? DusEmptyState(
                      icon: Symbols.folder_open,
                      title: l10n.driveEmpty,
                      message: l10n.driveNoFiles,
                    )
                  : DriveFileList(
                      files: inFolder,
                      isGrid: isGrid,
                      selectedIds: selection,
                      onFileTap: (file) {
                        if (selection.isNotEmpty) {
                          ref.read(selectionProvider.notifier).toggle(file.id);
                        } else {
                          context.push('/preview/${file.id}');
                        }
                      },
                      onFolderTap: (file) {
                        if (selection.isNotEmpty) {
                          ref.read(selectionProvider.notifier).toggle(file.id);
                        } else {
                          context.push('/files/${file.id}');
                        }
                      },
                      onLongPress: (file) => ref
                          .read(selectionProvider.notifier)
                          .toggle(file.id),
                      onStar: (file) => ref
                          .read(filesProvider.notifier)
                          .toggleStar(file.id),
                      onMore: (file) =>
                          showFileDetailsSheet(context, ref, file),
                    ),
            ),
          ],
        );
      },
    );
  }
}

/// Contextual action bar shown while files are selected.
class _SelectionBar extends StatelessWidget {
  const _SelectionBar({
    required this.count,
    required this.onStar,
    required this.onShare,
    required this.onTrash,
    required this.onClose,
  });

  final int count;
  final VoidCallback onStar;
  final VoidCallback onShare;
  final VoidCallback onTrash;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.primaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Symbols.close),
            onPressed: onClose,
            constraints: const BoxConstraints(
              minWidth: AppSizes.minTouchTarget,
              minHeight: AppSizes.minTouchTarget,
            ),
          ),
          Text('$count', style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          IconButton(
            icon: const Icon(Symbols.star),
            tooltip: l10n.driveStarred,
            onPressed: onStar,
            constraints: const BoxConstraints(
              minWidth: AppSizes.minTouchTarget,
              minHeight: AppSizes.minTouchTarget,
            ),
          ),
          IconButton(
            icon: const Icon(Symbols.share),
            tooltip: l10n.share,
            onPressed: onShare,
            constraints: const BoxConstraints(
              minWidth: AppSizes.minTouchTarget,
              minHeight: AppSizes.minTouchTarget,
            ),
          ),
          IconButton(
            icon: const Icon(Symbols.download),
            tooltip: l10n.driveDownload,
            onPressed: () {},
            constraints: const BoxConstraints(
              minWidth: AppSizes.minTouchTarget,
              minHeight: AppSizes.minTouchTarget,
            ),
          ),
          IconButton(
            icon: const Icon(Symbols.delete),
            tooltip: l10n.delete,
            onPressed: onTrash,
            constraints: const BoxConstraints(
              minWidth: AppSizes.minTouchTarget,
              minHeight: AppSizes.minTouchTarget,
            ),
          ),
        ],
      ),
    );
  }
}
