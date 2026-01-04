import 'package:flutter/material.dart';

/// Fortune type names mapping
/// Maps fortune type identifiers to their Korean display names
/// Entertainment-focused terminology for App Store compliance
class FortuneTypeNames {
  static const Map<String, String> names = {
    // Daily Insights (일일 인사이트)
    'daily': '오늘의 메시지',
    'today': '오늘의 인사이트',
    'tomorrow': '내일의 인사이트',
    'daily_calendar': '날짜별 인사이트',
    'weekly': '주간 인사이트',
    'monthly': '월간 인사이트',

    // Traditional Analysis (전통 분석)
    'traditional': '전통 분석',
    'saju': '생년월일 분석',
    'traditional-saju': '전통 생년월일 분석',
    'tarot': 'Insight Cards',
    'saju-psychology': '성격 심리 분석',
    'tojeong': '전통 해석',
    'salpuli': '기운 정화',
    'palmistry': '손금 분석',
    'physiognomy': 'Face AI',
    'face-reading': 'Face AI',
    'five-blessings': '오복 분석',

    // Personal/Character (성격/캐릭터)
    'mbti': 'MBTI 분석',
    'personality': '성격 분석',
    'personality-dna': '나의 성격 탐구',
    'blood-type': '혈액형 분석',
    'zodiac': '별자리 분석',
    'zodiac-animal': '띠별 분석',
    'birth-season': '태어난 계절',
    'birthdate': '생일 분석',
    'birthstone': '탄생석 가이드',
    'biorhythm': '바이오리듬',

    // Love & Relationship (연애/관계)
    'love': '연애 분석',
    'marriage': '결혼 분석',
    'compatibility': '성향 매칭',
    'traditional-compatibility': '전통 매칭 분석',
    'chemistry': '케미 분석',
    'couple-match': '소울메이트',
    'ex-lover': '재회 분석',
    'blind-date': '소개팅 가이드',
    'celebrity-match': '연예인 매칭',
    'avoid-people': '관계 주의 타입',

    // Career & Business (직업/사업)
    'career': '직업 분석',
    'employment': '취업 가이드',
    'business': '사업 분석',
    'startup': '창업 인사이트',
    'lucky-job': '추천 직업',
    'lucky-sidejob': '부업 가이드',
    'lucky-exam': '시험 가이드',

    // Wealth & Investment (재물/투자)
    'wealth': '재물 분석',
    'investment': '투자 인사이트',
    'lucky-investment': '투자 가이드',
    'lucky-realestate': '부동산 인사이트',
    'lucky-stock': '주식 가이드',
    'lucky-crypto': '암호화폐 가이드',
    'lucky-lottery': '로또 번호 생성',

    // Health & Life (건강/라이프)
    'health': '건강 체크',
    'moving': '이사 가이드',
    'moving-date': '이사 날짜 추천',
    'moving-unified': '이사 플래너',

    // Lucky Items (행운의 아이템)
    'lucky-color': '오늘의 색깔',
    'lucky-number': '행운 숫자',
    'lucky-items': '럭키 아이템',
    'lucky-food': '추천 음식',
    'lucky-place': '추천 장소',
    'lucky-outfit': '스타일 가이드',
    'lucky-series': '럭키 시리즈',

    // Sports & Activities (스포츠/활동)
    'lucky-baseball': '야구 가이드',
    'lucky-golf': '골프 가이드',
    'lucky-tennis': '테니스 가이드',
    'lucky-running': '런닝 가이드',
    'lucky-cycling': '사이클링 가이드',
    'lucky-swim': '수영 가이드',
    'lucky-fishing': '낚시 가이드',
    'lucky-hiking': '등산 가이드',
    'lucky-fitness': '피트니스 가이드',
    'lucky-yoga': '요가 가이드',
    'lucky-esports': 'e스포츠 가이드',
    'lucky-lck': 'LCK 가이드',
    'lucky-soccer': '축구 가이드',
    'lucky-basketball': '농구 가이드',

    // Special Features (특별 기능)
    'destiny': '인생 분석',
    'past-life': '전생 이야기',
    'talent': '재능 발견',
    'wish': '소원 분석',
    'timeline': '인생 타임라인',
    'talisman': '행운 카드',
    'new-year': '새해 인사이트',
    'celebrity': '유명인 분석',
    'same-birthday-celebrity': '같은 생일 연예인',
    'network-report': '네트워크 리포트',
    'dream': '꿈 분석',

    // Pet & Children (반려/육아)
    'pet': '반려동물 분석',
    'pet-dog': '반려견 가이드',
    'pet-cat': '반려묘 가이드',
    'pet-compatibility': '반려동물 매칭',
    'children': '자녀 분석',
    'parenting': '육아 가이드',
    'pregnancy': '태교 가이드',
    'family-harmony': '가족 화합 가이드',

    // Naming (작명)
    'naming': '이름 분석'};

  /// Get the Korean name for a fortune type
  /// Returns the type itself if not found in the mapping
  static String getName(String fortuneType) {
    return names[fortuneType] ?? fortuneType;
  }

  /// Get the category name for a fortune type
  static String getCategory(String fortuneType) {
    if (['daily', 'today', 'tomorrow', 'daily_calendar', 'weekly', 'monthly'].contains(fortuneType)) {
      return '일일 인사이트';
    } else if (['saju', 'traditional-saju', 'saju-psychology', 'tojeong', 'salpuli', 'palmistry', 'physiognomy', 'face-reading', 'five-blessings'].contains(fortuneType)) {
      return '전통 분석';
    } else if (['mbti', 'personality', 'blood-type', 'zodiac', 'zodiac-animal', 'birth-season', 'birthdate', 'birthstone', 'biorhythm'].contains(fortuneType)) {
      return '성격/캐릭터';
    } else if (['love', 'marriage', 'compatibility', 'traditional-compatibility', 'chemistry', 'couple-match', 'ex-lover', 'blind-date', 'celebrity-match', 'avoid-people', 'same-birthday-celebrity'].contains(fortuneType)) {
      return '연애/관계';
    } else if (['career', 'employment', 'business', 'startup', 'lucky-job', 'lucky-sidejob', 'lucky-exam'].contains(fortuneType)) {
      return '직업/사업';
    } else if (['wealth', 'lucky-investment', 'lucky-realestate', 'lucky-stock', 'lucky-crypto', 'lucky-lottery'].contains(fortuneType)) {
      return '재물/투자';
    } else if (['health', 'moving', 'moving-date'].contains(fortuneType)) {
      return '건강/라이프';
    } else if (['pet', 'pet-dog', 'pet-cat', 'pet-compatibility', 'children', 'parenting', 'pregnancy', 'family-harmony', 'naming'].contains(fortuneType)) {
      return '반려/육아';
    } else if (fortuneType.startsWith('lucky-')) {
      if (['lucky-baseball', 'lucky-golf', 'lucky-tennis', 'lucky-running', 'lucky-cycling', 'lucky-swim', 'lucky-fishing', 'lucky-hiking', 'lucky-fitness', 'lucky-yoga'].contains(fortuneType)) {
        return '스포츠/활동';
      }
      return '럭키 아이템';
    }
    return '특별 기능';
  }

  /// Get type info including icon and color for a fortune type
  static Map<String, dynamic> getTypeInfo(String fortuneType) {
    final category = getCategory(fortuneType);
    final name = getName(fortuneType);

    // Define icons and colors for each category
    switch (category) {
      case '일일 인사이트':
        return {
          'name': name,
          'icon': Icons.calendar_today,
          'color': null};
      case '전통 분석':
        return {
          'name': name,
          'icon': Icons.auto_awesome,
          'color': null};
      case '성격/캐릭터':
        return {
          'name': name,
          'icon': Icons.psychology,
          'color': null};
      case '연애/관계':
        return {
          'name': name,
          'icon': Icons.favorite,
          'color': null};
      case '직업/사업':
        return {
          'name': name,
          'icon': Icons.work,
          'color': null};
      case '재물/투자':
        return {
          'name': name,
          'icon': Icons.attach_money,
          'color': null};
      case '건강/라이프':
        return {
          'name': name,
          'icon': Icons.favorite_border,
          'color': null};
      case '스포츠/활동':
        return {
          'name': name,
          'icon': Icons.sports,
          'color': null};
      case '럭키 아이템':
        return {
          'name': name,
          'icon': Icons.star,
          'color': null};
      case '반려/육아':
        return {
          'name': name,
          'icon': Icons.family_restroom,
          'color': null};
      default:
        return {
          'name': name,
          'icon': Icons.auto_awesome,
          'color': null};
    }
  }

  /// Get route for a fortune type
  static String? getRoute(String fortuneType) {
    // Map fortune types to their routes
    final routeMap = {
      'daily': '/daily-calendar',
      'today': '/daily-calendar',
      'tomorrow': '/daily-calendar',
      'daily_calendar': '/daily-calendar',
      'weekly': '/daily-calendar',
      'monthly': '/daily-calendar',
      'saju': '/traditional-saju',
      'tojeong': '/traditional',
      'palmistry': '/traditional',
      'physiognomy': '/face-reading',
      'face-reading': '/face-reading',
      'mbti': '/mbti',
      'zodiac': '/daily-calendar',
      'zodiac-animal': '/daily-calendar',
      'love': '/love',
      'marriage': '/compatibility',
      'compatibility': '/compatibility',
      'career': '/career',
      'business': '/career',
      'wealth': '/investment',
      'health': '/health-toss',
      'dream': '/interactive/dream',
      'tarot': '/tarot',
      'naming': '/naming'};

    return routeMap[fortuneType] ?? '/fortune';
  }
}
