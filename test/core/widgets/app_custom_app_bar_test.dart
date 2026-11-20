import 'package:arana360/core/services/session_cubit.dart';
import 'package:arana360/core/services/session_store.dart';
import 'package:arana360/core/widgets/app_custom_app_bar.dart';
import 'package:arana360/features/auth/model/auth_session.dart';
import 'package:arana360/features/auth/model/user_model.dart';
import 'package:arana360/features/notifications/cubit/notifications_client.dart';
import 'package:arana360/features/notifications/cubit/notifications_cubit.dart';
import 'package:arana360/features/notifications/cubit/notifications_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/in_memory_secure_storage.dart';

Finder get _unreadDot => find.byWidgetPredicate(
  (widget) => widget is SizedBox && widget.width == 9 && widget.height == 9,
);

class _Api {
  _Api() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          pending.add(_Request(options, handler));
        },
      ),
    );
  }

  final dio = Dio(BaseOptions(baseUrl: 'https://audit.invalid/api/'));
  final pending = <_Request>[];

  Future<_Request> take(String path) async {
    for (var i = 0; i < 100; i++) {
      final index = pending.indexWhere(
        (request) => request.options.path == path,
      );
      if (index >= 0) return pending.removeAt(index);
      await Future<void>.delayed(Duration.zero);
    }
    throw StateError('No queued request for $path');
  }
}

class _Request {
  _Request(this.options, this.handler);
  final RequestOptions options;
  final RequestInterceptorHandler handler;

  void respond(Object? data) => handler.resolve(
    Response<dynamic>(requestOptions: options, statusCode: 200, data: data),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<NotificationsCubit> loadInbox(
    WidgetTester tester,
    _Api api,
    List<Object?> items,
  ) async {
    final cubit = await tester.runAsync(() async {
      final notifications = NotificationsCubit(
        NotificationsRepository(NotificationsClient(api.dio)),
      );
      (await api.take('notifications'))
          .respond({'items': items, 'nextCursor': null});
      await Future<void>.delayed(Duration.zero);
      return notifications;
    });
    return cubit!;
  }

  Future<void> pumpBar(
    WidgetTester tester, {
    required SessionCubit session,
    required NotificationsCubit notifications,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: session),
            BlocProvider.value(value: notifications),
          ],
          child: Scaffold(
            appBar: AppCustomAppBar(onAvatarTap: () {}, onNotifications: () {}),
          ),
        ),
      ),
    );
  }

  testWidgets('signed-in user with no unread notifications sees icon only', (
    tester,
  ) async {
    final session = SessionCubit(
      SessionStore(secureStorage: InMemorySecureStorage()),
    );
    addTearDown(session.close);
    await session.applySession(
      const AuthSession(
        accessToken: 'token',
        user: UserModel(id: 'u1', name: 'Ali', email: 'ali@arena.test'),
      ),
    );
    final api = _Api();
    final notifications = await loadInbox(tester, api, [
      {'id': 'read', 'readAt': '2026-01-01T00:00:00.000Z'},
    ]);
    addTearDown(notifications.close);

    await pumpBar(tester, session: session, notifications: notifications);
    expect(_unreadDot, findsNothing);
  });

  testWidgets('signed-in user with unread notifications sees the red dot', (
    tester,
  ) async {
    final session = SessionCubit(
      SessionStore(secureStorage: InMemorySecureStorage()),
    );
    addTearDown(session.close);
    await session.applySession(
      const AuthSession(
        accessToken: 'token',
        user: UserModel(id: 'u1', name: 'Ali', email: 'ali@arena.test'),
      ),
    );
    final api = _Api();
    final notifications = await loadInbox(tester, api, [
      {'id': 'new'},
    ]);
    addTearDown(notifications.close);

    await pumpBar(tester, session: session, notifications: notifications);
    expect(_unreadDot, findsOneWidget);
  });

  testWidgets('guest never sees a notification red dot', (tester) async {
    final session = SessionCubit(
      SessionStore(secureStorage: InMemorySecureStorage()),
    );
    addTearDown(session.close);
    final api = _Api();
    final notifications = await loadInbox(tester, api, [
      {'id': 'new'},
    ]);
    addTearDown(notifications.close);

    await pumpBar(tester, session: session, notifications: notifications);
    expect(_unreadDot, findsNothing);
  });
}
