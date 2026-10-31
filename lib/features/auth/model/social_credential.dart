import 'package:equatable/equatable.dart';

import 'social_provider.dart';

class SocialCredential extends Equatable {
  const SocialCredential({
    required this.provider,
    required this.providerUid,
    this.email = '',
    this.name = '',
    this.avatarUrl,
    this.idToken,
  });

  final SocialProvider provider;
  final String providerUid;
  final String email;
  final String name;
  final String? avatarUrl;
  final String? idToken;

  Map<String, dynamic> toJson() => {
    'provider': provider.apiValue,
    'provider_uid': providerUid,
    'email': email,
    'name': name,
    if (avatarUrl != null) 'avatar_url': avatarUrl,
    if (idToken != null) 'id_token': idToken,
  };

  @override
  List<Object?> get props => [
    provider,
    providerUid,
    email,
    name,
    avatarUrl,
    idToken,
  ];
}
