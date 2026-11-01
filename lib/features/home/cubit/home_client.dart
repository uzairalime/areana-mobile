import 'package:dio/dio.dart';

import '../../../core/consts/api_endpoints.dart';
import '../../../core/services/api_result.dart';
import '../../../core/services/pagination.dart';
import '../model/areana_models.dart';
import '../model/sport_game.dart';

/// Discovery client — the only home file that imports Dio.
/// Endpoints mirror user-web browse/home/courts: `GET /venues`,
/// `GET /courts`, `GET /venues/:id`, `GET /courts/:id`,
/// `GET /courts/:id/availability`, reviews, cities, surfaces,
/// banners, slot search, and venue events/reports.
class HomeClient {
  const HomeClient(this._dio);

  final Dio _dio;

  Map<String, dynamic> _query({
    String? q,
    String? city,
    String? sport,
    String? surface,
    String? sort,
    double? lat,
    double? lng,
    int? page,
    int? limit,
  }) {
    return {
      if (q != null && q.isNotEmpty) 'q': q,
      if (city != null && city.isNotEmpty) 'city': city,
      if (sport != null && sport.isNotEmpty) 'sport': sport,
      if (surface != null && surface.isNotEmpty) 'surface': surface,
      if (sort != null && sort.isNotEmpty) 'sort': sort,
      if (lat != null && lng != null) 'lat': lat,
      if (lat != null && lng != null) 'lng': lng,
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    };
  }

  Future<ApiResult<List<SportGame>>> fetchSports() async {
    try {
      final response = await _dio.get<dynamic>(ApiEndpoints.sports);
      final page = parseOffsetPage(
        response.data,
        (json) => json,
      );
      // Server items are `{name}` (see user-web BrowsePage); map the
      // name to both id and label so catalog presets still match.
      final sports = page.items.map((item) {
        final name = item['name']?.toString() ?? '';
        return SportGame.fromJson({'id': name, 'name': name});
      }).where((s) => s.label.isNotEmpty).toList();
      return ApiSuccess(sports, statusCode: response.statusCode);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<List<String>>> fetchCities() async {
    try {
      final response = await _dio.get<dynamic>(ApiEndpoints.venuesCities);
      final page = parseOffsetPage(response.data, (json) => json);
      final cities = page.items
          .map((item) => item['name']?.toString() ?? '')
          .where((c) => c.isNotEmpty)
          .toList();
      return ApiSuccess(cities, statusCode: response.statusCode);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<List<String>>> fetchSurfaces() async {
    try {
      final response = await _dio.get<dynamic>(ApiEndpoints.venuesSurfaces);
      final page = parseOffsetPage(response.data, (json) => json);
      final surfaces = page.items
          .map((item) => item['name']?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
      return ApiSuccess(surfaces, statusCode: response.statusCode);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

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
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.venues,
        queryParameters: _query(
          q: q,
          city: city,
          sport: sport,
          surface: surface,
          sort: sort,
          lat: lat,
          lng: lng,
          page: page,
          limit: limit,
        ),
      );
      return ApiSuccess(
        parseOffsetPage(response.data, AreanaVenue.fromJson),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

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
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.courts,
        queryParameters: _query(
          q: q,
          city: city,
          sport: sport,
          surface: surface,
          sort: sort,
          lat: lat,
          lng: lng,
          page: page,
          limit: limit,
        ),
      );
      return ApiSuccess(
        parseOffsetPage(response.data, AreanaCourtListItem.fromJson),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<AreanaVenueDetail>> fetchVenueDetail(String id) async {
    try {
      final response = await _dio.get<dynamic>(ApiEndpoints.venue(id));
      final data = response.data;
      if (data is! Map) return const ApiError(message: 'Unexpected response');
      return ApiSuccess(
        AreanaVenueDetail.fromJson(Map<String, dynamic>.from(data)),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<AreanaCourtDetail>> fetchCourtDetail(String id) async {
    try {
      final response = await _dio.get<dynamic>(ApiEndpoints.court(id));
      final data = response.data;
      if (data is! Map) return const ApiError(message: 'Unexpected response');
      return ApiSuccess(
        AreanaCourtDetail.fromJson(Map<String, dynamic>.from(data)),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<AvailabilityResponse>> fetchAvailability({
    required String courtId,
    required String date,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.courtAvailability(courtId),
        queryParameters: {'date': date},
      );
      final data = response.data;
      if (data is! Map) return const ApiError(message: 'Unexpected response');
      return ApiSuccess(
        AvailabilityResponse.fromJson(Map<String, dynamic>.from(data)),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<CursorPage<AreanaReview>>> fetchVenueReviews(
    String venueId, {
    String? cursor,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.venueReviews(venueId),
        queryParameters: {
          if (cursor != null) 'cursor': cursor,
          'limit': limit,
        },
      );
      return ApiSuccess(
        parseCursorPage(response.data, AreanaReview.fromJson),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<CursorPage<AreanaReview>>> fetchCourtReviews(
    String courtId, {
    String? cursor,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.courtReviews(courtId),
        queryParameters: {
          if (cursor != null) 'cursor': cursor,
          'limit': limit,
        },
      );
      return ApiSuccess(
        parseCursorPage(response.data, AreanaReview.fromJson),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<List<AreanaBanner>>> fetchBanners({String? city}) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.banners,
        queryParameters: {
          if (city != null && city.isNotEmpty) 'city': city,
        },
      );
      final page = parseOffsetPage(response.data, AreanaBanner.fromJson);
      return ApiSuccess(page.items, statusCode: response.statusCode);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<List<SlotSearchResult>>> fetchSlotSearch({
    required String date,
    String? sport,
    String? city,
    String? size,
    bool? indoor,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.searchSlots,
        queryParameters: {
          'date': date,
          if (sport != null && sport.isNotEmpty) 'sport': sport,
          if (city != null && city.isNotEmpty) 'city': city,
          if (size != null && size.isNotEmpty) 'size': size,
          if (indoor != null) 'indoor': indoor.toString(),
        },
      );
      final data = response.data;
      if (data is! Map) return const ApiError(message: 'Unexpected response');
      final map = Map<String, dynamic>.from(data);
      final results = (map['results'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((e) => SlotSearchResult.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return ApiSuccess(results, statusCode: response.statusCode);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  /// Fire-and-forget analytics beacon, same as user-web tracking.ts.
  /// Failures are swallowed: analytics must never break browsing.
  Future<void> postVenueEvent({
    required String venueId,
    required String type,
    String? courtId,
    String? visitorId,
  }) async {
    try {
      await _dio.post<dynamic>(
        ApiEndpoints.venueEvents(venueId),
        data: {
          'type': type,
          if (courtId != null) 'courtId': courtId,
          if (visitorId != null) 'visitorId': visitorId,
        },
      );
    } catch (_) {
      // Analytics only.
    }
  }
}
