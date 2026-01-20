import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color deepNavy = Color(0xFF0A0E21);
  static const Color vibrantEmerald = Color(0xFF00E676);
  static const Color glassWhite = Color(0x1AFFFFFF); // 10% opacity white
  static const Color glassBorder = Color(0x33FFFFFF); // 20% opacity white

  // Gradient for background
  static const LinearGradient mainBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0A0E21), // Deep Navy
      Color(0xFF111736), // Slightly lighter navy
    ],
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: deepNavy,
      primaryColor: deepNavy,
      colorScheme: const ColorScheme.dark(
        primary: deepNavy,
        secondary: vibrantEmerald,
        surface: deepNavy, // Using deep navy as base, glass cards will go on top
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: vibrantEmerald,
          foregroundColor: deepNavy,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
