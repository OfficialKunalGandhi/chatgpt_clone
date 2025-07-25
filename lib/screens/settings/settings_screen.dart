import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/auth_controller.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsController settingsController = Get.find<SettingsController>();
  final AuthController authController = Get.find<AuthController>();

  SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // User profile section
          _buildSectionHeader('Account'),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.tealAccent,
              child: Text(
                authController.currentUser.value?.username.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            title: Text(
              authController.currentUser.value?.username ?? 'User',
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              authController.currentUser.value?.email ?? 'user@example.com',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),
          const Divider(color: Colors.grey),

          // Appearance settings
          _buildSectionHeader('Appearance'),

          // Dark mode toggle
          Obx(() => SwitchListTile(
            title: const Text(
              'Dark Mode',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              'Always use dark theme',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            value: settingsController.isDarkMode.value,
            onChanged: (value) => settingsController.setDarkMode(value),
            activeColor: Colors.tealAccent,
          )),

          // Chat settings
          _buildSectionHeader('Chat Settings'),

          // Message density
          ListTile(
            title: const Text(
              'Message Density',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              'Adjust spacing between messages',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            trailing: Obx(() => DropdownButton<String>(
              value: settingsController.messageDensity.value,
              dropdownColor: Colors.grey[800],
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              underline: Container(),
              items: const [
                DropdownMenuItem(
                  value: 'compact',
                  child: Text('Compact', style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem(
                  value: 'normal',
                  child: Text('Normal', style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem(
                  value: 'spacious',
                  child: Text('Spacious', style: TextStyle(color: Colors.white)),
                ),
              ],
              onChanged: (value) => settingsController.setMessageDensity(value!),
            )),
          ),

          // Font size
          ListTile(
            title: const Text(
              'Font Size',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Obx(() => Slider(
              value: settingsController.fontSize.value,
              min: 12,
              max: 20,
              divisions: 4,
              activeColor: Colors.tealAccent,
              inactiveColor: Colors.grey[700],
              label: settingsController.fontSize.value.toStringAsFixed(0),
              onChanged: (value) => settingsController.setFontSize(value),
            )),
          ),

          // Google AI API settings
          _buildSectionHeader('API Settings'),

          ListTile(
            title: const Text(
              'API Status',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              'Test Google AI connection',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            trailing: Obx(() => settingsController.isTestingApi.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.tealAccent,
                    ),
                  )
                : Icon(
                    settingsController.apiStatus.value ? Icons.check_circle : Icons.error,
                    color: settingsController.apiStatus.value ? Colors.green : Colors.red,
                  )),
            onTap: () => settingsController.testApiConnection(),
          ),

          // Data management
          _buildSectionHeader('Data'),

          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Clear All Conversations',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              'This will permanently delete all your chat history',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            onTap: () => _showClearDataConfirmation(context),
          ),

          // App info
          _buildSectionHeader('About'),

          ListTile(
            title: const Text(
              'ChatGPT Clone',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),

          // Log out button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => authController.logout(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Log Out'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.tealAccent,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  void _showClearDataConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Clear All Data',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will permanently delete all your conversations. This action cannot be undone.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              settingsController.clearAllData();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
