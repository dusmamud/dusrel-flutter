import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import 'screens/chats_list_screen.dart';
import 'screens/coming_soon_screen.dart';
import 'screens/contact_info_screen.dart';
import 'screens/conversation_screen.dart';
import 'screens/global_search_screen.dart';
import 'screens/group_info_screen.dart';
import 'screens/in_chat_search_screen.dart';
import 'screens/media_viewer_screen.dart';
import 'screens/new_chat_screen.dart';
import 'screens/settings_screen.dart';

/// App router. The bottom-tab shell covers the four tabs; detail
/// screens (conversation, info, search, settings) sit above the shell
/// so the bottom navigation hides while they are open.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/chats',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _ChatShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chats',
                builder: (context, state) => const ChatsListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/updates',
                builder: (context, state) => ComingSoonScreen(
                  icon: Icons.update,
                  title: AppLocalizations.of(context).chatUpdates,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/communities',
                builder: (context, state) => ComingSoonScreen(
                  icon: Icons.groups,
                  title: AppLocalizations.of(context).chatCommunities,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calls',
                builder: (context, state) => ComingSoonScreen(
                  icon: Icons.call,
                  title: AppLocalizations.of(context).chatCalls,
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/chats/:chatId',
        builder: (context, state) => ConversationScreen(
          chatId: state.pathParameters['chatId']!,
          scrollToMessageId: state.uri.queryParameters['scrollTo'],
        ),
        routes: [
          GoRoute(
            path: 'group-info',
            builder: (context, state) => GroupInfoScreen(
              chatId: state.pathParameters['chatId']!,
            ),
          ),
          GoRoute(
            path: 'contact-info',
            builder: (context, state) => ContactInfoScreen(
              chatId: state.pathParameters['chatId']!,
            ),
          ),
          GoRoute(
            path: 'search',
            builder: (context, state) => InChatSearchScreen(
              chatId: state.pathParameters['chatId']!,
            ),
          ),
          GoRoute(
            path: 'media',
            builder: (context, state) {
              final url = state.extra;
              if (url is String && url.isNotEmpty) {
                return MediaViewerScreen(imageUrl: url);
              }
              return Scaffold(
                appBar: AppBar(),
                body: DusErrorState(
                  message: AppLocalizations.of(context).error,
                  onRetry: () => context.pop(),
                  retryLabel: AppLocalizations.of(context).back,
                ),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/new-chat',
        builder: (context, state) => const NewChatScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const GlobalSearchScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

/// Bottom-tab shell (Chats / Updates / Communities / Calls).
/// Only the Chats tab is built in v1; the other three show a designed
/// "coming soon" empty state.
class _ChatShell extends StatelessWidget {
  const _ChatShell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DusAppShell(
      destinations: [
        DusDestination(
          icon: Icons.chat_bubble_outline,
          selectedIcon: Icons.chat_bubble,
          label: l10n.chatChats,
        ),
        DusDestination(
          icon: Icons.update,
          selectedIcon: Icons.update,
          label: l10n.chatUpdates,
        ),
        DusDestination(
          icon: Icons.groups_outlined,
          selectedIcon: Icons.groups,
          label: l10n.chatCommunities,
        ),
        DusDestination(
          icon: Icons.call_outlined,
          selectedIcon: Icons.call,
          label: l10n.chatCalls,
        ),
      ],
      selectedIndex: shell.currentIndex,
      onDestinationSelected: shell.goBranch,
      body: shell,
    );
  }
}
