import 'package:flutter/material.dart';

class UiConst {
  static final colors = [
      Color(0xFF0D1B2A), // ink
      Color(0xFF233542), // slate
      Color(0xFF3A2F2A), // leather
    ]; 
  static const ink = Color(0xFF0D1B2A);
  static const slate = Color(0xFF233542);
  static const leather = Color(0xFF3A2F2A);

  static const amber = Color(0xFFF2C94C);
  static const brandAccent = Color(0xFFD4A373);
  static const sage = Color(0xFFA1E3B5);
  static const parchment = Color(0xFFD9CBAA);

  static const gradientBackground = [ink, slate, leather];
  static const brandGradient = [amber, brandAccent];
  static const brandTextGradient = [Colors.white, Color(0xFFFFF1CC), amber];

}