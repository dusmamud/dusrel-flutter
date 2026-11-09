import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../models/note.dart';
import '../providers/notes_providers.dart';

/// Settings: theme mode (via the shared ui_kit provider) and the
/// default home layout.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final viewMode = ref.watch(viewModeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenEdge),
        children: [
          Text(l10n.theme, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          RadioGroup<ThemeMode>(
            groupValue: themeMode,
            onChanged: (value) {
              if (value != null) {
                ref.read(themeModeProvider.notifier).set(value);
              }
            },
            child: Column(
              children: [
                for (final (mode, label) in [
                  (ThemeMode.system, l10n.themeSystem),
                  (ThemeMode.light, l10n.themeLight),
                  (ThemeMode.dark, l10n.themeDark),
                ])
                  RadioListTile<ThemeMode>(
                    title: Text(label),
                    value: mode,
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.defaultView, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          RadioGroup<NoteViewMode>(
            groupValue: viewMode,
            onChanged: (value) {
              if (value != null) {
                ref.read(viewModeProvider.notifier).set(value);
              }
            },
            child: Column(
              children: [
                RadioListTile<NoteViewMode>(
                  title: Text(l10n.notesGridView),
                  value: NoteViewMode.grid,
                ),
                RadioListTile<NoteViewMode>(
                  title: Text(l10n.notesListView),
                  value: NoteViewMode.list,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
