import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    background: Colors.white,
    primary: Colors.white,
    secondary: Colors.grey.shade800,
    secondaryContainer: const Color(0xFF6C6C6C),
    primaryContainer: Color.fromARGB(255, 175, 175, 175)
  )
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    background: Colors.grey.shade900,
    primary: Colors.grey.shade800,
    secondary: Colors.grey.shade800,
    surface: Colors.grey.shade500,
    secondaryContainer: Color.fromRGBO(221, 221, 221, 1),
    primaryContainer: Colors.grey.shade800
  )
);
