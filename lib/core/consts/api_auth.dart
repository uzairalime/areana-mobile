/// Which API paths need a player access token.
///
/// Public discovery (venues, courts, search, places) works while signed
/// out. Player data (bookings, chats, profile, notifications) does not.
abstract final class ApiAuth {
  static bool requiresAccessToken(String path, [String method = 'GET']) {
    final normalized = normalize(path);
    if (normalized.isEmpty) return false;
    return !_isPublic(normalized, method.toUpperCase());
  }

  static String normalize(String path) {
    var value = path.trim();
    final query = value.indexOf('?');
    if (query >= 0) value = value.substring(0, query);
    if (value.contains('://')) {
      value = Uri.tryParse(value)?.path ?? value;
    }
    while (value.startsWith('/')) {
      value = value.substring(1);
    }
    if (value.startsWith('api/')) value = value.substring(4);
    return value;
  }

  static bool _isPublic(String path, String method) {
    if (_matches(path, 'auth/request-otp') ||
        _matches(path, 'auth/verify-otp') ||
        _matches(path, 'auth/social') ||
        _matches(path, 'auth/refresh')) {
      return true;
    }
    if (_matches(path, 'venues') ||
        _matches(path, 'courts') ||
        _matches(path, 'sports') ||
        _matches(path, 'amenities') ||
        _matches(path, 'banners') ||
        _matches(path, 'search') ||
        _matches(path, 'places')) {
      return true;
    }
    if (_matches(path, 'bookings/shared') && method == 'GET') {
      return true;
    }
    if (_matches(path, 'game-posts')) {
      if (path.contains('/join') ||
          path.contains('/leave') ||
          path.contains('/requests')) {
        return false;
      }
      return method == 'GET';
    }
    return false;
  }

  static bool _matches(String path, String prefix) {
    return path == prefix || path.startsWith('$prefix/');
  }
}
