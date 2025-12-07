# 시험 운세 개선 기획서

## 문제 분석

### 현재 상태 vs 비교 대상

| 항목 | 시험 운세 (현재) | 재능 운세 (비교) |
|------|-----------------|-----------------|
| 데이터 필드 수 | 9개 | 15+ 개 |
| 구조화된 섹션 | 단순 텍스트 | 계층적 구조 (배열, 객체) |
| 시각적 요소 | 점수 원형만 | 레이더차트, 타임라인, 프로그레스바 |
| 실행 가능한 계획 | 없음 | 7일 실행 계획, 체크리스트 |
| 개인화 수준 | 낮음 | 높음 (멘탈모델, 학습전략) |

### 근본 원인

1. **Edge Function 미구현**: `fortune-exam` 함수가 기본적인 데이터만 반환
2. **데이터 구조 빈약**: 9개 필드 vs 재능운세 15+ 필드
3. **시험 도메인 특화 부족**: 범용적 조언만 제공
4. **시각적 표현 단조로움**: 단순 텍스트 블록

---

## 유저가 실제로 원하는 것

### 1. 시험 준비 계획 (가장 중요)

```
"D-30일 남았는데, 지금부터 뭘 해야 할지 모르겠어요"
```

**필요 데이터:**
- `studyPlan[]` - 주차별/일별 학습 계획
- `focusAreas[]` - 집중해야 할 과목/영역
- `weaknessAnalysis` - 약점 분석 및 보완 전략

### 2. 시험 당일 전략

```
"시험 당일에 어떻게 해야 좋은 결과가 나올까요?"
```

**필요 데이터:**
- `examDayChecklist[]` - 당일 체크리스트
- `timeManagement` - 시간 배분 전략
- `mentalTips` - 멘탈 관리 조언
- `luckyTimeslots` - 집중력 좋은 시간대

### 3. 합격 가능성 분석

```
"현재 내 상태로 합격할 수 있을까요?"
```

**필요 데이터:**
- `passRatePrediction` - 합격 확률 예측
- `competitorAnalysis` - 경쟁자 대비 위치
- `strengthWeaknessRadar` - 6각형 역량 분석

### 4. 동기부여 & 응원

```
"힘들 때 마음을 다잡을 수 있는 메시지가 필요해요"
```

**필요 데이터:**
- `motivationalQuote` - 응원 메시지
- `successStory` - 비슷한 상황 합격 사례
- `dailyAffirmation` - 오늘의 다짐

---

## 개선안: 데이터 구조

### 신규 FortuneResult.data 구조

```typescript
interface ExamFortuneData {
  // === 기본 정보 (항상 공개) ===
  title: string;                    // "2025 수능 합격 운세"
  score: number;                    // 종합 점수 (0-100)
  overall_fortune: string;          // 종합 운세 요약
  exam_keyword: string;             // "합격", "노력필요", "대박"

  // === 합격 분석 (프리미엄) ===
  passAnalysis: {
    probability: number;            // 합격 확률 (%)
    rating: string;                 // "매우 높음" | "높음" | "보통" | "노력 필요"
    insight: string;                // 상세 분석
    comparisonToAverage: string;    // 평균 대비 위치
  };

  // === 역량 육각형 (프리미엄) ===
  hexagonScores: {
    concentration: number;          // 집중력
    memoryRetention: number;        // 암기력
    problemSolving: number;         // 문제해결력
    timeManagement: number;         // 시간관리
    stressManagement: number;       // 스트레스 관리
    examStrategy: number;           // 시험 전략
  };

  // === D-Day 맞춤 계획 (프리미엄) ===
  studyPlan: {
    daysRemaining: number;          // D-Day 까지 남은 일수
    phase: string;                  // "초반집중" | "중반심화" | "막판스퍼트" | "마무리정리"
    weeklyGoals: Array<{
      week: string;                 // "1주차", "2주차"
      focus: string;                // 주요 목표
      subjects: string[];           // 집중 과목
      dailyHours: number;           // 권장 학습 시간
      milestone: string;            // 마일스톤
    }>;
  };

  // === 과목별 전략 (프리미엄) ===
  subjectStrategy: Array<{
    subject: string;                // "국어", "수학", "영어"
    priority: number;               // 우선순위 (1-5)
    currentLevel: string;           // "상" | "중" | "하"
    targetLevel: string;            // 목표 레벨
    strategy: string;               // 공부 전략
    recommendedMaterials: string[]; // 추천 교재/강의
    expectedImprovement: string;    // 예상 향상도
  }>;

  // === 시험 당일 전략 (프리미엄) ===
  examDayStrategy: {
    morningRoutine: string[];       // 아침 루틴
    checklist: string[];            // 체크리스트
    timeAllocation: {               // 시간 배분
      [subject: string]: string;
    };
    mentalTips: string[];           // 멘탈 관리
    luckyTimeslots: string[];       // 행운의 시간대
    emergencyTips: string[];        // 긴급 상황 대처
  };

  // === 약점 보완 (프리미엄) ===
  weaknessAnalysis: {
    identifiedWeaknesses: string[]; // 파악된 약점
    rootCause: string;              // 근본 원인
    improvementPlan: string;        // 개선 계획
    practiceExercises: string[];    // 연습 문제 유형
  };

  // === 스트레스 관리 (프리미엄) ===
  mentalWellness: {
    stressLevel: string;            // 예상 스트레스 레벨
    copingStrategies: string[];     // 대처 전략
    breakRecommendations: string;   // 휴식 권장사항
    motivationalMessage: string;    // 동기부여 메시지
  };

  // === 행운 아이템 (프리미엄) ===
  luckyItems: {
    color: string;                  // 행운의 색상
    number: number;                 // 행운의 숫자
    direction: string;              // 행운의 방향
    item: string;                   // 행운의 물건
    food: string;                   // 시험 전 추천 음식
    music: string;                  // 추천 음악/BGM
  };

  // === 성공 예언 (프리미엄) ===
  successPrediction: {
    bestDays: string[];             // 시험운이 좋은 날
    peakPerformanceTime: string;    // 최고 컨디션 시간
    luckySection: string;           // 행운의 문제 영역
    specialMessage: string;         // 특별 메시지
  };
}
```

---

## 개선안: UI 구성

### 결과 페이지 구조

```
┌─────────────────────────────────────┐
│  🎓 시험 운세 결과                    │
│  D-30 | 수능 | 목표: 1등급            │
├─────────────────────────────────────┤
│  ┌───────────────────────────────┐  │
│  │    [종합 점수 게이지]           │  │ ← 항상 공개
│  │         85점                   │  │
│  │    "합격이 보입니다!"           │  │
│  └───────────────────────────────┘  │
├─────────────────────────────────────┤
│  📊 역량 분석 (육각형 차트)          │  │ ← 프리미엄
│  ┌───────────────────────────────┐  │
│  │      집중력 85                 │  │
│  │   암기력      문제해결          │  │
│  │      [레이더 차트]             │  │
│  │   시간관리    스트레스          │  │
│  │      시험전략 78               │  │
│  └───────────────────────────────┘  │
├─────────────────────────────────────┤
│  📅 D-Day 학습 계획                  │  │ ← 프리미엄
│  ┌───────────────────────────────┐  │
│  │ [타임라인 UI]                  │  │
│  │ 1주차: 기본 개념 정리           │  │
│  │ 2주차: 문제풀이 집중            │  │
│  │ 3주차: 약점 보완               │  │
│  │ 4주차: 실전 모의고사           │  │
│  └───────────────────────────────┘  │
├─────────────────────────────────────┤
│  📚 과목별 전략                      │  │ ← 프리미엄
│  ┌───────────────────────────────┐  │
│  │ 국어 ⭐⭐⭐⭐ (우선순위 높음)     │  │
│  │ - 비문학 독해력 강화            │  │
│  │ - 추천: EBS 수능특강            │  │
│  │                                │  │
│  │ 수학 ⭐⭐⭐ (보통)               │  │
│  │ - 킬러문항 스킵 전략            │  │
│  │ - 추천: 수학의 정석             │  │
│  └───────────────────────────────┘  │
├─────────────────────────────────────┤
│  🗓️ 시험 당일 체크리스트             │  │ ← 프리미엄
│  ┌───────────────────────────────┐  │
│  │ ☐ 수험표 챙기기                │  │
│  │ ☐ 아침 6시 기상                │  │
│  │ ☐ 가벼운 스트레칭              │  │
│  │ ☐ 따뜻한 물 마시기             │  │
│  │ ☐ 시험장 30분 전 도착          │  │
│  └───────────────────────────────┘  │
├─────────────────────────────────────┤
│  💪 멘탈 관리                        │  │ ← 프리미엄
│  ┌───────────────────────────────┐  │
│  │ "당신의 노력은 배신하지 않습니다"│  │
│  │                                │  │
│  │ 예상 스트레스: 중간             │  │
│  │ 대처법: 심호흡, 5분 명상        │  │
│  └───────────────────────────────┘  │
├─────────────────────────────────────┤
│  🍀 행운 아이템                      │  │ ← 프리미엄
│  ┌───────────────────────────────┐  │
│  │ 🎨 파란색  🔢 7  🧭 동쪽        │  │
│  │ 📝 새 샤프펜슬  🍫 초콜릿       │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

---

## 구현 우선순위

### Phase 1: 데이터 확장 (필수)

1. **Edge Function 구현/개선**: `fortune-exam` 전면 개편
2. **프롬프트 설계**: 시험 도메인 특화 LLM 프롬프트
3. **데이터 모델**: FortuneResult 확장

### Phase 2: UI 개선 (중요)

1. **레이더 차트**: 역량 분석 시각화
2. **타임라인 UI**: 학습 계획 표시
3. **체크리스트 UI**: 인터랙티브 체크박스
4. **프로그레스 바**: 과목별 수준 표시

### Phase 3: 개인화 강화 (향후)

1. **학습 기록 연동**: 실제 공부 시간 추적
2. **리마인더**: 학습 계획 알림
3. **모의고사 점수 입력**: 예측 정확도 향상

---

## 예상 효과

| 지표 | 현재 | 개선 후 예상 |
|------|------|-------------|
| 결과 페이지 체류 시간 | 30초 | 2분+ |
| 광고 시청률 | 40% | 70%+ |
| 재방문율 | 10% | 40%+ |
| 사용자 만족도 | 낮음 | 높음 |

---

## 작업 체크리스트

- [ ] Phase 1: Edge Function `fortune-exam` 전면 개편
- [ ] Phase 1: LLM 프롬프트 설계 (시험 도메인 특화)
- [ ] Phase 1: FortuneResult 데이터 구조 확장
- [ ] Phase 2: 레이더 차트 위젯 구현
- [ ] Phase 2: 타임라인 UI 위젯 구현
- [ ] Phase 2: 체크리스트 UI 위젯 구현
- [ ] Phase 2: lucky_exam_fortune_page.dart UI 리뉴얼
- [ ] Phase 3: 학습 기록 연동 기능

---

## 관련 문서

- [05-fortune-system.md](05-fortune-system.md) - 운세 시스템 아키텍처
- [06-llm-module.md](06-llm-module.md) - LLM 모듈 가이드
- [03-ui-design-system.md](03-ui-design-system.md) - UI 디자인 시스템
