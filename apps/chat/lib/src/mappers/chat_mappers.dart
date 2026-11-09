import 'package:flutter_chat_core/flutter_chat_core.dart' as core;

import '../data/mock_data.dart';
import '../models/chat.dart';

/// Maps the app's own [ChatMessage] to the `flutter_chat_ui` message types.
/// This is the only place that knows about the chat package's types.
extension ChatMessageMapper on ChatMessage {
  core.Message toCoreMessage() {
    final core.MessageStatus? status;
    if (authorId == currentUserId) {
      status = switch (this.status) {
        ChatMessageStatus.sent => core.MessageStatus.sent,
        ChatMessageStatus.delivered => core.MessageStatus.delivered,
        ChatMessageStatus.read => core.MessageStatus.seen,
      };
    } else {
      status = null;
    }

    if (imageUrl != null) {
      return core.Message.image(
        id: id,
        authorId: authorId,
        source: imageUrl!,
        text: text.isEmpty ? null : text,
        createdAt: createdAt,
        status: status,
        replyToMessageId: replyToId,
      );
    }
    return core.Message.text(
      id: id,
      authorId: authorId,
      text: text,
      createdAt: createdAt,
      status: status,
      replyToMessageId: replyToId,
    );
  }
}

/// Resolves a user id to a `flutter_chat_ui` [core.User] for avatars/names.
core.User? resolveChatUser(String userId) {
  if (userId == currentUserId) {
    return const core.User(id: currentUserId, name: 'Me');
  }
  final contact = mockContactById(userId);
  if (contact == null) return null;
  return core.User(id: contact.id, name: contact.name);
}
