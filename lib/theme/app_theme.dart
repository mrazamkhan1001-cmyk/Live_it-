import 'package:flutter/material.dart';

/// LIVE IT — BY AZAM Global Design System Colors & Theme
class AppColors {
  static const Color background = Color(0xFF050505);
  static const Color surface = Color(0xFF0D0D0D);
  static const Color card = Color(0xFF151515);

  static const Color primaryRed = Color(0xFFE50914);
  static const Color brightRed = Color(0xFFFF1018);
  static const Color darkRed = Color(0xFF720006);
  static const Color glowPrimary = Color(0xFFFF1018);

  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFA0A0A0);
  static const Color divider = Color(0xFF252525);

  static const Color redGlow = Color(0x44FF1018);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.brightRed,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.brightRed,
        secondary: AppColors.primaryRed,
        surface: AppColors.surface,
        onSurface: AppColors.primaryText,
      ),
      cardColor: AppColors.card,
      dividerColor: AppColors.divider,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.primaryText),
        titleTextStyle: TextStyle(
          color: AppColors.primaryText,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.brightRed,
        unselectedItemColor: AppColors.secondaryText,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
