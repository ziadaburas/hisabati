import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static const String _themeKey = 'theme_mode';

  // 0 = system, 1 = light, 2 = dark
  final RxInt themeValue = 0.obs;

  ThemeMode get currentThemeMode => switch (themeValue.value) {
        1 => ThemeMode.light,
        2 => ThemeMode.dark,
        _ => ThemeMode.system
      };

  String get themeLabel =>
      switch (themeValue.value) { 1 => 'فاتح', 2 => 'داكن', _ => 'تبع النظام' };

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      themeValue.value = prefs.getInt(_themeKey) ?? 0;
    } catch (_) {
      themeValue.value = 0;
    }
  }

  Future<void> setTheme(int value) async {
    themeValue.value = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, value);
    } catch (_) {}
  }
}
