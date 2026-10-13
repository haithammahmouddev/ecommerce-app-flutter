import 'package:flutter/material.dart';
import '../../../../../common/preferences/preferences_manager.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isSystem => _themeMode == ThemeMode.system;
  bool get isDark => _themeMode == ThemeMode.dark;

  Future<void> init() async {
    String? savedTheme = PreferencesManager().getString("theme_mode");
    if (savedTheme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (savedTheme == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    String value = 'system';
    if (mode == ThemeMode.dark) value = 'dark';
    if (mode == ThemeMode.light) value = 'light';

    await PreferencesManager().setString('theme_mode', value);
    notifyListeners();
  }
}