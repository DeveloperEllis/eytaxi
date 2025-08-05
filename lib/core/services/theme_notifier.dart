import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  static const String prefKey = 'theme_mode';

  ThemeMode _currentTheme = ThemeMode.light;

  ThemeNotifier() {
    _loadFromPrefs();
  }

  ThemeMode get value => _currentTheme;

  void toggleTheme() {
    _currentTheme =
        _currentTheme == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(prefKey);

    if (themeIndex != null) {
      if (themeIndex == 0) {
        _currentTheme = ThemeMode.light;
      } else if (themeIndex == 1) {
        _currentTheme = ThemeMode.dark;
      } else {
        _currentTheme = ThemeMode.system;
      }
      notifyListeners();
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    int themeIndex = 0;
    if (_currentTheme == ThemeMode.light) {
      themeIndex = 0;
    } else if (_currentTheme == ThemeMode.dark) {
      themeIndex = 1;
    } else {
      themeIndex = 2;
    }
    await prefs.setInt(prefKey, themeIndex);
  }
}
