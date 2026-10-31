import 'package:equatable/equatable.dart';

import 'user_model.dart';

class AuthSession extends Equatable {
  const AuthSession({required this.accessToken, required this.user});

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    return AuthSession(
      accessToken:
          json['access_token'] as String? ?? json['token'] as String? ?? '',
      user: userJson is Map
          ? UserModel.fromJson(Map<String, dynamic>.from(userJson))
          : const UserModel(id: '', name: '', email: ''),
    );
  }

  final String accessToken;
  final UserModel user;

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'user': user.toJson(),
  };

  @override
  List<Object?> get props => [accessToken, user];
}
