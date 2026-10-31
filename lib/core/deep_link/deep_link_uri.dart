/// Origin used when a notification stores a path-only link (`/messages/…`).
/// Mirrors ReelStay's [kNotificationDeepLinkOrigin] pattern.
const kNotificationDeepLinkOrigin = 'https://www.pitchside.app';

const kDeepLinkCustomScheme = 'pitchside';

const kDeepLinkSupportedHosts = {
  'www.pitchside.app',
  'pitchside.app',
};

/// Path prefixes the app accepts for chat + notification deep links.
const kDeepLinkSupportedPaths = [
  '/messages',
  '/chat',
  '/notifications',
  '/bookings',
  '/home',
];

/// In-app / notification path for Bookings → Past tab.
const kBookingsPastDeepLink = '/bookings?tab=past';

/// Turns a stored notification `link` into a URI the resolver accepts.
Uri? resolveNotificationDeepLink(String? rawLink) {
  final raw = rawLink?.trim();
  if (raw == null || raw.isEmpty) return null;

  final parsed = Uri.tryParse(raw);
  if (parsed == null) return null;
  if (parsed.hasScheme) return parsed;

  return Uri.parse(
    kNotificationDeepLinkOrigin,
  ).resolve(raw.startsWith('/') ? raw : '/$raw');
}

/// `pitchside://messages/id` stores `messages` in the host, not the path.
List<String> deepLinkSegments(Uri uri) {
  final path = [
    for (final segment in uri.pathSegments)
      if (segment.isNotEmpty) segment,
  ];
  final host = uri.host;
  if (uri.scheme == kDeepLinkCustomScheme &&
      host.isNotEmpty &&
      !host.contains('.')) {
    return [host, ...path];
  }
  return path;
}

String deepLinkPath(Uri uri) {
  final segments = deepLinkSegments(uri);
  if (segments.isEmpty) return '/';
  return '/${segments.join('/')}';
}

bool isSupportedDeepLink(Uri uri) {
  if (uri.scheme == kDeepLinkCustomScheme) return true;
  if (uri.scheme == 'https' || uri.scheme == 'http') {
    return kDeepLinkSupportedHosts.contains(uri.host.toLowerCase());
  }
  return false;
}

bool isSupportedDeepLinkPath(String path) {
  if (path == '/' || path.isEmpty) return false;
  for (final prefix in kDeepLinkSupportedPaths) {
    if (path == prefix || path.startsWith('$prefix/')) return true;
  }
  return false;
}
