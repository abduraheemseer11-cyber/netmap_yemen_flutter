import 'package:flutter/material.dart';
import '../services/local_store.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = Locale(LocalStore.settings.get('lang', defaultValue: 'ar') as String);
  Locale get locale => _locale;

  Future<void> setLanguage(String code) async {
    _locale = Locale(code);
    await LocalStore.settings.put('lang', code);
    notifyListeners();
  }
}
