import '../../../core/config/app_config.dart';
import '../../../core/mock/mock_delay.dart';
import '../../../core/mock/mock_home_data.dart';
import '../../../core/services/api_result.dart';
import '../model/sport_game.dart';
import '../model/venue.dart';
import 'home_client.dart';

class HomeRepository {
  const HomeRepository(this._client);

  final HomeClient _client;

  Future<ApiResult<List<SportGame>>> fetchSports() {
    if (AppConfig.useMockApi) {
      return MockDelay.run(() => ApiSuccess(MockHomeData.sports));
    }
    return _client.fetchSports();
  }

  Future<ApiResult<List<Venue>>> fetchPopularVenues({String? sportId}) {
    if (AppConfig.useMockApi) {
      return MockDelay.run(
        () => ApiSuccess(MockHomeData.venuesForSport(sportId)),
      );
    }
    return _client.fetchPopularVenues(sportId: sportId);
  }
}
