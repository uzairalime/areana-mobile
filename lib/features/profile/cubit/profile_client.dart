import 'package:dio/dio.dart';

import '../../../core/consts/api_endpoints.dart';
import '../../../core/services/api_result.dart';
import '../../../core/services/pagination.dart';
import '../../auth/model/user_model.dart';
import '../../home/model/areana_models.dart';
import '../../home/model/venue.dart';
import '../model/help_faq.dart';
import '../model/notification_prefs.dart';
import '../model/profile_overview.dart';
import '../model/user_review.dart';

class ProfileClient {
  const ProfileClient(this._dio);

  final Dio _dio;

  Future<ApiResult<ProfileOverview>> fetchOverview() async {
    try {
      final response = await _dio.get<dynamic>(ApiEndpoints.profile);
      final map = _asMap(response.data);
      if (map == null) {
        return const ApiError(message: 'Unexpected response');
      }
      return ApiSuccess(
        ProfileOverview.fromJson(map),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<UserModel>> updateProfile(Map<String, dynamic> body) async {
    try {
      final response = await _dio.put<dynamic>(
        ApiEndpoints.profile,
        data: body,
      );
      return _parseUser(response.data, response.statusCode);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.post<dynamic>(
        ApiEndpoints.profilePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
      return const ApiSuccess(null);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<void>> deleteAccount() async {
    try {
      await _dio.delete<dynamic>(ApiEndpoints.profile);
      return const ApiSuccess(null);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<NotificationPrefs>> fetchNotificationPrefs() async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.profileNotifications,
      );
      final map = _asMap(response.data);
      if (map == null) {
        return const ApiError(message: 'Unexpected response');
      }
      return ApiSuccess(
        NotificationPrefs.fromJson(map),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<NotificationPrefs>> updateNotificationPrefs(
    NotificationPrefs prefs,
  ) async {
    try {
      final response = await _dio.put<dynamic>(
        ApiEndpoints.profileNotifications,
        data: prefs.toJson(),
      );
      final map = _asMap(response.data) ?? prefs.toJson();
      return ApiSuccess(
        NotificationPrefs.fromJson(map),
        statusCode: response.statusCode,
      );
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

  Future<ApiResult<List<UserReview>>> fetchReviews() async {
    try {
      final response = await _dio.get<dynamic>(ApiEndpoints.profileReviews);
      final list = _asList(response.data);
      if (list == null) {
        return const ApiError(message: 'Unexpected response');
      }
      final reviews = list
          .whereType<Map>()
          .map((item) => UserReview.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      return ApiSuccess(reviews, statusCode: response.statusCode);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<List<HelpFaq>>> fetchHelp() async {
    try {
      final response = await _dio.get<dynamic>(ApiEndpoints.profileHelp);
      final list = _asList(response.data);
      if (list == null) {
        return const ApiError(message: 'Unexpected response');
      }
      final faqs = list
          .whereType<Map>()
          .map((item) => HelpFaq.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      return ApiSuccess(faqs, statusCode: response.statusCode);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<void>> requestDownloadData() async {
    try {
      await _dio.post<dynamic>(ApiEndpoints.profileDownloadData);
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

  static List? _asList(dynamic data) => switch (data) {
    final List raw => raw,
    final Map map when map['data'] is List => map['data'] as List,
    _ => null,
  };
}
