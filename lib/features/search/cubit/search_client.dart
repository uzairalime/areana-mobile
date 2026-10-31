import 'package:dio/dio.dart';

import '../../../core/consts/api_endpoints.dart';
import '../../../core/services/api_result.dart';
import '../model/search_models.dart';

class SearchClient {
  const SearchClient(this._dio);

  final Dio _dio;

  Future<ApiResult<SearchBundle>> search(String query) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.searchVenues,
        queryParameters: {'q': query},
      );
      final data = response.data;
      if (data is Map) {
        return ApiSuccess(
          SearchBundle.fromJson(Map<String, dynamic>.from(data)),
          statusCode: response.statusCode,
        );
      }
      // Legacy list-only payload → venues only.
      if (data is List) {
        return ApiSuccess(
          SearchBundle.fromJson({'venues': data, 'places': const []}),
          statusCode: response.statusCode,
        );
      }
      return const ApiError(message: 'Unexpected response');
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }
}
