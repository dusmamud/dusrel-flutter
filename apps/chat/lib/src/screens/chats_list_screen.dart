import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../models/chat.dart';
import '../providers/chat_providers.dart';
import '../widgets/chat_list_tile.dart';

/// Chats tab: searchable list of conversations.
class ChatsListScreen extends ConsumerStatefulWidget {
  const ChatsListScreen({super.key});

  @override
  ConsumerState<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends ConsumerState<ChatsListScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(chatSearchQueryProvider),
    );
    _searchController.addListener(() {
      ref.read(chatSearchQueryProvider.notifier).set(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chatsAsync = ref.watch(chatsProvider);
    final query = ref.watch(chatSearchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chatChats),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: l10n.search,
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: l10n.settings,
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: chatsAsync.when(
        loading: () => const DusLoadingSkeleton(),
        error: (_, _) => DusErrorState(
          message: l10n.error,
          onRetry: () => ref.read(chatsProvider.notifier).refresh(),
          retryLabel: l10n.retry,
        ),
        data: (chats) {
          final filtered = _filter(chats, query);
          return Column(
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
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? DusEmptyState(
                        icon: query.isEmpty
                            ? Icons.chat_bubble_outline
                            : Icons.search_off,
                        title: query.isEmpty
                            ? l10n.chatEmpty
                            : l10n.noResults,
                      )
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const Divider(
                          height: 1,
                          indent: 72,
                        ),
                        itemBuilder: (context, index) {
                          final chat = filtered[index];
                          return ChatListTile(
                            chat: chat,
                            onTap: () {
                              ref
                                  .read(chatsProvider.notifier)
                                  .markRead(chat.id);
                              context.push('/chats/${chat.id}');
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/new-chat'),
        tooltip: l10n.chatNewChat,
        child: const Icon(Icons.add_comment),
      ),
    );
  }

  List<Chat> _filter(List<Chat> chats, String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return chats;
    return [
      for (final chat in chats)
        if (chat.name.toLowerCase().contains(needle) ||
            chat.lastMessageText.toLowerCase().contains(needle))
          chat,
    ];
  }
}
