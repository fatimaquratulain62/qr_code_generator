import 'package:flutter/material.dart';

import '../services/storage_service.dart';

/// Manages the app's theme mode (light / dark / system) and persists the
/// user's choice across launches.
class ThemeProvider extends ChangeNotifier {
  ThemeProvider() {
    _restore();
  }

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  Future<void> _restore() async {
    final saved = await StorageService.instance.loadThemeMode();
    if (saved != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (m) => m.name == saved,
        orElse: () => ThemeMode.system,
      );
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    await StorageService.instance.saveThemeMode(mode.name);
  }
}
