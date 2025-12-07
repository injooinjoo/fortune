/**
 * 소개팅 운세 (Blind Date Fortune) Edge Function
 *
 * @description 소개팅 상대와의 궁합을 사진/사주 기반으로 분석합니다.
 *
 * @endpoint POST /fortune-blind-date
 *
 * @requestBody
 * - userId: string - 사용자 ID
 * - userBirthDate: string - 본인 생년월일
 * - partnerBirthDate?: string - 상대 생년월일
 * - partnerPhoto?: string - 상대 사진 (base64)
 * - meetingContext?: string - 만남 상황
 *
 * @response BlindDateResponse
 * - compatibility_score: number - 궁합 점수
 * - first_impression: string - 첫인상 분석
 * - conversation_tips: string[] - 대화 팁
 * - warning_signs: string[] - 주의점
 * - success_probability: number - 성공 확률
 * - advice: string - 조언
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'
import { calculatePercentile, addPercentileToResult } from '../_shared/percentile/calculator.ts'

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
  isPremium?: boolean; // ✅ 프리미엄 사용자 여부
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

  // ✅ LLM 모듈 사용 (동적 DB 설정 - A/B 테스트 지원)
  const llm = await LLMFactory.createFromConfigAsync('blind-date')
  const response = await llm.generate(messages, {
    temperature: 1,
    maxTokens: 8192,
    jsonMode: true
  })

  console.log(`✅ LLM (analyzeProfilePhoto): ${response.provider}/${response.model} - ${response.latency}ms`)

  // ✅ LLM 사용량 로깅 (비용/성능 분석용)
  await UsageLogger.log({
    fortuneType: 'blind-date-photo',
    provider: response.provider,
    model: response.model,
    response: response,
    metadata: { myPhotosCount: myPhotos.length, theirPhotosCount: theirPhotos.length }
  })

  if (!response.content) {
    throw new Error('LLM API 응답 없음');
  }

  return JSON.parse(response.content);
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
  // ✅ LLM 모듈 사용 (동적 DB 설정 - A/B 테스트 지원)
  const llm = await LLMFactory.createFromConfigAsync('blind-date')
  const response = await llm.generate([{
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
  }], {
    temperature: 1,
    maxTokens: 8192,
    jsonMode: true
  })

  console.log(`✅ LLM (analyzeChatConversation): ${response.provider}/${response.model} - ${response.latency}ms`)

  // ✅ LLM 사용량 로깅 (비용/성능 분석용)
  await UsageLogger.log({
    fortuneType: 'blind-date-chat',
    provider: response.provider,
    model: response.model,
    response: response,
    metadata: { chatPlatform, chatLength: chatContent.length }
  })

  if (!response.content) {
    throw new Error('LLM API 응답 없음');
  }

  return JSON.parse(response.content);
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

    const requestData = await req.json() as any // Handle both camelCase and snake_case

    // Support both camelCase (from Flutter) and snake_case
    const name = requestData.name
    const birthDate = requestData.birthDate || requestData.birth_date
    const gender = requestData.gender
    const mbti = requestData.mbti
    const meetingDate = requestData.meetingDate || requestData.meeting_date
    const meetingTime = requestData.meetingTime || requestData.meeting_time
    const meetingType = requestData.meetingType || requestData.meeting_type
    const introducer = requestData.introducer
    const importantQualities = requestData.importantQualities || requestData.important_qualities || []
    const agePreference = requestData.agePreference || requestData.age_preference
    const idealFirstDate = requestData.idealFirstDate || requestData.ideal_first_date
    const confidence = requestData.confidence
    const concerns = requestData.concerns || []
    const isFirstBlindDate = requestData.isFirstBlindDate || requestData.is_first_blind_date || false
    const analysisType = requestData.analysisType || requestData.analysis_type || 'basic'
    const photoUrls = requestData.photoUrls || requestData.photo_urls
    // ✅ my_photos/partner_photos도 지원 (Base64 배열)
    const myPhotos = requestData.my_photos || requestData.myPhotos || []
    const partnerPhotos = requestData.partner_photos || requestData.partnerPhotos || []
    const chatContent = requestData.chatContent || requestData.chat_content
    const chatPlatform = requestData.chatPlatform || requestData.chat_platform
    const photoAnalysis = requestData.photoAnalysis || requestData.photo_analysis
    const userId = requestData.userId || requestData.user_id
    const isPremium = requestData.isPremium ?? requestData.is_premium ?? false

    console.log('📸 [BlindDate] Photo data:', {
      hasPhotoUrls: !!photoUrls,
      myPhotosCount: myPhotos.length,
      partnerPhotosCount: partnerPhotos.length
    })

    console.log('💎 [BlindDate] Premium 상태:', isPremium)

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
        { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
      )
    }

    // OpenAI API 호출
    const controller = new AbortController()
    const timeoutId = setTimeout(() => controller.abort(), 45000) // 45초로 증가 (Vision/Chat 분석 시간 고려)

    try {
      let photoAnalysisResult: any = null;
      let chatAnalysisResult: any = null;

      // 사진 분석
      if (analysisType === 'photos' || analysisType === 'comprehensive') {
        // ✅ 우선순위: my_photos/partner_photos (Base64 배열) > photoUrls (URL 배열)
        const myPhotoData = myPhotos.length > 0 ? myPhotos.map(b64 => `data:image/jpeg;base64,${b64}`) : (photoUrls?.myPhotos || [])
        const partnerPhotoData = partnerPhotos.length > 0 ? partnerPhotos.map(b64 => `data:image/jpeg;base64,${b64}`) : (photoUrls?.theirPhotos || [])

        console.log('📸 [BlindDate] Analyzing photos:', {
          myPhotoCount: myPhotoData.length,
          partnerPhotoCount: partnerPhotoData.length
        })

        if (myPhotoData.length > 0) {
          photoAnalysisResult = await analyzePhotosWithVision(
            myPhotoData,
            partnerPhotoData
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
- 개선 포인트: ${Array.isArray(chatAnalysisResult.improvementTips) ? chatAnalysisResult.improvementTips.join(', ') : '없음'}
- 다음 대화 주제 추천: ${Array.isArray(chatAnalysisResult.nextTopicSuggestions) ? chatAnalysisResult.nextTopicSuggestions.join(', ') : '없음'}
${chatAnalysisResult.redFlags && Array.isArray(chatAnalysisResult.redFlags) && chatAnalysisResult.redFlags.length > 0 ? `⚠️ 경고 신호: ${chatAnalysisResult.redFlags.join(', ')}` : ''}
` : ''

      // ✅ LLM 모듈 사용 (동적 DB 설정 - A/B 테스트 지원)
      const llm = await LLMFactory.createFromConfigAsync('blind-date')
      const response = await llm.generate([
        {
          role: 'system',
          content: `당신은 연애와 소개팅 전문 상담사입니다. 소개팅의 성공 가능성을 분석하고 실질적인 조언을 제공합니다.

다음 JSON 형식으로 응답해주세요:
{
  "overallScore": 0-100 사이의 점수 (소개팅 성공 확률),
  "content": "전체 분석 (100자 이내)",
  "successPrediction": {
    "score": 0-100,
    "message": "예측 메시지 (30자 이내)",
    "advice": "성공을 위한 조언 (80자 이내)"
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
- 중요 요소: ${Array.isArray(importantQualities) && importantQualities.length > 0 ? importantQualities.join(', ') : '알 수 없음'}
- 나이 선호: ${agePreference || '알 수 없음'}
- 이상적 데이트: ${idealFirstDate || '알 수 없음'}

자기 평가:
- 자신감: ${confidence || '알 수 없음'}
- 걱정: ${Array.isArray(concerns) && concerns.length > 0 ? concerns.join(', ') : '없음'}
- 첫 소개팅: ${isFirstBlindDate ? '예' : '아니오'}
${photoAnalysisText}${chatAnalysisText}
현재 날짜: ${new Date().toLocaleDateString('ko-KR')}

위 정보를 바탕으로 소개팅 성공 가능성을 분석하고 실질적인 조언을 제공해주세요.`
        }
      ], {
        temperature: 0.7,
        maxTokens: 1500,
        jsonMode: true
      })

      console.log(`✅ LLM (main fortune): ${response.provider}/${response.model} - ${response.latency}ms`)

      // ✅ LLM 사용량 로깅 (비용/성능 분석용)
      await UsageLogger.log({
        fortuneType: 'blind-date',
        userId: userId,
        provider: response.provider,
        model: response.model,
        response: response,
        metadata: { analysisType, isPremium, hasPhotoAnalysis: !!photoAnalysisResult, hasChatAnalysis: !!chatAnalysisResult }
      })

      if (!response.content) {
        throw new Error('LLM API 응답 없음')
      }

      const fortuneData = JSON.parse(response.content)

      // ✅ Blur 로직 적용
      const isBlurred = !isPremium
      const blurredSections = isBlurred
        ? ['successPrediction', 'firstImpressionTips', 'conversationTopics', 'outfitAdvice', 'locationAdvice', 'dosList', 'dontsList', 'finalMessage']
        : []

      const result = {
        overallScore: fortuneData.overallScore, // ✅ 무료: 공개
        content: fortuneData.content, // ✅ 무료: 공개
        successPrediction: isBlurred ? { score: 0, message: '🔒 프리미엄 전용', advice: '🔒 프리미엄 결제 후 확인 가능합니다' } : fortuneData.successPrediction, // 🔒 유료
        firstImpressionTips: isBlurred ? ['🔒 프리미엄 결제 후 확인 가능합니다'] : fortuneData.firstImpressionTips, // 🔒 유료
        conversationTopics: isBlurred ? { recommended: ['🔒 프리미엄 전용'], avoid: ['🔒 프리미엄 전용'] } : fortuneData.conversationTopics, // 🔒 유료
        outfitAdvice: isBlurred ? { style: '🔒 프리미엄 결제 후 확인 가능합니다', colors: ['🔒 프리미엄 전용'] } : fortuneData.outfitAdvice, // 🔒 유료
        locationAdvice: isBlurred ? ['🔒 프리미엄 결제 후 확인 가능합니다'] : fortuneData.locationAdvice, // 🔒 유료
        dosList: isBlurred ? ['🔒 프리미엄 결제 후 확인 가능합니다'] : fortuneData.dosList, // 🔒 유료
        dontsList: isBlurred ? ['🔒 프리미엄 결제 후 확인 가능합니다'] : fortuneData.dontsList, // 🔒 유료
        finalMessage: isBlurred ? '🔒 프리미엄 결제 후 확인 가능합니다' : fortuneData.finalMessage, // 🔒 유료
        userInfo: { name, birthDate, gender, mbti },
        meetingInfo: { meetingDate, meetingTime, meetingType, introducer },
        analysisType,
        photoAnalysis: photoAnalysisResult,
        chatAnalysis: chatAnalysisResult,
        hasPhotoAnalysis: !!photoAnalysisResult || !!photoAnalysis,
        hasChatAnalysis: !!chatAnalysisResult,
        timestamp: new Date().toISOString(),
        isBlurred, // ✅ 블러 상태
        blurredSections // ✅ 블러된 섹션 목록
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

      // ✅ 퍼센타일 계산
      const percentileData = await calculatePercentile(supabaseClient, 'blind-date', result.overallScore)
      const resultWithPercentile = addPercentileToResult(result, percentileData)

      return new Response(
        JSON.stringify({ success: true, data: resultWithPercentile }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
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
      { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' }, status: 500 }
    )
  }
})
