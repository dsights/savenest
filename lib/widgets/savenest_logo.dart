import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class SaveNestLogo extends StatelessWidget {
  final double fontSize;
  final bool isLight;

  const SaveNestLogo({
    super.key,
    this.fontSize = 24,
    this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isLight ? Colors.white : AppTheme.deepNavy;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // The "Save" part
        Text(
          'Save',
          style: GoogleFonts.montserrat(
            color: primaryColor,
            fontWeight: FontWeight.w900,
            fontSize: fontSize,
            letterSpacing: -1.0,
          ),
        ),
        // The "Nest" part styled as a badge resembling the logo banner
        Container(
          margin: const EdgeInsets.only(left: 2),
          padding: EdgeInsets.symmetric(horizontal: fontSize * 0.3, vertical: fontSize * 0.1),
          decoration: BoxDecoration(
            color: AppTheme.vibrantEmerald,
            borderRadius: BorderRadius.circular(fontSize * 0.2),
            boxShadow: [
              BoxShadow(
                color: AppTheme.vibrantEmerald.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                'Nest',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: fontSize,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.bolt,
                color: AppTheme.accentOrange,
                size: fontSize * 0.8,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
