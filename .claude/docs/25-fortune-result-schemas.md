# 인사이트 결과 스키마 레퍼런스

> 최종 업데이트: 2026.04.06

44개 사용자 노출 운세/분석 Edge Function의 입력/출력 스키마를 repo truth 기준으로 정리한 문서입니다.

---

## 범위

- 총 Edge Functions: `72` (`_shared` 제외)
- 운세 스키마 본문: `44` (`fortune-*` 43개 + `personality-dna` 1개)
- 유틸리티 Functions: `28` (본 문서 범위 제외)
- `personality-dna`는 접두사는 다르지만 사용자 노출 분석 surface, 카테고리, 결과 UI 문맥에서 운세 bucket으로 다루므로 본문에 포함합니다.

## 공통 응답 구조

모든 함수 응답은 아래 envelope를 기준으로 해석합니다.

```typescript
type FortuneEnvelope<T> = {
  success: true;
  data: T;
  error?: string;
};
```

### 공통 필드

| 필드 | 타입 | 설명 |
|------|------|------|
| `fortuneType` | `string` | 운세 타입 식별자 |
| `score` | `number` | 종합 점수 (0-100) |
| `content` | `string` | 메인 상세 콘텐츠 |
| `summary` | `string` | 한줄 요약 |
| `advice` | `string` | 실행 가능한 조언 |
| `timestamp` | `string` | ISO 8601 타임스탬프 |
| `percentile` | `number?` | 백분위 순위 (calculatePercentile) |

### 섹션 읽는 법

- `입력`: 함수가 요구하는 핵심 survey/profile/media 입력군
- `출력`: 공통 wrapper 기준 응답 타입
- `핵심 필드`: 결과 카드/채팅 surface에서 주로 읽는 상위 필드
- `TypeScript 타입`: `data` payload shape 요약

---

## 일상 운세

### fortune-daily (오늘의 운세)

#### 입력

- 사용자 프로필, 생년월일/시간, 오늘 날짜 컨텍스트를 기준으로 생성합니다.

#### 출력

- `FortuneEnvelope<FortuneDailyData>`

#### 핵심 필드

- `categories`, `lucky_items`, `lucky_numbers`, `special_tip`

#### TypeScript 타입

```typescript
type FortuneDailyData = {
  categories: {
    total: { score, advice },
    love: { score, advice },
    money: { score, advice },
    work: { score, advice },
    study: { score, advice },
    health: { score, advice }
  },
  lucky_items: { time, color, number, direction, food, item },
  lucky_numbers: string[],
  special_tip: string,
  ai_insight: string,
  ai_tips: string[],
  fortuneSummary: {
    byZodiacAnimal: { title, content, score },
    byZodiacSign: { title, content, score },
    byMBTI: { title, content, score }
  },
  personalActions: [{ title, why, priority }],
  sajuInsight: { lucky_color, lucky_food, lucky_item, luck_direction, keyword },
  lucky_outfit: { title, description, items[] },
  celebrities_same_day: string[],
  celebrities_similar_saju: string[],
  age_fortune: { ageGroup, title, description, zodiacAnimal },
  daily_predictions: { morning, afternoon, evening },
  share_count: number
}
```

### fortune-time (시간대별 운세)

#### 입력

- 사용자 프로필과 오늘 날짜를 기준으로 12시진 시간대 분석을 생성합니다.

#### 출력

- `FortuneEnvelope<FortuneTimeData>`

#### 핵심 필드

- `timeSlots`, `cautionTimes`, `cautionActivities`, `cautionPeople`

#### TypeScript 타입

```typescript
type FortuneTimeData = {
  timeSlots: [{ /* 12시진별 운세 */ }],
  cautionTimes: [{ time, reason, severity }],
  cautionActivities: [{ activity, reason, severity }],
  cautionPeople: [{ type, reason, severity, relatedZodiac }],
  cautionDirections: [{ direction, reason }],
  luckyElements: { colors[], numbers[], direction, items[] },
  timeStrategy: {
    morning: { caution, advice, luckyAction },
    afternoon: { caution, advice, luckyAction },
    evening: { caution, advice, luckyAction }
  },
  traditionalElements: { fiveElements, dailyStem, timeSlots }
}
```

### fortune-biorhythm (바이오리듬)

#### 입력

- 생년월일 기반 바이오리듬 값과 오늘 날짜를 입력으로 사용합니다.

#### 출력

- `FortuneEnvelope<FortuneBiorhythmData>`

#### 핵심 필드

- `status_message`, `greeting`, `physical`, `emotional`

#### TypeScript 타입

```typescript
type FortuneBiorhythmData = {
  status_message: string,
  greeting: string,
  physical: { score, value(-100~100), status, advice },
  emotional: { score, value(-100~100), status, advice },
  intellectual: { score, value(-100~100), status, advice },
  today_recommendation: { best_activity, avoid_activity, best_time, energy_management },
  weekly_forecast: { best_day, worst_day, overview, weekly_advice },
  important_dates: [{ date, type, description }],
  weekly_activities: string[],
  personal_analysis: string,
  lifestyle_advice: string,
  health_tips: string
}
```

### fortune-lucky-items (행운 아이템)

#### 입력

- 사용자 프로필과 오늘 컨텍스트를 바탕으로 행운 요소를 계산합니다.

#### 출력

- `FortuneEnvelope<FortuneLuckyItemsData>`

#### 핵심 필드

- `keyword`, `color`, `fashion`, `numbers`

#### TypeScript 타입

```typescript
type FortuneLuckyItemsData = {
  keyword: string,
  color: { primary, secondary, reason },
  fashion: [{ item, reason }],
  numbers: number[],
  numbersExplanation: string,
  avoidNumbers: number[],
  food: [{ item, reason, timing }],
  jewelry: string[],
  material: string[],
  direction: string,
  places: [{ place, category, reason, timing }],
  relationships: string[],
  todayTip: string,
  element: string,
  advice: string
}
```

### fortune-avoid-people (피해야 할 사람)

#### 입력

- 사용자 프로필과 오늘 컨텍스트를 기준으로 주의 대상/상황을 생성합니다.

#### 출력

- `FortuneEnvelope<FortuneAvoidPeopleData>`

#### 핵심 필드

- `cautionPeople`, `cautionObjects`, `cautionColors`, `cautionNumbers`

#### TypeScript 타입

```typescript
type FortuneAvoidPeopleData = {
  cautionPeople: { type, reason, sign, tip, severity, cautionSurnames[], surnameReason },
  cautionObjects: string[],
  cautionColors: string[],
  cautionNumbers: number[],
  cautionAnimals: string[],
  cautionPlaces: string[],
  cautionTimes: string[],
  cautionDirections: string[],
  luckyElements: { /* 긍정적 대응 */ },
  timeStrategy: string,
  dailyAdvice: string
}
```

---

## 연애/관계

### fortune-love (연애 운세)

#### 입력

- 사용자 프로필, 관계 상태, 연애 고민/맥락 입력을 사용합니다.

#### 출력

- `FortuneEnvelope<FortuneLoveData>`

#### 핵심 필드

- `personalInfo`, `loveProfile`, `detailedAnalysis`, `todaysAdvice`

#### TypeScript 타입

```typescript
type FortuneLoveData = {
  personalInfo: { age, gender, relationshipStatus },
  loveProfile: { dominantStyle, personalityType, communicationStyle, conflictResolution },
  detailedAnalysis: {
    loveStyle: { description, strengths[], tendencies[] },
    charmPoints: { primary, secondary, details[] },
    improvementAreas: { main, specific[], actionItems[] },
    compatibilityInsights: { bestMatch, avoidTypes, relationshipTips[] }
  },
  todaysAdvice: { general, specific[], luckyAction, warningArea },
  predictions: { thisWeek, thisMonth, nextThreeMonths },
  actionPlan: { immediate[], shortTerm[], longTerm[] },
  recommendations?: {
    dateSpots: { primary, alternatives[], reason, timeRecommendation },
    fashion: { style, colors[], topItems[], bottomItems[], outerwear, shoes, avoidFashion[], reason },
    accessories: { recommended[], avoid[], bags, reason },
    grooming: { hair, makeup, nails },
    fragrance: { notes[], mood, timing },
    conversation: { topics[], openers[], avoid[], tip }
  }
}
```

### fortune-compatibility (궁합)

#### 입력

- 두 사람의 생년월일/프로필과 관계 맥락을 입력으로 사용합니다.

#### 출력

- `FortuneEnvelope<FortuneCompatibilityData>`

#### 핵심 필드

- `overall_compatibility`, `overall_score`, `compatibility_grade`, `personality_match`

#### TypeScript 타입

```typescript
type FortuneCompatibilityData = {
  overall_compatibility: string,
  overall_score: number,  // 1-100
  compatibility_grade: string,  // 천생연분/좋음/보통/노력필요
  personality_match: number,
  love_match: number,
  marriage_match: number,
  communication_match: number,
  strengths: string[],
  cautions: string[],
  detailed_advice: string,
  compatibility_keyword: string,
  love_style: { /* 연애 스타일 분석 */ },
  name_compatibility: number,  // 0-99
  zodiac_animal: { person1, person2 },
  star_sign: string,
  destiny_number: number,
  age_difference: string,
  season: string
}
```

### fortune-blind-date (소개팅)

#### 입력

- 자기소개 정보와 선택된 분석 모드(`basic | photos | chat | comprehensive`)를 입력으로 사용합니다.

#### 출력

- `FortuneEnvelope<FortuneBlindDateData>`

#### 핵심 필드

- `score`, `successRate`, `successPrediction`, `conversationTopics`

#### TypeScript 타입

```typescript
type FortuneBlindDateData = {
  score: number,
  content: string,
  summary: string,
  overallAdvice: string,
  advice: string,
  keyPoints: string[],
  successRate: number,
  idealType: string,
  tips: string[],
  luckyPlace: string,
  fortuneType: 'blind-date',
  successPrediction?: { score, message, advice },
  firstImpressionTips?: string[],
  conversationTopics?: { recommended[], avoid[] },
  outfitAdvice?: { style, colors[] },
  locationAdvice?: string[],
  dosList?: string[],
  dontsList?: string[],
  finalMessage?: string,
  userInfo: { name, birthDate, gender, mbti? },
  meetingInfo: { meetingDate, meetingTime, meetingType, introducer },
  analysisType: 'basic' | 'photos' | 'chat' | 'comprehensive',
  photoAnalysis?: {
    myAttractiveness: number,
    theirAttractiveness?: number,
    visualCompatibility?: number,
    myStyle: string,
    myPersonality: string,
    theirStyle?: string,
    theirPersonality?: string,
    firstImpression: string,
    recommendedDateStyle: string
  },
  chatAnalysis?: {
    interestLevel: number,
    conversationStyle: string,
    improvementTips: string[],
    nextTopicSuggestions: string[],
    redFlags?: string[]
  },
  hasPhotoAnalysis: boolean,
  hasChatAnalysis: boolean,
  instagramUsername?: string | null,
  instagramFetched?: boolean,
  instagramError?: string | null,
  timestamp: string,
  percentile?: number
}
```

### fortune-ex-lover (전 연인)

#### 입력

- 이별 맥락, 현재 연락 상태, 목표(`healing | reunion_strategy | read_their_mind | new_start`)를 입력으로 사용합니다.

#### 출력

- `FortuneEnvelope<FortuneExLoverData>`

#### 핵심 필드

- `primaryGoal`, `relationshipDepth`, `coreReason`, `currentState`

#### TypeScript 타입

```typescript
type FortuneExLoverData = {
  primaryGoal: string,  // healing/reunion_strategy/read_their_mind/new_start
  relationshipDepth: string,
  coreReason: string,
  currentState: string[],
  contact_status: string,
  goalSpecific: { /* 목표별 분석 */ }
  // 채팅 스크린샷 분석 지원
}
```

### fortune-yearly-encounter (올해의 인연)

#### 입력

- 사용자 생년월일/프로필과 연간 인연 컨텍스트를 입력으로 사용합니다.

#### 출력

- `FortuneEnvelope<FortuneYearlyEncounterData>`

#### 핵심 필드

- `imageUrl`, `appearanceHashtags`, `encounterSpotTitle`, `encounterSpotStory`

#### TypeScript 타입

```typescript
type FortuneYearlyEncounterData = {
  imageUrl: string,
  imageGenerationSkipped?: boolean,
  imageGenerationReason?: string,
  appearanceHashtags: string[],
  encounterSpotTitle: string,
  encounterSpotStory: string,
  fateSignalTitle: string,
  fateSignalStory: string,
  personalityTitle: string,
  personalityStory: string,
  compatibilityScore: string,
  compatibilityDescription: string,
  targetGender: string,
  createdAt: string
}
```

---

## 전통/점술

### fortune-traditional-saju (사주 상담)

#### 입력

- 사주 원국 계산용 생년월일/시간과 성별, 달력 체계를 입력으로 사용합니다.

#### 출력

- `FortuneEnvelope<FortuneTraditionalSajuData>`

#### 핵심 필드

- `question`, `sections`, `summary`

#### TypeScript 타입

```typescript
type FortuneTraditionalSajuData = {
  question: string,
  sections: {
    analysis: string,  // 사주 분석
    answer: string,    // 질문 답변
    advice: string,    // 실용 조언
    supplement: string // 오행 보충
  },
  summary: string
}
```

### fortune-constellation (별자리)

#### 입력

- 생년월일과 서양 별자리 계산에 필요한 기본 프로필을 입력으로 사용합니다.

#### 출력

- `FortuneEnvelope<FortuneConstellationData>`

#### 핵심 필드

- `constellationEmoji`, `constellationSymbol`, `rulingPlanet`, `constellationElement`

#### TypeScript 타입

```typescript
type FortuneConstellationData = {
  constellationEmoji: string,
  constellationSymbol: string,
  rulingPlanet: string,
  constellationElement: string,  // fire/earth/air/water
  dateRange: string,
  todayInsight: string,
  starMessage: string,
  traits: { personality, strength, caution },
  fortuneScores: { overall, love, work, money },
  compatibility: { best, bestReason, caution, cautionReason },
  recommendations: string[],
  warnings: string[],
  luckyItems: { 색상, 숫자, 보석, 시간대 }
}
```

### fortune-zodiac-animal (띠 운세)

#### 입력

- 생년월일과 띠 계산용 출생 연도 정보를 입력으로 사용합니다.

#### 출력

- `FortuneEnvelope<FortuneZodiacAnimalData>`

#### 핵심 필드

- `zodiacAnimal`, `zodiacEmoji`, `zodiacHanja`, `element`

#### TypeScript 타입

```typescript
type FortuneZodiacAnimalData = {
  zodiacAnimal: string,
  zodiacEmoji: string,
  zodiacHanja: string,
  element: string,
  fortuneScores: { overall, wealth, love, health },
  compatibility: { best, bestReason, caution, cautionReason },
  luckyTimeSlot: string
}
```

### fortune-blood-type (혈액형)

#### 입력

- 혈액형과 성향 보조 프로필을 입력으로 사용합니다.

#### 출력

- `FortuneEnvelope<FortuneBloodTypeData>`

#### 핵심 필드

- `keyword`, `todayInsight`, `traits`, `fortuneScores`

#### TypeScript 타입

```typescript
type FortuneBloodTypeData = {
  keyword: string,
  todayInsight: string,
  traits: { strength, weakness, mood },
  fortuneScores: { overall, love, work, health },
  compatibility: { best, bestReason, caution, cautionReason },
  recommendations: string[],
  warnings: string[],
  luckyItems: { 색상, 숫자, 음식, 시간대 }
}
```

### fortune-tarot (타로)

#### 입력

- 질문, 선택된 카드/덱, spread 정보와 사용자 맥락을 입력으로 사용합니다.

#### 출력

- `FortuneEnvelope<FortuneTarotData>`

#### 핵심 필드

- `cardInterpretations`, `overallReading`, `storyTitle`, `guidance`

#### TypeScript 타입

```typescript
type FortuneTarotData = {
  cardInterpretations: object[],
  overallReading: string,
  storyTitle: string,
  guidance: string,
  energyLevel: number,  // 0-100
  keyThemes: string[],
  luckyElement: string,
  focusAreas: string[],
  timeFrame: string,
  positionInterpretations: { /* 위치별 해석 */ },
  cards: [{
    index, cardId, arcana, suit, rank,
    cardName, cardNameKr, imagePath,
    isReversed, orientationLabel,
    positionKey, positionName, positionDesc,
    interpretation, keywords, element
  }]
}
```

### fortune-dream (꿈 해몽)

#### 입력

- 꿈 서술 텍스트와 사용자 상태/상황을 입력으로 사용합니다.

#### 출력

- `FortuneEnvelope<FortuneDreamData>`

#### 핵심 필드

- `dream`, `inputType`, `date`, `analysis`

#### TypeScript 타입

```typescript
type FortuneDreamData = {
  dream: string,
  inputType: string,  // text/voice
  date: string,
  analysis: {
    mainTheme: string,
    psychologicalInsight: string,
    emotionalPattern: string,
    symbolAnalysis: [{ /* DreamSymbol */ }],
    scenes: [{ /* DreamScene */ }],
    luckyElements: string[],
    warningElements: string[]
  },
  interpretation: string,
  todayGuidance: string,
  psychologicalState: string,
  emotionalBalance: number,  // 1-10
  luckyKeywords: string[],
  avoidKeywords: string[],
  dreamType: string,
  significanceLevel: number,  // 1-10
  actionAdvice: string[],
  affirmations: string[],
  relatedSymbols: string[]
}
```

---

## 심리/역량/건강

### fortune-wealth (재물운)

#### 입력

- 재정 상태, 소비/저축 성향, 목표 금액 등 재물 맥락을 입력으로 사용합니다.

#### 출력

- `FortuneEnvelope<FortuneWealthData>`

#### 핵심 필드

- `overallScore`, `wealthPotential`, `elementAnalysis`, `goalAdvice`

#### TypeScript 타입

```typescript
type FortuneWealthData = {
  overallScore: number,
  wealthPotential: string,
  elementAnalysis: { /* 오행 재물 영향 */ },
  goalAdvice: { /* 목표별 가이드 */ },
  cashflowInsight: string,
  concernResolution: string,
  investmentInsights: {
    // stock, crypto, realestate, saving, business, side 별 상세 분석
  },
  luckyElements: { /* 행운 아이템/타이밍 */ },
  monthlyFlow: [{ /* 월별 예측 */ }],
  actionItems: string[]
}
```

### fortune-investment (투자운)

#### 입력

- 투자 성향, 자산 상황, 관심 종목/전략 같은 금융 맥락을 입력으로 사용합니다.

#### 출력

- `FortuneEnvelope<FortuneInvestmentData>`

#### 핵심 필드

- `overallScore`, `sajuInsight`, `timing`, `outlook`

#### TypeScript 타입

```typescript
type FortuneInvestmentData = {
  overallScore: number,
  sajuInsight: { elementFit, todayEnergy, mindsetAdvice },
  timing: { buySignal, generalAdvice, emotionalTip },
  outlook: { general: { mood, text } },
  risks: { emotionalRisks[], mindfulReminders[] },
  marketMood: { categoryMood, categoryMoodText, investorSentiment },
  luckyItems: { /* 행운 요소 */ },
  advice: string,
  psychologyTip: string,
  disclaimer: string
}
```

### fortune-career (커리어)

#### 입력

- 직무, 경력 단계, 현재 고민/목표를 입력으로 사용합니다.

#### 출력

- `FortuneEnvelope<FortuneCareerData>`

#### 핵심 필드

- `currentRole`, `timeHorizon`, `careerPath`, `predictions`

#### TypeScript 타입

```typescript
type FortuneCareerData = {
  currentRole: string,
  timeHorizon: string,
  careerPath: string,
  predictions: [{
    timeframe, probability, keyMilestones[],
    requiredActions[], potentialChallenges[], successFactors[]
  }],
  skillAnalysis: [{
    skill, currentLevel(1-10), targetLevel(1-10),
    developmentPlan, timeToMaster, importanceScore
  }],
  strengthsAssessment: string[],
  improvementAreas: string[],
  actionPlan: { immediate[], shortTerm[], longTerm[] },
  industryInsights: string,
  networkingAdvice: string[],
  luckyPeriods: string[],
  cautionPeriods: string[],
  careerKeywords: string[],
  mentorshipAdvice: string
}
```

### fortune-exam (시험운)

#### 입력

- 시험 종류, 준비 상태, 일정, 불안 요인을 입력으로 사용합니다.

#### 출력

- `FortuneEnvelope<FortuneExamData>`

#### 핵심 필드

- `statusMessage`, `passGrade`, `examStats`, `csatFocus`

#### TypeScript 타입

```typescript
type FortuneExamData = {
  statusMessage: string,
  passGrade: string,
  examStats: {
    answerIntuition: { description },
    mentalDefense: { description },
    memoryAcceleration: { description }
  },
  // 수능 모드:
  csatFocus: { subject, focus, tip },
  csatRoadmap: string,
  csatRoutine: string,
  csatChecklist: string[],
  // 일반 시험:
  todayStrategy, spiritAnimal, hashtags,
  luckyInfo, studyTips, warnings, mentalCare, sajuAnalysis,
  ddayAdvice: string,
  summary: string,
  detailedMessage: string
}
```

### fortune-talent (재능 분석)

#### 입력

- 자기평가, 관심사, 현재 역할/경험을 입력으로 사용합니다.

#### 출력

- `FortuneEnvelope<FortuneTalentData>`

#### 핵심 필드

- `talentProfile`, `strengthAreas`, `growthOpportunities`, `skillRecommendations`

#### TypeScript 타입

```typescript
type FortuneTalentData = {
  talentProfile: { /* 재능 유형/강점 분석 */ },
  strengthAreas: string[],
  growthOpportunities: string[],
  skillRecommendations: [{ /* 개발 우선순위 */ }],
  roadmap: { /* 장기 발전 경로 */ },
  challenges: [{ /* 현재 장애물 분석 */ }]
  // 프리미엄: 이력서 텍스트 통합 지원
}
```

### fortune-health (건강운)

#### 입력

- 현재 컨디션, 건강 고민, 생활 습관, profile 정보를 입력으로 사용합니다.

#### 출력

- `FortuneEnvelope<FortuneHealthData>`

#### 핵심 필드

- `element_balance`, `weak_organs`, `recommendations`, `seasonal_advice`

#### TypeScript 타입

```typescript
type FortuneHealthData = {
  element_balance: { /* 오행 상태 */ },
  weak_organs: string[],
  recommendations: {
    diet: string[],
    exercise: string[],
    lifestyle: string[]
  },
  seasonal_advice: { /* 계절별 가이드 */ }
  // 오행 장기 매핑: 목(간/담), 화(심장/소장), 토(비장/위), 금(폐/대장), 수(신장/방광)
}
```

### fortune-health-document (건강문서 분석)

#### 입력

- 건강검진/의료 문서 이미지 또는 추출 텍스트와 사용자 프로필을 입력으로 사용합니다.

#### 출력

- `FortuneEnvelope<FortuneHealthDocumentData>`

#### 핵심 필드

- `documentAnalysis`, `testResults`, `sajuHealthAnalysis`, `healthScore`

#### TypeScript 타입

```typescript
type FortuneHealthDocumentData = {
  documentAnalysis: {
    documentType: string,
    documentDate: string | null,
    institution: string | null,
    summary: string
  },
  testResults: [{
    category: string,
    items: [{
      name: string,
      value: string,
      unit: string,
      status: 'normal' | 'caution' | 'warning' | 'critical',
      normalRange: string,
      interpretation: string
    }]
  }],
  sajuHealthAnalysis: {
    dominantElement: string,
    weakElement: string,
    elementDescription: string,
    vulnerableOrgans: string[],
    strengthOrgans: string[],
    sajuAdvice: string
  },
  healthScore: number,
  recommendations: {
    urgent: string[],
    general: string[],
    lifestyle: string[]
  },
  healthRegimen: {
    diet: [{
      type: 'recommend' | 'avoid',
      items: string[],
      reason: string
    }],
    exercise: [{
      type: string,
      frequency: string,
      duration: string,
      benefit: string
    }],
    lifestyle: string[]
  },
  timestamp: string
}
```

### fortune-exercise (운동운)

#### 입력

- 운동 습관, 체력 수준, 목표, 선호 운동을 입력으로 사용합니다.

#### 출력

- `FortuneEnvelope<FortuneExerciseData>`

#### 핵심 필드

- `recommendedExercise`, `todayRoutine`, `optimalTime`, `weaknesses`

#### TypeScript 타입

```typescript
type FortuneExerciseData = {
  recommendedExercise: { primary: { /* 상세 */ }, alternatives[] },
  todayRoutine: { /* 스포츠 카테고리별 변형 */ },
  optimalTime: string,
  weaknesses: string[],
  supplementary: string
}
```

### fortune-mbti (MBTI 운세)

#### 입력

- MBTI 유형과 성향 질문 응답을 입력으로 사용합니다.

#### 출력

- `FortuneEnvelope<FortuneMbtiData>`

#### 핵심 필드

- `dimensions`, `overallScore`, `todayTrap`, `todayFortune`

#### TypeScript 타입

```typescript
type FortuneMbtiData = {
  dimensions: [{
    dimension: string,  // E/I/N/S/T/F/J/P
    title: string,
    fortune: string,    // 50자 이내
    tip: string,        // 30자 이내
    score: number,      // 0-100
    warning: string
  }],
  overallScore: number,
  todayTrap: string,
  todayFortune: string,
  loveFortune: string,
  careerFortune: string,
  moneyFortune: string,
  healthFortune: string,
  luckyColor: string,
  luckyNumber: number,
  compatibility: [{ /* 호환 유형 */ }],
  energyLevel: number,
  cognitiveStrengths: string[],
  challenges: string[],
  mbtiDescription: string
}
```

### fortune-face-reading (관상 V2)

#### 입력

- 얼굴 이미지와 기본 프로필, 분석 옵션을 입력으로 사용합니다.

#### 출력

- `FortuneEnvelope<FortuneFaceReadingData>`

#### 핵심 필드

- `overview`, `ogwan`, `samjeong`, `sibigung`

#### TypeScript 타입

```typescript
type FortuneFaceReadingData = {
  // 기본 응답
  overview: {
    faceType, faceTypeElement, firstImpression, overallBlessingScore
  },
  ogwan: {  // 오관
    ear: { observation, interpretation, score, advice },
    eyebrow: { observation, interpretation, score, advice },
    eye: { observation, interpretation, score, advice },
    nose: { observation, interpretation, score, advice },
    mouth: { observation, interpretation, score, advice }
  },
  samjeong: {  // 삼정
    upper: { period, description, peakAge, score },
    middle: { period, description, peakAge, score },
    lower: { period, description, peakAge, score }
  },
  sibigung: { /* 십이궁 분석 */ },
  personality: { traits, strengths, growthAreas },
  fortunes: { wealth, love, career, health, overall },

  // V2 확장
  priorityInsights: string[],
  faceCondition: { /* 현재 상태 */ },
  emotionAnalysis: { /* 감정 패턴 */ },
  myeonggung: string,
  migan: string,
  relationshipImpression: string,
  makeupStyleRecommendations: string[],  // 여성용
  leadershipAnalysis: string,            // 남성용
  watchData: { /* 추가 분석 */ }
}
```

### personality-dna (성격 DNA)

#### 입력

- 성향 질문 응답, 프로필, 행동 패턴 요약을 입력으로 사용합니다.

#### 출력

- `FortuneEnvelope<PersonalityDnaData>`

#### 핵심 필드

- `dnaCode`, `title`, `emoji`, `todayHighlight`

#### TypeScript 타입

```typescript
type PersonalityDnaData = {
  dnaCode: string,
  title: string,
  emoji: string,
  todayHighlight: string,
  loveStyle: {
    title: string,
    description: string,
    when_dating: string,
    after_breakup: string
  },
  workStyle: {
    title: string,
    as_boss: string,
    at_company_dinner: string,
    work_habit: string
  },
  dailyMatching: {
    cafe_menu: string,
    netflix_genre: string,
    weekend_activity: string
  },
  compatibility: {
    friend: { mbti: string, description: string },
    lover: { mbti: string, description: string },
    colleague: { mbti: string, description: string }
  },
  funStats: {
    rarity_rank: string,
    celebrity_match: string,
    percentage_in_korea: string
  },
  todayAdvice: string,
  rarityLevel: string,
  socialRanking: number,
  dailyFortune: {
    luckyColor: string,
    luckyNumber: number,
    energyLevel: number,
    recommendedActivity: string,
    caution: string,
    bestMatchToday: string
  }
}
```

### fortune-ootd (오늘의 코디)

#### 입력

- 착장 사진 또는 스타일 선호, 일정/날씨/TPO 맥락을 입력으로 사용합니다.

#### 출력

- `FortuneEnvelope<FortuneOotdData>`

#### 핵심 필드

- `overallScore`, `overallGrade`, `overallComment`, `tpoScore`

#### TypeScript 타입

```typescript
type FortuneOotdData = {
  overallScore: number,     // 1-10 또는 %
  overallGrade: string,     // S/A/B/C
  overallComment: string,
  tpoScore: number,
  tpoFeedback: string,
  categories: {
    colorHarmony: { score, feedback },
    silhouette: { score, feedback },
    styleConsistency: { score, feedback },
    accessories: { score, feedback },
    tpoFit: { score, feedback },
    trendScore: { score, feedback }
  },
  highlights: string[],
  softSuggestions: string[],
  recommendedItems: [{ category, item, reason, emoji }],
  styleKeywords: string[],
  celebrityMatch?: { name, similarity, reason }
}
```

---

## 가족/생활

### fortune-family-relationship (가족 관계)

#### 입력

- 가족 구성, 관계 상태, 현재 갈등/관심사를 입력으로 사용합니다.

#### 출력

- `FortuneEnvelope<FortuneFamilyRelationshipData>`

#### 핵심 필드

- `overallScore`, `relationshipCategories`, `luckyElements`, `communicationAdvice`

#### TypeScript 타입

```typescript
type FortuneFamilyRelationshipData = {
  overallScore: number,
  relationshipCategories: {
    couple: { score, title, description },
    parentChild: { score, title, description },
    siblings: { score, title, description },
    harmony: { score, title, description }
  },
  luckyElements: { direction, color, number, time },
  communicationAdvice: { style, topic, avoid },
  familySynergy: { compatibility, strengthPoints[], improvementAreas[] },
  monthlyFlow: { current, next, advice },
  familyAdvice: { tips[] },
  recommendations: string[],
  warnings: string[],
  specialAnswer: string
}
```

### fortune-family-wealth (가족 재물)

#### 입력

- 가계 상황, 재정 목표, 가족 역할 맥락을 입력으로 사용합니다.

#### 출력

- `FortuneEnvelope<FortuneFamilyWealthData>`

#### 핵심 필드

- `wealthCategories`, `luckyElements`, `monthlyTrend`, `familySynergy`

#### TypeScript 타입

```typescript
type FortuneFamilyWealthData = {
  wealthCategories: { income, savings, investment, stability },
  luckyElements: { /* 행운 아이템 */ },
  monthlyTrend: { best_period, caution_period, overall_trend },
  familySynergy: { /* 가족 재물 하모니 */ },
  monthlyFlow: { /* 월별 흐름 */ },
  familyAdvice: { tips[] },
  recommendations: string[],
  warnings: string[],
  specialAnswer: string
}
```

### fortune-family-children (자녀 운세)

#### 입력

- 자녀 정보, 양육 고민, 가족 환경 정보를 입력으로 사용합니다.

#### 출력

- `FortuneEnvelope<FortuneFamilyChildrenData>`

#### 핵심 필드

- `childAnalysis`, `parentingAdvice`, `educationTips`, `relationshipGuide`

#### TypeScript 타입

```typescript
type FortuneFamilyChildrenData = {
  childAnalysis: { /* 자녀별 분석 */ },
  parentingAdvice: [{ /* 양육 전략 */ }],
  educationTips: string[],
  relationshipGuide: { /* 가족 관계 가이드 */ },
  warnings: string[]
}
```

### fortune-family-change (가족 변화)

#### 입력

- 가족 내 변화 이벤트와 정서적 맥락을 입력으로 사용합니다.

#### 출력

- `FortuneEnvelope<FortuneFamilyChangeData>`

#### 핵심 필드

- `changeAnalysis`, `timing`, `recommendations`, `warnings`

#### TypeScript 타입

```typescript
type FortuneFamilyChangeData = {
  changeAnalysis: { /* 변화 분석 */ },
  timing: { good_period, caution_period, best_month },
  recommendations: string[],
  warnings: string[]
}
```

### fortune-family-health (가족 건강)

#### 입력

- 가족 건강 이슈, 생활 패턴, 관심 증상을 입력으로 사용합니다.

#### 출력

- `FortuneEnvelope<FortuneFamilyHealthData>`

#### 핵심 필드

- `healthAnalysis`, `preventionTips`, `dietRecommendations`, `exerciseGuide`

#### TypeScript 타입

```typescript
type FortuneFamilyHealthData = {
  healthAnalysis: { /* 건강 평가 */ },
  preventionTips: string[],
  dietRecommendations: { /* 영양 가이드 */ },
  exerciseGuide: { /* 운동 가이드 */ },
  warnings: string[]
}
```

### fortune-naming (작명)

#### 입력

- 이름 후보, 한자/음절 선호, 생년월일 같은 작명 입력을 사용합니다.

#### 출력

- `FortuneEnvelope<FortuneNamingData>`

#### 핵심 필드

- `ohaengAnalysis`, `recommendedNames`, `namingTips`, `warnings`

#### TypeScript 타입

```typescript
type FortuneNamingData = {
  ohaengAnalysis: { /* 오행 분석 */ },
  recommendedNames: [{
    rank, koreanName, hanjaName, hanjaMeaning[],
    pronunciationOhaeng, strokeOhaeng,
    totalScore, analysis, compatibility
  }],
  namingTips: string[],
  warnings: string[]
}
```

### fortune-moving (이사운)

#### 입력

- 이사 예정 시점, 지역, 주거 조건, 가족 구성을 입력으로 사용합니다.

#### 출력

- `FortuneEnvelope<FortuneMovingData>`

#### 핵심 필드

- `currentArea`, `targetArea`, `movingPeriod`, `purpose`

#### TypeScript 타입

```typescript
type FortuneMovingData = {
  currentArea: string,
  targetArea: string,
  movingPeriod: string,
  purpose: string,
  direction: string,  // 8방위
  purposeCategory: string,  // 직장/학교/결혼/가족/환경/투자/기타
  concerns: string[]
  // 좌표 기반 또는 지역명 기반 방위 계산
}
```

### fortune-home-fengshui (집 풍수)

#### 입력

- 집 구조, 방향, 공간 배치, 거주 목적 정보를 입력으로 사용합니다.

#### 출력

- `FortuneEnvelope<FortuneHomeFengshuiData>`

#### 핵심 필드

- `overall_analysis`, `baesan_imsu`, `yangtaek_analysis`, `interior_layout`

#### TypeScript 타입

```typescript
type FortuneHomeFengshuiData = {
  overall_analysis: string,
  baesan_imsu: { terrain_type, mountain_presence, water_presence, road_flow, terrain_score },
  yangtaek_analysis: {
    home_direction, direction_meaning,
    door_direction, door_element,
    compatibility, compatibility_reason
  },
  interior_layout: {
    entrance: { analysis, advice },
    living_room: { analysis, advice },
    bedroom: { analysis, advice },
    kitchen: { analysis, advice },
    bathroom: { analysis, advice }
  },
  energy_flow: { qi_circulation, bright_areas, dark_areas, improvement_priority },
  defects_and_solutions: string[],
  lucky_elements: { /* 행운 아이템/색상/방위 */ },
  seasonal_advice: { spring, summer, fall, winter },
  summary: { one_line, keywords[], final_message }
}
```

### fortune-decision (결정 도우미)

#### 입력

- 선택지와 우선순위, 현재 고민 배경을 입력으로 사용합니다.

#### 출력

- `FortuneEnvelope<FortuneDecisionData>`

#### 핵심 필드

- `decisionType`, `question`, `options`, `recommendation`

#### TypeScript 타입

```typescript
type FortuneDecisionData = {
  decisionType: string,  // dating/career/money/wellness/lifestyle/relationship
  question: string,
  options: [{
    option: string,
    pros: string[],
    cons: string[]
  }],
  recommendation: string,
  confidenceFactors: string[],
  nextSteps: string[],
  decisionReceiptId?: string
}
```

### fortune-new-year (신년 운세)

#### 입력

- 생년월일/사주와 연간 목표, 새해 컨텍스트를 입력으로 사용합니다.

#### 출력

- `FortuneEnvelope<FortuneNewYearData>`

#### 핵심 필드

- `overall_score`, `greeting`, `goalFortune`, `sajuAnalysis`

#### TypeScript 타입

```typescript
type FortuneNewYearData = {
  overall_score: number,
  greeting: string,
  goalFortune: {
    goalId, goalLabel, emoji, title, prediction,
    deepAnalysis, bestMonths[], cautionMonths[],
    quarterlyMilestones[], riskAnalysis,
    successFactors[], actionItems[]
  },
  sajuAnalysis: { /* 오행/합 분석 */ },
  monthlyHighlights: [{ /* 12개월 */ }],
  luckyItems: { /* 색상, 숫자, 방위 */ },
  actionPlan: { immediate, shortTerm, longTerm },
  recommendations: string[],
  specialMessage: string
}
```

---

## 특수/엔터테인먼트

### fortune-past-life (전생)

#### 입력

- 사용자 이름, 생년월일/생시, 현재 성별, 프리미엄 여부와 선택적 얼굴 사진(`faceImageBase64`)을 입력으로 사용합니다.

#### 출력

- `FortuneEnvelope<FortunePastLifeData>`

#### 핵심 필드

- `pastLifeStatus`, `story`, `chapters`, `portraitUrl`

#### TypeScript 타입

```typescript
type FortunePastLifeData = {
  id: string,
  fortuneType: 'past-life',
  pastLifeStatus: string,
  pastLifeStatusEn: string,
  pastLifeGender: string,
  pastLifeEra: string,
  pastLifeName: string,
  scenarioId: string,
  scenarioCategory: string,
  scenarioTrait: string,
  plotType: string,
  story: string,
  summary: string,
  chapters: [{
    chapterNumber: number,
    title: string,
    subtitle?: string,
    content: string,
    icon?: string,
    theme?: string
  }],
  portraitUrl: string,
  advice: string,
  score: number,
  faceFeatures?: {
    faceShape?: string,
    eyes?: string,
    nose?: string,
    mouth?: string,
    overallImpression?: string[]
  },
  timestamp: string
}
```

### fortune-celebrity (유명인 궁합)

#### 입력

- 사용자 프로필과 비교 대상 셀럽 식별자를 입력으로 사용합니다.

#### 출력

- `FortuneEnvelope<FortuneCelebrityData>`

#### 핵심 필드

- `overall_score`, `compatibility_grade`, `main_message`, `saju_analysis`

#### TypeScript 타입

```typescript
type FortuneCelebrityData = {
  overall_score: number,
  compatibility_grade: string,
  main_message: string,  // 300-400자
  saju_analysis: { /* 오행, 일주, 합 분석 */ },
  past_life: { connection_type, story, evidence[] },
  destined_timing: { best_year, best_month, timing_reason },
  intimate_compatibility: string,
  detailed_analysis: string,
  strengths: string[],
  challenges: string[],
  recommendations: string[],
  lucky_factors: string[],
  special_message: string
}
```

### fortune-pet-compatibility (반려동물 궁합)

#### 입력

- 반려동물 정보와 보호자 프로필, 관계 맥락을 입력으로 사용합니다.

#### 출력

- `FortuneEnvelope<FortunePetCompatibilityData>`

#### 핵심 필드

- `today_story`, `breed_specific`, `daily_condition`, `owner_bond`

#### TypeScript 타입

```typescript
type FortunePetCompatibilityData = {
  today_story: { opening, morning_chapter, afternoon_chapter, evening_chapter },
  breed_specific: { trait_today, health_watch, grooming_tip },
  daily_condition: { overall_score, mood_prediction, energy_level, energy_description },
  owner_bond: { bond_score, bonding_tip, best_time, communication_hint },
  lucky_items: { color, snack, activity, time, spot },
  pets_voice: { heartfelt_letter, letter_type, secret_confession },
  bonding_mission: { mission_type, title, description, expected_reaction, difficulty },
  health_insight: string,
  activity_recommendation: string,
  emotional_care: string,
  special_tips: string[],
  summary: string,
  greeting: string
}
```

### fortune-match-insight (스포츠 경기)

#### 입력

- 경기 참가 팀/선수, 시즌 맥락, 보조 통계 입력을 사용합니다.

#### 출력

- `FortuneEnvelope<FortuneMatchInsightData>`

#### 핵심 필드

- `prediction`, `favoriteTeamAnalysis`, `opponentAnalysis`, `fortuneElements`

#### TypeScript 타입

```typescript
type FortuneMatchInsightData = {
  prediction: {
    winProbability, confidence,
    keyFactors[], predictedScore, mvpCandidate
  },
  favoriteTeamAnalysis: {
    name, recentForm, strengths[], concerns[], keyPlayer, formEmoji
  },
  opponentAnalysis: { /* 동일 구조 */ },
  fortuneElements: {
    luckyColor, luckyNumber, luckyTime,
    luckyItem, luckySection, luckyAction
  },
  cautionMessage: string
}
```

### fortune-game-enhance (게임 강화)

#### 입력

- 기본 입력은 비어 있고, 선택적으로 `birthDate`, `gender`, `userId`만 받아 시간대/생월 cohort 기준으로 결과를 생성합니다.

#### 출력

- `FortuneEnvelope<FortuneGameEnhanceData>`

#### 핵심 필드

- `lucky_grade`, `enhance_stats`, `lucky_times`, `enhance_roadmap`

#### TypeScript 타입

```typescript
type FortuneGameEnhanceData = {
  fortuneType: 'game-enhance',
  fortune_type: 'game-enhance',
  title: string,
  score: number,
  lucky_grade: 'SSS' | 'SS' | 'S' | 'A' | 'B' | 'C',
  status_message: string,
  enhance_stats: {
    success_aura: number,
    success_aura_desc: string,
    protection_field: number,
    protection_field_desc: string,
    chance_time_active: boolean,
    chance_time_desc: string,
    stack_bonus: 'UP' | 'DOWN' | 'STABLE',
    stack_bonus_desc: string
  },
  lucky_times: {
    golden_hour: string,
    golden_hour_range: string,
    golden_hour_reason: string,
    avoid_time: string,
    avoid_time_reason: string
  },
  enhance_ritual: {
    lucky_spot: string,
    lucky_direction: string,
    lucky_action: string,
    lucky_phrase: string,
    avoid_action: string
  },
  enhance_roadmap: [{
    phase: string,
    action: string,
    tip: string,
    risk_level: 'low' | 'medium' | 'high'
  }],
  lucky_info: {
    lucky_number: number,
    lucky_number_meaning: string,
    lucky_color: string,
    lucky_color_tip: string,
    lucky_food: string,
    lucky_food_reason: string
  },
  warnings: string[],
  encouragement: {
    before_enhance: string,
    on_success: string,
    on_fail: string
  },
  hashtags: string[],
  summary: string,
  content: string,
  advice: string,
  timestamp: string,
  percentile?: number
}
```

### fortune-recommend (추천)

#### 입력

- 현재 관심 카테고리, profile, 최근 행동/선호도를 입력으로 사용합니다.

#### 출력

- `FortuneEnvelope<FortuneRecommendData>`

#### 핵심 필드

- `recommendations`

#### TypeScript 타입

```typescript
type FortuneRecommendData = {
  recommendations: [{
    fortuneType: string,
    reason: string,
    description: string,
    relevance: number,
    icon?: string
  }]
}
```

---

## 공통 계산 / 운영 메모

### Cohort Pool 시스템

- 개인 캐시 이전에 공용 cohort pool을 조회해 비용을 절감합니다.

### Percentile 계산

- `percentile`은 cohort pool 비교 또는 계산 로직이 있는 함수에서만 노출됩니다.

### LLM 설정

- Edge Function은 `LLMFactory.createFromConfig()`와 PromptManager 템플릿을 표준으로 사용합니다.
