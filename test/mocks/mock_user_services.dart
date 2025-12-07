/// Mock User Services - 사용자 관련 Mock 클래스
/// Phase 2: 프로필 & 사용자 테스트용

import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';

// ============================================
// Test Data Factory - User & Profile
// ============================================

class UserTestData {
  /// 테스트용 사용자 프로필
  static Map<String, dynamic> createUserProfile({
    String id = 'test-user-id',
    String name = '홍길동',
    String? email = 'test@example.com',
    String birthDate = '1990-01-15',
    String birthTime = '09:30',
    String gender = 'male',
    bool onboardingCompleted = true,
    String? zodiacSign,
    String? chineseZodiac,
    String? mbti,
    bool sajuCalculated = true,
  }) {
    return {
      'id': id,
      'name': name,
      'email': email,
      'birth_date': birthDate,
      'birth_time': birthTime,
      'gender': gender,
      'onboarding_completed': onboardingCompleted,
      'zodiac_sign': zodiacSign ?? _getZodiacSign(birthDate),
      'chinese_zodiac': chineseZodiac ?? _getChineseZodiac(birthDate),
      'mbti': mbti,
      'saju_calculated': sajuCalculated,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// 사주 데이터 생성
  static Map<String, dynamic> createSajuData({
    String userId = 'test-user-id',
    String birthDate = '1990-01-15',
    String birthTime = '09:30',
    bool isLunar = false,
  }) {
    return {
      'user_id': userId,
      'birth_date': birthDate,
      'birth_time': birthTime,
      'is_lunar': isLunar,
      'four_pillars': {
        'year': {'heavenly_stem': '경', 'earthly_branch': '오'},
        'month': {'heavenly_stem': '정', 'earthly_branch': '축'},
        'day': {'heavenly_stem': '갑', 'earthly_branch': '자'},
        'hour': {'heavenly_stem': '기', 'earthly_branch': '사'},
      },
      'elements': {
        'wood': 2,
        'fire': 3,
        'earth': 1,
        'metal': 1,
        'water': 1,
      },
      'main_element': 'wood',
      'personality': {
        'core_traits': ['창의적', '진취적', '리더십'],
        'strengths': ['추진력', '결단력'],
        'weaknesses': ['성급함', '고집'],
      },
      'calculated_at': DateTime.now().toIso8601String(),
    };
  }

  /// 오행 분석 데이터
  static Map<String, dynamic> createElementsAnalysis() {
    return {
      'elements': {
        'wood': {'count': 2, 'percentage': 25, 'status': 'balanced'},
        'fire': {'count': 3, 'percentage': 37.5, 'status': 'strong'},
        'earth': {'count': 1, 'percentage': 12.5, 'status': 'weak'},
        'metal': {'count': 1, 'percentage': 12.5, 'status': 'weak'},
        'water': {'count': 1, 'percentage': 12.5, 'status': 'weak'},
      },
      'dominant_element': 'fire',
      'weak_element': 'earth',
      'balance_score': 65,
      'recommendations': [
        '토 기운을 보충하면 좋습니다',
        '노란색 계열의 색상이 도움이 됩니다',
      ],
    };
  }

  /// 천간 데이터
  static List<Map<String, dynamic>> getHeavenlyStems() {
    return [
      {'name': '갑', 'korean': '갑', 'element': 'wood', 'yin_yang': 'yang'},
      {'name': '을', 'korean': '을', 'element': 'wood', 'yin_yang': 'yin'},
      {'name': '병', 'korean': '병', 'element': 'fire', 'yin_yang': 'yang'},
      {'name': '정', 'korean': '정', 'element': 'fire', 'yin_yang': 'yin'},
      {'name': '무', 'korean': '무', 'element': 'earth', 'yin_yang': 'yang'},
      {'name': '기', 'korean': '기', 'element': 'earth', 'yin_yang': 'yin'},
      {'name': '경', 'korean': '경', 'element': 'metal', 'yin_yang': 'yang'},
      {'name': '신', 'korean': '신', 'element': 'metal', 'yin_yang': 'yin'},
      {'name': '임', 'korean': '임', 'element': 'water', 'yin_yang': 'yang'},
      {'name': '계', 'korean': '계', 'element': 'water', 'yin_yang': 'yin'},
    ];
  }

  /// 지지 데이터
  static List<Map<String, dynamic>> getEarthlyBranches() {
    return [
      {'name': '자', 'korean': '쥐', 'element': 'water', 'hour': '23-01'},
      {'name': '축', 'korean': '소', 'element': 'earth', 'hour': '01-03'},
      {'name': '인', 'korean': '호랑이', 'element': 'wood', 'hour': '03-05'},
      {'name': '묘', 'korean': '토끼', 'element': 'wood', 'hour': '05-07'},
      {'name': '진', 'korean': '용', 'element': 'earth', 'hour': '07-09'},
      {'name': '사', 'korean': '뱀', 'element': 'fire', 'hour': '09-11'},
      {'name': '오', 'korean': '말', 'element': 'fire', 'hour': '11-13'},
      {'name': '미', 'korean': '양', 'element': 'earth', 'hour': '13-15'},
      {'name': '신', 'korean': '원숭이', 'element': 'metal', 'hour': '15-17'},
      {'name': '유', 'korean': '닭', 'element': 'metal', 'hour': '17-19'},
      {'name': '술', 'korean': '개', 'element': 'earth', 'hour': '19-21'},
      {'name': '해', 'korean': '돼지', 'element': 'water', 'hour': '21-23'},
    ];
  }

  /// 운세 히스토리 데이터
  static List<Map<String, dynamic>> createFortuneHistory({
    String userId = 'test-user-id',
    int count = 5,
  }) {
    return List.generate(count, (index) {
      final date = DateTime.now().subtract(Duration(days: index));
      return {
        'id': 'fortune-$index',
        'user_id': userId,
        'type': _getFortuneType(index),
        'score': 70 + (index * 5) % 30,
        'summary': '오늘의 운세 요약 $index',
        'created_at': date.toIso8601String(),
      };
    });
  }

  // Helper methods
  static String _getZodiacSign(String birthDate) {
    final date = DateTime.parse(birthDate);
    final month = date.month;
    final day = date.day;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return '양자리';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return '황소자리';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 21)) return '쌍둥이자리';
    if ((month == 6 && day >= 22) || (month == 7 && day <= 22)) return '게자리';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return '사자자리';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return '처녀자리';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return '천칭자리';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return '전갈자리';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return '궁수자리';
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return '염소자리';
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return '물병자리';
    return '물고기자리';
  }

  static String _getChineseZodiac(String birthDate) {
    final date = DateTime.parse(birthDate);
    final year = date.year;
    final animals = ['쥐', '소', '호랑이', '토끼', '용', '뱀', '말', '양', '원숭이', '닭', '개', '돼지'];
    return animals[(year - 4) % 12];
  }

  static String _getFortuneType(int index) {
    final types = ['daily', 'love', 'career', 'health', 'wealth'];
    return types[index % types.length];
  }
}

// ============================================
// Fallback Value Registration
// ============================================

void registerUserFallbackValues() {
  registerFallbackValue(DateTime.now());
  registerFallbackValue(<String, dynamic>{});
  registerFallbackValue(const Duration(seconds: 1));
  registerFallbackValue(TimeOfDay.now());
}
