import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linkup/presentation/constants/colors.dart'; //

// This helper is mandatory for testing widgets that use:
// 1. Theme.of(context) (MaterialApp/ThemeData)
// 2. .sp/.h/.w extensions (ScreenUtilInit)
// 3. Navigation/Scaffold context (Scaffold)
Widget buildTestWidget(Widget child) {
  // Uses the design size (411.43, 866.28) defined in lib/main.dart
  return ScreenUtilInit( 
    designSize: const Size(411.43, 866.28),
    builder: (context, _) => MaterialApp(
      // Provides both light and dark themes for theme-dependent widgets
      theme: AppTheme.lightTheme, //
      darkTheme: AppTheme.darkTheme, //
      // Wraps the component in a Scaffold body for context access
      home: Scaffold(body: child), 
    ),
  );
}