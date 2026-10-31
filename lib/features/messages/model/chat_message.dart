import 'package:equatable/equatable.dart';

enum ChatMessageKind { day, inbound, outbound }

extension ChatMessageKindX on ChatMessageKind {
  static ChatMessageKind fromJson(String? raw) => switch (raw) {
    'day' => .day,
    'in' || 'inbound' => .inbound,
    'out' || 'outbound' || _ => .outbound,
  };

  String get apiValue => switch (this) {
    .day => 'day',
    .inbound => 'inbound',
    .outbound => 'outbound',
  };
}

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.kind,
    required this.text,
    this.timeLabel = '',
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      kind: ChatMessageKindX.fromJson(
        json['kind'] as String? ?? json['k'] as String?,
      ),
      text: json['text'] as String? ?? json['body'] as String? ?? '',
      timeLabel: json['time_label'] as String? ?? json['time'] as String? ?? '',
    );
  }

  final String id;
  final ChatMessageKind kind;
  final String text;
  final String timeLabel;

  bool get isDay => kind == .day;
  bool get isInbound => kind == .inbound;
  bool get isOutbound => kind == .outbound;

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind.apiValue,
    'text': text,
    'time_label': timeLabel,
  };

  @override
  List<Object?> get props => [id, kind, text, timeLabel];
}
