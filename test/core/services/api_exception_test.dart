import 'package:arana360/core/services/api_result.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('backend validation messages stay readable with field errors intact', () {
    final request = RequestOptions(path: 'bookings');
    final error = ApiError<void>.fromDio(
      DioException(
        requestOptions: request,
        response: Response(
          requestOptions: request,
          statusCode: 400,
          data: {
            'message': ['courtId must be a string', 'date is required'],
            'errors': {'date': 'required'},
          },
        ),
      ),
    );
    expect(error.message, 'courtId must be a string\ndate is required');
    expect(error.statusCode, 400);
    expect(error.errors, {'date': 'required'});
  });

  test('empty server messages retain the transport failure description', () {
    final request = RequestOptions(path: 'bookings');
    final error = ApiError<void>.fromDio(
      DioException(
        requestOptions: request,
        message: 'Connection timed out',
        response: Response(
          requestOptions: request,
          data: {'message': []},
        ),
      ),
    );
    expect(error.message, 'Connection timed out');
  });
}
