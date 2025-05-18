import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  // Tema
  String get theme => _prefs.getString('theme') ?? 'system';
  Future<void> setTheme(String value) async {
    await _prefs.setString('theme', value);
  }

  // Moneda
  String get currency => _prefs.getString('currency') ?? 'USD';
  Future<void> setCurrency(String value) async {
    await _prefs.setString('currency', value);
  }

  // Idioma
  String get language => _prefs.getString('language') ?? 'es';
  Future<void> setLanguage(String value) async {
    await _prefs.setString('language', value);
  }
}
