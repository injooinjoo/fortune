# 관상 시스템 가이드 (Face Reading System)

## 개요

AI 기반 얼굴 분석 시스템의 2-30대 여성 타겟 리디자인 문서.

**핵심 가치 전환**: 자기계발 ❌ → 위로·공감·공유 ✅

---

## 앱 스토어 컴플라이언스

### 외부 포지셔닝 (App Store Review 대응)

| 사용 O | 사용 X |
|--------|--------|
| AI 얼굴 분석 | 관상, 운세 |
| 자기발견 | 점술, fortune |
| 성격 분석 | horoscope |
| 인사이트 | 예언, prediction |
| 셀프케어 | 팔자, 사주 |

**카테고리**: Lifestyle (Primary), Health & Fitness (Secondary)

### 내부 개발 vs 외부 표현

| 내부 코드 | 외부 UI/마케팅 |
|-----------|---------------|
| `face-reading` | AI 얼굴 분석 |
| `fortuneType` | analysisType |
| `관상 결과` | 분석 결과 |
| `운세` | 인사이트 |
| `점수` | 특성 지수 |

---

## 타겟 오디언스

### 1차 타겟: 2-30대 여성

**특성**:
- SNS 활발 (인스타, 틱톡)
- 자기 탐색에 관심
- 불안감 해소 니즈
- 공유 욕구 강함

**니즈**:
- "나는 어떤 사람일까?" 궁금증
- 연애/결혼/면접 불안 해소
- 친구들과 공유할 콘텐츠
- 예쁜 UI/공유 카드

### 2차 타겟: 20-40대 남성

**특성**:
- 실용적 정보 선호
- 커리어/재물 관심
- 공유보다 개인 소비

**니즈**:
- 직업 적합성 분석
- 리더십 유형 파악
- 재물운/성공 잠재력

---

## 말투 가이드 (CRITICAL)

### 변환 규칙

| 변경 전 ❌ | 변경 후 ✅ |
|-----------|-----------|
| ~입니다 | ~예요, ~이에요 |
| ~됩니다 | ~돼요, ~해 보세요 |
| 분석 결과... | 당신의 눈에서 느껴지는 건... |
| ~해야 합니다 | ~하면 좋을 것 같아요 |
| 결론적으로 | 정리하면 |
| 권고드립니다 | 추천해 드려요 |

### 예시 변환

**Before** (정보 전달형):
```
재물운이 좋습니다. 코의 형태가 안정적이며,
재백궁의 발달로 인해 재물 축적 능력이 있습니다.
```

**After** (친구처럼 대화형):
```
재물 복이 있어 보여요! 특히 코가 안정적이라서
돈을 차근차근 모으는 스타일이에요.
급하게 큰 돈을 쫓기보다 꾸준히 쌓아가는 게 잘 맞아요.
```

### 톤 원칙

1. **위로 우선**: 단점보다 장점을 먼저
2. **공감 표현**: "~처럼 느껴져요", "~일 수도 있어요"
3. **부드러운 조언**: "~해 보세요" (명령 아님)
4. **긍정 마무리**: 항상 희망적인 메시지로 끝내기

---

## 성별 기반 콘텐츠 분기

### 여성 전용 콘텐츠

```typescript
if (userGender === 'female') {
  // 강조 영역
  prioritize: ['연애운', '배우자운', '면접 인상', '매력 포인트']

  // 추가 분석
  include: ['makeupStyleRecommendations', 'charmFeature']

  // 톤 조정
  tone: '더 친근하고 감성적'
}
```

**포함 항목**:
- 매력 부위 강조
- 메이크업 스타일 추천
- 연애/결혼 적령기
- 어울리는 상대 유형
- 면접/미팅 인상 분석

### 남성 전용 콘텐츠

```typescript
if (userGender === 'male') {
  // 강조 영역
  prioritize: ['직업운', '재물운', '리더십', '신뢰감']

  // 추가 분석
  include: ['leadershipAnalysis', 'careerAdvice']

  // 톤 조정
  tone: '실용적이고 구체적'
}
```

**포함 항목**:
- 리더십 유형 분석
- 팀 역할 추천
- 커리어 조언
- 재물 관리 스타일
- 신뢰감 지수

---

## V2 응답 스키마

### 우선순위 인사이트 (무료)

```typescript
interface PriorityInsight {
  category: 'first_impression' | 'charm_point' | 'today_advice'
  icon: string      // 이모지
  title: string     // 20자 이내
  description: string  // 80자 이내, 친근한 말투
  score: number     // 60-98
}
```

**용도**: 결과 페이지 상단에 3가지 핵심 포인트 표시

### 얼굴 컨디션 (무료: 요약 / 프리미엄: 상세)

```typescript
interface FaceCondition {
  bloodCirculation: number   // 혈색 0-100
  puffiness: number          // 붓기 0-100 (낮을수록 좋음)
  fatigueLevel: number       // 피로도 0-100 (낮을수록 좋음)
  overallConditionScore: number
  conditionMessage: string   // 위로하는 메시지
  tips: string[]             // 피부 관리 팁
}
```

### 표정 감정 분석 (무료: 요약 / 프리미엄: 상세)

```typescript
interface EmotionAnalysis {
  smilePercentage: number
  tensionPercentage: number
  neutralPercentage: number
  relaxedPercentage: number
  dominantEmotion: 'smile' | 'tension' | 'neutral' | 'relaxed'
  emotionMessage: string
  impressionAnalysis: {
    trustScore: number
    approachabilityScore: number
    charismaScore: number
    overallImpression: string
  }
}
```

### Watch 경량 데이터 (무료)

```typescript
interface WatchData {
  luckyDirection: string     // 동|서|남|북|동북|동남|서북|서남
  luckyColor: string
  luckyColorHex: string
  luckyTimePeriods: string[] // ["오전 9-11시", "오후 3-5시"]
  dailyReminderMessage: string  // 30자 이내 응원 메시지
}
```

---

## 무료/프리미엄 분기

### 무료 공개 섹션

| 섹션 | 설명 |
|------|------|
| priorityInsights | 핵심 인사이트 3가지 |
| faceCondition_preview | 컨디션 점수 + 메시지 |
| emotionAnalysis_preview | 지배적 감정 + 메시지 |
| myeonggung_preview | 명궁 점수 + 요약 |
| migan_preview | 미간 점수 + 요약 |
| simplifiedOgwan | 오관 요약 |
| simplifiedSibigung | 십이궁 요약 |
| watchData | Watch 경량 데이터 |

### 프리미엄 전용 섹션

| 섹션 | 설명 |
|------|------|
| faceCondition (상세) | 혈색/붓기/피로도 + 팁 |
| emotionAnalysis (상세) | 감정 % + 인상 분석 |
| myeonggung (상세) | 명궁 상세 + 강점/약점/조언 |
| migan (상세) | 미간 상세 + 성격/조언 |
| relationshipImpression | 타인이 보는 나 |
| makeupStyleRecommendations | 메이크업 추천 (여성) |
| leadershipAnalysis | 리더십 분석 (남성) |
| ogwan (전체) | 오관 전체 분석 |
| sibigung (전체) | 십이궁 전체 분석 |
| compatibility | 이상형 관상 |
| marriagePrediction | 결혼 적령기 |

---

## 결과 페이지 구조

### 순서 (V2 기준)

```
1. 우선순위 인사이트 (3가지) - 항상 펼침
2. 오늘의 컨디션 카드 - 접힘
3. 표정 감정 분석 - 접힘
4. 명궁 분석 - 접힘 (기존: 펼침 → 변경됨)
5. 미간 분석 - 접힘
6. 요약형 오관 - 접힘 (상세는 펼치면 표시)
7. 요약형 십이궁 - 접힘
8. 관계 인상 분석 - 접힘, 프리미엄
9. 스타일 추천 (성별별) - 접힘, 프리미엄
```

### 위젯 매핑

| 순서 | 위젯 | 기본 상태 |
|------|------|----------|
| 1 | `KeyPointsSummaryCard` | Expanded |
| 2 | `FaceConditionCard` | Collapsed |
| 3 | `EmotionRecognitionCard` | Collapsed |
| 4 | `MyeonggungDetailCard` | Collapsed |
| 5 | `MiganDetailCard` | Collapsed |
| 6 | `ExpandableSectionCard` (오관) | Collapsed |
| 7 | `ExpandableSectionCard` (십이궁) | Collapsed |
| 8 | `RelationshipImpressionCard` | Collapsed |
| 9 | `MakeupStyleCard` / `LeadershipCard` | Collapsed |

---

## 프롬프트 템플릿

### 위치

```
supabase/functions/_shared/prompts/templates/face-reading.ts
```

### 주요 변수

| 변수 | 타입 | 설명 |
|------|------|------|
| userName | string | 사용자 이름 |
| userGender | string | male/female |
| userAgeGroup | string | 20s/30s/40s+ |
| today | string | 오늘 날짜 |
| isFemale | boolean | 여성 여부 (분기용) |

### 조건부 렌더링

```
{{#if isFemale}}
  여성 전용 콘텐츠
{{else}}
  남성 전용 콘텐츠
{{/if}}
```

---

## Edge Function API

### Endpoint

```
POST /fortune-face-reading
```

### Request Body

```typescript
{
  userId: string
  image?: string           // Base64
  instagram_url?: string
  analysis_source: 'camera' | 'gallery' | 'instagram'
  userName?: string
  userGender: 'male' | 'female'
  userAgeGroup?: '20s' | '30s' | '40s+'
  isPremium: boolean
  useV2: boolean           // V2 스키마 사용 (기본: true)
}
```

### Response (V2)

```typescript
{
  fortuneType: 'face-reading'
  version: 2
  mainFortune: string
  luckScore: number
  scoreBreakdown: { ogwan, samjeong, sibigung, specialFeatures }

  details: {
    // 무료 섹션
    priorityInsights: PriorityInsight[]
    faceCondition_preview: { score, message }
    emotionAnalysis_preview: { dominantEmotion, message }
    simplifiedOgwan: SimplifiedOgwanItem[]
    simplifiedSibigung: SimplifiedSibigungItem[]
    watchData: WatchData

    // 프리미엄 섹션
    faceCondition: FaceCondition
    emotionAnalysis: EmotionAnalysis
    myeonggung: MyeonggungAnalysis
    migan: MiganAnalysis
    relationshipImpression: RelationshipImpression
    makeupStyleRecommendations?: MakeupStyleRecommendations  // 여성
    leadershipAnalysis?: LeadershipAnalysis                   // 남성
    // ... 기존 필드들
  }

  userGender: string
  userAgeGroup: string
  timestamp: string
  isBlurred: boolean
  blurredSections: string[]
}
```

---

## SNS 공유 가이드

### 공유 카드 디자인

**제목**: "오늘의 얼굴 운세" ❌ → "오늘의 나" ✅

**비율**: 1:1 (인스타그램 최적화)

**포함 요소**:
- 핵심 인사이트 1개
- 매력 포인트
- 감성 문구
- 앱 로고 (작게)

**제외 요소**:
- 점수 (숫자 강조 X)
- "운세", "관상" 단어
- 상세 분석 내용

### 공유 텍스트 템플릿

```
✨ 오늘의 나 발견 ✨

{첫인상 한 줄}
나의 매력 포인트: {매력 부위}

#셀프디스커버리 #AI분석 #오늘의나
```

---

## 개인정보 보호

### 사진 처리 정책

```dart
// 프라이버시 배너 메시지
"사진은 분석 후 즉시 삭제되며, 서버에 저장되지 않아요."
```

### 데이터 저장

| 저장 O | 저장 X |
|--------|--------|
| 분석 결과 (JSON) | 원본 사진 |
| 특징 요약 (text) | 얼굴 이미지 |
| 점수/통계 | Base64 데이터 |

### 면책 조항

```dart
// 결과 페이지 하단 표시
"이 분석은 AI 기술을 활용한 엔터테인먼트 콘텐츠입니다.
실제 성격이나 미래를 예측하는 것이 아닙니다."
```

---

## 주요 파일

### Flutter

| 파일 | 설명 |
|------|------|
| `lib/features/fortune/domain/models/face_reading_result_v2.dart` | V2 모델 |
| `lib/features/fortune/domain/models/face_condition.dart` | 컨디션 모델 |
| `lib/features/fortune/domain/models/emotion_analysis.dart` | 감정 분석 모델 |
| `lib/features/fortune/presentation/pages/face_reading_fortune/` | 페이지 & 위젯 |
| `lib/features/fortune/presentation/providers/face_reading_state_notifier.dart` | 상태 관리 |

### Supabase

| 파일 | 설명 |
|------|------|
| `supabase/functions/fortune-face-reading/index.ts` | Edge Function |
| `supabase/functions/_shared/prompts/templates/face-reading.ts` | 프롬프트 템플릿 |

---

## 관련 문서

- [05-fortune-system.md](05-fortune-system.md) - 운세 시스템 전반
- [06-llm-module.md](06-llm-module.md) - LLM 모듈
- [03-ui-design-system.md](03-ui-design-system.md) - UI 디자인 시스템
- [docs/app_store_submission.md](/docs/app_store_submission.md) - 앱 스토어 제출
