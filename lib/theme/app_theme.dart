import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color deepNavy = Color(0xFF0A0E21); // Kept as primary text/contrast color
  static const Color vibrantEmerald = Color(0xFF00E676);
  static const Color offWhite = Color(0xFFF5F7FA);
  
  // Glass Effect Colors (Adjusted for Light Theme)
  static const Color glassWhite = Color(0xCCFFFFFF); // 80% opacity white
  static const Color glassBorder = Color(0xFFE0E0E0); // Light grey border

  // Gradient for background (Light Theme)
  static const LinearGradient mainBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      offWhite,
      Color(0xFFFFFFFF),
    ],
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: offWhite,
      primaryColor: deepNavy,
      colorScheme: const ColorScheme.light(
        primary: deepNavy,
        secondary: vibrantEmerald,
        surface: offWhite,
        onPrimary: Colors.white,
        onSecondary: deepNavy,
        onSurface: deepNavy,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: deepNavy,
        displayColor: deepNavy,
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
