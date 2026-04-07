import type { FortuneTypeId } from '@fortune/product-contracts';

import type {
  ActiveChatSurvey,
  ChatSurveyDefinition,
  ChatSurveyOption,
  ChatSurveyStep,
  CompletedChatSurvey,
} from './types';

const commonYesNoOptions = [
  { id: 'yes', label: '네' },
  { id: 'no', label: '아니요' },
] as const satisfies readonly ChatSurveyOption[];

const traditionalSurvey: ChatSurveyDefinition = {
  fortuneType: 'traditional-saju',
  title: '전통 사주',
  introReply: '전통 사주 흐름으로 먼저 볼게요. 꼭 필요한 것만 짧게 물어볼게요.',
  submitReply: '좋아요. 사주 흐름을 정리해서 같은 대화 안에 바로 보여드릴게요.',
  steps: [
    {
      id: 'analysisType',
      question: '어떤 분석이 가장 궁금하세요?',
      inputKind: 'chips',
      options: [
        { id: 'overall', label: '전체 흐름' },
        { id: 'love', label: '연애' },
        { id: 'career', label: '커리어' },
        { id: 'wealth', label: '재물' },
      ],
    },
    {
      id: 'specificQuestion',
      question: '특히 짚고 싶은 포인트가 있나요?',
      inputKind: 'chips',
      options: [
        { id: 'timing', label: '시기' },
        { id: 'strength', label: '강점' },
        { id: 'risk', label: '주의점' },
        { id: 'custom', label: '직접 적기' },
      ],
    },
    {
      id: 'customQuestion',
      question: '궁금한 점을 직접 적어주세요.',
      inputKind: 'text',
      placeholder: '예: 올해 하반기 이직 타이밍이 궁금해요.',
      required: false,
      showWhen: { specificQuestion: 'custom' },
    },
  ],
};

const dailyCalendarSurvey: ChatSurveyDefinition = {
  fortuneType: 'daily-calendar',
  title: '만세력',
  introReply: '만세력 흐름으로 이어갈게요. 날짜와 맥락만 먼저 맞춰볼게요.',
  submitReply: '좋아요. 날짜 흐름을 같은 채팅 안에서 바로 정리해드릴게요.',
  steps: [
    {
      id: 'calendarSync',
      question: '일정을 함께 볼까요?',
      inputKind: 'chips',
      options: [
        { id: 'sync', label: '일정과 함께 보기' },
        { id: 'date-only', label: '날짜만 보기' },
      ],
    },
    {
      id: 'targetDate',
      question: '어느 날짜가 궁금하세요?',
      inputKind: 'date',
    },
  ],
};

const mbtiSurvey: ChatSurveyDefinition = {
  fortuneType: 'mbti',
  title: 'MBTI',
  introReply: 'MBTI 흐름으로 볼게요. 성향 축을 바로 맞춰서 이어가겠습니다.',
  submitReply: '좋아요. MBTI 결과를 같은 채팅 안에 카드로 정리해드릴게요.',
  steps: [
    {
      id: 'mbtiConfirm',
      question: '지금 저장된 MBTI가 맞나요?',
      inputKind: 'chips',
      options: commonYesNoOptions,
    },
    {
      id: 'mbtiType',
      question: 'MBTI 유형을 선택해주세요.',
      inputKind: 'chips',
      required: false,
      showWhen: { mbtiConfirm: 'no' },
      options: [
        { id: 'INFP', label: 'INFP' },
        { id: 'ENFP', label: 'ENFP' },
        { id: 'INFJ', label: 'INFJ' },
        { id: 'ENFJ', label: 'ENFJ' },
        { id: 'INTJ', label: 'INTJ' },
        { id: 'ENTJ', label: 'ENTJ' },
        { id: 'ISTJ', label: 'ISTJ' },
        { id: 'ESTJ', label: 'ESTJ' },
      ],
    },
    {
      id: 'category',
      question: '어떤 인사이트를 받고 싶으세요?',
      inputKind: 'chips',
      options: [
        { id: 'love', label: '연애' },
        { id: 'work', label: '일' },
        { id: 'growth', label: '성장' },
        { id: 'mindset', label: '마음상태' },
      ],
    },
  ],
};

const careerSurvey: ChatSurveyDefinition = {
  fortuneType: 'career',
  title: '직업운',
  introReply: '커리어 흐름으로 바로 들어갈게요. 현재 위치를 먼저 짧게 맞춰볼게요.',
  submitReply: '좋아요. 커리어 흐름과 실행 포인트를 카드로 이어드릴게요.',
  steps: [
    {
      id: 'field',
      question: '어떤 분야에서 일하고 계신가요?',
      inputKind: 'chips',
      options: [
        { id: 'tech', label: 'IT/개발' },
        { id: 'finance', label: '금융' },
        { id: 'healthcare', label: '헬스케어' },
        { id: 'creative', label: '크리에이티브' },
        { id: 'other', label: '기타' },
      ],
    },
    {
      id: 'position',
      question: '현재 포지션은 어느 쪽에 가까우세요?',
      inputKind: 'chips',
      options: [
        { id: 'individual', label: '실무자' },
        { id: 'manager', label: '매니저' },
        { id: 'lead', label: '리드' },
        { id: 'student', label: '학생/취준' },
      ],
    },
    {
      id: 'concern',
      question: '가장 큰 고민은 무엇인가요?',
      inputKind: 'chips',
      options: [
        { id: 'growth', label: '성장 정체' },
        { id: 'direction', label: '방향성' },
        { id: 'change', label: '이직/전환' },
        { id: 'balance', label: '워라밸' },
      ],
    },
  ],
};

const loveSurvey: ChatSurveyDefinition = {
  fortuneType: 'love',
  title: '연애운',
  introReply: '연애운 흐름으로 갈게요. 지금 관계 맥락만 먼저 맞춰볼게요.',
  submitReply: '좋아요. 연애 에너지와 타이밍을 같은 채팅 안에서 바로 보여드릴게요.',
  steps: [
    {
      id: 'status',
      question: '지금 연애 상태가 어떤가요?',
      inputKind: 'chips',
      options: [
        { id: 'single', label: '솔로' },
        { id: 'dating', label: '연애 중' },
        { id: 'crush', label: '짝사랑' },
        { id: 'complicated', label: '복잡한 관계' },
      ],
    },
    {
      id: 'concern',
      question: '가장 궁금한 건 무엇인가요?',
      inputKind: 'chips',
      options: [
        { id: 'meeting', label: '만남/인연' },
        { id: 'confession', label: '고백 타이밍' },
        { id: 'relationship', label: '관계 발전' },
        { id: 'future', label: '미래/결혼' },
      ],
    },
    {
      id: 'datingStyle',
      question: '연애할 때 본인 스타일을 골라주세요.',
      inputKind: 'multi-select',
      required: false,
      maxSelections: 2,
      options: [
        { id: 'active', label: '적극적' },
        { id: 'romantic', label: '로맨틱' },
        { id: 'practical', label: '현실적' },
        { id: 'independent', label: '개인 시간 중요' },
      ],
    },
  ],
};

const healthSurvey: ChatSurveyDefinition = {
  fortuneType: 'health',
  title: '건강운',
  introReply: '건강 흐름으로 먼저 볼게요. 오늘 컨디션만 빠르게 맞춰보겠습니다.',
  submitReply: '좋아요. 건강 점수와 웰니스 플랜을 카드로 이어드릴게요.',
  steps: [
    {
      id: 'currentCondition',
      question: '오늘 전반적인 컨디션은 어떤가요?',
      inputKind: 'chips',
      options: [
        { id: 'great', label: '좋아요' },
        { id: 'normal', label: '보통이에요' },
        { id: 'tired', label: '피곤해요' },
        { id: 'drained', label: '많이 지쳤어요' },
      ],
    },
    {
      id: 'concern',
      question: '특히 신경 쓰이는 부분이 있나요?',
      inputKind: 'chips',
      options: [
        { id: 'sleep', label: '수면' },
        { id: 'stress', label: '스트레스' },
        { id: 'diet', label: '식사' },
        { id: 'fitness', label: '체력' },
      ],
    },
    {
      id: 'stressLevel',
      question: '요즘 스트레스는 어느 정도예요?',
      inputKind: 'chips',
      options: [
        { id: 'low', label: '낮아요' },
        { id: 'mid', label: '보통' },
        { id: 'high', label: '높아요' },
      ],
    },
  ],
};

const familySurvey: ChatSurveyDefinition = {
  fortuneType: 'family',
  title: '가족운',
  introReply: '가족운으로 이어갈게요. 누구에 대한 흐름인지 먼저 맞춰볼게요.',
  submitReply: '좋아요. 가족 하모니와 관계 팁을 카드로 바로 정리해드릴게요.',
  steps: [
    {
      id: 'concern',
      question: '무엇이 가장 궁금한가요?',
      inputKind: 'chips',
      options: [
        { id: 'harmony', label: '가족 분위기' },
        { id: 'conflict', label: '갈등 해결' },
        { id: 'support', label: '서로의 지원' },
        { id: 'future', label: '앞으로의 흐름' },
      ],
    },
    {
      id: 'member',
      question: '누구를 중심으로 볼까요?',
      inputKind: 'chips',
      options: [
        { id: 'parent', label: '부모님' },
        { id: 'partner', label: '배우자/연인' },
        { id: 'child', label: '자녀' },
        { id: 'sibling', label: '형제자매' },
      ],
    },
  ],
};

const pastLifeSurvey: ChatSurveyDefinition = {
  fortuneType: 'past-life',
  title: '전생 리딩',
  introReply: '전생 흐름으로 열어볼게요. 직감에 가까운 답으로 골라주세요.',
  submitReply: '좋아요. 상징과 메시지를 카드로 바로 풀어드릴게요.',
  steps: [
    {
      id: 'curiosity',
      question: '전생에서 가장 궁금한 건 무엇인가요?',
      inputKind: 'chips',
      options: [
        { id: 'identity', label: '나는 어떤 사람이었나' },
        { id: 'relationship', label: '누구와 얽혔나' },
        { id: 'lesson', label: '남은 과제는 무엇인가' },
      ],
    },
    {
      id: 'eraVibe',
      question: '끌리는 시대 감각이 있나요?',
      inputKind: 'chips',
      options: [
        { id: 'ancient', label: '고대' },
        { id: 'medieval', label: '중세' },
        { id: 'modern', label: '근대' },
        { id: 'unknown', label: '잘 모르겠어요' },
      ],
    },
    {
      id: 'feeling',
      question: '평소 자주 드는 감각을 골라주세요.',
      inputKind: 'chips',
      options: [
        { id: 'nostalgia', label: '낯익음' },
        { id: 'wander', label: '어딘가로 떠나고 싶음' },
        { id: 'guardian', label: '누군가를 지켜야 할 것 같음' },
        { id: 'artist', label: '표현 욕구가 큼' },
      ],
    },
  ],
};

const wishSurvey: ChatSurveyDefinition = {
  fortuneType: 'wish',
  title: '소원 리딩',
  introReply: '소원 흐름으로 갈게요. 바라는 결만 먼저 맞춰볼게요.',
  submitReply: '좋아요. 소원 흐름과 실행 메시지를 같은 채팅 안에 바로 담아드릴게요.',
  steps: [
    {
      id: 'category',
      question: '어떤 종류의 소원인가요?',
      inputKind: 'chips',
      options: [
        { id: 'love', label: '연애' },
        { id: 'career', label: '커리어' },
        { id: 'money', label: '재물' },
        { id: 'healing', label: '회복' },
      ],
    },
    {
      id: 'wishContent',
      question: '소원을 적어주세요.',
      inputKind: 'text',
      placeholder: '예: 올해 꼭 하고 싶은 일이 있어요.',
    },
    {
      id: 'bokchae',
      question: '감사의 복채를 올리시겠어요?',
      inputKind: 'chips',
      options: [
        { id: 'yes', label: '올릴게요' },
        { id: 'later', label: '나중에요' },
      ],
    },
  ],
};

const personalityDnaSurvey: ChatSurveyDefinition = {
  fortuneType: 'personality-dna',
  title: '성격운',
  introReply: '성격 DNA 흐름으로 볼게요. 기본 성향 축만 빠르게 맞춰볼게요.',
  submitReply: '좋아요. 성향 스펙트럼과 성장 조언을 카드로 정리해드릴게요.',
  steps: [
    {
      id: 'mbti',
      question: 'MBTI를 선택해주세요.',
      inputKind: 'chips',
      options: [
        { id: 'INFP', label: 'INFP' },
        { id: 'ENFP', label: 'ENFP' },
        { id: 'INFJ', label: 'INFJ' },
        { id: 'INTJ', label: 'INTJ' },
      ],
    },
    {
      id: 'bloodType',
      question: '혈액형을 선택해주세요.',
      inputKind: 'chips',
      options: [
        { id: 'A', label: 'A형' },
        { id: 'B', label: 'B형' },
        { id: 'AB', label: 'AB형' },
        { id: 'O', label: 'O형' },
      ],
    },
    {
      id: 'zodiac',
      question: '별자리를 선택해주세요.',
      inputKind: 'chips',
      options: [
        { id: 'aries', label: '양자리' },
        { id: 'taurus', label: '황소자리' },
        { id: 'gemini', label: '쌍둥이자리' },
        { id: 'cancer', label: '게자리' },
      ],
    },
  ],
};

const wealthSurvey: ChatSurveyDefinition = {
  fortuneType: 'wealth',
  title: '재물운',
  introReply: '재물운으로 들어갈게요. 목표와 불안 포인트만 먼저 맞춰볼게요.',
  submitReply: '좋아요. 금전 흐름과 행동 포인트를 카드로 정리해드릴게요.',
  steps: [
    {
      id: 'goal',
      question: '재물 목표가 무엇인가요?',
      inputKind: 'chips',
      options: [
        { id: 'save', label: '저축 늘리기' },
        { id: 'income', label: '수입 확대' },
        { id: 'invest', label: '투자 안정화' },
        { id: 'debt', label: '지출/부채 관리' },
      ],
    },
    {
      id: 'concern',
      question: '가장 고민되는 부분은 무엇인가요?',
      inputKind: 'chips',
      options: [
        { id: 'cashflow', label: '현금흐름' },
        { id: 'overspend', label: '과소비' },
        { id: 'risk', label: '투자 리스크' },
        { id: 'timing', label: '타이밍' },
      ],
    },
    {
      id: 'interests',
      question: '관심 분야를 골라주세요.',
      inputKind: 'multi-select',
      required: false,
      maxSelections: 2,
      options: [
        { id: 'salary', label: '연봉/수입' },
        { id: 'stocks', label: '주식' },
        { id: 'crypto', label: '코인' },
        { id: 'side-job', label: '부수입' },
      ],
    },
  ],
};

const talentSurvey: ChatSurveyDefinition = {
  fortuneType: 'talent',
  title: '재능 분석',
  introReply: '숨은 재능 흐름으로 볼게요. 흥미와 작업 습관을 먼저 맞춰볼게요.',
  submitReply: '좋아요. 강점 축과 성장 로드맵을 카드로 이어드릴게요.',
  steps: [
    {
      id: 'interest',
      question: '관심 있는 분야를 골라주세요.',
      inputKind: 'multi-select',
      maxSelections: 3,
      options: [
        { id: 'writing', label: '글/기획' },
        { id: 'design', label: '디자인' },
        { id: 'analysis', label: '분석' },
        { id: 'communication', label: '커뮤니케이션' },
      ],
    },
    {
      id: 'workStyle',
      question: '일할 때 어떤 스타일인가요?',
      inputKind: 'chips',
      options: [
        { id: 'deep', label: '깊게 몰입' },
        { id: 'fast', label: '빠르게 실행' },
        { id: 'team', label: '함께 조율' },
        { id: 'solo', label: '혼자 정리' },
      ],
    },
    {
      id: 'challenges',
      question: '요즘 어렵게 느끼는 부분을 골라주세요.',
      inputKind: 'multi-select',
      required: false,
      maxSelections: 2,
      options: [
        { id: 'focus', label: '집중 유지' },
        { id: 'confidence', label: '확신 부족' },
        { id: 'direction', label: '방향 선택' },
        { id: 'consistency', label: '꾸준함' },
      ],
    },
  ],
};

const exerciseSurvey: ChatSurveyDefinition = {
  fortuneType: 'exercise',
  title: '운동 운세',
  introReply: '운동 흐름으로 바로 갈게요. 목적과 강도만 먼저 맞춰볼게요.',
  submitReply: '좋아요. 추천 루틴과 컨디션 포인트를 카드로 이어드릴게요.',
  steps: [
    {
      id: 'goal',
      question: '운동 목적이 무엇인가요?',
      inputKind: 'chips',
      options: [
        { id: 'health', label: '건강 유지' },
        { id: 'strength', label: '근력 향상' },
        { id: 'diet', label: '체중 관리' },
        { id: 'mood', label: '기분 전환' },
      ],
    },
    {
      id: 'intensity',
      question: '원하는 강도는 어느 정도인가요?',
      inputKind: 'chips',
      options: [
        { id: 'light', label: '가볍게' },
        { id: 'medium', label: '중간' },
        { id: 'hard', label: '강하게' },
      ],
    },
  ],
};

const tarotSurvey: ChatSurveyDefinition = {
  fortuneType: 'tarot',
  title: '타로',
  introReply: '타로 흐름으로 열게요. 덱과 질문을 맞춘 뒤 카드 3장을 뽑아봅시다.',
  submitReply: '좋아요. 펼친 카드 해석을 같은 채팅 안에 바로 정리해드릴게요.',
  steps: [
    {
      id: 'deckId',
      question: '어떤 덱으로 열까요?',
      inputKind: 'chips',
      options: [
        { id: 'classic', label: '클래식' },
        { id: 'moonlight', label: '문라이트' },
        { id: 'gold', label: '골드' },
      ],
    },
    {
      id: 'purpose',
      question: '무슨 주제가 궁금하세요?',
      inputKind: 'chips',
      options: [
        { id: 'love', label: '연애' },
        { id: 'career', label: '커리어' },
        { id: 'mindset', label: '마음상태' },
        { id: 'timing', label: '타이밍' },
      ],
    },
    {
      id: 'questionText',
      question: '조금 더 구체적인 질문이 있으면 적어주세요.',
      inputKind: 'text-with-skip',
      required: false,
      placeholder: '예: 지금 밀고 있는 선택이 맞는지 궁금해요.',
    },
    {
      id: 'tarotSelection',
      question: '마음이 가는 카드 3장을 골라주세요.',
      inputKind: 'card-draw',
      maxSelections: 3,
      options: [
        { id: 'card-1', label: '1번 카드' },
        { id: 'card-2', label: '2번 카드' },
        { id: 'card-3', label: '3번 카드' },
        { id: 'card-4', label: '4번 카드' },
        { id: 'card-5', label: '5번 카드' },
        { id: 'card-6', label: '6번 카드' },
      ],
    },
  ],
};

const ootdSurvey: ChatSurveyDefinition = {
  fortuneType: 'ootd-evaluation',
  title: 'OOTD 코디',
  introReply: 'OOTD 흐름으로 볼게요. 오늘의 상황과 룩 포인트를 먼저 맞춰볼게요.',
  submitReply: '좋아요. 스타일 점수와 추천 아이템을 카드로 이어드릴게요.',
  steps: [
    {
      id: 'tpo',
      question: '오늘 어디로 가시나요?',
      inputKind: 'chips',
      options: [
        { id: 'work', label: '출근/업무' },
        { id: 'date', label: '데이트' },
        { id: 'daily', label: '일상 외출' },
        { id: 'special', label: '특별한 자리' },
      ],
    },
    {
      id: 'lookNote',
      question: '오늘 룩을 짧게 설명해주세요.',
      inputKind: 'text',
      placeholder: '예: 블랙 자켓에 데님, 실버 포인트로 입었어요.',
    },
  ],
};

const surveyDefinitions = [
  traditionalSurvey,
  dailyCalendarSurvey,
  mbtiSurvey,
  careerSurvey,
  loveSurvey,
  healthSurvey,
  familySurvey,
  pastLifeSurvey,
  wishSurvey,
  personalityDnaSurvey,
  wealthSurvey,
  talentSurvey,
  exerciseSurvey,
  tarotSurvey,
  ootdSurvey,
] as const satisfies readonly ChatSurveyDefinition[];

export const surveyDefinitionByFortuneType = Object.fromEntries(
  surveyDefinitions.map((definition) => [definition.fortuneType, definition]),
) as Partial<Record<FortuneTypeId, ChatSurveyDefinition>>;

const surveyDefinitionAliasByFortuneType: Partial<
  Record<FortuneTypeId, FortuneTypeId>
> = {
  daily: 'daily-calendar',
  'new-year': 'daily-calendar',
  'fortune-cookie': 'daily-calendar',
  'face-reading': 'traditional-saju',
  naming: 'traditional-saju',
  compatibility: 'love',
  'blind-date': 'love',
  'ex-lover': 'love',
  'avoid-people': 'love',
  celebrity: 'love',
  'yearly-encounter': 'love',
  exam: 'career',
  'lucky-items': 'wealth',
  lotto: 'wealth',
  biorhythm: 'personality-dna',
  'pet-compatibility': 'family',
};

export function getChatSurveyDefinition(fortuneType: FortuneTypeId) {
  const directDefinition = surveyDefinitionByFortuneType[fortuneType];

  if (directDefinition) {
    return directDefinition;
  }

  const aliasedType = surveyDefinitionAliasByFortuneType[fortuneType];

  if (!aliasedType) {
    return null;
  }

  const aliasedDefinition = surveyDefinitionByFortuneType[aliasedType];

  if (!aliasedDefinition) {
    return null;
  }

  return {
    ...aliasedDefinition,
    fortuneType,
  };
}

function shouldShowStep(
  step: ChatSurveyStep,
  answers: Record<string, unknown>,
) {
  if (!step.showWhen) {
    return true;
  }

  return Object.entries(step.showWhen).every(([key, expected]) => {
    const value = answers[key];

    if (Array.isArray(expected)) {
      return expected.includes(String(value ?? ''));
    }

    return String(value ?? '') === expected;
  });
}

export function getCurrentSurveyStep(session: ActiveChatSurvey) {
  let index = session.currentStepIndex;

  while (index < session.definition.steps.length) {
    const step = session.definition.steps[index];

    if (shouldShowStep(step, session.answers)) {
      return {
        index,
        step,
      };
    }

    index += 1;
  }

  return null;
}

export function startChatSurvey(definition: ChatSurveyDefinition): ActiveChatSurvey {
  return {
    fortuneType: definition.fortuneType,
    definition,
    currentStepIndex: 0,
    answers: {},
  };
}

export function resolveSurveyQuestion(
  session: ActiveChatSurvey,
  profile: {
    mbti?: string;
  },
) {
  const current = getCurrentSurveyStep(session);

  if (!current) {
    return null;
  }

  if (
    session.fortuneType === 'mbti' &&
    current.step.id === 'mbtiConfirm' &&
    profile.mbti
  ) {
    return `지금 저장된 MBTI가 ${profile.mbti}인데 맞나요?`;
  }

  return current.step.question;
}

export function applySurveyAnswer(
  session: ActiveChatSurvey,
  answer: unknown,
): {
  nextSurvey: ActiveChatSurvey | null;
  completed: CompletedChatSurvey | null;
} {
  const current = getCurrentSurveyStep(session);

  if (!current) {
    return {
      nextSurvey: null,
      completed: {
        fortuneType: session.fortuneType,
        answers: session.answers,
      },
    };
  }

  const nextAnswers = {
    ...session.answers,
    [current.step.id]: answer,
  };
  const nextSurvey: ActiveChatSurvey = {
    ...session,
    answers: nextAnswers,
    currentStepIndex: current.index + 1,
  };
  const nextStep = getCurrentSurveyStep(nextSurvey);

  if (!nextStep) {
    return {
      nextSurvey: null,
      completed: {
        fortuneType: session.fortuneType,
        answers: nextAnswers,
      },
    };
  }

  return {
    nextSurvey,
    completed: null,
  };
}

export function formatSurveyAnswerLabel(
  step: ChatSurveyStep,
  answer: unknown,
) {
  if (Array.isArray(answer)) {
    return answer
      .map((item) => formatSingleAnswerLabel(step, item))
      .join(', ');
  }

  return formatSingleAnswerLabel(step, answer);
}

function formatSingleAnswerLabel(step: ChatSurveyStep, answer: unknown) {
  if (typeof answer !== 'string') {
    if (answer instanceof Date) {
      return answer.toISOString().slice(0, 10);
    }

    return String(answer ?? '');
  }

  if (step.inputKind === 'date') {
    return answer;
  }

  const option = step.options?.find((candidate) => candidate.id === answer);

  if (!option) {
    return answer;
  }

  return option.emoji ? `${option.emoji} ${option.label}` : option.label;
}
