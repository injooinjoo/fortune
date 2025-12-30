// 십성(十星) 재능 모델
//
// 사주팔자의 십성을 재능, 직업, 성장 가이드로 매핑합니다.
//
// 십성:
// - 비견(比肩): 독립성, 자립심, 경쟁력
// - 겁재(劫財): 추진력, 행동력, 변화 주도
// - 식신(食神): 창의력, 표현력, 예술성
// - 상관(傷官): 비판력, 혁신, 재능 표출
// - 편재(偏財): 사교성, 다재다능, 순발력
// - 정재(正財): 안정성, 계획성, 책임감
// - 편관(偏官): 결단력, 추진력, 권위
// - 정관(正官): 질서, 원칙, 리더십
// - 편인(偏印): 통찰력, 직관, 독창성
// - 정인(正印): 학습력, 지혜, 보호본능

class SipseongTalent {
  final String name; // 십성 이름
  final String emoji; // 이모지
  final String title; // 재능 타이틀
  final String subtitle; // 부제목
  final String description; // 전체 설명

  // Part 2: TOP 3 재능에 사용
  final String talentDescription; // 이 재능이 뭔지 설명
  final String manifestation; // 이 재능이 어떻게 발현되는지
  final String developmentGuide; // 이 재능을 어떻게 키울지

  // Part 3: 커리어 로드맵에 사용
  final List<String> primaryCareers; // 1순위 직업군
  final List<String> secondaryCareers; // 2순위 직업군
  final String careerReason; // 추천 이유
  final String bestEnvironment; // 최적 업무 환경
  final String worstEnvironment; // 최악 업무 환경
  final List<String> pitfalls; // 주의해야 할 함정
  final List<String> complements; // 보완할 점

  // Part 4: 평생 성장 가이드에 사용
  final List<String> luckyElements; // 성장을 도와줄 행운의 요소
  final String growthAdvice; // 전반적인 성장 조언

  // Part 5: 친근한 콘텐츠 (BottomSheet 보강용)
  final String friendlyExplanation; // 쉽게 이해하기
  final List<String> realLifeExamples; // 실생활 예시
  final Map<String, String> seasonalTips; // 계절별 활용법 (best, caution, spring, summer, autumn, winter)
  final Map<String, dynamic> dailyTips; // 시간대별 활용법 (bestTime, bestActivities, caution)
  final List<String> compatibleSipseong; // 시너지 좋은 십신
  final List<String> challengingSipseong; // 보완 필요한 십신

  const SipseongTalent({
    required this.name,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.talentDescription,
    required this.manifestation,
    required this.developmentGuide,
    required this.primaryCareers,
    required this.secondaryCareers,
    required this.careerReason,
    required this.bestEnvironment,
    required this.worstEnvironment,
    required this.pitfalls,
    required this.complements,
    required this.luckyElements,
    required this.growthAdvice,
    this.friendlyExplanation = '',
    this.realLifeExamples = const [],
    this.seasonalTips = const {},
    this.dailyTips = const {},
    this.compatibleSipseong = const [],
    this.challengingSipseong = const [],
  });
}

