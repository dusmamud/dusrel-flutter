import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../providers/notes_providers.dart';
import '../widgets/note_card.dart';

/// Reminders tab: notes that have a reminder set, soonest first.
class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notesAsync = ref.watch(notesProvider);
    final labels = ref.watch(notesRepositoryProvider).labels;

    return notesAsync.when(
      loading: () => const DusLoadingSkeleton(),
      error: (error, _) => DusErrorState(
        message: l10n.error,
        onRetry: () => ref.invalidate(notesProvider),
        retryLabel: l10n.retry,
      ),
      data: (notes) {
        final withReminders = notes
            .where((n) => n.reminderAt != null && !n.isTrashed)
            .toList()
          ..sort((a, b) => a.reminderAt!.compareTo(b.reminderAt!));
        if (withReminders.isEmpty) {
          return DusEmptyState(
            icon: Icons.notifications_outlined,
            title: l10n.notesReminders,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.screenEdge),
          itemCount: withReminders.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final note = withReminders[index];
            return NoteCard(
              note: note,
              labels: labels,
              onTap: () => context.push('/editor/${note.id}'),
            );
          },
        );
      },
    );
  }
}
