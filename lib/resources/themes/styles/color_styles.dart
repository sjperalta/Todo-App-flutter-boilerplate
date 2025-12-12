import 'package:nylo_framework/nylo_framework.dart';

/// Interface for your base styles.
/// Add more styles here and then implement in
/// light_theme_colors.dart and dark_theme_colors.dart.

abstract class ColorStyles extends BaseColorStyles {
  /// Available styles

  // general
  @override
  Color get background;
  @override
  Color get content;
  @override
  Color get primaryAccent;

  @override
  Color get surfaceBackground;
  @override
  Color get surfaceContent;

  // app bar
  @override
  Color get appBarBackground;
  @override
  Color get appBarPrimaryContent;

  @override
  Color get buttonBackground;
  @override
  Color get buttonContent;

  @override
  Color get buttonSecondaryBackground;
  @override
  Color get buttonSecondaryContent;

  // bottom tab bar
  @override
  Color get bottomTabBarBackground;

  // bottom tab bar - icons
  @override
  Color get bottomTabBarIconSelected;
  @override
  Color get bottomTabBarIconUnselected;

  // bottom tab bar - label
  @override
  Color get bottomTabBarLabelUnselected;
  @override
  Color get bottomTabBarLabelSelected;

  // toast notification
  Color get toastNotificationBackground;

  // TaskFlow specific colors
  Color get cardBackground;
  Color get cardShadow;
  Color get inputBackground;
  Color get inputBorder;
  Color get inputFocusedBorder;
  Color get dividerColor;
  Color get successColor;
  Color get warningColor;
  Color get errorColor;
  Color get infoColor;
  
  // Category colors
  Color get categoryPersonal;
  Color get categoryWork;
  Color get categoryShopping;
  Color get categoryHealth;
  
  // Priority colors
  Color get priorityLow;
  Color get priorityMedium;
  Color get priorityHigh;
  
  // Task status colors
  Color get taskCompleted;
  Color get taskPending;
  Color get taskOverdue;
}
