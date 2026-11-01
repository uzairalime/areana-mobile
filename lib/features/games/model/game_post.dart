import 'package:equatable/equatable.dart';

enum GamePostStatus { open, full, closed }

extension GamePostStatusX on GamePostStatus {
  String get label => switch (this) {
    .open => 'Open',
    .full => 'Full',
    .closed => 'Closed',
  };

  static GamePostStatus fromJson(String? raw) => switch (raw) {
    'full' => .full,
    'closed' => .closed,
    _ => .open,
  };
}

/// Join state from the authenticated list/detail endpoints.
/// "none = not involved · pending = request sent, awaiting host ·
/// joined = accepted in" (user-web player-types).
enum GameJoinState { none, pending, joined }

extension GameJoinStateX on GameJoinState {
  static GameJoinState fromJson(String? raw, bool? joined) {
    if (joined == true) return .joined;
    return switch (raw) {
      'pending' => .pending,
      'joined' => .joined,
      _ => .none,
    };
  }
}

int _int(dynamic value, [int fallback = 0]) {
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? fallback;
  }
  return fallback;
}

double? _numOrNull(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

String fmtGameMinutes(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}

/// Game post, mirroring user-web `GamePost`.
class GamePost extends Equatable {
  const GamePost({
    required this.id,
    required this.sport,
    required this.city,
    required this.date,
    required this.startMinutes,
    required this.playersNeeded,
    required this.status,
    this.creatorId,
    this.creatorName,
    this.squadSize,
    this.level,
    this.note,
    this.courtName,
    this.courtSize,
    this.bookingId,
    this.isCurated = false,
    this.venueId,
    this.venueName,
    this.venueAddress,
    this.distanceKm,
    this.participantCount = 0,
    this.pricePerPlayer,
    this.courtFee,
    this.joinState = .none,
    this.pendingCount = 0,
    this.squadNames = const [],
  });

  factory GamePost.fromJson(Map<String, dynamic> json) {
    final venue = json['venue'];
    final venueMap = venue is Map ? Map<String, dynamic>.from(venue) : const {};
    final creator = json['creator'];
    final creatorMap =
        creator is Map ? Map<String, dynamic>.from(creator) : const {};
    final count = json['_count'];
    final countMap = count is Map ? Map<String, dynamic>.from(count) : const {};
    final squadNames = json['squadNames'];
    return GamePost(
      id: json['id']?.toString() ?? '',
      sport: json['sport']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      startMinutes: _int(json['startMinutes']),
      playersNeeded: _int(json['playersNeeded']),
      status: GamePostStatusX.fromJson(json['status'] as String?),
      creatorId: json['creatorId']?.toString(),
      creatorName: creatorMap['name']?.toString(),
      squadSize: json['squadSize'] == null ? null : _int(json['squadSize']),
      level: json['level'] as String?,
      note: json['note'] as String?,
      courtName: json['courtName'] as String?,
      courtSize: json['courtSize'] as String?,
      bookingId: json['bookingId']?.toString(),
      isCurated: json['isCurated'] as bool? ?? false,
      venueId: venueMap['id']?.toString(),
      venueName: venueMap['name']?.toString(),
      venueAddress: venueMap['address']?.toString(),
      distanceKm: _numOrNull(json['distanceKm']),
      participantCount: json['participantCount'] != null
          ? _int(json['participantCount'])
          : _int(countMap['participants']),
      pricePerPlayer: _numOrNull(json['pricePerPlayer']),
      courtFee: _numOrNull(json['courtFee']),
      joinState: GameJoinStateX.fromJson(
        json['joinState'] as String?,
        json['joined'] as bool?,
      ),
      pendingCount: _int(json['pendingCount']),
      squadNames: squadNames is List
          ? squadNames.map((e) => e.toString()).toList()
          : const [],
    );
  }

  final String id;
  final String sport;
  final String city;
  final String date;
  final int startMinutes;
  final int playersNeeded;
  final GamePostStatus status;
  final String? creatorId;
  final String? creatorName;
  final int? squadSize;
  final String? level;
  final String? note;
  final String? courtName;
  final String? courtSize;
  final String? bookingId;
  final bool isCurated;
  final String? venueId;
  final String? venueName;
  final String? venueAddress;
  final double? distanceKm;
  final int participantCount;
  final double? pricePerPlayer;
  final double? courtFee;
  final GameJoinState joinState;
  final int pendingCount;
  final List<String> squadNames;

  bool get isOpen => status == .open;
  bool get isJoined => joinState == .joined;
  bool get isPending => joinState == .pending;
  bool get canJoin => isOpen && joinState == .none;
  bool get canLeave => joinState == .joined || joinState == .pending;

  String get timeLabel => fmtGameMinutes(startMinutes);

  String get placeLine => [
    if (venueName != null && venueName!.isNotEmpty) venueName!,
    if (city.isNotEmpty) city,
  ].join(' · ');

  String get playersLine => squadSize != null
      ? '$squadSize playing · $playersNeeded needed'
      : '$playersNeeded players needed';

  GamePost copyWith({GameJoinState? joinState, GamePostStatus? status}) {
    return GamePost(
      id: id,
      sport: sport,
      city: city,
      date: date,
      startMinutes: startMinutes,
      playersNeeded: playersNeeded,
      status: status ?? this.status,
      creatorId: creatorId,
      creatorName: creatorName,
      squadSize: squadSize,
      level: level,
      note: note,
      courtName: courtName,
      courtSize: courtSize,
      bookingId: bookingId,
      isCurated: isCurated,
      venueId: venueId,
      venueName: venueName,
      venueAddress: venueAddress,
      distanceKm: distanceKm,
      participantCount: participantCount,
      pricePerPlayer: pricePerPlayer,
      courtFee: courtFee,
      joinState: joinState ?? this.joinState,
      pendingCount: pendingCount,
      squadNames: squadNames,
    );
  }

  @override
  List<Object?> get props => [id, status, joinState, date, startMinutes];
}

class GameParticipant extends Equatable {
  const GameParticipant({required this.id, required this.name});

  factory GameParticipant.fromJson(Map<String, dynamic> json) {
    return GameParticipant(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}

class GamePostDetail extends Equatable {
  const GamePostDetail({required this.post, this.participants = const []});

  factory GamePostDetail.fromJson(Map<String, dynamic> json) {
    final raw = json['participants'];
    return GamePostDetail(
      post: GamePost.fromJson(json),
      participants: raw is List
          ? raw
              .whereType<Map>()
              .map(
                (e) => GameParticipant.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList()
          : const [],
    );
  }

  final GamePost post;
  final List<GameParticipant> participants;

  @override
  List<Object?> get props => [post, participants];
}
