import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../data/mock_data.dart';
import '../providers/chat_providers.dart';
import 'group_info_screen.dart';

/// Contact info: avatar, online status, shared media, mute, block.
class ContactInfoScreen extends ConsumerWidget {
  const ContactInfoScreen({super.key, required this.chatId});

  final String chatId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final chat =
        ref.watch(chatsProvider).value?.where((c) => c.id == chatId).firstOrNull ??
            ref.read(chatRepositoryProvider).chatByIdSync(chatId);
    if (chat == null) {
      return Scaffold(
        appBar: AppBar(),
        body: DusErrorState(
          message: l10n.error,
          onRetry: () => context.pop(),
          retryLabel: l10n.back,
        ),
      );
    }
    final otherId = chat.participantIds
        .where((id) => id != currentUserId)
        .firstOrNull;
    final contact = otherId == null ? null : mockContactById(otherId);

    return Scaffold(
      appBar: AppBar(title: Text(chat.name)),
      body: ListView(
        children: [
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: DusAvatar(name: chat.name, size: 96),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Text(
              chat.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          if (contact?.isOnline == true)
            Center(
              child: Text(
                l10n.chatOnline,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenEdge,
            ),
            child: Text(
              l10n.chatMedia,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SharedMediaGrid(imageUrls: buildMockMediaUrls()),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1),
          SwitchListTile(
            title: Text(l10n.chatMute),
            secondary: const Icon(Icons.volume_off),
            value: chat.isMuted,
            onChanged: (value) {
              ref.read(chatsProvider.notifier).toggleMute(chat.id, value);
            },
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenEdge),
            child: DusButton(
              label: l10n.block,
              variant: DusButtonVariant.outlined,
              icon: Icons.block,
              expanded: true,
              onPressed: () async {
                final block = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(chat.name),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(l10n.block),
                      ),
                    ],
                  ),
                );
                if (block == true && context.mounted) {
                  context.go('/chats');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
