import '../api_response.dart';
import '../api_service.dart';


class ChatService {
  final ApiService _apiService = ApiService();

  // Save a new chat message
  Future<ApiResponse> saveChatMessage({
    required String userId,
    required String message,
    required String sender,
  }) async {
    return await _apiService.post(
      'chats',
      data: {
        'userId': userId,
        'message': message,
        'sender': sender,
      },
    );
  }

  // Get chat history for a user
  Future<ApiResponse> getChatHistory(String userId) async {
    return await _apiService.get('chats/$userId');
  }

  // Delete chat history for a user
  Future<ApiResponse> deleteChatHistory(String userId) async {
    return await _apiService.delete('chats/$userId');
  }
}
