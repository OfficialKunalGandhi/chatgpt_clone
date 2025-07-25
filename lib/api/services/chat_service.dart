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

  // Process message with ChatGPT (single message without conversation context)
  Future<ApiResponse> sendSingleChatGPTMessage({
    required String userId,
    required String message,
  }) async {
    return await _apiService.post(
      'chatgpt/chat',
      data: {
        'userId': userId,
        'message': message,
      },
    );
  }

  // Process message with ChatGPT within a conversation
  Future<ApiResponse> sendChatGPTMessage({
    required String userId,
    required String conversationId,
    required String message,
  }) async {
    return await _apiService.post(
      'chatgpt/conversation',
      data: {
        'userId': userId,
        'conversationId': conversationId,
        'message': message,
      },
    );
  }

  // Start a new conversation with ChatGPT
  Future<ApiResponse> startNewChatGPTConversation({
    required String userId,
    required String message,
  }) async {
    return await _apiService.post(
      'chatgpt/conversation',
      data: {
        'userId': userId,
        'message': message,
        'newConversation': true,
      },
    );
  }

  // Get all ChatGPT conversations for a user
  Future<ApiResponse> getChatGPTConversations(String userId) async {
    return await _apiService.get('chatgpt/conversations/$userId');
  }

  // Get a specific ChatGPT conversation with messages
  Future<ApiResponse> getChatGPTConversation(String conversationId) async {
    return await _apiService.get('chatgpt/conversation/$conversationId');
  }
}
