import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/bookings/cubit/bookings_cubit.dart';
import '../../features/bookings/model/booking_filter_tab.dart';
import '../router/app_router.dart';
import '../services/locator.dart';
import '../services/session_store.dart';
import 'deep_link_intent.dart';
import 'deep_link_resolver.dart';
import 'deep_link_uri.dart';

/// Lightweight deep-link orchestrator modeled on ReelStay:
/// listen → resolve intent → auth gate / pending → navigate.
class DeepLinkService {
  DeepLinkService(this._session);

  final SessionStore _session;
  final AppLinks _appLinks = AppLinks();

  GoRouter? _router;
  StreamSubscription<Uri>? _subscription;
  Uri? _pending;
  var _ready = false;

  Future<void> attach(GoRouter router) async {
    _router = router;
    _subscription ??= _appLinks.uriLinkStream.listen(
      handleUri,
      onError: (Object error, StackTrace stack) {
        debugPrint('DeepLink stream error: $error\n$stack');
      },
    );

    // Allow navigation after the first frame so shell routes exist.
    WidgetsBinding.instance.addPostFrameCallback((_) => markReady());

    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        await handleUri(initial);
      }
    } catch (error, stack) {
      debugPrint('DeepLink initial error: $error\n$stack');
    }
  }

  /// Call once the navigator can accept `go` / `push`.
  void markReady() {
    if (_ready) {
      unawaited(flushPending());
      return;
    }
    _ready = true;
    unawaited(flushPending());
  }

  Future<void> handleRaw(String? raw) async {
    final uri = resolveNotificationDeepLink(raw);
    if (uri != null) await handleUri(uri);
  }

  Future<void> handleUri(Uri uri) async {
    final intent = resolveDeepLinkIntent(uri);
    if (intent is UnsupportedDeepLinkIntent) {
      debugPrint('DeepLink ignored: $uri');
      return;
    }

    if (!_ready || _router == null) {
      _pending = uri;
      return;
    }

    if (intent.requiresAuth && !_session.isAuthenticated) {
      _pending = uri;
      _router!.go(AppRoutes.login);
      return;
    }

    await _navigate(intent);
  }

  /// Replay a pending link after a successful login.
  Future<void> flushPending() async {
    final pending = _pending;
    if (pending == null) return;
    _pending = null;
    await handleUri(pending);
  }

  Future<void> _navigate(AppDeepLinkIntent intent) async {
    final router = _router;
    if (router == null) return;

    // Unwind pushed routes so the destination is not buried under old sheets.
    while (router.canPop()) {
      router.pop();
    }
    await Future<void>.delayed(const Duration(milliseconds: 160));

    switch (intent) {
      case MessagesListIntent():
        router.go(AppRoutes.games);
      case ChatThreadIntent():
        // Chat no longer exists — the Games board replaced Messages.
        router.go(AppRoutes.games);
      case NotificationsIntent():
        router.go(AppRoutes.home);
        await Future<void>.delayed(const Duration(milliseconds: 120));
        router.push(AppRoutes.notifications);
      case BookingsIntent(:final tab):
        final location = (tab == null || tab.isEmpty)
            ? AppRoutes.bookings
            : '${AppRoutes.bookings}?tab=$tab';
        router.go(location);
        final filter = _bookingTabFromDeepLink(tab);
        if (filter != null) {
          getIt<BookingsCubit>().setTab(filter);
        }
      case HomeIntent():
        router.go(AppRoutes.home);
      case UnsupportedDeepLinkIntent():
        break;
    }
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _router = null;
    _ready = false;
  }
}

BookingFilterTab? _bookingTabFromDeepLink(String? raw) {
  final key = raw?.trim().toLowerCase();
  if (key == null || key.isEmpty) return null;
  return BookingFilterTab.values.asNameMap()[key];
}
