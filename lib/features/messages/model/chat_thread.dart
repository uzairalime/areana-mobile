import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';

enum ChatThreadKind { venue, support }

extension ChatThreadKindX on ChatThreadKind {
  static ChatThreadKind fromJson(String? raw) => switch (raw) {
    'support' => .support,
    _ => .venue,
  };

  String get apiValue => switch (this) {
    .venue => 'venue',
    .support => 'support',
  };
}

class ChatThread extends Equatable {
  const ChatThread({
    required this.id,
    required this.name,
    required this.initials,
    required this.preview,
    required this.timeLabel,
    required this.avatarBg,
    required this.avatarFg,
    this.unreadCount = 0,
    this.kind = .venue,
    this.subtitle = '',
    this.contextLabel = '',
    this.quickReplies = const [],
  });

  factory ChatThread.fromJson(Map<String, dynamic> json) {
    return ChatThread(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      initials: json['initials'] as String? ?? json['ini'] as String? ?? '',
      preview: json['preview'] as String? ?? '',
      timeLabel: json['time_label'] as String? ?? json['time'] as String? ?? '',
      unreadCount: (json['unread_count'] as num?)?.toInt() ??
          (json['unread'] as num?)?.toInt() ??
          0,
      kind: ChatThreadKindX.fromJson(json['kind'] as String?),
      subtitle: json['subtitle'] as String? ?? '',
      contextLabel: json['context_label'] as String? ?? '',
      avatarBg: _colorFromHex(json['avatar_bg'] as String? ?? json['bg'] as String?) ??
          AppColors.padelSoft,
      avatarFg: _colorFromHex(json['avatar_fg'] as String? ?? json['fg'] as String?) ??
          AppColors.padel,
      quickReplies: _stringList(json['quick_replies'] ?? json['quickReplies']),
    );
  }

  final String id;
  final String name;
  final String initials;
  final String preview;
  final String timeLabel;
  final int unreadCount;
  final ChatThreadKind kind;
  final String subtitle;
  final String contextLabel;
  final Color avatarBg;
  final Color avatarFg;
  final List<String> quickReplies;

  bool get hasUnread => unreadCount > 0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'initials': initials,
    'preview': preview,
    'time_label': timeLabel,
    'unread_count': unreadCount,
    'kind': kind.apiValue,
    'subtitle': subtitle,
    'context_label': contextLabel,
    'avatar_bg': _colorToHex(avatarBg),
    'avatar_fg': _colorToHex(avatarFg),
    'quick_replies': quickReplies,
  };

  ChatThread copyWith({
    String? id,
    String? name,
    String? initials,
    String? preview,
    String? timeLabel,
    int? unreadCount,
    ChatThreadKind? kind,
    String? subtitle,
    String? contextLabel,
    Color? avatarBg,
    Color? avatarFg,
    List<String>? quickReplies,
  }) {
    return ChatThread(
      id: id ?? this.id,
      name: name ?? this.name,
      initials: initials ?? this.initials,
      preview: preview ?? this.preview,
      timeLabel: timeLabel ?? this.timeLabel,
      unreadCount: unreadCount ?? this.unreadCount,
      kind: kind ?? this.kind,
      subtitle: subtitle ?? this.subtitle,
      contextLabel: contextLabel ?? this.contextLabel,
      avatarBg: avatarBg ?? this.avatarBg,
      avatarFg: avatarFg ?? this.avatarFg,
      quickReplies: quickReplies ?? this.quickReplies,
    );
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is! List) return const [];
    return [
      for (final e in raw)
        if (e is String && e.trim().isNotEmpty) e,
    ];
  }

  static Color? _colorFromHex(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    var hex = raw.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    final value = int.tryParse(hex, radix: 16);
    if (value == null) return null;
    return Color(value);
  }

  static String _colorToHex(Color color) {
    final value = color.toARGB32().toRadixString(16).padLeft(8, '0');
    return '#${value.substring(2)}';
  }

  @override
  List<Object?> get props => [
    id,
    name,
    initials,
    preview,
    timeLabel,
    unreadCount,
    kind,
    subtitle,
    contextLabel,
    avatarBg,
    avatarFg,
    quickReplies,
  ];
}
