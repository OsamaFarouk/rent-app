import 'package:flutter/material.dart';

/// Centralized application constants for Rent App.
abstract class AppConstants {
  static const String appName = 'Rent App';
  static const String appTagline = 'Discover. Connect. Create.';
  static const String appSubhead =
      'The discovery marketplace for film, media & production.';

  // Locales
  static const Locale enLocale = Locale('en');
  static const Locale arLocale = Locale('ar');
  static const List<Locale> supportedLocales = [
    enLocale,
    arLocale,
  ];

  // Design Dimensions
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
}
