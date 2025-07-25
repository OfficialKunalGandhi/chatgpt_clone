import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/conversation.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({Key? key}) : super(key: key);

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  final ChatController chatController = Get.find<ChatController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    // TODO: implement initState
    chatController.loadConversations();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Drawer header with user info
          SizedBox(
      height: 50,),
         Column(
                  children: [
                    ListTile(
         leading: const Icon(Icons.add_circle_outline, color: Colors.black),
         title: const Text(
           'New Chat',
           style: TextStyle(color: Colors.black87),
         ),
         onTap: () {
           chatController.createNewConversation();
           Navigator.pop(context); // Close drawer
         },
                    ),

                    // Chats option
                    ListTile(
         leading: const Icon(Icons.chat_bubble_outline, color: Colors.black),
         title: const Text(
           'Chats',
           style: TextStyle(color: Colors.black87),
         ),
         onTap: () {
           Navigator.pop(context); // Close drawer
           // Navigate to chats screen or simply stay on current screen
           // as we're already in the chat section
         },
                    ),

                    // Library option
                    ListTile(
         leading: const Icon(Icons.book_outlined, color: Colors.black),
         title: const Text(
           'Library',
           style: TextStyle(color: Colors.black87),
         ),
         onTap: () {
           Navigator.pop(context); // Close drawer
           // TODO: Navigate to library screen
           Get.snackbar(
             'Coming Soon',
             'Library feature will be available soon!',
             snackPosition: SnackPosition.BOTTOM,
           );
         },
                    ),

                    // Explore GPTs option
                    ListTile(
         leading: const Icon(Icons.explore_outlined, color: Colors.black),
         title: const Text(
           'Explore GPTs',
           style: TextStyle(color: Colors.black87),
         ),
         onTap: () {
           Navigator.pop(context); // Close drawer
           // TODO: Navigate to explore GPTs screen
           Get.snackbar(
             'Coming Soon',
             'Explore GPTs feature will be available soon!',
             snackPosition: SnackPosition.BOTTOM,
           );
         },
                    ),
                  ]
                  ),
          // New chat button


          const Divider(color: Colors.grey),

          // Conversations list
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
                  child: Text(
                    "Recent Conversations",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    if (chatController.isLoadingConversations.value) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (chatController.conversations.isEmpty) {
                      return Center(
                        child: Text(
                          'No conversations yet',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      );
                    } else {
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: chatController.conversations.length,
                        itemBuilder: (context, index) {
                          final conversation = chatController.conversations[index];
                          return _buildConversationTile(conversation, chatController, context);
                        },
                      );
                    }
                  }),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.grey),

          // Settings option
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.black54),
            title: const Text(
              'Settings',
              style: TextStyle(color: Colors.black87),
            ),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Get.toNamed('/settings');
            },
          ),

          // Logout option
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.black54),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.black87),
            ),
            onTap: () {
              Navigator.pop(context); // Close drawer
              authController.logout();
            },
          ),

          // Version info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'v1.0.0',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(
    Conversation conversation,
    ChatController chatController,
    BuildContext context,
  ) {
    bool isActive = conversation.id == chatController.currentConversation.value?.id;

    return ListTile(
      leading: Icon(
        Icons.chat_bubble_outline,
        color: isActive ? Colors.blue : Colors.black54,
      ),
      title: Text(
        conversation.title,
        style: TextStyle(
          color: Colors.black87,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        'Created: ${_formatDate(conversation.createdAt)}',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      selected: isActive,
      selectedTileColor: Colors.blue.withOpacity(0.1),
      onTap: () {
        chatController.loadConversation(conversation.id);
        Navigator.pop(context); // Close drawer
      },
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
        onPressed: () {
          _showDeleteConfirmation(context, conversation, chatController);
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteConfirmation(
    BuildContext context,
    Conversation conversation,
    ChatController chatController,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Delete Conversation',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${conversation.title}"?',
          style: const TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close drawer
              chatController.deleteConversation(conversation.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
