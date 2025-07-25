import 'package:chatgpt_clone/controllers/auth_controller.dart';
import 'package:chatgpt_clone/controllers/chat_controller.dart';
import 'package:chatgpt_clone/controllers/settings_controller.dart';
import 'package:chatgpt_clone/screens/auth/login_screen.dart';
import 'package:chatgpt_clone/screens/auth/register_screen.dart';
import 'package:chatgpt_clone/screens/chat/chat_screen.dart';
import 'package:chatgpt_clone/screens/settings/settings_screen.dart';
import 'package:chatgpt_clone/screens/splash_screen.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize controllers
  _initControllers();

  runApp(
    DevicePreview(
      enabled: kIsWeb,
      builder: (context) => const MyApp(), // Wrap your app
    ),
  );
}

// Initialize all required controllers
void _initControllers() {
  Get.put(AuthController());
  Get.put(ChatController());
  Get.put(SettingsController());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ChatGPT Clone',
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light().copyWith(
          primary: Colors.blue,
          secondary: Colors.blue,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          elevation: 1,
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/register', page: () => RegisterScreen()),
        GetPage(name: '/chat', page: () => ChatScreen()),
        GetPage(name: '/settings', page: () => SettingsScreen()),
      ],
    );
  }
}
