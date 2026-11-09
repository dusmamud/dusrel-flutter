import 'package:cached_network_image/cached_network_image.dart';
import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:ui_kit/ui_kit.dart';

import '../models/drive_file.dart';
import '../providers/drive_providers.dart';
import '../widgets/file_sheets.dart';

/// File preview: images open full-screen (easy_image_viewer); other
/// types show a type icon with details and actions. No fake rendering —
/// a PDF is not drawn as a document, it shows its icon and metadata.
class PreviewScreen extends ConsumerWidget {
  const PreviewScreen({super.key, required this.fileId});

  final String fileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filesAsync = ref.watch(filesProvider);
    return filesAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const DusLoadingSkeleton(),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: DusErrorState(
          message: l10n.error,
          onRetry: () => ref.invalidate(filesProvider),
        ),
      ),
      data: (files) {
        final file = files.where((f) => f.id == fileId).firstOrNull;
        if (file == null) {
          return Scaffold(
            appBar: AppBar(),
            body: DusEmptyState(
              icon: Symbols.insert_drive_file,
              title: l10n.driveNoFiles,
            ),
          );
        }
        final theme = Theme.of(context);
        final imageUrl = file.imageUrl;
        return Scaffold(
          appBar: AppBar(
            title: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            actions: [
              IconButton(
                icon: Icon(
                  file.isStarred ? Symbols.star : Symbols.star_border,
                ),
                tooltip: l10n.driveStarred,
                onPressed: () =>
                    ref.read(filesProvider.notifier).toggleStar(file.id),
                constraints: const BoxConstraints(
                  minWidth: AppSizes.minTouchTarget,
                  minHeight: AppSizes.minTouchTarget,
                ),
              ),
              IconButton(
                icon: const Icon(Symbols.share),
                tooltip: l10n.share,
                onPressed: () => showShareSheet(context, file),
                constraints: const BoxConstraints(
                  minWidth: AppSizes.minTouchTarget,
                  minHeight: AppSizes.minTouchTarget,
                ),
              ),
              IconButton(
                icon: const Icon(Symbols.more_vert),
                onPressed: () => showFileDetailsSheet(context, ref, file),
                constraints: const BoxConstraints(
                  minWidth: AppSizes.minTouchTarget,
                  minHeight: AppSizes.minTouchTarget,
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.screenEdge),
            children: [
              if (imageUrl != null)
                GestureDetector(
                  onTap: () => showImageViewer(
                    context,
                    CachedNetworkImageProvider(imageUrl),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => _typeHero(theme, file),
                      placeholder: (_, _) => _typeHero(theme, file),
                    ),
                  ),
                )
              else
                _typeHero(theme, file),
              const SizedBox(height: AppSpacing.lg),
              Text(file.name, style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              if (file.type != DriveFileType.folder)
                Text(formatFileSize(file.sizeBytes)),
              Text(formatDriveDate(file.modifiedAt)),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  DusAvatar(name: file.owner, size: AppSizes.avatarSm),
                  const SizedBox(width: AppSpacing.sm),
                  Text(file.owner),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: DusButton(
                      label: l10n.driveDownload,
                      icon: Symbols.download,
                      variant: DusButtonVariant.tonal,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: DusButton(
                      label: l10n.share,
                      icon: Symbols.share,
                      variant: DusButtonVariant.tonal,
                      onPressed: () => showShareSheet(context, file),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _typeHero(ThemeData theme, DriveFile file) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      alignment: Alignment.center,
      child: Icon(
        iconForType(file.type),
        size: 96,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
