import 'package:flutter/material.dart';

/* Default text theme
|-------------------------------------------------------------------------- */

const TextTheme defaultTextTheme = TextTheme(
  // Display styles - for large, prominent text
  displayLarge: TextStyle(
    fontSize: 36.0,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.5,
  ),
  displayMedium: TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
  ),
  displaySmall: TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  ),
  
  // Headline styles - for section headers
  headlineLarge: TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  ),
  headlineMedium: TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  ),
  headlineSmall: TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  ),
  
  // Title styles - for card titles, app bar titles
  titleLarge: TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  ),
  titleMedium: TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  ),
  titleSmall: TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  ),
  
  // Body styles - for main content
  bodyLarge: TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
  ),
  bodyMedium: TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  ),
  bodySmall: TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  ),
  
  // Label styles - for buttons, chips, captions
  labelLarge: TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  ),
  labelMedium: TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  ),
  labelSmall: TextStyle(
    fontSize: 10.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  ),
);
