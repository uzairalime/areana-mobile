import 'package:dio/dio.dart';

import '../../../core/consts/api_endpoints.dart';
import '../../../core/services/api_result.dart';
import '../../../core/services/pagination.dart';
import '../../auth/model/user_model.dart';
import '../../home/model/areana_models.dart';
import '../../home/model/venue.dart';
import '../model/profile_overview.dart';

class ProfileClient {
  const ProfileClient(this._dio);

  final Dio _dio;

  /// Own profile from the Areana API. No stats endpoint exists for
  /// players, so stats stay at their defaults.
  Future<ApiResult<ProfileOverview>> fetchOverview() async {
    try {
      final response = await _dio.get<dynamic>(ApiEndpoints.usersMe);
      final map = _asMap(response.data);
      if (map == null) {
        return const ApiError(message: 'Unexpected response');
      }
      return ApiSuccess(
        ProfileOverview(user: UserModel.fromJson(map)),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  /// PATCH /users/me. Only name/phone/city exist on the server;
  /// blank strings are ignored by the server, so they are omitted.
  /// (Password auth does not exist — players sign in with email OTP.)
  Future<ApiResult<UserModel>> updateProfile(Map<String, dynamic> body) async {
    try {
      final response = await _dio.patch<dynamic>(
        ApiEndpoints.usersMe,
        data: body,
      );
      return _parseUser(response.data, response.statusCode);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  /// DELETE /users/me anonymises the account in place.
  Future<ApiResult<void>> deleteAccount() async {
    try {
      await _dio.delete<dynamic>(ApiEndpoints.usersMe);
      return const ApiSuccess(null);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  /// Real favorites API: CursorPage of {venueId, venue} rows.
  /// Walks all pages so the saved list and heart state are complete.
  Future<ApiResult<List<Venue>>> fetchSavedVenues() async {
    try {
      final venues = <Venue>[];
      String? cursor;
      do {
        final response = await _dio.get<dynamic>(
          ApiEndpoints.favorites,
          queryParameters: {
            'limit': 50,
            if (cursor != null) 'cursor': cursor,
          },
        );
        final page = parseCursorPage<Map<String, dynamic>>(
          response.data,
          (json) => json,
        );
        for (final item in page.items) {
          final venueJson = item['venue'];
          if (venueJson is Map) {
            venues.add(
              AreanaVenue.fromJson(
                Map<String, dynamic>.from(venueJson),
              ).toVenue(),
            );
          }
        }
        cursor = page.nextCursor;
      } while (cursor != null);
      return ApiSuccess(venues);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<void>> saveVenue(String venueId) async {
    try {
      await _dio.post<dynamic>(
        ApiEndpoints.favorites,
        data: {'venueId': venueId},
      );
      return const ApiSuccess(null);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<void>> unsaveVenue(String venueId) async {
    try {
      await _dio.delete<dynamic>(
        '${ApiEndpoints.favorites}/$venueId',
      );
      return const ApiSuccess(null);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  ApiResult<UserModel> _parseUser(dynamic data, int? statusCode) {
    final map = _asMap(data);
    if (map == null) {
      return const ApiError(message: 'Unexpected response');
    }
    final userJson = map['user'] is Map
        ? Map<String, dynamic>.from(map['user'] as Map)
        : map;
    return ApiSuccess(UserModel.fromJson(userJson), statusCode: statusCode);
  }

  static Map<String, dynamic>? _asMap(dynamic data) => switch (data) {
    final Map raw => Map<String, dynamic>.from(raw),
    _ => null,
  };
}
