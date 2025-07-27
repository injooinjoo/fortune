import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import "https://deno.land/x/xhr@0.3.0/mod.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface CareerSeekerRequest {
  userId: string
  educationLevel: string
  desiredField: string
  jobSearchDuration: number
  primaryConcern: string
  skillAreas: string[]
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { 
      userId, 
      educationLevel, 
      desiredField, 
      jobSearchDuration,
      primaryConcern,
      skillAreas 
    }: CareerSeekerRequest = await req.json()

    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    const openAIKey = Deno.env.get('OPENAI_API_KEY') ?? ''

    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Check for cached fortune
    const today = new Date().toISOString().split('T')[0]
    const cacheKey = `career_seeker_${userId}_${today}_${desiredField}_${primaryConcern}`
    
    const { data: existingFortune } = await supabase
      .from('fortune_cache')
      .select('*')
      .eq('cache_key', cacheKey)
      .single()

    if (existingFortune && existingFortune.created_at > new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString()) {
      return new Response(
        JSON.stringify(existingFortune.fortune_data),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Generate new fortune using OpenAI
    const systemPrompt = `당신은 한국의 전문 직업운 상담사입니다. 구직자의 상황을 분석하여 희망과 현실적인 조언을 균형있게 제공합니다.
    
    응답은 반드시 다음 JSON 형식으로 제공하세요:
    {
      "summary": "전체적인 운세 요약 (2-3문장)",
      "jobOpportunityRadar": {
        "documentPass": 0-100 사이 숫자,
        "interviewSuccess": 0-100 사이 숫자,
        "salaryNegotiation": 0-100 사이 숫자,
        "networking": 0-100 사이 숫자,
        "marketDemand": 0-100 사이 숫자,
        "competitiveness": 0-100 사이 숫자
      },
      "timeline": [
        {
          "period": "1-2주",
          "event": "예상되는 이벤트",
          "advice": "구체적인 조언"
        }
      ],
      "industryCompatibility": [
        {
          "industry": "산업명",
          "compatibility": 0-100 사이 숫자,
          "reason": "이유"
        }
      ],
      "luckyCompanies": ["회사 유형 1", "회사 유형 2", "회사 유형 3", "회사 유형 4", "회사 유형 5"],
      "weeklyActions": [
        {
          "action": "액션 아이템",
          "description": "구체적인 설명",
          "priority": "high|medium|low"
        }
      ],
      "luckyDays": ["월", "수"],
      "luckyColors": ["파란색", "흰색"],
      "careerAdvice": "맞춤형 커리어 조언 (3-5문장)",
      "motivationalMessage": "동기부여 메시지 (1-2문장)"
    }`

    const userContext = `
    학력: ${educationLevel}
    희망 분야: ${desiredField}
    구직 기간: ${jobSearchDuration}개월
    주요 고민: ${primaryConcern}
    강점 스킬: ${skillAreas.join(', ')}
    날짜: ${new Date().toLocaleDateString('ko-KR')}
    `

    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${openAIKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-4o-mini',
        messages: [
          { role: 'system', content: systemPrompt },
          { role: 'user', content: userContext }
        ],
        temperature: 0.8,
        max_tokens: 2000,
        response_format: { type: "json_object" }
      }),
    })

    if (!response.ok) {
      throw new Error(`OpenAI API error: ${response.statusText}`)
    }

    const aiResponse = await response.json()
    const fortuneContent = JSON.parse(aiResponse.choices[0].message.content)

    // Save user parameters
    await supabase
      .from('fortune_history')
      .insert({
        user_id: userId,
        fortune_type: 'career_seeker',
        parameters: {
          educationLevel,
          desiredField,
          jobSearchDuration,
          primaryConcern,
          skillAreas
        },
        result: fortuneContent,
      })

    // Cache the fortune
    await supabase
      .from('fortune_cache')
      .upsert({
        cache_key: cacheKey,
        fortune_type: 'career_seeker',
        fortune_data: fortuneContent,
        created_at: new Date().toISOString(),
      })

    // Return fortune with metadata
    const responseData = {
      fortune: fortuneContent,
      metadata: {
        generated_at: new Date().toISOString(),
        fortune_type: 'career_seeker',
        cached: false,
      }
    }

    return new Response(
      JSON.stringify(responseData),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    console.error('Error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})