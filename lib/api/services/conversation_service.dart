import '../api_response.dart';
import '../api_service.dart';

class ConversationService {
  final ApiService _apiService = ApiService();

  // Create a new conversation
  Future<ApiResponse> createConversation({
    required String userId,
    required String title,
    bool setOthersInactive = true,
  }) async {
    return await _apiService.post(
      'conversations',
      data: {
        'userId': userId,
        'title': title,
        'setOthersInactive': setOthersInactive,
      },
    );
  }

  // Get all conversations for a user
  Future<ApiResponse> getUserConversations(String userId) async {
    return await _apiService.get('conversations/user/$userId');
  }

  // Get the active conversation for a user
  Future<ApiResponse> getActiveConversation(String userId) async {
    return await _apiService.get('conversations/active/$userId');
  }

  // Get a specific conversation with its messages
  Future<ApiResponse> getConversationWithMessages(String conversationId) async {
    return await _apiService.get('conversations/$conversationId');
  }

  // Update a conversation's title or active status
  Future<ApiResponse> updateConversation({
    required String conversationId,
    String? title,
    bool? isActive,
  }) async {
    Map<String, dynamic> data = {};
    if (title != null) data['title'] = title;
    if (isActive != null) data['isActive'] = isActive;

    return await _apiService.put(
      'conversations/$conversationId',
      data: data,
    );
  }

  // Delete a conversation and all its messages
  Future<ApiResponse> deleteConversation(String conversationId) async {
    return await _apiService.delete('conversations/$conversationId');
  }
}
