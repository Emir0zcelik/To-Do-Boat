import 'package:flutter/material.dart';

/// Desteklenen uygulama dilleri.
enum AppLocale {
  turkish(Locale('tr'), 'Türkçe'),
  english(Locale('en'), 'English'),
  russian(Locale('ru'), 'Русский');

  const AppLocale(this.locale, this.displayName);
  final Locale locale;
  final String displayName;

  static AppLocale fromLocale(Locale locale) {
    final code = locale.languageCode;
    if (code == 'tr') return AppLocale.turkish;
    if (code == 'en') return AppLocale.english;
    if (code == 'ru') return AppLocale.russian;
    return AppLocale.turkish;
  }

  static AppLocale fromLanguageCode(String code) {
    return fromLocale(Locale(code));
  }
}
