import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface BlindDateRequest {
  // Basic Info (기존)
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

  // Analysis Type
  analysisType: 'basic' | 'photos' | 'chat' | 'comprehensive';

  // Photo Analysis
  photoUrls?: {
    myPhotos?: string[];
    theirPhotos?: string[];
  };

  // Chat Analysis
  chatContent?: string;
  chatPlatform?: 'kakao' | 'sms' | 'instagram' | 'other';

  // Legacy support
  photoAnalysis?: {
    myStyle: string;
    myPersonality: string;
    partnerStyle?: string;
    partnerPersonality?: string;
    matchingScore?: number;
  };

  userId?: string;
}

// GPT-4 Vision으로 사진 분석
async function analyzePhotosWithVision(
  myPhotos: string[],
  theirPhotos: string[]
): Promise<{
  myAttractiveness: number;
  theirAttractiveness?: number;
  visualCompatibility?: number;
  myStyle: string;
  myPersonality: string;
  theirStyle?: string;
  theirPersonality?: string;
  firstImpression: string;
  recommendedDateStyle: string;
}> {
  const messages: any[] = [{
    role: "system",
    content: "당신은 소개팅 전문 이미지 분석가입니다. 사진을 보고 외모, 스타일, 성격을 분석합니다."
  }];

  const userContent: any[] = [{
    type: "text",
    text: `다음 사진들을 분석해주세요:
${myPhotos.length > 0 ? `내 사진: ${myPhotos.length}장` : ''}
${theirPhotos.length > 0 ? `상대방 사진: ${theirPhotos.length}장` : ''}

JSON 형식으로 응답:
{
  "myAttractiveness": 0-100,
  "theirAttractiveness": 0-100 (상대 사진 있을 때만),
  "visualCompatibility": 0-100 (상대 사진 있을 때만),
  "myStyle": "스타일 설명",
  "myPersonality": "추측되는 성격",
  "theirStyle": "상대 스타일 설명" (있을 때만),
  "theirPersonality": "상대 성격 추측" (있을 때만),
  "firstImpression": "첫인상 예측",
  "recommendedDateStyle": "추천 데이트 스타일"
}`
  }];

  // Add my photos
  for (const photoUrl of myPhotos.slice(0, 3)) {
    userContent.push({ type: "image_url", image_url: { url: photoUrl } });
  }

  // Add their photos
  for (const photoUrl of theirPhotos.slice(0, 3)) {
    userContent.push({ type: "image_url", image_url: { url: photoUrl } });
  }

  messages.push({ role: "user", content: userContent });

  const openaiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${Deno.env.get('OPENAI_API_KEY')}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: 'gpt-5-nano-2025-08-07',
      messages,
      response_format: { type: "json_object" },
      max_tokens: 800
    })
  });

  if (!openaiResponse.ok) {
    throw new Error(`GPT-4 Vision API error: ${openaiResponse.status}`);
  }

  const result = await openaiResponse.json();
  return JSON.parse(result.choices[0].message.content);
}

// GPT-4로 대화 분석
async function analyzeChatConversation(
  chatContent: string,
  chatPlatform: string
): Promise<{
  interestLevel: number;
  conversationStyle: string;
  improvementTips: string[];
  nextTopicSuggestions: string[];
  redFlags?: string[];
}> {
  const openaiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${Deno.env.get('OPENAI_API_KEY')}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: 'gpt-5-nano-2025-08-07',
      messages: [{
        role: "system",
        content: "당신은 연애 대화 분석 전문가입니다. 소개팅 대화를 분석하여 상대방의 관심도와 개선점을 찾아냅니다."
      }, {
        role: "user",
        content: `다음은 ${chatPlatform}에서 나눈 대화입니다:

${chatContent}

JSON 형식으로 분석:
{
  "interestLevel": 0-100 (상대방 호감도),
  "conversationStyle": "대화 스타일 분석",
  "improvementTips": ["개선점1", "개선점2", "개선점3"],
  "nextTopicSuggestions": ["다음 주제1", "다음 주제2", "다음 주제3"],
  "redFlags": ["경고 신호1", "경고 신호2"] (있을 경우만)
}`
      }],
      response_format: { type: "json_object" },
      temperature: 0.7,
      max_tokens: 600
    })
  });

  if (!openaiResponse.ok) {
    throw new Error(`GPT-4 Chat Analysis error: ${openaiResponse.status}`);
  }

  const result = await openaiResponse.json();
  return JSON.parse(result.choices[0].message.content);
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
      analysisType = 'basic',
      photoUrls,
      chatContent,
      chatPlatform,
      photoAnalysis,
      userId
    } = requestData

    // Cache key 생성
    const today = new Date().toISOString().split('T')[0]
    const cacheKey = `${userId || 'anonymous'}_blind-date_${today}_${analysisType}_${meetingDate}_${confidence}`

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
    const timeoutId = setTimeout(() => controller.abort(), 45000) // 45초로 증가 (Vision/Chat 분석 시간 고려)

    try {
      let photoAnalysisResult: any = null;
      let chatAnalysisResult: any = null;

      // 사진 분석 (새로운 방식)
      if (analysisType === 'photos' || analysisType === 'comprehensive') {
        if (photoUrls?.myPhotos && photoUrls.myPhotos.length > 0) {
          photoAnalysisResult = await analyzePhotosWithVision(
            photoUrls.myPhotos,
            photoUrls.theirPhotos || []
          );
        }
      }

      // 대화 분석
      if (analysisType === 'chat' || analysisType === 'comprehensive') {
        if (chatContent && chatPlatform) {
          chatAnalysisResult = await analyzeChatConversation(chatContent, chatPlatform);
        }
      }

      // 사진 분석 텍스트 (레거시 + 새 방식 통합)
      const photoAnalysisText = photoAnalysisResult ? `

🖼️ 사진 AI 분석 결과:
- 내 매력도: ${photoAnalysisResult.myAttractiveness}/100
- 내 스타일: ${photoAnalysisResult.myStyle}
- 내 성격 (추측): ${photoAnalysisResult.myPersonality}
${photoAnalysisResult.theirAttractiveness ? `- 상대 매력도: ${photoAnalysisResult.theirAttractiveness}/100` : ''}
${photoAnalysisResult.theirStyle ? `- 상대 스타일: ${photoAnalysisResult.theirStyle}` : ''}
${photoAnalysisResult.theirPersonality ? `- 상대 성격: ${photoAnalysisResult.theirPersonality}` : ''}
${photoAnalysisResult.visualCompatibility ? `- 비주얼 궁합: ${photoAnalysisResult.visualCompatibility}/100` : ''}
- 첫인상 예측: ${photoAnalysisResult.firstImpression}
- 추천 데이트: ${photoAnalysisResult.recommendedDateStyle}
` : (photoAnalysis ? `

사진 AI 분석 결과:
- 내 스타일: ${photoAnalysis.myStyle}
- 내 성격: ${photoAnalysis.myPersonality}
${photoAnalysis.partnerStyle ? `- 상대방 스타일: ${photoAnalysis.partnerStyle}` : ''}
${photoAnalysis.partnerPersonality ? `- 상대방 성격: ${photoAnalysis.partnerPersonality}` : ''}
${photoAnalysis.matchingScore ? `- 매칭 확률: ${photoAnalysis.matchingScore}%` : ''}
` : '')

      // 대화 분석 텍스트
      const chatAnalysisText = chatAnalysisResult ? `

💬 대화 AI 분석 결과:
- 상대방 호감도: ${chatAnalysisResult.interestLevel}/100
- 대화 스타일: ${chatAnalysisResult.conversationStyle}
- 개선 포인트: ${chatAnalysisResult.improvementTips.join(', ')}
- 다음 대화 주제 추천: ${chatAnalysisResult.nextTopicSuggestions.join(', ')}
${chatAnalysisResult.redFlags && chatAnalysisResult.redFlags.length > 0 ? `⚠️ 경고 신호: ${chatAnalysisResult.redFlags.join(', ')}` : ''}
` : ''

      const openaiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${Deno.env.get('OPENAI_API_KEY')}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: 'gpt-5-nano-2025-08-07',
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
${photoAnalysisText}${chatAnalysisText}
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
        analysisType,
        photoAnalysis: photoAnalysisResult,
        chatAnalysis: chatAnalysisResult,
        hasPhotoAnalysis: !!photoAnalysisResult || !!photoAnalysis,
        hasChatAnalysis: !!chatAnalysisResult,
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
