// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ThemeProvider extends ChangeNotifier {
//   bool _isDarkMode = false;
//   double _textSize = 1.0;

//   bool get isDarkMode => _isDarkMode;
//   double get textSize => _textSize;

//   ThemeProvider() {
//     _loadSettings();
//   }

//   Future<void> _loadSettings() async {
//     final prefs = await SharedPreferences.getInstance();
//     _isDarkMode = prefs.getBool('darkMode') ?? false;
//     _textSize = prefs.getDouble('textSize') ?? 1.0;
//     notifyListeners();
//   }

//   Future<void> toggleDarkMode(bool value) async {
//     _isDarkMode = value;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('darkMode', value);
//     notifyListeners();
//   }

//   Future<void> setTextSize(double size) async {
//     _textSize = size;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setDouble('textSize', size);
//     notifyListeners();
//   }

//   // Define your app's theme settings
//   ThemeData get lightTheme => ThemeData(
//     primaryColor: const Color(0xFF0F1C2E),
//     scaffoldBackgroundColor: Colors.white,
//     appBarTheme: const AppBarTheme(
//       backgroundColor: Colors.white,
//       foregroundColor: Colors.black,
//       elevation: 0,
//     ),
//     cardColor: Colors.white,
//     colorScheme: const ColorScheme.light(
//       primary: Color(0xFF0F1C2E),
//       secondary: Color(0xFF1E2C3D),
//     ),
//     iconTheme: const IconThemeData(color: Colors.black),
//     textTheme: TextTheme(
//       titleLarge: TextStyle(color: Colors.black, fontSize: 18 * _textSize),
//       titleMedium: TextStyle(color: Colors.black, fontSize: 16 * _textSize),
//       bodyLarge: TextStyle(color: Colors.black, fontSize: 16 * _textSize),
//       bodyMedium: TextStyle(color: Colors.black, fontSize: 14 * _textSize),
//     ),
//   );

//   ThemeData get darkTheme => ThemeData(
//     primaryColor: const Color(0xFF0F1C2E),
//     scaffoldBackgroundColor: const Color(0xFF0D1B2A),
//     appBarTheme: const AppBarTheme(
//       backgroundColor: Color(0xFF0D1B2A),
//       foregroundColor: Colors.white,
//       elevation: 0,
//     ),
//     cardColor: const Color(0xFF1E2C3D),
//     colorScheme: const ColorScheme.dark(
//       primary: Color(0xFF0F1C2E),
//       secondary: Color(0xFF1E2C3D),
//     ),
//     iconTheme: const IconThemeData(color: Colors.white),
//     textTheme: TextTheme(
//       titleLarge: TextStyle(color: Colors.white, fontSize: 18 * _textSize),
//       titleMedium: TextStyle(color: Colors.white, fontSize: 16 * _textSize),
//       bodyLarge: TextStyle(color: Colors.white, fontSize: 16 * _textSize),
//       bodyMedium: TextStyle(color: Colors.white, fontSize: 14 * _textSize),
//     ),
//   );
// }
