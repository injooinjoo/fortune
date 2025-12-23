import 'package:flutter/material.dart';

/// Fortune type names mapping
/// Maps fortune type identifiers to their Korean display names
class FortuneTypeNames {
  static const Map<String, String> names = {
    // Daily Fortunes (일일운세)
    'daily': '일일 운세',
    'today': '오늘의 운세',
    'tomorrow': '내일의 운세',
    'daily_calendar': '특정일 운세',
    'weekly': '주간 운세',
    'monthly': '월간 운세',
    'yearly': '연간 운세',
    
    // Traditional Korean Fortunes (전통 운세)
    'traditional': '전통 운세',
    'saju': '사주팔자',
    'traditional-saju': '전통 사주',
    'tarot': '타로',
    'saju-psychology': '사주 심리학',
    'tojeong': '토정비결',
    'salpuli': '살풀이',
    'palmistry': '손금',
    'physiognomy': '관상',
    'face-reading': '관상',  // face-reading = physiognomy 동일
    'five-blessings': '오복',
    
    // Personal/Character Fortunes (성격/캐릭터 운세)
    'mbti': 'MBTI 운세',
    'personality': '성격',
    'personality-dna': '나의 성격 탐구',
    'blood-type': '혈액형 운세',
    'zodiac': '별자리 운세',
    'zodiac-animal': '띠 운세',
    'birth-season': '태어난 계절',
    'birthdate': '생일 운세',
    'birthstone': '탄생석',
    'biorhythm': '바이오리듬',
    
    // Love & Relationship (연애/인연)
    'love': '연애운',
    'marriage': '결혼운',
    'compatibility': '궁합',
    'traditional-compatibility': '전통 궁합',
    'chemistry': '케미',
    'couple-match': '소울메이트',
    'ex-lover': '재회운',
    'blind-date': '소개팅',
    'celebrity-match': '연예인 매치',
    'avoid-people': '피해야 할 사람',
    
    // Career & Business (직업/사업)
    'career': '직업운',
    'employment': '취업운',
    'business': '사업운',
    'startup': '창업 운세',
    'lucky-job': '행운의 직업',
    'lucky-sidejob': '부업 운세',
    'lucky-exam': '시험 운세',
    
    // Wealth & Investment (재물/투자)
    'wealth': '재물운',
    'investment': '재물운',
    'lucky-investment': '재물운',
    'lucky-realestate': '부동산운',
    'lucky-stock': '주식 운세',
    'lucky-crypto': '암호화폐 운세',
    'lucky-lottery': '로또 운세',
    
    // Health & Life (건강/라이프)
    'health': '건강운',
    'moving': '이사',
    'moving-date': '이사 날짜',
    'moving-unified': '이사 운세',
    
    // Lucky Items (행운의 아이템)
    'lucky-color': '행운의 색깔',
    'lucky-number': '행운의 숫자',
    'lucky-items': '행운의 아이템',
    'lucky-food': '행운의 음식',
    'lucky-place': '행운의 장소',
    'lucky-outfit': '행운의 의상',
    'lucky-series': '행운의 시리즈',
    
    // Sports & Activities (스포츠/활동)
    'lucky-baseball': '야구 운세',
    'lucky-golf': '골프 운세',
    'lucky-tennis': '테니스 운세',
    'lucky-running': '런닝 운세',
    'lucky-cycling': '자전거 운세',
    'lucky-swim': '수영 운세',
    'lucky-fishing': '낚시 운세',
    'lucky-hiking': '등산 운세',
    'lucky-fitness': '피트니스 운세',
    'lucky-yoga': '요가 운세',
    'lucky-esports': 'e스포츠 운세',
    'lucky-lck': 'LCK 운세',
    'lucky-soccer': '축구 운세',
    'lucky-basketball': '농구 운세',
    
    // Special Fortunes (특별 운세)
    'destiny': '운명',
    'past-life': '전생',
    'talent': '재능 발견',
    'wish': '소원 성취',
    'timeline': '인생 타임라인',
    'talisman': '부적',
    'new-year': '새해 운세',
    'celebrity': '유명인 운세',
    'same-birthday-celebrity': '같은 생일 연예인',
    'network-report': '네트워크 리포트',
    'dream': '꿈 해몽',
    
    // Pet & Children Fortunes (반려/육아)
    'pet': '반려동물 운세',
    'pet-dog': '반려견 운세',
    'pet-cat': '반려묘 운세',
    'pet-compatibility': '반려동물 궁합',
    'children': '자녀 운세',
    'parenting': '육아 운세',
    'pregnancy': '태교 운세',
    'family-harmony': '가족 화합 운세',

    // Naming Fortune (작명 운세)
    'naming': '작명 운세'};
  
  /// Get the Korean name for a fortune type
  /// Returns the type itself if not found in the mapping
  static String getName(String fortuneType) {
    return names[fortuneType] ?? fortuneType;
  }
  
  /// Get the category name for a fortune type
  static String getCategory(String fortuneType) {
    if (['daily', 'today', 'tomorrow', 'daily_calendar', 'weekly', 'monthly', 'yearly'].contains(fortuneType)) {
      return '일일운세';
    } else if (['saju', 'traditional-saju', 'saju-psychology', 'tojeong', 'salpuli', 'palmistry', 'physiognomy', 'face-reading', 'five-blessings'].contains(fortuneType)) {
      return '전통 운세';
    } else if (['mbti', 'personality', 'blood-type', 'zodiac', 'zodiac-animal', 'birth-season', 'birthdate', 'birthstone', 'biorhythm'].contains(fortuneType)) {
      return '성격/캐릭터 운세';
    } else if (['love', 'marriage', 'compatibility', 'traditional-compatibility', 'chemistry', 'couple-match', 'ex-lover', 'blind-date', 'celebrity-match', 'avoid-people', 'same-birthday-celebrity'].contains(fortuneType)) {
      return '연애/인연';
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
      return '행운의 아이템';
    }
    return '특별 운세';
  }
  
  /// Get type info including icon and color for a fortune type
  static Map<String, dynamic> getTypeInfo(String fortuneType) {
    final category = getCategory(fortuneType);
    final name = getName(fortuneType);
    
    // Define icons and colors for each category
    switch (category) {
      case '일일운세':
        return {
          'name': name,
          'icon': Icons.calendar_today,
          'color': null};
      case '전통 운세':
        return {
          'name': name,
          'icon': Icons.auto_awesome,
          'color': null};
      case '성격/캐릭터 운세':
        return {
          'name': name,
          'icon': Icons.psychology,
          'color': null};
      case '연애/인연':
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
      case '행운의 아이템':
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
      'daily': '/fortune/daily',
      'today': '/fortune/today',
      'tomorrow': '/fortune/tomorrow',
      'daily_calendar': '/daily-calendar',
      'weekly': '/fortune/weekly',
      'monthly': '/fortune/monthly',
      'yearly': '/fortune/yearly',
      'saju': '/fortune/saju',
      'tojeong': '/fortune/tojeong',
      'palmistry': '/fortune/palmistry',
      'physiognomy': '/physiognomy',
      'mbti': '/fortune/mbti',
      'zodiac': '/fortune/zodiac',
      'zodiac-animal': '/fortune/zodiac-animal',
      'love': '/fortune/love',
      'marriage': '/fortune/marriage',
      'compatibility': '/fortune/compatibility',
      'career': '/fortune/career',
      'business': '/fortune/business',
      'wealth': '/fortune/wealth',
      'health': '/fortune/health',
      'dream': '/fortune/dream',
      'naming': '/naming'};
    
    return routeMap[fortuneType] ?? '/fortune';
  }
}