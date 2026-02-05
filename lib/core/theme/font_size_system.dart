import 'package:flutter/widgets.dart';

/// 폰트 크기 표준화 시스템
///
/// 이 시스템은 앱 전체에서 일관된 폰트 크기를 사용하도록 합니다.
/// 사용자 설정에 따라 폰트 크기를 조절할 수 있는 구조를 제공합니다.
///
/// 사용 예시:
/// ```dart
/// // 기본 크기 사용
/// Text('제목', style: TextStyle(fontSize: FontSizeSystem.heading1))
///
/// // 조절된 크기 사용 (추후 구현)
/// Text('제목', style: TextStyle(fontSize: FontSizeSystem.scaled.heading1))
/// ```
class FontSizeSystem {
  // ==========================================
  // BASE SIZES (기본 크기 템플릿)
  // ==========================================
  //
  // 이 크기들은 앱의 기본 폰트 크기입니다.
  // 사용자 설정에 따라 scaleFactor가 곱해져서 실제 크기가 결정됩니다.

  /// Display Sizes (대형 헤드라인)
  /// 스플래시, 온보딩 등 큰 타이틀에 사용
  static const double displayLarge = 40.0;   // 가장 큰 헤드라인
  static const double displayMedium = 34.0;  // 큰 헤드라인
  static const double displaySmall = 28.0;   // 중간 헤드라인

  /// Heading Sizes (섹션 제목)
  /// 페이지 제목, 섹션 헤더에 사용
  static const double heading1 = 26.0;  // 메인 페이지 제목
  static const double heading2 = 22.0;  // 섹션 제목
  static const double heading3 = 20.0;  // 서브 섹션 제목
  static const double heading4 = 18.0;  // 작은 섹션 제목

  /// Body Sizes (본문 텍스트)
  /// 일반 텍스트, 설명 등에 사용
  static const double bodyLarge = 16.0;   // 큰 본문
  static const double bodyMedium = 14.0;  // 기본 본문
  static const double bodySmall = 13.0;   // 작은 본문

  /// Label Sizes (라벨, 캡션)
  /// 버튼 라벨, 입력 필드 힌트, 캡션 등에 사용
  static const double labelLarge = 13.0;   // 큰 라벨
  static const double labelMedium = 12.0;  // 기본 라벨
  static const double labelSmall = 11.0;   // 작은 라벨
  static const double labelTiny = 10.0;    // 매우 작은 라벨 (배지, NEW 표시 등)

  /// Button Sizes (버튼 텍스트)
  /// 버튼 내부 텍스트에 사용
  static const double buttonLarge = 16.0;   // 큰 버튼
  static const double buttonMedium = 15.0;  // 기본 버튼
  static const double buttonSmall = 14.0;   // 작은 버튼
  static const double buttonTiny = 13.0;    // 매우 작은 버튼

  /// Number Sizes (숫자 전용)
  /// 금액, 점수 등 숫자 표시에 사용 (TossFace 폰트)
  static const double numberXLarge = 36.0;  // 매우 큰 숫자
  static const double numberLarge = 28.0;   // 큰 숫자
  static const double numberMedium = 22.0;  // 중간 숫자
  static const double numberSmall = 18.0;   // 작은 숫자

  // ==========================================
  // SCALE FACTOR (사용자 폰트 크기 조절)
  // ==========================================
  //
  // 사용자가 설정에서 폰트 크기를 조절할 수 있습니다.
  // 현재는 기본값 1.0으로 고정되어 있으며,
  // 추후 설정 페이지에서 조절 기능을 추가할 예정입니다.

  /// 폰트 크기 배율 (기본값: 1.0)
  ///
  /// 추후 사용자 설정으로 조절 가능:
  /// - 0.8: 작게
  /// - 1.0: 기본 (default)
  /// - 1.2: 크게
  static double _scaleFactor = 1.0;

  /// 현재 scale factor 조회
  static double get scaleFactor => _scaleFactor;

  /// Scale factor 설정 (추후 설정 페이지에서 사용)
  ///
  /// [factor] 폰트 크기 배율 (0.8 ~ 1.2 권장)
  static void setScaleFactor(double factor) {
    debugPrint('FontSizeSystem: scaleFactor changed from $_scaleFactor to $factor');
    _scaleFactor = factor.clamp(0.5, 2.0); // 안전 범위 설정
  }

  /// Scale factor 초기화 (기본값으로)
  static void resetScaleFactor() {
    _scaleFactor = 1.0;
  }

  // ==========================================
  // SCALED SIZES (조절된 크기)
  // ==========================================
  //
  // 실제 UI에서는 이 크기들을 사용합니다.
  // scaleFactor가 변경되면 자동으로 반영됩니다.

  /// Display Sizes (조절됨)
  static double get displayLargeScaled => displayLarge * _scaleFactor;
  static double get displayMediumScaled => displayMedium * _scaleFactor;
  static double get displaySmallScaled => displaySmall * _scaleFactor;

  /// Heading Sizes (조절됨)
  static double get heading1Scaled => heading1 * _scaleFactor;
  static double get heading2Scaled => heading2 * _scaleFactor;
  static double get heading3Scaled => heading3 * _scaleFactor;
  static double get heading4Scaled => heading4 * _scaleFactor;

  /// Body Sizes (조절됨)
  static double get bodyLargeScaled => bodyLarge * _scaleFactor;
  static double get bodyMediumScaled => bodyMedium * _scaleFactor;
  static double get bodySmallScaled => bodySmall * _scaleFactor;

  /// Label Sizes (조절됨)
  static double get labelLargeScaled => labelLarge * _scaleFactor;
  static double get labelMediumScaled => labelMedium * _scaleFactor;
  static double get labelSmallScaled => labelSmall * _scaleFactor;
  static double get labelTinyScaled => labelTiny * _scaleFactor;

  /// Button Sizes (조절됨)
  static double get buttonLargeScaled => buttonLarge * _scaleFactor;
  static double get buttonMediumScaled => buttonMedium * _scaleFactor;
  static double get buttonSmallScaled => buttonSmall * _scaleFactor;
  static double get buttonTinyScaled => buttonTiny * _scaleFactor;

  /// Number Sizes (조절됨)
  static double get numberXLargeScaled => numberXLarge * _scaleFactor;
  static double get numberLargeScaled => numberLarge * _scaleFactor;
  static double get numberMediumScaled => numberMedium * _scaleFactor;
  static double get numberSmallScaled => numberSmall * _scaleFactor;

  // ==========================================
  // UTILITY METHODS (유틸리티)
  // ==========================================

  /// 커스텀 크기를 scaleFactor에 맞춰 조절
  ///
  /// 특수한 경우에만 사용하고, 가능하면 위의 정의된 크기를 사용하세요.
  ///
  /// [baseSize] 기본 크기
  /// returns 조절된 크기
  static double scale(double baseSize) => baseSize * _scaleFactor;

  /// 폰트 크기 범주 판별 (디버깅용)
  static String getCategory(double size) {
    if (size >= displaySmall) return 'Display';
    if (size >= heading4) return 'Heading';
    if (size >= bodySmall) return 'Body';
    if (size >= labelTiny) return 'Label';
    return 'Unknown';
  }

  /// 시스템 정보 출력 (디버깅용)
  static void printInfo() {
    debugPrint('========================================');
    debugPrint('FontSizeSystem Information');
    debugPrint('========================================');
    debugPrint('Scale Factor: $_scaleFactor');
    debugPrint('');
    debugPrint('Display Sizes:');
    debugPrint('  Large: $displayLarge → $displayLargeScaled');
    debugPrint('  Medium: $displayMedium → $displayMediumScaled');
    debugPrint('  Small: $displaySmall → $displaySmallScaled');
    debugPrint('');
    debugPrint('Heading Sizes:');
    debugPrint('  H1: $heading1 → $heading1Scaled');
    debugPrint('  H2: $heading2 → $heading2Scaled');
    debugPrint('  H3: $heading3 → $heading3Scaled');
    debugPrint('  H4: $heading4 → $heading4Scaled');
    debugPrint('');
    debugPrint('Body Sizes:');
    debugPrint('  Large: $bodyLarge → $bodyLargeScaled');
    debugPrint('  Medium: $bodyMedium → $bodyMediumScaled');
    debugPrint('  Small: $bodySmall → $bodySmallScaled');
    debugPrint('========================================');
  }

  // ==========================================
  // DEVICE SCALE FACTOR (디바이스 접근성 연동)
  // ==========================================
  //
  // 디바이스의 시스템 폰트 크기 설정을 반영합니다.
  // 접근성을 위해 최대 1.5배까지 제한합니다.

  /// 디바이스 최소 스케일 (0.8x)
  static const double _minDeviceScale = 0.8;

  /// 디바이스 최대 스케일 (1.5x) - 레이아웃 깨짐 방지
  static const double _maxDeviceScale = 1.5;

  /// 디바이스 설정을 포함한 최종 스케일 팩터 계산
  ///
  /// [context] BuildContext (MediaQuery 접근용)
  /// returns 앱 설정 * 디바이스 설정 (제한 범위 내)
  static double getDeviceScaleFactor(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    // TextScaler.scale(1.0)으로 기준 스케일 팩터 계산
    final deviceScale = textScaler.scale(1.0);
    final combinedScale = deviceScale * _scaleFactor;
    return combinedScale.clamp(_minDeviceScale, _maxDeviceScale);
  }

  /// 디바이스 설정을 반영한 폰트 크기 계산
  ///
  /// [baseSize] 기본 폰트 크기
  /// [context] BuildContext
  /// returns 디바이스 설정이 반영된 최종 크기
  static double scaledWithContext(double baseSize, BuildContext context) {
    return baseSize * getDeviceScaleFactor(context);
  }

  /// 디바이스 설정만 반영 (앱 설정 무시)
  ///
  /// [baseSize] 기본 폰트 크기
  /// [context] BuildContext
  /// returns 디바이스 설정만 반영된 크기
  static double scaledWithDevice(double baseSize, BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    final deviceScale = textScaler.scale(1.0);
    return baseSize * deviceScale.clamp(_minDeviceScale, _maxDeviceScale);
  }

  /// 현재 디바이스의 텍스트 스케일 팩터 조회 (디버깅용)
  static double getDeviceTextScale(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    return textScaler.scale(1.0);
  }

  /// 디바이스 스케일 정보 출력 (디버깅용)
  static void printDeviceInfo(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    final deviceScale = textScaler.scale(1.0);
    final combinedScale = getDeviceScaleFactor(context);
    debugPrint('========================================');
    debugPrint('FontSizeSystem Device Info');
    debugPrint('========================================');
    debugPrint('App Scale Factor: $_scaleFactor');
    debugPrint('Device Text Scale: $deviceScale');
    debugPrint('Combined Scale: $combinedScale');
    debugPrint('Min Device Scale: $_minDeviceScale');
    debugPrint('Max Device Scale: $_maxDeviceScale');
    debugPrint('========================================');
  }
}

/// 폰트 크기 매핑 가이드 (마이그레이션용)
///
/// 기존 하드코딩된 크기 → FontSizeSystem 매핑:
///
/// Display:
///   48 → FontSizeSystem.displayLarge
///   40 → FontSizeSystem.displayMedium
///   32 → FontSizeSystem.displaySmall
///
/// Heading:
///   28 → FontSizeSystem.heading1
///   24 → FontSizeSystem.heading2
///   20 → FontSizeSystem.heading3
///   18 → FontSizeSystem.heading4
///
/// Body:
///   17 → FontSizeSystem.bodyLarge
///   15 → FontSizeSystem.bodyMedium
///   14 → FontSizeSystem.bodySmall
///
/// Label:
///   13 → FontSizeSystem.labelLarge
///   12 → FontSizeSystem.labelMedium
///   11 → FontSizeSystem.labelSmall
///   10 → FontSizeSystem.labelTiny
///
/// Button:
///   17 → FontSizeSystem.buttonLarge
///   16 → FontSizeSystem.buttonMedium
///   15 → FontSizeSystem.buttonSmall
///   14 → FontSizeSystem.buttonTiny
///
/// Number:
///   40 → FontSizeSystem.numberXLarge
///   32 → FontSizeSystem.numberLarge
///   24 → FontSizeSystem.numberMedium
///   18 → FontSizeSystem.numberSmall
