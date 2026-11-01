import 'package:dio/dio.dart';

import '../../../core/consts/api_endpoints.dart';
import '../../../core/services/api_result.dart';
import '../../../core/services/pagination.dart';
import '../model/game_post.dart';

class GamesClient {
  const GamesClient(this._dio);

  final Dio _dio;

  Future<ApiResult<OffsetPage<GamePost>>> fetchGames({
    String? sport,
    String? city,
    String? date,
    String status = 'open',
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.gamePosts,
        queryParameters: {
          if (sport != null && sport.isNotEmpty) 'sport': sport,
          if (city != null && city.isNotEmpty) 'city': city,
          if (date != null && date.isNotEmpty) 'date': date,
          'status': status,
          'page': page,
          'limit': limit,
        },
      );
      final pageResult = parseOffsetPage(
        response.data,
        (json) => GamePost.fromJson(json),
      );
      return ApiSuccess(pageResult, statusCode: response.statusCode);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<GamePostDetail>> fetchGame(String id) async {
    try {
      final response = await _dio.get<dynamic>(ApiEndpoints.gamePost(id));
      final map = _asMap(response.data);
      if (map == null) return const ApiError(message: 'Unexpected response');
      return ApiSuccess(
        GamePostDetail.fromJson(map),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<GamePost>> createGame({
    required String bookingId,
    required int playersNeeded,
    int? squadSize,
    String? level,
    String? note,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiEndpoints.gamePosts,
        data: {
          'bookingId': bookingId,
          'playersNeeded': playersNeeded,
          if (squadSize != null) 'squadSize': squadSize,
          if (level != null && level.isNotEmpty) 'level': level,
          if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
        },
      );
      final map = _asMap(response.data);
      if (map == null) return const ApiError(message: 'Unexpected response');
      return ApiSuccess(
        GamePost.fromJson(map),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<void>> joinGame(String id) async {
    try {
      await _dio.post<dynamic>(ApiEndpoints.gamePostJoin(id));
      return const ApiSuccess(null);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<void>> leaveGame(String id) async {
    try {
      await _dio.post<dynamic>(ApiEndpoints.gamePostLeave(id));
      return const ApiSuccess(null);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<void>> deleteGame(String id) async {
    try {
      await _dio.delete<dynamic>(ApiEndpoints.gamePost(id));
      return const ApiSuccess(null);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<void>> acceptRequest({
    required String postId,
    required String participantId,
  }) async {
    try {
      await _dio.post<dynamic>(
        ApiEndpoints.gamePostRequestAccept(postId, participantId),
      );
      return const ApiSuccess(null);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<void>> rejectRequest({
    required String postId,
    required String participantId,
  }) async {
    try {
      await _dio.post<dynamic>(
        ApiEndpoints.gamePostRequestReject(postId, participantId),
      );
      return const ApiSuccess(null);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  static Map<String, dynamic>? _asMap(dynamic data) => switch (data) {
    final Map map when map['data'] is Map =>
      Map<String, dynamic>.from(map['data'] as Map),
    final Map map => Map<String, dynamic>.from(map),
    _ => null,
  };
}
