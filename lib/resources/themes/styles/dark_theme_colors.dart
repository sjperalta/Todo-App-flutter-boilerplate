import 'package:flutter/material.dart';
import '/resources/themes/styles/color_styles.dart';

/* Dark Theme Colors
|-------------------------------------------------------------------------- */

class DarkThemeColors implements ColorStyles {
  // general
  @override
  Color get background => const Color(0xff161c20);

  @override
  Color get content => const Color(0xFFE1E1E1);
  @override
  Color get primaryAccent => const Color(0xFF32C7AE);

  @override
  Color get surfaceBackground => Colors.white70;
  @override
  Color get surfaceContent => Colors.black;

  // app bar
  @override
  Color get appBarBackground => const Color(0xff2a343c);
  @override
  Color get appBarPrimaryContent => Colors.white;

  // buttons
  @override
  Color get buttonBackground => const Color(0xffd8d8d8);
  @override
  Color get buttonContent => Colors.black87;

  @override
  Color get buttonSecondaryBackground => Colors.grey.shade800;
  @override
  Color get buttonSecondaryContent => Colors.white70;

  // bottom tab bar
  @override
  Color get bottomTabBarBackground => const Color(0xFF232c33);

  // bottom tab bar - icons
  @override
  Color get bottomTabBarIconSelected => Colors.white70;
  @override
  Color get bottomTabBarIconUnselected => Colors.white60;

  // bottom tab bar - label
  @override
  Color get bottomTabBarLabelUnselected => Colors.white54;
  @override
  Color get bottomTabBarLabelSelected => Colors.white;

  // toast notification
  @override
  Color get toastNotificationBackground => const Color(0xff3e4447);

  // TaskFlow specific colors
  @override
  Color get cardBackground => const Color(0xff2a343c);
  
  @override
  Color get cardShadow => Colors.black.withOpacity(0.3);
  
  @override
  Color get inputBackground => const Color(0xff1f2937);
  
  @override
  Color get inputBorder => const Color(0xff374151);
  
  @override
  Color get inputFocusedBorder => const Color(0xFF32C7AE);
  
  @override
  Color get dividerColor => const Color(0xff374151);
  
  @override
  Color get successColor => const Color(0xFF10B981);
  
  @override
  Color get warningColor => const Color(0xFFF59E0B);
  
  @override
  Color get errorColor => const Color(0xFFEF4444);
  
  @override
  Color get infoColor => const Color(0xFF3B82F6);
  
  // Category colors (same as light theme for consistency)
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
  Color get priorityLow => const Color(0xFF9CA3AF); // Light gray
  
  @override
  Color get priorityMedium => const Color(0xFFF59E0B); // Amber
  
  @override
  Color get priorityHigh => const Color(0xFFEF4444); // Red
  
  // Task status colors
  @override
  Color get taskCompleted => const Color(0xFF10B981); // Green
  
  @override
  Color get taskPending => const Color(0xFF9CA3AF); // Light gray
  
  @override
  Color get taskOverdue => const Color(0xFFEF4444); // Red
}
