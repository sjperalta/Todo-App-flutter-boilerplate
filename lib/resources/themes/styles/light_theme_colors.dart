import 'package:flutter/material.dart';
import '/resources/themes/styles/color_styles.dart';

/* Light Theme Colors
|-------------------------------------------------------------------------- */

class LightThemeColors implements ColorStyles {
  // general
  @override
  Color get background => const Color(0xFFFFFFFF);

  @override
  Color get content => const Color(0xFF000000);
  @override
  Color get primaryAccent => const Color(0xFF32C7AE);

  @override
  Color get surfaceBackground => Colors.white;
  @override
  Color get surfaceContent => Colors.black;

  // app bar
  @override
  Color get appBarBackground => const Color(0xFF32C7AE);
  @override
  Color get appBarPrimaryContent => Colors.white;

  // buttons
  @override
  Color get buttonBackground => const Color(0xFF32C7AE);
  @override
  Color get buttonContent => Colors.white;

  @override
  Color get buttonSecondaryBackground => const Color(0xff151925);
  @override
  Color get buttonSecondaryContent =>
      Colors.white.withAlpha((255.0 * 0.9).round());

  // bottom tab bar
  @override
  Color get bottomTabBarBackground => Colors.white;

  // bottom tab bar - icons
  @override
  Color get bottomTabBarIconSelected => const Color(0xFF32C7AE);
  @override
  Color get bottomTabBarIconUnselected => Colors.black54;

  // bottom tab bar - label
  @override
  Color get bottomTabBarLabelUnselected => Colors.black45;
  @override
  Color get bottomTabBarLabelSelected => Colors.black;

  // toast notification
  @override
  Color get toastNotificationBackground => Colors.white;

  // TaskFlow specific colors
  @override
  Color get cardBackground => Colors.white;
  
  @override
  Color get cardShadow => Colors.black.withOpacity(0.08);
  
  @override
  Color get inputBackground => const Color(0xFFF8F9FA);
  
  @override
  Color get inputBorder => const Color(0xFFE9ECEF);
  
  @override
  Color get inputFocusedBorder => const Color(0xFF32C7AE);
  
  @override
  Color get dividerColor => const Color(0xFFE9ECEF);
  
  @override
  Color get successColor => const Color(0xFF10B981);
  
  @override
  Color get warningColor => const Color(0xFFF59E0B);
  
  @override
  Color get errorColor => const Color(0xFFEF4444);
  
  @override
  Color get infoColor => const Color(0xFF3B82F6);
  
  // Category colors
  @override
  Color get categoryPersonal => const Color(0xFF32C7AE); // Mint green
  
  @override
  Color get categoryWork => const Color(0xFF8B5CF6); // Purple
  
  @override
  Color get categoryShopping => const Color(0xFFF97316); // Orange
  
  @override
  Color get categoryHealth => const Color(0xFF10B981); // Green
  
  // Priority colors
  @override
  Color get priorityLow => const Color(0xFF6B7280); // Gray
  
  @override
  Color get priorityMedium => const Color(0xFFF59E0B); // Amber
  
  @override
  Color get priorityHigh => const Color(0xFFEF4444); // Red
  
  // Task status colors
  @override
  Color get taskCompleted => const Color(0xFF10B981); // Green
  
  @override
  Color get taskPending => const Color(0xFF6B7280); // Gray
  
  @override
  Color get taskOverdue => const Color(0xFFEF4444); // Red
}
