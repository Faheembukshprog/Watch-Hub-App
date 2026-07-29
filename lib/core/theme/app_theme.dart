import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Luxury Gold Accents
  static const Color goldAccent = Color(0xFFD4AF37); // Champagne Gold
  static const Color goldLight = Color(0xFFE5C158);

  // Dark Palette (Obsidian Luxury)
  static const Color darkBg = Color(0xFF0F1115); // Obsidian Coal
  static const Color darkSurface = Color(0xFF181B22); // Dark Charcoal
  static const Color darkSurfaceCard = Color(0xFF20242D); // Lighter Charcoal
  static const Color darkBorder = Color(0xFF2A2E39); // Micro-borders
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFFA0A5B5); // Muted Silver

  // Light Palette (Slate Royal)
  static const Color lightBg = Color(0xFFF8F9FA); // Soft Grey
  static const Color lightSurface = Colors.white;
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A); // Slate Midnight
  static const Color lightTextSecondary = Color(0xFF64748B); // Slate Grey

  /// Luxury Obsidian Dark Theme definition
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: goldAccent,
      scaffoldBackgroundColor: darkBg,
      cardColor: darkSurface,
      dividerColor: darkBorder,
      colorScheme: const ColorScheme.dark(
        primary: goldAccent,
        secondary: goldLight,
        surface: darkSurface,
        error: Colors.redAccent,
        onPrimary: darkBg,
        onSecondary: darkBg,
        onSurface: darkTextPrimary,
        surfaceContainerHighest: darkSurfaceCard,
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.outfit(
          color: darkTextPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
        ),
        headlineMedium: GoogleFonts.outfit(
          color: darkTextPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
        titleLarge: GoogleFonts.outfit(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
        bodyLarge: GoogleFonts.inter(
          color: darkTextPrimary,
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          color: darkTextSecondary,
          fontSize: 14,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.outfit(
          color: goldAccent,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldAccent,
          foregroundColor: darkBg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: goldAccent,
          side: const BorderSide(color: goldAccent, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        hintStyle: const TextStyle(color: darkTextSecondary, fontSize: 14),
        labelStyle: const TextStyle(color: darkTextSecondary, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: goldAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: goldAccent,
        unselectedItemColor: darkTextSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkSurface,
        indicatorColor: goldAccent.withValues(alpha: 0.15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.outfit(
              color: goldAccent,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            );
          }
          return GoogleFonts.outfit(
            color: darkTextSecondary,
            fontSize: 12,
            letterSpacing: 0.5,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: goldAccent, size: 24);
          }
          return const IconThemeData(color: darkTextSecondary, size: 24);
        }),
      ),
    );
  }

  /// Luxury Slate Royal Light Theme definition
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: goldAccent,
      scaffoldBackgroundColor: lightBg,
      cardColor: lightSurface,
      dividerColor: lightBorder,
      colorScheme: const ColorScheme.light(
        primary: goldAccent,
        secondary: goldAccent,
        surface: lightSurface,
        error: Colors.redAccent,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightTextPrimary,
        surfaceContainerHighest: Color(0xFFF1F5F9),
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.outfit(
          color: lightTextPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
        ),
        headlineMedium: GoogleFonts.outfit(
          color: lightTextPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
        titleLarge: GoogleFonts.outfit(
          color: lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
        bodyLarge: GoogleFonts.inter(
          color: lightTextPrimary,
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          color: lightTextSecondary,
          fontSize: 14,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.outfit(
          color: goldAccent,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBg,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: lightTextPrimary),
        titleTextStyle: TextStyle(
          color: lightTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: goldAccent,
          side: const BorderSide(color: goldAccent, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        hintStyle: const TextStyle(color: lightTextSecondary, fontSize: 14),
        labelStyle: const TextStyle(color: lightTextSecondary, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: goldAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightSurface,
        selectedItemColor: goldAccent,
        unselectedItemColor: lightTextSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: lightSurface,
        indicatorColor: goldAccent.withValues(alpha: 0.1),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.outfit(
              color: goldAccent,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            );
          }
          return GoogleFonts.outfit(
            color: lightTextSecondary,
            fontSize: 12,
            letterSpacing: 0.5,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: goldAccent, size: 24);
          }
          return const IconThemeData(color: lightTextSecondary, size: 24);
        }),
      ),
    );
  }
}
