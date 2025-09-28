import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: Color(0xFF0D47A1),
    colorScheme: ColorScheme.light(
      primary: Color(0xFF0D47A1),
      secondary: Color(0xFFD32F2F),
      surface: Color(0xFFF5F5F5),
    ),
    scaffoldBackgroundColor: Color(0xFFF5F5F5),
    textTheme: TextTheme(bodyMedium: TextStyle(color: Color(0xFF212121))),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF0D47A1),
      foregroundColor: Colors.white,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color(0xFFFFFFFF),
      elevation: 8,
      selectedItemColor: Color(0xFF0D47A1),
      unselectedItemColor: Color(0xFF757575),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
    ),
  );
}
