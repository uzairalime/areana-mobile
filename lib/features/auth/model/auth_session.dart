import 'package:equatable/equatable.dart';

import 'user_model.dart';

class AuthSession extends Equatable {
  const AuthSession({
    required this.accessToken,
    required this.user,
    this.refreshToken,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final payload = json['data'];
    if (payload is Map) json = Map<String, dynamic>.from(payload);
    final userJson = json['user'];
    final refresh =
        json['refresh_token'] as String? ?? json['refreshToken'] as String?;
    final complete = readProfileComplete(json);
    return AuthSession(
      accessToken:
          json['accessToken'] as String? ??
          json['access_token'] as String? ??
          json['token'] as String? ??
          '',
      refreshToken: refresh != null && refresh.isNotEmpty ? refresh : null,
      user: userJson is Map
          ? UserModel.fromJson({
              ...Map<String, dynamic>.from(userJson),
              if (complete != null) 'isComplete': complete,
            })
          : const UserModel(id: '', name: '', email: ''),
    );
  }

  final String accessToken;

  /// Rotating refresh token (Areana `/auth/refresh`). Null for legacy
  /// Pitchside/mock sessions, which never issued one.
  final String? refreshToken;
  final UserModel user;

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    if (refreshToken != null) 'refresh_token': refreshToken,
    'user': user.toJson(),
  };

  @override
  List<Object?> get props => [accessToken, refreshToken, user];
}
