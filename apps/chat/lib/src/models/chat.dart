/// Chat domain models for the DusRel Chat app.
///
/// These models are intentionally free of any chat-UI package types.
/// Mapping to `flutter_chat_ui` types happens at the screen boundary only
/// (see `lib/src/mappers/chat_mappers.dart`).
library;

/// Delivery/read state of a message sent by the current user.
enum ChatMessageStatus { sent, delivered, read }

/// A 1:1 or group conversation.
class Chat {
  const Chat({
    required this.id,
    required this.name,
    required this.isGroup,
    required this.participantIds,
    required this.lastMessageText,
    required this.lastMessageAt,
    this.unreadCount = 0,
    this.isMuted = false,
    this.isOnline = false,
  });

  final String id;
  final String name;
  final bool isGroup;
  final List<String> participantIds;
  final String lastMessageText;
  final DateTime lastMessageAt;
  final int unreadCount;
  final bool isMuted;
  final bool isOnline;

  Chat copyWith({
    String? lastMessageText,
    DateTime? lastMessageAt,
    int? unreadCount,
    bool? isMuted,
  }) {
    return Chat(
      id: id,
      name: name,
      isGroup: isGroup,
      participantIds: participantIds,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      isMuted: isMuted ?? this.isMuted,
      isOnline: isOnline,
    );
  }
}

/// One message inside a [Chat].
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.authorId,
    required this.text,
    required this.createdAt,
    this.imageUrl,
    this.status = ChatMessageStatus.sent,
    this.replyToId,
  });

  final String id;
  final String chatId;
  final String authorId;

  /// Text body. May be empty when the message is image-only.
  final String text;
  final DateTime createdAt;

  /// Remote image URL for image messages; null for text messages.
  final String? imageUrl;

  /// Meaningful only for messages sent by the current user.
  final ChatMessageStatus status;

  /// Id of the message this one replies to, if any.
  final String? replyToId;
}

/// A person the user can start a chat with.
class Contact {
  const Contact({
    required this.id,
    required this.name,
    this.isOnline = false,
  });

  final String id;
  final String name;
  final bool isOnline;
}

/// One hit when searching messages across all chats.
class MessageSearchResult {
  const MessageSearchResult({required this.chat, required this.message});

  final Chat chat;
  final ChatMessage message;
}
