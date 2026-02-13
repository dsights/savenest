import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.unknown,
      };
}

class AppTheme {
  // Brand Colors - iSelect inspired but unique
  static const Color deepNavy = Color(0xFF002A54); // Very dark blue for primary contrast
  static const Color primaryBlue = Color(0xFF005696); // iSelect-ish Blue
  static const Color vibrantEmerald = Color(0xFF00A3AD); // Teal/Emerald accent
  static const Color accentOrange = Color(0xFFFF7900); // iSelect Vibrant Orange
  static const Color offWhite = Color(0xFFF8F9FA); // Very light grey background
  static const Color slate600 = Color(0xFF475467);
  static const Color slate300 = Color(0xFFD0D5DD);

  // Glass/Card Colors
  static const Color glassWhite = Colors.white;
  static const Color glassBorder = Color(0xFFEAECF0);

  // Gradient for background
  static const LinearGradient mainBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.white,
      offWhite,
    ],
  );

  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.montserratTextTheme(ThemeData.light().textTheme);
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: offWhite,
      primaryColor: primaryBlue,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: accentOrange,
        tertiary: vibrantEmerald,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: deepNavy,
      ),
      textTheme: textTheme.copyWith(
        displayLarge: GoogleFonts.montserrat(
          color: deepNavy, fontWeight: FontWeight.w800, letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.montserrat(
          color: deepNavy, fontWeight: FontWeight.w700, letterSpacing: -0.5,
        ),
        displaySmall: GoogleFonts.montserrat(
          color: deepNavy, fontWeight: FontWeight.w700,
        ),
        headlineMedium: GoogleFonts.montserrat(
          color: deepNavy, fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.montserrat(
          color: deepNavy, fontSize: 16, height: 1.6, fontWeight: FontWeight.w500,
        ),
        bodyMedium: GoogleFonts.montserrat(
          color: slate600, fontSize: 14, height: 1.6,
        ),
        labelLarge: GoogleFonts.montserrat(
          color: deepNavy, fontWeight: FontWeight.w600, fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentOrange,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: accentOrange.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Less rounded, more modern
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          textStyle: GoogleFonts.montserrat(
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
          borderSide: const BorderSide(color: slate300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: slate300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accentOrange, width: 2),
        ),
        labelStyle: const TextStyle(color: slate600),
      ),
    );
  }
}
