import 'package:flutter/material.dart';

/// 앱 전체 타이포그래피 테마 시스템
/// 5단계 크기 레벨 + 글꼴 통합 관리
/// 사용자 설정으로 폰트 크기 및 글꼴 변경 가능
class TypographyTheme {
  // ==========================================
  // 1. FONT SCALE MULTIPLIER (사용자 설정 배율)
  // ==========================================

  /// 폰트 크기 배율 (0.85 ~ 1.3)
  /// 기본값: 1.0 (100%)
  /// 작게: 0.85 (85%)
  /// 조금 작게: 0.92 (92%)
  /// 조금 크게: 1.08 (108%)
  /// 크게: 1.15 (115%)
  /// 매우 크게: 1.3 (130%)
  final double fontScale;

  // ==========================================
  // 2. FONT FAMILY (글꼴)
  // ==========================================

  /// 한글 본문용 글꼴
  final String bodyFontFamily;

  /// 제목용 글꼴
  final String headingFontFamily;

  /// 숫자/금액 표시용 글꼴
  final String numberFontFamily;

  // ==========================================
  // 3. BASE FONT SIZES (기본 폰트 크기)
  // ==========================================

  /// 5단계 폰트 크기 체계
  static const Map<String, double> _baseFontSizes = {
    // Display (특대 제목) - 히어로 섹션, 랜딩 페이지
    'display_large': 48.0,   // 예: "당신의 운명을 만나보세요"
    'display_medium': 40.0,  // 예: "오늘의 타로"
    'display_small': 32.0,   // 예: "운세 카테고리"

    // Heading (제목) - 페이지 제목, 섹션 제목
    'heading_large': 28.0,   // 예: "타로 카드 선택"
    'heading_medium': 24.0,  // 예: "오늘의 운세"
    'heading_small': 20.0,   // 예: "카드 해석"

    // Title (소제목) - 카드 타이틀, 리스트 아이템 제목
    'title_large': 18.0,     // 예: "연애운"
    'title_medium': 17.0,    // 예: "재물운"
    'title_small': 16.0,     // 예: "건강운"

    // Body (본문) - 일반 텍스트, 설명
    'body_large': 17.0,      // 예: "메인 설명 텍스트"
    'body_medium': 15.0,     // 예: "일반 본문"
    'body_small': 14.0,      // 예: "보조 설명"

    // Label (라벨) - 버튼, 태그, 캡션
    'label_large': 16.0,     // 예: "버튼 텍스트"
    'label_medium': 13.0,    // 예: "태그, 배지"
    'label_small': 12.0,     // 예: "캡션, 힌트"
  };

  // ==========================================
  // 4. CONSTRUCTOR
  // ==========================================

  const TypographyTheme({
    this.fontScale = 1.0,
    this.bodyFontFamily = 'Pretendard',
    this.headingFontFamily = 'Pretendard',
    this.numberFontFamily = 'TossFace',
  });

  // ==========================================
  // 5. FONT SIZE PRESETS (프리셋)
  // ==========================================

  /// 폰트 크기 프리셋
  static const Map<String, double> fontScalePresets = {
    'very_small': 0.85,   // 85% - 매우 작게
    'small': 0.92,        // 92% - 작게
    'normal': 1.0,        // 100% - 기본
    'large': 1.08,        // 108% - 조금 크게
    'very_large': 1.15,   // 115% - 크게
    'extra_large': 1.3,   // 130% - 매우 크게
  };

  /// 프리셋 이름 → 한글 라벨
  static const Map<String, String> fontScaleLabels = {
    'very_small': '매우 작게',
    'small': '작게',
    'normal': '기본',
    'large': '조금 크게',
    'very_large': '크게',
    'extra_large': '매우 크게',
  };

  // ==========================================
  // 6. COMPUTED TEXT STYLES (계산된 스타일)
  // ==========================================

  /// Display Large (특대 제목)
  /// 사용처: 히어로 섹션, 스플래시
  TextStyle get displayLarge => TextStyle(
    fontSize: _baseFontSizes['display_large']! * fontScale,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02,
    fontFamily: headingFontFamily,
  );

  /// Display Medium
  /// 사용처: 메인 제목
  TextStyle get displayMedium => TextStyle(
    fontSize: _baseFontSizes['display_medium']! * fontScale,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02,
    fontFamily: headingFontFamily,
  );

  /// Display Small
  /// 사용처: 큰 섹션 제목
  TextStyle get displaySmall => TextStyle(
    fontSize: _baseFontSizes['display_small']! * fontScale,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.01,
    fontFamily: headingFontFamily,
  );

  /// Heading Large (큰 제목)
  /// 사용처: 페이지 제목
  TextStyle get headingLarge => TextStyle(
    fontSize: _baseFontSizes['heading_large']! * fontScale,
    height: 1.3,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.01,
    fontFamily: headingFontFamily,
  );

  /// Heading Medium (중간 제목)
  /// 사용처: 섹션 제목
  TextStyle get headingMedium => TextStyle(
    fontSize: _baseFontSizes['heading_medium']! * fontScale,
    height: 1.35,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    fontFamily: headingFontFamily,
  );

  /// Heading Small (작은 제목)
  /// 사용처: 카드 제목, 서브 섹션
  TextStyle get headingSmall => TextStyle(
    fontSize: _baseFontSizes['heading_small']! * fontScale,
    height: 1.4,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    fontFamily: headingFontFamily,
  );

  /// Title Large (큰 타이틀)
  /// 사용처: 리스트 아이템 제목
  TextStyle get titleLarge => TextStyle(
    fontSize: _baseFontSizes['title_large']! * fontScale,
    height: 1.45,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    fontFamily: bodyFontFamily,
  );

  /// Title Medium (중간 타이틀)
  /// 사용처: 카드 타이틀
  TextStyle get titleMedium => TextStyle(
    fontSize: _baseFontSizes['title_medium']! * fontScale,
    height: 1.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    fontFamily: bodyFontFamily,
  );

  /// Title Small (작은 타이틀)
  /// 사용처: 작은 카드 타이틀
  TextStyle get titleSmall => TextStyle(
    fontSize: _baseFontSizes['title_small']! * fontScale,
    height: 1.5,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    fontFamily: bodyFontFamily,
  );

  /// Body Large (큰 본문)
  /// 사용처: 메인 본문, 중요한 설명
  TextStyle get bodyLarge => TextStyle(
    fontSize: _baseFontSizes['body_large']! * fontScale,
    height: 1.55,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: bodyFontFamily,
  );

  /// Body Medium (중간 본문)
  /// 사용처: 일반 본문
  TextStyle get bodyMedium => TextStyle(
    fontSize: _baseFontSizes['body_medium']! * fontScale,
    height: 1.6,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: bodyFontFamily,
  );

  /// Body Small (작은 본문)
  /// 사용처: 보조 설명, 작은 텍스트
  TextStyle get bodySmall => TextStyle(
    fontSize: _baseFontSizes['body_small']! * fontScale,
    height: 1.6,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: bodyFontFamily,
  );

  /// Label Large (큰 라벨)
  /// 사용처: 버튼 텍스트, 중요한 라벨
  TextStyle get labelLarge => TextStyle(
    fontSize: _baseFontSizes['label_large']! * fontScale,
    height: 1.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    fontFamily: bodyFontFamily,
  );

  /// Label Medium (중간 라벨)
  /// 사용처: 태그, 배지, 작은 버튼
  TextStyle get labelMedium => TextStyle(
    fontSize: _baseFontSizes['label_medium']! * fontScale,
    height: 1.55,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    fontFamily: bodyFontFamily,
  );

  /// Label Small (작은 라벨)
  /// 사용처: ��션, 힌트, 타임스탬프
  TextStyle get labelSmall => TextStyle(
    fontSize: _baseFontSizes['label_small']! * fontScale,
    height: 1.5,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: bodyFontFamily,
  );

  /// Number Large (큰 숫자)
  /// 사용처: 금액, 중요한 수치
  TextStyle get numberLarge => TextStyle(
    fontSize: _baseFontSizes['display_small']! * fontScale,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02,
    fontFamily: numberFontFamily,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// Number Medium (중간 숫자)
  /// 사용처: 일반 숫자 표시
  TextStyle get numberMedium => TextStyle(
    fontSize: _baseFontSizes['heading_medium']! * fontScale,
    height: 1.35,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.01,
    fontFamily: numberFontFamily,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// Number Small (작은 숫자)
  /// 사용처: 작은 수치, 통계
  TextStyle get numberSmall => TextStyle(
    fontSize: _baseFontSizes['body_medium']! * fontScale,
    height: 1.6,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    fontFamily: numberFontFamily,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  // ==========================================
  // 7. UTILITY METHODS
  // ==========================================

  /// 특정 배율로 새 테마 생성
  TypographyTheme copyWithScale(double scale) {
    return TypographyTheme(
      fontScale: scale,
      bodyFontFamily: bodyFontFamily,
      headingFontFamily: headingFontFamily,
      numberFontFamily: numberFontFamily,
    );
  }

  /// 특정 글꼴로 새 테마 생성
  TypographyTheme copyWithFonts({
    String? body,
    String? heading,
    String? number,
  }) {
    return TypographyTheme(
      fontScale: fontScale,
      bodyFontFamily: body ?? bodyFontFamily,
      headingFontFamily: heading ?? headingFontFamily,
      numberFontFamily: number ?? numberFontFamily,
    );
  }

  /// 배율 증가
  TypographyTheme increaseScale() {
    final newScale = (fontScale + 0.08).clamp(0.85, 1.3);
    return copyWithScale(newScale);
  }

  /// 배율 감소
  TypographyTheme decreaseScale() {
    final newScale = (fontScale - 0.08).clamp(0.85, 1.3);
    return copyWithScale(newScale);
  }

  /// 기본 테마로 리셋
  TypographyTheme reset() {
    return const TypographyTheme();
  }
}

/// 타이포그래피 테마 사용 예시:
///
/// ```dart
/// // 1. 기본 사용
/// Text(
///   '오늘의 타로',
///   style: context.typography.displayMedium.copyWith(
///     color: TossDesignSystem.textPrimaryLight,
///   ),
/// )
///
/// // 2. 사용자 설정 배율 적용
/// final customTheme = TypographyTheme(fontScale: 1.15); // 115% 크기
/// Text(
///   '본문 텍스트',
///   style: customTheme.bodyMedium.copyWith(
///     color: TossDesignSystem.textSecondaryLight,
///   ),
/// )
///
/// // 3. 프리셋 사용
/// final largeTheme = TypographyTheme(
///   fontScale: TypographyTheme.fontScalePresets['large']!,
/// );
///
/// // 4. 글꼴 변경
/// final customFontTheme = TypographyTheme(
///   bodyFontFamily: 'NotoSansKR',
///   headingFontFamily: 'NotoSansKR',
/// );
/// ```

/// 컨텍스트 확장 - 편리한 접근
/// 사용 예시:
/// Text('제목', style: context.typography.headingLarge)
extension TypographyThemeContext on BuildContext {}

/// 이 확장은 제거되었습니다.
/// 대신 ConsumerWidget을 사용하고 Provider를 직접 참조하세요:
///
/// ```dart
/// class MyWidget extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final typography = ref.watch(typographyThemeProvider);
///     return Text('제목', style: typography.headingLarge);
///   }
/// }
/// ```
