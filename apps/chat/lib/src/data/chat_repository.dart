import '../models/chat.dart';
import 'mock_data.dart';

/// Data source for chats. The UI only talks to this abstraction, so a real
/// backend can replace [MockChatRepository] later without touching screens.
abstract class ChatRepository {
  Future<List<Chat>> listChats();
  List<Chat> listChatsSync();
  Chat? chatByIdSync(String chatId);
  Future<List<ChatMessage>> messagesFor(String chatId);
  List<ChatMessage> messagesForSync(String chatId);
  Future<List<Contact>> listContacts();
  List<Contact> listContactsSync();
  Future<void> sendMessage(ChatMessage message);
  Future<void> markRead(String chatId);
  Future<void> toggleMute(String chatId, bool muted);
  Future<void> deleteMessage(String chatId, String messageId);

  /// Returns an existing 1:1 chat for [participantId], or creates one.
  Future<Chat> openOrCreateChat(String participantId);
  List<MessageSearchResult> searchAllMessages(String query);
}

/// In-memory mock implementation with realistic local data.
class MockChatRepository implements ChatRepository {
  MockChatRepository()
      : _chats = buildMockChats(),
        _messages = buildMockMessages();

  final List<Chat> _chats;
  final Map<String, List<ChatMessage>> _messages;

  @override
  Future<List<Chat>> listChats() async => List.unmodifiable(_chats);

  @override
  List<Chat> listChatsSync() => List.unmodifiable(_chats);

  @override
  Chat? chatByIdSync(String chatId) {
    for (final chat in _chats) {
      if (chat.id == chatId) return chat;
    }
    return null;
  }

  @override
  Future<List<ChatMessage>> messagesFor(String chatId) async =>
      messagesForSync(chatId);

  @override
  List<ChatMessage> messagesForSync(String chatId) {
    return List.unmodifiable(_messages[chatId] ?? const <ChatMessage>[]);
  }

  @override
  Future<List<Contact>> listContacts() async => listContactsSync();

  @override
  List<Contact> listContactsSync() => List.unmodifiable(mockContacts);

  @override
  Future<void> sendMessage(ChatMessage message) async {
    final list = _messages.putIfAbsent(message.chatId, () => []);
    list.add(message);
    // The preview is the message text itself. An image-only message
    // leaves the preview empty — there is no l10n key for a "Photo"
    // label yet, and no English string may be hardcoded here.
    _updateChat(
      message.chatId,
      lastMessageText: message.text,
      lastMessageAt: message.createdAt,
    );
  }

  @override
  Future<void> markRead(String chatId) async {
    _updateChat(chatId, unreadCount: 0);
  }

  @override
  Future<void> toggleMute(String chatId, bool muted) async {
    _updateChat(chatId, isMuted: muted);
  }

  @override
  Future<void> deleteMessage(String chatId, String messageId) async {
    _messages[chatId]?.removeWhere((m) => m.id == messageId);
  }

  @override
  Future<Chat> openOrCreateChat(String participantId) async {
    for (final chat in _chats) {
      if (!chat.isGroup &&
          chat.participantIds.contains(participantId) &&
          chat.participantIds.contains(currentUserId)) {
        return chat;
      }
    }
    final contact = mockContactById(participantId);
    final chat = Chat(
      id: 'chat-$participantId',
      name: contact?.name ?? participantId,
      isGroup: false,
      participantIds: [currentUserId, participantId],
      lastMessageText: '',
      lastMessageAt: DateTime.now(),
      isOnline: contact?.isOnline ?? false,
    );
    _chats.insert(0, chat);
    _messages[chat.id] = [];
    return chat;
  }

  @override
  List<MessageSearchResult> searchAllMessages(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return const [];
    final results = <MessageSearchResult>[];
    for (final chat in _chats) {
      for (final message in _messages[chat.id] ?? const <ChatMessage>[]) {
        if (message.text.toLowerCase().contains(needle)) {
          results.add(MessageSearchResult(chat: chat, message: message));
        }
      }
    }
    return results;
  }

  void _updateChat(
    String chatId, {
    String? lastMessageText,
    DateTime? lastMessageAt,
    int? unreadCount,
    bool? isMuted,
  }) {
    final index = _chats.indexWhere((c) => c.id == chatId);
    if (index == -1) return;
    _chats[index] = _chats[index].copyWith(
      lastMessageText: lastMessageText,
      lastMessageAt: lastMessageAt,
      unreadCount: unreadCount,
      isMuted: isMuted,
    );
  }
}
