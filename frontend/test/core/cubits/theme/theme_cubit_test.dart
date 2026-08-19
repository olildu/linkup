import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/core/cubits/theme/theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('defaults to dark and loads a saved light preference', () async {
    SharedPreferences.setMockInitialValues({'theme_mode': 'light'});
    final cubit = ThemeCubit();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(cubit.state, ThemeMode.light);
    expect(cubit.isDark, isFalse);
    await cubit.close();
  });

  test('loads a saved dark preference', () async {
    SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
    final cubit = ThemeCubit();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(cubit.state, ThemeMode.dark);
    await cubit.close();
  });

  test('toggleTheme flips and persists; setTheme sets explicitly', () async {
    SharedPreferences.setMockInitialValues({});
    final cubit = ThemeCubit();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(cubit.state, ThemeMode.dark);

    cubit.toggleTheme();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(cubit.state, ThemeMode.light);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('theme_mode'), 'light');

    cubit.setTheme(ThemeMode.dark);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(prefs.getString('theme_mode'), 'dark');
    await cubit.close();
  });
}
