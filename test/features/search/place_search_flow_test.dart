import 'package:arana360/core/services/explore_session_store.dart';
import 'package:arana360/core/services/recent_search_store.dart';
import 'package:arana360/features/explore/cubit/explore_cubit.dart';
import 'package:arana360/features/home/cubit/home_client.dart';
import 'package:arana360/features/home/cubit/home_repository.dart';
import 'package:arana360/features/search/cubit/search_client.dart';
import 'package:arana360/features/search/cubit/search_cubit.dart';
import 'package:arana360/features/search/cubit/search_repository.dart';
import 'package:arana360/features/search/model/search_models.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('typing Lahore asks Google places, not the venues list', () async {
    final api = _Api();
    final cubit = SearchCubit(
      SearchRepository(SearchClient(api.dio), RecentSearchStore()),
    );
    addTearDown(cubit.close);

    final pending = cubit.search('Lahore');
    final request = await api.take('places/autocomplete');
    expect(request.options.queryParameters['q'], 'Lahore');
    request.respond({
      'items': [
        {
          'id': 'ChIJ-lahore',
          'primaryText': 'Lahore',
          'secondaryText': 'Punjab, Pakistan',
          'label': 'Lahore, Punjab',
        },
      ],
      'total': 1,
      'hasMore': false,
    });
    await pending;
    expect(cubit.state.places.single.primaryText, 'Lahore');
    expect(api.pending, isEmpty);
  });

  test('explore place pick uses 50km radius and distance sort', () async {
    final api = _Api();
    final cubit = ExploreCubit(
      HomeRepository(HomeClient(api.dio)),
      ExploreSessionStore(),
    );
    addTearDown(cubit.close);
    (await api.take('venues')).respond(_venues(['seed']));

    final applied = cubit.applyArea(
      location: 'Lahore',
      placeId: 'ChIJ-lahore',
      lat: 31.5204,
      lng: 74.3587,
    );
    final request = await api.take('venues');
    expect(request.options.queryParameters['lat'], 31.5204);
    expect(request.options.queryParameters['lng'], 74.3587);
    expect(request.options.queryParameters['radiusKm'], 50);
    expect(request.options.queryParameters['sort'], 'distance');
    expect(request.options.queryParameters['type'], 'all');
    request.respond(_venues(['near']));
    await applied;
    expect(cubit.state.search.location, 'Lahore');
    expect(cubit.state.search.location.toLowerCase(), isNot('nearby'));
    expect(cubit.state.venues.single.id, 'near');
  });

  test('plain recent labels round-trip without searching the idle screen', () {
    const stored = RecentPlace(label: 'DHA');
    final parsed = RecentPlace.fromStored(stored.encoded);
    expect(parsed.label, 'DHA');
    expect(RecentPlace.fromStored('Lahore').label, 'Lahore');
    expect(RecentPlace.fromStored('Lahore').hasCoordinates, isFalse);
  });
}

Map<String, Object?> _venues(List<String> ids) {
  return {
    'items': [
      for (final id in ids) {'id': id, 'name': id, 'sports': ['Football']},
    ],
    'total': ids.length,
    'page': 1,
    'limit': 20,
    'hasMore': false,
  };
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
