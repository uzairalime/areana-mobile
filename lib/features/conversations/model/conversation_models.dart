import 'package:equatable/equatable.dart';

import '../../../core/utils/json_parsing.dart';

String _str(dynamic value) => value?.toString() ?? '';

enum ConversationInboxFilter { all, unread }

extension ConversationInboxFilterX on ConversationInboxFilter {
  String get label => switch (this) {
    .all => 'All',
    .unread => 'Unread',
  };
}

class ConversationBookingChip extends Equatable {
  const ConversationBookingChip({
    required this.id,
    required this.courtName,
    required this.date,
    required this.startMinutes,
  });

  factory ConversationBookingChip.fromJson(Map<String, dynamic> json) {
    return ConversationBookingChip(
      id: _str(json['id']),
      courtName: _str(json['courtName']),
      date: _str(json['date']),
      startMinutes: JsonParsing.intValue(json['startMinutes']),
    );
  }

  final String id;
  final String courtName;
  final String date;
  final int startMinutes;

  String get chipLabel {
    final time = _fmtTime(startMinutes);
    final day = _fmtDay(date);
    final court = courtName.trim();
    final parts = <String>[
      if (court.isNotEmpty) court,
      if (day.isNotEmpty && time.isNotEmpty) '$day, $time' else day + time,
    ];
    return parts.where((part) => part.trim().isNotEmpty).join(' · ');
  }

  @override
  List<Object?> get props => [id, courtName, date, startMinutes];
}

class ConversationThread extends Equatable {
  const ConversationThread({
    required this.id,
    required this.venueId,
    required this.venueName,
    required this.title,
    this.venuePhone = '',
    this.playerId = '',
    this.playerName = '',
    this.lastPreview = '',
    this.lastMessageAt,
    this.unreadCount = 0,
    this.lastBooking,
  });

  factory ConversationThread.fromJson(Map<String, dynamic> json) {
    final booking = json['lastBooking'];
    return ConversationThread(
      id: _str(json['id']),
      venueId: _str(json['venueId']),
      venueName: _str(json['venueName']),
      venuePhone: _str(json['venuePhone']),
      playerId: _str(json['playerId']),
      playerName: _str(json['playerName']),
      title: _str(json['title']).isEmpty
          ? _str(json['venueName'])
          : _str(json['title']),
      lastPreview: _str(json['lastPreview']),
      lastMessageAt: DateTime.tryParse(_str(json['lastMessageAt'])),
      unreadCount: JsonParsing.intValue(json['unreadCount']),
      lastBooking: booking is Map
          ? ConversationBookingChip.fromJson(Map<String, dynamic>.from(booking))
          : null,
    );
  }

  final String id;
  final String venueId;
  final String venueName;
  final String venuePhone;
  final String playerId;
  final String playerName;
  final String title;
  final String lastPreview;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final ConversationBookingChip? lastBooking;

  bool get hasUnread => unreadCount > 0;

  String compactAgo(DateTime now) {
    final at = lastMessageAt;
    if (at == null) return '';
    final delta = now.difference(at);
    if (delta.inMinutes < 1) return 'now';
    if (delta.inMinutes < 60) return '${delta.inMinutes} min';
    if (delta.inHours < 24) return '${delta.inHours}h';
    return '${delta.inDays}d';
  }

  ConversationThread copyWith({int? unreadCount}) {
    return ConversationThread(
      id: id,
      venueId: venueId,
      venueName: venueName,
      venuePhone: venuePhone,
      playerId: playerId,
      playerName: playerName,
      title: title,
      lastPreview: lastPreview,
      lastMessageAt: lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      lastBooking: lastBooking,
    );
  }

  @override
  List<Object?> get props => [id, lastPreview, unreadCount, lastMessageAt];
}

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.body,
    required this.createdAt,
    required this.mine,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: _str(json['id']),
      senderId: _str(json['senderId']),
      body: _str(json['body']),
      createdAt: DateTime.tryParse(_str(json['createdAt'])) ?? DateTime.now(),
      mine: json['mine'] == true,
    );
  }

  final String id;
  final String senderId;
  final String body;
  final DateTime createdAt;
  final bool mine;

  String get timeLabel => _fmtTime(
    createdAt.hour * 60 + createdAt.minute,
  );

  @override
  List<Object?> get props => [id, body, mine];
}

const conversationQuickReplies = [
  'Is parking available?',
  'Can I change my slot?',
  'What should I bring?',
];

String _fmtTime(int minutes) {
  final wrapped = ((minutes % 1440) + 1440) % 1440;
  final hour24 = wrapped ~/ 60;
  final mins = wrapped % 60;
  final period = hour24 >= 12 ? 'PM' : 'AM';
  final hour = hour24 % 12 == 0 ? 12 : hour24 % 12;
  return '$hour:${mins.toString().padLeft(2, '0')} $period';
}

String _fmtDay(String isoDate) {
  final parts = isoDate.split('-');
  final parsed = parts.length == 3
      ? DateTime(
          int.tryParse(parts[0]) ?? 0,
          int.tryParse(parts[1]) ?? 1,
          int.tryParse(parts[2]) ?? 1,
        )
      : DateTime.tryParse(isoDate);
  if (parsed == null || parsed.year == 0) return isoDate;
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${weekdays[parsed.weekday - 1]} ${parsed.day} ${months[parsed.month - 1]}';
}
