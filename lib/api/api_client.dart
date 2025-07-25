import 'package:dio/dio.dart';

class ApiClient {
  static ApiClient? _instance;
  final Dio _dio = Dio();

  ApiClient._() {
    _dio.options = BaseOptions(
      baseUrl: 'http://192.168.1.68:3000/api/',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
      validateStatus: (status) {
        return status! < 500;
      },
    );

    // Add request interceptor for logging
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('REQUEST[${options.method}] => PATH: ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print(
            'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print('ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');
        return handler.next(e);
      },
    ));
  }

  factory ApiClient.getInstance() {
    _instance ??= ApiClient._();
    return _instance!;
  }

  Dio get dio => _dio;

  // Add authentication token
  void setAuthToken(String token) {
    // _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Remove authentication token
  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}
