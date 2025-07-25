import 'package:dio/dio.dart';
import 'api_client.dart';
import 'api_exceptions.dart';
import 'api_response.dart';

class ApiService {
  final Dio _dio = ApiClient.getInstance().dio;

  Future<ApiResponse<T>> request<T>({
    required String path,
    required String method,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method),
      );

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        if (fromJson != null && response.data != null) {
          final T mappedData = fromJson(response.data);
          return ApiResponse.success(
            data: mappedData,
            statusCode: response.statusCode,
            message: response.statusMessage,
          );
        }
        return ApiResponse.success(
          data: response.data,
          statusCode: response.statusCode,
          message: response.statusMessage,
        );
      } else {
        return ApiResponse.error(
          message: response.data is Map ? response.data['message'] : 'Request failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      final exception = ApiException.fromDioError(e);
      return ApiResponse.error(
        message: exception.message,
        statusCode: exception.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  // Convenience methods for common HTTP methods
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    return request<T>(
      path: path,
      method: 'GET',
      queryParameters: queryParameters,
      fromJson: fromJson,
    );
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    return request<T>(
      path: path,
      method: 'POST',
      data: data,
      queryParameters: queryParameters,
      fromJson: fromJson,
    );
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    return request<T>(
      path: path,
      method: 'PUT',
      data: data,
      queryParameters: queryParameters,
      fromJson: fromJson,
    );
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    return request<T>(
      path: path,
      method: 'DELETE',
      data: data,
      queryParameters: queryParameters,
      fromJson: fromJson,
    );
  }
}
