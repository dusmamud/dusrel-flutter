import 'package:dusrel_l10n/dusrel_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' as core;
import 'package:flutter_chat_ui/flutter_chat_ui.dart' as chat_ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:ui_kit/ui_kit.dart';

import '../data/mock_data.dart';
import '../mappers/chat_mappers.dart';
import '../models/chat.dart';
import '../providers/chat_providers.dart';
import '../widgets/message_context_menu.dart';
import '../widgets/typing_indicator_row.dart';

/// One open conversation, rendered with `flutter_chat_ui`.
class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({
    super.key,
    required this.chatId,
    this.scrollToMessageId,
  });

  final String chatId;

  /// When set, the list scrolls to this message after the first frame
  /// (used by global / in-chat search results).
  final String? scrollToMessageId;

  @override
  ConsumerState<ConversationScreen> createState() =>
      _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  late final core.InMemoryChatController _controller;
  ChatMessage? _replyingTo;

  @override
  void initState() {
    super.initState();
    final messages = ref.read(conversationProvider(widget.chatId));
    _controller = core.InMemoryChatController(
      messages: [for (final m in messages) m.toCoreMessage()],
    );
    if (widget.scrollToMessageId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.scrollToMessage(
          widget.scrollToMessageId!,
          alignment: 0.5,
        );
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Keeps the chat-ui controller in step with the Riverpod message list.
  void _syncController(List<ChatMessage> next) {
    final controllerIds =
        _controller.messages.map((m) => m.id).toSet();
    final nextIds = next.map((m) => m.id).toSet();
    for (final removedId in controllerIds.difference(nextIds)) {
      final message =
          _controller.messages.firstWhere((m) => m.id == removedId);
      _controller.removeMessage(message);
    }
    for (final message in next) {
      if (!controllerIds.contains(message.id)) {
        _controller.insertMessage(message.toCoreMessage());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chats = ref.watch(chatsProvider).value ?? const <Chat>[];
    final chat = chats.where((c) => c.id == widget.chatId).firstOrNull ??
        ref.read(chatRepositoryProvider).chatByIdSync(widget.chatId);
    final messages = ref.watch(conversationProvider(widget.chatId));
    final typingUser = ref.watch(typingUserProvider(widget.chatId));

    ref.listen<List<ChatMessage>>(
      conversationProvider(widget.chatId),
      (_, next) => _syncController(next),
    );

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

    final subtitle = typingUser != null
        ? l10n.chatTyping
        : chat.isGroup
            ? l10n.chatMembers
            : chat.isOnline
                ? l10n.chatOnline
                : null;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: InkWell(
          onTap: () => _openInfo(context, chat),
          child: Row(
            children: [
              DusAvatar(name: chat.name, size: AppSizes.avatarMd),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: l10n.search,
            onPressed: () async {
              final messageId = await context.push<String>(
                '/chats/${chat.id}/search',
              );
              if (messageId != null) {
                await _controller.scrollToMessage(
                  messageId,
                  alignment: 0.5,
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: chat.isGroup ? l10n.chatGroupInfo : l10n.chatMembers,
            onPressed: () => _openInfo(context, chat),
          ),
        ],
      ),
      body: Column(
        children: [
          if (typingUser != null)
            TypingIndicatorRow(userName: typingUser),
          if (_replyingTo != null)
            _ReplyPreview(
              message: _replyingTo!,
              onCancel: () => setState(() => _replyingTo = null),
            ),
          Expanded(
            // flutter_chat_ui is built on the material_ui fork: its
            // composer needs a material_ui Material ancestor (Flutter's
            // Scaffold only provides flutter/material's Material).
            child: mui.Material(
              color: Theme.of(context).colorScheme.surface,
              child: chat_ui.Chat(
              currentUserId: currentUserId,
              resolveUser: (id) async => resolveChatUser(id),
              chatController: _controller,
              theme: _chatTheme(context),
              builders: core.Builders(
                composerBuilder: (context) => chat_ui.Composer(
                  hintText: l10n.chatTypeMessage,
                ),
              ),
              onMessageSend: (text) {
                final replyToId = _replyingTo?.id;
                setState(() => _replyingTo = null);
                ref
                    .read(conversationProvider(widget.chatId).notifier)
                    .sendMessage(text, replyToId: replyToId);
              },
              onMessageTap: (context, message, {required index, required details}) {
                if (message is core.ImageMessage) {
                  context.push(
                    '/chats/${chat.id}/media',
                    extra: message.source,
                  );
                }
              },
              onMessageLongPress:
                  (context, message, {required index, required details}) async {
                final mine = messages
                    .where((m) => m.id == message.id)
                    .firstOrNull;
                if (mine == null) return;
                final action =
                    await showMessageContextMenu(context, mine);
                if (!context.mounted) return;
                switch (action) {
                  case MessageAction.reply:
                    setState(() => _replyingTo = mine);
                  case MessageAction.forward:
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.chatForward)),
                    );
                  case MessageAction.delete:
                    await ref
                        .read(conversationProvider(widget.chatId).notifier)
                        .deleteMessage(mine.id);
                  case MessageAction.copy:
                  case null:
                    break;
                }
              },
              onAttachmentTap: () => showAttachmentSheet(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openInfo(BuildContext context, Chat chat) {
    if (chat.isGroup) {
      context.push('/chats/${chat.id}/group-info');
    } else {
      context.push('/chats/${chat.id}/contact-info');
    }
  }
}

/// Builds the `flutter_chat_ui` theme from the app's own Material 3
/// color scheme, so sent bubbles use the suite's primary color in both
/// light and dark mode. (`ChatTheme.fromThemeData` cannot be used: it
/// expects the `material_ui` package's own ThemeData type.)
core.ChatTheme _chatTheme(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  final base = Theme.of(context).brightness == Brightness.dark
      ? core.ChatColors.dark()
      : core.ChatColors.light();
  return core.ChatTheme(
    colors: base.copyWith(
      primary: colorScheme.primary,
      onPrimary: colorScheme.onPrimary,
      surface: colorScheme.surface,
      onSurface: colorScheme.onSurface,
      surfaceContainer: colorScheme.surfaceContainer,
      surfaceContainerLow: colorScheme.surfaceContainerLow,
      surfaceContainerHigh: colorScheme.surfaceContainerHigh,
    ),
    typography: core.ChatTypography.standard(),
    shape: const BorderRadius.all(Radius.circular(12)),
  );
}

/// Small bar above the composer showing the message being replied to.
class _ReplyPreview extends StatelessWidget {
  const _ReplyPreview({required this.message, required this.onCancel});

  final ChatMessage message;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final author = message.authorId == currentUserId
        ? 'Me'
        : mockContactById(message.authorId)?.name ?? '';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenEdge,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.reply,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.chatReply,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                Text(
                  '$author: ${message.text}',
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: l10n.close,
            onPressed: onCancel,
          ),
        ],
      ),
    );
  }
}
