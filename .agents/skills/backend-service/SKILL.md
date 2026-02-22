---
name: "sc:backend-service"
description: "Edge Function 전용 생성. Flutter 변경 없이 Supabase Edge Function만 생성/수정 시 사용."
depends_on: ["sc:enforce-discovery"]
auto_call_after: ["sc:enforce-verify"]
---

# Backend Service Builder

Supabase Edge Function만 생성하거나 수정하는 워크플로우 스킬입니다.

---

## ⛔ HARD BLOCK 전제 조건

**이 스킬 실행 전 반드시 `/sc:enforce-discovery`가 완료되어야 합니다.**

```
Discovery 보고서 없이 backend-service 실행 시:
⛔ 차단: "/sc:enforce-discovery를 먼저 실행해주세요"

필수 확인 사항:
- 기존 Edge Function 목록 확인 (ls supabase/functions/)
- 유사한 기능 확인
- LLMFactory, PromptManager 패턴 확인
```

---

## 사용법

```
/sc:backend-service 건강 분석 API
/sc:backend-service 사용자 통계 집계
/sc:backend-service fortune-daily 수정
```

---

## 생성 파일

| 파일 | 설명 |
|------|------|
| `supabase/functions/{name}/index.ts` | Edge Function 메인 |
| `supabase/functions/_shared/prompts/templates/{name}.ts` | LLM 프롬프트 (필요시) |

---

## Edge Function 표준 구조

```typescript
/**
 * @endpoint POST /functions/v1/{function-name}
 * @description 기능 설명
 * @requestBody { field1: type, field2: type }
 * @response { result: type }
 */

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { PromptManager } from '../_shared/prompts/manager.ts'
import { UsageLogger } from '../_shared/usage/logger.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const startTime = Date.now()
    const { field1, field2 } = await req.json()

    // LLM 호출 (필요시)
    const llm = LLMFactory.createFromConfig('{function-name}')
    const promptManager = new PromptManager()

    const systemPrompt = promptManager.getSystemPrompt('{function-name}')
    const userPrompt = promptManager.getUserPrompt('{function-name}', { field1, field2 })

    const response = await llm.generate(
      [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: userPrompt }
      ],
      { temperature: 1, maxTokens: 8192, jsonMode: true }
    )

    // 성능 로깅
    const duration = Date.now() - startTime
    console.log(`[{function-name}] completed in ${duration}ms`)

    return new Response(
      JSON.stringify(response),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    console.error('[{function-name}] Error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
```

---

## 필수 규칙

### LLMFactory 사용 (필수)
```typescript
// ✅ 올바른 사용
const llm = LLMFactory.createFromConfig('function-name')

// ❌ 금지
const openai = new OpenAI({ apiKey: ... })
const genai = new GoogleGenerativeAI(...)
```

### PromptManager 사용 (필수)
```typescript
// ✅ 올바른 사용
const promptManager = new PromptManager()
const systemPrompt = promptManager.getSystemPrompt('function-name')

// ❌ 금지
const systemPrompt = `당신은 ...` // 하드코딩
```

### JSON Mode (필수)
```typescript
// ✅ LLM 호출 시 항상
{ jsonMode: true }
```

---

## 검증

```bash
# TypeScript 검증
deno check supabase/functions/{name}/index.ts

# 로컬 테스트
supabase functions serve {name}

# 배포
supabase functions deploy {name}
```

---

## 완료 후 자동 검증

**생성 완료 시 `/sc:enforce-verify`가 자동 호출됩니다.**

```
생성 완료!
    │
    └─ /sc:enforce-verify 자동 호출
        ├─ deno check
        ├─ 로컬 테스트 안내
        └─ 배포 확인 요청
```

---

## 완료 메시지

```
✅ Edge Function이 생성되었습니다!

📁 생성된 파일:
1. supabase/functions/{name}/index.ts
2. supabase/functions/_shared/prompts/templates/{name}.ts

➡️ /sc:enforce-verify 실행 중...

🔧 테스트 안내:
1. 로컬 테스트: supabase functions serve {name}
2. 배포: supabase functions deploy {name}
```