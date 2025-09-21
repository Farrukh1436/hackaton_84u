import 'package:shared_preferences/shared_preferences.dart';
import 'en.dart';
import 'ru.dart';
import 'uz.dart';

class LanguageController {
  static Map<String, String> _localizedStrings = en;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('language') ?? 'en';
    setLanguage(code);
  }

  static Future<void> setLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', langCode);

    switch (langCode) {
      case 'uz':
        _localizedStrings = uz;
        break;
      case 'ru':
        _localizedStrings = ru;
        break;
      default:
        _localizedStrings = en;
    }
  }

  static String get(String key) {
    return _localizedStrings[key] ?? key;
  }
}
