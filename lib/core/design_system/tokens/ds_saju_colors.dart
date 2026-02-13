import 'package:flutter/material.dart';

/// 사주(四柱) 전용 색상 시스템
///
/// 오행(五行), 신살(神殺) 등 사주 관련 UI의 색상을 정의합니다.
/// 다크모드를 지원하며, DSColors와 일관성을 유지합니다.
class SajuColors {
  SajuColors._();

  // ============================================================
  // 오행(五行) 색상 - Light Mode (ChatGPT 스타일 세련된 파스텔)
  // ============================================================

  /// 목(木) - 에메랄드 그린: 성장, 봄, 동쪽
  static const Color woodLight = Color(0xFF10B981);

  /// 화(火) - 로즈 핑크: 열정, 여름, 남쪽
  static const Color fireLight = Color(0xFFF43F5E);

  /// 토(土) - 앰버 골드: 안정, 환절기, 중앙
  static const Color earthLight = Color(0xFFF59E0B);

  /// 금(金) - 슬레이트 그레이: 결단, 가을, 서쪽
  static const Color metalLight = Color(0xFF64748B);

  /// 수(水) - 스카이 블루: 지혜, 겨울, 북쪽
  static const Color waterLight = Color(0xFF0EA5E9);

  // ============================================================
  // 오행(五行) 색상 - Dark Mode (ChatGPT 스타일)
  // ============================================================

  /// 목(木) - 밝은 에메랄드
  static const Color woodDark = Color(0xFF34D399);

  /// 화(火) - 밝은 로즈
  static const Color fireDark = Color(0xFFFB7185);

  /// 토(土) - 밝은 앰버
  static const Color earthDark = Color(0xFFFBBF24);

  /// 금(金) - 밝은 슬레이트
  static const Color metalDark = Color(0xFF94A3B8);

  /// 수(水) - 밝은 스카이
  static const Color waterDark = Color(0xFF38BDF8);

  // ============================================================
  // 오행(五行) 배경색 - Light Mode (부드러운 파스텔 배경)
  // ============================================================

  static const Color woodBackgroundLight = Color(0x1A10B981);
  static const Color fireBackgroundLight = Color(0x1AF43F5E);
  static const Color earthBackgroundLight = Color(0x1AF59E0B);
  static const Color metalBackgroundLight = Color(0x1A64748B);
  static const Color waterBackgroundLight = Color(0x1A0EA5E9);

  // ============================================================
  // 오행(五行) 배경색 - Dark Mode (부드러운 파스텔 배경)
  // ============================================================

  static const Color woodBackgroundDark = Color(0x2634D399);
  static const Color fireBackgroundDark = Color(0x26FB7185);
  static const Color earthBackgroundDark = Color(0x26FBBF24);
  static const Color metalBackgroundDark = Color(0x2694A3B8);
  static const Color waterBackgroundDark = Color(0x2638BDF8);

  // ============================================================
  // 신살(神殺) 색상
  // ============================================================

  /// 길신(吉神) - 초록색: 천을귀인, 문창귀인, 학당귀인 등
  static const Color auspiciousLight = Color(0xFF10B981);
  static const Color auspiciousDark = Color(0xFF34D399);

  /// 흉신(凶神) - 빨간색: 역마살, 도화살, 겁살 등
  static const Color inauspiciousLight = Color(0xFFEF4444);
  static const Color inauspiciousDark = Color(0xFFF87171);

  /// 중립 신살 - 주황색: 도화살 등 양면성 있는 신살
  static const Color neutralLight = Color(0xFFF59E0B);
  static const Color neutralDark = Color(0xFFFBBF24);

  // ============================================================
  // 특수 표시 색상
  // ============================================================

  /// 일간(日干) 강조색 - 파란색
  static const Color dayMasterLight = Color(0xFF3B82F6);
  static const Color dayMasterDark = Color(0xFF60A5FA);

  /// 합(合) 표시색 - 보라색
  static const Color combinationLight = Color(0xFF8B5CF6);
  static const Color combinationDark = Color(0xFFA78BFA);

  /// 충(沖) 표시색 - 빨간색
  static const Color clashLight = Color(0xFFDC2626);
  static const Color clashDark = Color(0xFFF87171);

  /// 형(刑) 표시색 - 주황색
  static const Color punishmentLight = Color(0xFFEA580C);
  static const Color punishmentDark = Color(0xFFFB923C);

  /// 공망(空亡) 표시색 - 회색
  static const Color emptinessLight = Color(0xFF6B7280);
  static const Color emptinessDark = Color(0xFF9CA3AF);

  // ============================================================
  // 헬퍼 메서드
  // ============================================================

  /// 오행 문자열로 색상 반환
  static Color getWuxingColor(String wuxing, {bool isDark = false}) {
    switch (wuxing) {
      case '목':
      case '木':
        return isDark ? woodDark : woodLight;
      case '화':
      case '火':
        return isDark ? fireDark : fireLight;
      case '토':
      case '土':
        return isDark ? earthDark : earthLight;
      case '금':
      case '金':
        return isDark ? metalDark : metalLight;
      case '수':
      case '水':
        return isDark ? waterDark : waterLight;
      default:
        return isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    }
  }

  /// 오행 문자열로 배경색 반환
  static Color getWuxingBackgroundColor(String wuxing, {bool isDark = false}) {
    switch (wuxing) {
      case '목':
      case '木':
        return isDark ? woodBackgroundDark : woodBackgroundLight;
      case '화':
      case '火':
        return isDark ? fireBackgroundDark : fireBackgroundLight;
      case '토':
      case '土':
        return isDark ? earthBackgroundDark : earthBackgroundLight;
      case '금':
      case '金':
        return isDark ? metalBackgroundDark : metalBackgroundLight;
      case '수':
      case '水':
        return isDark ? waterBackgroundDark : waterBackgroundLight;
      default:
        return isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    }
  }

  /// 천간으로 오행 색상 반환
  static Color getStemColor(String stem, {bool isDark = false}) {
    const stemToWuxing = {
      '갑': '목', '을': '목', '甲': '목', '乙': '목',
      '병': '화', '정': '화', '丙': '화', '丁': '화',
      '무': '토', '기': '토', '戊': '토', '己': '토',
      '경': '금', '신': '금', '庚': '금', '辛': '금',
      '임': '수', '계': '수', '壬': '수', '癸': '수',
    };
    return getWuxingColor(stemToWuxing[stem] ?? '', isDark: isDark);
  }

  /// 지지로 오행 색상 반환
  static Color getBranchColor(String branch, {bool isDark = false}) {
    const branchToWuxing = {
      '자': '수', '축': '토', '인': '목', '묘': '목',
      '진': '토', '사': '화', '오': '화', '미': '토',
      '신': '금', '유': '금', '술': '토', '해': '수',
      '子': '수', '丑': '토', '寅': '목', '卯': '목',
      '辰': '토', '巳': '화', '午': '화', '未': '토',
      '申': '금', '酉': '금', '戌': '토', '亥': '수',
    };
    return getWuxingColor(branchToWuxing[branch] ?? '', isDark: isDark);
  }

  /// 신살 종류에 따른 색상 반환
  static Color getSinsalColor(String category, {bool isDark = false}) {
    switch (category) {
      case 'lucky':
      case 'auspicious':
      case '길신':
        return isDark ? auspiciousDark : auspiciousLight;
      case 'unlucky':
      case 'inauspicious':
      case '흉신':
        return isDark ? inauspiciousDark : inauspiciousLight;
      case 'neutral':
      case '중립':
        return isDark ? neutralDark : neutralLight;
      default:
        return isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    }
  }

  /// 관계 종류에 따른 색상 반환
  static Color getRelationColor(String relation, {bool isDark = false}) {
    switch (relation) {
      case '합':
      case '육합':
      case '삼합':
      case '방합':
      case '천간합':
        return isDark ? combinationDark : combinationLight;
      case '충':
        return isDark ? clashDark : clashLight;
      case '형':
        return isDark ? punishmentDark : punishmentLight;
      case '파':
      case '해':
        return isDark ? inauspiciousDark : inauspiciousLight;
      case '공망':
        return isDark ? emptinessDark : emptinessLight;
      default:
        return isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    }
  }
}
