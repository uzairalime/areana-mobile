import 'package:arana360/core/services/notification/notification_payload.dart';
import 'package:arana360/features/conversations/cubit/chat_cubit.dart';
import 'package:arana360/features/conversations/cubit/conversations_client.dart';
import 'package:arana360/features/conversations/cubit/conversations_cubit.dart';
import 'package:arana360/features/conversations/cubit/conversations_repository.dart';
import 'package:arana360/features/conversations/model/conversation_models.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('inbox loads threads and booking chat opens a venue thread', () async {
    final api = _Api();
    final repo = ConversationsRepository(ConversationsClient(api.dio));
    final cubit = ConversationsCubit(repo);
    addTearDown(cubit.close);

    final list = await api.take('conversations');
    expect(list.options.queryParameters['limit'], 30);
    list.respond({
      'items': [
        {
          'id': 'c1',
          'venueId': 'v1',
          'venueName': 'Arena One Padel Club',
          'title': 'Arena One Padel Club',
          'lastPreview': 'Yes, free parking',
          'unreadCount': 2,
        },
      ],
      'nextCursor': null,
    });
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.threads.single.title, 'Arena One Padel Club');
    expect(cubit.state.unreadThreadCount, 1);

    final opened = cubit.openWithVenue(venueId: 'v1', bookingId: 'b1');
    final req = await api.take('conversations');
    expect(req.options.method, 'POST');
    expect(req.options.data['venueId'], 'v1');
    expect(req.options.data['bookingId'], 'b1');
    req.respond({
      'id': 'c1',
      'venueId': 'v1',
      'venueName': 'Arena One Padel Club',
      'title': 'Arena One Padel Club',
    });
    expect((await opened)?.id, 'c1');
  });

  test('chat send posts the body and prepends the new message', () async {
    final api = _Api();
    final repo = ConversationsRepository(ConversationsClient(api.dio));
    final cubit = ChatCubit(repo, conversationId: 'c1');
    addTearDown(cubit.close);

    (await api.take('conversations/c1')).respond({
      'id': 'c1',
      'venueId': 'v1',
      'venueName': 'Arena One',
      'title': 'Arena One',
      'lastBooking': {
        'id': 'b1',
        'courtName': 'Court 2',
        'date': '2026-10-28',
        'startMinutes': 1140,
      },
    });
    (await api.take('conversations/c1/messages')).respond({
      'items': [
        {
          'id': 'm1',
          'senderId': 'arena',
          'body': 'Yes, free parking at the back of the club.',
          'createdAt': '2026-10-28T13:46:00.000Z',
          'mine': false,
        },
      ],
      'nextCursor': null,
    });
    await api.take('conversations/c1/read');
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.thread?.lastBooking?.chipLabel, contains('Court 2'));
    expect(cubit.state.messages.single.mine, isFalse);

    final sent = cubit.send('Great, do you have parking?');
    final post = await api.take('conversations/c1/messages');
    expect(post.options.method, 'POST');
    expect(post.options.data['body'], 'Great, do you have parking?');
    post.respond({
      'id': 'm2',
      'senderId': 'me',
      'body': 'Great, do you have parking?',
      'createdAt': '2026-10-28T13:47:00.000Z',
      'mine': true,
    });
    expect(await sent, isTrue);
    expect(cubit.state.messages.first.id, 'm2');
    expect(cubit.state.messages, hasLength(2));
  });

  test('booking chip formats court and slot', () {
    const chip = ConversationBookingChip(
      id: 'b',
      courtName: 'Court 2',
      date: '2026-10-28',
      startMinutes: 1140,
    );
    expect(chip.chipLabel, 'Court 2 · Wed 28 Oct, 7:00 PM');
  });

  test('push payload opens chat or bookings from FCM data', () {
    expect(
      NotificationPayload.fromRemoteData({
        'type': 'chat_message',
        'conversationId': 'c1',
      }).link,
      '/chat/c1',
    );
    expect(
      NotificationPayload.fromRemoteData({
        'type': 'booking_confirmed',
        'bookingId': 'b1',
      }).link,
      '/bookings',
    );
  });
}

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
