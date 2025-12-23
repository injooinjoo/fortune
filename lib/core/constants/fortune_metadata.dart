import 'package:flutter/material.dart';

/// Fortune type definitions
enum FortuneType {
  // Daily Fortunes
  daily('daily', '오늘의 운세'),
  today('today', '오늘의 운세'),
  tomorrow('tomorrow', '내일의 운세'),
  hourly('hourly', '시간별 운세'),
  weekly('weekly', '주간 운세'),
  monthly('monthly', '월간 운세'),
  yearly('yearly', '연간 운세'),
  
  // Traditional
  saju('saju', '사주'),
  traditionalSaju('traditional-saju', '전통 사주'),
  sajuPsychology('saju-psychology', '사주 심리학'),
  tojeong('tojeong', '토정비결'),
  palmistry('palmistry', '손금'),
  physiognomy('physiognomy', '관상'),
  nameAnalysis('name-analysis', '이름 풀이'),
  bloodType('blood-type', '혈액형 운세'),
  
  // Zodiac & Stars
  zodiac('zodiac', '별자리 운세'),
  zodiacAnimal('zodiac-animal', '띠별 운세'),
  constellation('constellation', '별자리'),
  birthstone('birthstone', '탄생석 운세'),
  
  // Personality
  mbti('mbti', 'MBTI 운세'),
  personality('personality', '성격 운세'),
  talent('talent', '재능 운세'),
  destiny('destiny', '운명'),
  pastLife('past-life', '전생'),
  
  // Love & Relationships
  love('love', '연애운'),
  marriage('marriage', '결혼운'),
  compatibility('compatibility', '궁합'),
  chemistry('chemistry', '케미'),
  coupleMatch('couple-match', '커플 매칭'),
  blindDate('blind-date', '소개팅 운세'),
  exLover('ex-lover', '전애인 운세'),
  relationshipFortuneWeekly('relationship-fortune-weekly', '주간 연애운'),
  soulmate('soulmate', '소울메이트'),
  
  // Career & Wealth
  career('career', '직업운'),
  employment('employment', '취업운'),
  business('business', '사업운'),
  wealth('wealth', '재물운'),
  startup('startup', '창업운'),
  luckyJob('lucky-job', '행운의 직업'),
  luckySidejob('lucky-sidejob', '행운의 부업'),
  investment('investment', '투자운'),
  
  // Lucky Items & Activities
  luckyColor('lucky-color', '행운의 색상'),
  luckyNumber('lucky-number', '행운의 숫자'),
  luckyItems('lucky-items', '행운의 아이템'),
  luckyFood('lucky-food', '행운의 음식'),
  luckyPlace('lucky-place', '행운의 장소'),
  luckyOutfit('lucky-outfit', '행운의 의상'),
  luckyDirection('lucky-direction', '행운의 방향'),
  
  // Sports & Activities
  sports('sports', '스포츠 운세'),
  luckyGolf('lucky-golf', '골프 운세'),
  luckyTennis('lucky-tennis', '테니스 운세'),
  luckyRunning('lucky-running', '러닝 운세'),
  luckyHiking('lucky-hiking', '등산 운세'),
  luckyFishing('lucky-fishing', '낚시 운세'),
  luckyGaming('lucky-gaming', '게임 운세'),
  luckyKaraoke('lucky-karaoke', '노래방 운세'),
  luckyCamping('lucky-camping', '캠핑 운세'),
  luckyYoga('lucky-yoga', '요가 운세'),
  eSports('esports', 'e스포츠 운세'),
  
  // Investment & Crypto
  luckyStock('lucky-stock', '주식 운세'),
  luckyCrypto('lucky-crypto', '암호화폐 운세'),
  luckyLottery('lucky-lottery', '로또 운세'),
  realEstate('real-estate', '부동산 운세'),
  
  // Feng Shui (풍수지리)
  moving('moving', '이사 풍수'),
  homeFengshui('home-fengshui', '집 풍수'),

  // Special
  biorhythm('biorhythm', '바이오리듬'),
  tarot('tarot', '타로'),
  dream('dream', '꿈해몽'),
  health('health', '건강운'),
  exam('exam', '시험운'),
  study('study', '학업운'),
  travel('travel', '여행운'),
  parenting('parenting', '육아운'),
  pet('pet', '반려동물 운세'),
  talisman('talisman', '부적'),
  salpuli('salpuli', '살풀이'),
  fiveBlessings('five-blessings', '오복'),
  sameBirthdayCelebrity('same-birthday-celebrity', '같은 생일 연예인'),
  dailyInspiration('daily-inspiration', '오늘의 영감'),
  lifestyle('lifestyle', '라이프스타일 운세'),
  crypto('crypto', '크립토 운세');

  final String key;
  final String displayName;
  
  const FortuneType(this.key, this.displayName);
  
  static FortuneType? fromKey(String key) {
    try {
      return FortuneType.values.firstWhere((type) => type.key == key);
    } catch (_) {
      return null;
    }
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