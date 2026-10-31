abstract final class EmailMask {
  /// `arsalnapax@gmail.com` → `ar....@gmail.com`
  static String mask(String email) {
    final trimmed = email.trim();
    final at = trimmed.indexOf('@');
    if (at <= 0) {
      return trimmed;
    }
    final local = trimmed.substring(0, at);
    final domain = trimmed.substring(at);
    if (local.length <= 2) {
      return '$local....$domain';
    }
    return '${local.substring(0, 2)}....$domain';
  }
}
