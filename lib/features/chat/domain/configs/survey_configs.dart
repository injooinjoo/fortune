import '../../../../core/design_system/design_system.dart';
import '../models/fortune_survey_config.dart';

/// 인사이트별 설문 설정 정의

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
const careerSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.career,
  title: '커리어 인사이트',
  description: '당신의 커리어 방향을 알려드릴게요',
  emoji: '💼',
  accentColor: DSColors.accentSecondary,
  steps: [
    SurveyStep(
      id: 'field',
      question: '어떤 분야에서 일하고 계신가요?',
      inputType: SurveyInputType.chips,
      options: _fieldOptions,
    ),
    SurveyStep(
      id: 'position',
      question: '현재 포지션이 어떻게 되세요?',
      inputType: SurveyInputType.chips,
      dependsOn: 'field',
      options: [], // 동적으로 로드됨
    ),
    SurveyStep(
      id: 'experience',
      question: '경력은 어느 정도 되셨나요?',
      inputType: SurveyInputType.chips,
      options: _experienceOptions,
    ),
    SurveyStep(
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

/// 이상형 성격 옵션 (공통)
const _idealTypePersonalityOptions = [
  SurveyOption(id: 'kind', label: '따뜻한', emoji: '🥰'),
  SurveyOption(id: 'funny', label: '유머러스', emoji: '😄'),
  SurveyOption(id: 'smart', label: '똑똑한', emoji: '🧠'),
  SurveyOption(id: 'stable', label: '안정적인', emoji: '🏠'),
  SurveyOption(id: 'passionate', label: '열정적인', emoji: '🔥'),
  SurveyOption(id: 'calm', label: '차분한', emoji: '🌊'),
];

/// 이상형 외모상 - 남성이 선호하는 여성 타입 (동물상)
const _idealTypeFemaleOptions = [
  SurveyOption(id: 'cat', label: '고양이상 (도도+세련)', emoji: '🐱'),
  SurveyOption(id: 'fox', label: '여우상 (성숙+요염)', emoji: '🦊'),
  SurveyOption(id: 'puppy', label: '강아지상 (밝고 순수)', emoji: '🐶'),
  SurveyOption(id: 'rabbit', label: '토끼상 (귀엽고 발랄)', emoji: '🐰'),
  SurveyOption(id: 'deer', label: '사슴상 (청순+우아)', emoji: '🦌'),
  SurveyOption(id: 'squirrel', label: '다람쥐상 (앙증맞은)', emoji: '🐿️'),
];

/// 이상형 외모상 - 여성이 선호하는 남성 타입 (남성상)
const _idealTypeMaleOptions = [
  SurveyOption(id: 'arab', label: '아랍상 (강렬+남자다운)', emoji: '🦁'),
  SurveyOption(id: 'tofu', label: '두부상 (부드럽고 정감)', emoji: '🧸'),
  SurveyOption(id: 'nerd', label: '너드남 (지적+섬세)', emoji: '🤓'),
  SurveyOption(id: 'beast', label: '짐승남 (야성+매력)', emoji: '🐺'),
  SurveyOption(id: 'gentle', label: '젠틀남 (매너+다정)', emoji: '🎩'),
  SurveyOption(id: 'warm', label: '훈훈남 (따뜻+편안)', emoji: '☀️'),
];

/// Love 설문 설정
const loveSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.love,
  title: '연애 인사이트',
  description: '당신의 사랑 운을 알려드릴게요',
  emoji: '💕',
  accentColor: DSColors.accentSecondary,
  steps: [
    // gender는 프로필에서 자동 가져옴 (chat_home_page.dart에서 initialAnswers로 전달)
    SurveyStep(
      id: 'status',
      question: '지금 연애 상태가 어때? 💕',
      inputType: SurveyInputType.chips,
      options: _relationshipStatusOptions,
    ),
    SurveyStep(
      id: 'concern',
      question: '가장 궁금한 게 뭐야? 🤔',
      inputType: SurveyInputType.chips,
      options: _loveConcernOptions,
    ),
    SurveyStep(
      id: 'datingStyle',
      question: '연애할 때 어떤 스타일이야? 💝',
      inputType: SurveyInputType.multiSelect,
      options: _datingStyleOptions,
      isRequired: false,
    ),
    // 남성 → 여성 이상형 (동물상)
    SurveyStep(
      id: 'idealLooks',
      question: '어떤 외모 스타일이 끌려? 👀',
      inputType: SurveyInputType.multiSelect,
      options: _idealTypeFemaleOptions,
      isRequired: false,
      showWhen: {
        'status': ['single', 'crush'],
        'gender': ['male']
      },
    ),
    // 여성 → 남성 이상형 (남성상)
    SurveyStep(
      id: 'idealLooks',
      question: '어떤 외모 스타일이 끌려? 👀',
      inputType: SurveyInputType.multiSelect,
      options: _idealTypeMaleOptions,
      isRequired: false,
      showWhen: {
        'status': ['single', 'crush'],
        'gender': ['female']
      },
    ),
    // 공통 성격 옵션
    SurveyStep(
      id: 'idealPersonality',
      question: '이상형 성격은? ✨',
      inputType: SurveyInputType.multiSelect,
      options: _idealTypePersonalityOptions,
      isRequired: false,
      showWhen: {
        'status': ['single', 'crush']
      },
    ),
  ],
);

// ============================================================
// Daily (오늘의 운세) 설문 설정
// ============================================================

/// Daily 설문 설정 (설문 스킵 - 바로 조회)
const dailySurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.daily,
  title: '오늘의 운세',
  description: '오늘 하루를 미리 살펴볼까요?',
  emoji: '🌅',
  accentColor: DSColors.accentSecondary,
  steps: [], // 설문 없이 바로 API 호출
);

// ============================================================
// Game Enhance (게임 강화운세) 설문 설정
// ============================================================

/// Game Enhance 설문 설정 (설문 스킵 - 바로 조회)
const gameEnhanceSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.gameEnhance,
  title: '강화의 기운',
  description: '오늘의 강화 성공 확률은?',
  emoji: '🎮',
  accentColor: DSColors.accentSecondary, // 화(火) - 강화의 불꽃
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

/// 재능 경험 수준 옵션
const _talentExperienceOptions = [
  SurveyOption(id: 'beginner', label: '처음 시작', emoji: '🌱'),
  SurveyOption(id: 'some', label: '조금 해봤어요', emoji: '📚'),
  SurveyOption(id: 'intermediate', label: '어느 정도 경험', emoji: '⭐'),
  SurveyOption(id: 'experienced', label: '전문가 수준', emoji: '🏆'),
];

/// 투자 가능 시간 옵션
const _timeAvailableOptions = [
  SurveyOption(id: 'minimal', label: '주 1-2시간', emoji: '⏰'),
  SurveyOption(id: 'moderate', label: '주 5-10시간', emoji: '📅'),
  SurveyOption(id: 'significant', label: '주 10시간 이상', emoji: '🔥'),
  SurveyOption(id: 'fulltime', label: '풀타임 가능', emoji: '💼'),
];

/// 도전 과제 옵션
const _challengesOptions = [
  SurveyOption(id: 'time', label: '시간 부족', emoji: '⏳'),
  SurveyOption(id: 'motivation', label: '동기부여 어려움', emoji: '😴'),
  SurveyOption(id: 'direction', label: '방향 모르겠음', emoji: '🧭'),
  SurveyOption(id: 'resources', label: '자원/비용 부담', emoji: '💰'),
  SurveyOption(id: 'confidence', label: '자신감 부족', emoji: '😰'),
];

/// Talent 설문 설정
const talentSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.talent,
  title: '적성 찾기',
  description: '숨겨진 재능을 발견해볼까요?',
  emoji: '🌟',
  accentColor: DSColors.accentSecondary,
  steps: [
    SurveyStep(
      id: 'interest',
      question: '어떤 분야에 관심이 있으세요?',
      inputType: SurveyInputType.multiSelect,
      options: _interestAreaOptions,
    ),
    SurveyStep(
      id: 'workStyle',
      question: '일할 때 어떤 스타일이세요?',
      inputType: SurveyInputType.chips,
      options: _workStyleOptions,
    ),
    SurveyStep(
      id: 'problemSolving',
      question: '문제를 어떻게 해결하세요?',
      inputType: SurveyInputType.chips,
      options: _problemSolvingOptions,
    ),
    SurveyStep(
      id: 'experience',
      question: '관심 분야 경험이 어느 정도 있으세요?',
      inputType: SurveyInputType.chips,
      options: _talentExperienceOptions,
    ),
    SurveyStep(
      id: 'timeAvailable',
      question: '일주일에 얼마나 투자할 수 있으세요?',
      inputType: SurveyInputType.chips,
      options: _timeAvailableOptions,
    ),
    SurveyStep(
      id: 'challenges',
      question: '현재 겪고 있는 어려움이 있나요?',
      inputType: SurveyInputType.multiSelect,
      options: _challengesOptions,
      isRequired: false,
    ),
  ],
);

// ============================================================
// Tarot (타로) 설문 설정
// ============================================================

/// 타로 목적 옵션
const _tarotPurposeOptions = [
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
  accentColor: DSColors.accentSecondary,
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

/// MBTI 확인 옵션 (Step 1용)
const _mbtiConfirmOptions = [
  SurveyOption(id: 'yes', label: '네, 맞아요!', emoji: '👍'),
  SurveyOption(id: 'no', label: '아니요, 다시 선택할게요', emoji: '🔄'),
];

/// MBTI 카테고리 옵션 (Step 2용)
const _mbtiCategoryOptions = [
  SurveyOption(id: 'personality', label: '성향 분석', emoji: '🔍'),
  SurveyOption(id: 'love', label: '연애/관계', emoji: '💕'),
  SurveyOption(id: 'career', label: '직장/커리어', emoji: '💼'),
  SurveyOption(id: 'growth', label: '자기계발', emoji: '🌱'),
];

/// MBTI 설문 설정 (3단계: 확인 → 재선택 → 카테고리)
const mbtiSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.mbti,
  title: 'MBTI 인사이트',
  description: 'MBTI로 보는 오늘의 운세',
  emoji: '🧠',
  accentColor: DSColors.accentSecondary,
  steps: [
    // Step 1: MBTI 확인 (프로필에 MBTI가 있으면 확인 질문)
    SurveyStep(
      id: 'mbtiConfirm',
      question: '맞으신가요?', // 실제 질문은 chat_home_page에서 동적 생성
      inputType: SurveyInputType.chips,
      options: _mbtiConfirmOptions,
    ),
    // Step 1-B: MBTI 재선택 (확인에서 '아니요' 선택 시에만 표시)
    SurveyStep(
      id: 'mbtiType',
      question: 'MBTI 유형이 어떻게 되세요?',
      inputType: SurveyInputType.chips,
      options: _mbtiTypeOptions,
      showWhen: {'mbtiConfirm': 'no'},
    ),
    // Step 2: 카테고리 선택
    SurveyStep(
      id: 'category',
      question: '어떤 인사이트를 받고 싶으세요? ✨',
      inputType: SurveyInputType.chips,
      options: _mbtiCategoryOptions,
    ),
  ],
);

// ============================================================
// 모든 설문 설정 매핑
// ============================================================

/// 인사이트 타입별 설문 설정 매핑 (30개 전체 + 유틸리티)
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
  // 인터랙티브 (4개)
  FortuneSurveyType.dream: dreamSurveyConfig,
  FortuneSurveyType.celebrity: celebritySurveyConfig,
  FortuneSurveyType.pastLife: pastLifeSurveyConfig,
  FortuneSurveyType.gameEnhance: gameEnhanceSurveyConfig,
  // 가족/반려동물 (3개) - baby-nickname은 naming으로 통합
  FortuneSurveyType.pet: petSurveyConfig,
  FortuneSurveyType.family: familySurveyConfig,
  FortuneSurveyType.naming: namingSurveyConfig,
  // 스타일/패션 (1개)
  FortuneSurveyType.ootdEvaluation: ootdEvaluationSurveyConfig,
  // 실용/결정 (2개)
  FortuneSurveyType.exam: examSurveyConfig,
  FortuneSurveyType.moving: movingSurveyConfig,
  // 이미지 생성 (1개)
  FortuneSurveyType.yearlyEncounter: yearlyEncounterSurveyConfig,
};

/// 분야별 포지션 가져오기
List<SurveyOption> getPositionsForField(String fieldId) {
  return _positionsByField[fieldId] ?? _positionsByField['other']!;
}

// ============================================================
// NewYear (새해 인사이트) 설문 설정
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
  title: '새해 인사이트',
  description: '새해 복 많이 받으세요!',
  emoji: '🎊',
  accentColor: DSColors.accentSecondary,
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
// DailyCalendar (기간별 인사이트) 설문 설정
// ============================================================

/// 캘린더 연동 옵션
const _calendarSyncOptions = [
  SurveyOption(id: 'sync', label: '캘린더 연동하기', emoji: '📲'),
  SurveyOption(id: 'skip', label: '건너뛰기', emoji: '⏭️'),
];

/// DailyCalendar 설문 설정
/// 플로우: 캘린더 연동 → 날짜 선택 → (동적) 일정 표시 → 인사이트 생성
const dailyCalendarSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.dailyCalendar,
  title: '기간별 인사이트',
  description: '날짜를 선택하면 그날의 일정과 인사이트를 함께 확인해드려요!',
  emoji: '📅',
  accentColor: DSColors.accentSecondary,
  steps: [
    // Step 1: 캘린더 연동 여부 (선택적)
    SurveyStep(
      id: 'calendarSync',
      question: '캘린더를 연동하면 일정과 함께 더 정확한 인사이트를 확인할 수 있어요! 📅',
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
  SurveyOption(id: 'luck', label: '올해 인사이트', emoji: '🍀'),
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
  accentColor: DSColors.accentSecondary,
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
  accentColor: DSColors.accentSecondary,
  steps: [
    SurveyStep(
      id: 'focus',
      question: '어떤 관상이 궁금하세요? 👀',
      inputType: SurveyInputType.chips,
      options: _faceReadingFocusOptions,
      isRequired: false,
    ),
    SurveyStep(
      id: 'photo',
      question: '얼굴 사진을 올려주세요! 📸\n정면 사진이 가장 정확해요',
      inputType: SurveyInputType.faceReading,
    ),
  ],
);

// ============================================================
// Talisman (부적) 설문 설정
// ============================================================

/// 부적 목적 옵션 (TalismanCategory.id와 일치)
const _talismanPurposeOptions = [
  SurveyOption(id: 'wealth_career', label: '재물/금전운', emoji: '💰'),
  SurveyOption(id: 'love_relationship', label: '연애/결혼운', emoji: '💕'),
  SurveyOption(id: 'health_longevity', label: '건강/장수', emoji: '💪'),
  SurveyOption(id: 'academic_success', label: '성공/합격', emoji: '🏆'),
  SurveyOption(id: 'disaster_removal', label: '액막이/보호', emoji: '🛡️'),
  SurveyOption(id: 'home_protection', label: '가정화목', emoji: '👨‍👩‍👧‍👦'),
  SurveyOption(id: 'disease_prevention', label: '질병퇴치', emoji: '🏥'),
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
  accentColor: DSColors.accentSecondary,
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

/// 성격 DNA용 혈액형 옵션
const _personalityDnaBloodTypeOptions = [
  SurveyOption(id: 'A', label: 'A형', emoji: '🅰️'),
  SurveyOption(id: 'B', label: 'B형', emoji: '🅱️'),
  SurveyOption(id: 'O', label: 'O형', emoji: '🅾️'),
  SurveyOption(id: 'AB', label: 'AB형', emoji: '🆎'),
];

/// 성격 DNA용 별자리 옵션
const _personalityDnaZodiacOptions = [
  SurveyOption(id: '양자리', label: '양자리', emoji: '♈'),
  SurveyOption(id: '황소자리', label: '황소자리', emoji: '♉'),
  SurveyOption(id: '쌍둥이자리', label: '쌍둥이자리', emoji: '♊'),
  SurveyOption(id: '게자리', label: '게자리', emoji: '♋'),
  SurveyOption(id: '사자자리', label: '사자자리', emoji: '♌'),
  SurveyOption(id: '처녀자리', label: '처녀자리', emoji: '♍'),
  SurveyOption(id: '천칭자리', label: '천칭자리', emoji: '♎'),
  SurveyOption(id: '전갈자리', label: '전갈자리', emoji: '♏'),
  SurveyOption(id: '궁수자리', label: '궁수자리', emoji: '♐'),
  SurveyOption(id: '염소자리', label: '염소자리', emoji: '♑'),
  SurveyOption(id: '물병자리', label: '물병자리', emoji: '♒'),
  SurveyOption(id: '물고기자리', label: '물고기자리', emoji: '♓'),
];

/// 성격 DNA용 띠 옵션
const _personalityDnaZodiacAnimalOptions = [
  SurveyOption(id: '쥐', label: '쥐띠', emoji: '🐭'),
  SurveyOption(id: '소', label: '소띠', emoji: '🐮'),
  SurveyOption(id: '호랑이', label: '호랑이띠', emoji: '🐯'),
  SurveyOption(id: '토끼', label: '토끼띠', emoji: '🐰'),
  SurveyOption(id: '용', label: '용띠', emoji: '🐲'),
  SurveyOption(id: '뱀', label: '뱀띠', emoji: '🐍'),
  SurveyOption(id: '말', label: '말띠', emoji: '🐴'),
  SurveyOption(id: '양', label: '양띠', emoji: '🐑'),
  SurveyOption(id: '원숭이', label: '원숭이띠', emoji: '🐵'),
  SurveyOption(id: '닭', label: '닭띠', emoji: '🐔'),
  SurveyOption(id: '개', label: '개띠', emoji: '🐶'),
  SurveyOption(id: '돼지', label: '돼지띠', emoji: '🐷'),
];

/// PersonalityDna 설문 설정 (MBTI, 혈액형, 별자리, 띠 수집)
/// 참고: 프로필에 이미 있는 값은 chat_home_page에서 스킵 처리
const personalityDnaSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.personalityDna,
  title: '성격 DNA',
  description: 'MBTI, 혈액형, 별자리, 띠를 조합한 당신만의 DNA',
  emoji: '🧬',
  accentColor: DSColors.accentSecondary,
  steps: [
    SurveyStep(
      id: 'mbti',
      question: 'MBTI가 어떻게 되세요?',
      inputType: SurveyInputType.chips,
      options: _mbtiTypeOptions,
      isRequired: true,
    ),
    SurveyStep(
      id: 'bloodType',
      question: '혈액형을 선택해주세요',
      inputType: SurveyInputType.chips,
      options: _personalityDnaBloodTypeOptions,
      isRequired: true,
    ),
    SurveyStep(
      id: 'zodiac',
      question: '별자리가 어떻게 되세요?',
      inputType: SurveyInputType.chips,
      options: _personalityDnaZodiacOptions,
      isRequired: true,
    ),
    SurveyStep(
      id: 'zodiacAnimal',
      question: '띠가 어떻게 되세요?',
      inputType: SurveyInputType.chips,
      options: _personalityDnaZodiacAnimalOptions,
      isRequired: true,
    ),
  ],
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
  accentColor: DSColors.accentSecondary,
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
  accentColor: DSColors.accentSecondary,
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
  accentColor: DSColors.accentSecondary,
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
  accentColor: DSColors.accentSecondary,
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
// ExLover (재회 인사이트) 설문 설정 - 8단계 심층 상담
// ============================================================

/// Step 1: 상담 목표 선택 (가치 제안)
const _exLoverPrimaryGoalOptions = [
  SurveyOption(id: 'healing', label: '감정 정리 + 힐링', emoji: '🌿'),
  SurveyOption(id: 'reunion_strategy', label: '재회 전략 가이드', emoji: '🔄'),
  SurveyOption(id: 'read_their_mind', label: '상대방 마음 읽기', emoji: '💭'),
  SurveyOption(id: 'new_start', label: '새 출발 준비도 확인', emoji: '🌸'),
];

/// Step 2: 이별 시기 (상세)
const _exLoverBreakupTimeOptions = [
  SurveyOption(id: 'very_recent', label: '1주일 이내', emoji: '⚡'),
  SurveyOption(id: 'recent', label: '1개월 이내', emoji: '💔'),
  SurveyOption(id: '1to3months', label: '1-3개월 전', emoji: '📅'),
  SurveyOption(id: '3to6months', label: '3-6개월 전', emoji: '🗓️'),
  SurveyOption(id: '6to12months', label: '6개월-1년 전', emoji: '📆'),
  SurveyOption(id: 'over_year', label: '1년 이상', emoji: '⏳'),
];

/// Step 3: 이별 주도권
const _exLoverInitiatorOptions = [
  SurveyOption(id: 'me', label: '내가 먼저', emoji: '🙋'),
  SurveyOption(id: 'them', label: '상대가 먼저', emoji: '😢'),
  SurveyOption(id: 'mutual', label: '서로 합의', emoji: '🤝'),
];

/// Step 4: 관계 깊이
const _exLoverRelationshipDepthOptions = [
  SurveyOption(id: 'short_casual', label: '짧고 가벼웠어 (1-3개월)', emoji: '🌱'),
  SurveyOption(id: 'growing', label: '진지해지던 중이었어 (3-6개월)', emoji: '🌷'),
  SurveyOption(id: 'serious', label: '진지한 관계였어 (6개월-1년)', emoji: '🌹'),
  SurveyOption(id: 'deep', label: '깊은 관계였어 (1-2년)', emoji: '💐'),
  SurveyOption(id: 'long_term', label: '오래된 관계였어 (2년+)', emoji: '🏡'),
  SurveyOption(id: 'engagement', label: '결혼을 약속했었어', emoji: '💍'),
];

/// Step 5: 핵심 이별 이유 (솔직하게)
const _exLoverCoreReasonOptions = [
  SurveyOption(id: 'values', label: '가치관/미래 계획 불일치', emoji: '🧭'),
  SurveyOption(id: 'communication', label: '소통 문제/잦은 싸움', emoji: '💢'),
  SurveyOption(id: 'trust', label: '신뢰 문제 (거짓말/의심)', emoji: '🔒'),
  SurveyOption(id: 'cheating', label: '외도/바람', emoji: '💔'),
  SurveyOption(id: 'distance', label: '거리/시간 문제', emoji: '🌍'),
  SurveyOption(id: 'family', label: '가족 반대/외부 압력', emoji: '👨‍👩‍👧'),
  SurveyOption(id: 'feelings_changed', label: '감정이 식음', emoji: '❄️'),
  SurveyOption(id: 'personal_issues', label: '개인적 문제 (직장/건강)', emoji: '🏥'),
  SurveyOption(id: 'unknown', label: '잘 모르겠어', emoji: '❓'),
];

/// Step 7: 현재 상태 (multiSelect 최대 3개)
const _exLoverCurrentStateOptions = [
  SurveyOption(id: 'cant_sleep', label: '잠을 못 자', emoji: '😴'),
  SurveyOption(id: 'checking_sns', label: 'SNS 계속 확인해', emoji: '📱'),
  SurveyOption(id: 'crying', label: '자주 울어', emoji: '😢'),
  SurveyOption(id: 'angry', label: '화가 나', emoji: '😤'),
  SurveyOption(id: 'regret', label: '후회돼', emoji: '😔'),
  SurveyOption(id: 'miss_them', label: '너무 보고싶어', emoji: '💙'),
  SurveyOption(id: 'relieved', label: '해방감이 느껴져', emoji: '🕊️'),
  SurveyOption(id: 'confused', label: '내 감정을 모르겠어', emoji: '🌀'),
  SurveyOption(id: 'moving_on', label: '극복하고 있어', emoji: '🌱'),
];

/// Step 8: 연락 상태
const _exLoverContactStatusOptions = [
  SurveyOption(id: 'blocked_both', label: '서로 차단', emoji: '🚫'),
  SurveyOption(id: 'blocked_by_them', label: '상대가 차단', emoji: '🔒'),
  SurveyOption(id: 'i_blocked', label: '내가 차단', emoji: '🛑'),
  SurveyOption(id: 'no_contact', label: '연락 안 함', emoji: '📵'),
  SurveyOption(id: 'occasional', label: '가끔 연락', emoji: '📬'),
  SurveyOption(id: 'frequent', label: '자주 연락', emoji: '💬'),
  SurveyOption(id: 'still_meeting', label: '아직 만나고 있음', emoji: '🫂'),
];

/// 목표별 분기 질문 - 힐링
const _exLoverHealingDeepOptions = [
  SurveyOption(id: 'morning', label: '아침에 일어날 때', emoji: '🌅'),
  SurveyOption(id: 'night', label: '밤에 잠들기 전', emoji: '🌙'),
  SurveyOption(id: 'places', label: '우리 갔던 장소 볼 때', emoji: '📍'),
  SurveyOption(id: 'alone', label: '혼자 있을 때', emoji: '🏠'),
  SurveyOption(id: 'couples', label: '커플 볼 때', emoji: '💑'),
];

/// 목표별 분기 질문 - 재회 전략
const _exLoverReunionDeepOptions = [
  SurveyOption(id: 'i_changed', label: '내가 변했어', emoji: '🦋'),
  SurveyOption(id: 'they_changed', label: '상대가 변했을 것 같아', emoji: '✨'),
  SurveyOption(id: 'situation_changed', label: '상황이 달라졌어', emoji: '🔄'),
  SurveyOption(id: 'both_grew', label: '둘 다 성장했어', emoji: '🌱'),
  SurveyOption(id: 'not_sure', label: '잘 모르겠어', emoji: '🤔'),
];

/// 목표별 분기 질문 - 상대방 마음 읽기 (MBTI)
const _exLoverMbtiOptions = [
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
  SurveyOption(id: 'unknown', label: '몰라', emoji: '❓'),
];

/// 목표별 분기 질문 - 새 출발
const _exLoverNewStartDeepOptions = [
  SurveyOption(id: 'trust', label: '신뢰/소통', emoji: '🤝'),
  SurveyOption(id: 'stability', label: '감정적 안정', emoji: '🧘'),
  SurveyOption(id: 'values', label: '비슷한 가치관', emoji: '🧭'),
  SurveyOption(id: 'passion', label: '설렘과 열정', emoji: '🔥'),
  SurveyOption(id: 'growth', label: '서로의 성장', emoji: '🌱'),
];

/// 상대방 생년 옵션 (10년 단위 + 모름)
const _exLoverPartnerBirthYearOptions = [
  SurveyOption(id: '2010s', label: '2010년대생', emoji: '🌱'),
  SurveyOption(id: '2000s', label: '2000년대생', emoji: '🧒'),
  SurveyOption(id: '1990s', label: '90년대생', emoji: '🌸'),
  SurveyOption(id: '1980s', label: '80년대생', emoji: '🌿'),
  SurveyOption(id: '1970s_or_older', label: '70년대 이전', emoji: '🏔️'),
  SurveyOption(id: 'unknown', label: '모르겠어요', emoji: '❓'),
];

/// ExLover 설문 설정 (8단계 심층 상담)
const exLoverSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.exLover,
  title: '재회 인사이트',
  description: '솔직한 조언자가 함께할게요',
  emoji: '💬',
  accentColor: DSColors.accentSecondary,
  steps: [
    // Step 1: 상담 목표 (가치 제안 선택)
    SurveyStep(
      id: 'primaryGoal',
      question: '오늘 이 상담에서 뭘 얻고 싶어? 💭',
      inputType: SurveyInputType.chips,
      options: _exLoverPrimaryGoalOptions,
    ),
    // Step 2: 이별 시기
    SurveyStep(
      id: 'breakupTime',
      question: '이별은 언제 있었어? 💔',
      inputType: SurveyInputType.chips,
      options: _exLoverBreakupTimeOptions,
    ),
    // Step 2-1: 상대방 이름 (선택)
    SurveyStep(
      id: 'exPartnerName',
      question: '상대방 이름이나 별명 알려줄래? 🏷️\n(모르면 "그 사람"으로 부를게)',
      inputType: SurveyInputType.text,
      isRequired: false,
    ),
    // Step 2-2: 상대방 나이대 (선택)
    SurveyStep(
      id: 'exPartnerBirthYear',
      question: '상대방은 몇 년생이야? 👤',
      inputType: SurveyInputType.chips,
      options: _exLoverPartnerBirthYearOptions,
      isRequired: false,
    ),
    // Step 2-3: 상대방 MBTI (선택 - 모든 목표에서 표시)
    SurveyStep(
      id: 'exPartnerMbti',
      question: '상대방 MBTI 알아? 🎭\n(성격 분석에 도움이 돼)',
      inputType: SurveyInputType.chips,
      options: _exLoverMbtiOptions,
      isRequired: false,
    ),
    // Step 3: 이별 주도권
    SurveyStep(
      id: 'breakupInitiator',
      question: '누가 먼저 이별을 말했어?',
      inputType: SurveyInputType.chips,
      options: _exLoverInitiatorOptions,
    ),
    // Step 4: 관계 깊이
    SurveyStep(
      id: 'relationshipDepth',
      question: '우리 관계는 얼마나 깊었어? 💕',
      inputType: SurveyInputType.chips,
      options: _exLoverRelationshipDepthOptions,
    ),
    // Step 5: 핵심 이별 이유
    SurveyStep(
      id: 'coreReason',
      question: '헤어진 핵심 이유가 뭐였어? (솔직하게) 🤔',
      inputType: SurveyInputType.chips,
      options: _exLoverCoreReasonOptions,
    ),
    // Step 6: 자세한 이야기 (음성/텍스트)
    SurveyStep(
      id: 'detailedStory',
      question: '좀 더 자세히 얘기해줄 수 있어? 🎤\n상담사처럼 들을게',
      inputType: SurveyInputType.voice,
      isRequired: false,
    ),
    // Step 7: 현재 상태 (multiSelect)
    SurveyStep(
      id: 'currentState',
      question: '지금 상태는 어때? 솔직하게 골라줘 🌡️\n(최대 3개)',
      inputType: SurveyInputType.multiSelect,
      options: _exLoverCurrentStateOptions,
    ),
    // Step 8: 연락 상태
    SurveyStep(
      id: 'contactStatus',
      question: '지금 연락은 어떻게 되고 있어? 📞',
      inputType: SurveyInputType.chips,
      options: _exLoverContactStatusOptions,
    ),
    // Step 9: 목표별 분기 질문 - 힐링
    SurveyStep(
      id: 'healingDeep',
      question: '가장 힘든 순간은 언제야? 🌙',
      inputType: SurveyInputType.chips,
      options: _exLoverHealingDeepOptions,
      showWhen: {'primaryGoal': 'healing'},
    ),
    // Step 9: 목표별 분기 질문 - 재회 전략
    SurveyStep(
      id: 'reunionDeep',
      question: '재회하면 뭐가 달라질 것 같아? 💫',
      inputType: SurveyInputType.chips,
      options: _exLoverReunionDeepOptions,
      showWhen: {'primaryGoal': 'reunion_strategy'},
    ),
    // Step 9: 목표별 분기 질문 - 새 출발
    SurveyStep(
      id: 'newStartDeep',
      question: '새로운 연애에서 가장 중요한 건 뭐야? 💝',
      inputType: SurveyInputType.chips,
      options: _exLoverNewStartDeepOptions,
      showWhen: {'primaryGoal': 'new_start'},
    ),
  ],
);

// ============================================================
// BlindDate (소개팅 가이드) 설문 설정
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
const blindDateSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.blindDate,
  title: '소개팅 인사이트',
  description: '소개팅 인사이트를 확인해드릴게요!',
  emoji: '💘',
  accentColor: DSColors.accentSecondary,
  steps: [
    SurveyStep(
      id: 'dateType',
      question: '어떤 방식으로 만나시나요?',
      inputType: SurveyInputType.chips,
      options: _blindDateTypeOptions,
    ),
    SurveyStep(
      id: 'expectation',
      question: '어떤 만남을 원하세요?',
      inputType: SurveyInputType.chips,
      options: _blindDateExpectOptions,
    ),
    SurveyStep(
      id: 'meetingTime',
      question: '만남 시간대가 어떻게 되나요?',
      inputType: SurveyInputType.chips,
      options: _blindDateTimeOptions,
    ),
    SurveyStep(
      id: 'isFirstBlindDate',
      question: '첫 소개팅이신가요?',
      inputType: SurveyInputType.chips,
      options: _blindDateFirstTimeOptions,
    ),
    SurveyStep(
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
      showWhen: {'hasPartnerInfo': 'photo'},
    ),
    // 조건부: 인스타를 안다고 하면 아이디 입력
    SurveyStep(
      id: 'partnerInstagram',
      question: '상대방 인스타그램 아이디를 알려주세요 📱',
      inputType: SurveyInputType.text,
      isRequired: false,
      showWhen: {'hasPartnerInfo': 'instagram'},
    ),
  ],
);

// ============================================================
// Money (재물/투자 인사이트) 설문 설정
// ============================================================

/// 재물 목표 옵션
const _wealthGoalOptions = [
  SurveyOption(id: 'saving', label: '목돈 마련', emoji: '💰'),
  SurveyOption(id: 'house', label: '내집 마련', emoji: '🏠'),
  SurveyOption(id: 'expense', label: '큰 지출 예정', emoji: '🚗'),
  SurveyOption(id: 'investment', label: '투자 수익', emoji: '📈'),
  SurveyOption(id: 'income', label: '안정적 수입', emoji: '💵'),
];

/// 재물 고민 옵션
const _wealthConcernOptions = [
  SurveyOption(id: 'spending', label: '지출 관리', emoji: '💸'),
  SurveyOption(id: 'loss', label: '투자 손실', emoji: '📉'),
  SurveyOption(id: 'debt', label: '빚/대출', emoji: '💳'),
  SurveyOption(id: 'returns', label: '수익률', emoji: '📊'),
  SurveyOption(id: 'savings', label: '저축', emoji: '🏦'),
];

/// 수입 상태 옵션
const _incomeStatusOptions = [
  SurveyOption(id: 'increasing', label: '늘어나는 중', emoji: '📈'),
  SurveyOption(id: 'stable', label: '안정적', emoji: '➡️'),
  SurveyOption(id: 'decreasing', label: '줄어드는 중', emoji: '📉'),
  SurveyOption(id: 'irregular', label: '불규칙', emoji: '🔀'),
];

/// 지출 패턴 옵션
const _expensePatternOptions = [
  SurveyOption(id: 'frugal', label: '절약형', emoji: '🐜'),
  SurveyOption(id: 'balanced', label: '균형형', emoji: '⚖️'),
  SurveyOption(id: 'spender', label: '소비 즐김', emoji: '🛍️'),
  SurveyOption(id: 'variable', label: '기복 있음', emoji: '🎲'),
];

/// 투자 성향 옵션
const _investmentStyleOptions = [
  SurveyOption(id: 'safe', label: '안전 최우선', emoji: '🛡️'),
  SurveyOption(id: 'balanced', label: '균형 추구', emoji: '⚖️'),
  SurveyOption(id: 'aggressive', label: '공격적', emoji: '🚀'),
];

/// 관심 분야 옵션 (다중선택)
const _investmentAreaOptions = [
  SurveyOption(id: 'stock', label: '주식', emoji: '📈'),
  SurveyOption(id: 'crypto', label: '코인', emoji: '₿'),
  SurveyOption(id: 'realestate', label: '부동산', emoji: '🏠'),
  SurveyOption(id: 'saving', label: '저축/예금', emoji: '🏦'),
  SurveyOption(id: 'business', label: '사업', emoji: '💼'),
  SurveyOption(id: 'side', label: '부업/N잡', emoji: '💵'),
];

/// 시급성 옵션
const _urgencyOptions = [
  SurveyOption(id: 'urgent', label: '급함', emoji: '⚡'),
  SurveyOption(id: 'thisYear', label: '올해 안에', emoji: '📅'),
  SurveyOption(id: 'longTerm', label: '장기적으로', emoji: '🌱'),
];

/// Money 설문 설정 (7단계 확장)
const moneySurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.money,
  title: '재물 인사이트',
  description: '당신의 재정 상황을 분석하고 맞춤 조언을 드릴게요',
  emoji: '💰',
  accentColor: DSColors.accentSecondary,
  steps: [
    // Step 1: 재물 목표
    SurveyStep(
      id: 'goal',
      question: '재물 목표가 뭐예요? 🎯',
      inputType: SurveyInputType.chips,
      options: _wealthGoalOptions,
    ),
    // Step 2: 가장 고민되는 것
    SurveyStep(
      id: 'concern',
      question: '가장 고민되는 건? 🤔',
      inputType: SurveyInputType.chips,
      options: _wealthConcernOptions,
    ),
    // Step 3: 수입 상태
    SurveyStep(
      id: 'income',
      question: '요즘 수입 상태는? 💵',
      inputType: SurveyInputType.chips,
      options: _incomeStatusOptions,
    ),
    // Step 4: 지출 패턴
    SurveyStep(
      id: 'expense',
      question: '지출 패턴은 어때요? 🛒',
      inputType: SurveyInputType.chips,
      options: _expensePatternOptions,
    ),
    // Step 5: 투자 성향
    SurveyStep(
      id: 'risk',
      question: '투자 성향은? 📊',
      inputType: SurveyInputType.chips,
      options: _investmentStyleOptions,
    ),
    // Step 6: 관심 분야 (다중선택)
    SurveyStep(
      id: 'interests',
      question: '관심 있는 분야를 모두 선택해주세요 ✨',
      inputType: SurveyInputType.multiSelect,
      options: _investmentAreaOptions,
    ),
    // Step 7: 시급성
    SurveyStep(
      id: 'urgency',
      question: '얼마나 급하세요? ⏰',
      inputType: SurveyInputType.chips,
      options: _urgencyOptions,
    ),
  ],
);

// ============================================================
// LuckyItems (행운 아이템) 설문 설정
// ============================================================

/// 아이템 카테고리 옵션
const _luckyItemCategoryOptions = [
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
  accentColor: DSColors.accentSecondary,
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
  accentColor: DSColors.accentSecondary,
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

/// 복채 옵션 (소원 후 감사 토큰)
const _wishBokchaeOptions = [
  SurveyOption(id: '0', label: '다음에 할게요', emoji: '🙏'),
  SurveyOption(id: '1', label: '1개', emoji: '🧧'),
  SurveyOption(id: '3', label: '3개', emoji: '🧧🧧🧧'),
  SurveyOption(id: '5', label: '5개', emoji: '🧧🧧🧧🧧🧧'),
];

/// Wish 설문 설정
const wishSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.wish,
  title: '소원 빌기',
  description: '마음 속 소원을 빌어보세요',
  emoji: '🌠',
  accentColor: DSColors.accentSecondary,
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
    SurveyStep(
      id: 'bokchae',
      question: '감사의 복채를 올리시겠어요?',
      inputType: SurveyInputType.chips,
      options: _wishBokchaeOptions,
      isRequired: false,
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
  accentColor: DSColors.accentSecondary,
  steps: [], // 추가 수집 없음
);

// ============================================================
// Health (건강 체크) 설문 설정
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

/// 수면 품질 옵션 (1-5)
const _sleepQualityOptions = [
  SurveyOption(id: '1', label: '매우 나쁨', emoji: '😵'),
  SurveyOption(id: '2', label: '나쁨', emoji: '😫'),
  SurveyOption(id: '3', label: '보통', emoji: '😐'),
  SurveyOption(id: '4', label: '좋음', emoji: '😊'),
  SurveyOption(id: '5', label: '매우 좋음', emoji: '😴'),
];

/// 운동 빈도 옵션 (1-5)
const _exerciseFrequencyOptions = [
  SurveyOption(id: '1', label: '거의 안함', emoji: '🛋️'),
  SurveyOption(id: '2', label: '가끔 (주1회)', emoji: '🚶'),
  SurveyOption(id: '3', label: '보통 (주2-3회)', emoji: '🏃'),
  SurveyOption(id: '4', label: '자주 (주4-5회)', emoji: '💪'),
  SurveyOption(id: '5', label: '매일', emoji: '🏋️'),
];

/// 스트레스 수준 옵션 (1-5)
const _stressLevelOptions = [
  SurveyOption(id: '1', label: '거의 없음', emoji: '😌'),
  SurveyOption(id: '2', label: '조금', emoji: '🙂'),
  SurveyOption(id: '3', label: '보통', emoji: '😐'),
  SurveyOption(id: '4', label: '많음', emoji: '😓'),
  SurveyOption(id: '5', label: '매우 많음', emoji: '😰'),
];

/// 식사 규칙성 옵션 (1-5)
const _mealRegularityOptions = [
  SurveyOption(id: '1', label: '불규칙', emoji: '🍕'),
  SurveyOption(id: '2', label: '자주 거름', emoji: '🍔'),
  SurveyOption(id: '3', label: '보통', emoji: '🍱'),
  SurveyOption(id: '4', label: '대체로 규칙적', emoji: '🥗'),
  SurveyOption(id: '5', label: '매우 규칙적', emoji: '🥦'),
];

/// 현재 컨디션 옵션
const _currentConditionOptions = [
  SurveyOption(id: 'excellent', label: '매우 좋음', emoji: '💪'),
  SurveyOption(id: 'good', label: '좋음', emoji: '😊'),
  SurveyOption(id: 'normal', label: '보통', emoji: '😐'),
  SurveyOption(id: 'tired', label: '피곤함', emoji: '😴'),
  SurveyOption(id: 'poor', label: '매우 피곤함', emoji: '😫'),
];

/// Health 설문 설정
const healthSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.health,
  title: '건강 인사이트',
  description: '오늘의 건강 인사이트를 확인해드릴게요',
  emoji: '💊',
  accentColor: DSColors.accentSecondary,
  steps: [
    SurveyStep(
      id: 'currentCondition',
      question: '오늘 전반적인 컨디션이 어떤가요?',
      inputType: SurveyInputType.chips,
      options: _currentConditionOptions,
    ),
    SurveyStep(
      id: 'concern',
      question: '특히 신경 쓰이는 부분이 있으세요?',
      inputType: SurveyInputType.chips,
      options: _healthConcernOptions,
      isRequired: false,
    ),
    SurveyStep(
      id: 'sleepQuality',
      question: '요즘 수면 상태는 어떠세요?',
      inputType: SurveyInputType.chips,
      options: _sleepQualityOptions,
    ),
    SurveyStep(
      id: 'exerciseFrequency',
      question: '운동은 얼마나 자주 하세요?',
      inputType: SurveyInputType.chips,
      options: _exerciseFrequencyOptions,
    ),
    SurveyStep(
      id: 'stressLevel',
      question: '요즘 스트레스는 어느 정도예요?',
      inputType: SurveyInputType.chips,
      options: _stressLevelOptions,
    ),
    SurveyStep(
      id: 'mealRegularity',
      question: '식사는 규칙적으로 하시나요?',
      inputType: SurveyInputType.chips,
      options: _mealRegularityOptions,
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
  accentColor: DSColors.accentSecondary,
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

/// 스포츠 종목 옵션 (한국 인기 종목)
const _sportTypeOptions = [
  SurveyOption(id: 'baseball', label: '야구', emoji: '⚾'),
  SurveyOption(id: 'soccer', label: '축구', emoji: '⚽'),
  SurveyOption(id: 'basketball', label: '농구', emoji: '🏀'),
  SurveyOption(id: 'volleyball', label: '배구', emoji: '🏐'),
  SurveyOption(id: 'esports', label: 'e스포츠', emoji: '🎮'),
];

/// SportsGame (경기 인사이트) 설문 설정
/// Step 1: 종목 선택 → Step 2: 경기 선택 → Step 3: 응원팀 선택
const sportsGameSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.sportsGame,
  title: '경기 인사이트',
  description: '경기 결과를 예측해드릴게요!',
  emoji: '🏆',
  accentColor: DSColors.accentSecondary,
  steps: [
    // Step 1: 종목 선택
    SurveyStep(
      id: 'sport',
      question: '어떤 종목인가요? 🏆',
      inputType: SurveyInputType.chips,
      options: _sportTypeOptions,
    ),
    // Step 2: 경기 선택 (종목에 따라 동적 로드)
    SurveyStep(
      id: 'match',
      question: '어떤 경기를 볼까요? 📅',
      inputType: SurveyInputType.matchSelection,
      dependsOn: 'sport',
    ),
    // Step 3: 응원팀 선택 (선택한 경기의 양 팀 중)
    SurveyStep(
      id: 'favoriteTeam',
      question: '어느 팀을 응원하시나요? 📣',
      inputType: SurveyInputType.chips,
      dependsOn: 'match',
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
  accentColor: DSColors.accentSecondary,
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

/// Celebrity 관계 유형 옵션
const _celebrityConnectionTypeOptions = [
  SurveyOption(id: 'ideal_match', label: '이상형으로', emoji: '💘'),
  SurveyOption(id: 'friend', label: '친구로', emoji: '🤝'),
  SurveyOption(id: 'colleague', label: '동료로', emoji: '💼'),
  SurveyOption(id: 'fan', label: '팬으로', emoji: '⭐'),
];

/// Celebrity 분석 유형 옵션 (유형별 전용 카드)
const _celebrityInterestOptions = [
  SurveyOption(id: 'personality', label: '성격 궁합', emoji: '🧠'),
  SurveyOption(id: 'love', label: '연애 궁합', emoji: '💕'),
  SurveyOption(id: 'pastLife', label: '전생 인연', emoji: '🌙'),
  SurveyOption(id: 'timing', label: '운명의 시기', emoji: '⏰'),
];

/// Celebrity 설문 설정
const celebritySurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.celebrity,
  title: '유명인 궁합',
  description: '좋아하는 유명인과 궁합을 알아볼까요?',
  emoji: '⭐',
  accentColor: DSColors.accentSecondary,
  steps: [
    SurveyStep(
      id: 'celebrity',
      question: '궁합을 보고 싶은 유명인을 선택해줘! ⭐',
      inputType: SurveyInputType.celebritySelection,
      options: [],
    ),
    SurveyStep(
      id: 'connectionType',
      question: '어떤 관계로 궁합을 볼까? 💫',
      inputType: SurveyInputType.chips,
      options: _celebrityConnectionTypeOptions,
    ),
    SurveyStep(
      id: 'interest',
      question: '어떤 궁합이 궁금해? ✨',
      inputType: SurveyInputType.chips,
      options: _celebrityInterestOptions,
      isRequired: true,
    ),
  ],
);

// ============================================================
// Pet (반려동물 궁합) 설문 설정
// ============================================================

/// Pet 관심포인트 옵션
const _petInterestOptions = [
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
  accentColor: DSColors.accentSecondary,
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
// Family (가족 인사이트) 설문 설정
// ============================================================

/// 가족 관심사 옵션
const _familyConcernOptions = [
  SurveyOption(id: 'relationship', label: '화목/관계', emoji: '💕'),
  SurveyOption(id: 'health', label: '건강', emoji: '💪'),
  SurveyOption(id: 'wealth', label: '재물', emoji: '💰'),
  SurveyOption(id: 'children', label: '자녀 교육', emoji: '📚'),
  SurveyOption(id: 'change', label: '변화/이사', emoji: '🔄'),
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
  title: '가족 인사이트',
  description: '가족 인사이트를 살펴볼게요',
  emoji: '👨‍👩‍👧‍👦',
  accentColor: DSColors.accentSecondary,
  steps: [
    SurveyStep(
      id: 'concern',
      question: '어떤 부분이 궁금하세요?',
      inputType: SurveyInputType.chips,
      options: _familyConcernOptions,
    ),
    SurveyStep(
      id: 'member',
      question: '누구에 대해 알아볼까요?',
      inputType: SurveyInputType.chips,
      options: _familyMemberOptions,
    ),
    // 특정 가족 구성원 선택 시 프로필 선택 단계 추가
    // "가족 전체"(all) 선택 시에는 이 단계 스킵
    SurveyStep(
      id: 'familyProfile',
      question: '가족 정보를 선택해주세요',
      inputType: SurveyInputType.familyProfile,
      options: [],
      showWhen: {
        'member': ['parents', 'spouse', 'children', 'siblings'],
      },
    ),
  ],
);

// ============================================================
// Naming (작명) 설문 설정
// ============================================================

/// 출산 예정일 확인 옵션
const _namingDueDateKnownOptions = [
  SurveyOption(id: 'known', label: '알아요', emoji: '📅'),
  SurveyOption(id: 'unknown', label: '미정이에요', emoji: '🤷'),
];

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

/// Naming 설문 설정 (작명 + 태명 통합)
const namingSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.naming,
  title: '작명/태명',
  description: '좋은 이름과 태명을 찾아드릴게요!',
  emoji: '📝',
  accentColor: DSColors.accentSecondary,
  steps: [
    SurveyStep(
      id: 'dueDateKnown',
      question: '출산 예정일을 알고 계세요?',
      inputType: SurveyInputType.chips,
      options: _namingDueDateKnownOptions,
    ),
    SurveyStep(
      id: 'dueDate',
      question: '출산 예정일이 언제인가요?',
      inputType: SurveyInputType.calendar,
      options: [],
      showWhen: {
        'dueDateKnown': ['known'],
      },
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
    // 태몽 (선택사항)
    SurveyStep(
      id: 'babyDream',
      question: '혹시 태몽을 꾸셨나요? 🌙\n어떤 꿈이었는지 알려주세요',
      inputType: SurveyInputType.text,
      isRequired: false,
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
  accentColor: DSColors.accentSecondary,
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
      inputType: SurveyInputType.ootdImage,
      options: [],
    ),
  ],
);

// ============================================================
// Exam (시험운) 설문 설정
// ============================================================

/// 시험 종류 옵션
const _examTypeOptions = [
  SurveyOption(id: 'csat', label: '수능', emoji: '🎓'),
  SurveyOption(id: 'license', label: '자격증', emoji: '📜'),
  SurveyOption(id: 'job', label: '취업/입사', emoji: '💼'),
  SurveyOption(id: 'promotion', label: '승진/진급', emoji: '📈'),
  SurveyOption(id: 'school', label: '입시/편입', emoji: '🏫'),
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
  description: '시험 합격 가이드를 드릴게요!',
  emoji: '📝',
  accentColor: DSColors.accentSecondary,
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
// Moving (이사운) 설문 설정
// ============================================================

/// 이사 시기 옵션
const _movingPeriodOptions = [
  SurveyOption(id: '1month', label: '1개월 이내', emoji: '🔥'),
  SurveyOption(id: '3months', label: '3개월 이내', emoji: '📅'),
  SurveyOption(id: '6months', label: '6개월 이내', emoji: '🗓️'),
  SurveyOption(id: 'year', label: '1년 이내', emoji: '📆'),
  SurveyOption(id: 'undecided', label: '아직 미정', emoji: '🤔'),
];

/// 이사 목적 옵션
const _movingPurposeOptions = [
  SurveyOption(id: 'work', label: '직장 때문에', emoji: '🏢'),
  SurveyOption(id: 'marriage', label: '결혼해서', emoji: '💑'),
  SurveyOption(id: 'education', label: '교육 환경', emoji: '🎓'),
  SurveyOption(id: 'better_life', label: '더 나은 환경', emoji: '🏡'),
  SurveyOption(id: 'investment', label: '투자 목적', emoji: '💰'),
  SurveyOption(id: 'family', label: '가족과 함께', emoji: '👨‍👩‍👧‍👦'),
  SurveyOption(id: 'other', label: '새로운 시작', emoji: '✨'),
];

/// 이사 걱정거리 옵션
const _movingConcernsOptions = [
  SurveyOption(id: 'direction', label: '방위가 걱정돼요', emoji: '🧭'),
  SurveyOption(id: 'timing', label: '시기가 맞을까요', emoji: '⏰'),
  SurveyOption(id: 'adaptation', label: '적응할 수 있을까요', emoji: '😟'),
  SurveyOption(id: 'neighbors', label: '이웃이 걱정돼요', emoji: '👥'),
  SurveyOption(id: 'cost', label: '비용이 부담돼요', emoji: '💸'),
  SurveyOption(id: 'feng_shui', label: '풍수가 궁금해요', emoji: '🏠'),
];

/// Moving 설문 설정 (6단계 개선 버전)
///
/// 1. 현재 지역 → 2. 이사할 지역 → 3. 이사 시기 → 4. 구체적 날짜(조건부)
/// → 5. 이사 목적 → 6. 걱정사항(선택)
///
/// 방향은 두 지역의 좌표를 기반으로 자동 계산됨
const movingSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.moving,
  title: '이사운',
  description: '새 보금자리의 길한 방향과 시기를 찾아드릴게요!',
  emoji: '🏠',
  accentColor: DSColors.accentSecondary,
  steps: [
    // Step 1: 현재 지역 (필수)
    SurveyStep(
      id: 'currentArea',
      question: '현재 어디 살고 있어요? 📍',
      inputType: SurveyInputType.location,
    ),
    // Step 2: 이사할 지역 (필수)
    SurveyStep(
      id: 'targetArea',
      question: '어디로 이사할 예정이에요? 🏠',
      inputType: SurveyInputType.location,
    ),
    // Step 3: 이사 시기 (필수)
    SurveyStep(
      id: 'movingPeriod',
      question: '이사 시기가 정해졌나요? 📅',
      inputType: SurveyInputType.chips,
      options: _movingPeriodOptions,
    ),
    // Step 4: 구체적인 날짜 (조건부 - 1개월/3개월 이내 선택 시)
    SurveyStep(
      id: 'specificDate',
      question: '구체적인 날짜가 있나요? 🗓️',
      inputType: SurveyInputType.calendar,
      isRequired: false,
      showWhen: {
        'movingPeriod': ['1month', '3months'],
      },
    ),
    // Step 5: 이사 목적 (필수)
    SurveyStep(
      id: 'purpose',
      question: '이사하는 이유가 뭐예요? 🤔',
      inputType: SurveyInputType.chips,
      options: _movingPurposeOptions,
    ),
    // Step 6: 걱정거리 (선택, 다중선택)
    SurveyStep(
      id: 'concerns',
      question: '특별히 걱정되는 점이 있나요? 💭',
      inputType: SurveyInputType.multiSelect,
      options: _movingConcernsOptions,
      isRequired: false,
    ),
  ],
);

// ============================================================
// YearlyEncounter (올해의 인연) 설문 설정
// ============================================================

/// 상대방 성별 옵션
const _targetGenderOptions = [
  SurveyOption(id: 'male', label: '남성', emoji: '👨'),
  SurveyOption(id: 'female', label: '여성', emoji: '👩'),
];

/// 사용자 연령대 옵션
const _userAgeOptions = [
  SurveyOption(id: 'early20s', label: '20대 초반', emoji: '🌱'),
  SurveyOption(id: 'mid20s', label: '20대 중반', emoji: '🌿'),
  SurveyOption(id: 'late20s', label: '20대 후반', emoji: '🌳'),
  SurveyOption(id: 'early30s', label: '30대 초반', emoji: '🌲'),
  SurveyOption(id: 'mid30s', label: '30대 중반', emoji: '🏔️'),
  SurveyOption(id: 'late30s', label: '30대 후반', emoji: '⛰️'),
  SurveyOption(id: 'over40s', label: '40대 이상', emoji: '🗻'),
];

/// 희망 MBTI 옵션
const _idealMbtiOptions = [
  SurveyOption(id: 'any', label: '상관없음', emoji: '✨'),
  SurveyOption(id: 'ISTJ', label: 'ISTJ', emoji: '📋'),
  SurveyOption(id: 'ISFJ', label: 'ISFJ', emoji: '🛡️'),
  SurveyOption(id: 'INFJ', label: 'INFJ', emoji: '🔮'),
  SurveyOption(id: 'INTJ', label: 'INTJ', emoji: '🧠'),
  SurveyOption(id: 'ISTP', label: 'ISTP', emoji: '🔧'),
  SurveyOption(id: 'ISFP', label: 'ISFP', emoji: '🎨'),
  SurveyOption(id: 'INFP', label: 'INFP', emoji: '🌙'),
  SurveyOption(id: 'INTP', label: 'INTP', emoji: '💡'),
  SurveyOption(id: 'ESTP', label: 'ESTP', emoji: '🎯'),
  SurveyOption(id: 'ESFP', label: 'ESFP', emoji: '🎉'),
  SurveyOption(id: 'ENFP', label: 'ENFP', emoji: '🌈'),
  SurveyOption(id: 'ENTP', label: 'ENTP', emoji: '⚡'),
  SurveyOption(id: 'ESTJ', label: 'ESTJ', emoji: '📊'),
  SurveyOption(id: 'ESFJ', label: 'ESFJ', emoji: '💝'),
  SurveyOption(id: 'ENFJ', label: 'ENFJ', emoji: '🌟'),
  SurveyOption(id: 'ENTJ', label: 'ENTJ', emoji: '👑'),
];

/// 남성 스타일 옵션 (올해의 인연)
const _maleStyleOptions = [
  SurveyOption(id: 'none', label: '없음', emoji: '🎲'),
  SurveyOption(id: 'dandy', label: '댄디한 정장남', emoji: '🎩'),
  SurveyOption(id: 'sporty', label: '스포티한 헬창', emoji: '💪'),
  SurveyOption(id: 'casual', label: '편안한 무드 감성남', emoji: '☕'),
  SurveyOption(id: 'prep', label: '프레피 대학생', emoji: '📚'),
  SurveyOption(id: 'street', label: '스트릿 패션 힙보이', emoji: '🎸'),
];

/// 여성 스타일 옵션 (올해의 인연)
const _femaleStyleOptions = [
  SurveyOption(id: 'none', label: '없음', emoji: '🎲'),
  SurveyOption(id: 'innocent', label: '청순한 첫사랑', emoji: '🌸'),
  SurveyOption(id: 'career', label: '시크한 커리어우먼', emoji: '💼'),
  SurveyOption(id: 'girlcrush', label: '걸크러쉬 언니', emoji: '🔥'),
  SurveyOption(id: 'pure', label: '수수한 옆집 언니', emoji: '🏠'),
  SurveyOption(id: 'glamour', label: '화려한 연예인상', emoji: '✨'),
];

/// YearlyEncounter 설문 설정
const yearlyEncounterSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.yearlyEncounter,
  title: '2026 올해의 인연',
  description: '올해 만나게 될 운명의 상대를 미리 만나보세요',
  emoji: '💕',
  accentColor: DSColors.accentSecondary,
  steps: [
    SurveyStep(
      id: 'targetGender',
      question: '어떤 성별의 인연을 찾고 있나요?',
      inputType: SurveyInputType.chips,
      options: _targetGenderOptions,
    ),
    SurveyStep(
      id: 'userAge',
      question: '나이대가 어떻게 되세요?',
      inputType: SurveyInputType.chips,
      options: _userAgeOptions,
    ),
    SurveyStep(
      id: 'idealMbti',
      question: '선호하는 MBTI가 있으신가요?',
      inputType: SurveyInputType.chips,
      options: _idealMbtiOptions,
    ),
    // 남성 스타일 선택 (targetGender가 male일 때만 표시)
    SurveyStep(
      id: 'idealStyle',
      question: '어떤 스타일이 끌리세요? ✨',
      inputType: SurveyInputType.chips,
      options: _maleStyleOptions,
      showWhen: {'targetGender': 'male'},
    ),
    // 여성 스타일 선택 (targetGender가 female일 때만 표시)
    SurveyStep(
      id: 'idealStyle',
      question: '어떤 스타일이 끌리세요? ✨',
      inputType: SurveyInputType.chips,
      options: _femaleStyleOptions,
      showWhen: {'targetGender': 'female'},
    ),
    SurveyStep(
      id: 'idealType',
      question: '추가로 원하는 특징이 있으면 적어주세요 💬',
      inputType: SurveyInputType.textWithSkip,
      isRequired: false,
    ),
  ],
);

// ============================================================
// PastLife (전생탐험) 설문 설정
// ============================================================

/// 전생 시대 예감 옵션
const _pastLifeEraVibeOptions = [
  SurveyOption(id: 'joseon_royal', label: '조선 왕실', emoji: '👑'),
  SurveyOption(id: 'joseon_scholar', label: '조선 선비', emoji: '📜'),
  SurveyOption(id: 'joseon_common', label: '조선 서민', emoji: '🏡'),
  SurveyOption(id: 'warrior', label: '전쟁터의 무사', emoji: '⚔️'),
  SurveyOption(id: 'artist', label: '예술가/기생', emoji: '🎨'),
  SurveyOption(id: 'unknown', label: '모르겠어요', emoji: '🌫️'),
];

/// 전생에서 궁금한 것 옵션
const _pastLifeCuriosityOptions = [
  SurveyOption(id: 'identity', label: '나는 누구였을까?', emoji: '🪞'),
  SurveyOption(id: 'story', label: '어떤 삶을 살았을까?', emoji: '📖'),
  SurveyOption(id: 'karma', label: '현생과 연결된 인연', emoji: '🔗'),
  SurveyOption(id: 'lesson', label: '전생이 남긴 교훈', emoji: '💡'),
];

/// 전생 기억 느낌 옵션
const _pastLifeFeelingOptions = [
  SurveyOption(id: 'deja_vu', label: '데자뷔를 자주 느껴요', emoji: '👁️'),
  SurveyOption(id: 'old_soul', label: '나이보다 성숙하다는 말을 들어요', emoji: '🧓'),
  SurveyOption(id: 'specific_era', label: '특정 시대에 끌려요', emoji: '⏳'),
  SurveyOption(id: 'recurring_dream', label: '반복되는 꿈이 있어요', emoji: '💭'),
  SurveyOption(id: 'none', label: '딱히 없어요', emoji: '🤷'),
];

const pastLifeSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.pastLife,
  title: '전생탐험',
  description: 'AI가 당신의 전생을 탐험해드려요',
  emoji: '🔮',
  accentColor: DSColors.accentSecondary,
  steps: [
    // Step 1: 전생에서 가장 궁금한 것
    SurveyStep(
      id: 'curiosity',
      question: '전생에서 가장 궁금한 게 뭐예요? 🔮',
      inputType: SurveyInputType.chips,
      options: _pastLifeCuriosityOptions,
    ),
    // Step 2: 전생 시대 예감 (선택)
    SurveyStep(
      id: 'eraVibe',
      question: '혹시 전생이 어느 시대였을 것 같으세요? ✨',
      inputType: SurveyInputType.chips,
      options: _pastLifeEraVibeOptions,
      isRequired: false,
    ),
    // Step 3: 전생 기억 느낌 (선택)
    SurveyStep(
      id: 'feeling',
      question: '평소에 이런 느낌 받으신 적 있으세요? 🌙',
      inputType: SurveyInputType.chips,
      options: _pastLifeFeelingOptions,
      isRequired: false,
    ),
    // Step 4: 사진 업로드 (핵심)
    SurveyStep(
      id: 'photo',
      question: '이제 전생을 읽어볼게요 🔮\n사진을 올려주시면 AI가 전생 초상화도 그려드릴 수 있어요',
      inputType: SurveyInputType.faceReading,
    ),
  ],
);
