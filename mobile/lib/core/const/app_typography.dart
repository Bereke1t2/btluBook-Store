import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App typography using Google Fonts.
/// Uses Poppins for display/headlines and Inter for body text.
class AppTypography {
  // ============================================
  // FONT FAMILIES
  // ============================================
  
  static String get displayFamily => GoogleFonts.poppins().fontFamily!;
  static String get bodyFamily => GoogleFonts.inter().fontFamily!;
  
  // ============================================
  // DISPLAY STYLES (Large headers, splash screens)
  // ============================================
  
  static TextStyle displayLarge = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.2,
    color: Colors.white,
  );
  
  static TextStyle displayMedium = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.2,
    color: Colors.white,
  );
  
  static TextStyle displaySmall = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.25,
    color: Colors.white,
  );
  
  // ============================================
  // HEADLINE STYLES (Section headers, card titles)
  // ============================================
  
  static TextStyle headlineLarge = GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.3,
    color: Colors.white,
  );
  
  static TextStyle headlineMedium = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.15,
    height: 1.3,
    color: Colors.white,
  );
  
  static TextStyle headlineSmall = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.35,
    color: Colors.white,
  );
  
  // ============================================
  // TITLE STYLES (Emphasized content titles)
  // ============================================
  
  static TextStyle titleLarge = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.35,
    color: Colors.white,
  );
  
  static TextStyle titleMedium = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
    color: Colors.white,
  );
  
  static TextStyle titleSmall = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
    color: Colors.white,
  );
  
  // ============================================
  // BODY STYLES (Main content, paragraphs)
  // ============================================
  
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.5,
    color: Colors.white,
  );
  
  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.5,
    color: Colors.white,
  );
  
  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.5,
    color: Colors.white70,
  );
  
  // ============================================
  // LABEL STYLES (Buttons, chips, captions)
  // ============================================
  
  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
    height: 1.4,
    color: Colors.white,
  );
  
  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.4,
    color: Colors.white,
  );
  
  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.4,
    color: Colors.white70,
  );
  
  // ============================================
  // SPECIAL STYLES
  // ============================================
  
  /// Price tag style with amber color
  static TextStyle price = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: const Color(0xFFF2C94C),
  );
  
  /// Large price for detail pages
  static TextStyle priceLarge = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: const Color(0xFFF2C94C),
  );
  
  /// Rating text
  static TextStyle rating = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  
  /// Button text
  static TextStyle button = GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );
  
  /// Hint/placeholder text
  static TextStyle hint = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.white70,
  );
  
  // ============================================
  // HELPER METHOD
  // ============================================
  
  /// Get text theme for MaterialApp
  static TextTheme get textTheme => TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}
