import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:ui_kit/ui_kit.dart';

import 'providers/drive_providers.dart';
import 'screens/files_screen.dart';
import 'screens/home_screen.dart';
import 'screens/offline_screen.dart';
import 'screens/photos_screen.dart';
import 'screens/preview_screen.dart';
import 'screens/recent_screen.dart';
import 'screens/search_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/shared_screen.dart';
import 'screens/starred_screen.dart';
import 'screens/storage_screen.dart';
import 'screens/trash_screen.dart';
import 'widgets/file_sheets.dart';

/// The app shell: bottom tabs Home / Starred / Shared / Files, with the
/// + FAB opening the create sheet. On wide screens the shell shows a
/// navigation rail (handled by [DusAppShell]).
class DriveShell extends ConsumerWidget {
  const DriveShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final index = navigationShell.currentIndex;
    final isGrid = ref.watch(viewModeProvider);
    final destinations = <DusDestination>[
      DusDestination(
        icon: Symbols.home,
        selectedIcon: Symbols.home,
        label: l10n.driveHome,
      ),
      DusDestination(
        icon: Symbols.star_border,
        selectedIcon: Symbols.star,
        label: l10n.driveStarred,
      ),
      DusDestination(
        icon: Symbols.group,
        selectedIcon: Symbols.group,
        label: l10n.driveShared,
      ),
      DusDestination(
        icon: Symbols.folder_open,
        selectedIcon: Symbols.folder,
        label: l10n.driveFiles,
      ),
    ];
    final titles = <String>[
      l10n.driveHome,
      l10n.driveStarred,
      l10n.driveShared,
      l10n.driveMyDrive,
    ];
    return DusAppShell(
      destinations: destinations,
      selectedIndex: index,
      onDestinationSelected: (i) {
        ref.read(selectionProvider.notifier).clear();
        navigationShell.goBranch(i);
      },
      title: titles[index],
      actions: [
        if (index == 3)
          IconButton(
            icon: Icon(isGrid ? Symbols.view_list : Symbols.grid_view),
            onPressed: () => ref.read(viewModeProvider.notifier).toggle(),
            constraints: const BoxConstraints(
              minWidth: AppSizes.minTouchTarget,
              minHeight: AppSizes.minTouchTarget,
            ),
          ),
        IconButton(
          icon: const Icon(Symbols.search),
          onPressed: () => context.push('/search'),
          constraints: const BoxConstraints(
            minWidth: AppSizes.minTouchTarget,
            minHeight: AppSizes.minTouchTarget,
          ),
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCreateSheet(context, ref),
        tooltip: l10n.driveUpload,
        child: const Icon(Symbols.add),
      ),
      body: navigationShell,
    );
  }
}

final driveRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          DriveShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/starred',
              builder: (context, state) => const StarredScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/shared',
              builder: (context, state) => const SharedScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/files',
              builder: (context, state) => const FilesScreen(),
              routes: [
                GoRoute(
                  path: ':folderId',
                  builder: (context, state) => FilesScreen(
                    folderId: state.pathParameters['folderId'],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/recent',
      builder: (context, state) => const RecentScreen(),
    ),
    GoRoute(
      path: '/photos',
      builder: (context, state) => const PhotosScreen(),
    ),
    GoRoute(
      path: '/offline',
      builder: (context, state) => const OfflineScreen(),
    ),
    GoRoute(
      path: '/trash',
      builder: (context, state) => const TrashScreen(),
    ),
    GoRoute(
      path: '/storage',
      builder: (context, state) => const StorageScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/preview/:fileId',
      builder: (context, state) => PreviewScreen(
        fileId: state.pathParameters['fileId']!,
      ),
    ),
  ],
);
