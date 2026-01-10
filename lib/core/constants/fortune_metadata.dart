import 'package:flutter/material.dart';

/// Fortune type definitions (Entertainment-focused terminology)
enum FortuneType {
  // Daily Insights
  daily('daily', '오늘의 인사이트'),
  today('today', '오늘의 메시지'),
  tomorrow('tomorrow', '내일의 인사이트'),
  hourly('hourly', '시간별 가이드'),
  weekly('weekly', '주간 인사이트'),
  monthly('monthly', '월간 인사이트'),
  yearly('yearly', '연간 인사이트'),

  // Traditional Analysis
  saju('saju', '생년월일 분석'),
  traditionalSaju('traditional-saju', '전통 분석'),
  sajuPsychology('saju-psychology', '성격 심리 분석'),
  tojeong('tojeong', '전통 해석'),
  palmistry('palmistry', '손금 분석'),
  physiognomy('physiognomy', 'Face AI'),
  faceReading('face-reading', 'AI 관상'), // face-reading 타입 추가
  nameAnalysis('name-analysis', '이름 분석'),
  bloodType('blood-type', '혈액형 분석'),

  // Zodiac & Stars
  zodiac('zodiac', '별자리 분석'),
  zodiacAnimal('zodiac-animal', '띠별 분석'),
  constellation('constellation', '별자리'),
  birthstone('birthstone', '탄생석 가이드'),

  // Personality
  mbti('mbti', 'MBTI 분석'),
  personality('personality', '성격 분석'),
  talent('talent', '재능 발견'),
  destiny('destiny', '인생 분석'),
  pastLife('past-life', '전생 이야기'),

  // Love & Relationships
  love('love', '연애 분석'),
  marriage('marriage', '결혼 분석'),
  compatibility('compatibility', '성향 매칭'),
  chemistry('chemistry', '케미 분석'),
  coupleMatch('couple-match', '커플 매칭'),
  blindDate('blind-date', '소개팅 가이드'),
  exLover('ex-lover', '재회 분석'),
  relationshipFortuneWeekly('relationship-fortune-weekly', '주간 연애 인사이트'),
  soulmate('soulmate', '소울메이트'),
  avoidPeople('avoid-people', '오늘의 경계운'),

  // Career & Wealth
  career('career', '직업 분석'),
  employment('employment', '취업 가이드'),
  business('business', '사업 분석'),
  wealth('wealth', '재물 분석'),
  startup('startup', '창업 인사이트'),
  luckyJob('lucky-job', '추천 직업'),
  luckySidejob('lucky-sidejob', '부업 가이드'),
  investment('investment', '투자 인사이트'),

  // Lucky Items & Activities
  luckyColor('lucky-color', '오늘의 색깔'),
  luckyNumber('lucky-number', '행운 숫자'),
  luckyItems('lucky-items', '럭키 아이템'),
  luckyFood('lucky-food', '추천 음식'),
  luckyPlace('lucky-place', '추천 장소'),
  luckyOutfit('lucky-outfit', '스타일 가이드'),
  luckyDirection('lucky-direction', '추천 방향'),

  // Sports & Activities
  sports('sports', '스포츠 가이드'),
  luckyGolf('lucky-golf', '골프 가이드'),
  luckyTennis('lucky-tennis', '테니스 가이드'),
  luckyRunning('lucky-running', '런닝 가이드'),
  luckyHiking('lucky-hiking', '등산 가이드'),
  luckyFishing('lucky-fishing', '낚시 가이드'),
  luckyGaming('lucky-gaming', '게임 가이드'),
  luckyKaraoke('lucky-karaoke', '노래방 가이드'),
  luckyCamping('lucky-camping', '캠핑 가이드'),
  luckyYoga('lucky-yoga', '요가 가이드'),
  eSports('esports', 'e스포츠 가이드'),

  // Investment & Crypto
  luckyStock('lucky-stock', '주식 가이드'),
  luckyCrypto('lucky-crypto', '암호화폐 가이드'),
  luckyLottery('lucky-lottery', '로또 번호 생성'),
  realEstate('real-estate', '부동산 인사이트'),

  // Lifestyle (라이프스타일)
  moving('moving', '이사 가이드'),
  homeFengshui('home-fengshui', '인테리어 가이드'),

  // Special
  biorhythm('biorhythm', '바이오리듬'),
  tarot('tarot', 'Insight Cards'),
  dream('dream', '꿈 분석'),
  health('health', '건강 체크'),
  exam('exam', '시험 가이드'),
  study('study', '학업 분석'),
  travel('travel', '여행 가이드'),
  parenting('parenting', '육아 가이드'),
  pet('pet', '반려동물 가이드'),
  talisman('talisman', '행운 카드'),
  salpuli('salpuli', '기운 정화'),
  fiveBlessings('five-blessings', '오복 분석'),
  sameBirthdayCelebrity('same-birthday-celebrity', '같은 생일 연예인'),
  dailyInspiration('daily-inspiration', '오늘의 영감'),
  lifestyle('lifestyle', '라이프스타일 가이드'),
  crypto('crypto', '크립토 가이드');

  final String key;
  final String displayName;
  
  const FortuneType(this.key, this.displayName);
  
  static FortuneType? fromKey(String key) {
    // 1. .key 속성으로 검색 (하이픈 형식: 'avoid-people')
    for (final type in FortuneType.values) {
      if (type.key == key) return type;
    }
    // 2. enum 필드명으로 검색 (camelCase: 'avoidPeople')
    for (final type in FortuneType.values) {
      if (type.name == key) return type;
    }
    return null;
  }
}

/// Fortune metadata containing UI and configuration details
class FortuneMetadata {
  final FortuneType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final int tokenCost;
  final List<String> inputFields;
  final bool requiresBirthInfo;
  final bool requiresPartnerInfo;
  final String? imagePath;
  final String description;

  const FortuneMetadata({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.tokenCost,
    this.inputFields = const [],
    this.requiresBirthInfo = true,
    this.requiresPartnerInfo = false,
    this.imagePath,
    required this.description});
}

/// Fortune metadata repository
class FortuneMetadataRepository {
  static final Map<FortuneType, FortuneMetadata> _metadata = {
    // Daily Fortunes
    FortuneType.daily: const FortuneMetadata(
      type: FortuneType.daily,
      title: '오늘의 운세',
      subtitle: '오늘 하루의 전체적인 운세를 확인하세요',
      icon: Icons.today,
      primaryColor: Color(0xFF4A90E2),
      secondaryColor: Color(0xFF5BA0F2),
      tokenCost: 0,
      description: '오늘 하루 동안의 전반적인 운세와 행운 지수를 확인할 수 있습니다.'
    ),
    
    FortuneType.tomorrow: const FortuneMetadata(
      type: FortuneType.tomorrow,
      title: '내일의 운세',
      subtitle: '내일의 운세를 미리 확인하세요',
      icon: Icons.event,
      primaryColor: Color(0xFF7B68EE),
      secondaryColor: Color(0xFF8B78FE),
      tokenCost: 1,
      description: '내일의 운세를 미리 확인하고 준비할 수 있습니다.'
    ),
    
    FortuneType.weekly: const FortuneMetadata(
      type: FortuneType.weekly,
      title: '주간 운세',
      subtitle: '이번 주 전체 운세를 확인하세요',
      icon: Icons.date_range,
      primaryColor: Color(0xFF50C878),
      secondaryColor: Color(0xFF60D888),
      tokenCost: 2,
      description: '이번 주 7일간의 전체적인 운세 흐름을 파악할 수 있습니다.'
    ),
    
    // Traditional
    FortuneType.saju: const FortuneMetadata(
      type: FortuneType.saju,
      title: '사주',
      subtitle: '사주팔자로 보는 평생 운명',
      icon: Icons.auto_awesome,
      primaryColor: Color(0xFFDC143C),
      secondaryColor: Color(0xFFEC254C),
      tokenCost: 5,
      requiresBirthInfo: true,
      inputFields: ['birthTime'],
      description: '생년월일시를 바탕으로 타고난 운명과 성격을 분석합니다.'
    ),
    
    // Love & Relationships
    FortuneType.love: const FortuneMetadata(
      type: FortuneType.love,
      title: '연애운',
      subtitle: '연애 운세와 조언',
      icon: Icons.favorite,
      primaryColor: Color(0xFFFF69B4),
      secondaryColor: Color(0xFFFF79C4),
      tokenCost: 2,
      description: '현재의 연애운과 미래의 인연에 대해 알아봅니다.'
    ),
    
    FortuneType.compatibility: const FortuneMetadata(
      type: FortuneType.compatibility,
      title: '궁합',
      subtitle: '두 사람의 궁합을 확인하세요',
      icon: Icons.favorite_border,
      primaryColor: Color(0xFFFF6B6B),
      secondaryColor: Color(0xFFFF7B7B),
      tokenCost: 3,
      requiresPartnerInfo: true,
      description: '두 사람의 궁합과 관계 발전 가능성을 분석합니다.'
    ),
    
    // Career & Wealth
    FortuneType.career: const FortuneMetadata(
      type: FortuneType.career,
      title: '직업운',
      subtitle: '직장과 커리어 운세',
      icon: Icons.work,
      primaryColor: Color(0xFF4169E1),
      secondaryColor: Color(0xFF5179F1),
      tokenCost: 2,
      description: '직장 생활과 커리어 발전에 대한 운세를 확인합니다.'
    ),
    
    FortuneType.wealth: const FortuneMetadata(
      type: FortuneType.wealth,
      title: '재물운',
      subtitle: '금전운과 재물 획득 운세',
      icon: Icons.attach_money,
      primaryColor: Color(0xFFFFD700),
      secondaryColor: Color(0xFFFFE710),
      tokenCost: 2,
      description: '금전운과 재물 획득의 기회를 알아봅니다.'
    ),
    
    // Lucky Items
    FortuneType.luckyColor: const FortuneMetadata(
      type: FortuneType.luckyColor,
      title: '행운의 색상',
      subtitle: '오늘의 행운을 가져다 줄 색상',
      icon: Icons.palette,
      primaryColor: Color(0xFF9C27B0),
      secondaryColor: Color(0xFFAC37C0),
      tokenCost: 1,
      description: '오늘 당신에게 행운을 가져다 줄 색상을 알아봅니다.'
    ),
    
    // Feng Shui (풍수지리)
    FortuneType.moving: const FortuneMetadata(
      type: FortuneType.moving,
      title: '이사 풍수',
      subtitle: '새로운 보금자리의 풍수를 분석합니다',
      icon: Icons.home_work,
      primaryColor: Color(0xFF8B7355),
      secondaryColor: Color(0xFF9B8365),
      tokenCost: 3,
      requiresBirthInfo: false,
      inputFields: ['currentArea', 'targetArea', 'period', 'purpose'],
      description: '이사할 지역의 방위와 시기를 분석하여 길한 이사운을 알려드립니다.',
    ),

    FortuneType.homeFengshui: const FortuneMetadata(
      type: FortuneType.homeFengshui,
      title: '집 풍수',
      subtitle: '현재 집의 풍수 기운을 진단합니다',
      icon: Icons.landscape,
      primaryColor: Color(0xFF8B7355),
      secondaryColor: Color(0xFF9B8365),
      tokenCost: 3,
      requiresBirthInfo: false,
      inputFields: ['address', 'homeType', 'floor', 'doorDirection'],
      description: '배산임수와 양택풍수를 기반으로 현재 집의 기운을 분석합니다.',
    ),

    // Add more metadata for all fortune types...
    // This is a simplified version. In production, add all 80+ types
  };
  
  static FortuneMetadata? getMetadata(FortuneType type) {
    return _metadata[type];
  }
  
  static FortuneMetadata getMetadataOrDefault(FortuneType type) {
    return _metadata[type] ?? FortuneMetadata(
      type: type,
      title: type.displayName,
      subtitle: '${type.displayName}을 확인하세요',
      icon: Icons.stars,
      primaryColor: const Color(0xFF6C63FF),
      secondaryColor: const Color(0xFF7C73FF),
      tokenCost: 2,
      description: '${type.displayName}에 대한 상세 정보를 확인할 수 있습니다.'
    );
  }
  
  static List<FortuneMetadata> getAllMetadata() {
    return _metadata.values.toList();
  }
  
  static List<FortuneMetadata> getByCategory(FortuneCategory category) {
    switch (category) {
      case FortuneCategory.daily:
        return [
          _metadata[FortuneType.daily]!,
          _metadata[FortuneType.tomorrow]!,
          _metadata[FortuneType.weekly]!,
          _metadata[FortuneType.monthly]!,
        ];
      
      case FortuneCategory.love:
        return [
          _metadata[FortuneType.love]!,
          _metadata[FortuneType.marriage]!,
          _metadata[FortuneType.compatibility]!];
      
      case FortuneCategory.career:
        return [
          _metadata[FortuneType.career]!,
          _metadata[FortuneType.wealth]!,
          _metadata[FortuneType.business]!];

      case FortuneCategory.fengshui:
        return [
          _metadata[FortuneType.moving]!,
          _metadata[FortuneType.homeFengshui]!,
        ];

      default:
        return [];
    }
  }
}

/// Fortune categories for grouping
enum FortuneCategory {
  daily('일일운세'),
  traditional('전통'),
  love('연애/관계'),
  career('직업/재물'),
  lucky('행운 아이템'),
  sports('스포츠/활동'),
  investment('투자/재테크'),
  fengshui('풍수지리'),
  special('특별');

  final String displayName;
  const FortuneCategory(this.displayName);
}