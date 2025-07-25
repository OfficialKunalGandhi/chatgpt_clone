import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/chat_controller.dart';
import '../../widgets/chat_input_widget.dart';
import '../../widgets/chat_message_widget.dart';
import '../../widgets/drawer_menu.dart';

class ChatScreen extends StatelessWidget {
  final ChatController chatController =           Get.put(ChatController());


  ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Obx(() => Text(
          chatController.currentConversation.value?.title ?? 'New Chat',
          style: const TextStyle(color: Colors.black),
        )),
        iconTheme: IconThemeData(
          color: Colors.black
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () => chatController.clearCurrentChat(),
            tooltip: 'New Chat',
          ),
        ],
      ),
      drawer: const DrawerMenu(),
      body: SafeArea(
        child: Column(
          children: [
            // Chat messages area
            Expanded(
              child: Obx(() {
                if (chatController.isFirstLoad.value &&
                    chatController.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!chatController.isFirstLoad.value &&
                          chatController.messages.isEmpty) {
                  return _buildWelcomeView();
                } else {
                  return _buildChatList();
                }
              }),
            ),

            // Input area
            Obx(() => chatController.isProcessing.value
              ? const LinearProgressIndicator(
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.tealAccent),
                )
              : const SizedBox(height: 1),
            ),

            // Chat input
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ChatInputWidget(
                onSendMessage: (message) => chatController.sendMessage(message),
                isProcessing: chatController.isProcessing,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      reverse: false, // Display newest messages at the bottom
      itemCount: chatController.messages.length,
      itemBuilder: (context, index) {
        final message = chatController.messages[index];
        return ChatMessageWidget(message: message);
      },
    );
  }

  Widget _buildWelcomeView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Text(
            'What Can i Help You?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Wrap(
              children: [
                _buildSuggestionButton(
                  'Tell me about Flutter',
                  Icons.code,
                ),
                const SizedBox(height: 10),
                _buildSuggestionButton(
                  'Generate a story about space',
                  Icons.auto_stories,
                ),
                const SizedBox(height: 10),
                _buildSuggestionButton(
                  'Explain quantum computing',
                  Icons.science,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionButton(String text, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () => chatController.sendMessage(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey[700]!),
        ),
        elevation: 0,
        minimumSize: const Size(double.infinity, 60),
      ),
      icon: Icon(icon),
      label: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
