import 'package:dio/dio.dart';

import '../../../core/consts/api_endpoints.dart';
import '../../../core/services/api_result.dart';
import '../../../core/services/pagination.dart';
import '../../home/model/areana_models.dart';
import '../model/search_models.dart';

/// Search client: user-web browse search is `GET /venues?q=…`
/// (OffsetPage). Places are not a server feature — the idle
/// "Near me" row stays local; results are venues only.
class SearchClient {
  const SearchClient(this._dio);

  final Dio _dio;

  Future<ApiResult<SearchBundle>> search(String query) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.venues,
        queryParameters: {'q': query},
      );
      final page = parseOffsetPage(response.data, AreanaVenue.fromJson);
      return ApiSuccess(
        SearchBundle(
          venues: page.items.map((v) => v.toVenue()).toList(),
        ),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiError.fromDio(error);
    }
  }
}
