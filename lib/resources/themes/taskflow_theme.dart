import 'package:flutter/material.dart';
import '/resources/themes/styles/color_styles.dart';
import '/resources/themes/styles/theme_extensions.dart';
import '/resources/themes/styles/animation_styles.dart';

/// TaskFlow theme configuration and utilities
class TaskFlowThemeConfig {
  
  /// Apply TaskFlow theming to the entire app
  static ThemeData applyTaskFlowTheming(ThemeData baseTheme, ColorStyles colors) {
    return baseTheme.copyWith(
      // Enhanced visual density for better touch targets
      visualDensity: VisualDensity.adaptivePlatformDensity,
      
      // Page transitions with smooth animations
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      
      // Enhanced app bar theme
      appBarTheme: baseTheme.appBarTheme.copyWith(
        centerTitle: true,
        titleSpacing: 0,
        toolbarHeight: 64,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      
      // Enhanced list tile theme
      listTileTheme: ListTileThemeData(
        contentPadding: TaskFlowSpacing.paddingHorizontalMD,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: colors.cardBackground,
        selectedTileColor: colors.primaryAccent.withOpacity(0.1),
      ),
      
      // Enhanced tab bar theme
      tabBarTheme: TabBarThemeData(
        labelColor: colors.primaryAccent,
        unselectedLabelColor: colors.content.withOpacity(0.6),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: colors.primaryAccent,
            width: 3,
          ),
          insets: TaskFlowSpacing.paddingHorizontalMD,
        ),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      
      // Enhanced switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return colors.content.withOpacity(0.5);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primaryAccent;
          }
          return colors.inputBorder;
        }),
      ),
      
      // Enhanced checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primaryAccent;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: colors.inputBorder, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      
      // Enhanced radio theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primaryAccent;
          }
          return colors.inputBorder;
        }),
      ),
      
      // Enhanced progress indicator theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primaryAccent,
        linearTrackColor: colors.inputBackground,
        circularTrackColor: colors.inputBackground,
      ),
      
      // Enhanced snack bar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.cardBackground,
        contentTextStyle: TextStyle(color: colors.content),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),
    );
  }
  
  /// Get category-specific theme colors
  static Map<String, Color> getCategoryColors(ColorStyles colors) {
    return {
      'personal': colors.categoryPersonal,
      'work': colors.categoryWork,
      'shopping': colors.categoryShopping,
      'health': colors.categoryHealth,
    };
  }
  
  /// Get priority-specific theme colors
  static Map<int, Color> getPriorityColors(ColorStyles colors) {
    return {
      1: colors.priorityLow,
      2: colors.priorityMedium,
      3: colors.priorityHigh,
    };
  }
  
  /// Get status-specific theme colors
  static Map<String, Color> getStatusColors(ColorStyles colors) {
    return {
      'completed': colors.taskCompleted,
      'pending': colors.taskPending,
      'overdue': colors.taskOverdue,
    };
  }
}

/// Animation presets for common UI interactions
class TaskFlowAnimations {
  
  /// Fade in animation for new items
  static Widget fadeIn({
    required Widget child,
    Duration duration = AnimationStyles.defaultDuration,
    Curve curve = AnimationStyles.defaultCurve,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
  
  /// Scale animation for buttons and interactive elements
  static Widget scaleOnTap({
    required Widget child,
    required VoidCallback onTap,
    double scaleValue = 0.95,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.0),
      duration: AnimationStyles.fast,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: GestureDetector(
            onTapDown: (_) {
              // Scale down
            },
            onTapUp: (_) {
              onTap();
              // Scale back up
            },
            onTapCancel: () {
              // Scale back up
            },
            child: child,
          ),
        );
      },
      child: child,
    );
  }
  
  /// Slide animation for list items
  static Widget slideInFromRight({
    required Widget child,
    Duration duration = AnimationStyles.defaultDuration,
    Curve curve = AnimationStyles.defaultCurve,
    double offset = 100.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 0.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(offset * value, 0),
          child: Opacity(
            opacity: 1 - value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
  
  /// Bounce animation for success states
  static Widget bounceIn({
    required Widget child,
    Duration duration = AnimationStyles.normal,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Utility functions for consistent theming
class TaskFlowThemeUtils {
  
  /// Get appropriate text color based on background
  static Color getContrastingTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
  
  /// Generate a lighter shade of a color
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
  
  /// Generate a darker shade of a color
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
  
  /// Create a gradient from a base color
  static LinearGradient createGradient(Color baseColor) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        lighten(baseColor, 0.1),
        baseColor,
        darken(baseColor, 0.1),
      ],
    );
  }
  
  /// Get elevation shadow for the given color
  static List<BoxShadow> getElevationShadow(Color color, double elevation) {
    return [
      BoxShadow(
        color: color.withOpacity(0.1),
        blurRadius: elevation * 2,
        offset: Offset(0, elevation),
      ),
      BoxShadow(
        color: color.withOpacity(0.05),
        blurRadius: elevation,
        offset: Offset(0, elevation / 2),
      ),
    ];
  }
}