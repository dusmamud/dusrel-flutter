import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../providers/chat_providers.dart';
/// Searchable contacts list to start a new 1:1 chat.
class NewChatScreen extends ConsumerStatefulWidget {
  const NewChatScreen({super.key});

  @override
  ConsumerState<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends ConsumerState<NewChatScreen> {
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
    final contacts = ref.watch(chatRepositoryProvider).listContactsSync();
    final needle = _query.trim().toLowerCase();
    final filtered = needle.isEmpty
        ? contacts
        : [
            for (final contact in contacts)
              if (contact.name.toLowerCase().contains(needle)) contact,
          ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.chatNewChat)),
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
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.group_add,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            title: Text(l10n.chatNewGroup),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.chatNewGroup)),
              );
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: filtered.isEmpty
                ? DusEmptyState(
                    icon: Icons.search_off,
                    title: l10n.noResults,
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final contact = filtered[index];
                      return ListTile(
                        leading: DusAvatar(
                          name: contact.name,
                          size: AppSizes.avatarMd,
                        ),
                        title: Text(contact.name),
                        subtitle: contact.isOnline
                            ? Text(
                                l10n.chatOnline,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary,
                                ),
                              )
                            : null,
                        onTap: () async {
                          final chat = await ref
                              .read(chatRepositoryProvider)
                              .openOrCreateChat(contact.id);
                          ref.read(chatsProvider.notifier).addChat(chat);
                          if (context.mounted) {
                            context.pushReplacement('/chats/${chat.id}');
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
