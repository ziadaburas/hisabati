import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
import 'bindings/app_bindings.dart';
import 'controllers/theme_controller.dart';
import 'services/database_service.dart';
import 'theme/app_theme.dart';
import 'views/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite for web
  DatabaseService.initForWeb();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Get.put(ThemeController(), permanent: true);
  runApp(const Hisabati());
}

class Hisabati extends StatelessWidget {
  const Hisabati({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() => GetMaterialApp(
      title: 'حساباتي',
      debugShowCheckedModeBanner: false,
      initialBinding: AppBindings(),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.currentThemeMode,
      home: const SplashView(),
    ));
  }
}
