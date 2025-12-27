# 채팅 설문 설계 가이드 (Chat Survey Design Guide)

> 모든 운세 유형의 채팅 설문 설계 명세서
> 작성일: 2024-12-27
> 총 운세: 31개 + 1개 유틸리티

---

## 목차

1. [설계 원칙](#설계-원칙)
2. [입력 타입 레퍼런스](#입력-타입-레퍼런스)
3. [카테고리별 상세 설계](#카테고리별-상세-설계)
   - [시간 기반 (3개)](#1-시간-기반-3개)
   - [전통 분석 (4개)](#2-전통-분석-4개)
   - [성격/개성 (3개)](#3-성격개성-3개)
   - [연애/관계 (5개)](#4-연애관계-5개)
   - [커리어/직업 (3개)](#5-커리어직업-3개)
   - [재물 (2개)](#6-재물-2개)
   - [라이프스타일 (5개)](#7-라이프스타일-5개)
   - [건강/스포츠 (3개)](#8-건강스포츠-3개)
   - [인터랙티브 (2개)](#9-인터랙티브-2개)
   - [가족/반려동물 (3개)](#10-가족반려동물-3개)
   - [스타일/패션 (1개)](#11-스타일패션-1개)
   - [유틸리티 (1개)](#12-유틸리티-1개)
4. [구현 체크리스트](#구현-체크리스트)

---

## 설계 원칙

### 1. 대화형 UX 원칙
- 질문은 **친근한 반말체**로 작성 ("~하세요?" → "~해?", "~인가요?" → "~야?")
- 이모지를 적극 활용하여 시각적 친근감 제공
- 1개 질문당 **1개 개념**만 물어보기 (복합 질문 금지)

### 2. 설문 길이 원칙
- **최소 설문**: 0~1개 step (daily, fortuneCookie, personalityDna)
- **표준 설문**: 2~3개 step (대부분의 운세)
- **상세 설문**: 4~5개 step (career, blindDate 등 복잡한 운세)
- **최대 설문**: 6개 step 초과 금지

### 3. 필수/선택 원칙
- 핵심 정보는 `isRequired: true` (기본값)
- 개인화 선택지는 `isRequired: false`
- 조건부 표시는 `showWhen` 사용

### 4. 기존 페이지 정보 활용 원칙
- 기존 페이지에서 **중요한 입력**은 반드시 채팅에도 포함
- 단, **8개 이상 필드**는 3~4개 핵심으로 압축
- 프로필에 있는 정보(생년월일 등)는 재수집하지 않음

---

## 입력 타입 레퍼런스

| InputType | 설명 | 사용 예시 |
|-----------|------|----------|
| `chips` | 단일 선택 칩 | MBTI 유형, 연애 상태 |
| `multiSelect` | 다중 선택 칩 | 관심 분야, 투자 영역 |
| `text` | 텍스트 입력 | 이름, 인스타 아이디 |
| `calendar` | 인라인 캘린더 | 출산예정일, 경기 날짜 |
| `birthDateTime` | 생년월일+시간 롤링 피커 | 상대방 사주 정보 |
| `image` | 이미지 업로드 | OOTD 사진, 상대방 사진 |
| `voice` | 음성/텍스트 입력 | 꿈 내용, 소원 |
| `profile` | 프로필 선택 | 궁합 상대 선택 |
| `petProfile` | 펫 프로필 선택 | 반려동물 선택 |
| `tarot` | 타로 카드 선택 | 카드 뽑기 플로우 |
| `faceReading` | AI 관상 분석 | 얼굴 사진 업로드 |
| `slider` | 슬라이더 | 중요도, 점수 |
| `grid` | 그리드 선택 | 다수 항목 중 선택 |
| `date` | 날짜 다이얼로그 | 특정 날짜 선택 |

---

## 카테고리별 상세 설계

---

# 1. 시간 기반 (3개)

---

## 1.1 Daily (오늘의 운세)

**FortuneSurveyType**: `daily`
**기존 페이지**: `daily_calendar_fortune_page.dart` - 캘린더로 날짜 선택
**현재 채팅**: `steps: []` (설문 없음)

### 설계 결정
**현행 유지** - 오늘의 운세는 "오늘"이 핵심이므로 날짜 선택 불필요

### 최종 설계
```dart
const dailySurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.daily,
  title: '오늘의 운세',
  description: '오늘 하루를 미리 살펴볼까요?',
  emoji: '🌅',
  steps: [], // 바로 API 호출
);
```

### 필요 데이터
- 프로필 생년월일 (자동)
- 오늘 날짜 (자동)

---

## 1.2 Yearly (연간 운세)

**FortuneSurveyType**: `yearly`
**기존 페이지**: 없음 (신규)
**현재 채팅**: focus 1개 step

### 설계 결정
**현행 유지** - 적절한 수준

### 최종 설계
```dart
const yearlySurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.yearly,
  title: '연간 운세',
  description: '2025년 한 해 운세를 미리 살펴볼까요?',
  emoji: '📅',
  steps: [
    SurveyStep(
      id: 'focus',
      question: '특히 궁금한 영역이 있어? 🎯',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'overall', label: '종합 운세', emoji: '✨'),
        SurveyOption(id: 'career', label: '커리어/사업', emoji: '💼'),
        SurveyOption(id: 'love', label: '연애/결혼', emoji: '💕'),
        SurveyOption(id: 'money', label: '재물/투자', emoji: '💰'),
        SurveyOption(id: 'health', label: '건강/웰빙', emoji: '💪'),
        SurveyOption(id: 'study', label: '학업/자격증', emoji: '📚'),
      ],
      isRequired: false, // 선택 안하면 종합으로
    ),
  ],
);
```

---

## 1.3 NewYear (새해 운세)

**FortuneSurveyType**: `newYear`
**기존 페이지**: 없음 (신규)
**현재 채팅**: goal 1개 step

### 설계 결정
**현행 유지** - 적절한 수준

### 최종 설계
```dart
const newYearSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.newYear,
  title: '새해 운세',
  description: '새해 복 많이 받으세요! 🎊',
  emoji: '🎊',
  steps: [
    SurveyStep(
      id: 'goal',
      question: '새해 가장 큰 소망이 뭐야? ��',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'success', label: '성공/성취', emoji: '🏆'),
        SurveyOption(id: 'love', label: '사랑/만남', emoji: '💘'),
        SurveyOption(id: 'wealth', label: '부자되기', emoji: '💎'),
        SurveyOption(id: 'health', label: '건강/운동', emoji: '🏃'),
        SurveyOption(id: 'growth', label: '자기계발', emoji: '📖'),
        SurveyOption(id: 'travel', label: '여행/경험', emoji: '✈️'),
        SurveyOption(id: 'peace', label: '마음의 평화', emoji: '🧘'),
      ],
      isRequired: false,
    ),
  ],
);
```

---

# 2. 전통 분석 (4개)

---

## 2.1 Traditional Saju (전통 사주)

**FortuneSurveyType**: `traditional`
**기존 페이지**: `traditional_saju_page.dart`
- 7개 탭: 명식, 오행, 지장간, 12운성, 신살, 합충, 질문
- 질문 탭: 5개 사전 정의 질문 + 커스텀 텍스트

**현재 채팅**: analysisType 1개 step만 있음 → **대폭 보강 필요**

### 설계 결정
**보강 필요** - 기존 질문 선택 기능 추가

### 최종 설계
```dart
const traditionalSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.traditional,
  title: '전통 사주 분석',
  description: '사주팔자로 보는 당신의 운명',
  emoji: '📿',
  steps: [
    // Step 1: 분석 유형 선택
    SurveyStep(
      id: 'analysisType',
      question: '어떤 분석이 궁금해? 📜',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'comprehensive', label: '종합 분석', emoji: '📜'),
        SurveyOption(id: 'personality', label: '성격/기질', emoji: '🎭'),
        SurveyOption(id: 'destiny', label: '운명/인생 흐름', emoji: '🌊'),
        SurveyOption(id: 'luck', label: '올해 운세', emoji: '🍀'),
        SurveyOption(id: 'relationship', label: '대인관계', emoji: '🤝'),
      ],
    ),
    // Step 2: 구체적 질문 선택 (기존 페이지의 질문 기능)
    SurveyStep(
      id: 'specificQuestion',
      question: '특별히 알고 싶은 게 있어? 🤔',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'money_timing', label: '언제 돈이 들어올까?', emoji: '💰'),
        SurveyOption(id: 'career_fit', label: '어떤 일이 나한테 맞을까?', emoji: '💼'),
        SurveyOption(id: 'marriage_timing', label: '언제 결혼하면 좋을까?', emoji: '💒'),
        SurveyOption(id: 'health_caution', label: '건강 주의사항 있어?', emoji: '🏥'),
        SurveyOption(id: 'direction', label: '어느 방향으로 가면 좋아?', emoji: '🧭'),
        SurveyOption(id: 'custom', label: '직접 질문할래', emoji: '✏️'),
      ],
      isRequired: false,
    ),
    // Step 3: 커스텀 질문 (조건부)
    SurveyStep(
      id: 'customQuestion',
      question: '궁금한 걸 자유롭게 물어봐! ✨',
      inputType: SurveyInputType.text,
      showWhen: {'specificQuestion': 'custom'},
      isRequired: false,
    ),
  ],
);
```

### 변경 사항
- Step 2 추가: 기존 페이지의 5개 사전 질문 + 커스텀 옵션
- Step 3 추가: 커스텀 질문 텍스트 입력 (조건부)

---

## 2.2 Face Reading (AI 관상)

**FortuneSurveyType**: `faceReading`
**기존 페이지**: `face_reading_fortune_page.dart` - 사진 업로드
**현재 채팅**: photo 1개 step

### 설계 결정
**보강 필요** - 분석 포커스 추가

### 최종 설계
```dart
const faceReadingSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.faceReading,
  title: 'AI 관상 분석',
  description: 'AI가 당신의 얼굴을 분석해드려요',
  emoji: '🎭',
  steps: [
    // Step 1: 분석 포커스 선택
    SurveyStep(
      id: 'focus',
      question: '어떤 관상이 궁금해? 👀',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'overall', label: '종합 관상', emoji: '✨'),
        SurveyOption(id: 'personality', label: '성격/기질', emoji: '🎭'),
        SurveyOption(id: 'fortune', label: '재물/복', emoji: '💰'),
        SurveyOption(id: 'love', label: '연애/결혼운', emoji: '💕'),
        SurveyOption(id: 'career', label: '직업/적성', emoji: '💼'),
      ],
      isRequired: false, // 선택 안하면 종합
    ),
    // Step 2: 사진 업로드
    SurveyStep(
      id: 'photo',
      question: '얼굴 사진을 올려줘! 📸\n정면 사진이 가장 정확해',
      inputType: SurveyInputType.faceReading,
    ),
  ],
);
```

### 변경 사항
- Step 1 추가: 분석 포커스 선택

---

## 2.3 Talisman (부적)

**FortuneSurveyType**: `talisman` → **신규 추가 필요**
**기존 페이지**: `talisman_fortune_page.dart`
**현재 채팅**: 없음 (FortuneSurveyType에 없음)

### 설계 결정
**신규 구현** - enum 추가 및 설문 설정 추가

### 최종 설계
```dart
// fortune_survey_config.dart에 enum 추가
enum FortuneSurveyType {
  // ... 기존 항목
  talisman, // 부적 (추가)
}

// survey_configs.dart에 설정 추가
const talismanSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.talisman,
  title: '부적',
  description: '당신을 위한 맞춤 부적',
  emoji: '🧧',
  steps: [
    // Step 1: 부적 목적
    SurveyStep(
      id: 'purpose',
      question: '어떤 부적이 필요해? 🧧',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'wealth', label: '재물/금전운', emoji: '💰'),
        SurveyOption(id: 'love', label: '연애/결혼운', emoji: '💕'),
        SurveyOption(id: 'health', label: '건강/장수', emoji: '💪'),
        SurveyOption(id: 'success', label: '성공/합격', emoji: '🏆'),
        SurveyOption(id: 'protection', label: '액막이/보호', emoji: '🛡️'),
        SurveyOption(id: 'family', label: '가정화목', emoji: '👨‍👩‍👧‍👦'),
      ],
    ),
    // Step 2: 특별한 상황
    SurveyStep(
      id: 'situation',
      question: '특별한 상황이 있어? 🤔',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'exam', label: '시험/면접 앞두고', emoji: '📝'),
        SurveyOption(id: 'business', label: '사업/창업 중', emoji: '💼'),
        SurveyOption(id: 'moving', label: '이사/이직 예정', emoji: '🏠'),
        SurveyOption(id: 'relationship', label: '관계 문제', emoji: '💔'),
        SurveyOption(id: 'none', label: '딱히 없어', emoji: '✨'),
      ],
      isRequired: false,
    ),
  ],
);

// surveyConfigs 맵에 추가
FortuneSurveyType.talisman: talismanSurveyConfig,
```

---

## 2.4 Tarot (타로)

**FortuneSurveyType**: `tarot`
**기존 페이지**:
- `tarot_deck_selection_page.dart` - 덱 선택
- `tarot_page.dart` - 카드 뽑기
**현재 채팅**: purpose + tarotSelection 2개 step (덱은 라이더-웨이트 고정)

### 설계 결정
**현행 유지** - 덱 고정은 의도적 간소화

### 최종 설계
```dart
const tarotSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.tarot,
  title: '타로',
  description: '카드가 전하는 메시지를 들어볼까요?',
  emoji: '🃏',
  steps: [
    // Step 1: 타로 목적
    SurveyStep(
      id: 'purpose',
      question: '어떤 주제로 타로 볼까? 🃏',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'general', label: '전체 운세', emoji: '✨'),
        SurveyOption(id: 'love', label: '연애/관계', emoji: '💕'),
        SurveyOption(id: 'career', label: '일/커리어', emoji: '💼'),
        SurveyOption(id: 'decision', label: '결정/선택', emoji: '🤔'),
        SurveyOption(id: 'guidance', label: '조언/가이드', emoji: '🧭'),
      ],
    ),
    // Step 2: 카드 뽑기
    SurveyStep(
      id: 'tarotSelection',
      question: '마음을 집중하고 카드를 뽑아봐! ✨',
      inputType: SurveyInputType.tarot,
    ),
  ],
);
```

---

# 3. 성격/개성 (3개)

---

## 3.1 Personality DNA (성격 DNA)

**FortuneSurveyType**: `personalityDna`
**기존 페이지**: `personality_dna_page.dart` - 추가 입력 없음
**현재 채팅**: `steps: []`

### 설계 결정
**현행 유지** - 생년월일 기반 분석이므로 추가 입력 불필요

### 최종 설계
```dart
const personalityDnaSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.personalityDna,
  title: '성격 DNA',
  description: '사주로 보는 당신만의 성격 DNA',
  emoji: '🧬',
  steps: [], // 추가 수집 없음 (생년월일 기반)
);
```

---

## 3.2 MBTI

**FortuneSurveyType**: `mbti`
**기존 페이지**: `mbti_fortune_page.dart` - MBTI 16개 타입 그리드 선택
**현재 채팅**: mbtiType 1개 step (16개 chips)

### 설계 결정
**현행 유지** - 완전 일치

### 최종 설계
```dart
const mbtiSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.mbti,
  title: 'MBTI 운세',
  description: 'MBTI로 보는 오늘의 운세',
  emoji: '🧠',
  steps: [
    SurveyStep(
      id: 'mbtiType',
      question: 'MBTI가 뭐야? 🧠',
      inputType: SurveyInputType.chips,
      options: [
        // Analysts
        SurveyOption(id: 'INTJ', label: 'INTJ'),
        SurveyOption(id: 'INTP', label: 'INTP'),
        SurveyOption(id: 'ENTJ', label: 'ENTJ'),
        SurveyOption(id: 'ENTP', label: 'ENTP'),
        // Diplomats
        SurveyOption(id: 'INFJ', label: 'INFJ'),
        SurveyOption(id: 'INFP', label: 'INFP'),
        SurveyOption(id: 'ENFJ', label: 'ENFJ'),
        SurveyOption(id: 'ENFP', label: 'ENFP'),
        // Sentinels
        SurveyOption(id: 'ISTJ', label: 'ISTJ'),
        SurveyOption(id: 'ISFJ', label: 'ISFJ'),
        SurveyOption(id: 'ESTJ', label: 'ESTJ'),
        SurveyOption(id: 'ESFJ', label: 'ESFJ'),
        // Explorers
        SurveyOption(id: 'ISTP', label: 'ISTP'),
        SurveyOption(id: 'ISFP', label: 'ISFP'),
        SurveyOption(id: 'ESTP', label: 'ESTP'),
        SurveyOption(id: 'ESFP', label: 'ESFP'),
      ],
    ),
  ],
);
```

---

## 3.3 Biorhythm (바이오리듬)

**FortuneSurveyType**: `biorhythm`
**기존 페이지**: `biorhythm_input_page.dart` - 날짜 선택
**현재 채팅**: targetDate 1개 step (calendar, 선택적)

### 설계 결정
**현행 유지** - 완전 일치

### 최종 설계
```dart
const biorhythmSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.biorhythm,
  title: '바이오리듬',
  description: '오늘의 신체/감성/지성 리듬',
  emoji: '📊',
  steps: [
    SurveyStep(
      id: 'targetDate',
      question: '언제 바이오리듬이 궁금해? 📅\n(선택 안하면 오늘!)',
      inputType: SurveyInputType.calendar,
      isRequired: false, // 기본값: 오늘
    ),
  ],
);
```

---

# 4. 연애/관계 (5개)

---

## 4.1 Love (연애운)

**FortuneSurveyType**: `love`
**기존 페이지**: `love_fortune_input_page.dart`
- 8개 아코디언 섹션, 약 20개 입력 필드
- Step 1: 나이, 성별, 연애상태
- Step 2: 연애 스타일 (다중)
- Step 3: 이상형 조건별 중요도 (5개 슬라이더)
- Step 4: 이상형 나이대
- Step 5: 이상형의 성격 (4개 선택)
- Step 6: 만남 방식, 연애 목표
- Step 7: 나의 매력 포인트, 라이프스타일
- Step 8: 자신감, 취미

**현재 채팅**: status + concern 2개 step만 → **90% 간소화 상태**

### 설계 결정
**보강 필요** - 핵심 정보 4개 step으로 압축

### 최종 설계
```dart
final loveSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.love,
  title: '연애 운세',
  description: '당신의 사랑 운을 알려드릴게요',
  emoji: '💕',
  steps: [
    // Step 1: 연애 상태
    SurveyStep(
      id: 'status',
      question: '지금 연애 상태가 어때? 💕',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'single', label: '솔로', emoji: '💔'),
        SurveyOption(id: 'dating', label: '연애 중', emoji: '💕'),
        SurveyOption(id: 'crush', label: '짝사랑', emoji: '💘'),
        SurveyOption(id: 'complicated', label: '복잡한 관계', emoji: '💫'),
      ],
    ),
    // Step 2: 핵심 고민
    SurveyStep(
      id: 'concern',
      question: '가장 궁금한 게 뭐야? 🤔',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'meeting', label: '만남/인연', emoji: '🤝'),
        SurveyOption(id: 'confession', label: '고백 타이밍', emoji: '💌'),
        SurveyOption(id: 'relationship', label: '관계 발전', emoji: '💞'),
        SurveyOption(id: 'conflict', label: '갈등 해결', emoji: '🌧️'),
        SurveyOption(id: 'future', label: '미래/결혼', emoji: '💒'),
        SurveyOption(id: 'breakup', label: '이별/재회', emoji: '🍂'),
      ],
    ),
    // Step 3: 연애 스타일 (기존 Step 2에서 가져옴)
    SurveyStep(
      id: 'datingStyle',
      question: '연애할 때 어떤 스타일이야? 💝',
      inputType: SurveyInputType.multiSelect,
      options: [
        SurveyOption(id: 'active', label: '적극적', emoji: '🔥'),
        SurveyOption(id: 'passive', label: '수동적', emoji: '🌙'),
        SurveyOption(id: 'romantic', label: '로맨틱', emoji: '🌹'),
        SurveyOption(id: 'practical', label: '현실적', emoji: '💼'),
        SurveyOption(id: 'clingy', label: '애정 표현 많이', emoji: '🤗'),
        SurveyOption(id: 'independent', label: '개인 시간 중요', emoji: '🧘'),
      ],
      isRequired: false,
    ),
    // Step 4: 이상형 (솔로/짝사랑일 때만)
    SurveyStep(
      id: 'idealType',
      question: '이상형은 어떤 스타일이야? ✨',
      inputType: SurveyInputType.multiSelect,
      options: [
        SurveyOption(id: 'kind', label: '따뜻한', emoji: '🥰'),
        SurveyOption(id: 'funny', label: '유머러스', emoji: '😄'),
        SurveyOption(id: 'smart', label: '똑똒한', emoji: '🧠'),
        SurveyOption(id: 'stable', label: '안정적인', emoji: '🏠'),
        SurveyOption(id: 'passionate', label: '열정적인', emoji: '🔥'),
        SurveyOption(id: 'calm', label: '차분한', emoji: '🌊'),
      ],
      showWhen: {'status': ['single', 'crush']}, // 솔로/짝사랑일 때만
      isRequired: false,
    ),
  ],
);
```

### 변경 사항
- Step 3 추가: 연애 스타일 (다중 선택, 선택적)
- Step 4 추가: 이상형 스타일 (조건부, 솔로/짝사랑일 때만)
- 기존 20개 필드 → 4개 step으로 핵심 정보만 압축

---

## 4.2 Compatibility (궁합)

**FortuneSurveyType**: `compatibility`
**기존 페이지**: `compatibility_page.dart`
- Person1 이름 + 생년월일
- Person2 이름 + 생년월일
**현재 채팅**: partner 1개 step (profile 선택)

### 설계 결정
**보강 필요** - 프로필 없을 때 직접 입력 옵션 추가

### 최종 설계
```dart
const compatibilitySurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.compatibility,
  title: '궁합',
  description: '누구와의 궁합이 궁금하세요?',
  emoji: '💞',
  steps: [
    // Step 1: 상대방 선택 방식
    SurveyStep(
      id: 'inputMethod',
      question: '상대방 정보를 어떻게 입력할래? 💞',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'profile', label: '저장된 프로필에서', emoji: '📋'),
        SurveyOption(id: 'new', label: '새로 입력할래', emoji: '✏️'),
      ],
    ),
    // Step 2a: 프로필 선택 (프로필 선택 시)
    SurveyStep(
      id: 'partner',
      question: '궁합 볼 상대를 선택해줘! 💕',
      inputType: SurveyInputType.profile,
      showWhen: {'inputMethod': 'profile'},
    ),
    // Step 2b: 이름 입력 (새로 입력 시)
    SurveyStep(
      id: 'partnerName',
      question: '상대방 이름이 뭐야? ✨',
      inputType: SurveyInputType.text,
      showWhen: {'inputMethod': 'new'},
    ),
    // Step 3: 생년월일 입력 (새로 입력 시)
    SurveyStep(
      id: 'partnerBirth',
      question: '상대방 생년월일을 알려줘! 📅',
      inputType: SurveyInputType.birthDateTime,
      showWhen: {'inputMethod': 'new'},
    ),
    // Step 4: 관계
    SurveyStep(
      id: 'relationship',
      question: '어떤 관계야? 🤔',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'lover', label: '애인/배우자', emoji: '💕'),
        SurveyOption(id: 'crush', label: '짝사랑/썸', emoji: '💘'),
        SurveyOption(id: 'friend', label: '친구', emoji: '👥'),
        SurveyOption(id: 'colleague', label: '동료/지인', emoji: '💼'),
        SurveyOption(id: 'family', label: '가족', emoji: '👨‍👩‍👧‍👦'),
      ],
    ),
  ],
);
```

### 변경 사항
- Step 1 추가: 입력 방식 선택 (프로필 vs 새로 입력)
- Step 2b, 3 추가: 새로 입력 시 이름 + 생년월일 (조건부)
- Step 4 추가: 관계 유형 선택

---

## 4.3 Avoid People (경계 대상)

**FortuneSurveyType**: `avoidPeople`
**기존 페이지**: `avoid_people_fortune_page.dart`
**현재 채팅**: situation 1개 step

### 설계 결정
**현행 유지** - 적절한 수준

### 최종 설계
```dart
const avoidPeopleSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.avoidPeople,
  title: '경계 대상',
  description: '조심해야 할 인연을 알려드려요',
  emoji: '⚠️',
  steps: [
    SurveyStep(
      id: 'situation',
      question: '어떤 상황에서 주의가 필요해? ⚠️',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'work', label: '직장/비즈니스', emoji: '💼'),
        SurveyOption(id: 'love', label: '연애/소개팅', emoji: '💕'),
        SurveyOption(id: 'friend', label: '친구/지인', emoji: '👥'),
        SurveyOption(id: 'family', label: '가족/친척', emoji: '👨‍👩‍👧‍👦'),
        SurveyOption(id: 'money', label: '금전 거래', emoji: '💰'),
      ],
    ),
  ],
);
```

---

## 4.4 Ex Lover (재회 운세)

**FortuneSurveyType**: `exLover`
**기존 페이지**: `ex_lover_fortune_simple_page.dart`
**현재 채팅**: breakupTime + breakupReason 2개 step

### 설계 결정
**보강 필요** - 현재 마음 상태 추가

### 최종 설계
```dart
const exLoverSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.exLover,
  title: '재회 운세',
  description: '재회 가능성을 살펴볼게요',
  emoji: '🔄',
  steps: [
    // Step 1: 이별 시기
    SurveyStep(
      id: 'breakupTime',
      question: '언제 헤어졌어? 💔',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'recent', label: '최근 (1개월 이내)', emoji: '💔'),
        SurveyOption(id: 'months', label: '몇 달 전', emoji: '📅'),
        SurveyOption(id: 'year', label: '1년 전후', emoji: '🗓️'),
        SurveyOption(id: 'years', label: '몇 년 전', emoji: '⏳'),
      ],
    ),
    // Step 2: 이별 사유
    SurveyStep(
      id: 'breakupReason',
      question: '헤어진 이유가 뭐였어? 🤔',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'natural', label: '자연스러운 이별', emoji: '🍂'),
        SurveyOption(id: 'conflict', label: '갈등/싸움', emoji: '💢'),
        SurveyOption(id: 'distance', label: '거리/시간', emoji: '🌍'),
        SurveyOption(id: 'other', label: '다른 사람', emoji: '💔'),
        SurveyOption(id: 'family', label: '가족 반대', emoji: '👨‍👩‍👧'),
        SurveyOption(id: 'unknown', label: '잘 모르겠어', emoji: '❓'),
      ],
    ),
    // Step 3: 현재 마음 상태 (추가)
    SurveyStep(
      id: 'currentFeeling',
      question: '지금 마음은 어때? 💭',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'miss', label: '많이 그리워', emoji: '😢'),
        SurveyOption(id: 'curious', label: '궁금해', emoji: '🤔'),
        SurveyOption(id: 'regret', label: '후회돼', emoji: '😔'),
        SurveyOption(id: 'conflicted', label: '복잡해', emoji: '🌀'),
        SurveyOption(id: 'hopeful', label: '다시 만나고 싶어', emoji: '🙏'),
      ],
    ),
  ],
);
```

### 변경 사항
- Step 3 추가: 현재 마음 상태

---

## 4.5 Blind Date (소개팅)

**FortuneSurveyType**: `blindDate`
**기존 페이지**: `blind_date_fortune_page.dart`
**현재 채팅**: 5개 기본 step + 2개 조건부 step

### 설계 결정
**현행 유지** - 이미 상세하게 구현됨

### 최종 설계
```dart
final blindDateSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.blindDate,
  title: '소개팅 운세',
  description: '소개팅 운세를 봐드릴게요!',
  emoji: '💘',
  steps: [
    // Step 1: 소개팅 유형
    SurveyStep(
      id: 'dateType',
      question: '어떤 방식으로 만나? 💘',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'app', label: '앱/온라인', emoji: '📱'),
        SurveyOption(id: 'friend', label: '지인 소개', emoji: '👥'),
        SurveyOption(id: 'work', label: '직장/학교', emoji: '🏢'),
        SurveyOption(id: 'group', label: '미팅/그룹', emoji: '🎉'),
      ],
    ),
    // Step 2: 기대
    SurveyStep(
      id: 'expectation',
      question: '어떤 만남을 원해? 💭',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'serious', label: '진지한 만남', emoji: '💍'),
        SurveyOption(id: 'casual', label: '가볍게 시작', emoji: '☕'),
        SurveyOption(id: 'friend', label: '친구로 시작', emoji: '🤝'),
        SurveyOption(id: 'explore', label: '모르겠어', emoji: '🤔'),
      ],
    ),
    // Step 3: 만남 시간대
    SurveyStep(
      id: 'meetingTime',
      question: '만남 시간대가 어때? ⏰',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'lunch', label: '점심', emoji: '☀️'),
        SurveyOption(id: 'afternoon', label: '오후', emoji: '🌤️'),
        SurveyOption(id: 'dinner', label: '저녁', emoji: '🌙'),
        SurveyOption(id: 'night', label: '밤', emoji: '🌃'),
      ],
    ),
    // Step 4: 첫 소개팅 여부
    SurveyStep(
      id: 'isFirstBlindDate',
      question: '첫 소개팅이야? 🌟',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'yes', label: '네, 처음이에요', emoji: '🌟'),
        SurveyOption(id: 'no', label: '경험 있어요', emoji: '✨'),
      ],
    ),
    // Step 5: 상대방 정보 유무
    SurveyStep(
      id: 'hasPartnerInfo',
      question: '상대방 정보가 있어? 🔍',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'photo', label: '사진 있어', emoji: '📷'),
        SurveyOption(id: 'instagram', label: '인스타 알아', emoji: '📱'),
        SurveyOption(id: 'none', label: '정보 없어', emoji: '❓'),
      ],
    ),
    // Step 6: 상대방 사진 (조건부)
    SurveyStep(
      id: 'partnerPhoto',
      question: '상대방 사진을 올려줘! 📷',
      inputType: SurveyInputType.image,
      showWhen: {'hasPartnerInfo': 'photo'},
      isRequired: false,
    ),
    // Step 7: 인스타 아이디 (조건부)
    SurveyStep(
      id: 'partnerInstagram',
      question: '상대방 인스타 아이디를 알려줘! 📱',
      inputType: SurveyInputType.text,
      showWhen: {'hasPartnerInfo': 'instagram'},
      isRequired: false,
    ),
  ],
);
```

---

# 5. 커리어/직업 (3개)

---

## 5.1 Career (커리어)

**FortuneSurveyType**: `career`
**기존 페이지**: `career_coaching_input_page.dart`
**현재 채팅**: field + position + experience + concern 4개 step

### 설계 결정
**현행 유지** - 완전 일치, 잘 구현됨

### 최종 설계
```dart
final careerSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.career,
  title: '커리어 운세',
  description: '당신의 커리어 방향을 알려드릴게요',
  emoji: '💼',
  steps: [
    // Step 1: 분야
    SurveyStep(
      id: 'field',
      question: '어떤 분야에서 일해? 💼',
      inputType: SurveyInputType.chips,
      options: [
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
      ],
    ),
    // Step 2: 포지션 (분야별 동적)
    SurveyStep(
      id: 'position',
      question: '포지션이 어떻게 돼? 🎯',
      inputType: SurveyInputType.chips,
      dependsOn: 'field', // 분야에 따라 동적 옵션
      options: [], // 동적으로 로드
    ),
    // Step 3: 경력
    SurveyStep(
      id: 'experience',
      question: '경력은 어느 정도야? 📈',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'student', label: '학생/취준생', emoji: '🎓'),
        SurveyOption(id: 'junior', label: '신입 (0-2년)', emoji: '🌱'),
        SurveyOption(id: 'mid', label: '주니어 (3-5년)', emoji: '🌿'),
        SurveyOption(id: 'senior', label: '시니어 (6-10년)', emoji: '🌳'),
        SurveyOption(id: 'lead', label: '리드급 (10년+)', emoji: '🌲'),
        SurveyOption(id: 'executive', label: '임원급', emoji: '👔'),
      ],
    ),
    // Step 4: 핵심 고민
    SurveyStep(
      id: 'concern',
      question: '요즘 가장 큰 고민이 뭐야? 🤔',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'growth', label: '성장 정체', emoji: '📈'),
        SurveyOption(id: 'direction', label: '방향성 고민', emoji: '🧭'),
        SurveyOption(id: 'change', label: '이직/전직', emoji: '🔄'),
        SurveyOption(id: 'balance', label: '워라밸', emoji: '⚖️'),
        SurveyOption(id: 'salary', label: '연봉/처우', emoji: '💵'),
        SurveyOption(id: 'relationship', label: '직장 내 관계', emoji: '👥'),
      ],
    ),
  ],
);
```

---

## 5.2 Talent (적성)

**FortuneSurveyType**: `talent`
**기존 페이지**: `talent_fortune_input_page.dart`
**현재 채팅**: interest + workStyle + problemSolving 3개 step

### 설계 결정
**현행 유지** - 완전 일치

### 최종 설계
```dart
final talentSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.talent,
  title: '적성 찾기',
  description: '숨겨진 재능을 발견해볼까요?',
  emoji: '🌟',
  steps: [
    // Step 1: 관심 분야 (다중)
    SurveyStep(
      id: 'interest',
      question: '어떤 분야에 관심 있어? 🎯 (여러 개 선택 가능)',
      inputType: SurveyInputType.multiSelect,
      options: [
        SurveyOption(id: 'creative', label: '예술/창작', emoji: '🎨'),
        SurveyOption(id: 'business', label: '비즈니스/경영', emoji: '📊'),
        SurveyOption(id: 'tech', label: 'IT/기술', emoji: '💻'),
        SurveyOption(id: 'people', label: '사람/소통', emoji: '🗣️'),
        SurveyOption(id: 'science', label: '과학/연구', emoji: '🔬'),
        SurveyOption(id: 'service', label: '서비스/봉사', emoji: '🤲'),
      ],
    ),
    // Step 2: 일하는 스타일
    SurveyStep(
      id: 'workStyle',
      question: '일할 때 어떤 스타일이야? 💪',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'solo', label: '혼자 집중해서'),
        SurveyOption(id: 'team', label: '팀과 협업하며'),
      ],
    ),
    // Step 3: 문제 해결 방식
    SurveyStep(
      id: 'problemSolving',
      question: '문제를 어떻게 해결해? 🧠',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'logical', label: '논리적으로 분석'),
        SurveyOption(id: 'intuitive', label: '직관적으로 판단'),
      ],
    ),
  ],
);
```

---

## 5.3 Exam (시험 운세)

**FortuneSurveyType**: `exam` → **신규 추가 필요**
**기존 페이지**: `lucky_exam_fortune_page.dart`
**현재 채팅**: 없음 (FortuneSurveyType에 없음)

### 설계 결정
**신규 구현** - enum 추가 및 설문 설정 추가

### 최종 설계
```dart
// fortune_survey_config.dart에 enum 추가
enum FortuneSurveyType {
  // ... 기존 항목
  exam, // 시험 운세 (추가)
}

// survey_configs.dart에 설정 추가
const examSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.exam,
  title: '시험 운세',
  description: '시험/면접 운세를 봐드릴게요!',
  emoji: '📝',
  steps: [
    // Step 1: 시험 유형
    SurveyStep(
      id: 'examType',
      question: '어떤 시험이야? 📝',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'school', label: '학교 시험', emoji: '🏫'),
        SurveyOption(id: 'certification', label: '자격증', emoji: '📜'),
        SurveyOption(id: 'employment', label: '취업/공채', emoji: '💼'),
        SurveyOption(id: 'interview', label: '면접', emoji: '🤝'),
        SurveyOption(id: 'civil', label: '공무원', emoji: '🏛️'),
        SurveyOption(id: 'other', label: '기타', emoji: '✨'),
      ],
    ),
    // Step 2: 시험 날짜
    SurveyStep(
      id: 'examDate',
      question: '시험 날짜가 언제야? 📅',
      inputType: SurveyInputType.calendar,
    ),
    // Step 3: 현재 준비 상태
    SurveyStep(
      id: 'preparation',
      question: '지금 준비 상태는 어때? 💪',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'confident', label: '자신 있어!', emoji: '😎'),
        SurveyOption(id: 'moderate', label: '그럭저럭', emoji: '😐'),
        SurveyOption(id: 'worried', label: '걱정돼...', emoji: '😰'),
        SurveyOption(id: 'cramming', label: '벼락치기 중', emoji: '📚'),
      ],
    ),
  ],
);

// surveyConfigs 맵에 추가
FortuneSurveyType.exam: examSurveyConfig,
```

---

# 6. 재물 (2개)

---

## 6.1 Money/Investment (재물운)

**FortuneSurveyType**: `money`
**기존 페이지**: `investment_fortune_page.dart`
**현재 채팅**: style + interest 2개 step

### 설계 결정
**현행 유지** - 적절한 수준

### 최종 설계
```dart
const moneySurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.money,
  title: '재물운',
  description: '재물운을 분석해드릴게요',
  emoji: '💰',
  steps: [
    // Step 1: 투자 성향
    SurveyStep(
      id: 'style',
      question: '투자 성향이 어때? 💰',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'safe', label: '안전 추구', emoji: '🛡️'),
        SurveyOption(id: 'balanced', label: '중립적', emoji: '⚖️'),
        SurveyOption(id: 'aggressive', label: '공격적', emoji: '🚀'),
      ],
    ),
    // Step 2: 관심 분야 (다중)
    SurveyStep(
      id: 'interest',
      question: '관심 있는 분야가 있어? 💎 (여러 개 선택 가능)',
      inputType: SurveyInputType.multiSelect,
      options: [
        SurveyOption(id: 'stock', label: '주식', emoji: '📈'),
        SurveyOption(id: 'realestate', label: '부동산', emoji: '🏠'),
        SurveyOption(id: 'crypto', label: '코인', emoji: '₿'),
        SurveyOption(id: 'saving', label: '저축/예금', emoji: '🏦'),
        SurveyOption(id: 'business', label: '사업', emoji: '💼'),
        SurveyOption(id: 'side', label: '부업/N잡', emoji: '💵'),
      ],
      isRequired: false,
    ),
  ],
);
```

---

## 6.2 Lotto (로또)

**FortuneSurveyType**: `lotto`
**기존 페이지**: `lotto_fortune_page.dart`
**현재 채팅**: method 1개 step

### 설계 결정
**보강 필요** - 뽑을 게임 수 추가

### 최종 설계
```dart
const lottoSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.lotto,
  title: '로또 번호',
  description: '행운의 번호를 뽑아볼게요!',
  emoji: '🎰',
  steps: [
    // Step 1: 번호 생성 방식
    SurveyStep(
      id: 'method',
      question: '어떤 방식으로 번호를 생성할까? 🎲',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'saju', label: '사주 기반', emoji: '📿'),
        SurveyOption(id: 'lucky', label: '오늘의 행운', emoji: '🍀'),
        SurveyOption(id: 'random', label: '완전 랜덤', emoji: '🎲'),
        SurveyOption(id: 'dream', label: '꿈 해석', emoji: '💭'),
      ],
    ),
    // Step 2: 게임 수
    SurveyStep(
      id: 'gameCount',
      question: '몇 게임 뽑을까? 🎫',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: '1', label: '1게임', emoji: '1️⃣'),
        SurveyOption(id: '3', label: '3게임', emoji: '3️⃣'),
        SurveyOption(id: '5', label: '5게임', emoji: '5️⃣'),
      ],
      isRequired: false, // 기본값: 1게임
    ),
  ],
);
```

### 변경 사항
- Step 2 추가: 게임 수 선택

---

# 7. 라이프스타일 (5개)

---

## 7.1 Lucky Items (행운 아이템)

**FortuneSurveyType**: `luckyItems`
**기존 페이지**: `lucky_items_page.dart`
**현재 채팅**: category 1개 step

### 설계 결정
**현행 유지** - 적절한 수준

### 최종 설계
```dart
const luckyItemsSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.luckyItems,
  title: '행운 아이템',
  description: '오늘의 행운을 가져다줄 아이템!',
  emoji: '🍀',
  steps: [
    SurveyStep(
      id: 'category',
      question: '어떤 종류의 행운 아이템이 궁금해? 🍀',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'all', label: '전체', emoji: '✨'),
        SurveyOption(id: 'fashion', label: '패션/액세서리', emoji: '👔'),
        SurveyOption(id: 'food', label: '음식/음료', emoji: '🍽️'),
        SurveyOption(id: 'color', label: '컬러', emoji: '🎨'),
        SurveyOption(id: 'place', label: '장소/방향', emoji: '🧭'),
        SurveyOption(id: 'number', label: '숫자', emoji: '🔢'),
      ],
      isRequired: false, // 선택 안하면 전체
    ),
  ],
);
```

---

## 7.2 Wish (소원)

**FortuneSurveyType**: `wish`
**기존 페이지**: `wish_fortune_page.dart`
**현재 채팅**: category + wishContent 2개 step

### 설계 결정
**현행 유지** - 적절한 수준

### 최종 설계
```dart
const wishSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.wish,
  title: '소원 빌기',
  description: '마음 속 소원을 빌어보세요',
  emoji: '🌠',
  steps: [
    // Step 1: 소원 카테고리
    SurveyStep(
      id: 'category',
      question: '어떤 종류의 소원이야? 🌟',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'love', label: '사랑', emoji: '💕'),
        SurveyOption(id: 'success', label: '성공', emoji: '🏆'),
        SurveyOption(id: 'health', label: '건강', emoji: '💪'),
        SurveyOption(id: 'wealth', label: '재물', emoji: '💰'),
        SurveyOption(id: 'family', label: '가족', emoji: '👨‍👩‍👧‍👦'),
        SurveyOption(id: 'other', label: '기타', emoji: '✨'),
      ],
    ),
    // Step 2: 소원 내용 (음성/텍스트)
    SurveyStep(
      id: 'wishContent',
      question: '소원을 말하거나 적어줘! 🌠\n마음을 담아서...',
      inputType: SurveyInputType.voice,
    ),
  ],
);
```

---

## 7.3 Fortune Cookie (오늘의 메시지)

**FortuneSurveyType**: `fortuneCookie`
**기존 페이지**: 없음 (바로 결과)
**현재 채팅**: `steps: []`

### 설계 결정
**현행 유지** - 추가 입력 불필요

### 최종 설계
```dart
const fortuneCookieSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.fortuneCookie,
  title: '오늘의 메시지',
  description: '오늘 당신에게 전하는 한 마디',
  emoji: '🥠',
  steps: [], // 추가 수집 없음
);
```

---

## 7.4 Moving (이사)

**FortuneSurveyType**: `moving` → **신규 추가 필요**
**기존 페이지**: `moving_fortune_page.dart`
**현재 채팅**: 없음 (FortuneSurveyType에 없음)

### 설계 결정
**신규 구현** - enum 추가 및 설문 설정 추가

### 최종 설계
```dart
// fortune_survey_config.dart에 enum 추가
enum FortuneSurveyType {
  // ... 기존 항목
  moving, // 이사 운세 (추가)
}

// survey_configs.dart에 설정 추가
const movingSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.moving,
  title: '이사 운세',
  description: '이사 방위와 시기를 알려드려요',
  emoji: '🏠',
  steps: [
    // Step 1: 이사 예정 시기
    SurveyStep(
      id: 'movingTime',
      question: '언제쯤 이사 예정이야? 📅',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'soon', label: '곧 (1개월 내)', emoji: '🏃'),
        SurveyOption(id: 'quarter', label: '3개월 내', emoji: '📅'),
        SurveyOption(id: 'half', label: '6개월 내', emoji: '🗓️'),
        SurveyOption(id: 'year', label: '1년 내', emoji: '📆'),
        SurveyOption(id: 'planning', label: '아직 계획 중', emoji: '🤔'),
      ],
    ),
    // Step 2: 이사 목적
    SurveyStep(
      id: 'purpose',
      question: '이사 이유가 뭐야? 🏠',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'marriage', label: '결혼/신혼집', emoji: '💒'),
        SurveyOption(id: 'job', label: '직장/학교', emoji: '💼'),
        SurveyOption(id: 'upgrade', label: '더 좋은 집', emoji: '🏡'),
        SurveyOption(id: 'independence', label: '독립', emoji: '🚀'),
        SurveyOption(id: 'environment', label: '환경 변화', emoji: '🌳'),
        SurveyOption(id: 'other', label: '기타', emoji: '✨'),
      ],
    ),
    // Step 3: 현재 위치 방향 (선택적)
    SurveyStep(
      id: 'currentDirection',
      question: '지금 집 방향 알아? (몰라도 괜찮아!) 🧭',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'east', label: '동쪽', emoji: '🌅'),
        SurveyOption(id: 'west', label: '서쪽', emoji: '🌇'),
        SurveyOption(id: 'south', label: '남쪽', emoji: '☀️'),
        SurveyOption(id: 'north', label: '북쪽', emoji: '❄️'),
        SurveyOption(id: 'unknown', label: '잘 모르겠어', emoji: '🤷'),
      ],
      isRequired: false,
    ),
  ],
);

// surveyConfigs 맵에 추가
FortuneSurveyType.moving: movingSurveyConfig,
```

---

## 7.5 Home Fengshui (집 풍수) - 참고

**참고**: `home_fengshui_fortune_page.dart` 존재하지만 fortune_category.dart에 없음
→ 향후 추가 검토 필요

---

# 8. 건강/스포츠 (3개)

---

## 8.1 Health (건강)

**FortuneSurveyType**: `health`
**기존 페이지**: 없음 (채팅 전용)
**현재 채팅**: concern 1개 step

### 설계 결정
**현행 유지** - 적절한 수준

### 최종 설계
```dart
const healthSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.health,
  title: '건강 운세',
  description: '오늘의 건강 운세를 봐드릴게요',
  emoji: '💊',
  steps: [
    SurveyStep(
      id: 'concern',
      question: '특히 신경 쓰이는 부분이 있어? 💪',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'fatigue', label: '피로/수면', emoji: '😴'),
        SurveyOption(id: 'stress', label: '스트레스', emoji: '😰'),
        SurveyOption(id: 'weight', label: '체중 관리', emoji: '⚖️'),
        SurveyOption(id: 'pain', label: '통증/불편', emoji: '🩹'),
        SurveyOption(id: 'mental', label: '정신 건강', emoji: '🧠'),
        SurveyOption(id: 'general', label: '전반적 건강', emoji: '💪'),
      ],
      isRequired: false, // 선택 안하면 전반적
    ),
  ],
);
```

---

## 8.2 Exercise (운동)

**FortuneSurveyType**: `exercise`
**기존 페이지**: 없음 (채팅 전용)
**현재 채팅**: goal + intensity 2개 step

### 설계 결정
**현행 유지** - 적절한 수준

### 최종 설계
```dart
const exerciseSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.exercise,
  title: '운동 추천',
  description: '오늘 맞는 운동을 추천해드려요',
  emoji: '🏃',
  steps: [
    // Step 1: 운동 목적
    SurveyStep(
      id: 'goal',
      question: '운동 목적이 뭐야? 🏃',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'weight', label: '다이어트', emoji: '🏃'),
        SurveyOption(id: 'muscle', label: '근력 강화', emoji: '💪'),
        SurveyOption(id: 'health', label: '건강 유지', emoji: '❤️'),
        SurveyOption(id: 'stress', label: '스트레스 해소', emoji: '🧘'),
        SurveyOption(id: 'flexibility', label: '유연성', emoji: '🤸'),
      ],
    ),
    // Step 2: 운동 강도
    SurveyStep(
      id: 'intensity',
      question: '원하는 강도는? 💪',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'light', label: '가볍게', emoji: '🚶'),
        SurveyOption(id: 'moderate', label: '적당히', emoji: '🏃'),
        SurveyOption(id: 'intense', label: '빡세게', emoji: '🏋️'),
      ],
    ),
  ],
);
```

---

## 8.3 Sports Game (스포츠 경기)

**FortuneSurveyType**: `sportsGame`
**기존 페이지**: 없음 (채팅 전용)
**현재 채팅**: sport + gameDate 2개 step

### 설계 결정
**보강 필요** - 응원팀 추가

### 최종 설계
```dart
const sportsGameSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.sportsGame,
  title: '스포츠 경기',
  description: '경기 운세를 봐드릴게요!',
  emoji: '🏆',
  steps: [
    // Step 1: 스포츠 종목
    SurveyStep(
      id: 'sport',
      question: '어떤 종목이야? ⚽',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'soccer', label: '축구', emoji: '⚽'),
        SurveyOption(id: 'baseball', label: '야구', emoji: '⚾'),
        SurveyOption(id: 'basketball', label: '농구', emoji: '🏀'),
        SurveyOption(id: 'esports', label: 'e스포츠', emoji: '🎮'),
        SurveyOption(id: 'other', label: '기타', emoji: '🏆'),
      ],
    ),
    // Step 2: 경기 날짜
    SurveyStep(
      id: 'gameDate',
      question: '경기 날짜가 언제야? 📅',
      inputType: SurveyInputType.calendar,
    ),
    // Step 3: 응원팀 (선택적)
    SurveyStep(
      id: 'favoriteTeam',
      question: '응원하는 팀 이름을 알려줘! 📣 (선택)',
      inputType: SurveyInputType.text,
      isRequired: false,
    ),
  ],
);
```

### 변경 사항
- Step 3 추가: 응원팀 이름 (선택적)

---

# 9. 인터랙티브 (2개)

---

## 9.1 Dream (꿈 해몽)

**FortuneSurveyType**: `dream`
**기존 페이지**: `dream_fortune_voice_page.dart` - 음성 입력
**현재 채팅**: dreamContent + emotion 2개 step

### 설계 결정
**현행 유지** - 잘 구현됨

### 최종 설계
```dart
const dreamSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.dream,
  title: '꿈 해몽',
  description: '어젯밤 꿈 이야기를 들려주세요',
  emoji: '💭',
  steps: [
    // Step 1: 꿈 내용 (음성/텍스트)
    SurveyStep(
      id: 'dreamContent',
      question: '어젯밤 꿈을 말하거나 적어줘! 💭',
      inputType: SurveyInputType.voice,
    ),
    // Step 2: 꿈에서의 감정
    SurveyStep(
      id: 'emotion',
      question: '꿈에서 어떤 기분이었어? 🌙',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'happy', label: '기뻤어', emoji: '😊'),
        SurveyOption(id: 'scary', label: '무서웠어', emoji: '😱'),
        SurveyOption(id: 'sad', label: '슬펐어', emoji: '😢'),
        SurveyOption(id: 'confused', label: '혼란스러웠어', emoji: '😵'),
        SurveyOption(id: 'strange', label: '이상했어', emoji: '🤔'),
        SurveyOption(id: 'vivid', label: '생생했어', emoji: '✨'),
      ],
    ),
  ],
);
```

---

## 9.2 Celebrity (유명인 궁합)

**FortuneSurveyType**: `celebrity`
**기존 페이지**: `celebrity_fortune_page.dart`
**현재 채팅**: celebrityName 1개 step

### 설계 결정
**보강 필요** - 관심 포인트 추가

### 최종 설계
```dart
const celebritySurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.celebrity,
  title: '유명인 궁합',
  description: '좋아하는 유명인과 궁합을 알아볼까요?',
  emoji: '⭐',
  steps: [
    // Step 1: 유명인 이름
    SurveyStep(
      id: 'celebrityName',
      question: '누구와의 궁합이 궁금해? ⭐',
      inputType: SurveyInputType.text,
    ),
    // Step 2: 궁합 포인트
    SurveyStep(
      id: 'interest',
      question: '특히 궁금한 부분이 있어? 💫',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'overall', label: '전체 궁합', emoji: '💫'),
        SurveyOption(id: 'personality', label: '성격 궁합', emoji: '🧠'),
        SurveyOption(id: 'love', label: '연애 궁합', emoji: '💕'),
        SurveyOption(id: 'work', label: '케미/협업', emoji: '🤝'),
      ],
      isRequired: false,
    ),
  ],
);
```

### 변경 사항
- Step 2 추가: 궁합 관심 포인트

---

# 10. 가족/반려동물 (3개)

---

## 10.1 Pet (반려동물 궁합)

**FortuneSurveyType**: `pet`
**기존 페이지**: `pet_compatibility_page.dart`
**현재 채팅**: pet 1개 step (petProfile)

### 설계 결정
**보강 필요** - 궁합 유형 추가

### 최종 설계
```dart
const petSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.pet,
  title: '반려동물 궁합',
  description: '반려동물과의 궁합을 봐드릴게요!',
  emoji: '🐾',
  steps: [
    // Step 1: 반려동물 선택
    SurveyStep(
      id: 'pet',
      question: '어떤 반려동물이야? 🐾',
      inputType: SurveyInputType.petProfile,
    ),
    // Step 2: 궁합 관심 포인트
    SurveyStep(
      id: 'interest',
      question: '특히 궁금한 부분이 있어? 💕',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'overall', label: '전체 궁합', emoji: '✨'),
        SurveyOption(id: 'personality', label: '성격 궁합', emoji: '🧠'),
        SurveyOption(id: 'health', label: '건강 관리', emoji: '💊'),
        SurveyOption(id: 'training', label: '훈련/교육', emoji: '📚'),
        SurveyOption(id: 'play', label: '놀이/활동', emoji: '🎾'),
      ],
      isRequired: false,
    ),
  ],
);
```

### 변경 사항
- Step 2 추가: 궁합 관심 포인트

---

## 10.2 Family (가족 운세)

**FortuneSurveyType**: `family`
**기존 페이지**: `family_fortune_page.dart`
**현재 채팅**: concern + member 2개 step

### 설계 결정
**현행 유지** - 적절한 수준

### 최종 설계
```dart
const familySurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.family,
  title: '가족 운세',
  description: '가족 운세를 살펴볼게요',
  emoji: '👨‍👩‍👧‍👦',
  steps: [
    // Step 1: 관심사
    SurveyStep(
      id: 'concern',
      question: '어떤 부분이 궁금해? 👨‍👩‍👧‍👦',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'harmony', label: '화목/관계', emoji: '💕'),
        SurveyOption(id: 'health', label: '건강', emoji: '💪'),
        SurveyOption(id: 'wealth', label: '재물', emoji: '💰'),
        SurveyOption(id: 'education', label: '자녀 교육', emoji: '📚'),
        SurveyOption(id: 'overall', label: '전체 운세', emoji: '✨'),
      ],
    ),
    // Step 2: 가족 구성원
    SurveyStep(
      id: 'member',
      question: '누구의 운세가 궁금해? 👪',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'all', label: '가족 전체', emoji: '👨‍👩‍👧‍👦'),
        SurveyOption(id: 'parents', label: '부모님', emoji: '👴👵'),
        SurveyOption(id: 'spouse', label: '배우자', emoji: '💑'),
        SurveyOption(id: 'children', label: '자녀', emoji: '👶'),
        SurveyOption(id: 'siblings', label: '형제자매', emoji: '👫'),
      ],
    ),
  ],
);
```

---

## 10.3 Naming (작명)

**FortuneSurveyType**: `naming`
**기존 페이지**: `naming_fortune_page.dart`
**현재 채팅**: dueDate + gender + lastName + style 4개 step

### 설계 결정
**현행 유지** - 잘 구현됨

### 최종 설계
```dart
const namingSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.naming,
  title: '작명',
  description: '좋은 이름을 찾아드릴게요!',
  emoji: '📝',
  steps: [
    // Step 1: 출산 예정일
    SurveyStep(
      id: 'dueDate',
      question: '출산 예정일이 언제야? 📅 (몰라도 괜찮아!)',
      inputType: SurveyInputType.calendar,
      isRequired: false,
    ),
    // Step 2: 성별
    SurveyStep(
      id: 'gender',
      question: '아이 성별은? 👶',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'male', label: '남아', emoji: '👦'),
        SurveyOption(id: 'female', label: '여아', emoji: '👧'),
        SurveyOption(id: 'unknown', label: '아직 몰라', emoji: '🤷'),
      ],
    ),
    // Step 3: 성(姓)
    SurveyStep(
      id: 'lastName',
      question: '성(姓)을 알려줘! ✍️',
      inputType: SurveyInputType.text,
    ),
    // Step 4: 이름 스타일
    SurveyStep(
      id: 'style',
      question: '원하는 이름 스타일은? ✨',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'traditional', label: '전통적', emoji: '📿'),
        SurveyOption(id: 'modern', label: '현대적', emoji: '✨'),
        SurveyOption(id: 'unique', label: '독특한', emoji: '🌟'),
        SurveyOption(id: 'cute', label: '귀여운', emoji: '🥰'),
        SurveyOption(id: 'strong', label: '강인한', emoji: '💪'),
      ],
    ),
  ],
);
```

---

# 11. 스타일/패션 (1개)

---

## 11.1 OOTD Evaluation (OOTD 평가)

**FortuneSurveyType**: `ootdEvaluation`
**기존 페이지**: 없음 (신규)
**현재 채팅**: tpo + photo 2개 step (이미 구현됨)

### 설계 결정
**현행 유지** - 잘 구현됨

### 최종 설계
```dart
const ootdEvaluationSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.ootdEvaluation,
  title: 'OOTD 평가',
  description: 'AI가 오늘의 패션을 평가해드려요!',
  emoji: '👔',
  steps: [
    // Step 1: TPO 선택
    SurveyStep(
      id: 'tpo',
      question: '오늘 어디 가? 👔',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'date', label: '데이트', emoji: '💕'),
        SurveyOption(id: 'interview', label: '면접', emoji: '💼'),
        SurveyOption(id: 'work', label: '출근', emoji: '🏢'),
        SurveyOption(id: 'casual', label: '일상', emoji: '☕'),
        SurveyOption(id: 'party', label: '파티/모임', emoji: '🎉'),
        SurveyOption(id: 'wedding', label: '경조사', emoji: '💒'),
        SurveyOption(id: 'travel', label: '여행', emoji: '✈️'),
        SurveyOption(id: 'sports', label: '운동', emoji: '🏃'),
      ],
    ),
    // Step 2: OOTD 사진
    SurveyStep(
      id: 'photo',
      question: 'OOTD 사진을 올려줘! 📸',
      inputType: SurveyInputType.image,
    ),
  ],
);
```

---

# 12. 유틸리티 (1개)

---

## 12.1 Profile Creation (프로필 생성)

**FortuneSurveyType**: `profileCreation`
**용도**: 궁합 등에서 새 프로필 생성 시 사용
**현재 채팅**: name + relationship + birthDateTime + gender 4개 step

### 설계 결정
**현행 유지** - 잘 구현됨

### 최종 설계
```dart
const profileCreationSurveyConfig = FortuneSurveyConfig(
  fortuneType: FortuneSurveyType.profileCreation,
  title: '상대방 정보 입력',
  description: '궁합을 볼 상대의 정보를 알려주세요',
  emoji: '✍️',
  steps: [
    // Step 1: 이름
    SurveyStep(
      id: 'name',
      question: '상대방 이름이 뭐야? ✨',
      inputType: SurveyInputType.text,
    ),
    // Step 2: 관계
    SurveyStep(
      id: 'relationship',
      question: '어떤 관계야? 💫',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'lover', label: '애인', emoji: '💕'),
        SurveyOption(id: 'family', label: '가족', emoji: '👨‍👩‍👧‍👦'),
        SurveyOption(id: 'friend', label: '친구', emoji: '👥'),
        SurveyOption(id: 'crush', label: '짝사랑', emoji: '💘'),
        SurveyOption(id: 'other', label: '기타', emoji: '✨'),
      ],
    ),
    // Step 3: 생년월일+시간
    SurveyStep(
      id: 'birthDateTime',
      question: '생년월일과 태어난 시간을 알려줘! 🗓️',
      inputType: SurveyInputType.birthDateTime,
    ),
    // Step 4: 성별
    SurveyStep(
      id: 'gender',
      question: '성별이 어떻게 돼? 👤',
      inputType: SurveyInputType.chips,
      options: [
        SurveyOption(id: 'male', label: '남성', emoji: '👨'),
        SurveyOption(id: 'female', label: '여성', emoji: '👩'),
      ],
    ),
  ],
);
```

---

# 구현 체크리스트

## 신규 추가 필요 (FortuneSurveyType enum + surveyConfigs 맵)

| 운세 | enum 값 | 상태 |
|------|---------|------|
| Talisman (부적) | `talisman` | ❌ 추가 필요 |
| Exam (시험) | `exam` | ❌ 추가 필요 |
| Moving (이사) | `moving` | ❌ 추가 필요 |

## 기존 설문 보강 필요

| 운세 | 변경 내용 |
|------|----------|
| Traditional Saju | Step 2, 3 추가 (질문 선택 + 커스텀) |
| Face Reading | Step 1 추가 (분석 포커스) |
| Love | Step 3, 4 추가 (연애 스타일 + 이상형) |
| Compatibility | Step 1, 2b, 3, 4 추가 (입력 방식 + 직접 입력 + 관계) |
| Ex Lover | Step 3 추가 (현재 마음 상태) |
| Lotto | Step 2 추가 (게임 수) |
| Sports Game | Step 3 추가 (응원팀) |
| Celebrity | Step 2 추가 (관심 포인트) |
| Pet | Step 2 추가 (관심 포인트) |

## 현행 유지 (변경 불필요)

| 운세 | 이유 |
|------|------|
| Daily | 설문 없음 (오늘 고정) |
| Yearly | 1개 step 적절 |
| NewYear | 1개 step 적절 |
| Tarot | 2개 step 완비 |
| Personality DNA | 설문 없음 (생년월일 기반) |
| MBTI | 1개 step 완비 |
| Biorhythm | 1개 step 완비 |
| Avoid People | 1개 step 적절 |
| Blind Date | 7개 step 상세 완비 |
| Career | 4개 step 완비 |
| Talent | 3개 step 완비 |
| Money | 2개 step 적절 |
| Lucky Items | 1개 step 적절 |
| Wish | 2개 step 완비 |
| Fortune Cookie | 설문 없음 |
| Health | 1개 step 적절 |
| Exercise | 2개 step 완비 |
| Dream | 2개 step 완비 |
| Family | 2개 step 완비 |
| Naming | 4개 step 완비 |
| OOTD Evaluation | 2개 step 완비 |
| Profile Creation | 4개 step 완비 |

---

## 결과 구조 가이드

### 공통 결과 필드 (Fortune 엔티티)

```dart
class Fortune {
  final String id;
  final String type;
  final String title;
  final String summary;
  final String content;
  final String? advice;
  final Map<String, int>? scores;      // 점수 (총점, 카테고리별)
  final List<String>? categories;      // 카테고리별 분석
  final List<String>? luckyItems;      // 행운 아이템
  final List<String>? recommendations; // 추천 사항
  final bool isBlurred;                // 블러 처리 여부
  final List<String> blurredSections;  // 블러 처리된 섹션
}
```

### 운세별 특수 결과 필드

| 운세 | 특수 필드 |
|------|----------|
| Traditional Saju | sajuData (명식, 오행, 지장간 등) |
| Tarot | selectedCards, cardMeanings |
| MBTI | mbtiType, compatibility |
| Biorhythm | physical, emotional, intellectual (수치) |
| Compatibility | matchScore, synergy, conflict |
| Lotto | numbers, bonusNumber |
| Dream | interpretation, luckyNumber |
| Face Reading | faceAnalysis, features |
| Naming | suggestedNames, meanings |
| OOTD Evaluation | overallScore, styleAdvice, colorAdvice |

---

## 마이그레이션 우선순위

### 1순위 (필수 - 현재 미구현)
1. Talisman - enum + config 추가
2. Exam - enum + config 추가
3. Moving - enum + config 추가

### 2순위 (중요 - 기존 페이지 정보 손실)
1. Traditional Saju - 질문 선택 기능 복원
2. Love - 핵심 정보 복원 (20개 → 4개 압축)
3. Compatibility - 직접 입력 옵션 추가

### 3순위 (개선 - UX 향상)
1. Face Reading - 분석 포커스 추가
2. Ex Lover - 마음 상태 추가
3. Lotto - 게임 수 추가
4. Sports Game - 응원팀 추가
5. Celebrity - 관심 포인트 추가
6. Pet - 관심 포인트 추가

---

*문서 끝*