import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tekne_demirbas/l10n/app_locale.dart';

const String _localeKey = 'app_locale';

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

class LocaleNotifier extends Notifier<Locale> {
  static final Future<SharedPreferences> _prefs =
      SharedPreferences.getInstance();

  @override
  Locale build() {
    _load();
    return const Locale('tr');
  }

  Future<void> _load() async {
    final prefs = await _prefs;
    final code = prefs.getString(_localeKey);
    if (code != null) {
      state = AppLocale.fromLanguageCode(code).locale;
    }
  }

  Future<void> setLocale(AppLocale appLocale) async {
    state = appLocale.locale;
    final prefs = await _prefs;
    await prefs.setString(_localeKey, appLocale.locale.languageCode);
  }

  AppLocale get currentAppLocale => AppLocale.fromLocale(state);
}
