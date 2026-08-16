import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _key = "theme_mode";

  ThemeCubit() : super(ThemeMode.dark) {
    _loadTheme();
  }

  bool get isDark => state == ThemeMode.dark;

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_key);

    if (savedTheme != null) {
      if (savedTheme == 'light') {
        emit(ThemeMode.light);
      } else if (savedTheme == 'dark') {
        emit(ThemeMode.dark);
      }
    }
  }

  void toggleTheme() async {
    final newTheme = state == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    emit(newTheme);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, newTheme == ThemeMode.light ? 'light' : 'dark');
  }

  void setTheme(ThemeMode mode) async {
    emit(mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode == ThemeMode.light ? 'light' : 'dark');
  }
}
