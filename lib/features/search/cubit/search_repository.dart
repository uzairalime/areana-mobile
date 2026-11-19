import '../../../core/services/api_result.dart';
import '../../../core/services/recent_search_store.dart';
import '../model/search_models.dart';
import 'search_client.dart';

class SearchRepository {
  const SearchRepository(this._client, this._recent);

  final SearchClient _client;
  final RecentSearchStore _recent;

  Future<ApiResult<SearchBundle>> search(String query, {String? session}) =>
      _client.search(query, session: session);

  Future<ApiResult<PlaceSuggestion>> details(String placeId, {String? session}) =>
      _client.details(placeId, session: session);

  Future<ApiResult<PlaceSuggestion>> reverse({
    required double lat,
    required double lng,
  }) => _client.reverse(lat: lat, lng: lng);

  Future<List<RecentPlace>> loadRecent() => _recent.read();

  Future<List<RecentPlace>> remember(RecentPlace place) => _recent.add(place);

  Future<List<RecentPlace>> removeRecent(RecentPlace place) =>
      _recent.remove(place);

  Future<void> clearRecent() => _recent.clear();
}
