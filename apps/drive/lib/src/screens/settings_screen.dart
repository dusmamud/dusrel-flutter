import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:ui_kit/ui_kit.dart';

/// Settings: theme mode, storage, offline.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenEdge),
        children: [
          Text(l10n.settings, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          // Icon-only segments: no theme strings exist in l10n yet,
          // so no English text is hardcoded here.
          SegmentedButton<ThemeMode>(
            segments: const <ButtonSegment<ThemeMode>>[
              ButtonSegment<ThemeMode>(
                value: ThemeMode.system,
                icon: Icon(Symbols.brightness_auto),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.light,
                icon: Icon(Symbols.light_mode),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.dark,
                icon: Icon(Symbols.dark_mode),
              ),
            ],
            selected: <ThemeMode>{themeMode},
            onSelectionChanged: (selected) => ref
                .read(themeModeProvider.notifier)
                .set(selected.first),
          ),
          const SizedBox(height: AppSpacing.lg),
          ListTile(
            leading: const Icon(Symbols.storage),
            title: Text(l10n.driveStorage),
            trailing: const Icon(Symbols.chevron_right),
            onTap: () => context.push('/storage'),
            contentPadding: EdgeInsets.zero,
          ),
          ListTile(
            leading: const Icon(Symbols.cloud_off),
            title: Text(l10n.driveOffline),
            trailing: const Icon(Symbols.chevron_right),
            onTap: () => context.push('/offline'),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
