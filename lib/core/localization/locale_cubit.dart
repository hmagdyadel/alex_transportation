import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages application locale (en, ar, it) and persists preference.
class LocaleCubit extends Cubit<Locale> {
  static const String _kLocaleKey = 'app_language_code';

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ar'),
    Locale('it'),
  ];

  LocaleCubit() : super(const Locale('en')) {
    loadSavedLocale();
  }

  /// Loads persisted language choice from SharedPreferences.
  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_kLocaleKey);
    if (savedCode != null && savedCode.isNotEmpty) {
      if (savedCode == 'ar') {
        emit(const Locale('ar'));
      } else if (savedCode == 'it') {
        emit(const Locale('it'));
      } else {
        emit(const Locale('en'));
      }
    }
  }

  /// Updates and persists the current locale.
  Future<void> setLocale(Locale newLocale) async {
    if (newLocale == state) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, newLocale.languageCode);
    emit(newLocale);
  }

  /// Convenience method by language code string ('en', 'ar', 'it').
  Future<void> setLanguageCode(String languageCode) async {
    switch (languageCode) {
      case 'ar':
        await setLocale(const Locale('ar'));
        break;
      case 'it':
        await setLocale(const Locale('it'));
        break;
      default:
        await setLocale(const Locale('en'));
        break;
    }
  }
}
