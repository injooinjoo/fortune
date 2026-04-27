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

const newYearSurvey: ChatSurveyDefinition = {
  fortuneType: 'new-year',
  title: '새해 인사이트',
  introReply: '신년 흐름으로 이어갈게요. 올해 가장 붙잡고 싶은 방향만 먼저 맞춰볼게요.',
  submitReply: '좋아요. 올해의 기운과 실행 포인트를 같은 채팅 안에 바로 정리해드릴게요.',
  steps: [
    {
      id: 'goal',
      question: '올해 가장 집중하고 싶은 방향은 무엇인가요?',
      inputKind: 'chips',
      options: [
        { id: 'love', label: '연애/관계' },
        { id: 'career', label: '커리어' },
        { id: 'wealth', label: '재물' },
        { id: 'health', label: '건강/회복' },
      ],
    },
  ],
};

const mbtiSurvey: ChatSurveyDefinition = {
  fortuneType: 'mbti',
  title: 'MBTI',
  introReply: 'MBTI 흐름으로 볼게요. 각 축을 하나씩 골라주세요.',
  submitReply: '좋아요. MBTI 결과를 같은 채팅 안에 카드로 정리해드릴게요.',
  steps: [
    {
      id: 'mbtiAxes',
      question: '각 성향 축을 선택해주세요. 모르는 축은 "모름"을 눌러도 괜찮아요.',
      inputKind: 'mbti-axis',
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

const compatibilitySurvey: ChatSurveyDefinition = {
  fortuneType: 'compatibility',
  title: '궁합',
  introReply: '궁합 흐름으로 들어갈게요. 상대 정보만 짧게 맞춰볼게요.',
  submitReply: '좋아요. 두 사람의 리듬과 궁합 포인트를 바로 카드로 정리해드릴게요.',
  steps: [
    {
      id: 'partnerName',
      question: '상대 이름이나 호칭을 적어주세요.',
      inputKind: 'text',
      placeholder: '예: 민지, 썸 상대, 연인',
    },
    {
      id: 'partnerBirth',
      question: '상대 생년월일을 알려주세요.',
      inputKind: 'date',
    },
    {
      id: 'relationship',
      question: '지금 관계는 어떤가요?',
      inputKind: 'chips',
      options: [
        { id: 'crush', label: '썸/호감' },
        { id: 'dating', label: '연애 중' },
        { id: 'married', label: '배우자' },
        { id: 'friend', label: '친구/지인' },
      ],
    },
  ],
};

const blindDateSurvey: ChatSurveyDefinition = {
  fortuneType: 'blind-date',
  title: '소개팅 분석',
  introReply: '소개팅 전에 준비할 게 있어요. 상대 정보를 알려주시면 더 정확해져요.',
  submitReply: '소개팅 분석을 준비하고 있어요. 오늘의 전략을 만들어드릴게요.',
  steps: [
    {
      id: 'dateType',
      question: '어떤 만남인가요?',
      inputKind: 'chips',
      options: [
        { id: 'first', label: '첫 소개팅' },
        { id: 'second', label: '두 번째 만남' },
        { id: 'app', label: '앱 매칭' },
        { id: 'setup', label: '지인 소개' },
      ],
    },
    {
      id: 'partnerInfo',
      question: '상대에 대해 아는 것을 적어주세요. (나이, 직업, 성격 등)',
      inputKind: 'text-with-skip',
      placeholder: '예: 28세, 디자이너, 조용한 편이라고 들었어요',
    },
    {
      id: 'partnerPhoto',
      question: '상대 사진이나 인스타 프로필이 있다면 올려주세요. (선택)',
      inputKind: 'image',
    },
    {
      id: 'meetingTime',
      question: '언제 만나요?',
      inputKind: 'chips',
      options: [
        { id: 'today', label: '오늘' },
        { id: 'tomorrow', label: '내일' },
        { id: 'thisWeek', label: '이번 주' },
        { id: 'notYet', label: '아직 미정' },
      ],
    },
    {
      id: 'concern',
      question: '가장 궁금하거나 걱정되는 건?',
      inputKind: 'chips',
      options: [
        { id: 'firstImpression', label: '첫인상 전략' },
        { id: 'conversation', label: '대화 주제' },
        { id: 'compatibility', label: '궁합 분석' },
        { id: 'outfit', label: '코디/패션' },
        { id: 'redFlags', label: '위험 신호 체크' },
        { id: 'afterDate', label: '만남 후 행동' },
      ],
    },
    {
      id: 'myStrength',
      question: '본인의 매력 포인트는? (최대 2개)',
      inputKind: 'multi-select',
      maxSelections: 2,
      required: false,
      options: [
        { id: 'humor', label: '유머' },
        { id: 'listening', label: '경청' },
        { id: 'looks', label: '외모' },
        { id: 'intelligence', label: '지적 매력' },
        { id: 'warmth', label: '따뜻함' },
        { id: 'confidence', label: '자신감' },
      ],
    },
  ],
};

const exLoverSurvey: ChatSurveyDefinition = {
  fortuneType: 'ex-lover',
  title: '재회 분석',
  introReply: '재회 흐름으로 볼게요. 지금 남아 있는 결만 먼저 맞춰볼게요.',
  submitReply: '좋아요. 재접점 가능성과 감정 포인트를 카드로 정리해드릴게요.',
  steps: [
    {
      id: 'primaryGoal',
      question: '가장 바라는 방향은 무엇인가요?',
      inputKind: 'chips',
      options: [
        { id: 'reunion', label: '재회' },
        { id: 'closure', label: '정리' },
        { id: 'healing', label: '회복' },
        { id: 'clarity', label: '마음 확인' },
      ],
    },
    {
      id: 'breakupTime',
      question: '헤어진 지 얼마나 됐나요?',
      inputKind: 'chips',
      options: [
        { id: 'recent', label: '1달 이내' },
        { id: 'quarter', label: '3달 안팎' },
        { id: 'half-year', label: '반년 이상' },
        { id: 'long', label: '오래됨' },
      ],
    },
    {
      id: 'relationshipDepth',
      question: '관계의 깊이는 어느 정도였나요?',
      inputKind: 'chips',
      options: [
        { id: 'light', label: '짧고 가벼웠음' },
        { id: 'steady', label: '안정적으로 만남' },
        { id: 'deep', label: '깊게 사랑했음' },
        { id: 'unfinished', label: '애매하게 끝남' },
      ],
    },
    {
      id: 'coreReason',
      question: '가장 큰 이별 이유는 무엇이었나요?',
      inputKind: 'chips',
      options: [
        { id: 'distance', label: '거리/타이밍' },
        { id: 'conflict', label: '갈등/오해' },
        { id: 'values', label: '가치관 차이' },
        { id: 'fade', label: '감정 식음' },
      ],
    },
    {
      id: 'currentState',
      question: '지금 내 상태를 골라주세요.',
      inputKind: 'multi-select',
      maxSelections: 2,
      options: [
        { id: 'still-miss', label: '아직 많이 생각남' },
        { id: 'curious', label: '상대가 궁금함' },
        { id: 'hurt', label: '마음이 남아 아픔' },
        { id: 'moving-on', label: '정리 중임' },
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

const avoidPeopleSurvey: ChatSurveyDefinition = {
  fortuneType: 'avoid-people',
  title: '피해야 할 인연',
  introReply: '관계 경계 흐름으로 볼게요. 어떤 장면에서 가장 흔들리는지 먼저 맞춰볼게요.',
  submitReply: '좋아요. 경계해야 할 신호와 대응 포인트를 바로 카드로 이어드릴게요.',
  steps: [
    {
      id: 'situation',
      question: '어떤 상황에서 특히 궁금하세요?',
      inputKind: 'chips',
      options: [
        { id: 'work', label: '직장/협업' },
        { id: 'dating', label: '연애/썸' },
        { id: 'friends', label: '친구/지인' },
        { id: 'family', label: '가족/가까운 관계' },
      ],
    },
  ],
};

const yearlyEncounterSurvey: ChatSurveyDefinition = {
  fortuneType: 'yearly-encounter',
  title: '올해의 인연운',
  introReply: '올해의 인연 흐름으로 열어볼게요. 바라는 상대 감각만 먼저 맞춰볼게요.',
  submitReply: '좋아요. 올해 만남의 분위기와 신호를 카드로 정리해드릴게요.',
  steps: [
    {
      id: 'targetGender',
      question: '어떤 상대를 상상하고 있나요?',
      inputKind: 'chips',
      options: [
        { id: 'male', label: '남성' },
        { id: 'female', label: '여성' },
        { id: 'any', label: '상관없음' },
      ],
    },
    {
      id: 'userAge',
      question: '현재 나이대는 어디에 가까우세요?',
      inputKind: 'chips',
      options: [
        { id: 'early-20s', label: '20대 초반' },
        { id: 'late-20s', label: '20대 후반' },
        { id: '30s', label: '30대' },
        { id: '40-plus', label: '40대 이상' },
      ],
    },
    {
      id: 'idealMbti',
      question: '끌리는 MBTI가 있나요?',
      inputKind: 'chips',
      options: [
        { id: 'INFP', label: 'INFP' },
        { id: 'ENFP', label: 'ENFP' },
        { id: 'INFJ', label: 'INFJ' },
        { id: 'ENTJ', label: 'ENTJ' },
        { id: 'any', label: '상관없음' },
      ],
    },
    {
      id: 'idealType',
      question: '원하는 느낌을 짧게 적어주세요.',
      inputKind: 'text-with-skip',
      required: false,
      placeholder: '예: 대화가 편하고 눈빛이 따뜻한 사람',
    },
  ],
};

const celebritySurvey: ChatSurveyDefinition = {
  fortuneType: 'celebrity',
  title: '연예인 궁합',
  introReply: '어떤 연예인이 궁금하세요? 이름과 모드를 알려주세요.',
  submitReply: '연예인과의 인연을 분석하고 있어요.',
  steps: [
    {
      id: 'celebrityName',
      question: '어떤 연예인이 궁금하세요?',
      inputKind: 'text',
      placeholder: '예: 차은우, 아이유, BTS 정국...',
    },
    {
      id: 'mode',
      question: '어떤 분석을 원하세요?',
      inputKind: 'chips',
      options: [
        { id: 'compatibility', label: '나와의 궁합' },
        { id: 'todayFortune', label: '이 연예인의 오늘 흐름' },
        { id: 'pastLife', label: '전생 인연' },
      ],
    },
    {
      id: 'reason',
      question: '이 연예인에게 끌리는 이유는?',
      inputKind: 'chips',
      required: false,
      options: [
        { id: 'looks', label: '외모' },
        { id: 'talent', label: '재능/실력' },
        { id: 'personality', label: '성격/매력' },
        { id: 'voice', label: '목소리' },
        { id: 'vibe', label: '분위기' },
        { id: 'unknown', label: '그냥 끌림' },
      ],
    },
  ],
};

const loveSurvey: ChatSurveyDefinition = {
  fortuneType: 'love',
  title: '연애운',
  introReply: '연애 에너지를 읽어볼게요. 지금 상황을 알려주세요.',
  submitReply: '연애 분석을 준비 중이에요. 오늘의 연애 흐름을 정리해드릴게요.',
  steps: [
    {
      id: 'status',
      question: '지금 연애 상태는?',
      inputKind: 'chips',
      options: [
        { id: 'single', label: '솔로' },
        { id: 'some', label: '썸 타는 중' },
        { id: 'dating', label: '연애 중' },
        { id: 'longterm', label: '장기 연애' },
        { id: 'complicated', label: '복잡한 관계' },
        { id: 'healing', label: '이별 후 힐링' },
      ],
    },
    {
      id: 'concern',
      question: '가장 궁금한 건?',
      inputKind: 'chips',
      options: [
        { id: 'meeting', label: '새로운 만남 시기' },
        { id: 'feelings', label: '상대 마음 읽기' },
        { id: 'timing', label: '고백/프로포즈 타이밍' },
        { id: 'conflict', label: '갈등 해결법' },
        { id: 'future', label: '관계의 미래' },
        { id: 'attraction', label: '매력 올리는 법' },
      ],
    },
    {
      id: 'loveLanguage',
      question: '사랑을 표현하는 방식은? (최대 2개)',
      inputKind: 'multi-select',
      maxSelections: 2,
      required: false,
      options: [
        { id: 'words', label: '말로 표현' },
        { id: 'time', label: '함께 시간 보내기' },
        { id: 'gift', label: '선물/서프라이즈' },
        { id: 'touch', label: '스킨십' },
        { id: 'service', label: '행동으로 보여주기' },
      ],
    },
  ],
};

const biorhythmSurvey: ChatSurveyDefinition = {
  fortuneType: 'biorhythm',
  title: '바이오리듬',
  introReply: '컨디션 리듬으로 볼게요. 날짜만 맞추면 바로 읽을 수 있어요.',
  submitReply: '좋아요. 몸과 감정 리듬을 카드로 정리해드릴게요.',
  steps: [
    {
      id: 'targetDate',
      question: '어느 날짜의 리듬이 궁금하세요?',
      inputKind: 'date',
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

const dreamSurvey: ChatSurveyDefinition = {
  fortuneType: 'dream',
  title: '꿈 해몽',
  introReply: '꿈 흐름으로 들어갈게요. 장면과 감정만 먼저 짧게 들려주세요.',
  submitReply: '좋아요. 꿈 상징과 현재 메시지를 카드로 정리해드릴게요.',
  steps: [
    {
      id: 'dreamContent',
      question: '기억나는 꿈 장면을 적어주세요.',
      inputKind: 'text',
      placeholder: '예: 낯선 집을 계속 헤매다가 문을 찾았어요.',
    },
    {
      id: 'emotion',
      question: '꿈속 감정은 어땠나요?',
      inputKind: 'chips',
      options: [
        { id: 'calm', label: '차분했어요' },
        { id: 'anxious', label: '불안했어요' },
        { id: 'joyful', label: '기분 좋았어요' },
        { id: 'confused', label: '혼란스러웠어요' },
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

const namingSurvey: ChatSurveyDefinition = {
  fortuneType: 'naming',
  title: '작명',
  introReply: '작명 흐름으로 볼게요. 아이 이름의 결을 정할 정보만 먼저 맞춰볼게요.',
  submitReply: '좋아요. 이름의 분위기와 추천 포인트를 카드로 바로 이어드릴게요.',
  steps: [
    {
      id: 'dueDateKnown',
      question: '예정일을 알고 계신가요?',
      inputKind: 'chips',
      options: commonYesNoOptions,
    },
    {
      id: 'dueDate',
      question: '예정일을 알려주세요.',
      inputKind: 'date',
      required: false,
      showWhen: { dueDateKnown: 'yes' },
    },
    {
      id: 'gender',
      question: '아이 성별을 알고 있나요?',
      inputKind: 'chips',
      options: [
        { id: 'boy', label: '남아' },
        { id: 'girl', label: '여아' },
        { id: 'unknown', label: '아직 몰라요' },
      ],
    },
    {
      id: 'lastName',
      question: '성을 적어주세요.',
      inputKind: 'text',
      placeholder: '예: 김, 박, 이',
    },
    {
      id: 'style',
      question: '어떤 이름 느낌을 원하세요?',
      inputKind: 'chips',
      options: [
        { id: 'modern', label: '세련되고 현대적' },
        { id: 'soft', label: '부드럽고 따뜻함' },
        { id: 'strong', label: '단단하고 또렷함' },
        { id: 'classic', label: '고전적이고 안정적' },
      ],
    },
    {
      id: 'babyDream',
      question: '떠오르는 이미지가 있으면 적어주세요.',
      inputKind: 'text-with-skip',
      required: false,
      placeholder: '예: 맑고 지적인 느낌, 단단한 첫인상',
    },
  ],
};

const luckyItemsSurvey: ChatSurveyDefinition = {
  fortuneType: 'lucky-items',
  title: '행운 아이템',
  introReply: '행운 아이템 흐름으로 볼게요. 어떤 카테고리를 원하시는지 먼저 맞춰볼게요.',
  submitReply: '좋아요. 지금 잘 맞는 컬러와 아이템 포인트를 카드로 정리해드릴게요.',
  steps: [
    {
      id: 'category',
      question: '어떤 쪽 아이템이 궁금하세요?',
      inputKind: 'chips',
      options: [
        { id: 'fashion', label: '패션/액세서리' },
        { id: 'desk', label: '책상/소지품' },
        { id: 'beauty', label: '뷰티/향' },
        { id: 'all', label: '전체 추천' },
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
    {
      id: 'faceImage',
      question: '지금 얼굴 사진 한 장만 올려주세요. 전생 초상화를 그려드릴게요.',
      inputKind: 'image',
    },
  ],
};

const talismanSurvey: ChatSurveyDefinition = {
  fortuneType: 'talisman',
  title: '부적',
  introReply: '부적 흐름으로 열어볼게요. 원하는 보호 방향만 먼저 맞춰볼게요.',
  submitReply: '좋아요. 부적의 상징과 추천 포인트를 카드로 정리해드릴게요.',
  steps: [
    {
      id: 'generationMode',
      question: '어떤 방식의 부적을 원하시나요?',
      inputKind: 'chips',
      options: [
        { id: 'simple', label: '간결하고 선명하게' },
        { id: 'traditional', label: '전통적인 분위기' },
        { id: 'warm', label: '부드럽고 따뜻하게' },
      ],
    },
    {
      id: 'purpose',
      question: '가장 필요한 보호 방향은 무엇인가요?',
      inputKind: 'chips',
      options: [
        { id: 'love', label: '연애/관계' },
        { id: 'career', label: '커리어/기회' },
        { id: 'health', label: '건강/회복' },
        { id: 'calm', label: '마음 안정' },
      ],
    },
    {
      id: 'situation',
      question: '지금 상황을 짧게 적어주세요.',
      inputKind: 'text-with-skip',
      required: false,
      placeholder: '예: 중요한 결정을 앞두고 마음이 흔들려요.',
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
      id: 'mbtiAxes',
      question: '각 성향 축을 선택해주세요. 모르는 축은 "모름"을 눌러도 괜찮아요.',
      inputKind: 'mbti-axis',
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
        { id: 'leo', label: '사자자리' },
        { id: 'virgo', label: '처녀자리' },
        { id: 'libra', label: '천칭자리' },
        { id: 'scorpio', label: '전갈자리' },
        { id: 'sagittarius', label: '궁수자리' },
        { id: 'capricorn', label: '염소자리' },
        { id: 'aquarius', label: '물병자리' },
        { id: 'pisces', label: '물고기자리' },
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
  title: '숨은 재능',
  introReply: '당신의 숨은 재능을 찾아볼게요. 몇 가지만 알려주세요.',
  submitReply: '분석 중이에요. 당신만의 재능 리포트를 만들고 있습니다.',
  steps: [
    {
      id: 'interest',
      question: '관심 있는 분야를 골라주세요. (최대 3개)',
      inputKind: 'multi-select',
      maxSelections: 3,
      options: [
        { id: 'tech', label: '기술/개발' },
        { id: 'design', label: '디자인/미술' },
        { id: 'writing', label: '글쓰기/기획' },
        { id: 'data', label: '데이터/분석' },
        { id: 'business', label: '비즈니스/경영' },
        { id: 'communication', label: '커뮤니케이션' },
        { id: 'education', label: '교육/코칭' },
        { id: 'media', label: '영상/미디어' },
        { id: 'food', label: '요리/F&B' },
        { id: 'sports', label: '스포츠/운동' },
      ],
    },
    {
      id: 'currentSkills',
      question: '자신 있는 스킬이나 경험이 있다면 적어주세요.',
      inputKind: 'text-with-skip',
      placeholder: '예: 엑셀, 영상 편집, 요리, 운동 지도...',
    },
    {
      id: 'experience',
      question: '이 분야 경험은 어느 정도인가요?',
      inputKind: 'chips',
      options: [
        { id: 'beginner', label: '입문 (경험 없음)' },
        { id: 'junior', label: '초급 (1~2년)' },
        { id: 'mid', label: '중급 (3~5년)' },
        { id: 'senior', label: '숙련 (5년+)' },
      ],
    },
    {
      id: 'goals',
      question: '어떤 목표를 이루고 싶으세요?',
      inputKind: 'chips',
      options: [
        { id: 'career-change', label: '이직/전직' },
        { id: 'side-project', label: '부업/사이드' },
        { id: 'deepen', label: '전문성 심화' },
        { id: 'startup', label: '창업' },
        { id: 'hobby-to-job', label: '취미를 직업으로' },
        { id: 'explore', label: '아직 탐색 중' },
      ],
    },
    {
      id: 'timeAvailable',
      question: '재능 개발에 투자할 수 있는 시간은?',
      inputKind: 'chips',
      options: [
        { id: 'under5', label: '주 5시간 미만' },
        { id: '5to10', label: '주 5~10시간' },
        { id: '10to20', label: '주 10~20시간' },
        { id: 'over20', label: '주 20시간 이상' },
      ],
    },
    {
      id: 'challenges',
      question: '요즘 어렵게 느끼는 부분이 있다면? (최대 2개)',
      inputKind: 'multi-select',
      maxSelections: 2,
      required: false,
      options: [
        { id: 'time', label: '시간 부족' },
        { id: 'direction', label: '방향 모르겠음' },
        { id: 'plateau', label: '실력 정체' },
        { id: 'monetize', label: '수익화 어려움' },
        { id: 'portfolio', label: '포트폴리오 없음' },
        { id: 'motivation', label: '동기 부족' },
      ],
    },
  ],
};

const exerciseSurvey: ChatSurveyDefinition = {
  fortuneType: 'exercise',
  title: '운동 인사이트',
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

const examSurvey: ChatSurveyDefinition = {
  fortuneType: 'exam',
  title: '시험운',
  introReply: '시험 흐름으로 볼게요. 시험 종류와 준비 상태만 먼저 맞춰볼게요.',
  submitReply: '좋아요. 합격 흐름과 준비 포인트를 카드로 정리해드릴게요.',
  steps: [
    {
      id: 'examType',
      question: '어떤 시험인가요?',
      inputKind: 'chips',
      options: [
        { id: 'csat', label: '수능/모의고사' },
        { id: 'language', label: '어학 시험' },
        { id: 'license', label: '자격증/실기' },
        { id: 'public', label: '공무원/임용' },
      ],
    },
    {
      id: 'examDate',
      question: '시험 날짜를 알려주세요.',
      inputKind: 'date',
    },
    {
      id: 'preparation',
      question: '현재 준비 상태는 어떤가요?',
      inputKind: 'chips',
      options: [
        { id: 'early', label: '초반 정리 단계' },
        { id: 'steady', label: '꾸준히 준비 중' },
        { id: 'final', label: '막바지 점검 중' },
        { id: 'urgent', label: '급하게 따라가는 중' },
      ],
    },
  ],
};

const faceReadingSurvey: ChatSurveyDefinition = {
  fortuneType: 'face-reading',
  title: '관상 분석',
  introReply: '관상을 봐드릴게요. 먼저 얼굴 사진을 준비해주세요.',
  submitReply: '사진을 분석하고 있어요. 잠시만 기다려주세요.',
  steps: [
    {
      id: 'gender',
      question: '성별을 선택해주세요.',
      inputKind: 'chips',
      options: [
        { id: 'male', label: '남성' },
        { id: 'female', label: '여성' },
      ],
    },
    {
      id: 'faceImage',
      question: '정면 얼굴 사진을 올려주세요. 카메라로 촬영하거나 갤러리에서 선택할 수 있어요.',
      inputKind: 'image',
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

const bloodTypeSurvey: ChatSurveyDefinition = {
  fortuneType: 'blood-type',
  title: '혈액형',
  introReply: '혈액형 분석을 볼게요.',
  submitReply: '혈액형 분석을 준비하고 있어요.',
  steps: [
    {
      id: 'bloodType',
      question: '혈액형을 선택해주세요.',
      inputKind: 'chips',
      options: [
        { id: 'A', label: 'A형' },
        { id: 'B', label: 'B형' },
        { id: 'O', label: 'O형' },
        { id: 'AB', label: 'AB형' },
      ],
    },
  ],
};

const coachingSurvey: ChatSurveyDefinition = {
  fortuneType: 'coaching',
  title: '코칭운',
  introReply: '오늘의 실행력을 분석해볼게요. 지금 상황만 간단히 알려주세요.',
  submitReply: '코칭 분석을 준비하고 있어요. 오늘의 실행 전략을 만들어드릴게요.',
  steps: [
    {
      id: 'currentGoal',
      question: '지금 가장 집중하고 싶은 건 뭐예요?',
      inputKind: 'chips',
      options: [
        { id: 'work', label: '업무/프로젝트' },
        { id: 'study', label: '공부/자격증' },
        { id: 'health', label: '운동/건강' },
        { id: 'creative', label: '창작/사이드' },
        { id: 'habit', label: '습관 만들기' },
        { id: 'decision', label: '중요한 결정' },
      ],
    },
    {
      id: 'blocker',
      question: '요즘 실행을 방해하는 게 있다면?',
      inputKind: 'chips',
      options: [
        { id: 'motivation', label: '동기 부족' },
        { id: 'overwhelm', label: '할 게 너무 많음' },
        { id: 'perfectionism', label: '완벽주의' },
        { id: 'time', label: '시간 부족' },
        { id: 'direction', label: '방향 모르겠음' },
        { id: 'energy', label: '에너지 부족' },
      ],
    },
    {
      id: 'timeAvailable',
      question: '오늘 집중할 수 있는 시간은?',
      inputKind: 'chips',
      options: [
        { id: '30min', label: '30분 이내' },
        { id: '1hr', label: '1시간' },
        { id: '2hr', label: '2~3시간' },
        { id: 'halfday', label: '반나절 이상' },
      ],
    },
  ],
};

const chatInsightSurvey: ChatSurveyDefinition = {
  fortuneType: 'chat-insight',
  title: '카톡 대화 분석',
  introReply: '카톡 대화를 분석해드릴게요. 먼저 관계와 궁금한 점을 알려주세요.',
  submitReply: '대화를 분석하고 있어요. 잠시만 기다려주세요.',
  steps: [
    {
      id: 'relationship',
      question: '이 대화 상대와의 관계는?',
      inputKind: 'chips',
      options: [
        { id: 'crush', label: '썸/관심' },
        { id: 'lover', label: '연인' },
        { id: 'ex', label: '전 연인' },
        { id: 'friend', label: '친구' },
        { id: 'colleague', label: '직장 동료' },
        { id: 'family', label: '가족' },
      ],
    },
    {
      id: 'curiosity',
      question: '가장 궁금한 포인트는?',
      inputKind: 'chips',
      options: [
        { id: 'feelings', label: '상대 감정/관심도' },
        { id: 'pattern', label: '대화 패턴 분석' },
        { id: 'advice', label: '앞으로 어떻게 할지' },
        { id: 'red-flags', label: '위험 신호 체크' },
        { id: 'compatibility', label: '관계 궁합' },
      ],
    },
    {
      id: 'chatContent',
      question: '카톡 대화를 붙여넣어주세요.\n\n💡 카카오톡 → 대화방 → ⋮ → 대화 내보내기 → 텍스트로 저장 → 내용 복사',
      inputKind: 'text',
      placeholder: '대화 내용을 여기에 붙여넣으세요... (길수록 정확해요)',
    },
  ],
};

const matchInsightSurvey: ChatSurveyDefinition = {
  fortuneType: 'match-insight',
  title: '경기 인사이트',
  introReply: '경기 분석을 도와드릴게요. 경기 정보를 알려주세요.',
  submitReply: '경기를 분석하고 있어요.',
  steps: [
    {
      id: 'sport',
      question: '어떤 스포츠인가요?',
      inputKind: 'chips',
      options: [
        { id: 'baseball', label: '야구' },
        { id: 'soccer', label: '축구' },
        { id: 'basketball', label: '농구' },
        { id: 'esports', label: 'e스포츠' },
        { id: 'volleyball', label: '배구' },
      ],
    },
    {
      id: 'teams',
      question: '어떤 경기인가요? (예: 두산 vs LG)',
      inputKind: 'text',
      placeholder: '예: 두산 vs LG, T1 vs GenG',
    },
    {
      id: 'favoriteTeam',
      question: '응원하는 팀은? (선택)',
      inputKind: 'text-with-skip',
      placeholder: '예: 두산, T1',
    },
  ],
};

const petCompatibilitySurvey: ChatSurveyDefinition = {
  fortuneType: 'pet-compatibility',
  title: '반려동물 궁합',
  introReply: '반려동물과의 궁합을 봐드릴게요. 반려동물 정보를 알려주세요.',
  submitReply: '반려동물과의 인연을 분석하고 있어요.',
  steps: [
    {
      id: 'petName',
      question: '반려동물 이름이 뭐예요?',
      inputKind: 'text',
      placeholder: '예: 콩이, 초코, 나비',
    },
    {
      id: 'petType',
      question: '어떤 동물인가요?',
      inputKind: 'chips',
      options: [
        { id: 'dog', label: '🐶 강아지' },
        { id: 'cat', label: '🐱 고양이' },
        { id: 'bird', label: '🐦 새' },
        { id: 'hamster', label: '🐹 햄스터' },
        { id: 'rabbit', label: '🐰 토끼' },
        { id: 'fish', label: '🐟 물고기' },
        { id: 'reptile', label: '🦎 파충류' },
        { id: 'other', label: '기타' },
      ],
    },
    {
      id: 'petGender',
      question: '성별은?',
      inputKind: 'chips',
      required: false,
      options: [
        { id: 'male', label: '수컷' },
        { id: 'female', label: '암컷' },
        { id: 'unknown', label: '모름' },
      ],
    },
  ],
};

const gameEnhanceSurvey: ChatSurveyDefinition = {
  fortuneType: 'game-enhance',
  title: '게임 컨디션',
  introReply: '오늘의 게임 운을 봐드릴게요.',
  submitReply: '게임 컨디션을 분석하고 있어요. 오늘의 골든타임을 찾아볼게요.',
  steps: [
    {
      id: 'gameType',
      question: '주로 어떤 게임을 하세요?',
      inputKind: 'chips',
      options: [
        { id: 'moba', label: 'MOBA (롤, 오버워치)' },
        { id: 'fps', label: 'FPS (배그, 발로란트)' },
        { id: 'rpg', label: 'RPG (메이플, 로아)' },
        { id: 'sports', label: '스포츠 (피파, NBA)' },
        { id: 'casual', label: '캐주얼/모바일' },
        { id: 'gacha', label: '가챠 (원신, 블아)' },
      ],
    },
    {
      id: 'goal',
      question: '오늘 게임 목표는?',
      inputKind: 'chips',
      options: [
        { id: 'rank', label: '랭크 상승' },
        { id: 'enhance', label: '강화/뽑기' },
        { id: 'fun', label: '그냥 재미' },
        { id: 'grind', label: '파밍/노가다' },
      ],
    },
  ],
};

const movingSurvey: ChatSurveyDefinition = {
  fortuneType: 'moving',
  title: '이사 인사이트',
  introReply: '이사 분석을 도와드릴게요. 현재 위치와 목적지를 알려주세요.',
  submitReply: '이사 인사이트를 분석하고 있어요. 방위, 손없는 날, 풍수까지 봐드릴게요.',
  steps: [
    {
      id: 'currentArea',
      question: '현재 거주 지역은 어디인가요?',
      inputKind: 'text',
      placeholder: '예: 서울 강남구, 경기 수원시',
    },
    {
      id: 'targetArea',
      question: '이사 예정 지역은 어디인가요?',
      inputKind: 'text',
      placeholder: '예: 경기 분당, 서울 마포구',
    },
    {
      id: 'movingDate',
      question: '이사 예정일이 있나요?',
      inputKind: 'date',
    },
    {
      id: 'concern',
      question: '가장 궁금한 건?',
      inputKind: 'chips',
      options: [
        { id: 'direction', label: '방위 길흉' },
        { id: 'timing', label: '손없는 날' },
        { id: 'fengshui', label: '풍수 배치' },
        { id: 'overall', label: '전체 분석' },
      ],
    },
  ],
};

const surveyDefinitions = [
  traditionalSurvey,
  dailyCalendarSurvey,
  newYearSurvey,
  mbtiSurvey,
  compatibilitySurvey,
  blindDateSurvey,
  exLoverSurvey,
  careerSurvey,
  avoidPeopleSurvey,
  yearlyEncounterSurvey,
  loveSurvey,
  celebritySurvey,
  biorhythmSurvey,
  healthSurvey,
  dreamSurvey,
  familySurvey,
  namingSurvey,
  luckyItemsSurvey,
  pastLifeSurvey,
  talismanSurvey,
  wishSurvey,
  personalityDnaSurvey,
  wealthSurvey,
  talentSurvey,
  exerciseSurvey,
  tarotSurvey,
  examSurvey,
  ootdSurvey,
  faceReadingSurvey,
  bloodTypeSurvey,
  coachingSurvey,
  chatInsightSurvey,
  matchInsightSurvey,
  movingSurvey,
  petCompatibilitySurvey,
  gameEnhanceSurvey,
] as const satisfies readonly ChatSurveyDefinition[];

export const surveyDefinitionByFortuneType = Object.fromEntries(
  surveyDefinitions.map((definition) => [definition.fortuneType, definition]),
) as Partial<Record<FortuneTypeId, ChatSurveyDefinition>>;

const surveyDefinitionAliasByFortuneType: Partial<
  Record<FortuneTypeId, FortuneTypeId>
> = {
  lotto: 'wealth',
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
  // Skip steps that already have a pre-filled answer from the user's profile.
  if (step.id in answers && answers[step.id] != null && answers[step.id] !== '') {
    return false;
  }

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

/** Profile fields that can auto-fill survey steps. */
interface SurveyProfilePrefill {
  mbti?: string;
  bloodType?: string;
}

/** Map profile fields to survey step ids. */
const PROFILE_TO_STEP: Record<keyof SurveyProfilePrefill, string> = {
  mbti: 'mbtiAxes',
  bloodType: 'bloodType',
};

export function startChatSurvey(
  definition: ChatSurveyDefinition,
  profile?: SurveyProfilePrefill,
): ActiveChatSurvey {
  const prefilled: Record<string, unknown> = {};

  if (profile) {
    for (const [field, stepId] of Object.entries(PROFILE_TO_STEP)) {
      const value = profile[field as keyof SurveyProfilePrefill];
      if (value) {
        prefilled[stepId] = value;
      }
    }
  }

  return {
    fortuneType: definition.fortuneType,
    definition,
    currentStepIndex: 0,
    answers: prefilled,
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
  if (step.inputKind === 'image') {
    return '사진을 보냈어요';
  }

  if (step.inputKind === 'mbti-axis') {
    return typeof answer === 'string' ? answer : 'MBTI 선택';
  }

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
