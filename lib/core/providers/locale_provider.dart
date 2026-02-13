import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 지원 언어 정보
class SupportedLanguage {
  final Locale locale;
  final String nativeName;
  final String englishName;

  const SupportedLanguage({
    required this.locale,
    required this.nativeName,
    required this.englishName,
  });
}

/// 지원 언어 목록
const supportedLanguages = [
  SupportedLanguage(
    locale: Locale('ko'),
    nativeName: '한국어',
    englishName: 'Korean',
  ),
  SupportedLanguage(
    locale: Locale('en'),
    nativeName: 'English',
    englishName: 'English',
  ),
  SupportedLanguage(
    locale: Locale('ja'),
    nativeName: '日本語',
    englishName: 'Japanese',
  ),
];

/// 언어 설정 Notifier
class LocaleNotifier extends StateNotifier<Locale> {
  static const String _localeKey = 'app_locale';

  LocaleNotifier() : super(const Locale('ko')) {
    _loadLocale();
  }

  /// SharedPreferences에서 저장된 언어 로드
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_localeKey);
    if (languageCode != null) {
      final locale = Locale(languageCode);
      // 지원하는 언어인지 확인
      if (_isSupported(locale)) {
        state = locale;
      }
    }
  }

  /// 언어 변경
  Future<void> setLocale(Locale locale) async {
    if (!_isSupported(locale)) return;

    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  /// 언어 코드로 변경
  Future<void> setLocaleByCode(String languageCode) async {
    await setLocale(Locale(languageCode));
  }

  /// 지원 언어인지 확인
  bool _isSupported(Locale locale) {
    return supportedLanguages.any(
      (lang) => lang.locale.languageCode == locale.languageCode,
    );
  }

  /// 현재 언어 정보 가져오기
  SupportedLanguage get currentLanguage {
    return supportedLanguages.firstWhere(
      (lang) => lang.locale.languageCode == state.languageCode,
      orElse: () => supportedLanguages.first,
    );
  }
}

/// 언어 설정 Provider
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
