import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

import '../models/chat.dart';

/// Localized list-row time: clock time today, short date otherwise.
/// Uses [MaterialLocalizations] so the format follows the device locale.
String formatChatTime(BuildContext context, DateTime time) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(time.year, time.month, time.day);
  if (day == today) {
    return MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay.fromDateTime(time));
  }
  return MaterialLocalizations.of(context).formatCompactDate(time);
}

/// One row in the chats list: avatar, name, last message, time,
/// unread badge, online dot and mute icon.
class ChatListTile extends StatelessWidget {
  const ChatListTile({
    super.key,
    required this.chat,
    required this.onTap,
  });

  final Chat chat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenEdge,
        vertical: AppSpacing.xs,
      ),
      leading: _AvatarWithPresence(chat: chat),
      title: Text(
        chat.name,
        style: theme.textTheme.titleMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        chat.lastMessageText,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            formatChatTime(context, chat.lastMessageAt),
            style: theme.textTheme.bodySmall?.copyWith(
              color: chat.unreadCount > 0
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (chat.isMuted)
                Icon(
                  Icons.volume_off,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                  semanticLabel:
                      AppLocalizations.of(context).chatMute,
                ),
              if (chat.isMuted && chat.unreadCount > 0)
                const SizedBox(width: AppSpacing.xs),
              if (chat.unreadCount > 0)
                Container(
                  constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(AppRadii.full),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${chat.unreadCount}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AvatarWithPresence extends StatelessWidget {
  const _AvatarWithPresence({required this.chat});

  final Chat chat;

  @override
  Widget build(BuildContext context) {
    final avatar = DusAvatar(
      name: chat.name,
      size: AppSizes.avatarLg,
    );
    if (!chat.isOnline || chat.isGroup) return avatar;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.surface,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
