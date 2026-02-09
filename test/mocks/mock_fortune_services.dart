// Mock Fortune Services - 운세 관련 Mock 클래스
// Phase 3: 운세 기능 테스트용

import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';

// ============================================
// Test Data Factory - Fortune
// ============================================

class FortuneTestData {
  /// 일일 운세 데이터
  static Map<String, dynamic> createDailyFortune({
    String userId = 'test-user-id',
    int score = 75,
  }) {
    return {
      'user_id': userId,
      'fortune_type': 'daily',
      'date': DateTime.now().toIso8601String().split('T')[0],
      'score': score,
      'overall': '오늘은 전반적으로 좋은 날입니다',
      'love': '연인과의 관계가 더욱 돈독해질 수 있습니다',
      'money': '재물운이 상승하는 기운이 있습니다',
      'health': '가벼운 운동이 도움이 됩니다',
      'work': '업무에서 좋은 성과를 기대할 수 있습니다',
      'lucky_color': '파란색',
      'lucky_number': 7,
      'lucky_direction': '동쪽',
      'advice': '새로운 시작에 좋은 날입니다',
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  /// 연애운 데이터
  static Map<String, dynamic> createLoveFortune({
    String userId = 'test-user-id',
    String relationshipStatus = 'single',
    int score = 80,
  }) {
    return {
      'user_id': userId,
      'fortune_type': 'love',
      'relationship_status': relationshipStatus,
      'score': score,
      'monthly_fortune': List.generate(12, (i) => 60 + (i * 3) % 40),
      'ideal_type_analysis': '활발하고 외향적인 성격의 사람이 잘 맞습니다',
      'advice': '적극적으로 다가가세요',
      'meeting_time': relationshipStatus == 'single' ? '봄에 좋은 인연이 있습니다' : null,
      'meeting_place': relationshipStatus == 'single' ? '동호회, 모임' : null,
      'relationship_advice': relationshipStatus == 'dating' ? '서로의 시간을 존중하세요' : null,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  /// 궁합 데이터
  static Map<String, dynamic> createCompatibility({
    String userId = 'test-user-id',
    int score = 85,
    String? grade,
  }) {
    return {
      'user_id': userId,
      'fortune_type': 'compatibility',
      'score': score,
      'grade': grade ?? _getCompatibilityGrade(score),
      'categories': {
        'personality': 85,
        'love': 90,
        'marriage': 82,
        'money': 78,
      },
      'element_compatibility': '목-화 상생',
      'strengths': ['서로를 보완하는 관계', '대화가 잘 통함'],
      'cautions': ['가치관 차이에 주의', '의사소통 노력 필요'],
      'advice': '서로의 차이를 인정하고 존중하세요',
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  /// 직업 코칭 데이터
  static Map<String, dynamic> createCareerCoaching({
    String userId = 'test-user-id',
    String currentStatus = 'employed',
    int successRate = 75,
  }) {
    return {
      'user_id': userId,
      'fortune_type': 'career',
      'current_status': currentStatus,
      'success_rate': successRate,
      'aptitude_analysis': '창의적인 분야에 적합합니다',
      'recommended_jobs': ['디자이너', '마케터', '기획자'],
      'career_advice': '지금이 도전할 때입니다',
      'timing_advice': '상반기에 집중하세요',
      'strengths': ['리더십', '창의성', '분석력'],
      'improvements': ['인내심', '세부 집중'],
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  /// 꿈 해몽 데이터
  static Map<String, dynamic> createDreamFortune({
    String userId = 'test-user-id',
    String dreamContent = '돼지가 나오는 꿈',
    String fortune = '대길',
  }) {
    return {
      'user_id': userId,
      'fortune_type': 'dream',
      'dream_content': dreamContent,
      'fortune': fortune,
      'meaning': '재물운의 상승을 의미합니다',
      'lucky_numbers': [3, 7, 12, 24, 36, 45],
      'caution': '오늘은 중요한 결정을 피하세요',
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  /// 관상 분석 데이터
  static Map<String, dynamic> createFaceReading({
    String userId = 'test-user-id',
    int overallScore = 85,
  }) {
    return {
      'user_id': userId,
      'fortune_type': 'face_reading',
      'overall_score': overallScore,
      'parts': {
        'forehead': {'description': '지혜와 관록의 상', 'score': 80},
        'eyes': {'description': '매력적인 눈', 'score': 88},
        'nose': {'description': '재물복이 있는 코', 'score': 85},
        'mouth': {'description': '복이 있는 입', 'score': 82},
        'chin': {'description': '의지가 강한 턱', 'score': 78},
      },
      'fortune_categories': {
        'wealth': 80,
        'love': 88,
        'career': 85,
      },
      'similar_celebrity': '분석 중...',
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  /// MBTI 운세 데이터
  static Map<String, dynamic> createMBTIFortune({
    String userId = 'test-user-id',
    String mbtiType = 'INTJ',
    bool hasSajuData = false,
  }) {
    return {
      'user_id': userId,
      'fortune_type': 'mbti',
      'mbti_type': mbtiType,
      'mbti_name': _getMBTIName(mbtiType),
      'today_fortune': '분석적인 능력이 빛나는 날입니다',
      'personality_traits': ['독립적', '전략적', '완벽주의'],
      'best_match': ['ENFP', 'ENTP'],
      'worst_match': ['ESFP', 'ISFP'],
      'recommended_jobs': ['과학자', '엔지니어', '전략 컨설턴트'],
      'saju_integration': hasSajuData ? '사주의 목(木) 기운과 INTJ의 전략적 성향이 조화롭게 어우러집니다' : null,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  /// 바이오리듬 데이터
  static Map<String, dynamic> createBiorhythm({
    String userId = 'test-user-id',
    String date = '2024-12-07',
  }) {
    return {
      'user_id': userId,
      'fortune_type': 'biorhythm',
      'date': date,
      'rhythms': {
        'physical': {'value': 75, 'status': '고조기'},
        'emotional': {'value': 50, 'status': '위험일'},
        'intellectual': {'value': 85, 'status': '고조기'},
        'intuitive': {'value': 60, 'status': '보통'},
      },
      'advice': '지적 활동에 적합한 날입니다',
      'caution': '격한 운동은 피하세요',
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  /// 투자운 데이터
  static Map<String, dynamic> createInvestmentFortune({
    String userId = 'test-user-id',
    String investmentType = 'stock',
    int score = 72,
  }) {
    return {
      'user_id': userId,
      'fortune_type': 'investment',
      'investment_type': investmentType,
      'score': score,
      'timing_analysis': '상반기가 유리합니다',
      'risk_analysis': '중간 수준의 리스크를 감수할 수 있습니다',
      'lucky_sectors': ['기술주', '금융주'],
      'caution_sectors': ['에너지주', '원자재'],
      'monthly_fortune': List.generate(12, (i) => 50 + (i * 5) % 50),
      'strategy': '장기 투자에 집중하세요',
      'caution': '3월에는 큰 결정을 피하세요',
      'disclaimer': '본 분석은 참고용이며 실제 투자 결정에 대한 책임은 본인에게 있습니다.',
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  /// 유명인 운세 데이터
  static Map<String, dynamic> createCelebrityFortune({
    String userId = 'test-user-id',
    String celebrityName = '손흥민',
    String category = 'sports',
  }) {
    return {
      'user_id': userId,
      'fortune_type': 'celebrity',
      'celebrity': {
        'name': celebrityName,
        'birth_date': '1992-07-08',
        'category': category,
        'profession': '축구선수',
      },
      'saju_analysis': '화(火) 기운이 강한 사주입니다',
      'success_factors': ['끈기와 열정', '목표 지향적 성격'],
      'comparison_with_user': '당신과 비슷한 오행 구성을 가지고 있습니다',
      'lessons': ['꾸준한 노력과 자기 관리'],
      'same_birthday_celebrities': ['유명인 A', '유명인 B'],
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  /// 타로 결과 데이터
  static Map<String, dynamic> createTarotResult({
    String userId = 'test-user-id',
    String category = 'general',
    List<String>? cards,
  }) {
    return {
      'user_id': userId,
      'fortune_type': 'tarot',
      'category': category,
      'cards': cards ?? ['The Fool', 'The Magician', 'The High Priestess'],
      'interpretation': '새로운 시작과 가능성이 열려 있습니다',
      'past': '과거에 중요한 결정을 내렸습니다',
      'present': '현재는 변화의 시기입니다',
      'future': '밝은 미래가 기다리고 있습니다',
      'advice': '직관을 믿고 앞으로 나아가세요',
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  /// 인기 꿈 주제 목록
  static List<String> getPopularDreamTopics() {
    return ['돼지', '뱀', '물', '용', '죽음', '불', '돈', '치아', '아기', '결혼'];
  }

  /// 운세 타입 목록
  static List<Map<String, dynamic>> getFortuneTypes() {
    return [
      {'type': 'daily', 'name': '오늘의 운세', 'icon': 'star'},
      {'type': 'love', 'name': '연애운', 'icon': 'heart'},
      {'type': 'career', 'name': '직업 코칭', 'icon': 'work'},
      {'type': 'money', 'name': '재물운', 'icon': 'money'},
      {'type': 'health', 'name': '건강운', 'icon': 'health'},
      {'type': 'tarot', 'name': '타로', 'icon': 'cards'},
      {'type': 'dream', 'name': '꿈 해몽', 'icon': 'dream'},
      {'type': 'face', 'name': '관상', 'icon': 'face'},
      {'type': 'mbti', 'name': 'MBTI 운세', 'icon': 'psychology'},
      {'type': 'biorhythm', 'name': '바이오리듬', 'icon': 'rhythm'},
      {'type': 'investment', 'name': '투자운', 'icon': 'trending'},
      {'type': 'celebrity', 'name': '유명인 운세', 'icon': 'star'},
      {'type': 'compatibility', 'name': '궁합', 'icon': 'favorite'},
    ];
  }

  // Helper methods
  static String _getCompatibilityGrade(int score) {
    if (score >= 90) return '천생연분';
    if (score >= 80) return '좋은 인연';
    if (score >= 70) return '괜찮은 궁합';
    if (score >= 60) return '보통';
    return '노력 필요';
  }

  static String _getMBTIName(String type) {
    const mbtiNames = {
      'INTJ': '전략가',
      'INTP': '논리술사',
      'ENTJ': '통솔자',
      'ENTP': '변론가',
      'INFJ': '옹호자',
      'INFP': '중재자',
      'ENFJ': '선도자',
      'ENFP': '활동가',
      'ISTJ': '현실주의자',
      'ISFJ': '수호자',
      'ESTJ': '경영자',
      'ESFJ': '집정관',
      'ISTP': '장인',
      'ISFP': '모험가',
      'ESTP': '사업가',
      'ESFP': '연예인',
    };
    return mbtiNames[type] ?? '';
  }
}

// ============================================
// Fallback Value Registration
// ============================================

void registerFortuneFallbackValues() {
  registerFallbackValue(DateTime.now());
  registerFallbackValue(<String, dynamic>{});
  registerFallbackValue(const Duration(seconds: 1));
  registerFallbackValue(TimeOfDay.now());
}
