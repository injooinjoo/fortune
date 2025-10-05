import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.7.1'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// OpenAI API 설정
const OPENAI_API_KEY = Deno.env.get('OPENAI_API_KEY')
const OPENAI_API_URL = 'https://api.openai.com/v1/chat/completions'

// 소원 분석 응답 스키마 정의 (공감/희망/조언/응원 중심)
interface WishAnalysisResponse {
  empathy_message: string;      // 공감 메시지 (150자)
  hope_message: string;          // 희망과 격려 (200자)
  advice: string[];              // 구체적 조언 3개
  encouragement: string;         // 응원 메시지 (100자)
  special_words: string;         // 신의 한마디 (50자)
}

serve(async (req) => {
  // CORS preflight 처리
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { wish_text, category, urgency, user_profile } = await req.json()

    if (!wish_text || !category || !urgency) {
      throw new Error('필수 파라미터가 누락되었습니다: wish_text, category, urgency')
    }

    console.log('📝 소원 분석 요청:', { wish_text, category, urgency, user_profile })

    // OpenAI를 사용한 소원 분석 (F 유형 응답: 공감 → 희망 → 조언 → 응원)
    const aiPrompt = `당신은 따뜻한 마음을 가진 상담가이자 예언자입니다.
사용자의 소원에 깊이 공감하고, 희망과 용기를 주는 메시지를 전달해주세요.

[중요: F(Feeling) 유형처럼 응답하세요]
- 감정에 공감하고 위로부터 시작하세요
- 따뜻하고 인간적인 어투를 사용하세요
- 실현 가능성이나 점수보다는 "당신은 할 수 있어요" 메시지를 전달하세요
- 구체적이고 실용적인 조언을 포함하세요
- 점수, 확률, 통계 등 숫자 데이터는 절대 사용하지 마세요

사용자 소원: "${wish_text}"
카테고리: ${category}
긴급도: ${urgency}/5 (긴급도가 높을수록 더 강한 격려와 희망을 전달)
${user_profile ? `사용자 정보: 생년월일 ${user_profile.birth_date}, 띠 ${user_profile.zodiac}` : ''}

다음 JSON 형식으로 정확하게 응답해주세요:
{
  "empathy_message": "소원에 대한 깊은 공감과 이해를 표현 (150자 이내). 사용자의 마음을 진심으로 이해한다는 메시지",
  "hope_message": "희망적이고 격려하는 메시지 (200자 이내). '당신은 할 수 있어요', '반드시 이루어질 거예요' 톤으로 작성",
  "advice": [
    "실용적이고 구체적인 조언 1 (한 문장)",
    "실용적이고 구체적인 조언 2 (한 문장)",
    "실용적이고 구체적인 조언 3 (한 문장)"
  ],
  "encouragement": "따뜻한 응원과 마무리 메시지 (100자 이내). '힘내세요', '응원해요' 톤",
  "special_words": "신이 전하는 특별한 한마디 (50자 이내). 짧고 강렬한 격려"
}

필수 규칙:
1. 점수(score), 확률(probability), 통계(statistics) 등 숫자 데이터 절대 금지
2. 모든 메시지는 따뜻하고 희망적인 톤으로 작성
3. "당신은 할 수 있어요", "반드시 이루어질 거예요" 식의 긍정 메시지
4. ${category} 카테고리에 맞는 구체적이고 실행 가능한 조언 포함
5. 긴급도 ${urgency}/5에 비례하여 격려의 강도를 조절`

    const aiResponse = await fetch(OPENAI_API_URL, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${OPENAI_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-5-nano',
        messages: [
          {
            role: 'system',
            content: '당신은 따뜻한 마음을 가진 상담가이자 예언자입니다. F(Feeling) 유형처럼 감정에 공감하고, "당신은 할 수 있어요" 메시지로 희망과 용기를 줍니다. 점수/확률/통계 등 숫자는 절대 사용하지 않으며, 오직 공감과 격려에 집중합니다.'
          },
          {
            role: 'user',
            content: aiPrompt
          }
        ],
        response_format: { type: "json_object" }
      }),
    })

    if (!aiResponse.ok) {
      const errorText = await aiResponse.text()
      console.error('❌ OpenAI API 오류:', errorText)
      throw new Error(`OpenAI API 오류: ${aiResponse.status} ${errorText}`)
    }

    const aiData = await aiResponse.json()
    const content = aiData.choices[0].message.content

    console.log('✅ AI 응답 원본:', content)

    const analysisResult: WishAnalysisResponse = JSON.parse(content)

    console.log('✅ 파싱된 분석 결과:', analysisResult)

    // Supabase 클라이언트 생성
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    )

    // 결과를 DB에 저장
    const { data: userData } = await supabaseClient.auth.getUser()
    const userId = userData?.user?.id

    if (userId) {
      const { error: insertError } = await supabaseClient
        .from('wish_fortunes')
        .insert({
          user_id: userId,
          wish_text,
          category,
          urgency,
          empathy_message: analysisResult.empathy_message,
          hope_message: analysisResult.hope_message,
          advice: analysisResult.advice,
          encouragement: analysisResult.encouragement,
          special_words: analysisResult.special_words,
          wish_date: new Date().toISOString().split('T')[0], // YYYY-MM-DD
        })

      if (insertError) {
        console.error('⚠️ DB 저장 오류:', insertError)
        // 하루 1회 제한 위반 시 에러 반환
        if (insertError.code === '23505') { // UNIQUE constraint violation
          throw new Error('오늘은 이미 소원을 빌었습니다. 내일 다시 시도해주세요.')
        }
        // 기타 DB 오류는 결과 반환
      } else {
        console.log('✅ DB 저장 성공')
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        data: analysisResult
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )

  } catch (error) {
    console.error('❌ 소원 분석 오류:', error)

    return new Response(
      JSON.stringify({
        success: false,
        error: error.message,
        message: '소원 분석 중 오류가 발생했습니다'
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      }
    )
  }
})
