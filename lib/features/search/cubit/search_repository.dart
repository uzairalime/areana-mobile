import '../../../core/config/app_config.dart';
import '../../../core/mock/mock_delay.dart';
import '../../../core/mock/mock_search_data.dart';
import '../../../core/services/api_result.dart';
import '../../../core/services/recent_search_store.dart';
import '../model/search_models.dart';
import 'search_client.dart';

class SearchRepository {
  const SearchRepository(this._client, this._recent);

  final SearchClient _client;
  final RecentSearchStore _recent;

  Future<ApiResult<SearchBundle>> search(String query) {
    if (AppConfig.useMockApi) {
      return MockDelay.run(() => ApiSuccess(MockSearchData.search(query)));
    }
    return _client.search(query);
  }

  Future<List<String>> loadRecent() => _recent.read();

  Future<List<String>> remember(String query) => _recent.add(query);

  Future<List<String>> removeRecent(String query) => _recent.remove(query);

  Future<void> clearRecent() => _recent.clear();
}
