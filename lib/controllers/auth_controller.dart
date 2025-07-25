import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../api/services/user_service.dart';
import '../api/api_client.dart';
import '../api/api_response.dart';
import 'chat_controller.dart';

class AuthController extends GetxController {
  final UserService _userService = UserService();

  // Observable variables
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isPasswordHidden = true.obs;
  final RxBool isConfirmPasswordHidden = true.obs;

  // Store token in memory
  String? _token;

  // SharedPreferences keys
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _tokenKey = 'auth_token';

  @override
  void onInit() {
    super.onInit();
  }

  // Check if user is already logged in
  Future<void> checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if we have stored token
      _token = "demo";

      if (_token != null && _token!.isNotEmpty) {
        // Set token in API client
        ApiClient.getInstance().setAuthToken(_token!);

        // Retrieve stored user data
        final userId = prefs.getString(_userIdKey) ?? '';
        final username = prefs.getString(_userNameKey) ?? '';
        final email = prefs.getString(_userEmailKey) ?? '';

        if (userId.isNotEmpty) {
          currentUser.value = User(
            id: userId,
            username: username,
            email: email,
            createdAt: DateTime.now(), // We don't store these dates
            updatedAt: DateTime.now(), // We could store them as strings if needed
          );

          // Redirect to chat if not already there
            Get.offAllNamed('/chat');

        } else {
          // Token exists but no user data - clear token
          await _clearStoredUserData();
          Get.offAllNamed('/login');

        }
      }else{
        Get.offAllNamed('/login');

      }
    } catch (e) {
      print('Error checking login status: $e');
      await _clearStoredUserData();
    }
  }

  // Register new user
  Future<void> register(String username, String email, String password) async {
    isLoading.value = true;

    try {
      final response = await _userService.registerUser(
        username: username,
        email: email,
        password: password,
      );

      if (response.success) {
        Get.snackbar(
          'Success',
          'Registration successful! Please login.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.offNamed('/login');
      } else {
        Get.snackbar(
          'Error',
          response.message ?? 'Registration failed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Login user
  Future<void> login(String email, String password) async {
    isLoading.value = true;

    try {
      final response = await _userService.loginUser(
        email: email,
        password: password,
      );

      if (response.success && response.data != null) {
        // Extract token and user data
        final data = response.data as Map<String, dynamic>;
        _token = "demo";

        if (_token != null) {
          // Set token in API client
          ApiClient.getInstance().setAuthToken(_token!);

          // Save user details
          if (data['user'] != null) {
            currentUser.value = User.fromJson(data['user']);

            // Save user data to SharedPreferences
            await _saveUserData(
              userId: currentUser.value!.id,
              username: currentUser.value!.username,
              email: currentUser.value!.email,
              token: _token!,
            );
          }

          Get.offAllNamed('/chat');
        } else {
          Get.snackbar(
            'Error',
            'Invalid authentication token',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          response.message ?? 'Login failed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Logout user
  Future<void> logout() async {
    // Clear token
    _token = null;
    ApiClient.getInstance().removeAuthToken();

    // Clear user data
    currentUser.value = null;

    // Clear stored preferences
    await _clearStoredUserData();

    // Navigate to login
    Get.offAllNamed('/login');
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  // Save user data to SharedPreferences
  Future<void> _saveUserData({
    required String userId,
    required String username,
    required String email,
    required String token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userNameKey, username);
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_tokenKey, token);
  }

  // Clear stored user data
  Future<void> _clearStoredUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_tokenKey);
  }
}
