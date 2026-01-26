import 'package:flutter/material.dart';

/// Centralized UI constants for the btluBook Store app.
/// Defines colors, gradients, spacing, shadows, and animation durations.
class UiConst {
  // ============================================
  // BRAND COLORS
  // ============================================
  
  /// Primary brand colors
  static const Color ink = Color(0xFF0D1B2A);       // Deep dark blue
  static const Color slate = Color(0xFF233542);     // Medium dark blue
  static const Color leather = Color(0xFF3A2F2A);   // Warm brown
  
  /// Accent colors
  static const Color amber = Color(0xFFF2C94C);     // Primary accent (gold)
  static const Color brandAccent = Color(0xFFD4A373); // Secondary accent (bronze)
  static const Color sage = Color(0xFFA1E3B5);      // Success/positive
  static const Color parchment = Color(0xFFD9CBAA); // Neutral warm
  
  /// Semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF2196F3);
  
  /// Surface colors (for glassmorphism)
  static const Color glassFill = Color(0x1AFFFFFF);       // 10% white
  static const Color glassBorder = Color(0x38FFFFFF);     // 22% white
  static const Color glassHighlight = Color(0x4DFFFFFF);  // 30% white
  
  // ============================================
  // GRADIENTS
  // ============================================
  
  /// Background gradient colors
  static const List<Color> gradientBackground = [ink, slate, leather];
  static const List<double> gradientStops = [0.0, 0.5, 1.0];
  
  /// Brand gradient (for buttons, accents)
  static const List<Color> brandGradient = [amber, brandAccent];
  
  /// Text gradient (for headings)
  static const List<Color> brandTextGradient = [
    Colors.white,
    Color(0xFFFFF1CC),
    amber,
  ];
  
  /// Glow colors for decorative circles
  static const Color glowAmber = Color(0xFFF2C94C);
  static const Color glowSage = Color(0xFFA1E3B5);
  static const Color glowParchment = Color(0xFFD9CBAA);
  
  // Legacy compatibility
  static final List<Color> colors = [ink, slate, leather];
  
  // ============================================
  // SPACING SCALE
  // ============================================
  
  static const double spacing2 = 2.0;
  static const double spacing4 = 4.0;
  static const double spacing6 = 6.0;
  static const double spacing8 = 8.0;
  static const double spacing10 = 10.0;
  static const double spacing12 = 12.0;
  static const double spacing14 = 14.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;
  
  // ============================================
  // BORDER RADIUS
  // ============================================
  
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 14.0;
  static const double radiusLarge = 18.0;
  static const double radiusXLarge = 24.0;
  static const double radiusRound = 999.0;
  
  // ============================================
  // BLUR SIGMA (for glassmorphism)
  // ============================================
  
  static const double blurLight = 12.0;
  static const double blurMedium = 18.0;
  static const double blurHeavy = 26.0;
  
  // ============================================
  // ANIMATION DURATIONS
  // ============================================
  
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationMedium = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Duration durationBackground = Duration(seconds: 8);
  
  // ============================================
  // SHADOWS
  // ============================================
  
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.14),
      blurRadius: 20,
      spreadRadius: 2,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: amber.withOpacity(0.35),
      blurRadius: 24,
      spreadRadius: 2,
    ),
  ];
  
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.18),
      blurRadius: 30,
      spreadRadius: 4,
      offset: const Offset(0, 10),
    ),
  ];
  
  // ============================================
  // INPUT DECORATION HELPER
  // ============================================
  
  static InputDecoration glassInputDecoration({
    required String hint,
    IconData? icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: Colors.white70) : null,
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withOpacity(0.10),
      hintStyle: const TextStyle(color: Colors.white70),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: amber, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: error),
      ),
    );
  }
}