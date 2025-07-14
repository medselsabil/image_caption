import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode; //Getter to access the current theme mode from outside the class.
  bool get isDarkMode => _themeMode == ThemeMode.dark;//Getter that returns true if current mode is dark, else false.

  void toggleTheme() {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
