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

const compatibilitySurvey: ChatSurveyDefinition = {
  fortuneType: 'compatibility',
  title: '궁합',
  introReply: '궁합 흐름으로 갈게요. 상대 정보를 먼저 맞춰볼게요.',
  submitReply: '좋아요. 궁합 결과를 같은 채팅 안에 바로 보여드릴게요.',
  steps: [
    {
      id: 'matchTarget',
      question: '누구와의 궁합이 궁금하세요?',
      inputKind: 'match-selector',
    },
    {
      id: 'partnerBirth',
      question: '상대방의 생년월일을 입력해주세요.',
      inputKind: 'birth-datetime',
    },
    {
      id: 'focus',
      question: '어떤 궁합이 가장 궁금하세요?',
      inputKind: 'chips',
      options: [
        { id: 'overall', label: '전체 궁합' },
        { id: 'love', label: '연애 궁합' },
        { id: 'marriage', label: '결혼 궁합' },
        { id: 'business', label: '사업 궁합' },
      ],
    },
  ],
};

const blindDateSurvey: ChatSurveyDefinition = {
  fortuneType: 'blind-date',
  title: '소개팅 운세',
  introReply: '소개팅 흐름으로 볼게요. 만남 맥락을 먼저 맞춰볼게요.',
  submitReply: '좋아요. 소개팅 에너지와 포인트를 카드로 정리해드릴게요.',
  steps: [
    {
      id: 'timing',
      question: '소개팅은 언제인가요?',
      inputKind: 'date',
    },
    {
      id: 'feeling',
      question: '지금 기분은 어떤가요?',
      inputKind: 'chips',
      options: [
        { id: 'excited', label: '기대돼요' },
        { id: 'nervous', label: '긴장돼요' },
        { id: 'neutral', label: '보통이에요' },
        { id: 'reluctant', label: '별로예요' },
      ],
    },
    {
      id: 'goal',
      question: '이번 만남에서 바라는 건?',
      inputKind: 'chips',
      options: [
        { id: 'fun', label: '즐거운 대화' },
        { id: 'chemistry', label: '케미 확인' },
        { id: 'longterm', label: '진지한 관계' },
        { id: 'friend', label: '친구도 괜찮아요' },
      ],
    },
  ],
};

const exLoverSurvey: ChatSurveyDefinition = {
  fortuneType: 'ex-lover',
  title: '재회 운세',
  introReply: '재회 흐름으로 열어볼게요. 지금 감정 상태를 먼저 맞춰볼게요.',
  submitReply: '좋아요. 재회 에너지와 시그널을 카드로 정리해드릴게요.',
  steps: [
    {
      id: 'emotionState',
      question: '지금 감정 상태는?',
      inputKind: 'chips',
      options: [
        { id: 'missing', label: '그리워요' },
        { id: 'angry', label: '화나요' },
        { id: 'confused', label: '혼란스러워요' },
        { id: 'healed', label: '많이 나아졌어요' },
        { id: 'hopeful', label: '다시 만나고 싶어요' },
      ],
    },
    {
      id: 'timeElapsed',
      question: '헤어진 지 얼마나 됐나요?',
      inputKind: 'chips',
      options: [
        { id: 'recent', label: '한 달 이내' },
        { id: 'months', label: '1~6개월' },
        { id: 'halfyear', label: '6개월~1년' },
        { id: 'years', label: '1년 이상' },
      ],
    },
    {
      id: 'contactStatus',
      question: '연락은 하고 있나요?',
      inputKind: 'chips',
      options: [
        { id: 'none', label: '완전 끊김' },
        { id: 'occasional', label: '가끔' },
        { id: 'frequent', label: '자주' },
      ],
    },
  ],
};

const dreamSurvey: ChatSurveyDefinition = {
  fortuneType: 'dream',
  title: '꿈해몽',
  introReply: '꿈 해몽으로 열어볼게요. 꿈의 핵심 장면부터 맞춰볼게요.',
  submitReply: '좋아요. 꿈의 상징과 메시지를 카드로 풀어드릴게요.',
  steps: [
    {
      id: 'dreamContent',
      question: '꿈에서 가장 기억나는 장면을 적어주세요.',
      inputKind: 'text',
      placeholder: '예: 하늘을 날아다녔어요. 바다에서 물고기를 잡았어요.',
    },
    {
      id: 'emotion',
      question: '꿈에서 느낀 감정은?',
      inputKind: 'chips',
      options: [
        { id: 'happy', label: '기쁨/행복' },
        { id: 'scared', label: '두려움' },
        { id: 'confused', label: '혼란' },
        { id: 'sad', label: '슬픔' },
        { id: 'excited', label: '흥분/설렘' },
      ],
    },
    {
      id: 'category',
      question: '어떤 해석이 궁금하세요?',
      inputKind: 'chips',
      options: [
        { id: 'money', label: '재물' },
        { id: 'love', label: '연애' },
        { id: 'warning', label: '경고' },
        { id: 'message', label: '메시지' },
      ],
    },
  ],
};

const faceReadingSurvey: ChatSurveyDefinition = {
  fortuneType: 'face-reading',
  title: '관상',
  introReply: '관상 흐름으로 볼게요. 얼굴 사진을 먼저 올려주세요.',
  submitReply: '좋아요. 관상 분석 결과를 카드로 정리해드릴게요.',
  steps: [
    {
      id: 'faceImage',
      question: '정면 얼굴 사진을 올려주세요.',
      inputKind: 'image',
      imageHint: '밝은 조명, 정면, 헤어가 이마를 가리지 않는 사진이 좋습니다.',
    },
    {
      id: 'focus',
      question: '어떤 관상 분석이 궁금하세요?',
      inputKind: 'chips',
      options: [
        { id: 'overall', label: '전체 관상' },
        { id: 'career', label: '직업운' },
        { id: 'love', label: '연애운' },
        { id: 'wealth', label: '재물운' },
      ],
    },
  ],
};

const lottoSurvey: ChatSurveyDefinition = {
  fortuneType: 'lotto',
  title: '로또 운세',
  introReply: '행운의 번호 흐름으로 갈게요. 감을 먼저 맞춰볼게요.',
  submitReply: '좋아요. 행운 번호와 에너지 분석을 카드로 정리해드릴게요.',
  steps: [
    {
      id: 'luckyFeeling',
      question: '요즘 운이 좋다고 느끼시나요?',
      inputKind: 'chips',
      options: [
        { id: 'very', label: '매우 좋아요' },
        { id: 'somewhat', label: '보통이에요' },
        { id: 'not-really', label: '별로예요' },
        { id: 'bad', label: '안 좋아요' },
      ],
    },
    {
      id: 'preferredRange',
      question: '선호하는 번호 영역이 있나요?',
      inputKind: 'chips',
      options: [
        { id: 'low', label: '1~15' },
        { id: 'mid', label: '16~30' },
        { id: 'high', label: '31~45' },
        { id: 'random', label: '상관없어요' },
      ],
    },
  ],
};

const luckyItemsSurvey: ChatSurveyDefinition = {
  fortuneType: 'lucky-items',
  title: '행운 아이템',
  introReply: '오늘의 행운 아이템을 찾아볼게요. 상황을 먼저 맞춰볼게요.',
  submitReply: '좋아요. 행운 아이템과 컬러를 카드로 정리해드릴게요.',
  steps: [
    {
      id: 'situation',
      question: '오늘 어떤 상황인가요?',
      inputKind: 'chips',
      options: [
        { id: 'work', label: '업무/회의' },
        { id: 'date', label: '데이트' },
        { id: 'exam', label: '시험/면접' },
        { id: 'daily', label: '일상' },
        { id: 'travel', label: '여행' },
      ],
    },
    {
      id: 'category',
      question: '어떤 행운 아이템이 궁금하세요?',
      inputKind: 'multi-select',
      maxSelections: 2,
      options: [
        { id: 'color', label: '행운 컬러' },
        { id: 'food', label: '행운 음식' },
        { id: 'accessory', label: '행운 소품' },
        { id: 'number', label: '행운 숫자' },
        { id: 'direction', label: '행운 방위' },
      ],
    },
  ],
};

const petCompatibilitySurvey: ChatSurveyDefinition = {
  fortuneType: 'pet-compatibility',
  title: '반려동물 궁합',
  introReply: '반려동물 궁합으로 볼게요. 반려동물 정보를 먼저 맞춰볼게요.',
  submitReply: '좋아요. 반려동물 궁합 결과를 카드로 정리해드릴게요.',
  steps: [
    {
      id: 'petType',
      question: '어떤 반려동물인가요?',
      inputKind: 'chips',
      options: [
        { id: 'dog', label: '🐕 강아지' },
        { id: 'cat', label: '🐈 고양이' },
        { id: 'bird', label: '🦜 새' },
        { id: 'fish', label: '🐠 물고기' },
        { id: 'other', label: '기타' },
      ],
    },
    {
      id: 'petName',
      question: '반려동물 이름을 알려주세요.',
      inputKind: 'text',
      placeholder: '예: 뽀삐, 나비, 코코',
    },
    {
      id: 'concern',
      question: '어떤 궁합이 궁금하세요?',
      inputKind: 'chips',
      options: [
        { id: 'personality', label: '성격 궁합' },
        { id: 'health', label: '건강 궁합' },
        { id: 'bonding', label: '유대감' },
        { id: 'training', label: '훈련 궁합' },
      ],
    },
  ],
};

const movingSurvey: ChatSurveyDefinition = {
  fortuneType: 'moving',
  title: '이사 운세',
  introReply: '이사 운세로 볼게요. 계획 중인 이사 맥락을 먼저 맞춰볼게요.',
  submitReply: '좋아요. 이사 길일과 방위를 카드로 정리해드릴게요.',
  steps: [
    {
      id: 'timing',
      question: '이사 예정 시기는?',
      inputKind: 'chips',
      options: [
        { id: 'soon', label: '1개월 이내' },
        { id: 'quarter', label: '1~3개월' },
        { id: 'half', label: '3~6개월' },
        { id: 'later', label: '6개월 이후' },
        { id: 'undecided', label: '미정' },
      ],
    },
    {
      id: 'direction',
      question: '이사 방향이 정해졌나요?',
      inputKind: 'chips',
      options: [
        { id: 'east', label: '동쪽' },
        { id: 'west', label: '서쪽' },
        { id: 'south', label: '남쪽' },
        { id: 'north', label: '북쪽' },
        { id: 'undecided', label: '미정' },
      ],
    },
  ],
};

const celebritySurvey: ChatSurveyDefinition = {
  fortuneType: 'celebrity',
  title: '연예인 궁합',
  introReply: '연예인 궁합으로 볼게요. 좋아하는 연예인을 먼저 알려주세요.',
  submitReply: '좋아요. 연예인과의 궁합을 카드로 정리해드릴게요.',
  steps: [
    {
      id: 'celebrityName',
      question: '궁합을 보고 싶은 연예인 이름을 적어주세요.',
      inputKind: 'text',
      placeholder: '예: 아이유, BTS 정국',
    },
    {
      id: 'reason',
      question: '어떤 궁합이 궁금하세요?',
      inputKind: 'chips',
      options: [
        { id: 'love', label: '연애 궁합' },
        { id: 'personality', label: '성격 궁합' },
        { id: 'friendship', label: '우정 궁합' },
        { id: 'work', label: '업무 궁합' },
      ],
    },
  ],
};

const namingSurvey: ChatSurveyDefinition = {
  fortuneType: 'naming',
  title: '작명',
  introReply: '작명 흐름으로 갈게요. 용도와 선호를 먼저 맞춰볼게요.',
  submitReply: '좋아요. 추천 이름과 의미를 카드로 정리해드릴게요.',
  steps: [
    {
      id: 'purpose',
      question: '어떤 용도의 이름인가요?',
      inputKind: 'chips',
      options: [
        { id: 'baby', label: '아기 이름' },
        { id: 'pet', label: '반려동물' },
        { id: 'business', label: '사업/브랜드' },
        { id: 'nickname', label: '별명/닉네임' },
      ],
    },
    {
      id: 'preference',
      question: '선호하는 느낌이 있으세요?',
      inputKind: 'chips',
      options: [
        { id: 'traditional', label: '전통적' },
        { id: 'modern', label: '현대적' },
        { id: 'unique', label: '독특한' },
        { id: 'meaningful', label: '의미 깊은' },
      ],
    },
    {
      id: 'note',
      question: '추가로 참고할 사항이 있으면 적어주세요.',
      inputKind: 'text-with-skip',
      placeholder: '예: 성이 김이고, 한자 이름을 원해요.',
    },
  ],
};

const biorhythmSurvey: ChatSurveyDefinition = {
  fortuneType: 'biorhythm',
  title: '바이오리듬',
  introReply: '바이오리듬으로 볼게요. 생년월일만 확인하면 바로 분석해드릴게요.',
  submitReply: '좋아요. 신체/감성/지성 리듬을 카드로 정리해드릴게요.',
  steps: [
    {
      id: 'confirmBirth',
      question: '등록된 생년월일로 분석할까요?',
      inputKind: 'chips',
      options: [
        { id: 'yes', label: '네, 바로 분석해주세요' },
        { id: 'other', label: '다른 날짜로 보기' },
      ],
    },
    {
      id: 'targetDate',
      question: '분석할 날짜를 선택해주세요.',
      inputKind: 'date',
      showWhen: { confirmBirth: 'other' },
    },
  ],
};

const dailySurvey: ChatSurveyDefinition = {
  fortuneType: 'daily',
  title: '오늘의 운세',
  introReply: '오늘의 흐름으로 볼게요. 관심사만 짧게 맞춰볼게요.',
  submitReply: '좋아요. 오늘의 에너지를 카드로 정리해드릴게요.',
  steps: [
    {
      id: 'focus',
      question: '오늘 가장 궁금한 영역은?',
      inputKind: 'chips',
      options: [
        { id: 'overall', label: '전체 흐름' },
        { id: 'love', label: '연애' },
        { id: 'career', label: '일/커리어' },
        { id: 'money', label: '재물' },
        { id: 'health', label: '건강' },
      ],
    },
    {
      id: 'mood',
      question: '지금 기분은 어떤가요?',
      inputKind: 'chips',
      options: [
        { id: 'great', label: '좋아요' },
        { id: 'normal', label: '보통' },
        { id: 'down', label: '처져요' },
        { id: 'anxious', label: '불안해요' },
      ],
    },
  ],
};

const surveyDefinitions = [
  traditionalSurvey,
  dailyCalendarSurvey,
  dailySurvey,
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
  compatibilitySurvey,
  blindDateSurvey,
  exLoverSurvey,
  dreamSurvey,
  faceReadingSurvey,
  lottoSurvey,
  luckyItemsSurvey,
  petCompatibilitySurvey,
  movingSurvey,
  celebritySurvey,
  namingSurvey,
  biorhythmSurvey,
] as const satisfies readonly ChatSurveyDefinition[];

export const surveyDefinitionByFortuneType = Object.fromEntries(
  surveyDefinitions.map((definition) => [definition.fortuneType, definition]),
) as Partial<Record<FortuneTypeId, ChatSurveyDefinition>>;

export function getChatSurveyDefinition(fortuneType: FortuneTypeId) {
  return surveyDefinitionByFortuneType[fortuneType] ?? null;
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
