import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../models/chat.dart';
import '../providers/chat_providers.dart';
import '../widgets/chat_list_tile.dart';

/// Search within the open conversation. Tapping a result pops back
/// with the message id so the thread can scroll to it.
class InChatSearchScreen extends ConsumerStatefulWidget {
  const InChatSearchScreen({super.key, required this.chatId});

  final String chatId;

  @override
  ConsumerState<InChatSearchScreen> createState() =>
      _InChatSearchScreenState();
}

class _InChatSearchScreenState extends ConsumerState<InChatSearchScreen> {
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
    final messages = ref.watch(conversationProvider(widget.chatId));
    final needle = _query.trim().toLowerCase();
    final results = needle.isEmpty
        ? const <ChatMessage>[]
        : [
            for (final message in messages)
              if (message.text.toLowerCase().contains(needle)) message,
          ];

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
            child: _query.trim().isEmpty
                ? DusEmptyState(
                    icon: Icons.search,
                    title: l10n.search,
                  )
                : results.isEmpty
                    ? DusEmptyState(
                        icon: Icons.search_off,
                        title: l10n.noResults,
                      )
                    : ListView.separated(
                        itemCount: results.length,
                        separatorBuilder: (_, _) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final message = results[index];
                          return ListTile(
                            title: Text(
                              message.text,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              formatChatTime(
                                context,
                                message.createdAt,
                              ),
                            ),
                            onTap: () => context.pop(message.id),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
