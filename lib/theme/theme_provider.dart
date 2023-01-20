import 'package:flutter/material.dart';

import 'colors.dart';

class AppTheme {
  bool isDark(BuildContext context) {
    Brightness brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    return isDarkMode;
  }

  ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    //Snackbar
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: darkSnackBarBackground,
      contentTextStyle: TextStyle(
        color: darkSnackBarContent,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    //Snackbar
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: lightSnackBarBackground,
      contentTextStyle: TextStyle(
        color: lightSnackBarContent,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
