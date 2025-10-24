# 프롬프트 엔지니어링 가이드

**목적**: 27개 운세별 프롬프트 템플릿 관리 및 최적화

**지원 Provider**: OpenAI, Gemini, Anthropic

---

## 📋 목차

1. [프롬프트 작성 원칙](#프롬프트-작성-원칙)
2. [Provider별 차이점](#provider별-차이점)
3. [프롬프트 템플릿 구조](#프롬프트-템플릿-구조)
4. [JSON 응답 강제 방법](#json-응답-강제-방법)
5. [한글 프롬프트 최적화](#한글-프롬프트-최적화)
6. [27개 운세별 프롬프트](#27개-운세별-프롬프트)

---

## 프롬프트 작성 원칙

### 1. 명확한 역할 정의

```typescript
// ❌ 나쁜 예
const systemPrompt = '운세를 봐주세요'

// ✅ 좋은 예
const systemPrompt = `
당신은 30년 경력의 전문 사주 역술가입니다.
사주팔자를 정확히 해석하여 이사운세를 봐주세요.
반드시 근거를 제시하고, 실용적인 조언을 포함하세요.
`
```

### 2. 구조화된 출력 요구

```typescript
// ❌ 나쁜 예
'결과를 알려주세요'

// ✅ 좋은 예
`
다음 JSON 형식으로 정확히 답변해주세요:
{
  "overallScore": 0-100 사이의 점수 (number),
  "analysis": "상세 분석 (string, 300자 내외)",
  "warnings": ["주의사항1", "주의사항2"] (array),
  "recommendations": ["추천사항1", "추천사항2"] (array)
}
`
```

### 3. 컨텍스트 제공

```typescript
// ❌ 나쁜 예
'이사운세 봐주세요'

// ✅ 좋은 예
`
이름: ${name}
생년월일: ${birthDate}
이사 예정일: ${moveDate}
이사 방향: ${direction}

위 정보를 바탕으로 이사운세를 분석해주세요.
`
```

### 4. 제약조건 명시

```typescript
// ✅ 좋은 예
`
다음 규칙을 반드시 지켜주세요:
1. 과도한 긍정/부정 표현 자제
2. 미신적 표현 지양
3. 실용적 조언 포함
4. 300자 내외로 작성
5. JSON 형식만 반환 (추가 설명 금지)
`
```

---

## Provider별 차이점

### OpenAI (GPT-5-nano, GPT-4o)

#### JSON 모드
```typescript
// API 호출 시 설정
{
  response_format: { type: 'json_object' }
}
```

#### 프롬프트 요구사항
- **필수**: "JSON" 키워드 포함
- **권장**: JSON 스키마 명시

```typescript
const systemPrompt = `
당신은 운세 전문가입니다.
반드시 JSON 형식으로 응답해주세요.  // ✅ "JSON" 키워드 필수!

{
  "score": number,
  "content": string
}
`
```

#### 특징
- ✅ JSON 모드 안정적
- ✅ 한글 품질 우수
- ✅ 지시 사항 준수율 높음
- ⚠️ GPT-5-nano는 Reasoning 모델 (느림)

---

### Google Gemini (2.0 Flash, 1.5 Pro)

#### JSON 모드
```typescript
// API 호출 시 설정
{
  generationConfig: {
    responseMimeType: 'application/json'
  }
}
```

#### 프롬프트 요구사항
- **선택**: "JSON" 키워드 (없어도 됨)
- **권장**: 명확한 구조 명시

```typescript
const systemPrompt = `
당신은 운세 전문가입니다.
다음 JSON 구조로 응답해주세요:

{
  "score": 정수 (0-100),
  "content": "문자열"
}
`
```

#### 특징
- ✅ 빠른 응답 속도
- ✅ 저렴한 비용
- ⚠️ 한글 품질 약간 낮음 (GPT 대비)
- ⚠️ 지시 무시 가능성 (프롬프트 강화 필요)

---

### Anthropic Claude (3.5 Sonnet)

#### JSON 모드
```typescript
// 프롬프트로만 제어 (별도 파라미터 없음)
```

#### 프롬프트 요구사항
- **필수**: 강력한 JSON 요구
- **권장**: 예시 포함

```typescript
const systemPrompt = `
당신은 운세 전문가입니다.

<instructions>
1. 반드시 JSON 형식으로만 응답하세요.
2. 추가 설명이나 마크다운 없이 순수 JSON만 반환하세요.
</instructions>

<example>
{
  "score": 85,
  "content": "좋은 운세입니다."
}
</example>

위 형식과 정확히 동일하게 응답하세요.
`
```

#### 특징
- ✅ 한글 품질 최고
- ✅ 긴 컨텍스트 지원
- ⚠️ JSON 모드 없음 (프롬프트만 의존)
- ⚠️ 비용 높음

---

## 프롬프트 템플릿 구조

### 파일 구조

```
supabase/functions/_shared/prompts/
├── templates/
│   ├── moving.ts              # 이사운
│   ├── tarot.ts               # 타로
│   ├── love.ts                # 연애운
│   └── ... (27개)
└── manager.ts                 # PromptManager
```

### 표준 템플릿 형식

```typescript
// _shared/prompts/templates/moving.ts

export interface MovingFortuneParams {
  name: string
  birthDate: string
  moveDate: string
  direction: string
}

export const MOVING_SYSTEM_PROMPT = `
당신은 30년 경력의 전문 이사운세 역술가입니다.

역할:
- 사주팔자를 기반으로 이사 날짜와 방향의 길흉을 정확히 판단
- 실용적이고 구체적인 조언 제공
- 과도한 미신적 표현 지양

반드시 다음 JSON 형식으로 응답해주세요:
{
  "overallScore": 0-100 사이의 점수 (number),
  "direction": "이사 방향 분석 (string, 150자)",
  "dateAnalysis": "이사 날짜 분석 (string, 150자)",
  "warnings": ["주의사항1", "주의사항2"] (array of string),
  "recommendations": ["추천사항1", "추천사항2"] (array of string),
  "luckyItems": ["행운 아이템1", "행운 아이템2"] (array of string)
}
`

export function getMovingUserPrompt(params: MovingFortuneParams): string {
  return `
의뢰인 정보:
- 이름: ${params.name}
- 생년월일: ${params.birthDate}
- 이사 예정일: ${params.moveDate}
- 이사 방향: ${params.direction}

위 정보를 바탕으로 이사운세를 상세히 분석해주세요.
`
}
```

### PromptManager 사용

```typescript
// _shared/prompts/manager.ts

import { MOVING_SYSTEM_PROMPT, getMovingUserPrompt } from './templates/moving.ts'
import { TAROT_SYSTEM_PROMPT, getTarotUserPrompt } from './templates/tarot.ts'
// ... 27개 import

export class PromptManager {
  getSystemPrompt(fortuneType: string): string {
    switch (fortuneType) {
      case 'moving':
        return MOVING_SYSTEM_PROMPT
      case 'tarot':
        return TAROT_SYSTEM_PROMPT
      // ... 27개 case
      default:
        throw new Error(`Unknown fortune type: ${fortuneType}`)
    }
  }

  getUserPrompt(fortuneType: string, params: any): string {
    switch (fortuneType) {
      case 'moving':
        return getMovingUserPrompt(params)
      case 'tarot':
        return getTarotUserPrompt(params)
      // ... 27개 case
      default:
        throw new Error(`Unknown fortune type: ${fortuneType}`)
    }
  }

  getPrompt(fortuneType: string, params: any): string {
    return `${this.getSystemPrompt(fortuneType)}\n\n${this.getUserPrompt(fortuneType, params)}`
  }
}
```

---

## JSON 응답 강제 방법

### OpenAI

```typescript
// 1. response_format 설정 (필수)
const response = await llm.generate([...], {
  jsonMode: true  // → response_format: { type: 'json_object' }
})

// 2. 프롬프트에 "JSON" 키워드 포함 (필수)
const systemPrompt = `
당신은 운세 전문가입니다.
반드시 JSON 형식으로 응답해주세요.  // ✅ "JSON" 필수!
`

// ❌ 에러 발생 케이스
// 'response_format'을 사용하려면 프롬프트에 'json' 단어 포함 필요
```

### Gemini

```typescript
// 1. responseMimeType 설정
const response = await llm.generate([...], {
  jsonMode: true  // → responseMimeType: 'application/json'
})

// 2. 프롬프트에 구조 명시 (권장)
const systemPrompt = `
다음 JSON 구조로 응답하세요:

{
  "score": number,
  "content": string
}

위 형식을 정확히 지켜주세요.
`
```

### Anthropic Claude

```typescript
// 1. 프롬프트로만 제어 (JSON 모드 없음)
const systemPrompt = `
<instructions>
1. 반드시 순수 JSON만 반환하세요.
2. 마크다운 코드 블록 사용 금지.
3. 추가 설명 금지.
</instructions>

<example>
{"score": 85, "content": "분석 결과"}
</example>

위 예시와 동일한 형식으로만 응답하세요.
`

// 2. JSON 추출 로직 필요
function extractJSON(text: string): any {
  // ```json ... ``` 제거
  const cleaned = text.replace(/```json\n?/g, '').replace(/```/g, '')
  return JSON.parse(cleaned)
}
```

---

## 한글 프롬프트 최적화

### 토큰 절약 기법

```typescript
// ❌ 비효율적 (토큰 낭비)
const prompt = `
의뢰인 정보는 다음과 같습니다:
- 의뢰인의 이름은 ${name}입니다.
- 의뢰인의 생년월일은 ${birthDate}입니다.
- 이사를 가려는 날짜는 ${moveDate}입니다.
- 이사하려는 방향은 ${direction}입니다.

위의 정보를 바탕으로 이사운세를 봐주시기 바랍니다.
`

// ✅ 효율적 (토큰 절약)
const prompt = `
이름: ${name}
생년월일: ${birthDate}
이사일: ${moveDate}
방향: ${direction}

이사운세 분석해주세요.
`
```

### 명확한 한글 표현

```typescript
// ❌ 모호한 표현
'좋은 운세를 봐주세요'

// ✅ 명확한 표현
'0-100점 척도로 점수를 매기고, 구체적 근거를 제시하세요'
```

### 한글 특화 프롬프트

```typescript
// ✅ 한국 문화 반영
const systemPrompt = `
당신은 한국의 전통 역술을 연구한 전문가입니다.

분석 시 고려사항:
- 음력/양력 변환
- 24절기
- 천간지지
- 십이운성
- 한국 전통 방위 (동/서/남/북)

반드시 한국어로 자연스럽게 작성하세요.
`
```

---

## 27개 운세별 프롬프트

### 1. 일일운세 (daily)

```typescript
export const DAILY_SYSTEM_PROMPT = `
당신은 일일운세 전문가입니다.
오늘의 운세를 긍정적이고 실용적으로 제공하세요.

JSON 형식:
{
  "overallScore": number (0-100),
  "summary": string (50자),
  "love": string (100자),
  "career": string (100자),
  "health": string (100자),
  "luckyNumber": number,
  "luckyColor": string
}
`
```

### 2. 타로 (tarot)

```typescript
export const TAROT_SYSTEM_PROMPT = `
당신은 타로 리더입니다.
선택한 카드의 의미를 해석하여 조언을 제공하세요.

JSON 형식:
{
  "overallScore": number (0-100),
  "cards": [
    {
      "name": string,
      "position": string,
      "meaning": string (150자)
    }
  ],
  "interpretation": string (300자),
  "advice": string (150자)
}
`
```

### 3. 연애운 (love)

```typescript
export const LOVE_SYSTEM_PROMPT = `
당신은 연애운세 전문가입니다.
사주팔자를 기반으로 연애운을 분석하세요.

JSON 형식:
{
  "overallScore": number (0-100),
  "currentStatus": string (150자),
  "meetingChance": string (150자),
  "relationshipAdvice": string (200자),
  "idealType": string (100자),
  "warnings": [string],
  "luckyDate": string
}
`
```

### 4. 궁합 (compatibility)

```typescript
export const COMPATIBILITY_SYSTEM_PROMPT = `
당신은 궁합 전문가입니다.
두 사람의 사주를 비교하여 궁합을 분석하세요.

JSON 형식:
{
  "overallScore": number (0-100),
  "strengths": [string] (장점 3개),
  "weaknesses": [string] (약점 3개),
  "adviceForUser": string (150자),
  "adviceForPartner": string (150자),
  "longTermProspect": string (200자)
}
`
```

### 5. 이사운 (moving)

위 예시 참조

### 6-27. 나머지 운세

각 운세별로 동일한 패턴 적용:
1. 역할 정의
2. JSON 스키마 명시
3. 제약조건 포함
4. 한글 자연스럽게

전체 템플릿 예시:
- `birth-season.ts`
- `birthdate.ts`
- `mbti.ts`
- `personality-dna.ts`
- `biorhythm.ts`
- `traditional.ts`
- `dream.ts`
- `face-reading.ts`
- `talisman.ts`
- `wish.ts`
- `fortune-cookie.ts`
- `career.ts`
- `study.ts`
- `investment.ts`
- `health.ts`
- `exercise.ts`
- `sports-game.ts`
- `talent.ts`
- `lucky-items.ts`
- `relationship.ts`
- `ex-lover.ts`
- `blind-date.ts`
- `family.ts`
- `pet.ts`
- `celebrity.ts`

---

## 프롬프트 최적화 팁

### 1. A/B 테스트

```typescript
// 버전 A
const promptA = '운세를 봐주세요'

// 버전 B
const promptB = `
역할: 전문 역술가
출력: JSON 형식
제약: 300자 이내
`

// 두 버전 테스트 후 더 나은 결과 선택
```

### 2. Few-shot 예시

```typescript
const systemPrompt = `
당신은 운세 전문가입니다.

예시 1:
입력: 홍길동, 1990-01-01
출력: {"score": 85, "content": "좋은 날입니다"}

예시 2:
입력: 김철수, 1985-05-15
출력: {"score": 60, "content": "조심하세요"}

위 예시처럼 응답하세요.
`
```

### 3. 점진적 개선

```typescript
// v1: 기본
'운세 봐주세요'

// v2: 구조화
'JSON 형식으로 운세 봐주세요'

// v3: 상세화
'JSON 형식으로 점수와 분석 내용 제공'

// v4: 최종
'0-100점 척도, 300자 분석, JSON 형식'
```

---

## 📚 참고 자료

- [LLM_MODULE_GUIDE.md](./LLM_MODULE_GUIDE.md) - LLM 모듈 사용법
- [LLM_PROVIDER_MIGRATION.md](./LLM_PROVIDER_MIGRATION.md) - Provider 전환
- [OpenAI Prompt Engineering](https://platform.openai.com/docs/guides/prompt-engineering)
- [Gemini Prompting Guide](https://ai.google.dev/docs/prompting_intro)
- [Claude Prompt Library](https://docs.anthropic.com/claude/prompt-library)

---

**작성자**: Claude Code
**최종 수정**: 2025-01-10
**버전**: 1.0.0
