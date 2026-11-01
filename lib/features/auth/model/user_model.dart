import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.avatarUrl,
    this.provider,
    this.city = '',
    this.favouriteSports = const [],
    this.memberSinceLabel = '',
    this.emailVerified = false,
    this.phoneVerified = false,
    this.languageCode = 'en',
    this.paymentPreference = 'pay_at_ground',
    this.twoStepEnabled = false,
    this.passwordUpdatedLabel = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawAvatar =
        json['avatar_url'] as String? ?? json['avatarUrl'] as String?;
    final rawProvider = json['provider'] as String?;
    final sportsRaw = json['favourite_sports'] ?? json['favorite_sports'];
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatarUrl: rawAvatar == null || rawAvatar.trim().isEmpty
          ? null
          : rawAvatar.trim(),
      provider: rawProvider == null || rawProvider.trim().isEmpty
          ? null
          : rawProvider.trim(),
      city: json['city'] as String? ?? '',
      favouriteSports: sportsRaw is List
          ? sportsRaw.map((e) => e.toString()).toList(growable: false)
          : const [],
      memberSinceLabel: json['member_since_label'] as String? ??
          json['member_since'] as String? ??
          '',
      emailVerified: json['email_verified'] as bool? ?? false,
      phoneVerified: json['phone_verified'] as bool? ?? false,
      languageCode: json['language'] as String? ??
          json['language_code'] as String? ??
          'en',
      paymentPreference: json['payment_preference'] as String? ??
          'pay_at_ground',
      twoStepEnabled: json['two_step_enabled'] as bool? ?? false,
      passwordUpdatedLabel: json['password_updated_label'] as String? ?? '',
    );
  }

  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;
  final String? provider;
  final String city;
  final List<String> favouriteSports;
  final String memberSinceLabel;
  final bool emailVerified;
  final bool phoneVerified;
  final String languageCode;
  final String paymentPreference;
  final bool twoStepEnabled;
  final String passwordUpdatedLabel;

  String get languageLabel => switch (languageCode) {
    'ur' => 'اردو',
    _ => 'English',
  };

  String get paymentLabel => switch (paymentPreference) {
    'online' => 'Pay online',
    _ => 'Pay at ground',
  };

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    String? provider,
    String? city,
    List<String>? favouriteSports,
    String? memberSinceLabel,
    bool? emailVerified,
    bool? phoneVerified,
    String? languageCode,
    String? paymentPreference,
    bool? twoStepEnabled,
    String? passwordUpdatedLabel,
    bool clearAvatar = false,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: clearAvatar ? null : avatarUrl ?? this.avatarUrl,
      provider: provider ?? this.provider,
      city: city ?? this.city,
      favouriteSports: favouriteSports ?? this.favouriteSports,
      memberSinceLabel: memberSinceLabel ?? this.memberSinceLabel,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      languageCode: languageCode ?? this.languageCode,
      paymentPreference: paymentPreference ?? this.paymentPreference,
      twoStepEnabled: twoStepEnabled ?? this.twoStepEnabled,
      passwordUpdatedLabel:
          passwordUpdatedLabel ?? this.passwordUpdatedLabel,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    if (avatarUrl != null) 'avatar_url': avatarUrl,
    if (provider != null) 'provider': provider,
    'city': city,
    'favourite_sports': favouriteSports,
    'member_since_label': memberSinceLabel,
    'email_verified': emailVerified,
    'phone_verified': phoneVerified,
    'language': languageCode,
    'payment_preference': paymentPreference,
    'two_step_enabled': twoStepEnabled,
    'password_updated_label': passwordUpdatedLabel,
  };

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    avatarUrl,
    provider,
    city,
    favouriteSports,
    memberSinceLabel,
    emailVerified,
    phoneVerified,
    languageCode,
    paymentPreference,
    twoStepEnabled,
    passwordUpdatedLabel,
  ];
}
