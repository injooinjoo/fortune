/// 앱 전체 폰트 설정 중앙 관리
///
/// 이 파일 하나만 수정하면 전체 앱의 폰트가 변경됩니다.
///
/// 사용 예시:
/// ```dart
/// // 폰트 패밀리 참조
/// fontFamily: FontConfig.primary
///
/// // 폰트 사이즈 참조 (FontSizeSystem 통합)
/// fontSize: FontConfig.displayLarge
/// ```
class FontConfig {
  FontConfig._();

  // ═══════════════════════════════════════════════════════
  // 폰트 패밀리 (수정하면 전체 앱에 적용)
  // ═══════════════════════════════════════════════════════

  /// 기본 폰트 패밀리
  static const String primary = 'NanumMyeongjo';

  /// 한글 전용 폰트
  static const String korean = 'NanumMyeongjo';

  /// 영문 전용 폰트
  static const String english = 'NanumMyeongjo';

  /// 숫자 전용 폰트
  static const String number = 'NanumMyeongjo';

  /// 서예/전통 스타일 폰트
  static const String calligraphy = 'NanumMyeongjo';

  // ═══════════════════════════════════════════════════════
  // 폰트 사이즈 (FontSizeSystem 참조)
  // ═══════════════════════════════════════════════════════

  // Display Sizes (대형 헤드라인)
  static const double displayLarge = 50.0;
  static const double displayMedium = 42.0;
  static const double displaySmall = 34.0;

  // Heading Sizes (섹션 제목)
  static const double heading1 = 30.0;
  static const double heading2 = 26.0;
  static const double heading3 = 22.0;
  static const double heading4 = 20.0;

  // Body Sizes (본문 텍스트)
  static const double bodyLarge = 19.0;
  static const double bodyMedium = 17.0;
  static const double bodySmall = 16.0;

  // Label Sizes (라벨, 캡션)
  static const double labelLarge = 15.0;
  static const double labelMedium = 14.0;
  static const double labelSmall = 13.0;
  static const double labelTiny = 12.0;

  // Caption/Badge Sizes (매우 작은 텍스트)
  static const double captionLarge = 11.0;
  static const double captionSmall = 10.0;
  static const double badgeText = 9.0;

  // Button Sizes (버튼 텍스트)
  static const double buttonLarge = 19.0;
  static const double buttonMedium = 18.0;
  static const double buttonSmall = 17.0;
  static const double buttonTiny = 16.0;

  // Number Sizes (숫자 전용)
  static const double numberXLarge = 42.0;
  static const double numberLarge = 34.0;
  static const double numberMedium = 26.0;
  static const double numberSmall = 20.0;

  // Emoji/Icon Display Sizes (이모지, 아이콘 표시용)
  static const double emojiXLarge = 80.0;
  static const double emojiLarge = 64.0;
  static const double emojiMedium = 56.0;
  static const double emojiSmall = 48.0;

  // Score Display Sizes (점수 표시용)
  static const double scoreXLarge = 64.0;
  static const double scoreLarge = 48.0;
  static const double scoreMedium = 36.0;

  // ═══════════════════════════════════════════════════════
  // 폰트 정보
  // ═══════════════════════════════════════════════════════

  /// Google Fonts 패키지 사용 여부
  static const bool useGoogleFonts = true;

  /// Google Fonts 메소드명 (GoogleFonts.nanumMyeongjo)
  static const String googleFontsMethod = 'nanumMyeongjo';
}
