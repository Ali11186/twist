import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.purple,
    scaffoldBackgroundColor: const Color(0xFF0D0D0D),
    colorScheme: const ColorScheme.dark(primary: Colors.purple),
    appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
  );
}
