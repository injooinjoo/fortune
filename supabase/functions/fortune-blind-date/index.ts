import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface BlindDateRequest {
  name: string;
  birthDate: string;
  gender: string;
  mbti?: string;
  meetingDate: string;
  meetingTime: string;
  meetingType: string;
  introducer: string;
  importantQualities: string[];
  agePreference: string;
  idealFirstDate: string;
  confidence: string;
  concerns?: string[];
  isFirstBlindDate?: boolean;
  photoAnalysis?: {
    myStyle: string;
    myPersonality: string;
    partnerStyle?: string;
    partnerPersonality?: string;
    matchingScore?: number;
  };
  userId?: string;
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    )

    const requestData = await req.json() as BlindDateRequest
    const {
      name, birthDate, gender, mbti,
      meetingDate, meetingTime, meetingType, introducer,
      importantQualities, agePreference, idealFirstDate,
      confidence, concerns = [], isFirstBlindDate = false,
      photoAnalysis, userId
    } = requestData

    // Cache key 생성
    const today = new Date().toISOString().split('T')[0]
    const cacheKey = `${userId || 'anonymous'}_blind-date_${today}_${meetingDate}_${confidence}`

    // fortune_cache 조회
    const { data: cachedResult } = await supabaseClient
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .eq('fortune_type', 'blind-date')
      .single()

    if (cachedResult) {
      return new Response(
        JSON.stringify({ success: true, data: cachedResult.result }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // OpenAI API 호출
    const controller = new AbortController()
    const timeoutId = setTimeout(() => controller.abort(), 30000)

    try {
      // 사진 분석이 있는 경우 추가 정보
      const photoAnalysisText = photoAnalysis ? `

사진 AI 분석 결과:
- 내 스타일: ${photoAnalysis.myStyle}
- 내 성격: ${photoAnalysis.myPersonality}
${photoAnalysis.partnerStyle ? `- 상대방 스타일: ${photoAnalysis.partnerStyle}` : ''}
${photoAnalysis.partnerPersonality ? `- 상대방 성격: ${photoAnalysis.partnerPersonality}` : ''}
${photoAnalysis.matchingScore ? `- 매칭 확률: ${photoAnalysis.matchingScore}%` : ''}
` : ''

      const openaiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${Deno.env.get('OPENAI_API_KEY')}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: 'gpt-4-turbo-preview',
          messages: [
            {
              role: 'system',
              content: `당신은 연애와 소개팅 전문 상담사입니다. 소개팅의 성공 가능성을 분석하고 실질적인 조언을 제공합니다.

다음 JSON 형식으로 응답해주세요:
{
  "overallScore": 0-100 사이의 점수 (소개팅 성공 확률),
  "content": "전체 분석 (300자 내외)",
  "successPrediction": {
    "score": 0-100,
    "message": "예측 메시지 (50자 내외)",
    "advice": "성공을 위한 조언 (150자 내외)"
  },
  "firstImpressionTips": ["첫인상 팁1", "첫인상 팁2", "첫인상 팁3"],
  "conversationTopics": {
    "recommended": ["추천 주제1", "추천 주제2", "추천 주제3"],
    "avoid": ["피할 주제1", "피할 주제2"]
  },
  "outfitAdvice": {
    "style": "스타일 추천 (100자 내외)",
    "colors": ["색상1", "색상2"]
  },
  "locationAdvice": ["장소 조언1", "장소 조언2"],
  "dosList": ["해야할 것1", "해야할 것2", "해야할 것3"],
  "dontsList": ["하지말아야할 것1", "하지말아야할 것2"],
  "finalMessage": "마지막 응원 메시지 (100자 내외)"
}`
            },
            {
              role: 'user',
              content: `이름: ${name}
생년월일: ${birthDate}
성별: ${gender}
MBTI: ${mbti || '알 수 없음'}

만남 정보:
- 날짜: ${new Date(meetingDate).toLocaleDateString('ko-KR')}
- 시간대: ${meetingTime}
- 방식: ${meetingType}
- 소개 경로: ${introducer}

선호 사항:
- 중요 요소: ${importantQualities.join(', ')}
- 나이 선호: ${agePreference}
- 이상적 데이트: ${idealFirstDate}

자기 평가:
- 자신감: ${confidence}
- 걱정: ${concerns.join(', ') || '없음'}
- 첫 소개팅: ${isFirstBlindDate ? '예' : '아니오'}
${photoAnalysisText}
현재 날짜: ${new Date().toLocaleDateString('ko-KR')}

위 정보를 바탕으로 소개팅 성공 가능성을 분석하고 실질적인 조언을 제공해주세요.`
            }
          ],
          response_format: { type: "json_object" },
          temperature: 0.7,
          max_tokens: 1500
        }),
        signal: controller.signal
      })

      if (!openaiResponse.ok) {
        throw new Error(`OpenAI API error: ${openaiResponse.status}`)
      }

      const openaiResult = await openaiResponse.json()
      const fortuneData = JSON.parse(openaiResult.choices[0].message.content)

      const result = {
        ...fortuneData,
        userInfo: { name, birthDate, gender, mbti },
        meetingInfo: { meetingDate, meetingTime, meetingType, introducer },
        hasPhotoAnalysis: !!photoAnalysis,
        timestamp: new Date().toISOString()
      }

      // fortune_cache에 저장
      await supabaseClient
        .from('fortune_cache')
        .insert({
          cache_key: cacheKey,
          fortune_type: 'blind-date',
          user_id: userId || null,
          result: result,
          created_at: new Date().toISOString()
        })

      return new Response(
        JSON.stringify({ success: true, data: result }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )

    } finally {
      clearTimeout(timeoutId)
    }

  } catch (error) {
    console.error('Blind Date Fortune API Error:', error)
    return new Response(
      JSON.stringify({
        success: false,
        error: '운세 생성 중 오류가 발생했습니다.',
        details: error instanceof Error ? error.message : String(error)
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
    )
  }
})
