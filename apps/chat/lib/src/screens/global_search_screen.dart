import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../models/chat.dart';
import '../providers/chat_providers.dart';
import '../widgets/chat_list_tile.dart';

/// Searches chats (by name / last message) and every message.
/// Tapping a chat opens it; tapping a message opens its chat
/// scrolled to that message.
class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() =>
      _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chatsAsync = ref.watch(chatsProvider);
    final needle = _query.trim().toLowerCase();

    final chats = chatsAsync.value ?? const <Chat>[];
    final matchingChats = needle.isEmpty
        ? const <Chat>[]
        : [
            for (final chat in chats)
              if (chat.name.toLowerCase().contains(needle) ||
                  chat.lastMessageText.toLowerCase().contains(needle))
                chat,
          ];
    final matchingMessages = needle.isEmpty
        ? const <MessageSearchResult>[]
        : ref.read(chatRepositoryProvider).searchAllMessages(_query);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.search)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenEdge,
              AppSpacing.sm,
              AppSpacing.screenEdge,
              AppSpacing.sm,
            ),
            child: DusSearchBar(
              controller: _searchController,
              hintText: l10n.chatSearchChats,
              autofocus: true,
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: chatsAsync.when(
              loading: () => const DusLoadingSkeleton(),
              error: (_, _) => DusErrorState(
                message: l10n.error,
                onRetry: () =>
                    ref.read(chatsProvider.notifier).refresh(),
                retryLabel: l10n.retry,
              ),
              data: (_) {
                if (needle.isEmpty) {
                  return DusEmptyState(
                    icon: Icons.search,
                    title: l10n.search,
                  );
                }
                if (matchingChats.isEmpty && matchingMessages.isEmpty) {
                  return DusEmptyState(
                    icon: Icons.search_off,
                    title: l10n.noResults,
                  );
                }
                return ListView(
                  children: [
                    for (final chat in matchingChats)
                      ChatListTile(
                        chat: chat,
                        onTap: () => context.push('/chats/${chat.id}'),
                      ),
                    if (matchingChats.isNotEmpty &&
                        matchingMessages.isNotEmpty)
                      const Divider(height: 1),
                    for (final result in matchingMessages)
                      ListTile(
                        leading: DusAvatar(
                          name: result.chat.name,
                          size: AppSizes.avatarMd,
                        ),
                        title: Text(
                          result.message.text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(result.chat.name),
                        trailing: Text(
                          formatChatTime(
                            context,
                            result.message.createdAt,
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        onTap: () => context.push(
                          '/chats/${result.chat.id}?scrollTo=${result.message.id}',
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
