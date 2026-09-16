import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized typography hierarchy for Rent App.
abstract class AppTypography {
  static const TextStyle display = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle heading = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static const TextStyle title = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle secondaryBody = TextStyle(
    fontSize: 13.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static const TextStyle label = TextStyle(
    fontSize: 11.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    letterSpacing: 0.2,
  );

  static const TextStyle button = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Builds standard Flutter TextTheme from design tokens.
  static TextTheme buildTextTheme() {
    return const TextTheme(
      headlineLarge: display,
      headlineMedium: heading,
      titleLarge: sectionTitle,
      titleMedium: title,
      bodyLarge: body,
      bodyMedium: secondaryBody,
      bodySmall: caption,
      labelLarge: button,
      labelSmall: label,
    );
  }
}
