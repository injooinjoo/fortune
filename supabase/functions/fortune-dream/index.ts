import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders, handleCors } from '../_shared/cors.ts'
import { authenticateUser } from '../_shared/auth.ts'
import { generateFortune, getSystemPrompt } from '../_shared/openai.ts'
import { FortuneRequest, FortuneResponse, FORTUNE_TOKEN_COSTS } from '../_shared/types.ts'

const FORTUNE_TYPE = 'dream'
const TOKEN_COST = FORTUNE_TOKEN_COSTS[FORTUNE_TYPE] || 50

serve(async (req: Request) => {
  // Handle CORS
  const corsResponse = handleCors(req)
  if (corsResponse) return corsResponse

  try {
    // Authenticate user
    const { user, error: authError } = await authenticateUser(req)
    if (authError) return authError

    // Parse request body
    const body: FortuneRequest = await req.json()

    // Validate dream content
    if (!body.dream || typeof body.dream !== 'string' || body.dream.trim().length === 0) {
      return new Response(
        JSON.stringify({ error: '꿈 내용을 입력해주세요' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Create dream interpretation system prompt
    const dreamSystemPrompt = `
당신은 전문적인 꿈 해몽가이자 심리 분석가입니다. 
사용자가 들려주는 꿈의 내용을 바탕으로 다음을 분석해주세요:

1. 꿈의 전체적인 의미와 메시지
2. 주요 상징들의 의미 (최소 3개)
3. 심리학적 해석
4. 현재 상황에 대한 조언
5. 행운의 요소들 (색상, 숫자, 방향 등)

응답은 다음 형식으로 제공해주세요:
{
  "title": "꿈 해몽 제목",
  "overallScore": 1-100 사이의 점수,
  "description": "전체적인 해몽 설명",
  "interpretation": {
    "psychological": "심리학적 해석",
    "symbolic": "상징적 의미",
    "practical": "현실적 조언"
  },
  "symbols": [
    {
      "symbol": "꿈에 나온 상징",
      "meaning": "그 상징의 의미"
    }
  ],
  "luckyElements": {
    "colors": ["행운의 색상들"],
    "numbers": [행운의 숫자들],
    "directions": ["행운의 방향들"],
    "items": ["행운의 아이템들"]
  },
  "advice": "오늘 하루를 위한 조언",
  "warning": "주의할 점",
  "affirmation": "긍정적인 확언"
}
`

    // Generate fortune with dream-specific prompt
    const fortune = await generateFortune(
      FORTUNE_TYPE, 
      {
        ...body,
        userMessage: `다음 꿈을 해몽해주세요:\n\n${body.dream}\n\n입력 방식: ${body.inputType || 'text'}`
      }, 
      dreamSystemPrompt
    )

    // Save to fortune history
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    await supabase
      .from('fortunes')
      .insert({
        user_id: user!.id,
        fortune_type: FORTUNE_TYPE,
        fortune_data: {
          ...fortune,
          dreamContent: body.dream,
          inputType: body.inputType
        },
        tokens_used: TOKEN_COST
      })

    // Return response
    const response: FortuneResponse = {
      fortune: {
        ...fortune,
        generatedAt: new Date().toISOString()
      },
      tokensUsed: TOKEN_COST,
      generatedAt: new Date().toISOString()
    }

    return new Response(
      JSON.stringify(response),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Dream fortune generation error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})