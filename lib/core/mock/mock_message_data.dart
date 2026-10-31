import '../../features/messages/model/chat_message.dart';
import '../../features/messages/model/chat_thread.dart';
import '../consts/app_colors.dart';

class MockMessageData {
  MockMessageData._();

  static final List<ChatThread> _threads = [
    ChatThread(
      id: 'arena-one',
      name: 'Arena One Padel Club',
      initials: 'AO',
      preview: 'Yes, free parking at the back of the club.',
      timeLabel: '2 min',
      unreadCount: 2,
      avatarBg: AppColors.padelSoft,
      avatarFg: AppColors.padel,
      subtitle: 'Usually replies within an hour',
      contextLabel: 'Court 2 · Wed 28 Oct, 7:00 PM',
      quickReplies: const [
        'Is parking available?',
        'Can I change my slot?',
        'Are rackets available?',
      ],
    ),
    ChatThread(
      id: 'support',
      name: 'Pitchside Support',
      initials: 'PS',
      preview: 'Open Bookings, pick your slot and tap Reschedule.',
      timeLabel: '1 h',
      unreadCount: 1,
      kind: .support,
      avatarBg: AppColors.primary,
      avatarFg: AppColors.accent,
      subtitle: 'Typically replies in a few minutes',
      quickReplies: const [
        'Cancel a booking',
        'Paying at the ground',
        'Report an issue',
      ],
    ),
    const ChatThread(
      id: 'goal-zone',
      name: 'Goal Zone Turf',
      initials: 'GZ',
      preview: 'Yes, the floodlights stay on until 11 PM.',
      timeLabel: 'Yesterday',
      avatarBg: AppColors.footballSoft,
      avatarFg: AppColors.football,
      subtitle: 'Usually replies within an hour',
      contextLabel: '5-a-side · Clifton',
      quickReplies: [
        'Is there a changing room?',
        'Do you provide bibs?',
        'Can I bring a friend?',
      ],
    ),
    const ChatThread(
      id: 'strike',
      name: 'Strike Indoor Cricket Arena',
      initials: 'SI',
      preview: 'Done. Your slot is moved to 9:00 PM.',
      timeLabel: 'Mon',
      avatarBg: AppColors.cricketSoft,
      avatarFg: AppColors.cricket,
      subtitle: 'Usually replies within an hour',
      contextLabel: 'Net lane · Gulshan-e-Iqbal',
      quickReplies: [
        'Is the cafe open?',
        'Do you have bats?',
        'Can I add a player?',
      ],
    ),
  ];

  static final Map<String, List<ChatMessage>> _messages = {
    'arena-one': const [
      ChatMessage(id: 'a0', kind: .day, text: 'Today'),
      ChatMessage(
        id: 'a1',
        kind: .outbound,
        text: 'Hi, is Court 2 confirmed for tonight at 7?',
        timeLabel: '6:40 PM',
      ),
      ChatMessage(
        id: 'a2',
        kind: .inbound,
        text: 'Hi Ahmed! Yes, Court 2 is confirmed for 7:00 to 8:00 PM.',
        timeLabel: '6:42 PM',
      ),
      ChatMessage(
        id: 'a3',
        kind: .inbound,
        text:
            'Rackets are available at the front desk. You can pay when you arrive.',
        timeLabel: '6:43 PM',
      ),
      ChatMessage(
        id: 'a4',
        kind: .outbound,
        text: 'Great, do you have parking?',
        timeLabel: '6:45 PM',
      ),
      ChatMessage(
        id: 'a5',
        kind: .inbound,
        text: 'Yes, free parking at the back of the club.',
        timeLabel: '6:46 PM',
      ),
    ],
    'support': const [
      ChatMessage(id: 's0', kind: .day, text: 'Today'),
      ChatMessage(
        id: 's1',
        kind: .inbound,
        text: 'Hi Ahmed, welcome to Pitchside support. How can we help?',
        timeLabel: '5:30 PM',
      ),
      ChatMessage(
        id: 's2',
        kind: .outbound,
        text: 'How do I change my booking time?',
        timeLabel: '5:32 PM',
      ),
      ChatMessage(
        id: 's3',
        kind: .inbound,
        text:
            'Open Bookings, pick your slot and tap Reschedule. Need a hand? Just ask here.',
        timeLabel: '5:33 PM',
      ),
    ],
    'goal-zone': const [
      ChatMessage(id: 'g0', kind: .day, text: 'Yesterday'),
      ChatMessage(
        id: 'g1',
        kind: .outbound,
        text: 'Are the floodlights on in the evening?',
        timeLabel: '4:10 PM',
      ),
      ChatMessage(
        id: 'g2',
        kind: .inbound,
        text: 'Yes, the floodlights stay on until 11 PM.',
        timeLabel: '4:25 PM',
      ),
    ],
    'strike': const [
      ChatMessage(id: 't0', kind: .day, text: 'Mon 26 Oct'),
      ChatMessage(
        id: 't1',
        kind: .outbound,
        text: 'Can we move our slot to 9 PM?',
        timeLabel: '2:05 PM',
      ),
      ChatMessage(
        id: 't2',
        kind: .inbound,
        text: 'Done. Your slot is moved to 9:00 PM. Thanks!',
        timeLabel: '2:20 PM',
      ),
    ],
  };

  static List<ChatThread> get threads =>
      List<ChatThread>.unmodifiable(_threads);

  static ChatThread? threadById(String id) {
    for (final thread in _threads) {
      if (thread.id == id) return thread;
    }
    return null;
  }

  static List<ChatMessage> messagesFor(String threadId) {
    final list = _messages[threadId];
    if (list == null) return const [];
    return List<ChatMessage>.unmodifiable(list);
  }

  static ChatMessage send(String threadId, String text) {
    final message = ChatMessage(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      kind: .outbound,
      text: text.trim(),
      timeLabel: 'Now',
    );
    final existing = _messages[threadId] ?? const <ChatMessage>[];
    _messages[threadId] = [...existing, message];

    final index = _threads.indexWhere((e) => e.id == threadId);
    if (index >= 0) {
      _threads[index] = _threads[index].copyWith(
        preview: message.text,
        timeLabel: 'Now',
        unreadCount: 0,
      );
    }
    return message;
  }

  static void markThreadRead(String threadId) {
    final index = _threads.indexWhere((e) => e.id == threadId);
    if (index < 0 || !_threads[index].hasUnread) return;
    _threads[index] = _threads[index].copyWith(unreadCount: 0);
  }
}
