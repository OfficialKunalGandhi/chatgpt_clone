

import '../api_response.dart';
import '../api_service.dart';

class UserService {
  final ApiService _apiService = ApiService();

  Future<ApiResponse> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    return await _apiService.post(
      'users/register',
      data: {
        'username': username,
        'email': email,
        'password': password,
      },
    );
  }

  Future<ApiResponse> loginUser({
    required String email,
    required String password,
  }) async {
    return await _apiService.post(
      'users/login',
      data: {
        'email': email,
        'password': password,
      },
    );
  }
}
