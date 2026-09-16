import 'package:flutter/material.dart';

/// Semantic color palette for Rent App matching the dark cinematic visual identity.
abstract class AppColors {
  // Backgrounds & Surfaces
  static const Color background = Color(0xFF0B0B0E);
  static const Color surface = Color(0xFF16161C);
  static const Color surfaceElevated = Color(0xFF1C1C24);
  static const Color surfaceSecondary = Color(0xFF22222C);

  // Brand Primary & Accents
  static const Color primary = Color(0xFFC5A059);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color primarySoft = Color(0xFF2A2417);

  // Typography & Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E9EA8);
  static const Color textMuted = Color(0xFF6E6E78);

  // Legacy Semantic Mappings for backwards compatibility
  static const Color primaryText = textPrimary;
  static const Color secondaryText = textSecondary;
  static const Color tertiaryText = textMuted;

  // Status & Actions
  static const Color success = Color(0xFF22C55E);
  static const Color successGreen = success;
  static const Color whatsappGreen = Color(0xFF25D366);
  static const Color ratingAmber = Color(0xFFF59E0B);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningAmber = warning;
  static const Color error = Color(0xFFEF4444);
  static const Color errorRed = error;

  // Borders & Dividers
  static const Color border = Color(0xFF262632);
  static const Color divider = Color(0xFF20202A);

  // Navigation
  static const Color unselectedNav = Color(0xFF71717A);
  static const Color selectedNav = Color(0xFFD4AF37);
}
