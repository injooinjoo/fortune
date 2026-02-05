import 'package:flutter/material.dart';

/// 오방색 (五方色) - Korean Traditional Five Cardinal Colors
/// Based on Yin-Yang and Five Elements philosophy (음양오행)
///
/// Design Philosophy:
/// - 한지 질감과 수묵화 스타일을 위한 전통 색상 시스템
/// - 톤다운된 고전미를 현대적으로 재해석
/// - 먹색과 미색을 기조로 오방색을 포인트로 활용
class ObangseokColors {
  ObangseokColors._();

  // ==================== 오방색 (Five Cardinal Colors) ====================

  /// 목(木) - 청색 / Cheong (Blue-Green)
  /// Element: Wood / Direction: East / Season: Spring
  /// 깊은 쪽빛 (Deep Indigo)
  static const Color cheong = Color(0xFF1E3A5F);
  static const Color cheongLight = Color(0xFF2D5A87);
  static const Color cheongDark = Color(0xFF0F1F33);
  static const Color cheongMuted = Color(0xFF3D5A73); // 톤다운

  /// 화(火) - 적색 / Jeok (Red)
  /// Element: Fire / Direction: South / Season: Summer
  /// 톤다운된 다홍색 (Muted Vermilion)
  static const Color jeok = Color(0xFFB91C1C);
  static const Color jeokLight = Color(0xFFDC2626);
  static const Color jeokDark = Color(0xFF7F1D1D);
  static const Color jeokMuted = Color(0xFF9B4D4D); // 톤다운

  /// 토(土) - 황색 / Hwang (Yellow)
  /// Element: Earth / Direction: Center / Season: Late Summer
  /// 황토색/겨자색 (Ocher/Mustard)
  static const Color hwang = Color(0xFFB8860B);
  static const Color hwangLight = Color(0xFFD4A017);
  static const Color hwangDark = Color(0xFF8B6914);
  static const Color hwangMuted = Color(0xFFA39171); // 톤다운

  /// 금(金) - 백색 / Baek (White)
  /// Element: Metal / Direction: West / Season: Autumn
  /// 소색 - 은은한 off-white
  static const Color baek = Color(0xFFF5F5DC);
  static const Color baekLight = Color(0xFFFFFFF0);
  static const Color baekDark = Color(0xFFE8E4C9);
  static const Color baekMuted = Color(0xFFD4D0BB); // 톤다운

  /// 수(水) - 흑색 / Heuk (Black)
  /// Element: Water / Direction: North / Season: Winter
  /// 현무색 (Charcoal Black)
  static const Color heuk = Color(0xFF1C1C1C);
  static const Color heukLight = Color(0xFF2D2D2D);
  static const Color heukDark = Color(0xFF0A0A0A);
  static const Color heukMuted = Color(0xFF404040); // 톤다운

  // ==================== 특수 색상 ====================

  /// 인주색 (Inju) - Red Seal/Stamp Color
  /// 중요 버튼, 결과 확인, 강조에 사용
  static const Color inju = Color(0xFFDC2626);
  static const Color injuDark = Color(0xFFB91C1C);
  static const Color injuLight = Color(0xFFEF4444);

  /// 먹색 (Meok) - Ink Color
  /// 먹이 스며든 듯한 검정~회색 그라데이션
  static const Color meok = Color(0xFF1A1A1A);
  static const Color meokLight = Color(0xFF333333);
  static const Color meokDark = Color(0xFF0D0D0D);
  static const Color meokFaded = Color(0xFF666666); // 옅은 먹

  /// 미색 (Misaek) - Unbleached Silk Color
  /// 한지 배경, 기본 배경색
  static const Color misaek = Color(0xFFF7F3E9);
  static const Color misaekLight = Color(0xFFFAF8F2);
  static const Color misaekDark = Color(0xFFEDE8DA);
  static const Color misaekWarm = Color(0xFFF5F0E1); // 따뜻한 미색

  // ==================== 한지 관련 색상 ====================

  /// 한지 배경색
  static const Color hanjiBackground = Color(0xFFFAF8F5);
  static const Color hanjiBackgroundDark = Color(0xFF1E1E1E);

  /// 한지 텍스처 오버레이
  static const Color hanjiOverlay = Color(0x14000000); // 8% opacity
  static const Color hanjiOverlayDark = Color(0x0AFFFFFF); // 4% opacity

  // ==================== 수묵화 그라데이션 ====================

  /// 수묵 그라데이션 (Ink Wash Gradient)
  static const LinearGradient inkWashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF2D2D2D),
      Color(0xFF1A1A1A),
      Color(0xFF0D0D0D),
    ],
  );

  /// 한지 그라데이션 (Hanji Paper Gradient)
  static const LinearGradient hanjiGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFAF8F5),
      Color(0xFFF5F0E8),
      Color(0xFFEDE8DA),
    ],
  );

  /// 오방색 원형 그라데이션 (Five Elements Circle)
  static const List<Color> fiveElementsColors = [
    cheong, // 동 (East) - 청
    jeok, // 남 (South) - 적
    hwang, // 중앙 (Center) - 황
    baek, // 서 (West) - 백
    heuk, // 북 (North) - 흑
  ];

  // ==================== 오행 카테고리 매핑 ====================

  /// 운세 카테고리별 오방색 매핑
  static Color getElementColor(String element) {
    switch (element.toLowerCase()) {
      case 'wood':
      case '목':
      case 'mok':
        return cheong;
      case 'fire':
      case '화':
      case 'hwa':
        return jeok;
      case 'earth':
      case '토':
      case 'to':
        return hwang;
      case 'metal':
      case '금':
      case 'geum':
        return baek;
      case 'water':
      case '수':
      case 'su':
        return heuk;
      default:
        return meok;
    }
  }

  /// 운세 도메인별 오방색 매핑
  static Color getDomainColor(String domain) {
    switch (domain.toLowerCase()) {
      // 연애/관계 - 적색 (화/Fire - 열정)
      case 'love':
      case 'relationship':
      case 'compatibility':
        return jeokMuted;
      // 직업/사업 - 청색 (목/Wood - 성장)
      case 'career':
      case 'business':
      case 'job':
        return cheongMuted;
      // 재물/투자 - 황색 (토/Earth - 풍요)
      case 'money':
      case 'wealth':
      case 'finance':
        return hwang;
      // 건강 - 백색 (금/Metal - 순수)
      case 'health':
      case 'wellness':
        return baekDark;
      // 운명/신비 - 흑색 (수/Water - 지혜)
      case 'spiritual':
      case 'mystical':
      case 'destiny':
        return heukMuted;
      default:
        return meok;
    }
  }

  // ==================== 테마 헬퍼 ====================

  static Color getThemedColor(
      BuildContext context, Color lightColor, Color darkColor) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? darkColor : lightColor;
  }

  static Color getHanjiBackground(BuildContext context) {
    return getThemedColor(context, hanjiBackground, hanjiBackgroundDark);
  }

  static Color getMisaek(BuildContext context) {
    return getThemedColor(context, misaek, heukLight);
  }

  static Color getMeok(BuildContext context) {
    return getThemedColor(context, meok, baekDark);
  }

  static Color getInju(BuildContext context) {
    return getThemedColor(context, inju, injuLight);
  }
}
