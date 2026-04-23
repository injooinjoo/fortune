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
import { deriveUserIdFromJwt } from '../_shared/auth.ts'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'
import { calculatePercentile, addPercentileToResult } from '../_shared/percentile/calculator.ts'
import { extractUsername, fetchInstagramProfileImage, downloadAndEncodeImage } from '../_shared/instagram/scraper.ts'
import {
  extractBlindDateCohort,
  generateCohortHash,
  getFromCohortPool,
  saveToCohortPool,
  personalize,
} from '../_shared/cohort/index.ts'

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

  // ✅ JSON 파싱 보호 - LLM이 불완전한 JSON 반환 시 기본값
  try {
    return JSON.parse(response.content);
  } catch (parseError) {
    console.error('❌ [analyzePhotosWithVision] JSON 파싱 실패:', parseError);
    console.error('❌ [analyzePhotosWithVision] LLM 원본 응답:', response.content?.substring(0, 500));
    // 기본값 반환 - 사진 분석 실패해도 운세는 계속 진행
    return {
      myAttractiveness: 75,
      myStyle: '분석 불가',
      myPersonality: '분석 불가',
      firstImpression: '사진 분석에 실패했습니다. 기본 분석으로 진행합니다.',
      recommendedDateStyle: '캐주얼한 카페 데이트'
    };
  }
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

  // ✅ JSON 파싱 보호 - LLM이 불완전한 JSON 반환 시 기본값
  try {
    return JSON.parse(response.content);
  } catch (parseError) {
    console.error('❌ [analyzeChatConversation] JSON 파싱 실패:', parseError);
    console.error('❌ [analyzeChatConversation] LLM 원본 응답:', response.content?.substring(0, 500));
    // 기본값 반환 - 대화 분석 실패해도 운세는 계속 진행
    return {
      interestLevel: 60,
      conversationStyle: '분석 불가',
      improvementTips: ['자연스럽게 대화를 이어가세요'],
      nextTopicSuggestions: ['취미', '여행', '맛집'],
    };
  }
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
    // SECURITY: body.userId / body.user_id 무시. JWT 에서만 파생.
    const userId = (await deriveUserIdFromJwt(req)) ?? 'anonymous'
    const isPremium = requestData.isPremium ?? requestData.is_premium ?? false
    const instagramUsername = requestData.instagramUsername || requestData.instagram_username

    console.log('📸 [BlindDate] Photo data:', {
      hasPhotoUrls: !!photoUrls,
      myPhotosCount: myPhotos.length,
      partnerPhotosCount: partnerPhotos.length,
      instagramUsername: instagramUsername || null
    })

    console.log('💎 [BlindDate] Premium 상태:', isPremium)

    // Instagram 프로필 이미지 가져오기
    let instagramError: string | null = null
    let instagramFetched = false
    const partnerPhotosWithInstagram = [...partnerPhotos]

    if (instagramUsername && partnerPhotos.length === 0) {
      try {
        console.log(`📷 [BlindDate] Instagram 프로필 이미지 가져오기: @${instagramUsername}`)
        const username = extractUsername(instagramUsername)
        const profileImageUrl = await fetchInstagramProfileImage(username)
        const base64Image = await downloadAndEncodeImage(profileImageUrl)
        partnerPhotosWithInstagram.push(base64Image)
        instagramFetched = true
        console.log(`✅ [BlindDate] Instagram 프로필 이미지 가져오기 성공: @${username}`)
      } catch (error) {
        console.error(`❌ [BlindDate] Instagram 프로필 이미지 가져오기 실패:`, error)
        instagramError = error instanceof Error ? error.message : '인스타그램 이미지를 가져올 수 없습니다.'
      }
    }

    // ✅ Cohort Pool에서 먼저 조회 (LLM 비용 90% 절감)
    const cohortData = extractBlindDateCohort({
      birthDate: requestData.birthDate,
      gender: requestData.gender,
      dateGoal: requestData.idealFirstDate, // 이상형 데이트 스타일로 dateGoal 추정
    })
    const cohortHash = await generateCohortHash(cohortData)
    console.log('💕 [Cohort] Cohort 추출:', JSON.stringify(cohortData), '| Hash:', cohortHash)

    const poolResult = await getFromCohortPool(supabaseClient, 'blind-date', cohortHash)
    if (poolResult) {
      console.log('💕 [Cohort] Pool HIT! - LLM 호출 생략')

      // 개인화 적용
      const personalizedResult = personalize(poolResult, {
        userName: requestData.name || '회원님',
        meetingDate: requestData.meetingDate || '오늘',
        meetingType: requestData.meetingType || '소개팅',
      })

      // Percentile 적용
      const percentileData = await calculatePercentile(supabaseClient, 'blind-date', personalizedResult.score || 70)
      const resultWithPercentile = addPercentileToResult(personalizedResult, percentileData)

      return new Response(
        JSON.stringify({ success: true, data: resultWithPercentile, cohortHit: true }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
      )
    }
    console.log('💕 [Cohort] Pool MISS - LLM 호출 필요')

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

      // 사진 분석 (Instagram 이미지 포함)
      if (analysisType === 'photos' || analysisType === 'comprehensive') {
        // ✅ 우선순위: my_photos/partner_photos (Base64 배열) > photoUrls (URL 배열)
        // ✅ Instagram에서 가져온 이미지도 partnerPhotosWithInstagram에 포함됨
        const myPhotoData = myPhotos.length > 0 ? myPhotos.map(b64 => `data:image/jpeg;base64,${b64}`) : (photoUrls?.myPhotos || [])
        const partnerPhotoData = partnerPhotosWithInstagram.length > 0 ? partnerPhotosWithInstagram.map(b64 => `data:image/jpeg;base64,${b64}`) : (photoUrls?.theirPhotos || [])

        console.log('📸 [BlindDate] Analyzing photos:', {
          myPhotoCount: myPhotoData.length,
          partnerPhotoCount: partnerPhotoData.length,
          fromInstagram: instagramFetched
        })

        if (partnerPhotoData.length > 0) {
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

다음 JSON 형식으로 응답해주세요. 절대로 "(xx자 이내)" 같은 글자수 지시문을 출력에 포함하지 마세요:
{
  "score": 0-100 사이의 점수,
  "content": "전체 분석",
  "summary": "한줄 요약 (점수 아래 표시, 20자 내외)",
  "overallAdvice": "종합 조언 (하이라이트 박스에 표시, 50자 내외)",
  "advice": "핵심 조언",
  "keyPoints": ["핵심 포인트1 (간결하게)", "핵심 포인트2 (간결하게)", "핵심 포인트3 (간결하게)"],
  "successPrediction": {
    "score": 0-100,
    "message": "예측 메시지",
    "advice": "성공을 위한 조언"
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
}

중요 규칙 (반드시 준수):
- "정보 부족", "알 수 없음", "중립적 평가", "정확한 판단이 어렵습니다" 같은 표현 절대 사용 금지
- 상대방 사진/정보가 없어도 사용자의 프로필과 상황만으로 긍정적이고 구체적인 조언 제공
- 모든 예측은 자신감 있게 표현하고, 확률/점수는 반드시 구체적인 숫자로 표현
- 불확실성을 표현하지 말고, 주어진 정보를 최대한 활용하여 실용적인 조언 제공`
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

      // ✅ JSON 파싱 보호 - LLM이 불완전한 JSON 반환 시 기본값
      let fortuneData: any;
      try {
        fortuneData = JSON.parse(response.content);
      } catch (parseError) {
        console.error('❌ [main fortune] JSON 파싱 실패:', parseError);
        console.error('❌ [main fortune] LLM 원본 응답:', response.content?.substring(0, 500));
        // 기본값으로 진행
        fortuneData = {
          score: 75,
          content: '소개팅 분석 결과입니다. 자신감을 가지고 임하세요.',
          summary: '좋은 인연이 기대됩니다',
          overallAdvice: '긍정적인 첫인상과 편안한 분위기를 통해 소개팅 성공을 기대할 수 있습니다.',
          advice: '자연스럽게 대화하며 상대방의 이야기에 귀 기울여보세요.',
          keyPoints: ['긍정적인 마음가짐이 좋은 결과로 이어집니다', '상대방의 이야기에 귀 기울여 보세요', '자연스러운 대화가 가장 매력적입니다'],
          successPrediction: { score: 70, message: '긍정적인 만남이 예상됩니다', advice: '자신감을 가지세요' },
          firstImpressionTips: ['미소를 잃지 마세요', '상대방 이야기에 집중하세요', '긍정적인 태도를 유지하세요'],
          conversationTopics: { recommended: ['취미', '여행', '맛집'], avoid: ['정치', '전 애인'] },
          outfitAdvice: { style: '깔끔하고 단정한 스타일', colors: ['네이비', '화이트'] },
          locationAdvice: ['분위기 좋은 카페', '조용한 레스토랑'],
          dosList: ['경청하기', '미소짓기', '질문하기'],
          dontsList: ['자기 자랑', '휴대폰 보기'],
          finalMessage: '좋은 인연이 되길 응원합니다!'
        };
      }

      const result = {
        // ✅ 표준화된 필드명: score, content, summary, advice
        score: fortuneData.score || fortuneData.overallScore || 75,
        content: fortuneData.content || '소개팅 분석 결과입니다.',
        summary: fortuneData.summary || '좋은 인연이 기대됩니다',
        overallAdvice: fortuneData.overallAdvice || '긍정적인 첫인상과 편안한 분위기를 통해 소개팅 성공을 기대할 수 있습니다.',
        advice: fortuneData.advice || fortuneData.successPrediction?.advice || '자신감을 가지고 임하세요',
        keyPoints: fortuneData.keyPoints || ['긍정적인 에너지가 좋은 만남으로 이어집니다', '상대방에게 관심을 표현해보세요', '자연스러운 모습이 가장 매력적입니다'],
        // 인포그래픽용 필드
        successRate: fortuneData.successPrediction?.score || 70,
        idealType: fortuneData.outfitAdvice?.style || '깔끔하고 단정한 스타일',
        tips: fortuneData.firstImpressionTips || ['미소를 잃지 마세요', '상대방 이야기에 집중하세요'],
        luckyPlace: fortuneData.locationAdvice?.[0] || '분위기 좋은 카페',
        fortuneType: 'blind-date',
        successPrediction: fortuneData.successPrediction,
        firstImpressionTips: fortuneData.firstImpressionTips,
        conversationTopics: fortuneData.conversationTopics,
        outfitAdvice: fortuneData.outfitAdvice,
        locationAdvice: fortuneData.locationAdvice,
        dosList: fortuneData.dosList,
        dontsList: fortuneData.dontsList,
        finalMessage: fortuneData.finalMessage,
        userInfo: { name, birthDate, gender, mbti },
        meetingInfo: { meetingDate, meetingTime, meetingType, introducer },
        analysisType,
        photoAnalysis: photoAnalysisResult,
        chatAnalysis: chatAnalysisResult,
        hasPhotoAnalysis: !!photoAnalysisResult || !!photoAnalysis,
        hasChatAnalysis: !!chatAnalysisResult,
        timestamp: new Date().toISOString(),
        // Instagram 관련 정보
        instagramUsername: instagramUsername || null,
        instagramFetched, // Instagram에서 이미지 가져왔는지
        instagramError // Instagram 에러 (비공개 계정 등)
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

      // ✅ Cohort Pool에 저장 (비동기, fire-and-forget)
      saveToCohortPool(supabaseClient, 'blind-date', cohortHash, cohortData, result)
        .catch(e => console.error('[BlindDate] Cohort 저장 오류:', e))

      // ✅ 퍼센타일 계산
      const percentileData = await calculatePercentile(supabaseClient, 'blind-date', result.score)
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
        error: '소개팅 인사이트 생성 중 오류가 발생했습니다.',
        details: error instanceof Error ? error.message : String(error)
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' }, status: 500 }
    )
  }
})
