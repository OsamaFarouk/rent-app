import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Dark cinematic Material 3 theme for Rent App.
abstract class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.success,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textPrimary,
      ),
      textTheme: AppTypography.buildTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: AppTypography.title,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0.0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: const BorderSide(color: AppColors.border, width: 1.0),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1.0,
        space: 1.0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.selectedNav,
        unselectedItemColor: AppColors.unselectedNav,
        type: BottomNavigationBarType.fixed,
        elevation: 0.0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceSecondary,
        selectedColor: AppColors.primarySoft,
        disabledColor: AppColors.surface,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        labelStyle: AppTypography.body,
        secondaryLabelStyle: AppTypography.body.copyWith(color: AppColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        hintStyle: AppTypography.body.copyWith(color: AppColors.textMuted),
        prefixIconColor: AppColors.textMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
