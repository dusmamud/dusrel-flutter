import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/chat_repository.dart';
import '../data/mock_data.dart';
import '../models/chat.dart';

/// The repository behind every provider. Swap the implementation here
/// when a real backend arrives; screens never touch it directly.
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return MockChatRepository();
});

/// Chats list. Loads with a short delay so the skeleton state is real.
class ChatsNotifier extends AsyncNotifier<List<Chat>> {
  @override
  Future<List<Chat>> build() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return ref.read(chatRepositoryProvider).listChats();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(chatRepositoryProvider).listChats(),
    );
  }

  void _replace(Chat updated) {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data([
      for (final chat in current)
        if (chat.id == updated.id) updated else chat,
    ]);
  }

  Future<void> markRead(String chatId) async {
    await ref.read(chatRepositoryProvider).markRead(chatId);
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data([
      for (final chat in current)
        if (chat.id == chatId) chat.copyWith(unreadCount: 0) else chat,
    ]);
  }

  Future<void> toggleMute(String chatId, bool muted) async {
    await ref.read(chatRepositoryProvider).toggleMute(chatId, muted);
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data([
      for (final chat in current)
        if (chat.id == chatId) chat.copyWith(isMuted: muted) else chat,
    ]);
  }

  /// Updates the last-message preview after the user sends a message.
  void applyOutgoingMessage(String chatId, String text) {
    final repo = ref.read(chatRepositoryProvider);
    final chat = repo.chatByIdSync(chatId);
    if (chat != null) _replace(chat);
  }

  /// Updates the last-message preview after a simulated incoming message.
  void applyIncomingMessage(String chatId) {
    final repo = ref.read(chatRepositoryProvider);
    final chat = repo.chatByIdSync(chatId);
    if (chat != null) _replace(chat);
  }

  void addChat(Chat chat) {
    final current = state.value ?? const <Chat>[];
    if (current.any((c) => c.id == chat.id)) return;
    state = AsyncValue.data([chat, ...current]);
  }
}

final chatsProvider =
    AsyncNotifierProvider<ChatsNotifier, List<Chat>>(ChatsNotifier.new);

/// Current filter text for the chats list.
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
}

final chatSearchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

/// Name of the user currently typing in a chat, or null.
class TypingNotifier extends Notifier<String?> {
  TypingNotifier(this.chatId);

  final String chatId;

  @override
  String? build() => null;

  void set(String? value) => state = value;
}

final typingUserProvider =
    NotifierProvider.family<TypingNotifier, String?, String>(
  TypingNotifier.new,
);

/// Messages of one open conversation.
class ConversationNotifier extends Notifier<List<ChatMessage>> {
  ConversationNotifier(this.chatId);

  final String chatId;

  Timer? _typingTimer;
  Timer? _replyTimer;

  @override
  List<ChatMessage> build() {
    ref.onDispose(() {
      _typingTimer?.cancel();
      _replyTimer?.cancel();
    });
    return ref.read(chatRepositoryProvider).messagesForSync(chatId);
  }

  /// Sends a text message as the current user.
  Future<void> sendMessage(String text, {String? replyToId}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final message = ChatMessage(
      id: 'm-${DateTime.now().microsecondsSinceEpoch}',
      chatId: chatId,
      authorId: currentUserId,
      text: trimmed,
      createdAt: DateTime.now(),
      status: ChatMessageStatus.sent,
      replyToId: replyToId,
    );
    await ref.read(chatRepositoryProvider).sendMessage(message);
    state = [...state, message];
    ref.read(chatsProvider.notifier).applyOutgoingMessage(chatId, trimmed);
    _maybeSimulateGroupReply();
  }

  /// Deletes a message from the conversation.
  Future<void> deleteMessage(String messageId) async {
    await ref.read(chatRepositoryProvider).deleteMessage(chatId, messageId);
    state = [
      for (final message in state)
        if (message.id != messageId) message,
    ];
  }

  /// In the Flutter Devs group, the other side answers after a short
  /// typing pause, so the typing indicator is visible in the mock.
  void _maybeSimulateGroupReply() {
    if (chatId != 'chat-flutter-devs') return;
    final chat = ref.read(chatRepositoryProvider).chatByIdSync(chatId);
    if (chat == null || !chat.isGroup) return;
    _typingTimer = Timer(const Duration(seconds: 1), () {
      ref.read(typingUserProvider(chatId).notifier).set('Aarav Sharma');
    });
    _replyTimer = Timer(const Duration(seconds: 3), () async {
      ref.read(typingUserProvider(chatId).notifier).set(null);
      final reply = ChatMessage(
        id: 'm-${DateTime.now().microsecondsSinceEpoch}',
        chatId: chatId,
        authorId: mockGroupReplyAuthorId,
        text: mockGroupReplyText,
        createdAt: DateTime.now(),
        status: ChatMessageStatus.read,
      );
      await ref.read(chatRepositoryProvider).sendMessage(reply);
      state = [...state, reply];
      ref.read(chatsProvider.notifier).applyIncomingMessage(chatId);
    });
  }
}

final conversationProvider = NotifierProvider.family<
    ConversationNotifier, List<ChatMessage>, String>(
  ConversationNotifier.new,
);

/// Local-only notifications toggle (settings screen).
class NotificationsNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void set(bool value) => state = value;
}

final notificationsEnabledProvider =
    NotifierProvider<NotificationsNotifier, bool>(NotificationsNotifier.new);
