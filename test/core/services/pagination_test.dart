import 'package:arana360/core/services/pagination.dart';
import 'package:arana360/features/home/model/areana_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('offset page compatibility', () {
    test('reads the live venue data envelope into visible venue models', () {
      final result = parseOffsetPage({
        'data': [
          {
            'id': 'demo-football-1',
            'name': 'Demo Football Lahore',
            'address': 'Demo Road',
            'city': 'Lahore',
            'sports': ['Football'],
            'lat': 31.47,
            'lng': 74.38,
            '_count': {'courts': 2},
          },
        ],
        'total': 21,
        'page': 1,
        'limit': 20,
      }, AreanaVenue.fromJson);

      expect(result.items, hasLength(1));
      final venue = result.items.single.toVenue();
      expect(venue.id, 'demo-football-1');
      expect(venue.name, 'Demo Football Lahore');
      expect(venue.sport, 'Football');
      expect(venue.location, 'Demo Road, Lahore');
      expect(venue.hasCoordinates, isTrue);
      expect(venue.courtsLabel, '2 courts');
      expect(result.totalPages, 2);
      expect(result.hasMore, isTrue);
    });

    test('stops paging after the last data page', () {
      final result = parseOffsetPage({
        'data': [
          {'id': 'last'},
        ],
        'total': 21,
        'page': 2,
        'limit': 20,
      }, (json) => json['id']);

      expect(result.items, ['last']);
      expect(result.totalPages, 2);
      expect(result.hasMore, isFalse);
    });

    test('preserves explicit items envelope pagination', () {
      final result = parseOffsetPage({
        'items': [
          {'id': 'modern'},
        ],
        'total': 50,
        'page': 1,
        'limit': 20,
        'totalPages': 7,
        'hasMore': false,
      }, (json) => json['id']);

      expect(result.items, ['modern']);
      expect(result.totalPages, 7);
      expect(result.hasMore, isFalse);
    });

    test('prefers an explicit empty items list over data', () {
      final result = parseOffsetPage({
        'items': [],
        'data': [
          {'id': 'legacy'},
        ],
      }, (json) => json['id']);

      expect(result.items, isEmpty);
      expect(result.hasMore, isFalse);
    });

    test('handles an empty live page without claiming more results', () {
      final result = parseOffsetPage({
        'data': [],
        'total': 0,
        'page': 1,
        'limit': 20,
      }, (json) => json);

      expect(result.items, isEmpty);
      expect(result.totalPages, 1);
      expect(result.hasMore, isFalse);
    });

    test('handles a zero limit without dividing by zero', () {
      final result = parseOffsetPage({
        'data': [],
        'total': 20,
        'limit': 0,
      }, (json) => json);

      expect(result.totalPages, 1);
      expect(result.hasMore, isFalse);
    });

    test('continues accepting bare list catalogs', () {
      final result = parseOffsetPage([
        {'name': 'Football'},
        {'name': 'Cricket'},
      ], (json) => json['name']);

      expect(result.items, ['Football', 'Cricket']);
      expect(result.total, 2);
      expect(result.hasMore, isFalse);
    });
  });
}
