Supabase Edge Function을 생성합니다.

## 입력 정보

- **운세 유형**: $ARGUMENTS 또는 사용자에게 질문
- **필수 입력 필드**: API 요청에 필요한 필드들
- **프롬프트 내용**: LLM에게 전달할 지시사항

## 생성 위치

```
supabase/functions/fortune-{type}/index.ts
supabase/functions/_shared/prompts/templates/{type}.ts
```

## Edge Function 템플릿

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

## 프롬프트 템플릿

```typescript
// supabase/functions/_shared/prompts/templates/{type}.ts

export const {type}SystemPrompt = `
당신은 전통 동양 운세와 현대적 해석을 결합한 전문 운세가입니다.

응답은 반드시 다음 JSON 형식으로 제공하세요:
{
  "overall_score": 0-100,
  "categories": {
    "love": { "score": 0-100, "message": "..." },
    "career": { "score": 0-100, "message": "..." }
  },
  "advice": "...",
  "warnings": "..."
}
`

export const {type}UserPrompt = (params: {Type}Params) => `
사용자 정보:
- 생년월일: ${params.birthDate}
- 태어난 시간: ${params.birthTime}
- 성별: ${params.gender}

위 정보를 바탕으로 {운세 유형}을(를) 분석해주세요.
`
```

## 배포 명령어

```bash
supabase functions deploy fortune-{type}
```

## 체크리스트

- [ ] LLMFactory.createFromConfig() 사용
- [ ] PromptManager 사용
- [ ] jsonMode: true 설정
- [ ] 성능 로그 추가
- [ ] CORS 헤더 설정

## 관련 Agent

- fortune-domain-expert

