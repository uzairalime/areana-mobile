import 'package:equatable/equatable.dart';

import '../../auth/model/user_model.dart';
import 'profile_stats.dart';

class ProfileOverview extends Equatable {
  const ProfileOverview({
    required this.user,
    this.stats = const ProfileStats(),
    this.appVersion = '1.4.0',
    this.buildNumber = '214',
  });

  factory ProfileOverview.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : json;
    final statsJson = json['stats'] is Map
        ? Map<String, dynamic>.from(json['stats'] as Map)
        : const <String, dynamic>{};
    return ProfileOverview(
      user: UserModel.fromJson(userJson),
      stats: ProfileStats.fromJson(statsJson),
      appVersion: json['app_version'] as String? ?? '1.4.0',
      buildNumber: json['build_number']?.toString() ?? '214',
    );
  }

  final UserModel user;
  final ProfileStats stats;
  final String appVersion;
  final String buildNumber;

  String get versionFooter => 'Pitchside v$appVersion (build $buildNumber)';

  ProfileOverview copyWith({
    UserModel? user,
    ProfileStats? stats,
    String? appVersion,
    String? buildNumber,
  }) {
    return ProfileOverview(
      user: user ?? this.user,
      stats: stats ?? this.stats,
      appVersion: appVersion ?? this.appVersion,
      buildNumber: buildNumber ?? this.buildNumber,
    );
  }

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'stats': stats.toJson(),
    'app_version': appVersion,
    'build_number': buildNumber,
  };

  @override
  List<Object?> get props => [user, stats, appVersion, buildNumber];
}
