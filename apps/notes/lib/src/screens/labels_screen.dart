import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../providers/notes_providers.dart';

/// Labels screen: tap a label chip to filter the home list by it.
class LabelsScreen extends ConsumerWidget {
  const LabelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final labels = ref.watch(notesRepositoryProvider).labels;
    final notesAsync = ref.watch(notesProvider);
    final selectedId = ref.watch(selectedLabelProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notesLabels)),
      body: notesAsync.when(
        loading: () => const DusLoadingSkeleton(),
        error: (error, _) => DusErrorState(
          message: l10n.error,
          onRetry: () => ref.invalidate(notesProvider),
          retryLabel: l10n.retry,
        ),
        data: (notes) {
          if (labels.isEmpty) {
            return DusEmptyState(
              icon: Icons.label_outlined,
              title: l10n.notesLabels,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.screenEdge),
            itemCount: labels.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final label = labels[index];
              final count = notes
                  .where((n) =>
                      n.labelIds.contains(label.id) &&
                      !n.isArchived &&
                      !n.isTrashed)
                  .length;
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.label_outlined),
                  title: Text(label.name),
                  subtitle: Text('$count'),
                  trailing: selectedId == label.id
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: () {
                    ref
                        .read(selectedLabelProvider.notifier)
                        .select(label.id);
                    Navigator.of(context).pop();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
