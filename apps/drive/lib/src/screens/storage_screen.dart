import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../providers/drive_providers.dart';
import '../widgets/file_widgets.dart';

/// Storage: usage meter and the largest files first.
class StorageScreen extends ConsumerWidget {
  const StorageScreen({super.key});

  // Mock quota: 7.2 GB used of 15 GB.
  static const double usedGb = 7.2;
  static const double totalGb = 15;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filesAsync = ref.watch(filesProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.driveStorage)),
      body: filesAsync.when(
        loading: () => const DusLoadingSkeleton(),
        error: (error, _) => DusErrorState(
          message: l10n.error,
          onRetry: () => ref.invalidate(filesProvider),
        ),
        data: (files) {
          final largest = files.where((f) => !f.isTrashed).toList()
            ..sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.screenEdge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${usedGb.toStringAsFixed(1)} GB / ${totalGb.toStringAsFixed(0)} GB',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    LinearProgressIndicator(value: usedGb / totalGb),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenEdge,
                  AppSpacing.md,
                  AppSpacing.screenEdge,
                  AppSpacing.sm,
                ),
                child: Text(l10n.driveLargestFiles, style: theme.textTheme.titleMedium),
              ),
              for (final file in largest.take(8))
                FileListTile(
                  file: file,
                  onTap: () => context.push('/preview/${file.id}'),
                  onStar: () =>
                      ref.read(filesProvider.notifier).toggleStar(file.id),
                ),
            ],
          );
        },
      ),
    );
  }
}
