// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;
  double _fontSize = 16.0;

  // Getters
  bool get isDark => _isDark;
  double get fontSize => _fontSize;

  // Static Themes (used in MyApp)
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.brown,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF6D4C41),
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.brown,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF6D4C41),
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16),
    ),
  );

  ThemeProvider() {
    _loadSettings();
  }

  // Toggle Dark Mode
  void toggleDarkMode() async {
    _isDark = !_isDark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDark);
  }

  // Change Font Size
  void setFontSize(double size) async {
    if (size >= 12 && size <= 26) {
      _fontSize = size;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('fontSize', size);
    }
  }

  // Load saved settings
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool('darkMode') ?? false;
    _fontSize = prefs.getDouble('fontSize') ?? 16.0;
    notifyListeners();
  }
}
