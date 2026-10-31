import 'package:equatable/equatable.dart';

import '../../features/auth/model/user_model.dart';

class SessionState extends Equatable {
  const SessionState({this.accessToken, this.user});

  final String? accessToken;
  final UserModel? user;

  bool get isAuthenticated =>
      accessToken != null && accessToken!.isNotEmpty && user != null;

  @override
  List<Object?> get props => [accessToken, user];
}
