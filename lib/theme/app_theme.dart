import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors - Premium Fintech Palette
  static const Color deepNavy = Color(0xFF101828); // Rich dark text
  static const Color primaryBlue = Color(0xFF2A0F5B); // Trust/Link color (Deep Purple/Navy)
  static const Color vibrantEmerald = Color(0xFF039855); // Success/Savings (Slightly deeper/richer than neon)
  static const Color accentOrange = Color(0xFFFF6A00); // High-impact CTA (Vibrant Orange)
  static const Color offWhite = Color(0xFFF4F6F8); // Cool grey background
  
  // Glass/Card Colors
  static const Color glassWhite = Color(0xFFFFFFFF); // Solid white for cards (Cleaner look)
  static const Color glassBorder = Color(0xFFEAECF0); // Subtle border

  // Gradient for background - Subtle top-down fade
  static const LinearGradient mainBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.white,
      offWhite,
    ],
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: offWhite,
      primaryColor: primaryBlue,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: vibrantEmerald,
        tertiary: accentOrange,
        surface: Colors.white,
        background: offWhite,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: deepNavy,
      ),
      textTheme: GoogleFonts.latoTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.lato(
          color: deepNavy, fontWeight: FontWeight.w900, letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.lato(
          color: deepNavy, fontWeight: FontWeight.w800, letterSpacing: -0.5,
        ),
        bodyLarge: GoogleFonts.lato(
          color: deepNavy, fontSize: 16, height: 1.5,
        ),
        bodyMedium: GoogleFonts.lato(
          color: Color(0xFF475467), // Slate 600 for secondary text
          fontSize: 14, 
          height: 1.5,
        ),
      ).apply(
        bodyColor: deepNavy,
        displayColor: deepNavy,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentOrange, // Primary Action is Orange
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100), // Pill shape
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD)), // Slate 300
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accentOrange, width: 2),
        ),
        labelStyle: const TextStyle(color: Color(0xFF667085)), // Slate 500
      ),
    );
  }
}
