import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import 'src/screens/archive_screen.dart';
import 'src/screens/editor_screen.dart';
import 'src/screens/labels_screen.dart';
import 'src/screens/search_screen.dart';
import 'src/screens/settings_screen.dart';
import 'src/screens/shell_screen.dart';
import 'src/screens/trash_screen.dart';

void main() {
  runApp(const ProviderScope(child: NotesApp()));
}

GoRouter _createRouter() {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const NotesShell(),
      ),
      GoRoute(
        path: '/editor/:id',
        builder: (context, state) =>
            EditorScreen(noteId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/archive',
        builder: (context, state) => const ArchiveScreen(),
      ),
      GoRoute(
        path: '/trash',
        builder: (context, state) => const TrashScreen(),
      ),
      GoRoute(
        path: '/labels',
        builder: (context, state) => const LabelsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}

/// Stateful so each app instance owns its [GoRouter]. A single top-level
/// router instance breaks when the widget tree is rebuilt (e.g. in tests),
/// because GoRouter holds a GlobalKey that can only live in one tree.
class NotesApp extends ConsumerStatefulWidget {
  const NotesApp({super.key});

  @override
  ConsumerState<NotesApp> createState() => _NotesAppState();
}

class _NotesAppState extends ConsumerState<NotesApp> {
  late final GoRouter _router = _createRouter();

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      routerConfig: _router,
      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (context) => AppLocalizations.of(context).notesAppTitle,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
    );
  }
}
