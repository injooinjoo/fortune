import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.7.1'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// OpenAI API 설정
const OPENAI_API_KEY = Deno.env.get('OPENAI_API_KEY')
const OPENAI_API_URL = 'https://api.openai.com/v1/chat/completions'

// 소원 분석 응답 스키마 정의
interface WishAnalysisResponse {
  overall_score: number;
  divine_message: string;
  wish_analysis: {
    keywords: string[];
    emotion_level: 'high' | 'medium' | 'low';
    sincerity_score: number;
  };
  realization: {
    probability: number;
    conditions: string[];
    timeline: '단기(1개월)' | '중기(3개월)' | '장기(6개월+)';
  };
  lucky_elements: {
    color: string;
    color_hex: string;
    direction: '동' | '서' | '남' | '북';
    time: '새벽' | '오전' | '오후' | '저녁' | '밤';
  };
  warnings: string[];
  action_plan: string[];
  spiritual_message: string;
  statistics: {
    similar_wishes: number;
    success_rate: number;
  };
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

    // OpenAI GPT-4를 사용한 소원 분석
    const aiPrompt = `당신은 동양 철학과 영성에 정통한 신비로운 예언자입니다. 사용자의 소원을 깊이 분석하고 신의 응답을 전달해주세요.

사용자 소원: "${wish_text}"
카테고리: ${category}
긴급도: ${urgency}/5
${user_profile ? `사용자 정보: 생년월일 ${user_profile.birth_date}, 띠 ${user_profile.zodiac}` : ''}

다음 JSON 형식으로 정확하게 응답해주세요:
{
  "overall_score": 1-100 사이의 점수 (소원 실현 가능성),
  "divine_message": "300자 이내의 신의 메시지 (따뜻하고 희망적인 조언)",
  "wish_analysis": {
    "keywords": ["핵심키워드1", "핵심키워드2", "핵심키워드3"],
    "emotion_level": "high|medium|low" (소원의 감정 강도),
    "sincerity_score": 1-100 (진심도 점수)
  },
  "realization": {
    "probability": 1-100 (실현 확률 %),
    "conditions": ["실현 조건1", "실현 조건2", "실현 조건3"],
    "timeline": "단기(1개월)|중기(3개월)|장기(6개월+)"
  },
  "lucky_elements": {
    "color": "행운의 색상 이름",
    "color_hex": "#HEX 코드",
    "direction": "동|서|남|북",
    "time": "새벽|오전|오후|저녁|밤"
  },
  "warnings": ["주의사항1", "주의사항2", "주의사항3"],
  "action_plan": ["구체적 행동1", "구체적 행동2", "구체적 행동3"],
  "spiritual_message": "200자 이내의 심오한 영적 메시지",
  "statistics": {
    "similar_wishes": 1000-5000 사이의 숫자,
    "success_rate": 50-90 사이의 퍼센트
  }
}

중요: 응답은 반드시 유효한 JSON 형식이어야 하며, 모든 필드를 포함해야 합니다.
긴급도가 높을수록 더 강력하고 희망적인 메시지를 전달하세요.
${category}에 맞는 구체적이고 실용적인 조언을 제공하세요.`

    const aiResponse = await fetch(OPENAI_API_URL, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${OPENAI_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-4o-mini',
        messages: [
          {
            role: 'system',
            content: '당신은 동양 철학과 영성에 정통한 신비로운 예언자입니다. 사용자의 소원을 깊이 있게 분석하고, 따뜻하면서도 실용적인 조언을 제공합니다. 항상 희망과 용기를 주는 메시지를 전달하며, 구체적인 행동 방안을 제시합니다.'
          },
          {
            role: 'user',
            content: aiPrompt
          }
        ],
        temperature: 0.8,
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
          overall_score: analysisResult.overall_score,
          divine_message: analysisResult.divine_message,
          wish_analysis: analysisResult.wish_analysis,
          realization: analysisResult.realization,
          lucky_elements: analysisResult.lucky_elements,
          warnings: analysisResult.warnings,
          action_plan: analysisResult.action_plan,
          spiritual_message: analysisResult.spiritual_message,
          statistics: analysisResult.statistics,
        })

      if (insertError) {
        console.error('⚠️ DB 저장 오류:', insertError)
        // DB 저장 실패해도 결과는 반환
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
