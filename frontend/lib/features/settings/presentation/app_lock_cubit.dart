import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLockCubit extends Cubit<bool> {
  static const String _key = 'app_lock_enabled';

  AppLockCubit() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    emit(prefs.getBool(_key) ?? false);
  }

  Future<void> setEnabled(bool enabled) async {
    emit(enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, enabled);
  }

  Future<void> toggle() => setEnabled(!state);
}
