/// 커리어 코칭 입력 모델 (간소화된 2단계)
class CareerCoachingInput {
  // Step 1: 현재 상황
  final String currentRole; // 현재 직무/역할 (경력 수준: junior, mid, senior 등)
  final String experienceLevel; // 경력 수준
  final String primaryConcern; // 핵심 고민
  final String? industry; // 업계 (선택) - deprecated, use field instead

  // F20: 분야 및 맞춤 포지션
  final String? field; // 분야 (tech, finance, healthcare 등)
  final String? position; // 분야별 맞춤 포지션 (developer, analyst 등)

  // Step 2: 목표와 가치
  final String shortTermGoal; // 3-6개월 목표
  final String coreValue; // 핵심 가치
  final List<String> skillsToImprove; // 개선하고 싶은 스킬

  CareerCoachingInput({
    required this.currentRole,
    required this.experienceLevel,
    required this.primaryConcern,
    this.industry,
    this.field,
    this.position,
    required this.shortTermGoal,
    required this.coreValue,
    required this.skillsToImprove,
  });
}

/// 커리어 코칭 결과 모델
class CareerCoachingResult {
  // 종합 분석
  final CareerHealthScore healthScore;
  final String overallAssessment;
  
  // 3가지 핵심 인사이트
  final List<CareerInsight> keyInsights;
  
  // 30일 액션 플랜
  final ActionPlan thirtyDayPlan;
  
  // 성장 로드맵
  final GrowthRoadmap growthRoadmap;
  
  // 추천 사항
  final CareerRecommendations recommendations;
  
  // 시장 트렌드
  final MarketTrends marketTrends;
  
  // 동기부여 메시지
  final String motivationalMessage;
  
  CareerCoachingResult({
    required this.healthScore,
    required this.overallAssessment,
    required this.keyInsights,
    required this.thirtyDayPlan,
    required this.growthRoadmap,
    required this.recommendations,
    required this.marketTrends,
    required this.motivationalMessage,
  });
}

/// 커리어 건강도 점수
class CareerHealthScore {
  final int overallScore; // 0-100
  final int growthScore; // 성장 가능성
  final int satisfactionScore; // 만족도
  final int marketScore; // 시장 경쟁력
  final int balanceScore; // 워라벨
  final String level; // excellent, good, moderate, needs-attention
  
  CareerHealthScore({
    required this.overallScore,
    required this.growthScore,
    required this.satisfactionScore,
    required this.marketScore,
    required this.balanceScore,
    required this.level,
  });
}

/// 커리어 인사이트
class CareerInsight {
  final String icon; // 아이콘 이모지
  final String title;
  final String description;
  final String impact; // high, medium, low
  final String category; // opportunity, warning, trend, advice
  
  CareerInsight({
    required this.icon,
    required this.title,
    required this.description,
    required this.impact,
    required this.category,
  });
}

/// 30일 액션 플랜
class ActionPlan {
  final List<WeeklyAction> weeks;
  final String focusArea;
  final String expectedOutcome;
  
  ActionPlan({
    required this.weeks,
    required this.focusArea,
    required this.expectedOutcome,
  });
}

/// 주간 액션
class WeeklyAction {
  final int weekNumber;
  final String theme;
  final List<String> tasks;
  final String milestone;
  
  WeeklyAction({
    required this.weekNumber,
    required this.theme,
    required this.tasks,
    required this.milestone,
  });
}

/// 성장 로드맵
class GrowthRoadmap {
  final String currentStage;
  final String nextStage;
  final int estimatedMonths; // 다음 단계까지 예상 기간
  final List<String> requiredSkills;
  final List<String> keyMilestones;
  final String growthStrategy;
  
  GrowthRoadmap({
    required this.currentStage,
    required this.nextStage,
    required this.estimatedMonths,
    required this.requiredSkills,
    required this.keyMilestones,
    required this.growthStrategy,
  });
}

/// 커리어 추천사항
class CareerRecommendations {
  final List<SkillRecommendation> skills;
  final List<String> courses;
  final List<String> books;
  final List<String> networkingOpportunities;
  final List<String> sideProjects;
  
  CareerRecommendations({
    required this.skills,
    required this.courses,
    required this.books,
    required this.networkingOpportunities,
    required this.sideProjects,
  });
}

/// 스킬 추천
class SkillRecommendation {
  final String name;
  final String priority; // critical, high, medium, low
  final String reason;
  final String learningPath;
  
  SkillRecommendation({
    required this.name,
    required this.priority,
    required this.reason,
    required this.learningPath,
  });
}

/// 시장 트렌드
class MarketTrends {
  final String industryOutlook; // positive, stable, challenging
  final List<String> emergingOpportunities;
  final List<String> decliningAreas;
  final String salaryTrend;
  final String demandLevel; // high, moderate, low
  
  MarketTrends({
    required this.industryOutlook,
    required this.emergingOpportunities,
    required this.decliningAreas,
    required this.salaryTrend,
    required this.demandLevel,
  });
}

/// 미리 정의된 현재 역할 옵션
const List<RoleOption> roleOptions = [
  RoleOption(id: 'junior', title: '주니어', emoji: '🌱', description: '1-3년차'),
  RoleOption(id: 'mid', title: '미드레벨', emoji: '🎯', description: '3-7년차'),
  RoleOption(id: 'senior', title: '시니어', emoji: '💎', description: '7년차 이상'),
  RoleOption(id: 'lead', title: '리드/매니저', emoji: '👥', description: '팀 관리'),
  RoleOption(id: 'freelance', title: '프리랜서', emoji: '💼', description: '독립 근무'),
  RoleOption(id: 'student', title: '학생/준비생', emoji: '📚', description: '취업 준비'),
];

/// 역할 옵션
class RoleOption {
  final String id;
  final String title;
  final String emoji;
  final String description;
  
  const RoleOption({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
  });
}

/// 핵심 고민 카드
const List<ConcernCard> concernCards = [
  ConcernCard(id: 'growth', title: '성장 정체', emoji: '📈', description: '더 이상 배울 게 없어요'),
  ConcernCard(id: 'direction', title: '방향성 고민', emoji: '🧭', description: '어디로 가야 할지 모르겠어요'),
  ConcernCard(id: 'transition', title: '이직/전직', emoji: '🚀', description: '새로운 기회를 찾고 있어요'),
  ConcernCard(id: 'balance', title: '워라벨', emoji: '⚖️', description: '일과 삶의 균형이 필요해요'),
  ConcernCard(id: 'compensation', title: '보상', emoji: '💰', description: '노력 대비 보상이 부족해요'),
  ConcernCard(id: 'relationship', title: '인간관계', emoji: '🤝', description: '직장 내 관계가 어려워요'),
];

/// 고민 카드
class ConcernCard {
  final String id;
  final String title;
  final String emoji;
  final String description;
  
  const ConcernCard({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
  });
}

/// 목표 옵션
const List<GoalOption> goalOptions = [
  GoalOption(id: 'promotion', title: '승진', emoji: '📊'),
  GoalOption(id: 'skillup', title: '스킬업', emoji: '💪'),
  GoalOption(id: 'transition', title: '이직', emoji: '🎯'),
  GoalOption(id: 'stability', title: '안정', emoji: '🛡️'),
  GoalOption(id: 'independence', title: '독립', emoji: '🚀'),
  GoalOption(id: 'leadership', title: '리더십', emoji: '👑'),
];

/// 목표 옵션
class GoalOption {
  final String id;
  final String title;
  final String emoji;
  
  const GoalOption({
    required this.id,
    required this.title,
    required this.emoji,
  });
}

/// 가치관 옵션
const List<ValueOption> valueOptions = [
  ValueOption(id: 'growth', title: '성장', color: 0xFF10B981),
  ValueOption(id: 'stability', title: '안정', color: 0xFF3B82F6),
  ValueOption(id: 'freedom', title: '자유', color: 0xFF8B5CF6),
  ValueOption(id: 'impact', title: '영향력', color: 0xFFF59E0B),
  ValueOption(id: 'money', title: '금전', color: 0xFFEF4444),
  ValueOption(id: 'balance', title: '균형', color: 0xFF6B7280),
];

/// 가치관 옵션
class ValueOption {
  final String id;
  final String title;
  final int color;
  
  const ValueOption({
    required this.id,
    required this.title,
    required this.color,
  });
}

/// 스킬 카테고리
const Map<String, List<String>> skillCategories = {
  '기술': ['프로그래밍', 'AI/ML', '클라우드', '데이터분석', '보안'],
  '비즈니스': ['전략기획', '프로젝트관리', '재무분석', '마케팅', '영업'],
  '소프트스킬': ['리더십', '커뮤니케이션', '문제해결', '협업', '시간관리'],
  '창의': ['디자인', 'UX/UI', '콘텐츠제작', '브랜딩', '스토리텔링'],
  '언어': ['영어', '중국어', '일본어', '프레젠테이션', '문서작성'],
};

/// F20: 분야(산업군) 옵션 - 먼저 분야를 선택하면 맞춤 포지션 표시
const List<FieldOption> fieldOptions = [
  FieldOption(id: 'tech', title: 'IT/테크', emoji: '💻', description: '소프트웨어, 하드웨어, AI'),
  FieldOption(id: 'finance', title: '금융', emoji: '💰', description: '은행, 증권, 보험, 핀테크'),
  FieldOption(id: 'healthcare', title: '의료/바이오', emoji: '🏥', description: '병원, 제약, 바이오텍'),
  FieldOption(id: 'education', title: '교육', emoji: '📚', description: '학교, 학원, 에듀테크'),
  FieldOption(id: 'service', title: '서비스업', emoji: '🛎️', description: '유통, 호텔, F&B'),
  FieldOption(id: 'manufacturing', title: '제조업', emoji: '🏭', description: '자동차, 전자, 화학'),
  FieldOption(id: 'media', title: '미디어/엔터', emoji: '🎬', description: '방송, 게임, 콘텐츠'),
  FieldOption(id: 'consulting', title: '컨설팅', emoji: '📊', description: '경영, 전략, 인사'),
  FieldOption(id: 'startup', title: '스타트업', emoji: '🚀', description: '초기창업, 성장기업'),
  FieldOption(id: 'public', title: '공공/비영리', emoji: '🏛️', description: '공기업, NGO, 정부'),
  FieldOption(id: 'other', title: '기타', emoji: '✨', description: '그 외 분야'),
];

/// 분야 옵션 클래스
class FieldOption {
  final String id;
  final String title;
  final String emoji;
  final String description;

  const FieldOption({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
  });
}

/// F20: 분야별 맞춤 포지션 - 선택한 분야에 따라 해당 포지션 목록 표시
const Map<String, List<PositionOption>> fieldPositions = {
  'tech': [
    PositionOption(id: 'developer', title: '개발자', emoji: '👨‍💻'),
    PositionOption(id: 'designer', title: '디자이너', emoji: '🎨'),
    PositionOption(id: 'pm', title: 'PM/기획자', emoji: '📋'),
    PositionOption(id: 'data', title: '데이터분석가', emoji: '📊'),
    PositionOption(id: 'qa', title: 'QA/테스터', emoji: '🔍'),
    PositionOption(id: 'devops', title: 'DevOps/인프라', emoji: '🔧'),
    PositionOption(id: 'ai', title: 'AI/ML 엔지니어', emoji: '🤖'),
    PositionOption(id: 'security', title: '보안전문가', emoji: '🔒'),
  ],
  'finance': [
    PositionOption(id: 'analyst', title: '애널리스트', emoji: '📈'),
    PositionOption(id: 'trader', title: '트레이더', emoji: '💹'),
    PositionOption(id: 'rm', title: 'RM/PB', emoji: '🤝'),
    PositionOption(id: 'risk', title: '리스크관리', emoji: '⚠️'),
    PositionOption(id: 'compliance', title: '컴플라이언스', emoji: '📜'),
    PositionOption(id: 'quant', title: '퀀트', emoji: '🔢'),
    PositionOption(id: 'accounting', title: '회계/재무', emoji: '💵'),
  ],
  'healthcare': [
    PositionOption(id: 'doctor', title: '의사', emoji: '👨‍⚕️'),
    PositionOption(id: 'nurse', title: '간호사', emoji: '👩‍⚕️'),
    PositionOption(id: 'pharmacist', title: '약사', emoji: '💊'),
    PositionOption(id: 'researcher', title: '연구원', emoji: '🔬'),
    PositionOption(id: 'biotech', title: '바이오엔지니어', emoji: '🧬'),
    PositionOption(id: 'clinical', title: '임상연구', emoji: '🧪'),
    PositionOption(id: 'admin', title: '병원행정', emoji: '🏥'),
  ],
  'education': [
    PositionOption(id: 'teacher', title: '교사', emoji: '👩‍🏫'),
    PositionOption(id: 'professor', title: '교수', emoji: '🎓'),
    PositionOption(id: 'tutor', title: '강사', emoji: '📖'),
    PositionOption(id: 'curriculum', title: '교육과정개발', emoji: '📝'),
    PositionOption(id: 'edtech', title: '에듀테크', emoji: '💻'),
    PositionOption(id: 'admin', title: '교육행정', emoji: '🏫'),
  ],
  'service': [
    PositionOption(id: 'retail', title: '유통/리테일', emoji: '🛍️'),
    PositionOption(id: 'hospitality', title: '호텔/관광', emoji: '🏨'),
    PositionOption(id: 'fnb', title: 'F&B', emoji: '🍽️'),
    PositionOption(id: 'cs', title: '고객서비스', emoji: '📞'),
    PositionOption(id: 'logistics', title: '물류', emoji: '📦'),
    PositionOption(id: 'sales', title: '영업', emoji: '🤝'),
  ],
  'manufacturing': [
    PositionOption(id: 'engineer', title: '생산엔지니어', emoji: '⚙️'),
    PositionOption(id: 'quality', title: '품질관리', emoji: '✅'),
    PositionOption(id: 'rnd', title: 'R&D', emoji: '🔬'),
    PositionOption(id: 'supply', title: '구매/자재', emoji: '📦'),
    PositionOption(id: 'maintenance', title: '설비관리', emoji: '🔧'),
    PositionOption(id: 'safety', title: '안전관리', emoji: '⛑️'),
  ],
  'media': [
    PositionOption(id: 'pd', title: 'PD/디렉터', emoji: '🎬'),
    PositionOption(id: 'writer', title: '작가/기자', emoji: '✍️'),
    PositionOption(id: 'creator', title: '콘텐츠크리에이터', emoji: '📱'),
    PositionOption(id: 'game', title: '게임개발', emoji: '🎮'),
    PositionOption(id: 'marketing', title: '마케팅', emoji: '📣'),
    PositionOption(id: 'art', title: '아티스트', emoji: '🎨'),
  ],
  'consulting': [
    PositionOption(id: 'strategy', title: '전략컨설턴트', emoji: '🎯'),
    PositionOption(id: 'operation', title: '운영컨설턴트', emoji: '⚙️'),
    PositionOption(id: 'hr', title: 'HR컨설턴트', emoji: '👥'),
    PositionOption(id: 'it', title: 'IT컨설턴트', emoji: '💻'),
    PositionOption(id: 'tax', title: '세무/회계', emoji: '📊'),
    PositionOption(id: 'legal', title: '법률자문', emoji: '⚖️'),
  ],
  'startup': [
    PositionOption(id: 'founder', title: '창업자/대표', emoji: '🚀'),
    PositionOption(id: 'cto', title: 'CTO/개발리드', emoji: '👨‍💻'),
    PositionOption(id: 'growth', title: '그로스해커', emoji: '📈'),
    PositionOption(id: 'ops', title: '운영총괄', emoji: '⚙️'),
    PositionOption(id: 'biz', title: '사업개발', emoji: '🤝'),
    PositionOption(id: 'product', title: '프로덕트매니저', emoji: '📋'),
  ],
  'public': [
    PositionOption(id: 'civil', title: '공무원', emoji: '🏛️'),
    PositionOption(id: 'researcher', title: '연구원', emoji: '🔬'),
    PositionOption(id: 'ngo', title: 'NGO활동가', emoji: '🌍'),
    PositionOption(id: 'policy', title: '정책기획', emoji: '📜'),
    PositionOption(id: 'social', title: '사회복지사', emoji: '❤️'),
    PositionOption(id: 'military', title: '군인/경찰', emoji: '👮'),
  ],
  'other': [
    PositionOption(id: 'freelance', title: '프리랜서', emoji: '💼'),
    PositionOption(id: 'artist', title: '예술가', emoji: '🎨'),
    PositionOption(id: 'athlete', title: '운동선수', emoji: '🏃'),
    PositionOption(id: 'influencer', title: '인플루언서', emoji: '📱'),
    PositionOption(id: 'entrepreneur', title: '개인사업자', emoji: '🏪'),
    PositionOption(id: 'etc', title: '기타', emoji: '✨'),
  ],
};

/// 포지션 옵션 클래스
class PositionOption {
  final String id;
  final String title;
  final String emoji;

  const PositionOption({
    required this.id,
    required this.title,
    required this.emoji,
  });
}