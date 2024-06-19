import 'package:flutter/material.dart';
import 'package:linkup/colors/colors.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Colors.white,
    primary: Colors.white,
    secondary: Colors.grey.shade800,
    secondaryContainer: const Color(0xFF6C6C6C),
    primaryContainer: const Color.fromARGB(255, 175, 175, 175)
  ),
  splashColor: ReuseableColors.accentColor,
  highlightColor: ReuseableColors.primaryColor

);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade900,
    primary: Colors.grey.shade800,
    secondary: Colors.grey.shade800,
    secondaryContainer: const Color.fromRGBO(221, 221, 221, 1),
    primaryContainer: Colors.grey.shade800
  ),
  splashColor: Colors.white,
  highlightColor: Colors.grey.shade800
);

/* Theme color choices

  splashColor : For notification color handle
  highlightColor : For the loading background color










*/