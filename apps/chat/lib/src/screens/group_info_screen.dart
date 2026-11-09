import 'package:cached_network_image/cached_network_image.dart';
import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../data/mock_data.dart';
import '../models/chat.dart';
import '../providers/chat_providers.dart';

/// Shared media grid used by group and contact info screens.
/// Offline-safe: every thumbnail has an error fallback.
class SharedMediaGrid extends StatelessWidget {
  const SharedMediaGrid({super.key, required this.imageUrls});

  final List<String> imageUrls;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenEdge,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.xs,
        mainAxisSpacing: AppSpacing.xs,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: CachedNetworkImage(
            imageUrl: imageUrls[index],
            fit: BoxFit.cover,
            placeholder: (_, _) => Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            errorWidget: (_, _, _) => Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.broken_image,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Group info: avatar, members, shared media, mute toggle, leave group.
class GroupInfoScreen extends ConsumerWidget {
  const GroupInfoScreen({super.key, required this.chatId});

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
    final members = [
      for (final id in chat.participantIds)
        if (id != currentUserId) mockContactById(id),
    ].whereType<Contact>().toList();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.chatGroupInfo)),
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
          Center(
            child: Text(
              '${members.length + 1} ${l10n.chatMembers}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenEdge,
            ),
            child: Text(
              l10n.chatMembers,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final member in members)
            ListTile(
              leading: DusAvatar(
                name: member.name,
                size: AppSizes.avatarMd,
              ),
              title: Text(member.name),
              subtitle: member.isOnline ? Text(l10n.chatOnline) : null,
            ),
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
              label: l10n.leaveGroup,
              variant: DusButtonVariant.outlined,
              icon: Icons.exit_to_app,
              expanded: true,
              onPressed: () async {
                final leave = await showDialog<bool>(
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
                        child: Text(l10n.leaveGroup),
                      ),
                    ],
                  ),
                );
                if (leave == true && context.mounted) {
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
