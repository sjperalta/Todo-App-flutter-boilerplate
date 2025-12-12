import 'dart:ui';
import 'package:flutter/material.dart';
import '/resources/themes/styles/color_styles.dart';
import 'package:nylo_framework/nylo_framework.dart';

/// Extension methods for easy access to theme colors and styles
extension ThemeExtensions on BuildContext {
  /// Get the current color styles
  ColorStyles get colors => nyColorStyle(this);
  
  /// Get the current text theme
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  /// Get the current theme data
  ThemeData get theme => Theme.of(this);
}

/// TaskFlow specific theme extension
@immutable
class TaskFlowTheme extends ThemeExtension<TaskFlowTheme> {
  const TaskFlowTheme({
    required this.cardRadius,
    required this.inputRadius,
    required this.chipRadius,
    required this.buttonRadius,
    required this.modalRadius,
    required this.shadowElevation,
    required this.animationDuration,
  });

  final double cardRadius;
  final double inputRadius;
  final double chipRadius;
  final double buttonRadius;
  final double modalRadius;
  final double shadowElevation;
  final Duration animationDuration;

  @override
  TaskFlowTheme copyWith({
    double? cardRadius,
    double? inputRadius,
    double? chipRadius,
    double? buttonRadius,
    double? modalRadius,
    double? shadowElevation,
    Duration? animationDuration,
  }) {
    return TaskFlowTheme(
      cardRadius: cardRadius ?? this.cardRadius,
      inputRadius: inputRadius ?? this.inputRadius,
      chipRadius: chipRadius ?? this.chipRadius,
      buttonRadius: buttonRadius ?? this.buttonRadius,
      modalRadius: modalRadius ?? this.modalRadius,
      shadowElevation: shadowElevation ?? this.shadowElevation,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }

  @override
  TaskFlowTheme lerp(TaskFlowTheme? other, double t) {
    if (other is! TaskFlowTheme) {
      return this;
    }
    return TaskFlowTheme(
      cardRadius: lerpDouble(cardRadius, other.cardRadius, t) ?? cardRadius,
      inputRadius: lerpDouble(inputRadius, other.inputRadius, t) ?? inputRadius,
      chipRadius: lerpDouble(chipRadius, other.chipRadius, t) ?? chipRadius,
      buttonRadius: lerpDouble(buttonRadius, other.buttonRadius, t) ?? buttonRadius,
      modalRadius: lerpDouble(modalRadius, other.modalRadius, t) ?? modalRadius,
      shadowElevation: lerpDouble(shadowElevation, other.shadowElevation, t) ?? shadowElevation,
      animationDuration: t < 0.5 ? animationDuration : other.animationDuration,
    );
  }

  // Default theme values
  static const TaskFlowTheme light = TaskFlowTheme(
    cardRadius: 12.0,
    inputRadius: 12.0,
    chipRadius: 20.0,
    buttonRadius: 12.0,
    modalRadius: 20.0,
    shadowElevation: 2.0,
    animationDuration: Duration(milliseconds: 250),
  );

  static const TaskFlowTheme dark = TaskFlowTheme(
    cardRadius: 12.0,
    inputRadius: 12.0,
    chipRadius: 20.0,
    buttonRadius: 12.0,
    modalRadius: 20.0,
    shadowElevation: 4.0,
    animationDuration: Duration(milliseconds: 250),
  );
}

/// Extension to get TaskFlow theme from context
extension TaskFlowThemeExtension on BuildContext {
  TaskFlowTheme get taskFlowTheme => Theme.of(this).extension<TaskFlowTheme>() ?? TaskFlowTheme.light;
}

/// Utility class for common UI measurements and spacing
class TaskFlowSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  
  // Padding presets
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);
  
  // Horizontal padding
  static const EdgeInsets paddingHorizontalXS = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets paddingHorizontalSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLG = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHorizontalXL = EdgeInsets.symmetric(horizontal: xl);
  
  // Vertical padding
  static const EdgeInsets paddingVerticalXS = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets paddingVerticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLG = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets paddingVerticalXL = EdgeInsets.symmetric(vertical: xl);
}

/// Utility class for shadows
class TaskFlowShadows {
  static List<BoxShadow> soft(Color color) => [
    BoxShadow(
      color: color,
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> medium(Color color) => [
    BoxShadow(
      color: color,
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> strong(Color color) => [
    BoxShadow(
      color: color,
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
}

/// Helper function to get category color
Color getCategoryColor(String categoryId, ColorStyles colors) {
  switch (categoryId.toLowerCase()) {
    case 'personal':
      return colors.categoryPersonal;
    case 'work':
      return colors.categoryWork;
    case 'shopping':
      return colors.categoryShopping;
    case 'health':
      return colors.categoryHealth;
    default:
      return colors.categoryPersonal;
  }
}

/// Helper function to get priority color
Color getPriorityColor(int priority, ColorStyles colors) {
  switch (priority) {
    case 1:
      return colors.priorityLow;
    case 2:
      return colors.priorityMedium;
    case 3:
      return colors.priorityHigh;
    default:
      return colors.priorityMedium;
  }
}

/// Helper function to get task status color
Color getTaskStatusColor(bool isCompleted, bool isOverdue, ColorStyles colors) {
  if (isCompleted) {
    return colors.taskCompleted;
  } else if (isOverdue) {
    return colors.taskOverdue;
  } else {
    return colors.taskPending;
  }
}