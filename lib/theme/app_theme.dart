import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// LIVE IT — BY AZAM Global Design System Colors & Theme
/// Strict 90% Black / 10% Red aesthetic.
class AppColors {
  // Foundations
  static const Color background = Color(0xFF050505);
  static const Color surface = Color(0xFF0D0D0D);
  static const Color card = Color(0xFF151515);
  static const Color cardElevated = Color(0xFF1C1C1C);

  // Red Accents (Reserved for meaningful emphasis, active states, signature glow)
  static const Color primaryRed = Color(0xFFE50914);
  static const Color brightRed = Color(0xFFFF1018);
  static const Color darkRed = Color(0xFF720006);
  static const Color glowPrimary = Color(0xFFFF1018);

  // Typography & Content
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFA0A0A0);
  static const Color tertiaryText = Color(0xFF707070);
  static const Color divider = Color(0xFF252525);

  // Subtle Red Glows
  static const Color redGlow = Color(0x33FF1018);
  static const Color redGlowIntense = Color(0x66FF1018);

  // Shimmer / Skeleton
  static const Color shimmerBase = Color(0xFF151515);
  static const Color shimmerHighlight = Color(0xFF222222);
}

/// Standardized Border Radii Tokens
class AppRadii {
  static final BorderRadius r6 = BorderRadius.circular(6);
  static final BorderRadius r8 = BorderRadius.circular(8);
  static final BorderRadius r12 = BorderRadius.circular(12);
  static final BorderRadius r16 = BorderRadius.circular(16);
  static final BorderRadius r20 = BorderRadius.circular(20);
  static final BorderRadius r24 = BorderRadius.circular(24);
  static final BorderRadius circular = BorderRadius.circular(999);
}

/// Standardized Shadow & Glow Tokens
class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 3)),
  ];

  static const List<BoxShadow> subtleRedGlow = [
    BoxShadow(
      color: AppColors.redGlow,
      blurRadius: 10,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> intenseRedGlow = [
    BoxShadow(
      color: AppColors.redGlowIntense,
      blurRadius: 16,
      spreadRadius: 1,
      offset: Offset(0, 0),
    ),
  ];
}

/// Standardized Typography Hierarchy
class AppTypography {
  static const TextStyle brandTitle = TextStyle(
    color: AppColors.primaryText,
    fontSize: 22,
    fontWeight: FontWeight.w900,
    letterSpacing: 2.0,
  );

  static const TextStyle brandSubtitle = TextStyle(
    color: AppColors.brightRed,
    fontSize: 10,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.8,
  );

  static const TextStyle headingLarge = TextStyle(
    color: AppColors.primaryText,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  static const TextStyle headingMedium = TextStyle(
    color: AppColors.primaryText,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle headingSmall = TextStyle(
    color: AppColors.primaryText,
    fontSize: 15,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.0,
  );

  static const TextStyle titleMedium = TextStyle(
    color: AppColors.primaryText,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyMedium = TextStyle(
    color: AppColors.secondaryText,
    fontSize: 13,
  );

  static const TextStyle bodySmall = TextStyle(
    color: AppColors.secondaryText,
    fontSize: 12,
  );

  static const TextStyle caption = TextStyle(
    color: AppColors.tertiaryText,
    fontSize: 11,
  );
}

/// Safe Haptic Feedback Helper
class LiveItHaptics {
  static void light() {
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }

  static void medium() {
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  static void selection() {
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
  }
}

/// Responsive, subtle slide-and-fade page transition
class LiveItPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  LiveItPageRoute({required this.child, super.settings})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionDuration: const Duration(milliseconds: 260),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.04, 0.0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      );
}

/// Immersive bottom-sheet style or full-screen scale page transition
class LiveItScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  LiveItScalePageRoute({required this.child, super.settings})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 240),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      );
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
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.brightRed,
        unselectedItemColor: AppColors.secondaryText,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.divider),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brightRed,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryText,
          side: const BorderSide(color: AppColors.divider),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
      ),
    );
  }
}
