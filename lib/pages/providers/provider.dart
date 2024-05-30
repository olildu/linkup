import 'package:demo/api/api_calls.dart';
import 'package:demo/colors/theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier{
  ThemeData _themeData = darkMode;

  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData){
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() async{
    print("Toggled Here");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (themeData == darkMode){
      themeData = lightMode;
      userValues.darkTheme = false;
      await prefs.setBool('darkTheme', false);
    }
    else{
      themeData = darkMode;
      userValues.darkTheme = true;
      await prefs.setBool('darkTheme', true);
    }
  }
  
}