/**
 * 부적 운세 (Talisman Fortune) Edge Function
 *
 * @description 사용자의 생년월일 기반으로 개인화된 부적 운세를 생성합니다.
 * LLMFactory를 통한 gemini-2.0-flash-lite 모델 사용
 *
 * @endpoint POST /fortune-talisman
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders, handleCors } from '../_shared/cors.ts'
import { authenticateUser, checkTokenBalance, deductTokens } from '../_shared/auth.ts'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'
import { FortuneRequest, FortuneResponse, FORTUNE_TOKEN_COSTS } from '../_shared/types.ts'
import {
  extractTalismanCohort,
  generateCohortHash,
  getFromCohortPool,
  saveToCohortPool,
  personalize,
} from '../_shared/cohort/index.ts'

const FORTUNE_TYPE = 'talisman'
const TOKEN_COST = FORTUNE_TOKEN_COSTS[FORTUNE_TYPE]

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

    // Check token balance
    const { hasBalance, balance, error: balanceError } = await checkTokenBalance(
      user!.id,
      TOKEN_COST
    )

    if (balanceError) {
      return new Response(
        JSON.stringify({ error: balanceError }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    if (!hasBalance) {
      return new Response(
        JSON.stringify({
          error: 'Insufficient token balance',
          required: TOKEN_COST,
          current: balance
        }),
        {
          status: 402,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    // Check cache first
    const cacheKey = `${FORTUNE_TYPE}_${user!.id}_${new Date().toISOString().split('T')[0]}`
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    const { data: cached } = await supabase
      .from('fortune_cache')
      .select('fortune_data')
      .eq('cache_key', cacheKey)
      .single()

    if (cached) {
      return new Response(
        JSON.stringify({
          ...cached.fortune_data,
          cached: true,
          tokensUsed: 0
        }),
        {
          status: 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    // Generate fortune using LLMFactory
    const llm = await LLMFactory.createFromConfigAsync('talisman')

    // ===== Cohort Pool 조회 =====
    const cohortData = extractTalismanCohort({ birthDate: body.birthDate })
    const cohortHash = await generateCohortHash(cohortData)
    console.log(`[fortune-talisman] 🔍 Cohort: ${JSON.stringify(cohortData)}, hash: ${cohortHash.slice(0, 8)}...`)

    const cachedResult = await getFromCohortPool(supabase, 'talisman', cohortHash)

    if (cachedResult) {
      console.log(`[fortune-talisman] ✅ Cohort Pool HIT!`)

      // Personalize with user-specific data
      const personalizedResult = personalize(cachedResult, {
        '{{userName}}': body.name || '사용자',
        '{{name}}': body.name || '사용자',
      })

      const fortune = typeof personalizedResult === 'string'
        ? JSON.parse(personalizedResult)
        : personalizedResult

      // Deduct tokens (캐시여도 토큰 차감)
      await deductTokens(user!.id, TOKEN_COST, `Talisman fortune (cohort)`)

      return new Response(
        JSON.stringify({
          fortune: {
            ...fortune,
            generatedAt: new Date().toISOString()
          },
          tokensUsed: TOKEN_COST,
          cached: true,
          cohortHit: true,
          generatedAt: new Date().toISOString()
        }),
        {
          status: 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    console.log(`[fortune-talisman] 💨 Cohort Pool MISS - LLM 호출 필요`)

    // 현재 날짜 (UTC+9 한국 시간)
    const now = new Date()
    const koreaTime = new Date(now.getTime() + 9 * 60 * 60 * 1000)
    const todayStr = `${koreaTime.getFullYear()}년 ${koreaTime.getMonth() + 1}월 ${koreaTime.getDate()}일`

    const systemPrompt = `You are a professional fortune teller specializing in talisman fortunes.
Provide insightful, positive, and helpful fortune readings in Korean.

Create a personalized Korean traditional talisman (부적) fortune reading. Today is ${todayStr}.
Focus on:
- The protective and blessing powers of the talisman
- Specific lucky elements (colors, directions, numbers) for today
- Traditional Korean spiritual guidance
- How to use and care for the talisman

Return the response in the following JSON format:
{
  "title": "운세 제목",
  "description": "전체적인 운세 설명 (2-3문단)",
  "details": {
    "overall": "종합운",
    "love": "애정운",
    "career": "직장/사업운",
    "health": "건강운",
    "wealth": "금전운"
  },
  "advice": "조언 및 행동 지침",
  "luckyItems": ["행운의 아이템1", "행운의 아이템2"],
  "warnings": ["주의사항1", "주의사항2"],
  "score": 85,
  "period": "${todayStr}"
}
Include specific Korean talisman symbols and their meanings.`

    const userPrompt = createUserPrompt(body)

    const response = await llm.generate([
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userPrompt }
    ], {
      responseFormat: { type: 'json_object' }
    })

    // Log usage
    await UsageLogger.log({
      userId: user!.id,
      fortuneType: FORTUNE_TYPE,
      model: response.model,
      inputTokens: response.usage?.promptTokens || 0,
      outputTokens: response.usage?.completionTokens || 0,
    })

    const fortune = JSON.parse(response.content)

    // Deduct tokens
    const { success: deductSuccess, error: deductError } = await deductTokens(
      user!.id,
      TOKEN_COST,
      `Talisman fortune generation`
    )

    if (!deductSuccess) {
      return new Response(
        JSON.stringify({ error: deductError || 'Failed to deduct tokens' }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    // Cache the result
    await supabase
      .from('fortune_cache')
      .upsert({
        cache_key: cacheKey,
        user_id: user!.id,
        fortune_type: FORTUNE_TYPE,
        fortune_data: { fortune },
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString()
      })

    // Save to fortune history
    await supabase
      .from('fortunes')
      .insert({
        user_id: user!.id,
        fortune_type: FORTUNE_TYPE,
        fortune_data: fortune,
        tokens_used: TOKEN_COST
      })

    // ===== Cohort Pool 저장 (Fire-and-forget) =====
    saveToCohortPool(supabase, 'talisman', cohortHash, fortune)
      .then(() => console.log(`[fortune-talisman] 💾 Cohort Pool 저장 완료`))
      .catch((err) => console.error(`[fortune-talisman] ⚠️ Cohort Pool 저장 실패:`, err))

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
    console.error('Fortune generation error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }
})

// Helper function to create user prompt
function createUserPrompt(request: FortuneRequest): string {
  const parts = ['Generate a talisman fortune with the following information:']

  if (request.name) parts.push(`Name: ${request.name}`)
  if (request.birthDate) parts.push(`Birth Date: ${request.birthDate}`)
  if (request.birthTime) parts.push(`Birth Time: ${request.birthTime}`)
  if (request.isLunar) parts.push(`Calendar Type: Lunar`)
  if (request.gender) parts.push(`Gender: ${request.gender}`)
  if (request.zodiacSign) parts.push(`Zodiac Sign: ${request.zodiacSign}`)

  if (request.additionalInfo) {
    Object.entries(request.additionalInfo).forEach(([key, value]) => {
      parts.push(`${key}: ${value}`)
    })
  }

  parts.push('\nPlease provide the fortune in Korean language with detailed insights and practical advice.')

  return parts.join('\n')
}
