import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  factory ApiException.fromDioError(DioException error) {
    int? statusCode = error.response?.statusCode;
    String message;
    dynamic data = error.response?.data;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Request send timeout';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Response receive timeout';
        break;
      case DioExceptionType.badCertificate:
        message = 'Bad certificate';
        break;
      case DioExceptionType.badResponse:
        message = _handleBadResponse(statusCode, data);
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled';
        break;
      case DioExceptionType.connectionError:
        message = 'Connection error';
        break;
      case DioExceptionType.unknown:
        message = 'Unknown error occurred';
        break;
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      data: data,
    );
  }

  static String _handleBadResponse(int? statusCode, dynamic data) {
    switch (statusCode) {
      case 400:
        return data is Map ? data['message'] ?? 'Bad request' : 'Bad request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not found';
      case 422:
        return data is Map ? data['message'] ?? 'Validation error' : 'Validation error';
      case 500:
        return 'Server error';
      default:
        return 'Something went wrong';
    }
  }

  @override
  String toString() => message;
}
