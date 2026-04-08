import type { FortuneTypeId } from "@fortune/product-contracts";

import type {
  ActiveChatSurvey,
  ChatSurveyDefinition,
  ChatSurveyOption,
  ChatSurveyStep,
  CompletedChatSurvey,
} from "./types";

const commonYesNoOptions = [
  { id: "yes", label: "네" },
  { id: "no", label: "아니요" },
] as const satisfies readonly ChatSurveyOption[];

const traditionalSurvey: ChatSurveyDefinition = {
  fortuneType: "traditional-saju",
  title: "전통 사주",
  introReply: "전통 사주 흐름으로 먼저 볼게요. 꼭 필요한 것만 짧게 물어볼게요.",
  submitReply: "좋아요. 사주 흐름을 정리해서 같은 대화 안에 바로 보여드릴게요.",
  steps: [
    {
      id: "analysisType",
      question: "어떤 분석이 가장 궁금하세요?",
      inputKind: "chips",
      options: [
        { id: "overall", label: "전체 흐름" },
        { id: "love", label: "연애" },
        { id: "career", label: "커리어" },
        { id: "wealth", label: "재물" },
      ],
    },
    {
      id: "specificQuestion",
      question: "특히 짚고 싶은 포인트가 있나요?",
      inputKind: "chips",
      options: [
        { id: "timing", label: "시기" },
        { id: "strength", label: "강점" },
        { id: "risk", label: "주의점" },
        { id: "custom", label: "직접 적기" },
      ],
    },
    {
      id: "customQuestion",
      question: "궁금한 점을 직접 적어주세요.",
      inputKind: "text",
      placeholder: "예: 올해 하반기 이직 타이밍이 궁금해요.",
      required: false,
      showWhen: { specificQuestion: "custom" },
    },
  ],
};

const faceReadingSurvey: ChatSurveyDefinition = {
  fortuneType: "face-reading",
  title: "관상",
  introReply:
    "관상 흐름으로 볼게요. 얼굴 사진 한 장만 보내주시면 바로 이어서 분석할게요.",
  submitReply:
    "좋아요. 인상 흐름과 관상 포인트를 같은 대화 안에서 바로 보여드릴게요.",
  steps: [
    {
      id: "photo",
      question: "얼굴이 잘 보이는 사진을 한 장 보내주세요.",
      inputKind: "photo",
      placeholder: "정면에 가깝고 얼굴 윤곽이 잘 보이는 사진이 좋아요.",
    },
  ],
};

const dailyCalendarSurvey: ChatSurveyDefinition = {
  fortuneType: "daily-calendar",
  title: "만세력",
  introReply: "만세력 흐름으로 이어갈게요. 날짜와 맥락만 먼저 맞춰볼게요.",
  submitReply: "좋아요. 날짜 흐름을 같은 채팅 안에서 바로 정리해드릴게요.",
  steps: [
    {
      id: "calendarSync",
      question: "일정을 함께 볼까요?",
      inputKind: "chips",
      options: [
        { id: "sync", label: "일정과 함께 보기" },
        { id: "date-only", label: "날짜만 보기" },
      ],
    },
    {
      id: "targetDate",
      question: "어느 날짜가 궁금하세요?",
      inputKind: "date",
    },
  ],
};

const newYearSurvey: ChatSurveyDefinition = {
  fortuneType: "new-year",
  title: "신년 운세",
  introReply:
    "신년 흐름으로 이어갈게요. 올해 가장 붙잡고 싶은 방향만 먼저 맞춰볼게요.",
  submitReply:
    "좋아요. 올해의 기운과 실행 포인트를 같은 채팅 안에 바로 정리해드릴게요.",
  steps: [
    {
      id: "goal",
      question: "올해 가장 집중하고 싶은 방향은 무엇인가요?",
      inputKind: "chips",
      options: [
        { id: "love", label: "연애/관계" },
        { id: "success", label: "성공/성취" },
        { id: "wealth", label: "재물" },
        { id: "health", label: "건강/회복" },
      ],
    },
  ],
};

const mbtiSurvey: ChatSurveyDefinition = {
  fortuneType: "mbti",
  title: "MBTI",
  introReply: "MBTI 흐름으로 볼게요. 성향 축을 바로 맞춰서 이어가겠습니다.",
  submitReply: "좋아요. MBTI 결과를 같은 채팅 안에 카드로 정리해드릴게요.",
  steps: [
    {
      id: "mbtiConfirm",
      question: "지금 저장된 MBTI가 맞나요?",
      inputKind: "chips",
      options: commonYesNoOptions,
    },
    {
      id: "mbtiType",
      question: "MBTI 유형을 선택해주세요.",
      inputKind: "chips",
      required: false,
      showWhen: { mbtiConfirm: "no" },
      options: [
        { id: "INFP", label: "INFP" },
        { id: "ENFP", label: "ENFP" },
        { id: "INFJ", label: "INFJ" },
        { id: "ENFJ", label: "ENFJ" },
        { id: "INTJ", label: "INTJ" },
        { id: "ENTJ", label: "ENTJ" },
        { id: "ISTJ", label: "ISTJ" },
        { id: "ESTJ", label: "ESTJ" },
      ],
    },
    {
      id: "category",
      question: "어떤 인사이트를 받고 싶으세요?",
      inputKind: "chips",
      options: [
        { id: "love", label: "연애" },
        { id: "career", label: "일" },
        { id: "all", label: "성장" },
        { id: "overall", label: "마음상태" },
      ],
    },
  ],
};

const compatibilitySurvey: ChatSurveyDefinition = {
  fortuneType: "compatibility",
  title: "궁합",
  introReply: "궁합 흐름으로 들어갈게요. 상대 정보만 짧게 맞춰볼게요.",
  submitReply:
    "좋아요. 두 사람의 리듬과 궁합 포인트를 바로 카드로 정리해드릴게요.",
  steps: [
    {
      id: "partnerName",
      question: "상대 이름이나 호칭을 적어주세요.",
      inputKind: "text",
      placeholder: "예: 민지, 썸 상대, 연인",
    },
    {
      id: "partnerBirth",
      question: "상대 생년월일을 알려주세요.",
      inputKind: "date",
    },
    {
      id: "relationship",
      question: "지금 관계는 어떤가요?",
      inputKind: "chips",
      options: [
        { id: "crush", label: "썸/호감" },
        { id: "dating", label: "연애 중" },
        { id: "married", label: "배우자" },
        { id: "friend", label: "친구/지인" },
      ],
    },
  ],
};

const blindDateSurvey: ChatSurveyDefinition = {
  fortuneType: "blind-date",
  title: "소개팅 운세",
  introReply: "소개팅 흐름으로 볼게요. 만남 분위기만 먼저 짧게 맞춰볼게요.",
  submitReply: "좋아요. 성공 포인트와 대화 흐름을 카드로 바로 이어드릴게요.",
  steps: [
    {
      id: "dateType",
      question: "이번 만남은 어떤 성격에 가까운가요?",
      inputKind: "chips",
      options: [
        { id: "casual", label: "가벼운 첫 만남" },
        { id: "serious", label: "진지한 소개팅" },
        { id: "group", label: "지인 동반" },
      ],
    },
    {
      id: "expectation",
      question: "가장 기대하는 건 무엇인가요?",
      inputKind: "chips",
      options: [
        { id: "chemistry", label: "대화 케미" },
        { id: "romance", label: "설렘" },
        { id: "stability", label: "진중함" },
        { id: "fun", label: "편한 분위기" },
      ],
    },
    {
      id: "meetingTime",
      question: "언제 만날 예정인가요?",
      inputKind: "chips",
      options: [
        { id: "lunch", label: "점심" },
        { id: "afternoon", label: "오후" },
        { id: "dinner", label: "저녁" },
        { id: "late", label: "늦은 시간" },
      ],
    },
    {
      id: "isFirstBlindDate",
      question: "소개팅이 처음인가요?",
      inputKind: "chips",
      options: commonYesNoOptions,
    },
  ],
};

const exLoverSurvey: ChatSurveyDefinition = {
  fortuneType: "ex-lover",
  title: "재회 운세",
  introReply: "재회 흐름으로 볼게요. 지금 남아 있는 결만 먼저 맞춰볼게요.",
  submitReply: "좋아요. 재접점 가능성과 감정 포인트를 카드로 정리해드릴게요.",
  steps: [
    {
      id: "primaryGoal",
      question: "가장 바라는 방향은 무엇인가요?",
      inputKind: "chips",
      options: [
        { id: "reunion", label: "재회" },
        { id: "closure", label: "정리" },
        { id: "healing", label: "회복" },
        { id: "clarity", label: "마음 확인" },
      ],
    },
    {
      id: "breakupTime",
      question: "헤어진 지 얼마나 됐나요?",
      inputKind: "chips",
      options: [
        { id: "recent", label: "1달 이내" },
        { id: "quarter", label: "3달 안팎" },
        { id: "half-year", label: "반년 이상" },
        { id: "long", label: "오래됨" },
      ],
    },
    {
      id: "relationshipDepth",
      question: "관계의 깊이는 어느 정도였나요?",
      inputKind: "chips",
      options: [
        { id: "light", label: "짧고 가벼웠음" },
        { id: "steady", label: "안정적으로 만남" },
        { id: "deep", label: "깊게 사랑했음" },
        { id: "unfinished", label: "애매하게 끝남" },
      ],
    },
    {
      id: "coreReason",
      question: "가장 큰 이별 이유는 무엇이었나요?",
      inputKind: "chips",
      options: [
        { id: "distance", label: "거리/타이밍" },
        { id: "conflict", label: "갈등/오해" },
        { id: "values", label: "가치관 차이" },
        { id: "fade", label: "감정 식음" },
      ],
    },
    {
      id: "currentState",
      question: "지금 내 상태를 골라주세요.",
      inputKind: "multi-select",
      maxSelections: 2,
      options: [
        { id: "still-miss", label: "아직 많이 생각남" },
        { id: "curious", label: "상대가 궁금함" },
        { id: "hurt", label: "마음이 남아 아픔" },
        { id: "moving-on", label: "정리 중임" },
      ],
    },
    {
      id: "breakupInitiator",
      question: "이별을 먼저 꺼낸 쪽은 누구였나요?",
      inputKind: "chips",
      options: [
        { id: "me", label: "내가 먼저 말했어요" },
        { id: "them", label: "상대가 먼저 말했어요" },
        { id: "mutual", label: "서로 합의했어요" },
      ],
    },
    {
      id: "contactStatus",
      question: "지금 연락 흐름은 어떤가요?",
      inputKind: "chips",
      options: [
        { id: "blocked", label: "완전히 끊겼어요" },
        { id: "no-contact", label: "연락 안 해요" },
        { id: "sometimes", label: "가끔 연락해요" },
        { id: "often", label: "자주 연락해요" },
      ],
    },
    {
      id: "detailedStory",
      question: "꼭 반영됐으면 하는 사연이 있나요?",
      inputKind: "text-with-skip",
      required: false,
      placeholder: "예: 마지막 대화가 계속 마음에 남아요.",
    },
  ],
};

const careerSurvey: ChatSurveyDefinition = {
  fortuneType: "career",
  title: "직업운",
  introReply:
    "커리어 흐름으로 바로 들어갈게요. 현재 위치를 먼저 짧게 맞춰볼게요.",
  submitReply: "좋아요. 커리어 흐름과 실행 포인트를 카드로 이어드릴게요.",
  steps: [
    {
      id: "field",
      question: "어떤 분야에서 일하고 계신가요?",
      inputKind: "chips",
      options: [
        { id: "tech", label: "IT/개발" },
        { id: "finance", label: "금융" },
        { id: "healthcare", label: "헬스케어" },
        { id: "creative", label: "크리에이티브" },
        { id: "other", label: "기타" },
      ],
    },
    {
      id: "position",
      question: "현재 포지션은 어느 쪽에 가까우세요?",
      inputKind: "chips",
      options: [
        { id: "individual", label: "실무자" },
        { id: "manager", label: "매니저" },
        { id: "lead", label: "리드" },
        { id: "student", label: "학생/취준" },
      ],
    },
    {
      id: "concern",
      question: "가장 큰 고민은 무엇인가요?",
      inputKind: "chips",
      options: [
        { id: "growth", label: "성장 정체" },
        { id: "direction", label: "방향성" },
        { id: "change", label: "이직/전환" },
        { id: "balance", label: "워라밸" },
      ],
    },
  ],
};

const avoidPeopleSurvey: ChatSurveyDefinition = {
  fortuneType: "avoid-people",
  title: "피해야 할 인연",
  introReply:
    "관계 경계 흐름으로 볼게요. 어떤 장면에서 가장 흔들리는지 먼저 맞춰볼게요.",
  submitReply:
    "좋아요. 경계해야 할 신호와 대응 포인트를 바로 카드로 이어드릴게요.",
  steps: [
    {
      id: "situation",
      question: "어떤 상황에서 특히 궁금하세요?",
      inputKind: "chips",
      options: [
        { id: "work", label: "직장/협업" },
        { id: "dating", label: "연애/썸" },
        { id: "friends", label: "친구/지인" },
        { id: "family", label: "가족/가까운 관계" },
      ],
    },
  ],
};

const yearlyEncounterSurvey: ChatSurveyDefinition = {
  fortuneType: "yearly-encounter",
  title: "올해의 인연운",
  introReply:
    "올해의 인연 흐름으로 열어볼게요. 바라는 상대 감각만 먼저 맞춰볼게요.",
  submitReply: "좋아요. 올해 만남의 분위기와 신호를 카드로 정리해드릴게요.",
  steps: [
    {
      id: "targetGender",
      question: "어떤 상대를 상상하고 있나요?",
      inputKind: "chips",
      options: [
        { id: "male", label: "남성" },
        { id: "female", label: "여성" },
      ],
    },
    {
      id: "userAge",
      question: "현재 나이대는 어디에 가까우세요?",
      inputKind: "chips",
      options: [
        { id: "early-20s", label: "20대 초반" },
        { id: "late-20s", label: "20대 후반" },
        { id: "30s", label: "30대" },
        { id: "40-plus", label: "40대 이상" },
      ],
    },
    {
      id: "idealMbti",
      question: "끌리는 MBTI가 있나요?",
      inputKind: "chips",
      options: [
        { id: "INFP", label: "INFP" },
        { id: "ENFP", label: "ENFP" },
        { id: "INFJ", label: "INFJ" },
        { id: "ENTJ", label: "ENTJ" },
        { id: "any", label: "상관없음" },
      ],
    },
    {
      id: "idealStyle",
      question: "어떤 분위기가 끌리세요?",
      inputKind: "chips",
      showWhen: { targetGender: "male" },
      options: [
        { id: "dandy", label: "댄디하고 정갈함" },
        { id: "sporty", label: "활기찬 스포티 무드" },
        { id: "casual", label: "편안한 감성" },
        { id: "street", label: "스트릿하고 힙한 느낌" },
      ],
    },
    {
      id: "idealStyle",
      question: "어떤 분위기가 끌리세요?",
      inputKind: "chips",
      showWhen: { targetGender: "female" },
      options: [
        { id: "innocent", label: "청순하고 따뜻함" },
        { id: "career", label: "시크하고 또렷함" },
        { id: "girlcrush", label: "걸크러쉬 무드" },
        { id: "pure", label: "수수하고 편안함" },
      ],
    },
    {
      id: "idealType",
      question: "원하는 느낌을 짧게 적어주세요.",
      inputKind: "text-with-skip",
      required: false,
      placeholder: "예: 대화가 편하고 눈빛이 따뜻한 사람",
    },
  ],
};

const loveSurvey: ChatSurveyDefinition = {
  fortuneType: "love",
  title: "연애운",
  introReply: "연애운 흐름으로 갈게요. 지금 관계 맥락만 먼저 맞춰볼게요.",
  submitReply:
    "좋아요. 연애 에너지와 타이밍을 같은 채팅 안에서 바로 보여드릴게요.",
  steps: [
    {
      id: "status",
      question: "지금 연애 상태가 어떤가요?",
      inputKind: "chips",
      options: [
        { id: "single", label: "솔로" },
        { id: "dating", label: "연애 중" },
        { id: "crush", label: "짝사랑" },
        { id: "complicated", label: "복잡한 관계" },
      ],
    },
    {
      id: "concern",
      question: "가장 궁금한 건 무엇인가요?",
      inputKind: "chips",
      options: [
        { id: "meeting", label: "만남/인연" },
        { id: "confession", label: "고백 타이밍" },
        { id: "relationship", label: "관계 발전" },
        { id: "future", label: "미래/결혼" },
      ],
    },
    {
      id: "datingStyle",
      question: "연애할 때 본인 스타일을 골라주세요.",
      inputKind: "multi-select",
      required: false,
      maxSelections: 2,
      options: [
        { id: "active", label: "적극적" },
        { id: "romantic", label: "로맨틱" },
        { id: "practical", label: "현실적" },
        { id: "independent", label: "개인 시간 중요" },
      ],
    },
    {
      id: "idealLooks",
      question: "이상형 분위기도 골라볼까요?",
      inputKind: "multi-select",
      required: false,
      maxSelections: 2,
      options: [
        { id: "clean", label: "정갈하고 깔끔함" },
        { id: "warm", label: "따뜻하고 부드러움" },
        { id: "confident", label: "자신감 있고 또렷함" },
        { id: "playful", label: "유쾌하고 장난기 있음" },
      ],
    },
    {
      id: "idealPersonality",
      question: "가장 끌리는 성격을 골라주세요.",
      inputKind: "multi-select",
      required: false,
      maxSelections: 2,
      options: [
        { id: "kind", label: "배려 깊음" },
        { id: "honest", label: "솔직하고 담백함" },
        { id: "stable", label: "안정감 있음" },
        { id: "ambitious", label: "성장 의지가 강함" },
      ],
    },
  ],
};

const biorhythmSurvey: ChatSurveyDefinition = {
  fortuneType: "biorhythm",
  title: "바이오리듬",
  introReply: "컨디션 리듬으로 볼게요. 날짜만 맞추면 바로 읽을 수 있어요.",
  submitReply: "좋아요. 몸과 감정 리듬을 카드로 정리해드릴게요.",
  steps: [
    {
      id: "targetDate",
      question: "어느 날짜의 리듬이 궁금하세요?",
      inputKind: "date",
    },
  ],
};

const healthSurvey: ChatSurveyDefinition = {
  fortuneType: "health",
  title: "건강운",
  introReply:
    "건강 흐름으로 먼저 볼게요. 컨디션과 생활 리듬을 짧게 맞춰보겠습니다.",
  submitReply: "좋아요. 건강 점수와 웰니스 플랜을 카드로 이어드릴게요.",
  steps: [
    {
      id: "currentCondition",
      question: "오늘 전반적인 컨디션은 어떤가요?",
      inputKind: "chips",
      options: [
        { id: "great", label: "좋아요" },
        { id: "normal", label: "보통이에요" },
        { id: "tired", label: "피곤해요" },
        { id: "drained", label: "많이 지쳤어요" },
      ],
    },
    {
      id: "concern",
      question: "특히 신경 쓰이는 부분이 있나요?",
      inputKind: "chips",
      options: [
        { id: "sleep", label: "수면" },
        { id: "stress", label: "스트레스" },
        { id: "diet", label: "식사" },
        { id: "fitness", label: "체력" },
      ],
    },
    {
      id: "stressLevel",
      question: "요즘 스트레스는 어느 정도예요?",
      inputKind: "chips",
      options: [
        { id: "low", label: "낮아요" },
        { id: "mid", label: "보통" },
        { id: "high", label: "높아요" },
      ],
    },
    {
      id: "sleepQuality",
      question: "수면 상태는 어떤가요?",
      inputKind: "chips",
      options: [
        { id: "1", label: "매우 나쁨" },
        { id: "2", label: "나쁨" },
        { id: "3", label: "보통" },
        { id: "4", label: "좋음" },
        { id: "5", label: "매우 좋음" },
      ],
    },
    {
      id: "exerciseFrequency",
      question: "운동은 얼마나 자주 하나요?",
      inputKind: "chips",
      options: [
        { id: "1", label: "거의 안 함" },
        { id: "2", label: "가끔" },
        { id: "3", label: "주 2-3회" },
        { id: "4", label: "주 4-5회" },
        { id: "5", label: "거의 매일" },
      ],
    },
    {
      id: "mealRegularity",
      question: "식사는 규칙적인 편인가요?",
      inputKind: "chips",
      options: [
        { id: "1", label: "매우 불규칙" },
        { id: "2", label: "자주 거름" },
        { id: "3", label: "보통" },
        { id: "4", label: "대체로 규칙적" },
        { id: "5", label: "매우 규칙적" },
      ],
    },
  ],
};

const dreamSurvey: ChatSurveyDefinition = {
  fortuneType: "dream",
  title: "꿈 해몽",
  introReply: "꿈 흐름으로 들어갈게요. 장면과 감정만 먼저 짧게 들려주세요.",
  submitReply: "좋아요. 꿈 상징과 현재 메시지를 카드로 정리해드릴게요.",
  steps: [
    {
      id: "dreamContent",
      question: "기억나는 꿈 장면을 적어주세요.",
      inputKind: "text",
      placeholder: "예: 낯선 집을 계속 헤매다가 문을 찾았어요.",
    },
    {
      id: "emotion",
      question: "꿈속 감정은 어땠나요?",
      inputKind: "chips",
      options: [
        { id: "calm", label: "차분했어요" },
        { id: "anxious", label: "불안했어요" },
        { id: "joyful", label: "기분 좋았어요" },
        { id: "confused", label: "혼란스러웠어요" },
      ],
    },
  ],
};

const familySurvey: ChatSurveyDefinition = {
  fortuneType: "family",
  title: "가족운",
  introReply: "가족운으로 이어갈게요. 누구에 대한 흐름인지 먼저 맞춰볼게요.",
  submitReply: "좋아요. 가족 하모니와 관계 팁을 카드로 바로 정리해드릴게요.",
  steps: [
    {
      id: "concern",
      question: "무엇이 가장 궁금한가요?",
      inputKind: "chips",
      options: [
        { id: "relationship", label: "관계/소통" },
        { id: "wealth", label: "재물/가계" },
        { id: "children", label: "자녀/양육" },
        { id: "change", label: "변화/전환" },
        { id: "health", label: "건강/회복" },
      ],
    },
    {
      id: "member",
      question: "누구를 중심으로 볼까요?",
      inputKind: "chips",
      options: [
        { id: "self", label: "나/우리 집 중심" },
        { id: "parent", label: "부모님" },
        { id: "spouse", label: "배우자/연인" },
        { id: "child", label: "자녀" },
        { id: "sibling", label: "형제자매" },
      ],
    },
    {
      id: "relationshipDetails",
      question: "특히 어떤 관계 포인트가 궁금한가요?",
      inputKind: "multi-select",
      required: false,
      maxSelections: 2,
      showWhen: { concern: "relationship" },
      options: [
        { id: "couple", label: "부부/연인 관계" },
        { id: "parent_child", label: "부모-자녀 관계" },
        { id: "siblings", label: "형제자매 관계" },
        { id: "in_laws", label: "시댁/친정 관계" },
        { id: "conflict", label: "갈등 해결" },
      ],
    },
    {
      id: "wealthDetails",
      question: "재물운에서 특히 어디가 궁금한가요?",
      inputKind: "multi-select",
      required: false,
      maxSelections: 2,
      showWhen: { concern: "wealth" },
      options: [
        { id: "income", label: "소득 증대" },
        { id: "investment", label: "재테크/투자" },
        { id: "debt", label: "빚/대출" },
        { id: "property", label: "부동산/자산" },
        { id: "business", label: "사업/창업" },
      ],
    },
    {
      id: "childrenDetails",
      question: "자녀운에서 어떤 쪽이 궁금한가요?",
      inputKind: "multi-select",
      required: false,
      maxSelections: 2,
      showWhen: { concern: "children" },
      options: [
        { id: "education", label: "학업/성적" },
        { id: "exam", label: "입시/시험" },
        { id: "career", label: "진로/적성" },
        { id: "marriage", label: "결혼/인연" },
        { id: "character", label: "성격/품성" },
      ],
    },
    {
      id: "changeDetails",
      question: "가족 변화 중 어떤 포인트가 궁금한가요?",
      inputKind: "multi-select",
      required: false,
      maxSelections: 2,
      showWhen: { concern: "change" },
      options: [
        { id: "moving", label: "이사/이주" },
        { id: "job_change", label: "직장 변화" },
        { id: "family_change", label: "가족 구성 변화" },
        { id: "lifestyle", label: "생활 방식 변화" },
        { id: "timing", label: "변화 시기" },
      ],
    },
    {
      id: "healthDetails",
      question: "건강운에서 무엇이 가장 신경 쓰이나요?",
      inputKind: "multi-select",
      required: false,
      maxSelections: 2,
      showWhen: { concern: "health" },
      options: [
        { id: "family_health", label: "가족 건강 전반" },
        { id: "elderly_health", label: "어르신 건강" },
        { id: "children_health", label: "자녀 건강" },
        { id: "pregnancy", label: "임신/출산" },
        { id: "surgery", label: "수술/치료" },
      ],
    },
    {
      id: "specialQuestion",
      question: "가족운에서 꼭 보고 싶은 상황이 있으면 적어주세요.",
      inputKind: "text-with-skip",
      required: false,
      placeholder: "예: 요즘 대화가 자꾸 어긋나는데 언제 풀릴지 궁금해요.",
    },
  ],
};

const namingSurvey: ChatSurveyDefinition = {
  fortuneType: "naming",
  title: "작명",
  introReply:
    "작명 흐름으로 볼게요. 아이 이름의 결을 정할 정보만 먼저 맞춰볼게요.",
  submitReply:
    "좋아요. 이름의 분위기와 추천 포인트를 카드로 바로 이어드릴게요.",
  steps: [
    {
      id: "dueDateKnown",
      question: "예정일을 알고 계신가요?",
      inputKind: "chips",
      options: commonYesNoOptions,
    },
    {
      id: "dueDate",
      question: "예정일을 알려주세요.",
      inputKind: "date",
      required: false,
      showWhen: { dueDateKnown: "yes" },
    },
    {
      id: "gender",
      question: "아이 성별을 알고 있나요?",
      inputKind: "chips",
      options: [
        { id: "male", label: "남아" },
        { id: "female", label: "여아" },
        { id: "unknown", label: "아직 몰라요" },
      ],
    },
    {
      id: "lastName",
      question: "성을 적어주세요.",
      inputKind: "text",
      placeholder: "예: 김, 박, 이",
    },
    {
      id: "style",
      question: "어떤 이름 느낌을 원하세요?",
      inputKind: "chips",
      options: [
        { id: "modern", label: "세련되고 현대적" },
        { id: "korean", label: "부드럽고 따뜻함" },
        { id: "traditional", label: "단단하고 또렷함" },
      ],
    },
    {
      id: "babyDream",
      question: "떠오르는 이미지가 있으면 적어주세요.",
      inputKind: "text-with-skip",
      required: false,
      placeholder: "예: 맑고 지적인 느낌, 단단한 첫인상",
    },
  ],
};

const luckyItemsSurvey: ChatSurveyDefinition = {
  fortuneType: "lucky-items",
  title: "행운 아이템",
  introReply:
    "행운 아이템 흐름으로 볼게요. 어떤 카테고리를 원하시는지 먼저 맞춰볼게요.",
  submitReply:
    "좋아요. 지금 잘 맞는 컬러와 아이템 포인트를 카드로 정리해드릴게요.",
  steps: [
    {
      id: "category",
      question: "어떤 쪽 아이템이 궁금하세요?",
      inputKind: "chips",
      options: [
        { id: "fashion", label: "패션/액세서리" },
        { id: "desk", label: "책상/소지품" },
        { id: "beauty", label: "뷰티/향" },
        { id: "all", label: "전체 추천" },
      ],
    },
  ],
};

const pastLifeSurvey: ChatSurveyDefinition = {
  fortuneType: "past-life",
  title: "전생 리딩",
  introReply: "전생 흐름으로 열어볼게요. 직감에 가까운 답으로 골라주세요.",
  submitReply: "좋아요. 상징과 메시지를 카드로 바로 풀어드릴게요.",
  steps: [
    {
      id: "curiosity",
      question: "전생에서 가장 궁금한 건 무엇인가요?",
      inputKind: "chips",
      options: [
        { id: "identity", label: "나는 어떤 사람이었나" },
        { id: "relationship", label: "누구와 얽혔나" },
        { id: "lesson", label: "남은 과제는 무엇인가" },
      ],
    },
    {
      id: "eraVibe",
      question: "끌리는 시대 감각이 있나요?",
      inputKind: "chips",
      options: [
        { id: "ancient", label: "고대" },
        { id: "medieval", label: "중세" },
        { id: "modern", label: "근대" },
        { id: "unknown", label: "잘 모르겠어요" },
      ],
    },
    {
      id: "feeling",
      question: "평소 자주 드는 감각을 골라주세요.",
      inputKind: "chips",
      options: [
        { id: "nostalgia", label: "낯익음" },
        { id: "wander", label: "어딘가로 떠나고 싶음" },
        { id: "guardian", label: "누군가를 지켜야 할 것 같음" },
        { id: "artist", label: "표현 욕구가 큼" },
      ],
    },
  ],
};

const talismanSurvey: ChatSurveyDefinition = {
  fortuneType: "talisman",
  title: "부적",
  introReply: "부적 흐름으로 열어볼게요. 원하는 보호 방향만 먼저 맞춰볼게요.",
  submitReply: "좋아요. 부적의 상징과 추천 포인트를 카드로 정리해드릴게요.",
  steps: [
    {
      id: "generationMode",
      question: "어떤 방식의 부적을 원하시나요?",
      inputKind: "chips",
      options: [
        { id: "simple", label: "간결하고 선명하게" },
        { id: "traditional", label: "전통적인 분위기" },
        { id: "warm", label: "부드럽고 따뜻하게" },
      ],
    },
    {
      id: "purpose",
      question: "가장 필요한 보호 방향은 무엇인가요?",
      inputKind: "chips",
      options: [
        { id: "love", label: "연애/관계" },
        { id: "career", label: "커리어/기회" },
        { id: "health", label: "건강/회복" },
        { id: "calm", label: "마음 안정" },
      ],
    },
    {
      id: "situation",
      question: "지금 상황을 짧게 적어주세요.",
      inputKind: "text-with-skip",
      required: false,
      placeholder: "예: 중요한 결정을 앞두고 마음이 흔들려요.",
    },
  ],
};

const wishSurvey: ChatSurveyDefinition = {
  fortuneType: "wish",
  title: "소원 리딩",
  introReply: "소원 흐름으로 갈게요. 바라는 결만 먼저 맞춰볼게요.",
  submitReply:
    "좋아요. 소원 흐름과 실행 메시지를 같은 채팅 안에 바로 담아드릴게요.",
  steps: [
    {
      id: "category",
      question: "어떤 종류의 소원인가요?",
      inputKind: "chips",
      options: [
        { id: "love", label: "연애" },
        { id: "career", label: "커리어" },
        { id: "money", label: "재물" },
        { id: "healing", label: "회복" },
      ],
    },
    {
      id: "wishContent",
      question: "소원을 적어주세요.",
      inputKind: "text",
      placeholder: "예: 올해 꼭 하고 싶은 일이 있어요.",
    },
    {
      id: "bokchae",
      question: "감사의 복채를 올리시겠어요?",
      inputKind: "chips",
      options: [
        { id: "yes", label: "올릴게요" },
        { id: "later", label: "나중에요" },
      ],
    },
  ],
};

const personalityDnaSurvey: ChatSurveyDefinition = {
  fortuneType: "personality-dna",
  title: "성격운",
  introReply: "성격 DNA 흐름으로 볼게요. 기본 성향 축만 빠르게 맞춰볼게요.",
  submitReply: "좋아요. 성향 스펙트럼과 성장 조언을 카드로 정리해드릴게요.",
  steps: [
    {
      id: "mbti",
      question: "MBTI를 선택해주세요.",
      inputKind: "chips",
      options: [
        { id: "INFP", label: "INFP" },
        { id: "ENFP", label: "ENFP" },
        { id: "INFJ", label: "INFJ" },
        { id: "INTJ", label: "INTJ" },
      ],
    },
    {
      id: "bloodType",
      question: "혈액형을 선택해주세요.",
      inputKind: "chips",
      options: [
        { id: "A", label: "A형" },
        { id: "B", label: "B형" },
        { id: "AB", label: "AB형" },
        { id: "O", label: "O형" },
      ],
    },
    {
      id: "zodiac",
      question: "별자리를 선택해주세요.",
      inputKind: "chips",
      options: [
        { id: "양자리", label: "양자리" },
        { id: "황소자리", label: "황소자리" },
        { id: "쌍둥이자리", label: "쌍둥이자리" },
        { id: "게자리", label: "게자리" },
        { id: "사자자리", label: "사자자리" },
        { id: "처녀자리", label: "처녀자리" },
        { id: "천칭자리", label: "천칭자리" },
        { id: "전갈자리", label: "전갈자리" },
        { id: "사수자리", label: "사수자리" },
        { id: "염소자리", label: "염소자리" },
        { id: "물병자리", label: "물병자리" },
        { id: "물고기자리", label: "물고기자리" },
      ],
    },
    {
      id: "zodiacAnimal",
      question: "띠를 선택해주세요.",
      inputKind: "chips",
      options: [
        { id: "쥐", label: "쥐띠" },
        { id: "소", label: "소띠" },
        { id: "호랑이", label: "호랑이띠" },
        { id: "토끼", label: "토끼띠" },
        { id: "용", label: "용띠" },
        { id: "뱀", label: "뱀띠" },
        { id: "말", label: "말띠" },
        { id: "양", label: "양띠" },
        { id: "원숭이", label: "원숭이띠" },
        { id: "닭", label: "닭띠" },
        { id: "개", label: "개띠" },
        { id: "돼지", label: "돼지띠" },
      ],
    },
  ],
};

const wealthSurvey: ChatSurveyDefinition = {
  fortuneType: "wealth",
  title: "재물운",
  introReply:
    "재물운으로 들어갈게요. 금전 흐름을 읽을 핵심 항목만 빠르게 맞춰볼게요.",
  submitReply: "좋아요. 금전 흐름과 행동 포인트를 카드로 정리해드릴게요.",
  steps: [
    {
      id: "goal",
      question: "재물 목표가 무엇인가요?",
      inputKind: "chips",
      options: [
        { id: "save", label: "저축 늘리기" },
        { id: "income", label: "수입 확대" },
        { id: "invest", label: "투자 안정화" },
        { id: "debt", label: "지출/부채 관리" },
      ],
    },
    {
      id: "concern",
      question: "가장 고민되는 부분은 무엇인가요?",
      inputKind: "chips",
      options: [
        { id: "cashflow", label: "현금흐름" },
        { id: "overspend", label: "과소비" },
        { id: "risk", label: "투자 리스크" },
        { id: "timing", label: "타이밍" },
      ],
    },
    {
      id: "income",
      question: "현재 수입 흐름은 어떤 편인가요?",
      inputKind: "chips",
      options: [
        { id: "stable", label: "안정적이에요" },
        { id: "growing", label: "늘어나는 중" },
        { id: "variable", label: "들쑥날쑥해요" },
        { id: "tight", label: "빠듯해요" },
      ],
    },
    {
      id: "expense",
      question: "지출 흐름은 어떤가요?",
      inputKind: "chips",
      options: [
        { id: "controlled", label: "잘 관리 중" },
        { id: "rising", label: "점점 늘어요" },
        { id: "impulsive", label: "충동 지출이 있어요" },
        { id: "heavy", label: "고정비가 커요" },
      ],
    },
    {
      id: "risk",
      question: "금전 선택에서는 어떤 편인가요?",
      inputKind: "chips",
      options: [
        { id: "low", label: "안전 우선" },
        { id: "balanced", label: "균형 있게" },
        { id: "high", label: "기회가 보이면 과감하게" },
      ],
    },
    {
      id: "urgency",
      question: "얼마나 빨리 변화가 필요하다고 느끼나요?",
      inputKind: "chips",
      options: [
        { id: "low", label: "천천히 준비해도 돼요" },
        { id: "mid", label: "올해 안엔 바꾸고 싶어요" },
        { id: "high", label: "지금 바로 필요해요" },
      ],
    },
    {
      id: "interests",
      question: "특히 신경 쓰는 재물 영역을 골라주세요.",
      inputKind: "multi-select",
      required: false,
      maxSelections: 3,
      options: [
        { id: "saving", label: "저축/예금" },
        { id: "stock", label: "주식" },
        { id: "crypto", label: "가상자산" },
        { id: "realestate", label: "부동산" },
        { id: "business", label: "사업/사이드잡" },
      ],
    },
  ],
};

const talentSurvey: ChatSurveyDefinition = {
  fortuneType: "talent",
  title: "재능 분석",
  introReply:
    "숨은 재능 흐름으로 볼게요. 흥미와 일하는 방식을 조금 더 정확히 맞춰볼게요.",
  submitReply: "좋아요. 강점 축과 성장 로드맵을 카드로 이어드릴게요.",
  steps: [
    {
      id: "interest",
      question: "관심 있는 분야를 골라주세요.",
      inputKind: "multi-select",
      maxSelections: 3,
      options: [
        { id: "writing", label: "글/기획" },
        { id: "design", label: "디자인" },
        { id: "analysis", label: "분석" },
        { id: "communication", label: "커뮤니케이션" },
      ],
    },
    {
      id: "workStyle",
      question: "일할 때 어떤 스타일인가요?",
      inputKind: "chips",
      options: [
        { id: "deep", label: "깊게 몰입" },
        { id: "fast", label: "빠르게 실행" },
        { id: "team", label: "함께 조율" },
        { id: "solo", label: "혼자 정리" },
      ],
    },
    {
      id: "problemSolving",
      question: "문제는 보통 어떻게 푸는 편인가요?",
      inputKind: "chips",
      options: [
        { id: "logical", label: "논리적으로 분석" },
        { id: "intuitive", label: "직감적으로 판단" },
        { id: "collaborative", label: "사람들과 같이 푼다" },
        { id: "experimental", label: "직접 부딪혀 본다" },
      ],
    },
    {
      id: "experience",
      question: "관심 분야 경험은 어느 정도인가요?",
      inputKind: "chips",
      options: [
        { id: "beginner", label: "처음 시작 단계" },
        { id: "some", label: "조금 해봤어요" },
        { id: "intermediate", label: "어느 정도 익숙해요" },
        { id: "experienced", label: "꽤 깊게 해봤어요" },
      ],
    },
    {
      id: "timeAvailable",
      question: "일주일에 얼마나 투자할 수 있나요?",
      inputKind: "chips",
      options: [
        { id: "minimal", label: "주 1-2시간" },
        { id: "moderate", label: "주 5-10시간" },
        { id: "significant", label: "주 10시간 이상" },
        { id: "fulltime", label: "거의 풀타임 가능" },
      ],
    },
    {
      id: "goal",
      question: "재능을 어디까지 키우고 싶은지 적어주세요.",
      inputKind: "text-with-skip",
      required: false,
      placeholder: "예: 실무에서 바로 쓰는 기획력을 만들고 싶어요.",
    },
    {
      id: "challenges",
      question: "요즘 어렵게 느끼는 부분을 골라주세요.",
      inputKind: "multi-select",
      required: false,
      maxSelections: 2,
      options: [
        { id: "focus", label: "집중 유지" },
        { id: "confidence", label: "확신 부족" },
        { id: "direction", label: "방향 선택" },
        { id: "consistency", label: "꾸준함" },
      ],
    },
  ],
};

const movingSurvey: ChatSurveyDefinition = {
  fortuneType: "moving",
  title: "이사운",
  introReply:
    "이사 흐름으로 볼게요. 현재 지역과 옮길 방향만 정확히 맞춰볼게요.",
  submitReply: "좋아요. 시기와 방향, 주의 포인트를 카드로 정리해드릴게요.",
  steps: [
    {
      id: "currentArea",
      question: "지금 살고 있는 지역을 적어주세요.",
      inputKind: "text",
      placeholder: "예: 서울 강남구",
    },
    {
      id: "targetArea",
      question: "어디로 옮길 예정인가요?",
      inputKind: "text",
      placeholder: "예: 경기 성남시 분당구",
    },
    {
      id: "movingPeriod",
      question: "이사 시기는 어느 쪽에 가까운가요?",
      inputKind: "chips",
      options: [
        { id: "1month", label: "1개월 이내" },
        { id: "3months", label: "3개월 이내" },
        { id: "6months", label: "6개월 이내" },
        { id: "year", label: "1년 이내" },
        { id: "undecided", label: "아직 미정" },
      ],
    },
    {
      id: "purpose",
      question: "이사 이유는 무엇인가요?",
      inputKind: "chips",
      options: [
        { id: "work", label: "직장/이직" },
        { id: "marriage", label: "결혼/동거" },
        { id: "education", label: "교육 환경" },
        { id: "better_life", label: "더 나은 생활 환경" },
        { id: "investment", label: "투자/자산" },
        { id: "family", label: "가족 사정" },
        { id: "other", label: "새로운 시작" },
      ],
    },
    {
      id: "concerns",
      question: "걱정되는 점이 있으면 골라주세요.",
      inputKind: "multi-select",
      required: false,
      maxSelections: 2,
      options: [
        { id: "direction", label: "방위가 걱정돼요" },
        { id: "timing", label: "시기가 맞을지 걱정돼요" },
        { id: "adaptation", label: "적응이 걱정돼요" },
        { id: "neighbors", label: "이웃/분위기가 걱정돼요" },
        { id: "cost", label: "비용이 부담돼요" },
      ],
    },
  ],
};

const celebritySurvey: ChatSurveyDefinition = {
  fortuneType: "celebrity",
  title: "유명인 궁합",
  introReply:
    "좋아하는 유명인과의 흐름으로 볼게요. 누구를 어떤 관점으로 볼지만 맞춰볼게요.",
  submitReply: "좋아요. 인연 포인트와 궁합 메시지를 카드로 정리해드릴게요.",
  steps: [
    {
      id: "celebrityName",
      question: "궁합을 보고 싶은 유명인 이름을 적어주세요.",
      inputKind: "text",
      placeholder: "예: 아이유, 손흥민",
    },
    {
      id: "connectionType",
      question: "어떤 관점으로 볼까요?",
      inputKind: "chips",
      options: [
        { id: "ideal_match", label: "이상형으로 보기" },
        { id: "compatibility", label: "전체 궁합 보기" },
        { id: "career_advice", label: "커리어 영감 보기" },
      ],
    },
    {
      id: "interest",
      question: "어떤 결이 가장 궁금하세요?",
      inputKind: "chips",
      options: [
        { id: "love", label: "연애/감정" },
        { id: "career", label: "커리어/성공" },
        { id: "life", label: "인생 방향" },
        { id: "friendship", label: "친구/인맥" },
      ],
    },
  ],
};

const petCompatibilitySurvey: ChatSurveyDefinition = {
  fortuneType: "pet-compatibility",
  title: "반려동물 궁합",
  introReply: "반려동물과의 궁합 흐름으로 볼게요. 아이 정보만 짧게 맞춰볼게요.",
  submitReply: "좋아요. 오늘 컨디션과 교감 포인트를 카드로 정리해드릴게요.",
  steps: [
    {
      id: "petName",
      question: "반려동물 이름을 적어주세요.",
      inputKind: "text",
      placeholder: "예: 몽이",
    },
    {
      id: "petSpecies",
      question: "어떤 반려동물인가요?",
      inputKind: "chips",
      options: [
        { id: "강아지", label: "강아지" },
        { id: "고양이", label: "고양이" },
        { id: "토끼", label: "토끼" },
        { id: "새", label: "새" },
        { id: "햄스터", label: "햄스터" },
        { id: "기타", label: "기타" },
      ],
    },
    {
      id: "petAge",
      question: "나이를 숫자로 적어주세요.",
      inputKind: "text",
      placeholder: "예: 3",
    },
    {
      id: "petGender",
      question: "성별을 알려주세요.",
      inputKind: "chips",
      required: false,
      options: [
        { id: "수컷", label: "수컷" },
        { id: "암컷", label: "암컷" },
        { id: "모름", label: "잘 모르겠어요" },
      ],
    },
    {
      id: "petPersonality",
      question: "성격은 어느 쪽에 가까운가요?",
      inputKind: "chips",
      required: false,
      options: [
        { id: "활발함", label: "활발하고 에너지가 많아요" },
        { id: "차분함", label: "차분하고 안정적이에요" },
        { id: "수줍음", label: "조심스럽고 수줍어요" },
        { id: "애교쟁이", label: "애교가 많아요" },
      ],
    },
  ],
};

const matchInsightSurvey: ChatSurveyDefinition = {
  fortuneType: "match-insight",
  title: "경기 인사이트",
  introReply:
    "경기 흐름으로 볼게요. 어떤 매치인지 짧게 맞추면 바로 읽을 수 있어요.",
  submitReply: "좋아요. 경기 분위기와 응원 포인트를 카드로 정리해드릴게요.",
  steps: [
    {
      id: "sport",
      question: "어떤 종목인가요?",
      inputKind: "chips",
      options: [
        { id: "baseball", label: "야구" },
        { id: "soccer", label: "축구" },
        { id: "basketball", label: "농구" },
        { id: "volleyball", label: "배구" },
        { id: "esports", label: "e스포츠" },
      ],
    },
    {
      id: "homeTeam",
      question: "홈팀 이름을 적어주세요.",
      inputKind: "text",
      placeholder: "예: 두산 베어스",
    },
    {
      id: "awayTeam",
      question: "원정팀 이름을 적어주세요.",
      inputKind: "text",
      placeholder: "예: LG 트윈스",
    },
    {
      id: "gameDate",
      question: "경기 날짜를 알려주세요.",
      inputKind: "date",
    },
    {
      id: "favoriteSide",
      question: "어느 쪽을 응원하시나요?",
      inputKind: "chips",
      required: false,
      options: [
        { id: "home", label: "홈팀" },
        { id: "away", label: "원정팀" },
        { id: "neutral", label: "중립" },
      ],
    },
  ],
};

const decisionSurvey: ChatSurveyDefinition = {
  fortuneType: "decision",
  title: "의사결정",
  introReply: "결정 흐름으로 볼게요. 질문과 선택지만 짧게 정리해주시면 돼요.",
  submitReply: "좋아요. 선택지별 장단점과 추천 흐름을 카드로 정리해드릴게요.",
  steps: [
    {
      id: "decisionType",
      question: "어떤 종류의 결정인가요?",
      inputKind: "chips",
      options: [
        { id: "dating", label: "연애/관계" },
        { id: "career", label: "커리어/일" },
        { id: "money", label: "돈/소비" },
        { id: "wellness", label: "건강/생활관리" },
        { id: "lifestyle", label: "일상 선택" },
        { id: "relationship", label: "대인관계" },
      ],
    },
    {
      id: "question",
      question: "지금 고민하는 질문을 적어주세요.",
      inputKind: "text",
      placeholder: "예: 이번 제안을 받아들이는 게 맞을까요?",
    },
    {
      id: "optionsText",
      question: "선택지가 있으면 쉼표로 나눠 적어주세요.",
      inputKind: "text-with-skip",
      required: false,
      placeholder: "예: 지금 한다, 한 달 더 본다, 하지 않는다",
    },
  ],
};

const exerciseSurvey: ChatSurveyDefinition = {
  fortuneType: "exercise",
  title: "운동 운세",
  introReply: "운동 흐름으로 바로 갈게요. 목적과 강도만 먼저 맞춰볼게요.",
  submitReply: "좋아요. 추천 루틴과 컨디션 포인트를 카드로 이어드릴게요.",
  steps: [
    {
      id: "goal",
      question: "운동 목적이 무엇인가요?",
      inputKind: "chips",
      options: [
        { id: "health", label: "건강 유지" },
        { id: "strength", label: "근력 향상" },
        { id: "diet", label: "체중 관리" },
        { id: "mood", label: "기분 전환" },
      ],
    },
    {
      id: "intensity",
      question: "원하는 강도는 어느 정도인가요?",
      inputKind: "chips",
      options: [
        { id: "light", label: "가볍게" },
        { id: "medium", label: "중간" },
        { id: "hard", label: "강하게" },
      ],
    },
    {
      id: "sportType",
      question: "어떤 운동이 가장 끌리나요?",
      inputKind: "chips",
      options: [
        { id: "gym", label: "헬스/웨이트" },
        { id: "running", label: "러닝" },
        { id: "yoga", label: "요가/필라테스" },
        { id: "swimming", label: "수영" },
      ],
    },
    {
      id: "weeklyFrequency",
      question: "일주일에 몇 번 정도 하고 싶으세요?",
      inputKind: "chips",
      options: [
        { id: "2", label: "주 2회 정도" },
        { id: "3", label: "주 3회 정도" },
        { id: "4", label: "주 4회 정도" },
        { id: "5", label: "주 5회 이상" },
      ],
    },
    {
      id: "preferredTime",
      question: "운동은 보통 언제가 편한가요?",
      inputKind: "chips",
      options: [
        { id: "morning", label: "아침" },
        { id: "afternoon", label: "낮" },
        { id: "evening", label: "저녁" },
        { id: "night", label: "밤" },
      ],
    },
    {
      id: "injuryHistory",
      question: "조심해야 할 부위가 있다면 골라주세요.",
      inputKind: "multi-select",
      required: false,
      maxSelections: 2,
      options: [
        { id: "none", label: "특별히 없어요" },
        { id: "knee", label: "무릎" },
        { id: "shoulder", label: "어깨" },
        { id: "back", label: "허리/등" },
      ],
    },
  ],
};

const tarotSurvey: ChatSurveyDefinition = {
  fortuneType: "tarot",
  title: "타로",
  introReply:
    "타로 흐름으로 열게요. 덱과 질문을 맞춘 뒤 마음이 가는 카드를 펼쳐봅시다.",
  submitReply: "좋아요. 펼친 카드 해석을 같은 채팅 안에 바로 정리해드릴게요.",
  steps: [
    {
      id: "deckId",
      question: "어떤 덱으로 열까요?",
      inputKind: "chips",
      options: [
        { id: "rider_waite", label: "라이더-웨이트-스미스" },
        { id: "thoth", label: "토트 타로" },
        { id: "before_tarot", label: "비포 타로" },
        { id: "after_tarot", label: "애프터 타로" },
      ],
    },
    {
      id: "purpose",
      question: "무슨 주제가 궁금하세요?",
      inputKind: "chips",
      options: [
        { id: "guidance", label: "조언/가이드" },
        { id: "love", label: "연애" },
        { id: "career", label: "커리어" },
        { id: "decision", label: "결정/선택" },
      ],
    },
    {
      id: "questionText",
      question: "조금 더 구체적인 질문이 있으면 적어주세요.",
      inputKind: "text-with-skip",
      required: false,
      placeholder: "예: 지금 밀고 있는 선택이 맞는지 궁금해요.",
    },
    {
      id: "tarotSelection",
      question: "마음이 가는 카드를 펼쳐주세요.",
      inputKind: "card-draw",
      placeholder: "카드를 한 장씩 확정하면 바로 리딩 준비로 넘어갑니다.",
    },
  ],
};

const examSurvey: ChatSurveyDefinition = {
  fortuneType: "exam",
  title: "시험운",
  introReply: "시험 흐름으로 볼게요. 시험 종류와 준비 상태만 먼저 맞춰볼게요.",
  submitReply: "좋아요. 합격 흐름과 준비 포인트를 카드로 정리해드릴게요.",
  steps: [
    {
      id: "examType",
      question: "어떤 시험인가요?",
      inputKind: "chips",
      options: [
        { id: "csat", label: "수능/모의고사" },
        { id: "language", label: "어학 시험" },
        { id: "license", label: "자격증/실기" },
        { id: "public", label: "공무원/임용" },
      ],
    },
    {
      id: "examDate",
      question: "시험 날짜를 알려주세요.",
      inputKind: "date",
    },
    {
      id: "preparation",
      question: "현재 준비 상태는 어떤가요?",
      inputKind: "chips",
      options: [
        { id: "early", label: "초반 정리 단계" },
        { id: "steady", label: "꾸준히 준비 중" },
        { id: "final", label: "막바지 점검 중" },
        { id: "urgent", label: "급하게 따라가는 중" },
      ],
    },
  ],
};

const ootdSurvey: ChatSurveyDefinition = {
  fortuneType: "ootd-evaluation",
  title: "OOTD 코디",
  introReply:
    "OOTD 흐름으로 볼게요. 오늘의 상황과 사진 한 장만 있으면 바로 읽을 수 있어요.",
  submitReply: "좋아요. 스타일 점수와 추천 아이템을 카드로 이어드릴게요.",
  steps: [
    {
      id: "tpo",
      question: "오늘 어디로 가시나요?",
      inputKind: "chips",
      options: [
        { id: "work", label: "출근/업무" },
        { id: "date", label: "데이트" },
        { id: "daily", label: "일상 외출" },
        { id: "special", label: "특별한 자리" },
      ],
    },
    {
      id: "photo",
      question: "오늘 룩 사진을 한 장 보내주세요.",
      inputKind: "photo",
      placeholder: "전신 또는 상반신이 잘 보이는 사진이면 더 정확해요.",
    },
    {
      id: "lookNote",
      question: "오늘 룩을 짧게 설명해주세요.",
      inputKind: "text-with-skip",
      required: false,
      placeholder: "예: 블랙 자켓에 데님, 실버 포인트로 입었어요.",
    },
  ],
};

const surveyDefinitions = [
  traditionalSurvey,
  faceReadingSurvey,
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
  movingSurvey,
  celebritySurvey,
  petCompatibilitySurvey,
  matchInsightSurvey,
  decisionSurvey,
  examSurvey,
  ootdSurvey,
] as const satisfies readonly ChatSurveyDefinition[];

export const surveyDefinitionByFortuneType = Object.fromEntries(
  surveyDefinitions.map((definition) => [definition.fortuneType, definition]),
) as Partial<Record<FortuneTypeId, ChatSurveyDefinition>>;

const surveyDefinitionAliasByFortuneType: Partial<
  Record<FortuneTypeId, FortuneTypeId>
> = {
  lotto: "wealth",
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
      return expected.includes(String(value ?? ""));
    }

    return String(value ?? "") === expected;
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

export function startChatSurvey(
  definition: ChatSurveyDefinition,
): ActiveChatSurvey {
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
    session.fortuneType === "mbti" &&
    current.step.id === "mbtiConfirm" &&
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

export function formatSurveyAnswerLabel(step: ChatSurveyStep, answer: unknown) {
  if (Array.isArray(answer)) {
    return answer.map((item) => formatSingleAnswerLabel(step, item)).join(", ");
  }

  return formatSingleAnswerLabel(step, answer);
}

function formatSingleAnswerLabel(step: ChatSurveyStep, answer: unknown) {
  if (step.inputKind === "photo") {
    return "사진 1장 첨부";
  }

  if (
    answer &&
    typeof answer === "object" &&
    "displayText" in answer &&
    typeof answer.displayText === "string" &&
    answer.displayText.trim().length > 0
  ) {
    return answer.displayText.trim();
  }

  if (typeof answer !== "string") {
    if (answer instanceof Date) {
      return answer.toISOString().slice(0, 10);
    }

    return String(answer ?? "");
  }

  if (step.inputKind === "date") {
    return answer;
  }

  const option = step.options?.find((candidate) => candidate.id === answer);

  if (!option) {
    return answer;
  }

  return option.emoji ? `${option.emoji} ${option.label}` : option.label;
}
