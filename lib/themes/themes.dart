// themes.dart

import 'package:flutter/material.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    textTheme: const TextTheme(bodyLarge: TextStyle(color: Colors.black)),
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
        .copyWith(background: Colors.white),
  );

  static final ThemeData darkTheme = ThemeData(
    textTheme: const TextTheme(bodyLarge: TextStyle(color: Colors.white)),
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.grey)
        .copyWith(background: Colors.black),
  );

  static final ThemeData redTheme = ThemeData(
    textTheme: TextTheme(bodyLarge: TextStyle(color: Colors.red[900])),
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.red)
        .copyWith(background: Colors.red[50]),
  );

  // Add more themes as needed
}
