import 'deep_link_intent.dart';
import 'deep_link_uri.dart';

/// Maps a URI to a typed intent — same idea as ReelStay's [intentResolver].
AppDeepLinkIntent resolveDeepLinkIntent(Uri uri) {
  if (!isSupportedDeepLink(uri)) {
    return UnsupportedDeepLinkIntent(uri: uri);
  }

  final path = deepLinkPath(uri);
  if (!isSupportedDeepLinkPath(path)) {
    return UnsupportedDeepLinkIntent(uri: uri);
  }

  final segments = deepLinkSegments(uri);
  if (segments.isEmpty) {
    return HomeIntent(uri: uri);
  }

  return switch (segments.first) {
    'messages' => _messagesIntent(uri, segments),
    'chat' => segments.length >= 2 && segments[1].isNotEmpty
        ? ChatThreadIntent(uri: uri, threadId: segments[1])
        : MessagesListIntent(uri: uri),
    'notifications' => NotificationsIntent(uri: uri),
    'bookings' => BookingsIntent(uri: uri, tab: _bookingsTab(uri, segments)),
    'home' => HomeIntent(uri: uri),
    _ => UnsupportedDeepLinkIntent(uri: uri),
  };
}

/// `/bookings?tab=past` or `/bookings/past`.
String? _bookingsTab(Uri uri, List<String> segments) {
  const allowed = {'upcoming', 'past', 'reviews'};
  final fromQuery = uri.queryParameters['tab']?.trim().toLowerCase();
  if (fromQuery != null && allowed.contains(fromQuery)) return fromQuery;
  if (segments.length >= 2) {
    final fromPath = segments[1].trim().toLowerCase();
    if (allowed.contains(fromPath)) return fromPath;
  }
  return null;
}

AppDeepLinkIntent _messagesIntent(Uri uri, List<String> segments) {
  if (segments.length >= 2 && segments[1].isNotEmpty) {
    return ChatThreadIntent(uri: uri, threadId: segments[1]);
  }
  return MessagesListIntent(uri: uri);
}
