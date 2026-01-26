import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/const/ui_const.dart';
import '../../core/const/app_typography.dart';

/// Theme state
enum AppThemeMode { dark, light }

/// Theme events
abstract class ThemeEvent {}

class ToggleTheme extends ThemeEvent {}

class SetTheme extends ThemeEvent {
  final AppThemeMode mode;
  SetTheme(this.mode);
}

class LoadTheme extends ThemeEvent {}

/// Theme BLoC
class ThemeBloc extends Bloc<ThemeEvent, AppThemeMode> {
  static const String _themeKey = 'app_theme_mode';

  ThemeBloc() : super(AppThemeMode.dark) {
    on<LoadTheme>(_onLoadTheme);
    on<ToggleTheme>(_onToggleTheme);
    on<SetTheme>(_onSetTheme);
  }

  Future<void> _onLoadTheme(LoadTheme event, Emitter<AppThemeMode> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themeKey);
    if (themeString == 'light') {
      emit(AppThemeMode.light);
    } else {
      emit(AppThemeMode.dark);
    }
  }

  Future<void> _onToggleTheme(ToggleTheme event, Emitter<AppThemeMode> emit) async {
    final newMode = state == AppThemeMode.dark ? AppThemeMode.light : AppThemeMode.dark;
    await _saveTheme(newMode);
    emit(newMode);
  }

  Future<void> _onSetTheme(SetTheme event, Emitter<AppThemeMode> emit) async {
    await _saveTheme(event.mode);
    emit(event.mode);
  }

  Future<void> _saveTheme(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode == AppThemeMode.light ? 'light' : 'dark');
  }
}

/// App theme data provider
class AppTheme {
  // ============================================
  // DARK THEME
  // ============================================
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: UiConst.ink,
      textTheme: AppTypography.textTheme,
      colorScheme: ColorScheme.dark(
        primary: UiConst.amber,
        secondary: UiConst.brandAccent,
        surface: UiConst.slate,
        error: UiConst.error,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: UiConst.slate,
        contentTextStyle: AppTypography.bodyMedium,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiConst.radiusMedium),
        ),
      ),
      cardTheme: CardTheme(
        color: UiConst.slate,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiConst.radiusMedium),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: UiConst.slate,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiConst.radiusLarge),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: UiConst.amber,
        unselectedItemColor: Colors.white60,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.10),
        hintStyle: AppTypography.hint,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiConst.radiusMedium),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiConst.radiusMedium),
          borderSide: const BorderSide(color: UiConst.amber, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiConst.radiusMedium),
          borderSide: const BorderSide(color: UiConst.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiConst.radiusMedium),
          borderSide: const BorderSide(color: UiConst.error),
        ),
      ),
    );
  }

  // ============================================
  // LIGHT THEME
  // ============================================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: LightColors.background,
      textTheme: _lightTextTheme,
      colorScheme: ColorScheme.light(
        primary: LightColors.primary,
        secondary: LightColors.secondary,
        surface: LightColors.surface,
        error: UiConst.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: LightColors.textPrimary,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: LightColors.surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: LightColors.textPrimary),
        titleTextStyle: TextStyle(
          color: LightColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: LightColors.surface,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: LightColors.textPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiConst.radiusMedium),
        ),
      ),
      cardTheme: CardTheme(
        color: LightColors.surface,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiConst.radiusMedium),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: LightColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiConst.radiusLarge),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: LightColors.surface,
        selectedItemColor: LightColors.primary,
        unselectedItemColor: LightColors.textSecondary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LightColors.inputFill,
        hintStyle: AppTypography.hint.copyWith(
          color: LightColors.textSecondary,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiConst.radiusMedium),
          borderSide: BorderSide(color: LightColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiConst.radiusMedium),
          borderSide: BorderSide(color: LightColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiConst.radiusMedium),
          borderSide: const BorderSide(color: UiConst.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiConst.radiusMedium),
          borderSide: const BorderSide(color: UiConst.error),
        ),
      ),
    );
  }

  static TextTheme get _lightTextTheme {
    return AppTypography.textTheme.apply(
      bodyColor: LightColors.textPrimary,
      displayColor: LightColors.textPrimary,
    );
  }
}

/// Light mode specific colors
class LightColors {
  // Backgrounds
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color inputFill = Color(0xFFF1F3F5);
  
  // Primary brand colors (adjusted for light mode)
  static const Color primary = Color(0xFFD4A373);
  static const Color secondary = Color(0xFFB8860B);
  
  // Text colors
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textTertiary = Color(0xFF9CA3AF);
  
  // Borders
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderFocused = Color(0xFFD4A373);
  
  // Cards & Glassmorphism adjustments
  static const Color cardBorder = Color(0xFFE5E7EB);
  static const Color glassFill = Color(0x80FFFFFF);
  
  // Gradient for light mode
  static const List<Color> gradientBackground = [
    Color(0xFFFFFBF5),
    Color(0xFFF5F0EB),
    Color(0xFFEDE6DF),
  ];
}
