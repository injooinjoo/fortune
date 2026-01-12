import 'package:flutter/material.dart';
import 'package:fortune/core/constants/fortune_metadata.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/category_bar_chart.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/lucky_item_row.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/templates/score_template.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/templates/chart_template.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/templates/image_template.dart';
import 'package:fortune/features/fortune/presentation/widgets/infographic/templates/grid_template.dart';

/// 인포그래픽 템플릿 타입
enum InfographicTemplateType {
  /// 점수 중심 템플릿 (18개 운세)
  score,

  /// 차트/분석 중심 템플릿 (8개 운세)
  chart,

  /// 이미지 중심 템플릿 (6개 운세)
  image,

  /// 그리드/리스트 템플릿 (3개 운세)
  grid,

  /// 지원하지 않는 타입
  unsupported,
}

/// 인포그래픽 설정
class InfographicConfig {
  final InfographicTemplateType templateType;
  final String title;
  final Color? themeColor;
  final bool hasCategories;
  final bool hasLuckyItems;

  const InfographicConfig({
    required this.templateType,
    required this.title,
    this.themeColor,
    this.hasCategories = false,
    this.hasLuckyItems = false,
  });
}

/// 운세 타입별 인포그래픽 템플릿 매핑 팩토리
///
/// 각 운세 타입에 맞는 인포그래픽 템플릿과 설정을 제공합니다.
/// 템플릿 분류:
/// - Score Template (18개): 점수 중심
/// - Chart Template (8개): 차트/분석 중심
/// - Image Template (6개): 이미지 중심
/// - Grid Template (3개): 그리드/리스트
class InfographicFactory {
  InfographicFactory._();

  /// FortuneType에 해당하는 인포그래픽 설정 반환
  static InfographicConfig getConfig(FortuneType type) {
    return _configMap[type] ??
        InfographicConfig(
          templateType: InfographicTemplateType.unsupported,
          title: type.displayName,
        );
  }

  /// FortuneType에 해당하는 템플릿 타입 반환
  static InfographicTemplateType getTemplateType(FortuneType type) {
    return getConfig(type).templateType;
  }

  /// 해당 운세 타입이 인포그래픽을 지원하는지 확인
  static bool isSupported(FortuneType type) {
    return getTemplateType(type) != InfographicTemplateType.unsupported;
  }

  /// Score 템플릿을 사용하는 운세 타입 목록
  static List<FortuneType> get scoreTemplateTypes => _configMap.entries
      .where((e) => e.value.templateType == InfographicTemplateType.score)
      .map((e) => e.key)
      .toList();

  /// Chart 템플릿을 사용하는 운세 타입 목록
  static List<FortuneType> get chartTemplateTypes => _configMap.entries
      .where((e) => e.value.templateType == InfographicTemplateType.chart)
      .map((e) => e.key)
      .toList();

  /// Image 템플릿을 사용하는 운세 타입 목록
  static List<FortuneType> get imageTemplateTypes => _configMap.entries
      .where((e) => e.value.templateType == InfographicTemplateType.image)
      .map((e) => e.key)
      .toList();

  /// Grid 템플릿을 사용하는 운세 타입 목록
  static List<FortuneType> get gridTemplateTypes => _configMap.entries
      .where((e) => e.value.templateType == InfographicTemplateType.grid)
      .map((e) => e.key)
      .toList();

  /// 운세 타입별 인포그래픽 설정 매핑
  static final Map<FortuneType, InfographicConfig> _configMap = {
    // ==========================================
    // Score Template (점수 중심) - 18개
    // ==========================================

    // 일일/기간별 운세
    FortuneType.daily: const InfographicConfig(
      templateType: InfographicTemplateType.score,
      title: '오늘의 인사이트',
      themeColor: Color(0xFF4A90E2),
      hasCategories: true,
      hasLuckyItems: true,
    ),
    FortuneType.weekly: const InfographicConfig(
      templateType: InfographicTemplateType.score,
      title: '주간 인사이트',
      themeColor: Color(0xFF50C878),
      hasCategories: true,
      hasLuckyItems: true,
    ),
    FortuneType.monthly: const InfographicConfig(
      templateType: InfographicTemplateType.score,
      title: '월간 인사이트',
      themeColor: Color(0xFF7B68EE),
      hasCategories: true,
      hasLuckyItems: true,
    ),
    FortuneType.yearly: const InfographicConfig(
      templateType: InfographicTemplateType.score,
      title: '연간 인사이트',
      themeColor: Color(0xFFFFD700),
      hasCategories: true,
      hasLuckyItems: true,
    ),

    // 연애/관계 운세
    FortuneType.love: const InfographicConfig(
      templateType: InfographicTemplateType.score,
      title: '연애 운세',
      themeColor: Color(0xFFFF69B4),
      hasLuckyItems: true,
    ),
    FortuneType.blindDate: const InfographicConfig(
      templateType: InfographicTemplateType.score,
      title: '소개팅 가이드',
      themeColor: Color(0xFFFF8C9E),
      hasLuckyItems: true,
    ),
    FortuneType.exLover: const InfographicConfig(
      templateType: InfographicTemplateType.score,
      title: '재회 분석',
      themeColor: Color(0xFFDDA0DD),
    ),
    FortuneType.avoidPeople: const InfographicConfig(
      templateType: InfographicTemplateType.score,
      title: '오늘의 경계운',
      themeColor: Color(0xFFE74C3C),
    ),

    // 직업/학업 운세
    FortuneType.career: const InfographicConfig(
      templateType: InfographicTemplateType.score,
      title: '직업 운세',
      themeColor: Color(0xFF4169E1),
      hasCategories: true,
    ),
    FortuneType.exam: const InfographicConfig(
      templateType: InfographicTemplateType.score,
      title: '시험 가이드',
      themeColor: Color(0xFF20B2AA),
      hasLuckyItems: true,
    ),

    // 건강/운동 운세
    FortuneType.health: const InfographicConfig(
      templateType: InfographicTemplateType.score,
      title: '건강 체크',
      themeColor: Color(0xFF32CD32),
    ),
    FortuneType.biorhythm: const InfographicConfig(
      templateType: InfographicTemplateType.score,
      title: '바이오리듬',
      themeColor: Color(0xFF00CED1),
    ),

    // 풍수/이사 운세
    FortuneType.moving: const InfographicConfig(
      templateType: InfographicTemplateType.score,
      title: '이사 가이드',
      themeColor: Color(0xFF8B7355),
      hasLuckyItems: true,
    ),

    // 관계 운세
    FortuneType.family: const InfographicConfig(
      templateType: InfographicTemplateType.score,
      title: '가족 인사이트',
      themeColor: Color(0xFF8B5CF6),
      hasCategories: true,
      hasLuckyItems: true,
    ),
    FortuneType.pet: const InfographicConfig(
      templateType: InfographicTemplateType.score,
      title: '반려동물 가이드',
      themeColor: Color(0xFFFF7F50),
    ),

    // 유명인 매칭
    FortuneType.sameBirthdayCelebrity: const InfographicConfig(
      templateType: InfographicTemplateType.score,
      title: '같은 생일 유명인',
      themeColor: Color(0xFFDA70D6),
    ),

    // 메시지 기반
    FortuneType.today: const InfographicConfig(
      templateType: InfographicTemplateType.score,
      title: '오늘의 메시지',
      themeColor: Color(0xFF6A5ACD),
    ),
    FortuneType.dailyInspiration: const InfographicConfig(
      templateType: InfographicTemplateType.score,
      title: '오늘의 영감',
      themeColor: Color(0xFFFF6347),
    ),

    // ==========================================
    // Chart Template (차트/분석 중심) - 8개
    // ==========================================

    // 사주 분석
    FortuneType.saju: const InfographicConfig(
      templateType: InfographicTemplateType.chart,
      title: '사주 분석',
      themeColor: Color(0xFFDC143C),
    ),
    FortuneType.traditionalSaju: const InfographicConfig(
      templateType: InfographicTemplateType.chart,
      title: '전통 사주',
      themeColor: Color(0xFFB22222),
    ),

    // MBTI 분석
    FortuneType.mbti: const InfographicConfig(
      templateType: InfographicTemplateType.chart,
      title: 'MBTI 분석',
      themeColor: Color(0xFF9370DB),
    ),

    // 성격/재능 분석
    FortuneType.personality: const InfographicConfig(
      templateType: InfographicTemplateType.chart,
      title: '성격 DNA',
      themeColor: Color(0xFF8A2BE2),
    ),
    FortuneType.talent: const InfographicConfig(
      templateType: InfographicTemplateType.chart,
      title: '재능 분석',
      themeColor: Color(0xFFFF8C00),
    ),

    // 궁합 분석
    FortuneType.compatibility: const InfographicConfig(
      templateType: InfographicTemplateType.chart,
      title: '궁합 분석',
      themeColor: Color(0xFFFF6B6B),
    ),

    // 재물 분석
    FortuneType.investment: const InfographicConfig(
      templateType: InfographicTemplateType.chart,
      title: '투자 인사이트',
      themeColor: Color(0xFFFFD700),
    ),
    FortuneType.wealth: const InfographicConfig(
      templateType: InfographicTemplateType.chart,
      title: '재물 분석',
      themeColor: Color(0xFFFFA500),
    ),
    FortuneType.money: const InfographicConfig(
      templateType: InfographicTemplateType.chart,
      title: '재물운',
      themeColor: Color(0xFF16A34A),
    ),

    // 스포츠 분석
    FortuneType.sports: const InfographicConfig(
      templateType: InfographicTemplateType.chart,
      title: '경기 분석',
      themeColor: Color(0xFF228B22),
    ),

    // ==========================================
    // Image Template (이미지 중심) - 6개
    // ==========================================

    // 타로
    FortuneType.tarot: const InfographicConfig(
      templateType: InfographicTemplateType.image,
      title: 'Insight Cards',
      themeColor: Color(0xFF4B0082),
    ),

    // 부적/행운 카드
    FortuneType.talisman: const InfographicConfig(
      templateType: InfographicTemplateType.image,
      title: '행운 카드',
      themeColor: Color(0xFFFFD700),
    ),

    // 전생
    FortuneType.pastLife: const InfographicConfig(
      templateType: InfographicTemplateType.image,
      title: '전생 이야기',
      themeColor: Color(0xFF8B4513),
    ),

    // 관상
    FortuneType.physiognomy: const InfographicConfig(
      templateType: InfographicTemplateType.image,
      title: 'Face AI',
      themeColor: Color(0xFF87CEEB),
    ),

    // 관상 (face-reading 타입)
    FortuneType.faceReading: const InfographicConfig(
      templateType: InfographicTemplateType.image,
      title: 'AI 관상',
      themeColor: Color(0xFF87CEEB),
    ),

    // 꿈 해석
    FortuneType.dream: const InfographicConfig(
      templateType: InfographicTemplateType.image,
      title: '꿈 분석',
      themeColor: Color(0xFF483D8B),
    ),

    // 손금
    FortuneType.palmistry: const InfographicConfig(
      templateType: InfographicTemplateType.image,
      title: '손금 분석',
      themeColor: Color(0xFFDEB887),
    ),

    // ==========================================
    // Grid Template (그리드/리스트) - 3개
    // ==========================================

    // 행운 아이템
    FortuneType.luckyItems: const InfographicConfig(
      templateType: InfographicTemplateType.grid,
      title: '오늘의 행운 아이템',
      themeColor: Color(0xFF9C27B0),
    ),

    // 로또 번호
    FortuneType.luckyLottery: const InfographicConfig(
      templateType: InfographicTemplateType.grid,
      title: '로또 번호 생성',
      themeColor: Color(0xFFFF4500),
    ),

    // 오늘의 로또 (클라이언트 생성)
    FortuneType.lotto: const InfographicConfig(
      templateType: InfographicTemplateType.grid,
      title: '오늘의 로또',
      themeColor: Color(0xFFFFD700),
      hasLuckyItems: true,
    ),

    // 이름 분석
    FortuneType.nameAnalysis: const InfographicConfig(
      templateType: InfographicTemplateType.grid,
      title: 'AI 작명',
      themeColor: Color(0xFF4682B4),
    ),
  };

  /// 기본 Score 인포그래픽 위젯 생성
  ///
  /// [fortuneType] 운세 타입
  /// [score] 점수 (0-100)
  /// [categories] 카테고리 데이터 (선택)
  /// [luckyItems] 행운 아이템 (선택)
  /// [isShareMode] 공유 모드 (개인정보 숨김)
  static Widget buildScoreInfographic({
    required FortuneType fortuneType,
    required int score,
    List<CategoryData>? categories,
    List<LuckyItem>? luckyItems,
    bool isShareMode = false,
  }) {
    final config = getConfig(fortuneType);

    return ScoreTemplate(
      title: config.title,
      score: score,
      categories: categories,
      luckyItems: luckyItems,
      progressColor: config.themeColor,
      isShareMode: isShareMode,
    );
  }

  /// 기본 Chart 인포그래픽 위젯 생성
  ///
  /// [fortuneType] 운세 타입
  /// [chartWidget] 차트 위젯
  /// [headerWidget] 헤더 위젯 (선택)
  /// [footerWidget] 푸터 위젯 (선택)
  /// [isShareMode] 공유 모드
  static Widget buildChartInfographic({
    required FortuneType fortuneType,
    required Widget chartWidget,
    Widget? headerWidget,
    Widget? footerWidget,
    bool isShareMode = false,
  }) {
    final config = getConfig(fortuneType);

    return ChartTemplate(
      title: config.title,
      chartWidget: chartWidget,
      headerWidget: headerWidget,
      footerWidget: footerWidget,
      isShareMode: isShareMode,
    );
  }

  /// 기본 Image 인포그래픽 위젯 생성
  ///
  /// [fortuneType] 운세 타입
  /// [imageWidget] 이미지 위젯
  /// [footerWidget] 푸터 위젯 (선택)
  /// [isShareMode] 공유 모드
  static Widget buildImageInfographic({
    required FortuneType fortuneType,
    required Widget imageWidget,
    Widget? footerWidget,
    bool isShareMode = false,
  }) {
    final config = getConfig(fortuneType);

    return ImageTemplate(
      title: config.title,
      imageWidget: imageWidget,
      footerWidget: footerWidget,
      isShareMode: isShareMode,
    );
  }

  /// 기본 Grid 인포그래픽 위젯 생성
  ///
  /// [fortuneType] 운세 타입
  /// [gridWidget] 그리드 위젯
  /// [headerWidget] 헤더 위젯 (선택)
  /// [footerWidget] 푸터 위젯 (선택)
  /// [isShareMode] 공유 모드
  static Widget buildGridInfographic({
    required FortuneType fortuneType,
    required Widget gridWidget,
    Widget? headerWidget,
    Widget? footerWidget,
    bool isShareMode = false,
  }) {
    final config = getConfig(fortuneType);

    return GridTemplate(
      title: config.title,
      gridWidget: gridWidget,
      headerWidget: headerWidget,
      footerWidget: footerWidget,
      isShareMode: isShareMode,
    );
  }

  // ==========================================
  // Specialized Template Builders
  // ==========================================

  /// 일일 운세 인포그래픽 생성
  static Widget buildDailyInfographic({
    required int score,
    required List<CategoryData> categories,
    String? luckyColor,
    Color? luckyColorValue,
    int? luckyNumber,
    String? luckyTime,
    DateTime? date,
    bool isShareMode = false,
  }) {
    return DailyScoreTemplate(
      score: score,
      categories: categories,
      luckyColor: luckyColor,
      luckyColorValue: luckyColorValue,
      luckyNumber: luckyNumber,
      luckyTime: luckyTime,
      date: date,
      isShareMode: isShareMode,
    );
  }

  /// 주간 운세 인포그래픽 생성
  static Widget buildWeeklyInfographic({
    required int score,
    required String weekRange,
    List<CategoryData>? categories,
    int? luckyDay,
    String? luckyDayLabel,
    String? advice,
    bool isShareMode = false,
  }) {
    return WeeklyScoreTemplate(
      score: score,
      weekRange: weekRange,
      categories: categories,
      luckyDay: luckyDay,
      luckyDayLabel: luckyDayLabel,
      advice: advice,
      isShareMode: isShareMode,
    );
  }

  /// 월간 운세 인포그래픽 생성
  static Widget buildMonthlyInfographic({
    required int score,
    required String monthLabel,
    List<CategoryData>? categories,
    List<int>? luckyDates,
    String? advice,
    bool isShareMode = false,
  }) {
    return MonthlyScoreTemplate(
      score: score,
      monthLabel: monthLabel,
      categories: categories,
      luckyDates: luckyDates,
      advice: advice,
      isShareMode: isShareMode,
    );
  }

  /// 연간 운세 인포그래픽 생성
  static Widget buildYearlyInfographic({
    required int score,
    required String yearLabel,
    List<CategoryData>? categories,
    List<int>? luckyMonths,
    String? yearKeyword,
    String? advice,
    bool isShareMode = false,
  }) {
    return YearlyScoreTemplate(
      score: score,
      yearLabel: yearLabel,
      categories: categories,
      luckyMonths: luckyMonths,
      yearKeyword: yearKeyword,
      advice: advice,
      isShareMode: isShareMode,
    );
  }

  /// 연애 운세 인포그래픽 생성
  static Widget buildLoveInfographic({
    required int score,
    int? encounterProbability,
    List<String>? tips,
    String? luckyPlace,
    String? luckyColor,
    String? luckyTime,
    String? luckyItem,
    DateTime? date,
    bool isShareMode = false,
  }) {
    return LoveScoreTemplate(
      score: score,
      encounterProbability: encounterProbability,
      tips: tips,
      luckyPlace: luckyPlace,
      luckyColor: luckyColor,
      luckyTime: luckyTime,
      luckyItem: luckyItem,
      date: date,
      isShareMode: isShareMode,
    );
  }

  /// 직업 운세 인포그래픽 생성
  static Widget buildCareerInfographic({
    required int score,
    int? percentile,
    int? employmentScore,
    int? businessScore,
    int? promotionScore,
    int? jobChangeScore,
    List<String>? keywords,
    String? advice,
    DateTime? date,
    bool isShareMode = false,
  }) {
    return CareerScoreTemplate(
      score: score,
      percentile: percentile,
      employmentScore: employmentScore,
      businessScore: businessScore,
      promotionScore: promotionScore,
      jobChangeScore: jobChangeScore,
      keywords: keywords,
      advice: advice,
      date: date,
      isShareMode: isShareMode,
    );
  }

  /// 바이오리듬 인포그래픽 생성
  ///
  /// [physicalScore], [emotionalScore], [intellectualScore] 각 리듬 점수
  /// [summaryPoints] 점수 아래 표시할 요약 포인트 (최대 3개)
  static Widget buildBiorhythmInfographic({
    required int physicalScore,
    required int emotionalScore,
    required int intellectualScore,
    String? physicalPhase,
    String? emotionalPhase,
    String? intellectualPhase,
    List<String>? summaryPoints,
    int overallRating = 3,
    String? advice,
    bool isShareMode = false,
  }) {
    return BiorhythmScoreTemplate(
      physicalScore: physicalScore,
      emotionalScore: emotionalScore,
      intellectualScore: intellectualScore,
      physicalPhase: physicalPhase,
      emotionalPhase: emotionalPhase,
      intellectualPhase: intellectualPhase,
      summaryPoints: summaryPoints,
      overallRating: overallRating,
      advice: advice,
      isShareMode: isShareMode,
    );
  }

  /// 궁합 분석 인포그래픽 생성
  static Widget buildCompatibilityInfographic({
    required int overallScore,
    required List<CompatibilityCategory> categories,
    String? personAName,
    String? personBName,
    String? summary,
    bool isShareMode = false,
  }) {
    return CompatibilityChartTemplate(
      overallScore: overallScore,
      categories: categories,
      personAName: personAName,
      personBName: personBName,
      summary: summary,
      isShareMode: isShareMode,
    );
  }

  /// 사주 분석 인포그래픽 생성
  static Widget buildSajuInfographic({
    required List<SajuPillar> pillars,
    required Map<String, int> elements,
    String? geukguk,
    String? yongshin,
    String? interpretation,
    DateTime? date,
    bool isShareMode = false,
  }) {
    return SajuChartTemplate(
      pillars: pillars,
      elements: elements,
      geukguk: geukguk,
      yongshin: yongshin,
      interpretation: interpretation,
      date: date,
      isShareMode: isShareMode,
    );
  }

  /// MBTI 분석 인포그래픽 생성
  static Widget buildMbtiInfographic({
    required String mbtiType,
    required List<MbtiDimension> dimensions,
    String? todayMessage,
    String? warning,
    bool isShareMode = false,
  }) {
    return MbtiChartTemplate(
      mbtiType: mbtiType,
      dimensions: dimensions,
      todayMessage: todayMessage,
      warning: warning,
      isShareMode: isShareMode,
    );
  }

  /// 스포츠 경기 분석 인포그래픽 생성
  static Widget buildSportsInfographic({
    required String teamA,
    required String teamB,
    required int teamAWinRate,
    String? matchInfo,
    String? teamAAnalysis,
    String? teamBAnalysis,
    List<String>? luckyItems,
    DateTime? date,
    bool isShareMode = false,
  }) {
    return SportsChartTemplate(
      teamA: teamA,
      teamB: teamB,
      teamAWinRate: teamAWinRate,
      matchInfo: matchInfo,
      teamAAnalysis: teamAAnalysis,
      teamBAnalysis: teamBAnalysis,
      luckyItems: luckyItems,
      date: date,
      isShareMode: isShareMode,
    );
  }

  /// 성격 DNA 인포그래픽 생성
  static Widget buildPersonalityDnaInfographic({
    required String mbti,
    required String bloodType,
    required String zodiac,
    required String chineseZodiac,
    required String personalityType,
    List<DnaScore>? scores,
    String? powerColor,
    Color? powerColorValue,
    bool isShareMode = false,
  }) {
    return PersonalityDnaChartTemplate(
      mbti: mbti,
      bloodType: bloodType,
      zodiac: zodiac,
      chineseZodiac: chineseZodiac,
      personalityType: personalityType,
      scores: scores,
      powerColor: powerColor,
      powerColorValue: powerColorValue,
      isShareMode: isShareMode,
    );
  }

  /// 재능 분석 인포그래픽 생성
  static Widget buildTalentInfographic({
    required int overallScore,
    required List<TalentData> talents,
    String? topTalent,
    String? advice,
    bool isShareMode = false,
  }) {
    return TalentChartTemplate(
      overallScore: overallScore,
      talents: talents,
      topTalent: topTalent,
      advice: advice,
      isShareMode: isShareMode,
    );
  }

  /// 재물 운세 인포그래픽 생성
  static Widget buildInvestmentInfographic({
    required int overallScore,
    required List<InvestmentSector> sectors,
    String? topSector,
    String? bottomSector,
    String? advice,
    bool isShareMode = false,
  }) {
    return InvestmentChartTemplate(
      overallScore: overallScore,
      sectors: sectors,
      topSector: topSector,
      bottomSector: bottomSector,
      advice: advice,
      isShareMode: isShareMode,
    );
  }

  /// 경계 대상 운세 인포그래픽 생성
  ///
  /// [score] 경계 지수 (0-100)
  /// [categoryCounts] 카테고리별 경계 대상 개수
  /// [luckyElements] 행운 요소 (색상, 숫자, 방향, 시간)
  /// [timeStrategy] 시간대별 전략 (오전/오후/저녁)
  /// [summary] 요약 메시지
  /// [isShareMode] 공유 모드
  static Widget buildAvoidPeopleInfographic({
    required int score,
    Map<String, int>? categoryCounts,
    Map<String, String>? luckyElements,
    Map<String, Map<String, String>>? timeStrategy,
    String? summary,
    bool isShareMode = false,
  }) {
    return AvoidPeopleScoreTemplate(
      riskScore: score,
      categoryCounts: categoryCounts,
      luckyElements: luckyElements,
      timeStrategy: timeStrategy,
      summary: summary,
      isShareMode: isShareMode,
    );
  }

  /// 소개팅 운세 인포그래픽 생성
  ///
  /// [score] 종합 점수 (0-100)
  /// [summary] 한줄 요약 (점수 바로 아래)
  /// [keyPoints] 핵심 포인트 3개
  /// [overallAdvice] 종합 조언 (하이라이트 박스)
  /// [successRate] 성공 확률
  /// [idealType] 오늘의 이상형
  /// [tips] 소개팅 팁 목록
  /// [luckyPlace] 추천 장소
  /// [isShareMode] 공유 모드
  static Widget buildBlindDateInfographic({
    required int score,
    String? summary,
    List<String>? keyPoints,
    String? overallAdvice,
    int? successRate,
    String? idealType,
    List<String>? tips,
    String? luckyPlace,
    bool isShareMode = false,
  }) {
    return BlindDateScoreTemplate(
      score: score,
      summary: summary,
      keyPoints: keyPoints,
      overallAdvice: overallAdvice,
      successRate: successRate,
      idealType: idealType,
      tips: tips,
      luckyPlace: luckyPlace,
      isShareMode: isShareMode,
    );
  }
}
