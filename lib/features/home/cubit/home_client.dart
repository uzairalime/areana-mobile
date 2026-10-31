import 'package:dio/dio.dart';

import '../../../core/consts/api_endpoints.dart';
import '../../../core/services/api_result.dart';
import '../model/sport_game.dart';
import '../model/venue.dart';

class HomeClient {
  const HomeClient(this._dio);

  final Dio _dio;

  Future<ApiResult<List<SportGame>>> fetchSports() async {
    try {
      final response = await _dio.get<dynamic>(ApiEndpoints.sports);
      final list = _asList(response.data);
      if (list == null) {
        return const ApiError(message: 'Unexpected response');
      }
      final sports = list
          .whereType<Map>()
          .map((item) => SportGame.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      return ApiSuccess(sports, statusCode: response.statusCode);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<List<Venue>>> fetchPopularVenues({String? sportId}) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.popularVenues,
        queryParameters: {
          if (sportId != null &&
              sportId.isNotEmpty &&
              sportId != SportGame.all.id)
            'sport': sportId,
        },
      );
      final list = _asList(response.data);
      if (list == null) {
        return const ApiError(message: 'Unexpected response');
      }
      final venues = list
          .whereType<Map>()
          .map((item) => Venue.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      return ApiSuccess(venues, statusCode: response.statusCode);
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  static List? _asList(dynamic data) => switch (data) {
    final List raw => raw,
    final Map map when map['data'] is List => map['data'] as List,
    _ => null,
  };
}
