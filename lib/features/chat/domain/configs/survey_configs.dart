import '../../../../core/theme/fortune_colors.dart';
import '../models/fortune_survey_config.dart';

/// 운세별 설문 설정 정의

// ============================================================
// Career (커리어) 설문 설정
// ============================================================

/// 분야 옵션
const _fieldOptions = [
  SurveyOption(id: 'tech', label: 'IT/개발', emoji: '💻'),
  SurveyOption(id: 'finance', label: '금융/재무', emoji: '💰'),
  SurveyOption(id: 'healthcare', label: '의료/헬스케어', emoji: '🏥'),
  SurveyOption(id: 'education', label: '교육', emoji: '📚'),
  SurveyOption(id: 'creative', label: '크리에이티브', emoji: '🎨'),
  SurveyOption(id: 'marketing', label: '마케팅/광고', emoji: '📢'),
  SurveyOption(id: 'sales', label: '영업/세일즈', emoji: '🤝'),
  SurveyOption(id: 'hr', label: '인사/HR', emoji: '👥'),
  SurveyOption(id: 'legal', label: '법률/법무', emoji: '⚖️'),
  SurveyOption(id: 'manufacturing', label: '제조/생산', emoji: '🏭'),
  SurveyOption(id: 'other', label: '기타', emoji: '✨'),
];

/// 분야별 포지션 옵션
const Map<String, List<SurveyOption>> _positionsByField = {
  'tech': [
    SurveyOption(id: 'frontend', label: '프론트엔드'),
    SurveyOption(id: 'backend', label: '백엔드'),
    SurveyOption(id: 'fullstack', label: '풀스택'),
    SurveyOption(id: 'mobile', label: '모바일'),
    SurveyOption(id: 'data', label: '데이터/AI'),
    SurveyOption(id: 'devops', label: 'DevOps'),
    SurveyOption(id: 'pm', label: 'PM/PO'),
  ],
  'finance': [
    SurveyOption(id: 'analyst', label: '애널리스트'),
    SurveyOption(id: 'accountant', label: '회계사'),
    SurveyOption(id: 'banker', label: '은행원'),
    SurveyOption(id: 'trader', label: '트레이더'),
    SurveyOption(id: 'auditor', label: '감사'),
  ],
  'healthcare': [
    SurveyOption(id: 'doctor', label: '의사'),
    SurveyOption(id: 'nurse', label: '간호사'),
    SurveyOption(id: 'pharmacist', label: '약사'),
    SurveyOption(id: 'researcher', label: '연구원'),
    SurveyOption(id: 'admin', label: '의료행정'),
  ],
  'education': [
    SurveyOption(id: 'teacher', label: '교사'),
    SurveyOption(id: 'professor', label: '교수'),
    SurveyOption(id: 'tutor', label: '강사'),
    SurveyOption(id: 'admin', label: '교육행정'),
  ],
  'creative': [
    SurveyOption(id: 'designer', label: '디자이너'),
    SurveyOption(id: 'writer', label: '작가/카피라이터'),
    SurveyOption(id: 'photographer', label: '포토그래퍼'),
    SurveyOption(id: 'director', label: '감독/PD'),
  ],
  'marketing': [
    SurveyOption(id: 'marketer', label: '마케터'),
    SurveyOption(id: 'planner', label: '기획자'),
    SurveyOption(id: 'brand', label: '브랜드 매니저'),
    SurveyOption(id: 'performance', label: '퍼포먼스 마케터'),
  ],
  'sales': [
    SurveyOption(id: 'sales_rep', label: '영업 담당자'),
    SurveyOption(id: 'account', label: '어카운트 매니저'),
    SurveyOption(id: 'bd', label: 'BD/사업개발'),
  ],
  'hr': [
    SurveyOption(id: 'recruiter', label: '채용 담당자'),
    SurveyOption(id: 'hrbp', label: 'HRBP'),
    SurveyOption(id: 'training', label: '교육/연수'),
  ],
  'legal': [
    SurveyOption(id: 'lawyer', label: '변호사'),
    SurveyOption(id: 'paralegal', label: '법무팀'),
    SurveyOption(id: 'compliance', label: '컴플라이언스'),
  ],
  'manufacturing': [
    SurveyOption(id: 'engineer', label: '엔지니어'),
    SurveyOption(id: 'manager', label: '생산 관리'),
    SurveyOption(id: 'quality', label: '품질 관리'),
  ],
  'other': [
    SurveyOption(id: 'general', label: '일반 사무직'),
    SurveyOption(id: 'specialist', label: '전문직'),
    SurveyOption(id: 'freelance', label: '프리랜서'),
  ],
};

/// 경력 수준 옵션
const _experienceOptions = [
  SurveyOption(id: 'student', label: '학생/취준생', emoji: '🎓'),
  SurveyOption(id: 'junior', label: '신입 (0-2년)', emoji: '🌱'),
  SurveyOption(id: 'mid', label: '주니어 (3-5년)', emoji: '🌿'),
  SurveyOption(id: 'senior', label: '시니어 (6-10년)', emoji: '🌳'),
  SurveyOption(id: 'lead', label: '리드급 (10년+)', emoji: '🌲'),
  SurveyOption(id: 'executive', label: '임원급', emoji: '👔'),
];

/// 핵심 고민 옵션
const _concernOptions = [
  SurveyOption(id: 'growth', label: '성장 정체', emoji: '📈'),
  SurveyOption(id: 'direction', label: '방향성 고민', emoji: '🧭'),
  SurveyOption(id: 'change', label: '이직/전직', emoji: '🔄'),
  SurveyOption(id: 'balance', label: '워라밸', emoji: '⚖️'),
  SurveyOption(id: 'salary', label: '연봉/처우', emoji: '💵'),
  SurveyOption(id: 'relationship', label: '직장 내 관계', emoji: '👥'),
];

/// Career 설문 설정
final careerSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.career,
  title: '커리어 운세',
  description: '당신의 커리어 방향을 알려드릴게요',
  emoji: '💼',
  accentColor: FortuneColors.career,
  steps: [
    const SurveyStep(
      id: 'field',
      question: '어떤 분야에서 일하고 계신가요?',
      inputType: SurveyInputType.chips,
      options: _fieldOptions,
    ),
    const SurveyStep(
      id: 'position',
      question: '현재 포지션이 어떻게 되세요?',
      inputType: SurveyInputType.chips,
      dependsOn: 'field',
      options: [], // 동적으로 로드됨
    ),
    const SurveyStep(
      id: 'experience',
      question: '경력은 어느 정도 되셨나요?',
      inputType: SurveyInputType.chips,
      options: _experienceOptions,
    ),
    const SurveyStep(
      id: 'concern',
      question: '요즘 가장 큰 고민은 뭔가요?',
      inputType: SurveyInputType.chips,
      options: _concernOptions,
    ),
  ],
);

// ============================================================
// Love (연애) 설문 설정
// ============================================================

/// 연애 상태 옵션
const _relationshipStatusOptions = [
  SurveyOption(id: 'single', label: '솔로', emoji: '💔'),
  SurveyOption(id: 'dating', label: '연애 중', emoji: '💕'),
  SurveyOption(id: 'crush', label: '짝사랑', emoji: '💘'),
  SurveyOption(id: 'complicated', label: '복잡한 관계', emoji: '💫'),
];

/// 연애 고민 옵션
const _loveConcernOptions = [
  SurveyOption(id: 'meeting', label: '만남/인연', emoji: '🤝'),
  SurveyOption(id: 'confession', label: '고백 타이밍', emoji: '💌'),
  SurveyOption(id: 'relationship', label: '관계 발전', emoji: '💞'),
  SurveyOption(id: 'conflict', label: '갈등 해결', emoji: '🌧️'),
  SurveyOption(id: 'future', label: '미래/결혼', emoji: '💒'),
  SurveyOption(id: 'breakup', label: '이별/재회', emoji: '🍂'),
];

/// 연애 스타일 옵션
const _datingStyleOptions = [
  SurveyOption(id: 'active', label: '적극적', emoji: '🔥'),
  SurveyOption(id: 'passive', label: '수동적', emoji: '🌙'),
  SurveyOption(id: 'romantic', label: '로맨틱', emoji: '🌹'),
  SurveyOption(id: 'practical', label: '현실적', emoji: '💼'),
  SurveyOption(id: 'clingy', label: '애정 표현 많이', emoji: '🤗'),
  SurveyOption(id: 'independent', label: '개인 시간 중요', emoji: '🧘'),
];

/// 이상형 스타일 옵션
const _idealTypeOptions = [
  SurveyOption(id: 'kind', label: '따뜻한', emoji: '🥰'),
  SurveyOption(id: 'funny', label: '유머러스', emoji: '😄'),
  SurveyOption(id: 'smart', label: '똑똒한', emoji: '🧠'),
  SurveyOption(id: 'stable', label: '안정적인', emoji: '🏠'),
  SurveyOption(id: 'passionate', label: '열정적인', emoji: '🔥'),
  SurveyOption(id: 'calm', label: '차분한', emoji: '🌊'),
];

/// Love 설문 설정
final loveSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.love,
  title: '연애 운세',
  description: '당신의 사랑 운을 알려드릴게요',
  emoji: '💕',
  accentColor: FortuneColors.love,
  steps: [
    const SurveyStep(
      id: 'status',
      question: '지금 연애 상태가 어때? 💕',
      inputType: SurveyInputType.chips,
      options: _relationshipStatusOptions,
    ),
    const SurveyStep(
      id: 'concern',
      question: '가장 궁금한 게 뭐야? 🤔',
      inputType: SurveyInputType.chips,
      options: _loveConcernOptions,
    ),
    const SurveyStep(
      id: 'datingStyle',
      question: '연애할 때 어떤 스타일이야? 💝',
      inputType: SurveyInputType.multiSelect,
      options: _datingStyleOptions,
      isRequired: false,
    ),
    const SurveyStep(
      id: 'idealType',
      question: '이상형은 어떤 스타일이야? ✨',
      inputType: SurveyInputType.multiSelect,
      options: _idealTypeOptions,
      isRequired: false,
      showWhen: {'status': ['single', 'crush']},
    ),
  ],
);

// ============================================================
// Daily (오늘의 운세) 설문 설정
// ============================================================

/// Daily 설문 설정 (설문 스킵 - 바로 운세 조회)
final dailySurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.daily,
  title: '오늘의 운세',
  description: '오늘 하루를 미리 살펴볼까요?',
  emoji: '🌅',
  accentColor: FortuneColors.daily,
  steps: [], // 설문 없이 바로 API 호출
);

// ============================================================
// Talent (적성/재능) 설문 설정
// ============================================================

/// 관심 분야 옵션
const _interestAreaOptions = [
  SurveyOption(id: 'creative', label: '예술/창작', emoji: '🎨'),
  SurveyOption(id: 'business', label: '비즈니스/경영', emoji: '📊'),
  SurveyOption(id: 'tech', label: 'IT/기술', emoji: '💻'),
  SurveyOption(id: 'people', label: '사람/소통', emoji: '🗣️'),
  SurveyOption(id: 'science', label: '과학/연구', emoji: '🔬'),
  SurveyOption(id: 'service', label: '서비스/봉사', emoji: '🤲'),
];

/// 성향 옵션
const _workStyleOptions = [
  SurveyOption(id: 'solo', label: '혼자 집중해서'),
  SurveyOption(id: 'team', label: '팀과 협업하며'),
];

const _problemSolvingOptions = [
  SurveyOption(id: 'logical', label: '논리적으로 분석'),
  SurveyOption(id: 'intuitive', label: '직관적으로 판단'),
];

/// Talent 설문 설정
final talentSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.talent,
  title: '적성 찾기',
  description: '숨겨진 재능을 발견해볼까요?',
  emoji: '🌟',
  accentColor: FortuneColors.mystical,
  steps: [
    const SurveyStep(
      id: 'interest',
      question: '어떤 분야에 관심이 있으세요?',
      inputType: SurveyInputType.multiSelect,
      options: _interestAreaOptions,
    ),
    const SurveyStep(
      id: 'workStyle',
      question: '일할 때 어떤 스타일이세요?',
      inputType: SurveyInputType.chips,
      options: _workStyleOptions,
    ),
    const SurveyStep(
      id: 'problemSolving',
      question: '문제를 어떻게 해결하세요?',
      inputType: SurveyInputType.chips,
      options: _problemSolvingOptions,
    ),
  ],
);

// ============================================================
// Tarot (타로) 설문 설정
// ============================================================

/// 타로 목적 옵션
const _tarotPurposeOptions = [
  SurveyOption(id: 'general', label: '전체 운세', emoji: '✨'),
  SurveyOption(id: 'love', label: '연애/관계', emoji: '💕'),
  SurveyOption(id: 'career', label: '일/커리어', emoji: '💼'),
  SurveyOption(id: 'decision', label: '결정/선택', emoji: '🤔'),
  SurveyOption(id: 'guidance', label: '조언/가이드', emoji: '🧭'),
];

/// Tarot 설문 설정
const tarotSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.tarot,
  title: '타로',
  description: '카드가 전하는 메시지를 들어볼까요?',
  emoji: '🃏',
  accentColor: FortuneColors.mystical,
  steps: [
    SurveyStep(
      id: 'purpose',
      question: '어떤 주제로 타로를 봐드릴까요?',
      inputType: SurveyInputType.chips,
      options: _tarotPurposeOptions,
    ),
    SurveyStep(
      id: 'tarotSelection',
      question: '오늘의 타로 덱은 라이더-웨이트입니다! 카드를 뽑아볼까요?',
      inputType: SurveyInputType.tarot,
    ),
  ],
);

// ============================================================
// MBTI 설문 설정
// ============================================================

/// MBTI 타입 옵션
const _mbtiTypeOptions = [
  SurveyOption(id: 'INTJ', label: 'INTJ'),
  SurveyOption(id: 'INTP', label: 'INTP'),
  SurveyOption(id: 'ENTJ', label: 'ENTJ'),
  SurveyOption(id: 'ENTP', label: 'ENTP'),
  SurveyOption(id: 'INFJ', label: 'INFJ'),
  SurveyOption(id: 'INFP', label: 'INFP'),
  SurveyOption(id: 'ENFJ', label: 'ENFJ'),
  SurveyOption(id: 'ENFP', label: 'ENFP'),
  SurveyOption(id: 'ISTJ', label: 'ISTJ'),
  SurveyOption(id: 'ISFJ', label: 'ISFJ'),
  SurveyOption(id: 'ESTJ', label: 'ESTJ'),
  SurveyOption(id: 'ESFJ', label: 'ESFJ'),
  SurveyOption(id: 'ISTP', label: 'ISTP'),
  SurveyOption(id: 'ISFP', label: 'ISFP'),
  SurveyOption(id: 'ESTP', label: 'ESTP'),
  SurveyOption(id: 'ESFP', label: 'ESFP'),
];

/// MBTI 설문 설정
const mbtiSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.mbti,
  title: 'MBTI 운세',
  description: 'MBTI로 보는 오늘의 운세',
  emoji: '🧠',
  accentColor: FortuneColors.career,
  steps: [
    SurveyStep(
      id: 'mbtiType',
      question: 'MBTI 유형이 어떻게 되세요?',
      inputType: SurveyInputType.chips,
      options: _mbtiTypeOptions,
    ),
  ],
);

// ============================================================
// 모든 설문 설정 매핑
// ============================================================

/// 운세 타입별 설문 설정 매핑 (30개 전체 + 유틸리티)
final Map<FortuneSurveyType, FortuneSurveyConfig> surveyConfigs = {
  // 유틸리티
  FortuneSurveyType.profileCreation: profileCreationSurveyConfig,
  // 기존 6개
  FortuneSurveyType.career: careerSurveyConfig,
  FortuneSurveyType.love: loveSurveyConfig,
  FortuneSurveyType.daily: dailySurveyConfig,
  FortuneSurveyType.talent: talentSurveyConfig,
  FortuneSurveyType.tarot: tarotSurveyConfig,
  FortuneSurveyType.mbti: mbtiSurveyConfig,
  // 시간 기반 (2개)
  FortuneSurveyType.newYear: newYearSurveyConfig,
  FortuneSurveyType.dailyCalendar: dailyCalendarSurveyConfig,
  // 전통 분석 (3개)
  FortuneSurveyType.traditional: traditionalSurveyConfig,
  FortuneSurveyType.faceReading: faceReadingSurveyConfig,
  FortuneSurveyType.talisman: talismanSurveyConfig,
  // 성격/개성 (2개)
  FortuneSurveyType.personalityDna: personalityDnaSurveyConfig,
  FortuneSurveyType.biorhythm: biorhythmSurveyConfig,
  // 연애/관계 (4개)
  FortuneSurveyType.compatibility: compatibilitySurveyConfig,
  FortuneSurveyType.avoidPeople: avoidPeopleSurveyConfig,
  FortuneSurveyType.exLover: exLoverSurveyConfig,
  FortuneSurveyType.blindDate: blindDateSurveyConfig,
  // 재물 (1개)
  FortuneSurveyType.money: moneySurveyConfig,
  // 라이프스타일 (4개)
  FortuneSurveyType.luckyItems: luckyItemsSurveyConfig,
  FortuneSurveyType.lotto: lottoSurveyConfig,
  FortuneSurveyType.wish: wishSurveyConfig,
  FortuneSurveyType.fortuneCookie: fortuneCookieSurveyConfig,
  // 건강/스포츠 (3개)
  FortuneSurveyType.health: healthSurveyConfig,
  FortuneSurveyType.exercise: exerciseSurveyConfig,
  FortuneSurveyType.sportsGame: sportsGameSurveyConfig,
  // 인터랙티브 (2개)
  FortuneSurveyType.dream: dreamSurveyConfig,
  FortuneSurveyType.celebrity: celebritySurveyConfig,
  // 가족/반려동물 (3개)
  FortuneSurveyType.pet: petSurveyConfig,
  FortuneSurveyType.family: familySurveyConfig,
  FortuneSurveyType.naming: namingSurveyConfig,
  // 스타일/패션 (1개)
  FortuneSurveyType.ootdEvaluation: ootdEvaluationSurveyConfig,
  // 실용/결정 (2개)
  FortuneSurveyType.exam: examSurveyConfig,
  FortuneSurveyType.moving: movingSurveyConfig,
  // 웰니스 (1개)
  FortuneSurveyType.gratitude: gratitudeSurveyConfig,
};

/// 분야별 포지션 가져오기
List<SurveyOption> getPositionsForField(String fieldId) {
  return _positionsByField[fieldId] ?? _positionsByField['other']!;
}

// ============================================================
// NewYear (새해 운세) 설문 설정
// ============================================================

/// 새해 목표 옵션
const _newYearGoalOptions = [
  SurveyOption(id: 'success', label: '성공/성취', emoji: '🏆'),
  SurveyOption(id: 'love', label: '사랑/만남', emoji: '💘'),
  SurveyOption(id: 'wealth', label: '부자되기', emoji: '💎'),
  SurveyOption(id: 'health', label: '건강/운동', emoji: '🏃'),
  SurveyOption(id: 'growth', label: '자기계발', emoji: '📖'),
  SurveyOption(id: 'travel', label: '여행/경험', emoji: '✈️'),
  SurveyOption(id: 'peace', label: '마음의 평화', emoji: '🧘'),
];

/// NewYear 설문 설정
const newYearSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.newYear,
  title: '새해 운세',
  description: '새해 복 많이 받으세요!',
  emoji: '🎊',
  accentColor: FortuneColors.wealth,
  steps: [
    SurveyStep(
      id: 'goal',
      question: '새해 가장 큰 소망이 뭔가요?',
      inputType: SurveyInputType.chips,
      options: _newYearGoalOptions,
      isRequired: false,
    ),
  ],
);

// ============================================================
// DailyCalendar (기간별 운세) 설문 설정
// ============================================================

/// 캘린더 연동 옵션
const _calendarSyncOptions = [
  SurveyOption(id: 'sync', label: '캘린더 연동하기', emoji: '📲'),
  SurveyOption(id: 'skip', label: '건너뛰기', emoji: '⏭️'),
];

/// DailyCalendar 설문 설정
/// 플로우: 캘린더 연동 → 날짜 선택 → (동적) 일정 표시 → 운세 생성
const dailyCalendarSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.dailyCalendar,
  title: '기간별 운세',
  description: '날짜를 선택하면 그날의 일정과 운세를 함께 봐드려요!',
  emoji: '📅',
  accentColor: FortuneColors.daily,
  steps: [
    // Step 1: 캘린더 연동 여부 (선택적)
    SurveyStep(
      id: 'calendarSync',
      question: '캘린더를 연동하면 일정과 함께 더 정확한 운세를 볼 수 있어요! 📅',
      inputType: SurveyInputType.chips,
      options: _calendarSyncOptions,
      isRequired: false,
    ),
    // Step 2: 날짜 선택 (인라인 캘린더)
    SurveyStep(
      id: 'targetDate',
      question: '날짜를 선택해주세요! 🗓️',
      inputType: SurveyInputType.calendar,
    ),
    // Note: 일정 선택은 chat handler에서 동적으로 처리
    // 날짜 선택 후 해당 날짜의 일정을 보여주고, 사용자가 선택/확인
  ],
);

// ============================================================
// Traditional (전통 사주 분석) 설문 설정
// ============================================================

/// 분석 유형 옵션
const _traditionalTypeOptions = [
  SurveyOption(id: 'comprehensive', label: '종합 분석', emoji: '📜'),
  SurveyOption(id: 'personality', label: '성격/기질', emoji: '🎭'),
  SurveyOption(id: 'destiny', label: '운명/인생 흐름', emoji: '🌊'),
  SurveyOption(id: 'luck', label: '올해 운세', emoji: '🍀'),
  SurveyOption(id: 'relationship', label: '대인관계', emoji: '🤝'),
];

/// 구체적 질문 옵션 (기존 페이지 질문 기능)
const _traditionalQuestionOptions = [
  SurveyOption(id: 'money_timing', label: '언제 돈이 들어올까?', emoji: '💰'),
  SurveyOption(id: 'career_fit', label: '어떤 일이 나한테 맞을까?', emoji: '💼'),
  SurveyOption(id: 'marriage_timing', label: '언제 결혼하면 좋을까?', emoji: '💒'),
  SurveyOption(id: 'health_caution', label: '건강 주의사항 있어?', emoji: '🏥'),
  SurveyOption(id: 'direction', label: '어느 방향으로 가면 좋아?', emoji: '🧭'),
  SurveyOption(id: 'custom', label: '직접 질문할래', emoji: '✏️'),
];

/// Traditional 설문 설정
const traditionalSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.traditional,
  title: '전통 사주 분석',
  description: '사주팔자로 보는 당신의 운명',
  emoji: '📿',
  accentColor: FortuneColors.mystical,
  steps: [
    SurveyStep(
      id: 'analysisType',
      question: '어떤 분석이 궁금하세요? 📜',
      inputType: SurveyInputType.chips,
      options: _traditionalTypeOptions,
    ),
    SurveyStep(
      id: 'specificQuestion',
      question: '특별히 알고 싶은 게 있어? 🤔',
      inputType: SurveyInputType.chips,
      options: _traditionalQuestionOptions,
      isRequired: false,
    ),
    SurveyStep(
      id: 'customQuestion',
      question: '궁금한 점을 자유롭게 적어줘! ✍️',
      inputType: SurveyInputType.text,
      showWhen: {'specificQuestion': 'custom'},
    ),
  ],
);

// ============================================================
// FaceReading (AI 관상 분석) 설문 설정
// ============================================================

/// 분석 포커스 옵션
const _faceReadingFocusOptions = [
  SurveyOption(id: 'overall', label: '종합 관상', emoji: '✨'),
  SurveyOption(id: 'personality', label: '성격/기질', emoji: '🎭'),
  SurveyOption(id: 'fortune', label: '재물/복', emoji: '💰'),
  SurveyOption(id: 'love', label: '연애/결혼운', emoji: '💕'),
  SurveyOption(id: 'career', label: '직업/적성', emoji: '💼'),
];

/// FaceReading 설문 설정 (AI 관상 분석 플로우)
const faceReadingSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.faceReading,
  title: 'AI 관상 분석',
  description: 'AI가 당신의 얼굴을 분석해드려요',
  emoji: '🎭',
  accentColor: FortuneColors.mystical,
  steps: [
    SurveyStep(
      id: 'focus',
      question: '어떤 관상이 궁금해? 👀',
      inputType: SurveyInputType.chips,
      options: _faceReadingFocusOptions,
      isRequired: false,
    ),
    SurveyStep(
      id: 'photo',
      question: '얼굴 사진을 올려줘! 📸\n정면 사진이 가장 정확해',
      inputType: SurveyInputType.faceReading,
    ),
  ],
);

// ============================================================
// Talisman (부적) 설문 설정
// ============================================================

/// 부적 목적 옵션
const _talismanPurposeOptions = [
  SurveyOption(id: 'wealth', label: '재물/금전운', emoji: '💰'),
  SurveyOption(id: 'love', label: '연애/결혼운', emoji: '💕'),
  SurveyOption(id: 'health', label: '건강/장수', emoji: '💪'),
  SurveyOption(id: 'success', label: '성공/합격', emoji: '🏆'),
  SurveyOption(id: 'protection', label: '액막이/보호', emoji: '🛡️'),
  SurveyOption(id: 'family', label: '가정화목', emoji: '👨‍👩‍👧‍👦'),
];

/// 특별한 상황 옵션
const _talismanSituationOptions = [
  SurveyOption(id: 'exam', label: '시험/면접 앞두고', emoji: '📝'),
  SurveyOption(id: 'business', label: '사업/창업 중', emoji: '💼'),
  SurveyOption(id: 'moving', label: '이사/이직 예정', emoji: '🏠'),
  SurveyOption(id: 'relationship', label: '관계 문제', emoji: '💔'),
  SurveyOption(id: 'none', label: '딱히 없어', emoji: '✨'),
];

/// Talisman 설문 설정
const talismanSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.talisman,
  title: '부적',
  description: '당신을 위한 맞춤 부적',
  emoji: '🧧',
  accentColor: FortuneColors.mystical,
  steps: [
    SurveyStep(
      id: 'purpose',
      question: '어떤 부적이 필요하세요? 🧧',
      inputType: SurveyInputType.chips,
      options: _talismanPurposeOptions,
    ),
    SurveyStep(
      id: 'situation',
      question: '특별한 상황이 있으세요? 🤔',
      inputType: SurveyInputType.chips,
      options: _talismanSituationOptions,
      isRequired: false,
    ),
  ],
);

// ============================================================
// PersonalityDna (성격 DNA) 설문 설정
// ============================================================

/// PersonalityDna 설문 설정 (사주 기반, 추가 수집 없음)
const personalityDnaSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.personalityDna,
  title: '성격 DNA',
  description: '사주로 보는 당신만의 성격 DNA',
  emoji: '🧬',
  accentColor: FortuneColors.career,
  steps: [], // 추가 수집 없음 (생년월일 기반)
);

// ============================================================
// Biorhythm (바이오리듬) 설문 설정
// ============================================================

/// Biorhythm 설문 설정
const biorhythmSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.biorhythm,
  title: '바이오리듬',
  description: '오늘의 신체/감성/지성 리듬',
  emoji: '📊',
  accentColor: FortuneColors.career,
  steps: [
    SurveyStep(
      id: 'targetDate',
      question: '어느 날짜의 바이오리듬이 궁금하세요?',
      inputType: SurveyInputType.calendar,
      options: [],
      isRequired: false, // 기본값: 오늘
    ),
  ],
);

// ============================================================
// ProfileCreation (채팅 내 프로필 생성) 설문 설정
// ============================================================

/// 관계 옵션 (프로필 생성용)
const _profileRelationshipOptions = [
  SurveyOption(id: 'lover', label: '애인', emoji: '💕'),
  SurveyOption(id: 'family', label: '가족', emoji: '👨‍👩‍👧‍👦'),
  SurveyOption(id: 'friend', label: '친구', emoji: '👥'),
  SurveyOption(id: 'crush', label: '짝사랑', emoji: '💘'),
  SurveyOption(id: 'other', label: '기타', emoji: '✨'),
];

/// 성별 옵션 (프로필 생성용)
const _profileGenderOptions = [
  SurveyOption(id: 'male', label: '남성', emoji: '👨'),
  SurveyOption(id: 'female', label: '여성', emoji: '👩'),
];

/// ProfileCreation 설문 설정 (채팅 내 프로필 생성)
const profileCreationSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.profileCreation,
  title: '상대방 정보 입력',
  description: '궁합을 볼 상대의 정보를 알려주세요',
  emoji: '✍️',
  accentColor: FortuneColors.love,
  steps: [
    SurveyStep(
      id: 'name',
      question: '상대방 이름이 뭐예요?',
      inputType: SurveyInputType.text,
      options: [],
    ),
    SurveyStep(
      id: 'relationship',
      question: '어떤 관계인가요?',
      inputType: SurveyInputType.chips,
      options: _profileRelationshipOptions,
    ),
    SurveyStep(
      id: 'birthDateTime',
      question: '생년월일과 태어난 시간을 알려주세요 🗓️',
      inputType: SurveyInputType.birthDateTime,
      options: [],
    ),
    SurveyStep(
      id: 'gender',
      question: '성별이 어떻게 되세요?',
      inputType: SurveyInputType.chips,
      options: _profileGenderOptions,
    ),
  ],
);

// ============================================================
// Compatibility (궁합) 설문 설정
// ============================================================

/// Compatibility 설문 설정
/// 입력 방식 옵션
const _compatibilityInputMethodOptions = [
  SurveyOption(id: 'profile', label: '저장된 프로필에서', emoji: '📋'),
  SurveyOption(id: 'new', label: '새로 입력할래', emoji: '✏️'),
];

/// 관계 유형 옵션
const _compatibilityRelationshipOptions = [
  SurveyOption(id: 'lover', label: '애인/배우자', emoji: '💕'),
  SurveyOption(id: 'crush', label: '짝사랑/썸', emoji: '💘'),
  SurveyOption(id: 'friend', label: '친구', emoji: '👥'),
  SurveyOption(id: 'colleague', label: '동료/지인', emoji: '💼'),
  SurveyOption(id: 'family', label: '가족', emoji: '👨‍👩‍👧‍👦'),
];

const compatibilitySurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.compatibility,
  title: '궁합',
  description: '누구와의 궁합이 궁금하세요?',
  emoji: '💞',
  accentColor: FortuneColors.love,
  steps: [
    SurveyStep(
      id: 'inputMethod',
      question: '상대방 정보를 어떻게 입력할래? 💞',
      inputType: SurveyInputType.chips,
      options: _compatibilityInputMethodOptions,
    ),
    SurveyStep(
      id: 'partner',
      question: '궁합 볼 상대를 선택해줘! 💕',
      inputType: SurveyInputType.profile,
      showWhen: {'inputMethod': 'profile'},
    ),
    SurveyStep(
      id: 'partnerName',
      question: '상대방 이름이 뭐야? ✨',
      inputType: SurveyInputType.text,
      showWhen: {'inputMethod': 'new'},
    ),
    SurveyStep(
      id: 'partnerBirth',
      question: '상대방 생년월일을 알려줘! 📅',
      inputType: SurveyInputType.birthDateTime,
      showWhen: {'inputMethod': 'new'},
    ),
    SurveyStep(
      id: 'relationship',
      question: '어떤 관계야? 🤔',
      inputType: SurveyInputType.chips,
      options: _compatibilityRelationshipOptions,
    ),
  ],
);

// ============================================================
// AvoidPeople (경계 대상) 설문 설정
// ============================================================

/// 경계 상황 옵션
const _avoidSituationOptions = [
  SurveyOption(id: 'work', label: '직장/비즈니스', emoji: '💼'),
  SurveyOption(id: 'love', label: '연애/소개팅', emoji: '💕'),
  SurveyOption(id: 'friend', label: '친구/지인', emoji: '👥'),
  SurveyOption(id: 'family', label: '가족/친척', emoji: '👨‍👩‍👧‍👦'),
  SurveyOption(id: 'money', label: '금전 거래', emoji: '💰'),
];

/// AvoidPeople 설문 설정
const avoidPeopleSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.avoidPeople,
  title: '경계 대상',
  description: '조심해야 할 인연을 알려드려요',
  emoji: '⚠️',
  accentColor: FortuneColors.moderate,
  steps: [
    SurveyStep(
      id: 'situation',
      question: '어떤 상황에서 주의가 필요하세요?',
      inputType: SurveyInputType.chips,
      options: _avoidSituationOptions,
    ),
  ],
);

// ============================================================
// ExLover (재회 운세) 설문 설정
// ============================================================

/// 이별 시기 옵션
const _breakupTimeOptions = [
  SurveyOption(id: 'recent', label: '최근 (1개월 이내)', emoji: '💔'),
  SurveyOption(id: 'months', label: '몇 달 전', emoji: '📅'),
  SurveyOption(id: 'year', label: '1년 전후', emoji: '🗓️'),
  SurveyOption(id: 'years', label: '몇 년 전', emoji: '⏳'),
];

/// 이별 사유 옵션
const _breakupReasonOptions = [
  SurveyOption(id: 'natural', label: '자연스러운 이별', emoji: '🍂'),
  SurveyOption(id: 'conflict', label: '갈등/싸움', emoji: '💢'),
  SurveyOption(id: 'distance', label: '거리/시간', emoji: '🌍'),
  SurveyOption(id: 'other', label: '다른 사람', emoji: '💔'),
  SurveyOption(id: 'family', label: '가족 반대', emoji: '👨‍👩‍👧'),
  SurveyOption(id: 'unknown', label: '잘 모르겠어요', emoji: '❓'),
];

/// 현재 마음 상태 옵션
const _currentFeelingOptions = [
  SurveyOption(id: 'miss', label: '많이 그리워', emoji: '😢'),
  SurveyOption(id: 'curious', label: '궁금해', emoji: '🤔'),
  SurveyOption(id: 'regret', label: '후회돼', emoji: '😔'),
  SurveyOption(id: 'conflicted', label: '복잡해', emoji: '🌀'),
  SurveyOption(id: 'hopeful', label: '다시 만나고 싶어', emoji: '🙏'),
];

/// ExLover 설문 설정
const exLoverSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.exLover,
  title: '재회 운세',
  description: '재회 가능성을 살펴볼게요',
  emoji: '🔄',
  accentColor: FortuneColors.love,
  steps: [
    SurveyStep(
      id: 'breakupTime',
      question: '언제 헤어졌어? 💔',
      inputType: SurveyInputType.chips,
      options: _breakupTimeOptions,
    ),
    SurveyStep(
      id: 'breakupReason',
      question: '헤어진 이유가 뭐였어? 🤔',
      inputType: SurveyInputType.chips,
      options: _breakupReasonOptions,
    ),
    SurveyStep(
      id: 'currentFeeling',
      question: '지금 마음은 어때? 💭',
      inputType: SurveyInputType.chips,
      options: _currentFeelingOptions,
    ),
  ],
);

// ============================================================
// BlindDate (소개팅 운세) 설문 설정
// ============================================================

/// 소개팅 유형 옵션
const _blindDateTypeOptions = [
  SurveyOption(id: 'app', label: '앱/온라인', emoji: '📱'),
  SurveyOption(id: 'friend', label: '지인 소개', emoji: '👥'),
  SurveyOption(id: 'work', label: '직장/학교', emoji: '🏢'),
  SurveyOption(id: 'group', label: '미팅/그룹', emoji: '🎉'),
];

/// 기대하는 점 옵션
const _blindDateExpectOptions = [
  SurveyOption(id: 'serious', label: '진지한 만남', emoji: '💍'),
  SurveyOption(id: 'casual', label: '가볍게 시작', emoji: '☕'),
  SurveyOption(id: 'friend', label: '친구로 시작', emoji: '🤝'),
  SurveyOption(id: 'explore', label: '모르겠어요', emoji: '🤔'),
];

/// 만남 시간대 옵션
const _blindDateTimeOptions = [
  SurveyOption(id: 'lunch', label: '점심', emoji: '☀️'),
  SurveyOption(id: 'afternoon', label: '오후', emoji: '🌤️'),
  SurveyOption(id: 'dinner', label: '저녁', emoji: '🌙'),
  SurveyOption(id: 'night', label: '밤', emoji: '🌃'),
];

/// 첫 소개팅 여부 옵션
const _blindDateFirstTimeOptions = [
  SurveyOption(id: 'yes', label: '네, 처음이에요', emoji: '🌟'),
  SurveyOption(id: 'no', label: '경험 있어요', emoji: '✨'),
];

/// 상대방 정보 유무 옵션
const _blindDatePartnerInfoOptions = [
  SurveyOption(id: 'photo', label: '사진 있어요', emoji: '📷'),
  SurveyOption(id: 'instagram', label: '인스타 알아요', emoji: '📱'),
  SurveyOption(id: 'none', label: '정보 없어요', emoji: '❓'),
];

/// BlindDate 설문 설정
final blindDateSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.blindDate,
  title: '소개팅 운세',
  description: '소개팅 운세를 봐드릴게요!',
  emoji: '💘',
  accentColor: FortuneColors.love,
  steps: [
    const SurveyStep(
      id: 'dateType',
      question: '어떤 방식으로 만나시나요?',
      inputType: SurveyInputType.chips,
      options: _blindDateTypeOptions,
    ),
    const SurveyStep(
      id: 'expectation',
      question: '어떤 만남을 원하세요?',
      inputType: SurveyInputType.chips,
      options: _blindDateExpectOptions,
    ),
    const SurveyStep(
      id: 'meetingTime',
      question: '만남 시간대가 어떻게 되나요?',
      inputType: SurveyInputType.chips,
      options: _blindDateTimeOptions,
    ),
    const SurveyStep(
      id: 'isFirstBlindDate',
      question: '첫 소개팅이신가요?',
      inputType: SurveyInputType.chips,
      options: _blindDateFirstTimeOptions,
    ),
    const SurveyStep(
      id: 'hasPartnerInfo',
      question: '상대방 정보가 있나요?',
      inputType: SurveyInputType.chips,
      options: _blindDatePartnerInfoOptions,
    ),
    // 조건부: 사진이 있다고 하면 사진 업로드
    SurveyStep(
      id: 'partnerPhoto',
      question: '상대방 사진을 올려주세요 📷',
      inputType: SurveyInputType.image,
      isRequired: false,
      showWhen: const {'hasPartnerInfo': 'photo'},
    ),
    // 조건부: 인스타를 안다고 하면 아이디 입력
    SurveyStep(
      id: 'partnerInstagram',
      question: '상대방 인스타그램 아이디를 알려주세요 📱',
      inputType: SurveyInputType.text,
      isRequired: false,
      showWhen: const {'hasPartnerInfo': 'instagram'},
    ),
  ],
);

// ============================================================
// Money (재물운) 설문 설정
// ============================================================

/// 투자 성향 옵션
const _investmentStyleOptions = [
  SurveyOption(id: 'safe', label: '안전 추구', emoji: '🛡️'),
  SurveyOption(id: 'balanced', label: '중립적', emoji: '⚖️'),
  SurveyOption(id: 'aggressive', label: '공격적', emoji: '🚀'),
];

/// 관심 분야 옵션
const _investmentAreaOptions = [
  SurveyOption(id: 'stock', label: '주식', emoji: '📈'),
  SurveyOption(id: 'realestate', label: '부동산', emoji: '🏠'),
  SurveyOption(id: 'crypto', label: '코인', emoji: '₿'),
  SurveyOption(id: 'saving', label: '저축/예금', emoji: '🏦'),
  SurveyOption(id: 'business', label: '사업', emoji: '💼'),
  SurveyOption(id: 'side', label: '부업/N잡', emoji: '💵'),
];

/// Money 설문 설정
const moneySurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.money,
  title: '재물운',
  description: '재물운을 분석해드릴게요',
  emoji: '💰',
  accentColor: FortuneColors.wealth,
  steps: [
    SurveyStep(
      id: 'style',
      question: '투자 성향이 어떻게 되세요?',
      inputType: SurveyInputType.chips,
      options: _investmentStyleOptions,
    ),
    SurveyStep(
      id: 'interest',
      question: '관심 있는 분야가 있으세요?',
      inputType: SurveyInputType.multiSelect,
      options: _investmentAreaOptions,
      isRequired: false,
    ),
  ],
);

// ============================================================
// LuckyItems (행운 아이템) 설문 설정
// ============================================================

/// 아이템 카테고리 옵션
const _luckyItemCategoryOptions = [
  SurveyOption(id: 'all', label: '전체', emoji: '✨'),
  SurveyOption(id: 'fashion', label: '패션/액세서리', emoji: '👔'),
  SurveyOption(id: 'food', label: '음식/음료', emoji: '🍽️'),
  SurveyOption(id: 'color', label: '컬러', emoji: '🎨'),
  SurveyOption(id: 'place', label: '장소/방향', emoji: '🧭'),
  SurveyOption(id: 'number', label: '숫자', emoji: '🔢'),
];

/// LuckyItems 설문 설정
const luckyItemsSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.luckyItems,
  title: '행운 아이템',
  description: '오늘의 행운을 가져다줄 아이템!',
  emoji: '🍀',
  accentColor: FortuneColors.daily,
  steps: [
    SurveyStep(
      id: 'category',
      question: '어떤 종류의 행운 아이템이 궁금하세요?',
      inputType: SurveyInputType.chips,
      options: _luckyItemCategoryOptions,
      isRequired: false,
    ),
  ],
);

// ============================================================
// Lotto (로또 번호) 설문 설정
// ============================================================

/// 번호 생성 방식 옵션
const _lottoMethodOptions = [
  SurveyOption(id: 'saju', label: '사주 기반', emoji: '📿'),
  SurveyOption(id: 'lucky', label: '오늘의 행운', emoji: '🍀'),
  SurveyOption(id: 'random', label: '완전 랜덤', emoji: '🎲'),
  SurveyOption(id: 'dream', label: '꿈 해석', emoji: '💭'),
];

/// 게임 수 옵션
const _lottoGameCountOptions = [
  SurveyOption(id: '1', label: '1게임', emoji: '1️⃣'),
  SurveyOption(id: '3', label: '3게임', emoji: '3️⃣'),
  SurveyOption(id: '5', label: '5게임', emoji: '5️⃣'),
];

/// Lotto 설문 설정
const lottoSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.lotto,
  title: '로또 번호',
  description: '행운의 번호를 뽑아볼게요!',
  emoji: '🎰',
  accentColor: FortuneColors.wealth,
  steps: [
    SurveyStep(
      id: 'method',
      question: '어떤 방식으로 번호를 생성할까? 🎲',
      inputType: SurveyInputType.chips,
      options: _lottoMethodOptions,
    ),
    SurveyStep(
      id: 'gameCount',
      question: '몇 게임 뽑을까? 🎫',
      inputType: SurveyInputType.chips,
      options: _lottoGameCountOptions,
      isRequired: false,
    ),
  ],
);

// ============================================================
// Wish (소원) 설문 설정
// ============================================================

/// 소원 카테고리 옵션
const _wishCategoryOptions = [
  SurveyOption(id: 'love', label: '사랑', emoji: '💕'),
  SurveyOption(id: 'success', label: '성공', emoji: '🏆'),
  SurveyOption(id: 'health', label: '건강', emoji: '💪'),
  SurveyOption(id: 'wealth', label: '재물', emoji: '💰'),
  SurveyOption(id: 'family', label: '가족', emoji: '👨‍👩‍👧‍👦'),
  SurveyOption(id: 'other', label: '기타', emoji: '✨'),
];

/// Wish 설문 설정
const wishSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.wish,
  title: '소원 빌기',
  description: '마음 속 소원을 빌어보세요',
  emoji: '🌠',
  accentColor: FortuneColors.mystical,
  steps: [
    SurveyStep(
      id: 'category',
      question: '어떤 종류의 소원인가요?',
      inputType: SurveyInputType.chips,
      options: _wishCategoryOptions,
    ),
    SurveyStep(
      id: 'wishContent',
      question: '소원을 말하거나 적어주세요',
      inputType: SurveyInputType.voice,
      options: [],
    ),
  ],
);

// ============================================================
// FortuneCookie (오늘의 메시지) 설문 설정
// ============================================================

/// FortuneCookie 설문 설정 (추가 수집 없음)
const fortuneCookieSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.fortuneCookie,
  title: '오늘의 메시지',
  description: '오늘 당신에게 전하는 한 마디',
  emoji: '🥠',
  accentColor: FortuneColors.daily,
  steps: [], // 추가 수집 없음
);

// ============================================================
// Health (건강 운세) 설문 설정
// ============================================================

/// 건강 고민 옵션
const _healthConcernOptions = [
  SurveyOption(id: 'fatigue', label: '피로/수면', emoji: '😴'),
  SurveyOption(id: 'stress', label: '스트레스', emoji: '😰'),
  SurveyOption(id: 'weight', label: '체중 관리', emoji: '⚖️'),
  SurveyOption(id: 'pain', label: '통증/불편', emoji: '🩹'),
  SurveyOption(id: 'mental', label: '정신 건강', emoji: '🧠'),
  SurveyOption(id: 'general', label: '전반적 건강', emoji: '💪'),
];

/// Health 설문 설정
const healthSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.health,
  title: '건강 운세',
  description: '오늘의 건강 운세를 봐드릴게요',
  emoji: '💊',
  accentColor: FortuneColors.career,
  steps: [
    SurveyStep(
      id: 'concern',
      question: '특히 신경 쓰이는 부분이 있으세요?',
      inputType: SurveyInputType.chips,
      options: _healthConcernOptions,
      isRequired: false,
    ),
  ],
);

// ============================================================
// Exercise (운동 추천) 설문 설정
// ============================================================

/// 운동 목적 옵션
const _exerciseGoalOptions = [
  SurveyOption(id: 'weight', label: '다이어트', emoji: '🏃'),
  SurveyOption(id: 'muscle', label: '근력 강화', emoji: '💪'),
  SurveyOption(id: 'health', label: '건강 유지', emoji: '❤️'),
  SurveyOption(id: 'stress', label: '스트레스 해소', emoji: '🧘'),
  SurveyOption(id: 'flexibility', label: '유연성', emoji: '🤸'),
];

/// 운동 강도 옵션
const _exerciseIntensityOptions = [
  SurveyOption(id: 'light', label: '가볍게', emoji: '🚶'),
  SurveyOption(id: 'moderate', label: '적당히', emoji: '🏃'),
  SurveyOption(id: 'intense', label: '빡세게', emoji: '🏋️'),
];

/// Exercise 설문 설정
const exerciseSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.exercise,
  title: '운동 추천',
  description: '오늘 맞는 운동을 추천해드려요',
  emoji: '🏃',
  accentColor: FortuneColors.career,
  steps: [
    SurveyStep(
      id: 'goal',
      question: '운동 목적이 뭔가요?',
      inputType: SurveyInputType.chips,
      options: _exerciseGoalOptions,
    ),
    SurveyStep(
      id: 'intensity',
      question: '원하는 강도는요?',
      inputType: SurveyInputType.chips,
      options: _exerciseIntensityOptions,
    ),
  ],
);

// ============================================================
// SportsGame (스포츠 경기) 설문 설정
// ============================================================

/// 스포츠 종목 옵션
const _sportTypeOptions = [
  SurveyOption(id: 'soccer', label: '축구', emoji: '⚽'),
  SurveyOption(id: 'baseball', label: '야구', emoji: '⚾'),
  SurveyOption(id: 'basketball', label: '농구', emoji: '🏀'),
  SurveyOption(id: 'esports', label: 'e스포츠', emoji: '🎮'),
  SurveyOption(id: 'other', label: '기타', emoji: '🏆'),
];

/// SportsGame 설문 설정
const sportsGameSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.sportsGame,
  title: '스포츠 경기',
  description: '경기 운세를 봐드릴게요!',
  emoji: '🏆',
  accentColor: FortuneColors.career,
  steps: [
    SurveyStep(
      id: 'sport',
      question: '어떤 종목이야? ⚽',
      inputType: SurveyInputType.chips,
      options: _sportTypeOptions,
    ),
    SurveyStep(
      id: 'gameDate',
      question: '경기 날짜가 언제야? 📅',
      inputType: SurveyInputType.calendar,
    ),
    SurveyStep(
      id: 'favoriteTeam',
      question: '응원하는 팀 이름을 알려줘! 📣',
      inputType: SurveyInputType.text,
      isRequired: false,
    ),
  ],
);

// ============================================================
// Dream (꿈 해몽) 설문 설정
// ============================================================

/// 꿈 감정 옵션
const _dreamEmotionOptions = [
  SurveyOption(id: 'happy', label: '기뻤어요', emoji: '😊'),
  SurveyOption(id: 'scary', label: '무서웠어요', emoji: '😱'),
  SurveyOption(id: 'sad', label: '슬펐어요', emoji: '😢'),
  SurveyOption(id: 'confused', label: '혼란스러웠어요', emoji: '😵'),
  SurveyOption(id: 'strange', label: '이상했어요', emoji: '🤔'),
  SurveyOption(id: 'vivid', label: '생생했어요', emoji: '✨'),
];

/// Dream 설문 설정
const dreamSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.dream,
  title: '꿈 해몽',
  description: '어젯밤 꿈 이야기를 들려주세요',
  emoji: '💭',
  accentColor: FortuneColors.mystical,
  steps: [
    SurveyStep(
      id: 'dreamContent',
      question: '꿈 내용을 말하거나 적어주세요',
      inputType: SurveyInputType.voice,
      options: [],
    ),
    SurveyStep(
      id: 'emotion',
      question: '꿈에서 어떤 기분이었나요?',
      inputType: SurveyInputType.chips,
      options: _dreamEmotionOptions,
    ),
  ],
);

// ============================================================
// Celebrity (유명인 궁합) 설문 설정
// ============================================================

/// Celebrity 관심포인트 옵션
const _celebrityInterestOptions = [
  SurveyOption(id: 'overall', label: '전체 궁합', emoji: '💫'),
  SurveyOption(id: 'personality', label: '성격 궁합', emoji: '🧠'),
  SurveyOption(id: 'love', label: '연애 궁합', emoji: '💕'),
  SurveyOption(id: 'work', label: '케미/협업', emoji: '🤝'),
];

/// Celebrity 설문 설정
const celebritySurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.celebrity,
  title: '유명인 궁합',
  description: '좋아하는 유명인과 궁합을 알아볼까요?',
  emoji: '⭐',
  accentColor: FortuneColors.love,
  steps: [
    SurveyStep(
      id: 'celebrityName',
      question: '누구와의 궁합이 궁금하세요?',
      inputType: SurveyInputType.text,
      options: [],
    ),
    SurveyStep(
      id: 'interest',
      question: '특히 궁금한 부분이 있어? 💫',
      inputType: SurveyInputType.chips,
      options: _celebrityInterestOptions,
      isRequired: false,
    ),
  ],
);

// ============================================================
// Pet (반려동물 궁합) 설문 설정
// ============================================================

/// Pet 관심포인트 옵션
const _petInterestOptions = [
  SurveyOption(id: 'overall', label: '전체 궁합', emoji: '💫'),
  SurveyOption(id: 'personality', label: '성격 궁합', emoji: '🧠'),
  SurveyOption(id: 'activity', label: '활동 궁합', emoji: '🏃'),
  SurveyOption(id: 'care', label: '케어 스타일', emoji: '💕'),
];

/// Pet 설문 설정
const petSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.pet,
  title: '반려동물 궁합',
  description: '반려동물과의 궁합을 봐드릴게요!',
  emoji: '🐾',
  accentColor: FortuneColors.daily,
  steps: [
    SurveyStep(
      id: 'pet',
      question: '반려동물을 선택해주세요',
      inputType: SurveyInputType.petProfile,
      options: [],
    ),
    SurveyStep(
      id: 'interest',
      question: '특히 궁금한 부분이 있어? 🐾',
      inputType: SurveyInputType.chips,
      options: _petInterestOptions,
      isRequired: false,
    ),
  ],
);

// ============================================================
// Family (가족 운세) 설문 설정
// ============================================================

/// 가족 관심사 옵션
const _familyConcernOptions = [
  SurveyOption(id: 'harmony', label: '화목/관계', emoji: '💕'),
  SurveyOption(id: 'health', label: '건강', emoji: '💪'),
  SurveyOption(id: 'wealth', label: '재물', emoji: '💰'),
  SurveyOption(id: 'education', label: '자녀 교육', emoji: '📚'),
  SurveyOption(id: 'overall', label: '전체 운세', emoji: '✨'),
];

/// 가족 구성원 옵션
const _familyMemberOptions = [
  SurveyOption(id: 'all', label: '가족 전체', emoji: '👨‍👩‍👧‍👦'),
  SurveyOption(id: 'parents', label: '부모님', emoji: '👴👵'),
  SurveyOption(id: 'spouse', label: '배우자', emoji: '💑'),
  SurveyOption(id: 'children', label: '자녀', emoji: '👶'),
  SurveyOption(id: 'siblings', label: '형제자매', emoji: '👫'),
];

/// Family 설문 설정
const familySurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.family,
  title: '가족 운세',
  description: '가족 운세를 살펴볼게요',
  emoji: '👨‍👩‍👧‍👦',
  accentColor: FortuneColors.love,
  steps: [
    SurveyStep(
      id: 'concern',
      question: '어떤 부분이 궁금하세요?',
      inputType: SurveyInputType.chips,
      options: _familyConcernOptions,
    ),
    SurveyStep(
      id: 'member',
      question: '누구의 운세가 궁금하세요?',
      inputType: SurveyInputType.chips,
      options: _familyMemberOptions,
    ),
  ],
);

// ============================================================
// Naming (작명) 설문 설정
// ============================================================

/// 성별 옵션
const _namingGenderOptions = [
  SurveyOption(id: 'male', label: '남아', emoji: '👦'),
  SurveyOption(id: 'female', label: '여아', emoji: '👧'),
  SurveyOption(id: 'unknown', label: '아직 몰라요', emoji: '🤷'),
];

/// 이름 스타일 옵션
const _namingStyleOptions = [
  SurveyOption(id: 'traditional', label: '전통적', emoji: '📿'),
  SurveyOption(id: 'modern', label: '현대적', emoji: '✨'),
  SurveyOption(id: 'unique', label: '독특한', emoji: '🌟'),
  SurveyOption(id: 'cute', label: '귀여운', emoji: '🥰'),
  SurveyOption(id: 'strong', label: '강인한', emoji: '💪'),
];

/// Naming 설문 설정
const namingSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.naming,
  title: '작명',
  description: '좋은 이름을 찾아드릴게요!',
  emoji: '📝',
  accentColor: FortuneColors.mystical,
  steps: [
    SurveyStep(
      id: 'dueDate',
      question: '출산 예정일이 언제인가요?',
      inputType: SurveyInputType.calendar,
      options: [],
      isRequired: false,
    ),
    SurveyStep(
      id: 'gender',
      question: '아이 성별은요?',
      inputType: SurveyInputType.chips,
      options: _namingGenderOptions,
    ),
    SurveyStep(
      id: 'lastName',
      question: '성(姓)을 알려주세요',
      inputType: SurveyInputType.text,
      options: [],
    ),
    SurveyStep(
      id: 'style',
      question: '원하는 이름 스타일은요?',
      inputType: SurveyInputType.chips,
      options: _namingStyleOptions,
    ),
  ],
);

// ============================================================
// OOTD Evaluation (OOTD 평가) 설문 설정
// ============================================================

/// TPO (Time, Place, Occasion) 옵션
const _ootdTpoOptions = [
  SurveyOption(id: 'date', label: '데이트', emoji: '💕'),
  SurveyOption(id: 'interview', label: '면접', emoji: '💼'),
  SurveyOption(id: 'work', label: '출근', emoji: '🏢'),
  SurveyOption(id: 'casual', label: '일상', emoji: '☕'),
  SurveyOption(id: 'party', label: '파티/모임', emoji: '🎉'),
  SurveyOption(id: 'wedding', label: '경조사', emoji: '💒'),
  SurveyOption(id: 'travel', label: '여행', emoji: '✈️'),
  SurveyOption(id: 'sports', label: '운동', emoji: '🏃'),
];

/// OOTD 평가 설문 설정
const ootdEvaluationSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.ootdEvaluation,
  title: 'OOTD 평가',
  description: 'AI가 오늘의 패션을 평가해드려요!',
  emoji: '👔',
  accentColor: FortuneColors.career,
  steps: [
    SurveyStep(
      id: 'tpo',
      question: '오늘 어디 가시나요?',
      inputType: SurveyInputType.chips,
      options: _ootdTpoOptions,
    ),
    SurveyStep(
      id: 'photo',
      question: 'OOTD 사진을 올려주세요! 📸',
      inputType: SurveyInputType.image,
      options: [],
    ),
  ],
);

// ============================================================
// Exam (시험운) 설문 설정
// ============================================================

/// 시험 종류 옵션
const _examTypeOptions = [
  SurveyOption(id: 'license', label: '자격증', emoji: '📜'),
  SurveyOption(id: 'job', label: '취업/입사', emoji: '💼'),
  SurveyOption(id: 'promotion', label: '승진/진급', emoji: '📈'),
  SurveyOption(id: 'school', label: '입시/편입', emoji: '🎓'),
  SurveyOption(id: 'language', label: '어학시험', emoji: '🌍'),
  SurveyOption(id: 'other', label: '기타', emoji: '✏️'),
];

/// 준비 상태 옵션
const _examPreparationOptions = [
  SurveyOption(id: 'perfect', label: '완벽 준비', emoji: '💯'),
  SurveyOption(id: 'good', label: '잘 되고 있어', emoji: '😊'),
  SurveyOption(id: 'normal', label: '보통이야', emoji: '😐'),
  SurveyOption(id: 'worried', label: '좀 걱정돼', emoji: '😟'),
  SurveyOption(id: 'panic', label: '급하게 준비중', emoji: '😰'),
];

/// Exam 설문 설정
const examSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.exam,
  title: '시험운',
  description: '시험 합격 운세를 봐드릴게요!',
  emoji: '📝',
  accentColor: FortuneColors.career,
  steps: [
    SurveyStep(
      id: 'examType',
      question: '어떤 시험을 준비하고 있어요? 📝',
      inputType: SurveyInputType.chips,
      options: _examTypeOptions,
    ),
    SurveyStep(
      id: 'examDate',
      question: '시험 날짜가 언제예요? 📅',
      inputType: SurveyInputType.calendar,
    ),
    SurveyStep(
      id: 'preparation',
      question: '준비 상태는 어떠세요? 💪',
      inputType: SurveyInputType.chips,
      options: _examPreparationOptions,
    ),
  ],
);

// ============================================================
// Moving (이사/이직운) 설문 설정
// ============================================================

/// 이동 유형 옵션
const _movingTypeOptions = [
  SurveyOption(id: 'home', label: '이사', emoji: '🏠'),
  SurveyOption(id: 'job', label: '이직', emoji: '💼'),
  SurveyOption(id: 'both', label: '둘 다', emoji: '🔄'),
];

/// 이사 방향 옵션
const _movingDirectionOptions = [
  SurveyOption(id: 'east', label: '동쪽', emoji: '🌅'),
  SurveyOption(id: 'west', label: '서쪽', emoji: '🌇'),
  SurveyOption(id: 'south', label: '남쪽', emoji: '☀️'),
  SurveyOption(id: 'north', label: '북쪽', emoji: '❄️'),
  SurveyOption(id: 'unknown', label: '아직 모름', emoji: '🤔'),
];

/// Moving 설문 설정
const movingSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.moving,
  title: '이사/이직운',
  description: '좋은 방향을 찾아드릴게요!',
  emoji: '🏠',
  accentColor: FortuneColors.career,
  steps: [
    SurveyStep(
      id: 'movingType',
      question: '어떤 이동을 계획하고 있어요? 🚚',
      inputType: SurveyInputType.chips,
      options: _movingTypeOptions,
    ),
    SurveyStep(
      id: 'movingDate',
      question: '예정일이 언제예요? 📅',
      inputType: SurveyInputType.calendar,
    ),
    SurveyStep(
      id: 'direction',
      question: '이동 방향이 정해졌나요? 🧭',
      inputType: SurveyInputType.chips,
      options: _movingDirectionOptions,
      showWhen: {'movingType': ['home', 'both']},
    ),
  ],
);

// ============================================================
// Gratitude (감사일기) 설문 설정
// ============================================================

/// Gratitude 설문 설정
const gratitudeSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.gratitude,
  title: '감사일기',
  description: '오늘 감사한 일 3가지를 적어보세요',
  emoji: '✨',
  accentColor: FortuneColors.wealth,
  steps: [
    SurveyStep(
      id: 'gratitude1',
      question: '첫 번째로 감사한 일이 뭐예요? 🙏',
      inputType: SurveyInputType.text,
    ),
    SurveyStep(
      id: 'gratitude2',
      question: '두 번째로 감사한 일은요? 💫',
      inputType: SurveyInputType.text,
    ),
    SurveyStep(
      id: 'gratitude3',
      question: '마지막으로 감사한 일을 적어주세요 ✨',
      inputType: SurveyInputType.text,
    ),
  ],
);
