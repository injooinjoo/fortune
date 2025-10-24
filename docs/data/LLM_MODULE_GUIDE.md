# LLM 모듈 사용 가이드

**목적**: LLM Provider를 쉽게 전환할 수 있는 추상화 모듈 사용법

**지원 Provider**: OpenAI, Google Gemini, Anthropic Claude

**핵심 특징**: 설정 기반 Provider 전환 (코드 수정 없음)

---

## 📋 목차

1. [빠른 시작](#빠른-시작)
2. [아키텍처 개요](#아키텍처-개요)
3. [Provider 전환 방법](#provider-전환-방법)
4. [Edge Function에서 사용](#edge-function에서-사용)
5. [새 Provider 추가](#새-provider-추가)
6. [트러블슈팅](#트러블슈팅)

---

## 빠른 시작

### 1. 환경변수 설정

```bash
# Supabase Secrets에 Provider 설정
supabase secrets set LLM_PROVIDER=gemini
supabase secrets set LLM_DEFAULT_MODEL=gemini-2.0-flash-lite
supabase secrets set GEMINI_API_KEY=your-api-key-here
```

### 2. Edge Function에서 사용

```typescript
// supabase/functions/fortune-moving/index.ts
import { LLMFactory } from '../_shared/llm/factory.ts'
import { PromptManager } from '../_shared/prompts/manager.ts'

serve(async (req) => {
  // 1. LLM Client 생성 (설정에서 자동 선택)
  const llm = LLMFactory.createFromConfig('moving')

  // 2. 프롬프트 생성
  const promptManager = new PromptManager()
  const prompt = promptManager.getPrompt('moving', {
    name, birthDate, moveDate, direction
  })

  // 3. LLM 호출 (Provider 무관)
  const response = await llm.generate([
    { role: 'system', content: systemPrompt },
    { role: 'user', content: prompt }
  ], {
    temperature: 1,
    maxTokens: 16000,
    jsonMode: true
  })

  return new Response(JSON.stringify({
    success: true,
    data: JSON.parse(response.content)
  }), {
    headers: { 'Content-Type': 'application/json' }
  })
})
```

### 3. Provider 전환

```bash
# Gemini로 전환
supabase secrets set LLM_PROVIDER=gemini

# OpenAI로 전환
supabase secrets set LLM_PROVIDER=openai

# 코드 수정 불필요! 재배포만 하면 됨
supabase functions deploy fortune-moving
```

---

## 아키텍처 개요

### 폴더 구조

```
supabase/functions/_shared/
├── llm/
│   ├── README.md              # 모듈 문서
│   ├── types.ts               # ILLMProvider 인터페이스
│   ├── factory.ts             # LLMFactory (Provider 생성)
│   ├── config.ts              # 설정 관리
│   └── providers/
│       ├── README.md          # Provider 추가 가이드
│       ├── gemini.ts          # GeminiProvider
│       ├── openai.ts          # OpenAIProvider
│       └── anthropic.ts       # AnthropicProvider (향후)
└── prompts/
    ├── README.md              # 프롬프트 관리 가이드
    ├── types.ts               # 프롬프트 타입
    ├── manager.ts             # PromptManager
    └── templates/
        ├── moving.ts          # 이사운 프롬프트
        ├── tarot.ts           # 타로 프롬프트
        └── ... (27개 운세)
```

### 핵심 컴포넌트

#### 1. ILLMProvider 인터페이스

모든 Provider가 구현해야 하는 공통 인터페이스:

```typescript
// _shared/llm/types.ts
export interface ILLMProvider {
  // LLM 호출 (Provider 무관)
  generate(
    messages: LLMMessage[],
    options?: GenerateOptions
  ): Promise<LLMResponse>

  // 설정 검증
  validateConfig(): boolean

  // 모델 정보
  getModelInfo(): { provider: string; model: string; capabilities: string[] }
}
```

#### 2. LLMFactory

설정 기반으로 적절한 Provider 생성:

```typescript
// _shared/llm/factory.ts
export class LLMFactory {
  static createFromConfig(fortuneType: string): ILLMProvider {
    const config = getModelConfig(fortuneType)

    switch (config.provider) {
      case 'gemini':
        return new GeminiProvider({
          apiKey: Deno.env.get('GEMINI_API_KEY'),
          model: config.model
        })

      case 'openai':
        return new OpenAIProvider({
          apiKey: Deno.env.get('OPENAI_API_KEY'),
          model: config.model
        })

      default:
        throw new Error(`Unknown provider: ${config.provider}`)
    }
  }
}
```

#### 3. 설정 관리

환경변수 기반 Provider 선택:

```typescript
// _shared/llm/config.ts
export const LLM_GLOBAL_CONFIG = {
  provider: Deno.env.get('LLM_PROVIDER') || 'gemini',
  defaultModel: Deno.env.get('LLM_DEFAULT_MODEL') || 'gemini-2.0-flash-lite',
  defaultTemperature: 1,
  defaultMaxTokens: 8192,
}

// 운세별 커스텀 모델 (선택사항)
export const FORTUNE_SPECIFIC_MODELS: Record<string, string | undefined> = {
  'moving': 'gemini-2.0-flash-lite',
  'tarot': 'gemini-2.0-flash-lite',
  // 특정 운세만 다른 모델 사용 가능
}

export function getModelConfig(fortuneType: string) {
  return {
    provider: LLM_GLOBAL_CONFIG.provider,
    model: FORTUNE_SPECIFIC_MODELS[fortuneType] || LLM_GLOBAL_CONFIG.defaultModel,
    temperature: LLM_GLOBAL_CONFIG.defaultTemperature,
    maxTokens: LLM_GLOBAL_CONFIG.defaultMaxTokens,
  }
}
```

---

## Provider 전환 방법

### 시나리오 1: 모든 운세를 Gemini로 전환

```bash
# 1. 환경변수 설정
supabase secrets set LLM_PROVIDER=gemini
supabase secrets set LLM_DEFAULT_MODEL=gemini-2.0-flash-lite
supabase secrets set GEMINI_API_KEY=your-key-here

# 2. 전체 함수 재배포
supabase functions deploy --all

# 3. 검증
curl -X POST https://your-project.supabase.co/functions/v1/fortune-moving \
  -H "Content-Type: application/json" \
  -d '{"name":"테스트","birthDate":"1990-01-01",...}'
```

### 시나리오 2: OpenAI로 복귀

```bash
# 1. 환경변수 변경
supabase secrets set LLM_PROVIDER=openai
supabase secrets set LLM_DEFAULT_MODEL=gpt-4o-mini
# OPENAI_API_KEY는 이미 설정되어 있음

# 2. 재배포
supabase functions deploy --all
```

### 시나리오 3: 특정 운세만 다른 Provider 사용

```typescript
// _shared/llm/config.ts 수정
export const FORTUNE_SPECIFIC_MODELS = {
  'tarot': 'gpt-4o-mini',  // 타로만 OpenAI 사용
  // 나머지는 기본 Provider (Gemini) 사용
}
```

---

## Edge Function에서 사용

### Before (하드코딩)

```typescript
// ❌ 문제점: Provider 하드코딩
const openaiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${Deno.env.get('OPENAI_API_KEY')}`,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    model: 'gpt-5-nano-2025-08-07',  // 하드코딩!
    messages: [...],
    response_format: { type: 'json_object' },
    temperature: 1,
    max_completion_tokens: 16000
  })
})
```

### After (모듈화)

```typescript
// ✅ 개선: Provider 추상화
import { LLMFactory } from '../_shared/llm/factory.ts'

const llm = LLMFactory.createFromConfig('moving')

const response = await llm.generate([
  { role: 'system', content: systemPrompt },
  { role: 'user', content: userPrompt }
], {
  temperature: 1,
  maxTokens: 16000,
  jsonMode: true
})

console.log(`✅ ${response.provider}/${response.model} - ${response.latency}ms`)
```

### 프롬프트 중앙 관리

```typescript
// Before: 프롬프트 하드코딩
const prompt = `당신은 이사운세 전문가입니다.
이름: ${name}
생년월일: ${birthDate}
...`

// After: 템플릿 사용
import { PromptManager } from '../_shared/prompts/manager.ts'

const promptManager = new PromptManager()
const prompt = promptManager.getPrompt('moving', {
  name, birthDate, moveDate, direction
})
```

---

## 새 Provider 추가

### 1. Provider 클래스 생성

```typescript
// _shared/llm/providers/anthropic.ts
import { ILLMProvider, LLMMessage, LLMResponse, GenerateOptions } from '../types.ts'

export class AnthropicProvider implements ILLMProvider {
  constructor(private config: { apiKey: string; model: string }) {}

  async generate(
    messages: LLMMessage[],
    options?: GenerateOptions
  ): Promise<LLMResponse> {
    const startTime = Date.now()

    // Anthropic API 호출 로직
    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'x-api-key': this.config.apiKey,
        'anthropic-version': '2023-06-01',
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        model: this.config.model,
        messages: messages,
        temperature: options?.temperature ?? 1,
        max_tokens: options?.maxTokens ?? 4096
      })
    })

    const data = await response.json()

    return {
      content: data.content[0].text,
      finishReason: data.stop_reason === 'end_turn' ? 'stop' : 'length',
      usage: {
        promptTokens: data.usage.input_tokens,
        completionTokens: data.usage.output_tokens,
        totalTokens: data.usage.input_tokens + data.usage.output_tokens
      },
      latency: Date.now() - startTime,
      provider: 'anthropic',
      model: this.config.model
    }
  }

  validateConfig(): boolean {
    return !!this.config.apiKey && !!this.config.model
  }

  getModelInfo() {
    return {
      provider: 'anthropic',
      model: this.config.model,
      capabilities: ['text', 'long-context']
    }
  }
}
```

### 2. Factory에 등록

```typescript
// _shared/llm/factory.ts
import { AnthropicProvider } from './providers/anthropic.ts'

export class LLMFactory {
  static createFromConfig(fortuneType: string): ILLMProvider {
    const config = getModelConfig(fortuneType)

    switch (config.provider) {
      case 'anthropic':  // 추가
        return new AnthropicProvider({
          apiKey: Deno.env.get('ANTHROPIC_API_KEY'),
          model: config.model
        })

      // ... 기존 case들
    }
  }
}
```

### 3. 환경변수 추가

```bash
supabase secrets set LLM_PROVIDER=anthropic
supabase secrets set LLM_DEFAULT_MODEL=claude-3-5-sonnet-20241022
supabase secrets set ANTHROPIC_API_KEY=your-key-here
```

---

## 트러블슈팅

### 1. "Unknown provider" 에러

**증상**:
```
Error: Unknown provider: gemini
```

**원인**: `LLM_PROVIDER` 환경변수가 설정되지 않았거나 잘못됨

**해결**:
```bash
# 환경변수 확인
supabase secrets list | grep LLM_PROVIDER

# 올바른 값으로 설정
supabase secrets set LLM_PROVIDER=gemini
```

### 2. API 호출 실패

**증상**:
```
Error: API call failed: 401 Unauthorized
```

**원인**: API Key가 설정되지 않았거나 만료됨

**해결**:
```bash
# Gemini 사용 시
supabase secrets list | grep GEMINI_API_KEY

# 키가 없으면 설정
supabase secrets set GEMINI_API_KEY=your-key-here

# OpenAI 사용 시
supabase secrets list | grep OPENAI_API_KEY
supabase secrets set OPENAI_API_KEY=your-key-here
```

### 3. JSON 파싱 에러

**증상**:
```
Error: Unexpected token in JSON
```

**원인**: Provider가 JSON 응답을 보내지 않음

**해결**:
- `jsonMode: true` 옵션 사용 확인
- 프롬프트에 "JSON 형식으로 응답" 명시 확인
- Provider별 JSON 모드 지원 확인

```typescript
// Gemini JSON 모드
const response = await llm.generate([...], {
  jsonMode: true,  // responseMimeType: 'application/json'
})

// OpenAI JSON 모드
const response = await llm.generate([...], {
  jsonMode: true,  // response_format: { type: 'json_object' }
})
```

### 4. 느린 응답 속도

**증상**: API 호출이 10초 이상 소요

**원인**: Reasoning 모델 (GPT-5-nano) 사용 중

**해결**:
```bash
# Reasoning 모델 대신 일반 모델 사용
supabase secrets set LLM_PROVIDER=gemini
supabase secrets set LLM_DEFAULT_MODEL=gemini-2.0-flash-lite
# 또는
supabase secrets set LLM_PROVIDER=openai
supabase secrets set LLM_DEFAULT_MODEL=gpt-4o-mini
```

### 5. 비용 과다

**증상**: OpenAI 청구액이 예상보다 높음

**해결**:
1. **Gemini로 전환** (70% 비용 절감)
   ```bash
   supabase secrets set LLM_PROVIDER=gemini
   ```

2. **토큰 사용량 모니터링**
   ```typescript
   const response = await llm.generate([...])
   console.log(`📊 Tokens: ${response.usage.totalTokens}`)
   ```

3. **운세별 모델 최적화**
   ```typescript
   // 짧은 운세는 작은 모델
   export const FORTUNE_SPECIFIC_MODELS = {
     'fortune-cookie': 'gemini-1.5-flash',  // 짧은 응답
     'tarot': 'gemini-2.0-flash-lite',       // 긴 응답
   }
   ```

---

## 📚 관련 문서

- [LLM_PROVIDER_MIGRATION.md](./LLM_PROVIDER_MIGRATION.md) - Provider 변경 가이드
- [PROMPT_ENGINEERING_GUIDE.md](./PROMPT_ENGINEERING_GUIDE.md) - 프롬프트 작성 가이드
- [API_KEY_ROTATION_GUIDE.md](../deployment/API_KEY_ROTATION_GUIDE.md) - API 키 관리

---

## 📞 지원

### OpenAI
- https://help.openai.com
- API 키 분실 시 재발급 필수

### Google Gemini
- https://ai.google.dev/docs
- API Console: https://aistudio.google.com/app/apikey

### Anthropic Claude
- https://docs.anthropic.com
- Console: https://console.anthropic.com

---

**작성자**: Claude Code
**최종 수정**: 2025-01-10
**버전**: 1.0.0
