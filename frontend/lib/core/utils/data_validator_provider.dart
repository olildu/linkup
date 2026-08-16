import 'package:flutter/material.dart';

class DataValidatorProvider with ChangeNotifier {
  bool _allowNext = false;

  bool get allowNext => _allowNext;

  void allowDisallow(bool value) {
    _allowNext = value;
    notifyListeners();
  }
}
