import 'package:dio/dio.dart';

import '../../../core/consts/api_endpoints.dart';
import '../../../core/services/api_result.dart';
import '../../../core/services/pagination.dart';
import '../model/search_models.dart';

/// Place search: Google via the public Areana proxy.
class SearchClient {
  const SearchClient(this._dio);

  final Dio _dio;

  Future<ApiResult<SearchBundle>> search(String query) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.placesAutocomplete,
        queryParameters: {'q': query},
      );
      final page = parseOffsetPage(response.data, PlaceSuggestion.fromJson);
      return ApiSuccess(
        SearchBundle(places: page.items),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<PlaceSuggestion>> details(String placeId) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.placesDetails,
        queryParameters: {'placeId': placeId},
      );
      final data = response.data;
      if (data is! Map) return const ApiError(message: 'Unexpected response');
      return ApiSuccess(
        PlaceSuggestion.fromJson(Map<String, dynamic>.from(data)),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }

  Future<ApiResult<PlaceSuggestion>> reverse({
    required double lat,
    required double lng,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.placesReverse,
        queryParameters: {'lat': lat, 'lng': lng},
      );
      final data = response.data;
      if (data is! Map) return const ApiError(message: 'Unexpected response');
      return ApiSuccess(
        PlaceSuggestion.fromJson(Map<String, dynamic>.from(data)),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }
}
