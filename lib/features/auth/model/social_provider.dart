enum SocialProvider {
  google,
  apple;

  String get apiValue => name;

  static SocialProvider? tryParse(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    for (final provider in SocialProvider.values) {
      if (provider.name == value) {
        return provider;
      }
    }
    return null;
  }
}
