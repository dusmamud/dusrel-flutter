import '../models/chat.dart';

/// The id of the signed-in user in all mock data.
const String currentUserId = 'me';

/// Contacts used by the mock repository.
const List<Contact> mockContacts = [
  Contact(id: 'aarav', name: 'Aarav Sharma', isOnline: true),
  Contact(id: 'priya', name: 'Priya Patel', isOnline: true),
  Contact(id: 'rohan', name: 'Rohan Verma'),
  Contact(id: 'ananya', name: 'Ananya Iyer'),
  Contact(id: 'vikram', name: 'Vikram Singh', isOnline: true),
  Contact(id: 'neha', name: 'Neha Gupta', isOnline: true),
  Contact(id: 'arjun', name: 'Arjun Mehta'),
  Contact(id: 'kavya', name: 'Kavya Nair'),
  Contact(id: 'sana', name: 'Sana Khan'),
];

Contact? mockContactById(String id) {
  for (final contact in mockContacts) {
    if (contact.id == id) return contact;
  }
  return null;
}

DateTime _ago({int days = 0, int hours = 0, int minutes = 0}) =>
    DateTime.now().subtract(
      Duration(days: days, hours: hours, minutes: minutes),
    );

ChatMessage _m(
  String id,
  String chatId,
  String authorId,
  String text, {
  required DateTime at,
  String? imageUrl,
  ChatMessageStatus status = ChatMessageStatus.sent,
  String? replyToId,
}) {
  return ChatMessage(
    id: id,
    chatId: chatId,
    authorId: authorId,
    text: text,
    createdAt: at,
    imageUrl: imageUrl,
    status: status,
    replyToId: replyToId,
  );
}

/// Mock chats, ordered by most recent activity.
List<Chat> buildMockChats() {
  return [
    Chat(
      id: 'chat-aarav',
      name: 'Aarav Sharma',
      isGroup: false,
      participantIds: const [currentUserId, 'aarav'],
      lastMessageText: 'Sounds good, see you at 6!',
      lastMessageAt: _ago(minutes: 12),
      unreadCount: 2,
      isOnline: true,
    ),
    Chat(
      id: 'chat-flutter-devs',
      name: 'Flutter Devs',
      isGroup: true,
      participantIds: const [
        currentUserId,
        'aarav',
        'priya',
        'rohan',
        'vikram',
      ],
      lastMessageText: 'Priya: The new ui_kit tokens look clean',
      lastMessageAt: _ago(minutes: 35),
      unreadCount: 5,
    ),
    Chat(
      id: 'chat-priya',
      name: 'Priya Patel',
      isGroup: false,
      participantIds: const [currentUserId, 'priya'],
      lastMessageText: 'Sent the designs, check Drive',
      lastMessageAt: _ago(hours: 2),
      isOnline: true,
    ),
    Chat(
      id: 'chat-family',
      name: 'Family Group',
      isGroup: true,
      participantIds: const [
        currentUserId,
        'neha',
        'arjun',
        'kavya',
      ],
      lastMessageText: "Neha: Dinner at 8, don't be late",
      lastMessageAt: _ago(hours: 5),
      isMuted: true,
    ),
    Chat(
      id: 'chat-rohan',
      name: 'Rohan Verma',
      isGroup: false,
      participantIds: const [currentUserId, 'rohan'],
      lastMessageText: "Let's sync tomorrow morning",
      lastMessageAt: _ago(days: 1, hours: 3),
    ),
    Chat(
      id: 'chat-ananya',
      name: 'Ananya Iyer',
      isGroup: false,
      participantIds: const [currentUserId, 'ananya'],
      lastMessageText: 'Did you see the new Flutter release?',
      lastMessageAt: _ago(days: 1, hours: 6),
      unreadCount: 1,
    ),
    Chat(
      id: 'chat-vikram',
      name: 'Vikram Singh',
      isGroup: false,
      participantIds: const [currentUserId, 'vikram'],
      lastMessageText: 'Thanks for the help!',
      lastMessageAt: _ago(days: 2, hours: 4),
      isOnline: true,
    ),
  ];
}

/// Mock message history per chat, oldest first.
Map<String, List<ChatMessage>> buildMockMessages() {
  return {
    'chat-aarav': [
      _m('a1', 'chat-aarav', 'aarav', 'Hey! Did you finish the chat UI?',
          at: _ago(days: 1, hours: 2), status: ChatMessageStatus.read),
      _m('a2', 'chat-aarav', currentUserId, 'Almost done, just polishing the thread screen.',
          at: _ago(days: 1, hours: 2, minutes: -5),
          status: ChatMessageStatus.read),
      _m('a3', 'chat-aarav', 'aarav', 'Nice. Did you wire up the Riverpod providers?',
          at: _ago(days: 1, hours: 1), status: ChatMessageStatus.read),
      _m('a4', 'chat-aarav', currentUserId, 'Yes, chats list and conversation both use Notifiers now.',
          at: _ago(days: 1, hours: 1, minutes: -3),
          status: ChatMessageStatus.read),
      _m('a5', 'chat-aarav', currentUserId,
          'The mock repository makes local testing really fast.',
          at: _ago(days: 1, minutes: -50), status: ChatMessageStatus.read),
      _m('a6', 'chat-aarav', 'aarav', 'Agreed. Can you review my PR when you get a chance?',
          at: _ago(hours: 3), status: ChatMessageStatus.read),
      _m('a7', 'chat-aarav', currentUserId, 'Sure, I will look at it after lunch.',
          at: _ago(hours: 3, minutes: -10), status: ChatMessageStatus.read),
      _m('a8', 'chat-aarav', 'aarav', 'Thanks! It is the one about the message bubbles.',
          at: _ago(hours: 2, minutes: 40), status: ChatMessageStatus.read),
      _m('a9', 'chat-aarav', 'aarav', 'Also, are we still on for the call this evening?',
          at: _ago(minutes: 25), status: ChatMessageStatus.read),
      _m('a10', 'chat-aarav', currentUserId, 'Yes, 6 works for me.',
          at: _ago(minutes: 20), status: ChatMessageStatus.read, replyToId: 'a9'),
      _m('a11', 'chat-aarav', 'aarav', 'Perfect, I will send the meeting link.',
          at: _ago(minutes: 15), status: ChatMessageStatus.read),
      _m('a12', 'chat-aarav', 'aarav', 'Sounds good, see you at 6!',
          at: _ago(minutes: 12), status: ChatMessageStatus.read),
    ],
    'chat-flutter-devs': [
      _m('d1', 'chat-flutter-devs', 'vikram', 'Morning everyone! Flutter 3.47 is out.',
          at: _ago(days: 1, hours: 5), status: ChatMessageStatus.read),
      _m('d2', 'chat-flutter-devs', 'rohan', 'Already updated. The new Material 3 defaults are nice.',
          at: _ago(days: 1, hours: 5, minutes: -8), status: ChatMessageStatus.read),
      _m('d3', 'chat-flutter-devs', currentUserId,
          'Has anyone tried the new flutter_chat_ui 2.x yet?',
          at: _ago(days: 1, hours: 4), status: ChatMessageStatus.read),
      _m('d4', 'chat-flutter-devs', 'priya', 'Yes! The controller API changed a lot, but it is cleaner.',
          at: _ago(days: 1, hours: 4, minutes: -6), status: ChatMessageStatus.read),
      _m('d5', 'chat-flutter-devs', 'aarav', 'InMemoryChatController is handy for local testing.',
          at: _ago(days: 1, hours: 3, minutes: 30), status: ChatMessageStatus.read),
      _m('d6', 'chat-flutter-devs', 'priya', 'Sharing the new home screen mock.',
          at: _ago(hours: 6),
          imageUrl: 'https://picsum.photos/seed/dusrel-devs-1/800/600',
          status: ChatMessageStatus.read),
      _m('d7', 'chat-flutter-devs', 'vikram', 'That layout looks really clean.',
          at: _ago(hours: 6, minutes: -4), status: ChatMessageStatus.read),
      _m('d8', 'chat-flutter-devs', 'rohan', 'The spacing tokens make a big difference.',
          at: _ago(hours: 5, minutes: 40), status: ChatMessageStatus.read),
      _m('d9', 'chat-flutter-devs', currentUserId,
          'Agreed. ui_kit keeps all four apps consistent.',
          at: _ago(hours: 5, minutes: -12), status: ChatMessageStatus.read),
      _m('d10', 'chat-flutter-devs', 'priya', 'I pushed the theme tokens to the repo.',
          at: _ago(hours: 2), status: ChatMessageStatus.read),
      _m('d11', 'chat-flutter-devs', 'aarav', 'Reviewed. Just one nit about the radius values.',
          at: _ago(hours: 1, minutes: 50), status: ChatMessageStatus.read),
      _m('d12', 'chat-flutter-devs', 'vikram', 'Fixed and pushed.',
          at: _ago(hours: 1, minutes: 30), status: ChatMessageStatus.read),
      _m('d13', 'chat-flutter-devs', 'rohan', 'Great, let us merge it today.',
          at: _ago(minutes: 50), status: ChatMessageStatus.read),
      _m('d14', 'chat-flutter-devs', 'priya', 'The new ui_kit tokens look clean',
          at: _ago(minutes: 35), status: ChatMessageStatus.read),
    ],
    'chat-priya': [
      _m('p1', 'chat-priya', 'priya', 'Hi! I finished the onboarding screens.',
          at: _ago(days: 2, hours: 1), status: ChatMessageStatus.read),
      _m('p2', 'chat-priya', currentUserId, 'Awesome, can you share a screenshot?',
          at: _ago(days: 1, hours: 23, minutes: 55),
          status: ChatMessageStatus.read),
      _m('p3', 'chat-priya', 'priya', 'Here is the main flow.',
          at: _ago(days: 1, hours: 23, minutes: 50),
          imageUrl: 'https://picsum.photos/seed/dusrel-priya-1/800/600',
          status: ChatMessageStatus.read),
      _m('p4', 'chat-priya', currentUserId, 'This looks great. The empty states are really clear.',
          at: _ago(days: 1, hours: 23, minutes: 40), status: ChatMessageStatus.read),
      _m('p5', 'chat-priya', 'priya', 'Thanks! I followed the design-system skill notes.',
          at: _ago(days: 1, hours: 8), status: ChatMessageStatus.read),
      _m('p6', 'chat-priya', currentUserId, 'One small thing: the search bar radius.',
          at: _ago(days: 1, hours: 7, minutes: 30), status: ChatMessageStatus.read),
      _m('p7', 'chat-priya', 'priya', 'Good catch, I will fix it.',
          at: _ago(days: 1, hours: 7), status: ChatMessageStatus.read),
      _m('p8', 'chat-priya', currentUserId, 'Also, the dark theme contrast looks good now.',
          at: _ago(hours: 4), status: ChatMessageStatus.read),
      _m('p9', 'chat-priya', 'priya', 'Sent the designs, check Drive',
          at: _ago(hours: 2), status: ChatMessageStatus.read),
    ],
    'chat-family': [
      _m('f1', 'chat-family', 'neha', 'Good morning everyone!',
          at: _ago(days: 1, hours: 6), status: ChatMessageStatus.read),
      _m('f2', 'chat-family', 'arjun', 'Morning! What is the plan for the weekend?',
          at: _ago(days: 1, hours: 5, minutes: 40), status: ChatMessageStatus.read),
      _m('f3', 'chat-family', 'kavya', 'Can we visit the park on Sunday?',
          at: _ago(days: 1, hours: 5), status: ChatMessageStatus.read),
      _m('f4', 'chat-family', currentUserId, 'Sunday works for me.',
          at: _ago(days: 1, hours: 4, minutes: 30), status: ChatMessageStatus.read),
      _m('f5', 'chat-family', 'neha', 'Great, I will pack lunch.',
          at: _ago(days: 1, hours: 4), status: ChatMessageStatus.read),
      _m('f6', 'chat-family', 'arjun', 'I will bring the cricket kit.',
          at: _ago(hours: 8), status: ChatMessageStatus.read),
      _m('f7', 'chat-family', 'kavya', 'Yay!',
          at: _ago(hours: 7, minutes: 45), status: ChatMessageStatus.read),
      _m('f8', 'chat-family', 'neha', "Dinner at 8, don't be late",
          at: _ago(hours: 5), status: ChatMessageStatus.read),
    ],
    'chat-rohan': [
      _m('r1', 'chat-rohan', 'rohan', 'Hey, did you check the Melos setup?',
          at: _ago(days: 2, hours: 2), status: ChatMessageStatus.read),
      _m('r2', 'chat-rohan', currentUserId, 'Yes, bootstrap worked on the first try.',
          at: _ago(days: 2, hours: 1, minutes: 45), status: ChatMessageStatus.read),
      _m('r3', 'chat-rohan', 'rohan', 'Nice. The workspace layout is much cleaner now.',
          at: _ago(days: 2, hours: 1), status: ChatMessageStatus.read),
      _m('r4', 'chat-rohan', currentUserId, 'Agreed, shared packages are easy to find.',
          at: _ago(days: 1, hours: 9), status: ChatMessageStatus.read),
      _m('r5', 'chat-rohan', 'rohan', 'Let me know when the calendar app starts.',
          at: _ago(days: 1, hours: 8, minutes: 30), status: ChatMessageStatus.read),
      _m('r6', 'chat-rohan', currentUserId, 'Will do. Chat comes first.',
          at: _ago(days: 1, hours: 8), status: ChatMessageStatus.read),
      _m('r7', 'chat-rohan', 'rohan', "Let's sync tomorrow morning",
          at: _ago(days: 1, hours: 3), status: ChatMessageStatus.read),
    ],
    'chat-ananya': [
      _m('n1', 'chat-ananya', 'ananya', 'Hi! Long time.',
          at: _ago(days: 3), status: ChatMessageStatus.read),
      _m('n2', 'chat-ananya', currentUserId, 'Hey Ananya! How have you been?',
          at: _ago(days: 3, minutes: -20), status: ChatMessageStatus.read),
      _m('n3', 'chat-ananya', 'ananya', 'Good! Working on a new notes app.',
          at: _ago(days: 2, hours: 10), status: ChatMessageStatus.read),
      _m('n4', 'chat-ananya', currentUserId, 'Interesting, we are building one too.',
          at: _ago(days: 2, hours: 9, minutes: 30), status: ChatMessageStatus.read),
      _m('n5', 'chat-ananya', 'ananya', 'We should compare notes sometime.',
          at: _ago(days: 2, hours: 9), status: ChatMessageStatus.read),
      _m('n6', 'chat-ananya', currentUserId, 'Definitely, let us plan a call.',
          at: _ago(days: 1, hours: 10), status: ChatMessageStatus.read),
      _m('n7', 'chat-ananya', 'ananya', 'Did you see the new Flutter release?',
          at: _ago(days: 1, hours: 6), status: ChatMessageStatus.read),
    ],
    'chat-vikram': [
      _m('v1', 'chat-vikram', 'vikram', 'Thanks for the Riverpod help yesterday.',
          at: _ago(days: 3, hours: 2), status: ChatMessageStatus.read),
      _m('v2', 'chat-vikram', currentUserId, 'Anytime! The provider docs are good.',
          at: _ago(days: 3, hours: 1, minutes: 40), status: ChatMessageStatus.read),
      _m('v3', 'chat-vikram', 'vikram', 'The codegen approach is much cleaner.',
          at: _ago(days: 3, hours: 1), status: ChatMessageStatus.read),
      _m('v4', 'chat-vikram', currentUserId, 'Yes, way less boilerplate than before.',
          at: _ago(days: 2, hours: 6), status: ChatMessageStatus.read),
      _m('v5', 'chat-vikram', 'vikram', 'I refactored the settings screen with it.',
          at: _ago(days: 2, hours: 5, minutes: 30), status: ChatMessageStatus.read),
      _m('v6', 'chat-vikram', currentUserId, 'Nice, send me the diff when ready.',
          at: _ago(days: 2, hours: 5), status: ChatMessageStatus.read),
      _m('v7', 'chat-vikram', 'vikram', 'Thanks for the help!',
          at: _ago(days: 2, hours: 4), status: ChatMessageStatus.read),
    ],
  };
}

/// Placeholder media thumbnails for group/contact info screens.
List<String> buildMockMediaUrls() {
  return [
    for (var i = 1; i <= 6; i++)
      'https://picsum.photos/seed/dusrel-media-$i/400/400',
  ];
}

/// Canned reply used to simulate the other side typing in the group chat.
const String mockGroupReplyAuthorId = 'aarav';
const String mockGroupReplyText =
    'Haha, exactly! Let us ship it this week.';
