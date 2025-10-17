import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fortune/core/theme/typography_theme.dart';

/// 사용자 설정 상태
class UserSettings {
  /// 폰트 크기 배율 (0.85 ~ 1.3)
  final double fontScale;

  /// 본문 글꼴
  final String bodyFontFamily;

  /// 제목 글꼴
  final String headingFontFamily;

  /// 숫자 글꼴
  final String numberFontFamily;

  const UserSettings({
    this.fontScale = 1.0,
    this.bodyFontFamily = 'Pretendard',
    this.headingFontFamily = 'Pretendard',
    this.numberFontFamily = 'TossFace',
  });

  UserSettings copyWith({
    double? fontScale,
    String? bodyFontFamily,
    String? headingFontFamily,
    String? numberFontFamily,
  }) {
    return UserSettings(
      fontScale: fontScale ?? this.fontScale,
      bodyFontFamily: bodyFontFamily ?? this.bodyFontFamily,
      headingFontFamily: headingFontFamily ?? this.headingFontFamily,
      numberFontFamily: numberFontFamily ?? this.numberFontFamily,
    );
  }

  /// SharedPreferences 키
  static const String _keyFontScale = 'user_settings_font_scale';
  static const String _keyBodyFont = 'user_settings_body_font';
  static const String _keyHeadingFont = 'user_settings_heading_font';
  static const String _keyNumberFont = 'user_settings_number_font';

  /// SharedPreferences에 저장
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyFontScale, fontScale);
    await prefs.setString(_keyBodyFont, bodyFontFamily);
    await prefs.setString(_keyHeadingFont, headingFontFamily);
    await prefs.setString(_keyNumberFont, numberFontFamily);
  }

  /// SharedPreferences에서 로드
  static Future<UserSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return UserSettings(
      fontScale: prefs.getDouble(_keyFontScale) ?? 1.0,
      bodyFontFamily: prefs.getString(_keyBodyFont) ?? 'Pretendard',
      headingFontFamily: prefs.getString(_keyHeadingFont) ?? 'Pretendard',
      numberFontFamily: prefs.getString(_keyNumberFont) ?? 'TossFace',
    );
  }
}

/// 사용자 설정 Notifier
class UserSettingsNotifier extends StateNotifier<UserSettings> {
  UserSettingsNotifier() : super(const UserSettings()) {
    _loadSettings();
  }

  /// 앱 시작 시 설정 로드
  Future<void> _loadSettings() async {
    state = await UserSettings.load();
  }

  /// 폰트 크기 변경
  Future<void> setFontScale(double scale) async {
    state = state.copyWith(fontScale: scale.clamp(0.85, 1.3));
    await state.save();
  }

  /// 프리셋으로 폰트 크기 변경
  Future<void> setFontScalePreset(String preset) async {
    final scale = TypographyTheme.fontScalePresets[preset] ?? 1.0;
    await setFontScale(scale);
  }

  /// 폰트 크기 증가
  Future<void> increaseFontScale() async {
    final newScale = (state.fontScale + 0.08).clamp(0.85, 1.3);
    await setFontScale(newScale);
  }

  /// 폰트 크기 감소
  Future<void> decreaseFontScale() async {
    final newScale = (state.fontScale - 0.08).clamp(0.85, 1.3);
    await setFontScale(newScale);
  }

  /// 본문 글꼴 변경
  Future<void> setBodyFont(String fontFamily) async {
    state = state.copyWith(bodyFontFamily: fontFamily);
    await state.save();
  }

  /// 제목 글꼴 변경
  Future<void> setHeadingFont(String fontFamily) async {
    state = state.copyWith(headingFontFamily: fontFamily);
    await state.save();
  }

  /// 숫자 글꼴 변경
  Future<void> setNumberFont(String fontFamily) async {
    state = state.copyWith(numberFontFamily: fontFamily);
    await state.save();
  }

  /// 모든 글꼴 일괄 변경
  Future<void> setAllFonts(String fontFamily) async {
    state = state.copyWith(
      bodyFontFamily: fontFamily,
      headingFontFamily: fontFamily,
    );
    await state.save();
  }

  /// 설정 초기화
  Future<void> reset() async {
    state = const UserSettings();
    await state.save();
  }
}

/// 사용자 설정 Provider
final userSettingsProvider = StateNotifierProvider<UserSettingsNotifier, UserSettings>((ref) {
  return UserSettingsNotifier();
});

/// 타이포그래피 테마 Provider (사용자 설정 반영)
final typographyThemeProvider = Provider<TypographyTheme>((ref) {
  final settings = ref.watch(userSettingsProvider);
  return TypographyTheme(
    fontScale: settings.fontScale,
    bodyFontFamily: settings.bodyFontFamily,
    headingFontFamily: settings.headingFontFamily,
    numberFontFamily: settings.numberFontFamily,
  );
});
