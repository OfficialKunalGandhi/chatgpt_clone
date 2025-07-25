import '../api_response.dart';
import '../api_service.dart';

class GoogleAiService {
  final ApiService _apiService = ApiService();

  // Process a chat message with Google AI
  Future<ApiResponse> processChatMessage({
    required String userId,
    required String conversationId,
    required String message,
  }) async {
    return await _apiService.post(
      'google-ai/chat',
      data: {
        'userId': userId,
        'conversationId': conversationId,
        'message': message,
      },
    );
  }

  // Get Google AI chat history for a conversation
  Future<ApiResponse> getChatHistory(String conversationId) async {
    return await _apiService.get('google-ai/history/$conversationId');
  }

  // Delete Google AI chat history for a conversation
  Future<ApiResponse> deleteChatHistory(String conversationId) async {
    return await _apiService.delete('google-ai/history/$conversationId');
  }

  // Test Google AI connection
  Future<ApiResponse> testGoogleAiConnection() async {
    return await _apiService.get('test-google-ai/test-google-ai');
  }
}
