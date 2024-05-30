// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SystemUiOverlayStyleProvider extends ChangeNotifier {
  SystemUiOverlayStyle _overlayStyle = SystemUiOverlayStyle(
    statusBarColor: Color.fromRGBO(12, 25, 44, 1),
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color.fromRGBO(12, 25, 44, 1),
  );

  SystemUiOverlayStyle get overlayStyle => _overlayStyle;

  set overlayStyle(SystemUiOverlayStyle style) {
    _overlayStyle = style;
    notifyListeners();
  }
}

class reuseableColors{
  static Color secondaryColor = Color.fromRGBO(12, 25, 44, 1);
  static Color primaryColor = Color.fromRGBO(25, 48, 70, 1);
  static Color accentColor = Color(0xFFFFC629);
}
