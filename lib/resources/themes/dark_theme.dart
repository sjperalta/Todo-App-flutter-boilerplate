import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/config/design.dart';
import '/resources/themes/styles/color_styles.dart';
import '/resources/themes/styles/theme_extensions.dart';
import '/resources/themes/text_theme/default_text_theme.dart';
import 'package:nylo_framework/nylo_framework.dart';

/* Dark Theme
|--------------------------------------------------------------------------
| Theme Config - config/theme.dart
|-------------------------------------------------------------------------- */

ThemeData darkTheme(ColorStyles color) {
  TextTheme darkTheme =
      getAppTextTheme(appFont, defaultTextTheme.merge(_textTheme(color)));
  return ThemeData(
    useMaterial3: true,
    primaryColor: color.content,
    primaryColorDark: color.content,
    focusColor: color.content,
    scaffoldBackgroundColor: color.background,
    brightness: Brightness.dark,
    datePickerTheme: DatePickerThemeData(
      headerForegroundColor: Colors.white,
      weekdayStyle: TextStyle(color: Colors.white),
      dayForegroundColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.black; // Color for selected date
        }
        return Colors.white; // Color for unselected dates
      }),
    ),
    timePickerTheme: TimePickerThemeData(
      hourMinuteTextColor: Colors.white,
      dialTextColor: Colors.white,
      dayPeriodTextColor: Colors.white,
      helpTextStyle: TextStyle(color: Colors.white),
      // For the AM/PM selector
      dayPeriodBorderSide: BorderSide(color: Colors.white),
      // For the dial background
      dialBackgroundColor: Colors.grey[800],
      // For the input decoration if using text input mode
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: Colors.white),
        hintStyle: TextStyle(color: Colors.white70),
      ),
    ),
    appBarTheme: AppBarTheme(
        surfaceTintColor: Colors.transparent,
        backgroundColor: color.appBarBackground,
        titleTextStyle:
            darkTheme.titleLarge!.copyWith(color: color.appBarPrimaryContent),
        iconTheme: IconThemeData(color: color.appBarPrimaryContent),
        elevation: 1.0,
        systemOverlayStyle: SystemUiOverlayStyle.dark),
    buttonTheme: ButtonThemeData(
      buttonColor: color.primaryAccent,
      colorScheme: ColorScheme.light(primary: color.buttonBackground),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: color.content),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: TextButton.styleFrom(
          foregroundColor: color.buttonContent,
          backgroundColor: color.buttonBackground),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: color.bottomTabBarBackground,
      unselectedIconTheme:
          IconThemeData(color: color.bottomTabBarIconUnselected),
      selectedIconTheme: IconThemeData(color: color.bottomTabBarIconSelected),
      unselectedLabelStyle: TextStyle(color: color.bottomTabBarLabelUnselected),
      selectedLabelStyle: TextStyle(color: color.bottomTabBarLabelSelected),
      selectedItemColor: color.bottomTabBarLabelSelected,
    ),
    textTheme: darkTheme,
    // Card theme with rounded corners and shadows
    cardTheme: CardThemeData(
      color: color.cardBackground,
      shadowColor: color.cardShadow,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    
    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: color.inputBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color.inputFocusedBorder, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color.errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color.errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      labelStyle: TextStyle(color: color.content),
      hintStyle: TextStyle(color: color.content.withOpacity(0.6)),
    ),
    
    // Chip theme
    chipTheme: ChipThemeData(
      backgroundColor: color.inputBackground,
      selectedColor: color.primaryAccent,
      disabledColor: color.inputBackground.withOpacity(0.5),
      labelStyle: TextStyle(color: color.content),
      secondaryLabelStyle: TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      side: BorderSide(color: color.inputBorder),
      selectedShadowColor: color.cardShadow,
      elevation: 0,
      pressElevation: 2,
    ),
    
    // FloatingActionButton theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: color.primaryAccent,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // Dialog theme
    dialogTheme: DialogThemeData(
      backgroundColor: color.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
    ),
    
    // Bottom sheet theme
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: color.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      elevation: 8,
    ),
    
    colorScheme: ColorScheme.dark(
      primary: color.primaryAccent,
      onSurface: Colors.black,
    ),
    
    // TaskFlow theme extension
    extensions: const <ThemeExtension<dynamic>>[
      TaskFlowTheme.dark,
    ],
  );
}

/* Dark Text Theme
|-------------------------------------------------------------------------*/

TextTheme _textTheme(ColorStyles colors) {
  TextTheme textTheme = const TextTheme()
      .apply(displayColor: colors.content, bodyColor: colors.content);
  return textTheme.copyWith(
      titleLarge:
          TextStyle(color: colors.content.withAlpha((255.0 * 0.8).round())),
      labelLarge:
          TextStyle(color: colors.content.withAlpha((255.0 * 0.8).round())),
      bodySmall:
          TextStyle(color: colors.content.withAlpha((255.0 * 0.8).round())),
      bodyMedium:
          TextStyle(color: colors.content.withAlpha((255.0 * 0.8).round())));
}
