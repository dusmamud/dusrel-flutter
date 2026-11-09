import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:ui_kit/ui_kit.dart';

import '../models/drive_file.dart';
import '../providers/drive_providers.dart';
import '../widgets/file_widgets.dart';

/// Home tab: suggested files row, recent activity list, and quick
/// links to the other Drive areas.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

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
        final visible = files.where((f) => !f.isTrashed).toList();
        final suggested = visible.where((f) => f.isStarred).toList();
        final recent = List<DriveFile>.of(visible)
          ..sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
        final theme = Theme.of(context);
        return ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          children: [
            _QuickLinks(l10n: l10n),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                AppSpacing.md,
                AppSpacing.screenEdge,
                AppSpacing.sm,
              ),
              child: Text(l10n.driveSuggested, style: theme.textTheme.titleMedium),
            ),
            SizedBox(
              height: 148,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenEdge,
                ),
                itemCount: suggested.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.md),
                itemBuilder: (context, index) {
                  final file = suggested[index];
                  return SizedBox(
                    width: 120,
                    child: FileGridCell(
                      file: file,
                      onTap: () => context.push('/preview/${file.id}'),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                AppSpacing.lg,
                AppSpacing.screenEdge,
                AppSpacing.sm,
              ),
              child: Text(l10n.driveActivity, style: theme.textTheme.titleMedium),
            ),
            for (final file in recent.take(8))
              FileListTile(
                file: file,
                onTap: () => context.push('/preview/${file.id}'),
                onStar: () =>
                    ref.read(filesProvider.notifier).toggleStar(file.id),
              ),
          ],
        );
      },
    );
  }
}

class _QuickLinks extends StatelessWidget {
  const _QuickLinks({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final links = <({IconData icon, String label, String route})>[
      (icon: Symbols.schedule, label: l10n.driveRecent, route: '/recent'),
      (icon: Symbols.photo_library, label: l10n.drivePhotos, route: '/photos'),
      (icon: Symbols.cloud_off, label: l10n.driveOffline, route: '/offline'),
      (icon: Symbols.delete, label: l10n.driveTrash, route: '/trash'),
      (icon: Symbols.storage, label: l10n.driveStorage, route: '/storage'),
      (icon: Symbols.settings, label: l10n.settings, route: '/settings'),
    ];
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenEdge),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final link in links)
            ActionChip(
              avatar: Icon(link.icon, size: 18),
              label: Text(link.label),
              onPressed: () => context.push(link.route),
            ),
        ],
      ),
    );
  }
}
