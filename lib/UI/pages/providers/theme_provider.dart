import 'package:linkup/api/api_calls.dart';
import 'package:linkup/UI/colors/theme.dart';
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (themeData == darkMode){
      themeData = lightMode;
      UserValues.darkTheme = false;
      await prefs.setBool('darkTheme', false);
    }
    else{
      themeData = darkMode;
      UserValues.darkTheme = true;
      await prefs.setBool('darkTheme', true);
    }
  }
  
}