sealed class AppDeepLinkIntent {
  const AppDeepLinkIntent({required this.uri, required this.requiresAuth});

  final Uri uri;
  final bool requiresAuth;
}

final class MessagesListIntent extends AppDeepLinkIntent {
  const MessagesListIntent({required super.uri}) : super(requiresAuth: true);
}

final class ChatThreadIntent extends AppDeepLinkIntent {
  const ChatThreadIntent({required super.uri, required this.threadId})
    : super(requiresAuth: true);

  final String threadId;
}

final class NotificationsIntent extends AppDeepLinkIntent {
  const NotificationsIntent({required super.uri}) : super(requiresAuth: true);
}

final class BookingsIntent extends AppDeepLinkIntent {
  const BookingsIntent({required super.uri, this.tab})
    : super(requiresAuth: true);

  /// Optional bookings filter: `upcoming` | `past` | `reviews`.
  final String? tab;
}

final class HomeIntent extends AppDeepLinkIntent {
  const HomeIntent({required super.uri}) : super(requiresAuth: false);
}

final class UnsupportedDeepLinkIntent extends AppDeepLinkIntent {
  const UnsupportedDeepLinkIntent({required super.uri})
    : super(requiresAuth: false);
}
