import '../../../core/services/api_result.dart';
import '../../../core/services/pagination.dart';
import '../model/areana_models.dart';
import '../model/sport_game.dart';
import 'home_client.dart';

/// Discovery repository. No mock branches: mock mode is off in
/// development and the Areana API is the source of truth.
class HomeRepository {
  const HomeRepository(this._client);

  final HomeClient _client;

  Future<ApiResult<List<SportGame>>> fetchSports() =>
      _client.fetchSports();

  Future<ApiResult<List<String>>> fetchCities() => _client.fetchCities();

  Future<ApiResult<List<String>>> fetchSurfaces() =>
      _client.fetchSurfaces();

  Future<ApiResult<OffsetPage<AreanaVenue>>> fetchVenues({
    String? q,
    String? city,
    String? sport,
    String? surface,
    String? sort,
    double? lat,
    double? lng,
    int page = 1,
    int limit = 20,
  }) =>
      _client.fetchVenues(
        q: q,
        city: city,
        sport: sport,
        surface: surface,
        sort: sort,
        lat: lat,
        lng: lng,
        page: page,
        limit: limit,
      );

  Future<ApiResult<OffsetPage<AreanaCourtListItem>>> fetchCourts({
    String? q,
    String? city,
    String? sport,
    String? surface,
    String? sort,
    double? lat,
    double? lng,
    int page = 1,
    int limit = 20,
  }) =>
      _client.fetchCourts(
        q: q,
        city: city,
        sport: sport,
        surface: surface,
        sort: sort,
        lat: lat,
        lng: lng,
        page: page,
        limit: limit,
      );

  Future<ApiResult<AreanaVenueDetail>> fetchVenueDetail(String id) =>
      _client.fetchVenueDetail(id);

  Future<ApiResult<AreanaCourtDetail>> fetchCourtDetail(String id) =>
      _client.fetchCourtDetail(id);

  Future<ApiResult<AvailabilityResponse>> fetchAvailability({
    required String courtId,
    required String date,
  }) =>
      _client.fetchAvailability(courtId: courtId, date: date);

  Future<ApiResult<CursorPage<AreanaReview>>> fetchVenueReviews(
    String venueId, {
    String? cursor,
  }) =>
      _client.fetchVenueReviews(venueId, cursor: cursor);

  Future<ApiResult<CursorPage<AreanaReview>>> fetchCourtReviews(
    String courtId, {
    String? cursor,
  }) =>
      _client.fetchCourtReviews(courtId, cursor: cursor);

  Future<ApiResult<List<AreanaBanner>>> fetchBanners({String? city}) =>
      _client.fetchBanners(city: city);

  Future<ApiResult<List<SlotSearchResult>>> fetchSlotSearch({
    required String date,
    String? sport,
    String? city,
    String? size,
    bool? indoor,
  }) =>
      _client.fetchSlotSearch(
        date: date,
        sport: sport,
        city: city,
        size: size,
        indoor: indoor,
      );

  Future<void> postVenueEvent({
    required String venueId,
    required String type,
    String? courtId,
    String? visitorId,
  }) =>
      _client.postVenueEvent(
        venueId: venueId,
        type: type,
        courtId: courtId,
        visitorId: visitorId,
      );
}
