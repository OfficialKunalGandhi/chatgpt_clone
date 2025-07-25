import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/chat_controller.dart';
import '../../widgets/chat_input_widget.dart';
import '../../widgets/chat_message_widget.dart';
import '../../widgets/drawer_menu.dart';

class ChatScreen extends StatelessWidget {
  final ChatController chatController = Get.put(ChatController());

  ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Obx(
          () => Text(
            chatController.currentConversation.value?.title ?? 'New Chat',
            style: const TextStyle(color: Colors.black),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
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
                if (chatController.isFirstLoad.value && chatController.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!chatController.isFirstLoad.value && chatController.messages.isEmpty) {
                  return _buildWelcomeView();
                } else {
                  return _buildChatList();
                }
              }),
            ),

            // Input area
            Obx(
              () => chatController.isProcessing.value
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
      reverse: false,
      // Display newest messages at the bottom
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
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Wrap(
              children: [
                _buildSuggestionButton('Code', Icons.code),
                _buildSuggestionButton('Generate', Icons.auto_stories),
                _buildSuggestionButton('Explain', Icons.science),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionButton(String text, IconData icon) {
    return GestureDetector(
      onTap: () => chatController.sendMessage(text),
      child: Container(
        margin: const EdgeInsets.only(right: 8.0, top: 8.0, bottom: 8.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: Colors.grey[400]!),
        ),

        child: Wrap(
          children: [
            Icon(icon),
            SizedBox(width: 8.0),
            Text(text, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
