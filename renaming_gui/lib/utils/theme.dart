import 'package:flutter/material.dart';

class AppTheme {
  static const Color backgroundColor = Color(0xFF1E1E1E);
  static const Color panelColor = Color(0xFF252526);
  static const Color headerColor = Color(0xFF2D2D30);
  static const Color borderColor = Color(0xFF3C3C3C);
  static const Color primaryColor = Color(0xFF0E639C);
  static const Color primaryHoverColor = Color(0xFF1177BB);
  static const Color successColor = Color(0xFF16825D);
  static const Color successHoverColor = Color(0xFF1A9268);
  static const Color textColor = Color(0xFFCCCCCC);
  static const Color textSecondaryColor = Color(0xFF9CDCFE);
  static const Color textMutedColor = Color(0xFF808080);
  static const Color errorColor = Color(0xFFF48771);
  static const Color warningColor = Color(0xFF4EC9B0);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: textSecondaryColor,
        surface: panelColor,
        error: errorColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: headerColor,
        foregroundColor: textColor,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: panelColor,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 0,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textColor, fontSize: 14),
        bodyMedium: TextStyle(color: textColor, fontSize: 12),
        bodySmall: TextStyle(color: textMutedColor, fontSize: 11),
        titleMedium: TextStyle(
            color: textColor, fontSize: 13, fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: borderColor),
      ),
    );
  }
}
