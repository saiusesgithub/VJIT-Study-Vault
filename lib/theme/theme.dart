import 'package:flutter/material.dart';

class AppTheme {
  static const gradientStart = Color(0xFF1A237E);
  static const gradientMiddle = Color(0xFF0D47A1);
  static const gradientEnd = Color(0xFF00838F);

  static ThemeData lightTheme = ThemeData(
    primaryColor: Color(0xFF0D47A1),
    colorScheme: ColorScheme.light(
      primary: Color(0xFF0D47A1),
      secondary: Color(0xFF00838F),
      surface: Color(0xFFF5F5F5),
    ),
    scaffoldBackgroundColor: Colors.transparent,
    textTheme: TextTheme(bodyMedium: TextStyle(color: Color(0xFF212121))),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white.withOpacity(0.9),
      elevation: 12,
      selectedItemColor: Color(0xFF0D47A1),
      unselectedItemColor: Color(0xFF757575),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
    ),
  );
  static Widget gradientBackground({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradientStart, gradientMiddle, gradientEnd],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }
}
