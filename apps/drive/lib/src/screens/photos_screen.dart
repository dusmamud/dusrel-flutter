import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:ui_kit/ui_kit.dart';

import '../models/drive_file.dart';
import '../providers/drive_providers.dart';
import '../widgets/file_widgets.dart';

/// Photos & media: a grid of image files with thumbnails.
/// Thumbnails load from the network when online; the type icon is the
/// offline fallback.
class PhotosScreen extends ConsumerWidget {
  const PhotosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filesAsync = ref.watch(filesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.drivePhotos)),
      body: filesAsync.when(
        loading: () => const DusLoadingSkeleton(),
        error: (error, _) => DusErrorState(
          message: l10n.error,
          onRetry: () => ref.invalidate(filesProvider),
        ),
        data: (files) {
          final photos = files
              .where((f) => !f.isTrashed && f.type == DriveFileType.image)
              .toList()
            ..sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
          if (photos.isEmpty) {
            return DusEmptyState(
              icon: Symbols.photo_library,
              title: l10n.driveNoFiles,
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.screenEdge),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final file = photos[index];
              return FileGridCell(
                file: file,
                onTap: () => context.push('/preview/${file.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
