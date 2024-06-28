import 'package:flutter/material.dart';
import 'package:linkup/colors/colors.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: const Color.fromARGB(255, 249, 249, 249),
    primary: Colors.white,
    secondary: Colors.grey.shade800,
    secondaryContainer: const Color(0xFF6C6C6C),
    primaryContainer: const Color.fromARGB(255, 175, 175, 175)
  ),
  splashColor: ReuseableColors.accentColor,
  highlightColor: ReuseableColors.primaryColor,
  shadowColor: const Color.fromARGB(255, 120, 120, 120),
  cardColor: Colors.white,
  hintColor: Colors.black,
  focusColor: Color.fromARGB(255, 246, 246, 246),
  primaryColor: Color(0xFFF6F6F6),
  secondaryHeaderColor: Colors.white,
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
  highlightColor: Colors.grey.shade800,
  shadowColor: const Color.fromARGB(255, 167, 167, 167),
  hintColor: Colors.white,
  cardColor: Colors.black,
  focusColor: Color.fromARGB(255, 45, 45, 45),
  primaryColor: Color(0xFF343434),
  secondaryHeaderColor: Colors.grey.shade900,
);

/* Theme color choices

  splashColor : For notification color handle
  highlightColor : For the loading background color
  shadowColor : For the streamText color in candidatePage
  cardColor: For the aboutMe and Tags in candidatePage
  primaryColor: For chat bubble in chatDetailsPage
  secondaryHeaderColor: For scaffoldColor chatDetailsPage
  hintColor: Opposite color with respect to the theme (Currently in use in spashScreen)






*/