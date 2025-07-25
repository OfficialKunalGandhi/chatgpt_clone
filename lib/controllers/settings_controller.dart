import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../api/services/google_ai_service.dart';
import '../api/services/conversation_service.dart';
import '../models/conversation.dart';
import 'auth_controller.dart';
import 'chat_controller.dart';

class SettingsController extends GetxController {
  final GoogleAiService _googleAiService = GoogleAiService();
  final ConversationService _conversationService = ConversationService();
  final AuthController _authController = Get.find<AuthController>();

  // Observable variables
  final RxBool isDarkMode = true.obs;
  final RxString messageDensity = 'normal'.obs;
  final RxDouble fontSize = 16.0.obs;
  final RxBool apiStatus = false.obs;
  final RxBool isTestingApi = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load settings from local storage if available
    // For now, we'll use default values
    loadSettings();
  }

  // Load settings from local storage
  void loadSettings() {
    // This would typically load from shared preferences or secure storage
    // For now, we'll just set defaults
    isDarkMode.value = true;
    messageDensity.value = 'normal';
    fontSize.value = 16.0;
  }

  // Save settings to local storage
  void saveSettings() {
    // This would typically save to shared preferences or secure storage
    // For now, this is just a placeholder
  }

  // Set dark mode
  void setDarkMode(bool value) {
    isDarkMode.value = value;
    saveSettings();

    // Apply theme change
    Get.changeTheme(value
        ? ThemeData.dark().copyWith(
            primaryColor: Colors.tealAccent,
            colorScheme: const ColorScheme.dark().copyWith(
              primary: Colors.tealAccent,
              secondary: Colors.tealAccent,
            ),
          )
        : ThemeData.light().copyWith(
            primaryColor: Colors.teal,
            colorScheme: const ColorScheme.light().copyWith(
              primary: Colors.teal,
              secondary: Colors.tealAccent,
            ),
          ));
  }

  // Set message density
  void setMessageDensity(String value) {
    messageDensity.value = value;
    saveSettings();
  }

  // Set font size
  void setFontSize(double value) {
    fontSize.value = value;
    saveSettings();
  }

  // Test API connection
  Future<void> testApiConnection() async {
    isTestingApi.value = true;

    try {
      final response = await _googleAiService.testGoogleAiConnection();

      apiStatus.value = response.success;

      Get.snackbar(
        response.success ? 'Success' : 'Error',
        response.success
            ? 'API connection successful'
            : 'API connection failed: ${response.message}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: response.success ? Colors.green : Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      apiStatus.value = false;
      Get.snackbar(
        'Error',
        'API connection test failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isTestingApi.value = false;
    }
  }

  // Clear all data (conversations and messages)
  Future<void> clearAllData() async {
    if (_authController.currentUser.value == null) {
      return;
    }

    try {
      final userId = _authController.currentUser.value!.id;

      // This would typically call an API to delete all user data
      // For now, let's just delete each conversation
      final conversationsResponse = await _conversationService.getUserConversations(userId);

      if (conversationsResponse.success && conversationsResponse.data != null) {
        final List<Map<String, dynamic>> conversationsData = conversationsResponse.data is List
            ? conversationsResponse.data
            : conversationsResponse.data['conversations'] ?? [];

        for (var conversationData in conversationsData) {
          final conversation = conversationData is Map
              ? Conversation.fromJson(conversationData)
              : null;

          if (conversation != null) {
            await _conversationService.deleteConversation(conversation.id);
          }
        }

        Get.snackbar(
          'Success',
          'All data has been cleared',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Reload the chat controller
        Get.find<ChatController>().clearCurrentChat();
        Get.find<ChatController>().loadConversations();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to clear data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
