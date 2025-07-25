import 'dart:math';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../api/api_response.dart';
import '../models/message.dart';
import '../models/conversation.dart';
import '../api/services/chat_service.dart';
import '../api/services/google_ai_service.dart';
import '../api/services/conversation_service.dart';
import 'auth_controller.dart';

enum AIModel {
  gemini,
  chatGPT
}

class ChatController extends GetxController {
  final ChatService _chatService = ChatService();
  final GoogleAiService _googleAiService = GoogleAiService();
  final ConversationService _conversationService = ConversationService();
  final AuthController _authController = Get.find<AuthController>();

  // Observable variables
  final RxList<Message> messages = <Message>[].obs;
  final RxList<Conversation> conversations = <Conversation>[].obs;
  final Rx<Conversation?> currentConversation = Rx<Conversation?>(null);

  final RxBool isProcessing = false.obs;
  final RxBool isFirstLoad = true.obs;
  final RxBool isLoadingConversations = false.obs;

  // Model selection
  final Rx<AIModel> selectedModel = AIModel.gemini.obs;

  @override
  void onInit() {
    super.onInit();
    loadConversations();
  }

  // Load user's conversations
  Future<void> loadConversations() async {
    // if (_authController.currentUser.value == null) {
    //   return;
    // }

    isLoadingConversations.value = true;

    try {
      final userId = _authController.currentUser.value!.id;
      final response = await _conversationService.getUserConversations(userId);

      if (response.success && response.data != null) {
        final List<dynamic> conversationsData = response.data is List
            ? response.data
            : response.data['conversations'] ?? [];

        conversations.value = conversationsData
            .map((data) => Conversation.fromJson(data))
            .toList();

        // Load active conversation if any
        if (conversations.isNotEmpty) {
          final activeResponse = await _conversationService.getActiveConversation(userId);

          if (activeResponse.success && activeResponse.data != null) {
            final activeConversation = Conversation.fromJson(
                activeResponse.data is Map ? activeResponse.data : activeResponse.data[0]
            );

            currentConversation.value = activeConversation;
            loadMessages(activeConversation.id);
          } else {
            // If no active conversation, set the first one as active
            currentConversation.value = conversations.first;
            loadMessages(conversations.first.id);
          }
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load conversations: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingConversations.value = false;
    }
  }

  // Load messages for a specific conversation
  Future<void> loadMessages(String conversationId) async {
    isFirstLoad.value = true;

    try {
      final response = await _conversationService.getConversationWithMessages(conversationId);

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final List<dynamic> messagesData = data['messages'] ?? [];



        messages.value = messagesData
            .map((data) {
              data["message"] =data["sender"]=="user"? data["message"] :_formatMessageContent(data["message"]);
              return Message.fromJson(data); })
            .toList();
      } else {
        isFirstLoad.value = false;

        messages.clear();
      }
    } catch (e) {
      isFirstLoad.value = false;

      Get.snackbar(
        'Error',
        'Failed to load messages: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      messages.clear();
    } finally {
      isFirstLoad.value = false;
    }
  }

  // Create a new conversation
  Future<void> createNewConversation({String? title}) async {
    if (_authController.currentUser.value == null) {
      return;
    }

    try {
      final userId = _authController.currentUser.value!.id;
      final response = await _conversationService.createConversation(
        userId: userId,
        title: title ?? 'New Chat',
        setOthersInactive: true,
      );

      if (response.success && response.data != null) {
        final newConversation = Conversation.fromJson(response.data);

        // Add to conversations list
        conversations.add(newConversation);

        // Set as current conversation
        currentConversation.value = newConversation;

        // Clear messages
        messages.clear();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create new conversation: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Load an existing conversation
  Future<void> loadConversation(String conversationId) async {
    try {
      // Find the conversation in the list
      final conversation = conversations.firstWhere(
        (c) => c.id == conversationId,
        orElse: () => throw Exception('Conversation not found'),
      );

      // Set conversation as active in backend
      await _conversationService.updateConversation(
        conversationId: conversationId,
        isActive: true,
      );

      // Update current conversation
      currentConversation.value = conversation;

      // Load messages
      await loadMessages(conversationId);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load conversation: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Delete a conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      final response = await _conversationService.deleteConversation(conversationId);

      if (response.success) {
        // Remove from list
        conversations.removeWhere((c) => c.id == conversationId);

        // If current conversation was deleted, create a new one or load another
        if (currentConversation.value?.id == conversationId) {
          if (conversations.isNotEmpty) {
            await loadConversation(conversations.first.id);
          } else {
            await createNewConversation();
          }
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete conversation: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Send a message and get AI response
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || isProcessing.value) {
      return;
    }

    // Ensure we have a conversation
    if (currentConversation.value == null) {
      await createNewConversation();
    }


    isProcessing.value = true;

    try {
      // Create user message
      final userMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        sender: 'user',
        timestamp: DateTime.now(),
        conversationId: currentConversation.value!.id,
      );

      // Add to UI immediately
      messages.add(userMessage);

      // Get user and conversation IDs
      final userId = _authController.currentUser.value!.id;
      final conversationId = currentConversation.value!.id;

      // Process with selected AI model
      late ApiResponse response;

      if (selectedModel.value == AIModel.gemini) {
        // Use Gemini API
        response = await _googleAiService.processChatMessage(
          userId: userId,
          conversationId: conversationId,
          message: content,
        );
      } else {
        // Use ChatGPT API
        response = await _chatService.sendChatGPTMessage(
          userId: userId,
          conversationId: conversationId,
          message: content,
        );
      }

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        // Extract AI response - handle different response formats from different APIs
        String rawResponse;
        if (true) {
          rawResponse = data['response'] ?? data['message'] ?? data["aiResponse"]["message"];

        // Convert the message to formatted text (handling code blocks, bold, links)
        final formattedResponse = _formatMessageContent(rawResponse);

        // Create AI message
        final aiMessage = Message(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '1',
          content: formattedResponse,
          sender: 'assistant',
          timestamp: DateTime.now(),
          conversationId: conversationId,
        );

        // Add to UI
        messages.add(aiMessage);

        // Update conversation title if it's new
        if (currentConversation.value!.title == 'New Chat') {
          // Generate a title based on the first message
          final title = content.length > 30
              ? content.substring(0, 27) + '...'
              : content;

          await _conversationService.updateConversation(
            conversationId: conversationId,
            title: title,
          );

          // Update in local list
          final index = conversations.indexWhere((c) => c.id == conversationId);
          if (index >= 0) {
            final updatedConversation = Conversation(
              id: conversationId,
              userId: userId,
              title: title,
              isActive: true,
              createdAt: currentConversation.value!.createdAt,
              updatedAt: DateTime.now(),
            );

            conversations[index] = updatedConversation;
            currentConversation.value = updatedConversation;
          }
        }
      }} else {
        // Add error message
        final errorMessage = Message(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '1',
          content: 'Error: Failed to get response from AI'+response.data.toString(),
          sender: 'assistant',
          timestamp: DateTime.now(),
          conversationId: conversationId,
        );

        messages.add(errorMessage);

        Get.snackbar(
          'Error',
          response.message ?? 'Failed to process message',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send message: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  // Clear current chat (create a new conversation)
  void clearCurrentChat() {
    createNewConversation();
  }

  // Format message content (handle code blocks, bold, links)
  String _formatMessageContent(String content) {
    String formattedContent = content;
    
    // Debug the raw content
    print("Raw content from API: $content");

    // Some API responses might include HTML entities or have different formats
    // Let's check if the content is already in a special format
    if (content.contains("<code") || content.contains("<bold>") || content.contains("<link")) {
      print("Content already contains formatting tags, returning as is");
      return content;
    }

    // Handle code blocks (```code```)
    formattedContent = _formatCodeBlocks(formattedContent);
    print("After code blocks formatting: ${formattedContent.substring(0, min(50, formattedContent.length))}...");

    // Handle inline code (`code`)
    formattedContent = _formatInlineCode(formattedContent);
    print("After inline code formatting: ${formattedContent.substring(0, min(50, formattedContent.length))}...");

    // Handle bold text (**text**)
    formattedContent = _formatBoldText(formattedContent);
    print("After bold formatting: ${formattedContent.substring(0, min(50, formattedContent.length))}...");

    // Handle links ([text](url))
    formattedContent = _formatLinks(formattedContent);
    print("Final formatted content: ${formattedContent.substring(0, min(50, formattedContent.length))}...");

    return formattedContent;
  }

  // Format code blocks (```code```)
  String _formatCodeBlocks(String content) {
    // We'll use a special marker for code blocks that our UI can interpret
    // Format: <code language="language">code content</code>

    final RegExp codeBlockRegex = RegExp(r'```([a-zA-Z]*)\n([\s\S]*?)\n```', multiLine: true);

    return content.replaceAllMapped(codeBlockRegex, (match) {
      final language = match.group(1) ?? '';
      final code = match.group(2) ?? '';
      return '<code language="$language">${_escapeHtml(code)}</code>';
    });
  }

  // Format inline code (`code`)
  String _formatInlineCode(String content) {
    // Format: <code-inline>code</code-inline>
    final RegExp inlineCodeRegex = RegExp(r'`([^`]+)`');

    return content.replaceAllMapped(inlineCodeRegex, (match) {
      final code = match.group(1) ?? '';
      return '<code-inline>${_escapeHtml(code)}</code-inline>';
    });
  }

  // Format bold text (**text**)
  String _formatBoldText(String content) {
    // Format: <bold>text</bold>
    final RegExp boldRegex = RegExp(r'\*\*([^*]+)\*\*');

    return content.replaceAllMapped(boldRegex, (match) {
      final text = match.group(1) ?? '';
      return '<bold>$text</bold>';
    });
  }

  // Format links ([text](url))
  String _formatLinks(String content) {
    // Format: <link url="url">text</link>
    final RegExp linkRegex = RegExp(r'\[([^\]]+)\]\(([^)]+)\)');

    return content.replaceAllMapped(linkRegex, (match) {
      final text = match.group(1) ?? '';
      final url = match.group(2) ?? '';
      return '<link url="$url">$text</link>';
    });
  }

  // Escape HTML special characters to prevent injection
  String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#039;');
  }
}
