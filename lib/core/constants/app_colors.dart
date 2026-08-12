import 'package:flutter/material.dart';

/// Centralized luxury palette tokens for WatchHub.
abstract final class AppColors {
  AppColors._();

  // Brand accents
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFE5C158);

  // Dark palette
  static const Color darkBg = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF181B22);
  static const Color darkSurfaceCard = Color(0xFF20242D);
  static const Color darkBorder = Color(0xFF2A2E39);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFFA0A5B5);

  // Light palette
  static const Color lightBg = Color(0xFFF8F9FA);
  static const Color lightSurface = Colors.white;
  static const Color lightSurfaceMuted = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // Semantic
  static const Color error = Colors.redAccent;
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color neutral = Color(0xFF9CA3AF);
  static const Color lightControlTrack = Color(0xFFE5E7EB);

  static Color scaffoldBackground(Brightness brightness) =>
      brightness == Brightness.dark ? darkBg : lightBg;

  static Color primaryText(Brightness brightness) =>
      brightness == Brightness.dark ? darkTextPrimary : lightTextPrimary;

  static Color secondaryText(Brightness brightness) =>
      brightness == Brightness.dark ? darkTextSecondary : lightTextSecondary;

  static Color cardBackground(Brightness brightness) =>
      brightness == Brightness.dark ? darkSurface : lightSurface;

  static Color cardBorder(Brightness brightness) =>
      brightness == Brightness.dark ? darkBorder : lightBorder;
}
