import 'package:flutter/material.dart';
import '../data/models/user_settings.dart';
import '../data/services/database_service.dart';

class ThemeProvider extends ChangeNotifier {
  final IDatabaseService _db;
  AppThemeMode _themeMode = AppThemeMode.system;
  String _userName = 'Alex';

  ThemeProvider(this._db);

  AppThemeMode get themeMode => _themeMode;
  String get userName => _userName;

  ThemeMode get flutterThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  Future<void> initialize() async {
    final settings = await _db.getUserSettings();
    _themeMode = settings.themeMode;
    _userName = settings.userName;
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final settings = await _db.getUserSettings();
    await _db.saveUserSettings(settings.copyWith(themeMode: mode));
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    notifyListeners();
    final settings = await _db.getUserSettings();
    await _db.saveUserSettings(settings.copyWith(userName: name));
  }
}
