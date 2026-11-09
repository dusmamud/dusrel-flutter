import 'package:cached_network_image/cached_network_image.dart';
import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:ui_kit/ui_kit.dart';

import '../models/drive_file.dart';
import '../providers/drive_providers.dart';
import 'file_sheets.dart';

/// The type icon for a file, on a theme-colored tile.
/// Images show their photo thumbnail when it loads, with the type icon
/// as the offline/error fallback.
class FileTypeIcon extends StatelessWidget {
  const FileTypeIcon({super.key, required this.file, this.size = 40});

  final DriveFile file;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color tileColor = switch (file.type) {
      DriveFileType.folder => colorScheme.primaryContainer,
      DriveFileType.pdf => colorScheme.errorContainer,
      DriveFileType.image => colorScheme.tertiaryContainer,
      DriveFileType.video => colorScheme.secondaryContainer,
      _ => colorScheme.surfaceContainerHighest,
    };
    final Color iconColor = switch (file.type) {
      DriveFileType.folder => colorScheme.onPrimaryContainer,
      DriveFileType.pdf => colorScheme.onErrorContainer,
      DriveFileType.image => colorScheme.onTertiaryContainer,
      DriveFileType.video => colorScheme.onSecondaryContainer,
      _ => colorScheme.onSurfaceVariant,
    };

    final Widget icon = Icon(
      iconForType(file.type),
      color: iconColor,
      size: 22,
      semanticLabel: file.name,
    );

    final Widget tile = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      alignment: Alignment.center,
      child: icon,
    );

    final thumbnailUrl = file.thumbnailUrl;
    if (thumbnailUrl == null) return tile;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: CachedNetworkImage(
        imageUrl: thumbnailUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        // Offline-safe: the type icon shows when the photo can't load.
        errorWidget: (_, _, _) => tile,
        placeholder: (_, _) => tile,
      ),
    );
  }
}

/// One row in a file list.
class FileListTile extends StatelessWidget {
  const FileListTile({
    super.key,
    required this.file,
    required this.onTap,
    this.onLongPress,
    this.selected = false,
    this.onStar,
    this.onMore,
  });

  final DriveFile file;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool selected;
  final VoidCallback? onStar;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final subtitle = file.type == DriveFileType.folder
        ? formatDriveDate(file.modifiedAt)
        : '${formatFileSize(file.sizeBytes)} · ${formatDriveDate(file.modifiedAt)}';
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenEdge),
      minVerticalPadding: AppSpacing.sm,
      selected: selected,
      selectedTileColor: theme.colorScheme.primaryContainer,
      leading: selected
          ? CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              child: Icon(
                Symbols.check,
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
            )
          : FileTypeIcon(file: file),
      title: Text(
        file.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          if (file.isShared)
            Icon(Symbols.group, size: 16, color: theme.colorScheme.onSurfaceVariant),
          if (file.isOffline) ...[
            const SizedBox(width: AppSpacing.xs),
            Icon(Symbols.cloud_off, size: 16, color: theme.colorScheme.onSurfaceVariant),
          ],
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onStar != null)
            IconButton(
              icon: Icon(
                file.isStarred ? Symbols.star : Symbols.star_border,
                color: file.isStarred
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              tooltip: l10n.driveStarred,
              onPressed: onStar,
              constraints: const BoxConstraints(
                minWidth: AppSizes.minTouchTarget,
                minHeight: AppSizes.minTouchTarget,
              ),
            ),
          if (onMore != null)
            IconButton(
              icon: const Icon(Symbols.more_vert),
              onPressed: onMore,
              constraints: const BoxConstraints(
                minWidth: AppSizes.minTouchTarget,
                minHeight: AppSizes.minTouchTarget,
              ),
            ),
        ],
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}

/// One cell in a file grid (used by the Photos screen).
class FileGridCell extends StatelessWidget {
  const FileGridCell({
    super.key,
    required this.file,
    required this.onTap,
  });

  final DriveFile file;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final thumbnailUrl = file.thumbnailUrl;
    final Widget tile;
    if (thumbnailUrl != null) {
      tile = CachedNetworkImage(
        imageUrl: thumbnailUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorWidget: (_, _, _) => _typeTile(colorScheme),
        placeholder: (_, _) => _typeTile(colorScheme),
      );
    } else {
      tile = _typeTile(colorScheme);
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              clipBehavior: Clip.antiAlias,
              child: tile,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            file.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
          Text(
            formatDriveDate(file.modifiedAt),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeTile(ColorScheme colorScheme) {
    final Color tileColor = switch (file.type) {
      DriveFileType.folder => colorScheme.primaryContainer,
      DriveFileType.pdf => colorScheme.errorContainer,
      DriveFileType.image => colorScheme.tertiaryContainer,
      DriveFileType.video => colorScheme.secondaryContainer,
      _ => colorScheme.surfaceContainerHighest,
    };
    return Container(
      color: tileColor,
      alignment: Alignment.center,
      child: Icon(iconForType(file.type), size: 40),
    );
  }
}

/// Folders first, then files, each group sorted by name.
List<DriveFile> foldersFirst(List<DriveFile> files) {
  final folders = files.where((f) => f.type == DriveFileType.folder).toList()
    ..sort((a, b) => a.name.compareTo(b.name));
  final rest = files.where((f) => f.type != DriveFileType.folder).toList()
    ..sort((a, b) => a.name.compareTo(b.name));
  return <DriveFile>[...folders, ...rest];
}

/// A file list that switches between list and grid mode.
class DriveFileList extends StatelessWidget {
  const DriveFileList({
    super.key,
    required this.files,
    required this.isGrid,
    required this.onFileTap,
    this.onFolderTap,
    this.onLongPress,
    this.selectedIds = const <String>{},
    this.onStar,
    this.onMore,
  });

  final List<DriveFile> files;
  final bool isGrid;
  final void Function(DriveFile file) onFileTap;
  final void Function(DriveFile file)? onFolderTap;
  final void Function(DriveFile file)? onLongPress;
  final Set<String> selectedIds;
  final void Function(DriveFile file)? onStar;
  final void Function(DriveFile file)? onMore;

  @override
  Widget build(BuildContext context) {
    final ordered = foldersFirst(files);
    if (isGrid) {
      return GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.screenEdge),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.85,
        ),
        itemCount: ordered.length,
        itemBuilder: (context, index) {
          final file = ordered[index];
          return FileGridCell(
            file: file,
            onTap: () {
              if (file.type == DriveFileType.folder && onFolderTap != null) {
                onFolderTap!(file);
              } else {
                onFileTap(file);
              }
            },
          );
        },
      );
    }
    return ListView.builder(
      itemCount: ordered.length,
      itemBuilder: (context, index) {
        final file = ordered[index];
        return FileListTile(
          file: file,
          selected: selectedIds.contains(file.id),
          onTap: () {
            if (file.type == DriveFileType.folder && onFolderTap != null) {
              onFolderTap!(file);
            } else {
              onFileTap(file);
            }
          },
          onLongPress:
              onLongPress != null ? () => onLongPress!(file) : null,
          onStar: onStar != null ? () => onStar!(file) : null,
          onMore: onMore != null ? () => onMore!(file) : null,
        );
      },
    );
  }
}

/// Shared list body used by the Starred / Shared / Recent / Offline
/// screens: loading skeleton, error state with retry, empty state,
/// then the file list.
class FilteredFileList extends ConsumerWidget {
  const FilteredFileList({
    super.key,
    required this.filter,
    required this.emptyIcon,
  });

  final bool Function(DriveFile file) filter;
  final IconData emptyIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filesAsync = ref.watch(filesProvider);
    return filesAsync.when(
      loading: () => const DusLoadingSkeleton(),
      error: (error, _) => DusErrorState(
        message: l10n.error,
        onRetry: () => ref.invalidate(filesProvider),
      ),
      data: (files) {
        final filtered = files.where(filter).toList()
          ..sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
        if (filtered.isEmpty) {
          return DusEmptyState(
            icon: emptyIcon,
            title: l10n.driveNoFiles,
          );
        }
        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final file = filtered[index];
            return FileListTile(
              file: file,
              onTap: () => context.push('/preview/${file.id}'),
              onStar: () =>
                  ref.read(filesProvider.notifier).toggleStar(file.id),
              onMore: () {
                showFileDetailsSheet(context, ref, file);
              },
            );
          },
        );
      },
    );
  }
}

/// The uploads queue card, shown at the top of the Files screen while
/// uploads are running or finished-but-not-dismissed.
class UploadQueueCard extends StatelessWidget {
  const UploadQueueCard({
    super.key,
    required this.uploads,
    required this.onDismiss,
  });

  final List<UploadItem> uploads;
  final void Function(String id) onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.all(AppSpacing.screenEdge),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Symbols.upload, color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(l10n.driveUpload, style: theme.textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final upload in uploads) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(upload.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  if (upload.done)
                    IconButton(
                      icon: const Icon(Symbols.close),
                      onPressed: () => onDismiss(upload.id),
                      constraints: const BoxConstraints(
                        minWidth: AppSizes.minTouchTarget,
                        minHeight: AppSizes.minTouchTarget,
                      ),
                    )
                  else
                    Text('${(upload.progress * 100).toInt()}%'),
                ],
              ),
              LinearProgressIndicator(value: upload.progress),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}
