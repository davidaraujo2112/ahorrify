import 'package:flutter/material.dart';

import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService;

  SettingsProvider(this._settingsService);

  // Moneda
  String get currency => _settingsService.currency;
  Future<void> setCurrency(String value) async {
    await _settingsService.setCurrency(value);
    notifyListeners();
  }

  // Tema
  String get theme => _settingsService.theme;
  Future<void> setTheme(String value) async {
    await _settingsService.setTheme(value);
    notifyListeners();
  }

  // Cambiar entre claro y oscuro con un bool (para Switch)
  void toggleThemeMode(bool isDark) async {
    final newTheme = isDark ? 'dark' : 'light';
    await setTheme(newTheme);
  }

  // Idioma
  String get language => _settingsService.language;
  Locale get locale => Locale(language);

  Future<void> setLanguage(String value) async {
    await _settingsService.setLanguage(value);
    notifyListeners();
  }

  // Obtener ThemeMode desde string guardado
  ThemeMode get themeMode {
    switch (theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
