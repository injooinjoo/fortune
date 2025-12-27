# LLM 모듈 가이드 (Edge Function)

## 개요

모든 Supabase Edge Function에서 LLM 호출 시 반드시 `_shared/llm` 모듈을 사용합니다.

**목적**:
- Provider 전환이 환경변수 변경만으로 가능
- 비용 절감 (Gemini 전환 시 ~70%)
- 프롬프트 중앙 관리

---

## 올바른 사용법

```typescript
// 올바른 방법: LLM 모듈 사용
import { LLMFactory } from '../_shared/llm/factory.ts'
import { PromptManager } from '../_shared/prompts/manager.ts'

// 1. 설정 기반 LLM Client 생성 (Provider 자동 선택)
const llm = LLMFactory.createFromConfig('fortune-type')

// 2. 프롬프트 템플릿 사용
const promptManager = new PromptManager()
const systemPrompt = promptManager.getSystemPrompt('fortune-type')
const userPrompt = promptManager.getUserPrompt('fortune-type', params)

// 3. LLM 호출 (Provider 무관)
const response = await llm.generate([
  { role: 'system', content: systemPrompt },
  { role: 'user', content: userPrompt }
], {
  temperature: 1,
  maxTokens: 8192,
  jsonMode: true
})

console.log(`✅ ${response.provider}/${response.model} - ${response.latency}ms`)
```

---

## 절대 하지 말아야 할 것

```typescript
// WRONG - OpenAI/Gemini API 직접 호출 금지
const openaiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${Deno.env.get('OPENAI_API_KEY')}`,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    model: 'gpt-4o-mini',  // 하드코딩!
    // ...
  })
})

// WRONG - 프롬프트 하드코딩 금지
const prompt = '당신은 운세 전문가입니다...'  // 템플릿 사용!
```

---

## Provider 전환 방법

코드 수정 없이 환경변수만 변경:

```bash
# Gemini로 전환
supabase secrets set LLM_PROVIDER=gemini
supabase secrets set LLM_DEFAULT_MODEL=gemini-2.0-flash-exp

# OpenAI로 전환
supabase secrets set LLM_PROVIDER=openai
supabase secrets set LLM_DEFAULT_MODEL=gpt-4o-mini

# 재배포
supabase functions deploy fortune-{type}
```

---

## Edge Function 작성 체크리스트

새로운 운세 Edge Function 작성 시 **반드시 확인**:

- [ ] `LLMFactory.createFromConfig()` 사용
- [ ] `PromptManager` 사용 (프롬프트 템플릿화)
- [ ] `llm.generate()` 호출 (Provider 무관)
- [ ] `jsonMode: true` 옵션 설정
- [ ] 성능 모니터링 로그 추가 (`response.latency`, `response.usage`)

---

## Edge Function 표준 구조

```typescript
// supabase/functions/fortune-{type}/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { LLMFactory } from '../_shared/llm/factory.ts'
import { PromptManager } from '../_shared/prompts/manager.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // 1. CORS preflight 처리
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 2. 요청 파싱
    const { userId, birthDate, birthTime, gender, ...params } = await req.json()

    // 3. 입력 검증
    if (!userId || !birthDate) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 4. LLM 클라이언트 생성
    const llm = LLMFactory.createFromConfig('fortune-{type}')
    const promptManager = new PromptManager()

    // 5. 프롬프트 생성
    const systemPrompt = promptManager.getSystemPrompt('fortune-{type}')
    const userPrompt = promptManager.getUserPrompt('fortune-{type}', {
      birthDate,
      birthTime,
      gender,
      ...params
    })

    // 6. LLM 호출
    const response = await llm.generate([
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userPrompt }
    ], {
      temperature: 1,
      maxTokens: 8192,
      jsonMode: true
    })

    // 7. 성능 로그
    console.log(`✅ ${response.provider}/${response.model} - ${response.latency}ms`)

    // 8. 응답 파싱 및 검증
    const fortuneResult = JSON.parse(response.content)

    // 9. 응답 반환
    return new Response(
      JSON.stringify({
        success: true,
        data: fortuneResult,
        meta: {
          provider: response.provider,
          model: response.model,
          latency: response.latency,
        }
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('❌ Error:', error.message)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
```

---

## 표준 응답 형식 (CRITICAL)

모든 Edge Function은 **반드시** 아래 표준 형식을 따라야 합니다.

### 표준 응답 스키마

```typescript
interface StandardFortuneResponse {
  success: boolean;
  data: {
    // === 필수 필드 (모든 운세 공통) ===
    fortuneType: string;        // "love" | "career" | "health" | "daily" | "blind-date" | ...
    score: number;              // 0-100 (점수) - 반드시 "score" 사용!
    content: string;            // 메인 메시지/분석 결과 - 반드시 "content" 사용!
    summary: string;            // 한줄 요약
    advice: string;             // 조언/추천 행동

    // === 선택 필드 ===
    sections?: FortuneSection[];  // 세부 섹션들
    luckyItems?: LuckyItems;      // 행운 아이템
    metadata?: object;            // 추가 메타데이터

    // === Premium 블러 관련 ===
    isBlurred: boolean;           // 블러 처리 여부
    blurredSections?: string[];   // 블러된 섹션 목록
    percentile?: Percentile;      // 백분위 정보

    timestamp: string;            // ISO 8601 형식
  };
  meta?: {
    provider: string;
    model: string;
    latency: number;
  };
}

interface FortuneSection {
  title: string;
  score?: number;
  content: string;
  icon?: string;
}

interface LuckyItems {
  color?: string;
  number?: number;
  direction?: string;
  time?: string;
  item?: string;
}

interface Percentile {
  rank: number;
  total: number;
  percentage: number;
}
```

### 필드명 통일 규칙 (CRITICAL)

| 표준 필드명 | ❌ 사용 금지 | 설명 |
|------------|-------------|------|
| `score` | `loveScore`, `careerScore`, `healthScore`, `overallScore`, `overall_score`, `compatibilityScore` | 모든 점수는 `score` 사용 |
| `content` | `mainMessage`, `overallOutlook`, `overall_health`, `detailedAnalysis`, `message` | 메인 메시지는 `content` 사용 |
| `summary` | `shortSummary`, `brief`, `one_liner` | 한줄 요약은 `summary` 사용 |
| `advice` | `recommendation`, `suggestion`, `actionItem` | 조언은 `advice` 사용 |
| `sections` | `categories`, `details`, `breakdown` | 세부 섹션은 `sections` 사용 |
| `luckyItems` | `lucky_items`, `luckyThings`, `fortune_items` | 행운 아이템은 `luckyItems` 사용 |

### 표준 응답 예시

```json
{
  "success": true,
  "data": {
    "fortuneType": "love",
    "score": 85,
    "content": "오늘은 사랑에 있어 매우 좋은 기운이 흐르고 있어요. 평소에 마음에 두고 있던 사람이 있다면 적극적으로 다가가 보세요.",
    "summary": "사랑의 기운이 충만한 하루",
    "advice": "용기를 내어 먼저 연락해 보세요. 좋은 결과가 있을 거예요.",
    "sections": [
      {
        "title": "연애 성향",
        "score": 88,
        "content": "배려심이 깊고 상대방을 이해하려는 노력이 돋보입니다.",
        "icon": "heart"
      },
      {
        "title": "인연 시기",
        "content": "이번 달 중순경 좋은 만남이 예상됩니다.",
        "icon": "calendar"
      }
    ],
    "luckyItems": {
      "color": "핑크",
      "number": 7,
      "direction": "남쪽",
      "time": "오후 3시"
    },
    "isBlurred": false,
    "blurredSections": [],
    "percentile": {
      "rank": 15,
      "total": 100,
      "percentage": 85
    },
    "timestamp": "2025-01-15T09:30:00.000Z"
  },
  "meta": {
    "provider": "gemini",
    "model": "gemini-2.0-flash-exp",
    "latency": 1234
  }
}
```

### Edge Function 수정 체크리스트

기존 Edge Function 수정 시:

- [ ] `loveScore` → `score`
- [ ] `careerScore` → `score`
- [ ] `healthScore` → `score`
- [ ] `overallScore` → `score`
- [ ] `overall_score` → `score`
- [ ] `mainMessage` → `content`
- [ ] `overallOutlook` → `content`
- [ ] `overall_health` → `content`
- [ ] 응답 wrapper: `{ success: true, data: {...} }` 형식 확인
- [ ] `isBlurred`, `blurredSections` 필드 포함

---

## 디버깅 가이드

### LLM 호출 실패 시 체크 순서

1. **환경변수 확인**
   ```bash
   supabase secrets list | grep LLM_PROVIDER
   ```

2. **API Key 확인**
   ```bash
   supabase secrets list | grep GEMINI_API_KEY
   # 또는
   supabase secrets list | grep OPENAI_API_KEY
   ```

3. **로그 확인**
   ```bash
   supabase functions logs fortune-{type} --limit 10
   ```

4. **JSON 응답 확인**
   - `jsonMode: true` 설정 확인
   - 프롬프트에 "JSON" 키워드 포함 여부

---

## 프롬프트 관리

### 프롬프트 파일 위치

```
supabase/functions/_shared/prompts/
├── manager.ts          # PromptManager 클래스
├── templates/
│   ├── daily.ts        # 일일운세 템플릿
│   ├── tarot.ts        # 타로 템플릿
│   ├── saju.ts         # 사주 템플릿
│   └── ...             # 기타 운세 템플릿
└── constants.ts        # 공통 상수
```

### 프롬프트 템플릿 예시

```typescript
// supabase/functions/_shared/prompts/templates/daily.ts

export const dailySystemPrompt = `
당신은 전통 동양 운세와 현대적 해석을 결합한 전문 운세가입니다.
사용자의 생년월일과 사주를 기반으로 오늘의 운세를 분석합니다.

응답은 반드시 다음 JSON 형식으로 제공하세요:
{
  "overall_score": 0-100,
  "categories": {
    "love": { "score": 0-100, "message": "..." },
    "career": { "score": 0-100, "message": "..." },
    "health": { "score": 0-100, "message": "..." },
    "wealth": { "score": 0-100, "message": "..." }
  },
  "advice": "...",
  "warnings": "...",
  "lucky_items": ["...", "..."]
}
`

export const dailyUserPrompt = (params: DailyParams) => `
사용자 정보:
- 생년월일: ${params.birthDate}
- 태어난 시간: ${params.birthTime}
- 성별: ${params.gender}
- 오늘 날짜: ${params.today}

위 정보를 바탕으로 오늘의 운세를 분석해주세요.
`
```

---

## 관상 (Face Reading) V2 프롬프트

### 개요

관상 분석 프롬프트는 **V2 스키마**로 운영되며, 성별/연령 기반 분기와 App Store 심사 대응이 필수입니다.

### 템플릿 위치

```
supabase/functions/_shared/prompts/templates/face-reading.ts
```

### 핵심 특징

| 항목 | 설명 |
|------|------|
| fortuneType | `face-reading-v2` (V1과 별도 등록) |
| 타겟 | 2-30대 여성 중심 |
| 말투 | 친근한 대화형 (~예요, ~해 보세요) |
| 성별 분기 | Handlebars 조건부 렌더링 |

### 말투 가이드 (CRITICAL)

프롬프트 작성 시 **반드시 친근한 말투** 사용:

| 변경 전 ❌ | 변경 후 ✅ |
|-----------|-----------|
| ~입니다 | ~예요, ~이에요 |
| ~됩니다 | ~돼요, ~해 보세요 |
| 분석 결과... | 당신의 눈에서 느껴지는 건... |
| ~해야 합니다 | ~하면 좋을 것 같아요 |
| 결론적으로 | 정리하면 |

### 성별 기반 분기

```handlebars
{{#if isFemale}}
  <!-- 여성: 연애운, 배우자운, 메이크업 추천 -->
  "makeupStyleRecommendations": {...}
{{else}}
  <!-- 남성: 리더십, 커리어, 재물운 -->
  "leadershipAnalysis": {...}
{{/if}}
```

### PromptManager 사용법

```typescript
// Edge Function에서 V2 프롬프트 사용
import { PromptManager } from '../_shared/prompts/manager.ts'

const promptContext = {
  userName: '홍길동',
  userGender: 'female',      // 성별 분기용
  userAgeGroup: '20s',       // 연령대
  today: '2025-01-15',
  isFemale: true             // Handlebars 조건부 렌더링용
}

// 정적 메서드 사용
const systemPrompt = PromptManager.getSystemPrompt('face-reading-v2', promptContext)
const userPrompt = PromptManager.getUserPrompt('face-reading-v2', promptContext)
const genConfig = PromptManager.getGenerationConfig('face-reading-v2')
```

### App Store 심사 대응

**프롬프트 내부에서도 외부 노출 단어 제한**:

| 사용 O (내부) | 사용 X (절대 금지) |
|--------------|------------------|
| 분석 결과 | 운세, 점술 |
| 인사이트 | fortune, horoscope |
| 특성 분석 | 예언, prediction |
| 셀프케어 팁 | 팔자, 사주 |

### V2 응답 스키마 (요약)

```typescript
// 무료 섹션
priorityInsights: PriorityInsight[]      // 핵심 포인트 3가지
faceCondition_preview: { score, message }
emotionAnalysis_preview: { dominantEmotion, message }
watchData: WatchData                      // Watch 경량 데이터

// 프리미엄 섹션
faceCondition: FaceCondition             // 상세 컨디션
emotionAnalysis: EmotionAnalysis         // 감정 분석 전체
makeupStyleRecommendations: {...}        // 여성 전용
leadershipAnalysis: {...}                // 남성 전용
```

### 상세 문서

전체 관상 시스템 가이드: [17-face-reading-system.md](17-face-reading-system.md)

---

## 주요 파일

| 용도 | 파일 |
|------|------|
| LLM Factory | `supabase/functions/_shared/llm/factory.ts` |
| LLM Config | `supabase/functions/_shared/llm/config.ts` |
| Prompt Manager | `supabase/functions/_shared/prompts/manager.ts` |
| 일일운세 Function | `supabase/functions/fortune-daily/index.ts` |
| 관상 V2 템플릿 | `supabase/functions/_shared/prompts/templates/face-reading.ts` |
| 관상 Edge Function | `supabase/functions/fortune-face-reading/index.ts` |

---

## 장점

- **유연성**: Provider 전환이 환경변수 변경만으로 가능
- **비용 절감**: Gemini 전환 시 ~70% 비용 절감
- **속도 향상**: Reasoning 모델 대신 일반 모델 사용 가능
- **유지보수**: 프롬프트 중앙 관리
- **확장성**: 새 Provider 추가 용이

---

## 관련 문서

- [05-fortune-system.md](05-fortune-system.md) - 운세 시스템 전체
- [17-face-reading-system.md](17-face-reading-system.md) - 관상 V2 시스템 전체 가이드
- [docs/data/LLM_MODULE_GUIDE.md](/docs/data/LLM_MODULE_GUIDE.md) - 상세 가이드
- [docs/data/LLM_PROVIDER_MIGRATION.md](/docs/data/LLM_PROVIDER_MIGRATION.md) - Provider 전환
- [docs/data/PROMPT_ENGINEERING_GUIDE.md](/docs/data/PROMPT_ENGINEERING_GUIDE.md) - 프롬프트 작성
