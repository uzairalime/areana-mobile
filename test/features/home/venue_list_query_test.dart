import 'package:arana360/features/home/cubit/home_client.dart';
import 'package:arana360/features/home/cubit/home_cubit.dart';
import 'package:arana360/features/home/cubit/home_repository.dart';
import 'package:arana360/features/home/model/court_filter.dart';
import 'package:arana360/features/home/model/sport_game.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('filter draft maps to the public venues query', () {
    const open = CourtFilterDraft();
    expect(open.apiSort, 'rating');
    expect(open.apiMinPrice, isNull);
    expect(open.apiMaxPrice, isNull);

    final narrowed = const CourtFilterDraft().copyWith(
      sort: CourtSortOption.newest,
      sportId: 'padel',
      minPrice: 2000,
      maxPrice: 8000,
    );
    expect(narrowed.apiSort, 'newest');
    expect(narrowed.apiMinPrice, 2000);
    expect(narrowed.apiMaxPrice, 8000);
    expect(SportGame.apiName('padel'), 'Padel');
    expect(SportGame.apiName('all'), isNull);
    expect(SportGame.match('Indoor Cricket')?.id, 'cricket');
    expect(SportGame.catalog.where((sport) => !sport.isAll).length, 10);
    expect(
      SportGame.catalog.any((sport) => sport.id == 'courts'),
      isFalse,
    );
  });

  test('home loads type=all, then pages and applies filters on the API', () async {
    final api = _Api();
    final cubit = HomeCubit(HomeRepository(HomeClient(api.dio)));
    addTearDown(cubit.close);

    (await api.take('sports')).respond({
      'items': [
        {'name': 'Padel'},
        {'name': 'Football'},
      ],
      'total': 2,
      'page': 1,
      'limit': 2,
      'hasMore': false,
    });
    (await api.take('venues/cities')).respond({'items': [], 'total': 0});
    (await api.take('banners')).respond({'items': [], 'total': 0});
    final first = await api.take('venues');
    expect(first.options.queryParameters['type'], 'all');
    expect(first.options.queryParameters['page'], 1);
    expect(first.options.queryParameters['limit'], 20);
    expect(first.options.queryParameters.containsKey('sport'), isFalse);
    first.respond(_page(const ['a', 'b'], more: true));
    await _flush();
    expect(cubit.state.venues.map((venue) => venue.id), ['a', 'b']);
    expect(cubit.state.hasMore, isTrue);
    expect(cubit.state.sports.map((sport) => sport.id), ['all', 'padel', 'football']);

    final more = cubit.loadMore();
    final pageTwo = await api.take('venues');
    expect(pageTwo.options.queryParameters['page'], 2);
    expect(pageTwo.options.queryParameters['type'], 'all');
    pageTwo.respond(_page(const ['c'], page: 2));
    await more;
    expect(cubit.state.venues.map((venue) => venue.id), ['a', 'b', 'c']);
    expect(cubit.state.hasMore, isFalse);

    final filtered = cubit.applyFilter(
      const CourtFilterDraft(
        sort: CourtSortOption.priceLowHigh,
        sportId: 'padel',
        minPrice: 2000,
        maxPrice: 8000,
      ),
    );
    final query = await api.take('venues');
    expect(query.options.queryParameters['type'], 'all');
    expect(query.options.queryParameters['sport'], 'Padel');
    expect(query.options.queryParameters['sort'], 'price_asc');
    expect(query.options.queryParameters['minPrice'], 2000);
    expect(query.options.queryParameters['maxPrice'], 8000);
    expect(query.options.queryParameters['page'], 1);
    query.respond(
      _page(const ['padel-1']),
    );
    await filtered;
    expect(cubit.state.venues.single.id, 'padel-1');
    expect(cubit.state.selectedSportId, 'padel');
  });
}

Map<String, Object?> _page(List<String> ids, {int page = 1, bool more = false}) {
  return {
    'items': [
      for (final id in ids) {'id': id, 'name': id, 'sports': ['Padel']},
    ],
    'total': more ? ids.length + 1 : ids.length,
    'page': page,
    'limit': 20,
    'hasMore': more,
  };
}

Future<void> _flush() => Future<void>.delayed(Duration.zero);

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
