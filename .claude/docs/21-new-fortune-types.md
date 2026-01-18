# 신규 인사이트 타입 가이드

> 최종 업데이트: 2025.01.16

## 개요

2024-2025년에 추가된 신규 인사이트 타입들을 정리한 문서입니다.
기존 22개에서 40개로 확장되어 **19개 신규 인사이트**가 추가되었습니다.

---

## 신규 인사이트 목록 (18개)

| 카테고리 | 인사이트 | Edge Function | 토큰 |
|----------|------|---------------|------|
| **가족** | 가족 변화 인사이트 | fortune-family-change | 3 |
| **가족** | 자녀 인사이트 | fortune-family-children | 3 |
| **가족** | 가족 건강 체크 | fortune-family-health | 3 |
| **가족** | 가족 관계 인사이트 | fortune-family-relationship | 3 |
| **가족** | 가족 재물 인사이트 | fortune-family-wealth | 3 |
| **특수** | 전생 분석 | fortune-past-life | 4 |
| **특수** | 셀럽 매칭 | fortune-celebrity | 5 |
| **특수** | 매칭 인사이트 | fortune-match-insight | 4 |
| **특수** | 추천 인사이트 | fortune-recommend | 4 |
| **특수** | 부적 생성 | fortune-talisman | 4 |
| **인터랙티브** | 게임 강화운세 | fortune-game-enhance | 0 (무료) |
| **시즌** | 시험 가이드 | fortune-exam | 4 |
| **시즌** | 신년 인사이트 | fortune-new-year | 2 |
| **건강** | 건강 문서 분석 | fortune-health-document | 3 |
| **환경** | 풍수 인테리어 | fortune-home-fengshui | 5 |
| **환경** | 오늘의 코디 | fortune-ootd | 5 |
| **재물** | 재물 인사이트 | fortune-wealth | 5 |
| **펫** | 펫 궁합 | fortune-pet-compatibility | 5 |
| **사주** | 프리미엄 사주 | fortune-premium-saju | 5 |

---

## 가족 운세 시리즈 (5개)

### 공통 특징
- 사용자 사주 + 가족 구성원 사주 조합 분석
- 프리미엄 전용 (토큰 3개)
- 가족 전체 운세 맥락 제공

### fortune-family-change
```typescript
// 가족 변화운 - 이사, 직장 변경, 학교 등
requiredFields: {
  saju: SajuData,
  familyMembers: FamilyMember[],
  changeType: 'moving' | 'job' | 'school' | 'general'
}

// 응답 구조
{
  overallTiming: string,       // 전체 변화 시기
  memberAnalysis: MemberResult[], // 구성원별 영향
  bestTiming: string,          // 최적 시기
  precautions: string[]        // 주의사항
}
```

### fortune-family-children
```typescript
// 자녀운 - 자녀 교육, 성장, 진로
requiredFields: {
  parentSaju: SajuData,
  childSaju?: SajuData,        // 자녀 사주 (있으면)
  childAge?: number
}

// 응답 구조
{
  educationInsight: string,    // 교육 방향
  talentAnalysis: string,      // 재능 분석
  parentChildRelation: string, // 부모-자녀 관계
  futurePath: string           // 진로 제안
}
```

### fortune-family-health
```typescript
// 가족 건강운
requiredFields: {
  saju: SajuData,
  familyMembers: FamilyMember[],
  focusArea?: 'prevention' | 'recovery' | 'mental'
}
```

### fortune-family-relationship
```typescript
// 가족 관계운 - 갈등 해소, 화목
requiredFields: {
  saju: SajuData,
  familyMembers: FamilyMember[],
  conflictType?: 'sibling' | 'parent' | 'spouse' | 'inlaw'
}
```

### fortune-family-wealth
```typescript
// 가족 재물운 - 가계 재정
requiredFields: {
  saju: SajuData,
  familyMembers: FamilyMember[],
  financialGoal?: 'saving' | 'investment' | 'inheritance'
}
```

---

## 특수 운세 (6개)

### fortune-past-life
```typescript
// 전생 분석 - 윤회/카르마 기반
requiredFields: {
  saju: SajuData,
  birthTime: string  // 정확한 시간 필수
}

// 응답 구조
{
  pastLifeEra: string,         // 전생 시대
  pastLifeRole: string,        // 전생 역할
  karmaLesson: string,         // 이번 생 과제
  soulMission: string,         // 영혼의 미션
  pastLifePortrait?: string    // 전생 초상화 이미지 (프리미엄)
}
```

### fortune-celebrity
```typescript
// 셀럽 매칭 - 유명인과의 궁합
requiredFields: {
  userSaju: SajuData,
  celebrityId: string
}

// 셀럽 데이터는 DB에 사전 등록
// celebrities 테이블: id, name, birthDate, saju, category
```

### fortune-match-insight
```typescript
// 매칭 인사이트 - MBTI + 사주 조합 분석
requiredFields: {
  userSaju: SajuData,
  userMbti: string,
  partnerSaju?: SajuData,
  partnerMbti?: string
}
```

### fortune-recommend
```typescript
// 추천 운세 - AI 기반 맞춤 추천
requiredFields: {
  saju: SajuData,
  recentFortunes: string[],    // 최근 조회한 운세
  interests: string[],          // 관심사
  currentConcern?: string       // 현재 고민
}

// 응답: 추천 운세 리스트 + 이유
{
  recommendations: [
    { type: 'career', reason: '...' },
    { type: 'love', reason: '...' }
  ]
}
```

### fortune-talisman
```typescript
// 부적 생성 - 맞춤형 부적 이미지
requiredFields: {
  saju: SajuData,
  purpose: 'wealth' | 'love' | 'health' | 'success' | 'protection',
  style: 'traditional' | 'modern'
}

// 응답: 부적 이미지 URL + 설명
{
  talismanImage: string,       // 생성된 부적 이미지
  meaning: string,             // 부적의 의미
  usage: string,               // 사용법
  placement: string            // 배치 장소
}
```

### fortune-premium-saju
```typescript
// 프리미엄 사주 - 상세 사주 분석
requiredFields: {
  saju: SajuData,
  analysisDepth: 'standard' | 'detailed' | 'comprehensive'
}

// 기존 saju보다 3배 상세한 분석
// 십성, 신살, 대운, 세운 등 전문적 내용 포함
```

---

## 인터랙티브 운세 (1개)

### fortune-game-enhance
```typescript
// 게임 강화운세 - 범용 강화 성공 기운
// ⚠️ 무료, 입력 없음, 즉시 결과

requiredFields: {
  saju: SajuData,
  // 입력 필드 없음 - 칩 탭 시 즉시 호출
}

// 응답 구조
{
  score: number;                    // 0-100
  luckyGrade: 'SSS'|'SS'|'S'|'A'|'B'|'C';
  statusMessage: string;            // "오늘 강화, 해도 됩니다!"

  enhanceStats: {
    successAura: number;            // 성공 기운 %
    protectionField: number;        // 파괴 방어력 %
    chanceTimeActive: boolean;      // 찬스타임 여부
    stackBonus: 'UP'|'DOWN'|'STABLE';
  };

  luckyTimes: {
    goldenHour: string;             // "14:22"
    goldenHourRange: string;        // "14:00-16:00"
    avoidTime: string;              // "03:00-05:00"
  };

  enhanceRitual: {
    luckySpot: string;              // NPC 위치
    luckyDirection: string;         // 캐릭터 방향
    luckyAction: string;            // 점프, 앉기 등
    luckyPhrase: string;            // 주문
  };

  enhanceRoadmap: Array<{
    phase: string;
    action: string;
    tip: string;
    riskLevel: 'LOW'|'MEDIUM'|'HIGH';
  }>;

  luckyInfo: {
    luckyNumber: number;
    luckyColor: string;
    luckyFood: string;
  };

  warnings: string[];
  encouragement: {
    beforeEnhance: string;
    onSuccess: string;
    onFail: string;
  };
}
```

**특징**:
- 무료 (토큰 0개) - 블러 없음
- 입력 필드 없음 - 범용 강화운
- SSS~C 등급 시스템으로 도파민 자극
- 복주머니 후원 기능 (수익화)
- 게임 미신 + 사주 오행 융합

---

## 시즌 운세 (2개)

### fortune-exam
```typescript
// 시험운 - 수능, 자격증, 면접
requiredFields: {
  saju: SajuData,
  examType: 'college' | 'certification' | 'job_interview' | 'promotion',
  examDate: Date,
  subject?: string
}

// 응답 구조
{
  overallLuck: number,         // 전체 운 (1-100)
  bestStudyTime: string,       // 최적 공부 시간대
  luckyItems: string[],        // 시험 당일 행운 아이템
  precautions: string[],       // 주의사항
  mentalAdvice: string         // 멘탈 관리 조언
}
```

### fortune-new-year
```typescript
// 신년운세 - 연간 운세
requiredFields: {
  saju: SajuData,
  targetYear: number  // 2025, 2026 등
}

// 응답: 12개월별 운세 + 연간 종합
{
  yearOverview: string,
  monthlyFortunes: MonthlyFortune[12],
  luckyMonths: number[],
  cautiousMonths: number[],
  yearlyTheme: string
}
```

---

## 건강 운세 (1개)

### fortune-health-document
```typescript
// 건강 문서 분석 - Apple Watch / 건강 데이터 연동
requiredFields: {
  saju: SajuData,
  healthData: {
    bloodPressure?: { systolic: number, diastolic: number },
    heartRate?: number,
    steps?: number,
    sleep?: { duration: number, quality: string },
    weight?: number
  }
}

// 사주 + 실제 건강 데이터 조합 분석
{
  healthInsight: string,       // 건강 인사이트
  sajuHealthTendency: string,  // 사주 기반 건강 경향
  recommendations: string[],    // 맞춤 건강 조언
  riskAreas: string[]          // 주의 영역
}
```

---

## 환경 운세 (2개)

### fortune-home-fengshui
```typescript
// 풍수 인테리어 - 집/방 배치 조언
requiredFields: {
  saju: SajuData,
  roomType: 'bedroom' | 'living' | 'office' | 'entrance' | 'kitchen',
  houseDirection?: string,     // 집 방향 (선택)
  currentIssue?: string        // 현재 고민 (재물, 건강, 관계 등)
}

// 응답 구조
{
  overallEnergy: string,       // 전체 기운
  colorRecommendation: string[], // 추천 색상
  furniturePlacement: string,  // 가구 배치
  luckyItems: string[],        // 행운 아이템
  avoidItems: string[]         // 피해야 할 것
}
```

### fortune-ootd
```typescript
// 오늘의 코디 - 일일 패션 추천
requiredFields: {
  saju: SajuData,
  gender: 'male' | 'female',
  occasion?: 'work' | 'date' | 'interview' | 'casual',
  season: 'spring' | 'summer' | 'fall' | 'winter'
}

// 응답: 색상 + 스타일 + 악세서리 조합
{
  luckyColors: string[],       // 행운 색상
  styleRecommendation: string, // 스타일 제안
  accessories: string[],       // 악세서리
  avoidColors: string[],       // 피할 색상
  ootdImage?: string           // 코디 이미지 (프리미엄)
}
```

---

## 재물/펫 운세 (2개)

### fortune-wealth
```typescript
// 재물운 - 투자, 저축, 재정 관리
requiredFields: {
  saju: SajuData,
  investmentType: 'stock' | 'realestate' | 'crypto' | 'savings' | 'general',
  riskTolerance: 'low' | 'medium' | 'high'
}

// 응답 구조
{
  wealthTiming: string,        // 재물운 시기
  investmentAdvice: string,    // 투자 조언
  luckyNumbers: number[],      // 행운 숫자
  luckyDirections: string[],   // 행운 방향
  monthlyForecast: string      // 월별 전망
}
```

### fortune-pet-compatibility
```typescript
// 펫 궁합 - 반려동물과의 궁합
requiredFields: {
  userSaju: SajuData,
  petType: 'dog' | 'cat' | 'bird' | 'fish' | 'hamster' | 'rabbit',
  petBreed?: string,
  petBirthDate?: Date
}

// 응답 구조
{
  compatibilityScore: number,  // 궁합 점수 (1-100)
  relationshipType: string,    // 관계 유형
  communicationTips: string[], // 소통 팁
  careAdvice: string[],        // 케어 조언
  luckyActivities: string[]    // 함께하면 좋은 활동
}
```

---

## 프리미엄 전용 운세

| 운세 | 토큰 | 특징 |
|------|------|------|
| fortune-celebrity | 5 | 셀럽 DB 필요 |
| fortune-wealth | 5 | 상세 투자 분석 |
| fortune-pet-compatibility | 5 | 펫 사주 분석 |
| fortune-ootd | 5 | AI 이미지 생성 |
| fortune-home-fengshui | 5 | 전문 풍수 분석 |
| fortune-premium-saju | 5 | 전문가급 사주 |
| fortune-past-life | 4 | 전생 초상화 |
| fortune-talisman | 4 | 부적 이미지 생성 |

---

## 구현 가이드

### 새 운세 추가 시 체크리스트

1. **Edge Function 생성**
   ```bash
   supabase functions new fortune-{type}
   ```

2. **LLMFactory 프롬프트 추가**
   ```typescript
   // _shared/prompts/templates/{type}.ts
   export const {TYPE}_PROMPT = `...`;
   ```

3. **Flutter 모델 생성**
   ```dart
   // lib/features/fortune/domain/models/conditions/{type}_conditions.dart
   class {Type}FortuneConditions extends FortuneConditions
   ```

4. **서비스 연동**
   ```dart
   // UnifiedFortuneService에 타입 등록
   ```

5. **UI 페이지 생성**
   ```dart
   // lib/features/fortune/presentation/pages/{type}_fortune_page.dart
   ```

6. **라우트 등록**
   ```dart
   // lib/core/router/fortune_routes.dart
   ```

7. **추천 칩 추가**
   ```dart
   // survey_configs.dart에 추가
   ```

---

## 관련 문서

- [05-fortune-system.md](05-fortune-system.md) - 운세 시스템 전체
- [06-llm-module.md](06-llm-module.md) - Edge Function & LLM
- [09-edge-function-conventions.md](09-edge-function-conventions.md) - Edge Function 규칙
