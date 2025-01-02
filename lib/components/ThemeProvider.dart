import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeData _currentTheme;
  final String key = "theme";
  SharedPreferences? _prefs;

  ThemeNotifier() : _currentTheme = yellowTheme {
    _loadFromPrefs();
  }

  ThemeData get currentTheme => _currentTheme;

  Future<void> toggleTheme() async {
    _currentTheme = (_currentTheme == yellowTheme) ? blackTheme : yellowTheme;
    await _saveToPrefs(_currentTheme == yellowTheme ? 'yellow' : 'black');
    notifyListeners();
  }

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> _loadFromPrefs() async {
    await _initPrefs();
    final themeStr = _prefs!.getString(key) ?? 'yellow';
    _currentTheme = (themeStr == 'black') ? blackTheme : yellowTheme;
    notifyListeners();
  }

  Future<void> _saveToPrefs(String themeStr) async {
    await _initPrefs();
    await _prefs!.setString(key, themeStr);
  }
}

ThemeData yellowTheme = ThemeData(
  primaryColor: Colors.yellow,
  hintColor: Colors.black,
  scaffoldBackgroundColor: Colors.yellow,
  // Define other text styles as needed
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.yellow,
    selectedItemColor: Colors.black,
    unselectedItemColor: Colors.white, // Or any other color
  ),
  // Add other customizations as needed
);

ThemeData blackTheme = ThemeData(
  primaryColor: Colors.black,
  hintColor: Colors.yellow,
  scaffoldBackgroundColor: Colors.black,
  // Define other text styles as needed
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.black,
    selectedItemColor: Colors.yellow,
    unselectedItemColor: Colors.white, // Or any other color
  ),
  // Add other customizations as needed
);

