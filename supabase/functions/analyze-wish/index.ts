/**
 * 소원 분석 (Analyze Wish) Edge Function
 *
 * @description 사용자의 소원을 AI가 분석하여 공감 메시지, 희망의 말, 조언을 제공합니다.
 *
 * @endpoint POST /analyze-wish
 *
 * @requestBody
 * - wish_text: string - 소원 내용 (필수)
 * - category: string - 소원 카테고리 (필수)
 * - urgency?: number - 긴급도 (1-5, 기본값: 3)
 * - user_profile?: object - 사용자 프로필 정보
 *
 * @response WishAnalysisResponse
 * - empathy_message: string - 공감 메시지 (150자)
 * - hope_message: string - 희망과 격려 (200자)
 * - advice: string[] - 구체적 조언 3개
 * - encouragement: string - 응원 메시지 (100자)
 * - special_words: string - 신의 한마디 (50자)
 *
 * @example
 * // Request
 * {
 *   "wish_text": "취업에 성공하고 싶어요",
 *   "category": "career",
 *   "urgency": 4
 * }
 *
 * // Response
 * {
 *   "success": true,
 *   "data": {
 *     "empathy_message": "취업 준비의 어려움을 잘 알고 있어요...",
 *     "hope_message": "당신의 노력은 반드시 빛을 발할 거예요...",
 *     "advice": ["이력서를 업데이트하세요", "네트워킹을 넓히세요", ...],
 *     "encouragement": "포기하지 마세요!",
 *     "special_words": "기회는 준비된 자에게 온다"
 *   }
 * }
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.7.1'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// ✅ LLM 모듈 사용 (OpenAI API 설정 제거)

// 소원 분석 응답 스키마 정의 (용 테마 + 게이미피케이션)
interface WishAnalysisResponse {
  // 기존 필드
  empathy_message: string;       // 공감 메시지 (300자)
  hope_message: string;          // 희망과 격려 (400자)
  advice: string[];              // 구체적 조언 3개
  encouragement: string;         // 응원 메시지 (200자)
  special_words: string;         // 신의 한마디 (50자)

  // 🆕 운의 흐름 (데이터 기반 느낌)
  fortune_flow: {
    achievement_level: string;   // "매우 높음" | "높음" | "보통" | "노력 필요"
    lucky_timing: string;        // "오후 2시~4시" 형식
    keywords: string[];          // 3개 해시태그 ["#인연", "#결단", "#기다림"]
    helper: string;              // 도움이 되는 사람/행동
    obstacle: string;            // 주의해야 할 행동
  };

  // 🆕 행운의 미션 (게이미피케이션)
  lucky_mission: {
    item: string;                // "주머니에 동전 하나"
    item_reason: string;         // 왜 이 아이템인지
    place: string;               // "탁 트인 공원"
    place_reason: string;        // 왜 이 장소인지
    color: string;               // "파란색"
    color_reason: string;        // 왜 이 색상인지
  };

  // 🆕 용의 메시지 (스토리텔링)
  dragon_message: {
    pearl_message: string;       // 여의주 메시지
    wisdom: string;              // 용의 지혜
    power_line: string;          // 짧고 강렬한 한마디 (소원 키워드 포함)
  };
}

/**
 * LLM 응답에서 JSON 추출
 * - ```json ... ``` 마크다운 코드블록 처리
 * - ``` ... ``` 일반 코드블록 처리
 * - 순수 JSON 처리
 * - 앞뒤 텍스트가 있는 JSON 처리
 */
function extractJsonFromResponse(content: string): string {
  // 1. ```json ... ``` 패턴 추출
  const jsonBlockMatch = content.match(/```json\s*([\s\S]*?)```/)
  if (jsonBlockMatch) {
    console.log('📦 JSON 코드블록에서 추출')
    return jsonBlockMatch[1].trim()
  }

  // 2. ``` ... ``` 패턴 추출
  const codeBlockMatch = content.match(/```\s*([\s\S]*?)```/)
  if (codeBlockMatch) {
    console.log('📦 코드블록에서 추출')
    return codeBlockMatch[1].trim()
  }

  // 3. { ... } 패턴 추출 (가장 바깥쪽 중괄호)
  const jsonMatch = content.match(/\{[\s\S]*\}/)
  if (jsonMatch) {
    console.log('📦 중괄호에서 추출')
    return jsonMatch[0].trim()
  }

  // 4. 원본 반환
  console.log('📦 원본 사용')
  return content.trim()
}

serve(async (req) => {
  // CORS preflight 처리
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { wish_text, category, urgency: rawUrgency, user_profile } = await req.json()

    if (!wish_text || !category) {
      throw new Error('필수 파라미터가 누락되었습니다: wish_text, category')
    }

    // urgency는 선택적 (기본값: 3 - 보통)
    const urgency = rawUrgency ?? 3

    console.log('📝 소원 분석 요청:', { wish_text, category, urgency, user_profile })

    // ✅ 용 테마 소원 분석 프롬프트: 청룡 현자 + 게이미피케이션 + 개인화
    // 소원 키워드 추출 (power_line에 사용)
    const wishKeyword = wish_text.length > 10 ? wish_text.substring(0, 10) + '...' : wish_text

    // 카테고리별 행운 색상 매핑
    const categoryColorMap: Record<string, string> = {
      'love': '분홍색',
      'money': '금색',
      'health': '초록색',
      'success': '빨간색',
      'family': '노란색',
      'study': '파란색',
      'career': '남색',
      'other': '보라색'
    }
    const luckyColorHint = categoryColorMap[category] || '파란색'

    const aiPrompt = `당신은 **용의 여의주를 관장하는 청룡 현자**입니다.
사용자의 소원을 듣고, 여의주의 빛으로 그 소원의 운명을 읽습니다.
동양의 신비로운 용의 지혜로 따뜻한 공감과 구체적인 행운 미션을 전달합니다.

🐉 **청룡 현자의 역할**:
1. 소원에 담긴 진심을 읽고 깊이 공감합니다
2. 여의주의 빛으로 성취 가능성을 봅니다 (텍스트로 표현, 숫자 금지)
3. 오늘 당장 실천할 수 있는 구체적인 행운 미션을 제시합니다
4. 용의 지혜로 깊이 있는 조언을 전달합니다
5. 소원 키워드를 메시지에 직접 포함하여 개인화합니다

📋 **사용자 소원 정보**:
- 소원: "${wish_text}"
- 소원 키워드: "${wishKeyword}"
- 카테고리: ${category}
- 긴급도: ${urgency}/5
${user_profile ? `- 생년월일: ${user_profile.birth_date}, 띠: ${user_profile.zodiac}` : ''}
- 추천 행운 색상: ${luckyColorHint} (카테고리 기반)

반드시 다음 JSON 형식으로만 응답하세요:

{
  "empathy_message": "소원에 담긴 진심을 읽어내고 공감하는 메시지 (300자). 형식적인 위로가 아닌 진심어린 공감.",
  "hope_message": "왜 이 소원이 이루어질 수 있는지 구체적인 이유와 함께 희망을 전달 (400자)",
  "advice": ["오늘부터 실천할 수 있는 구체적인 조언 1 (100자)", "카테고리에 맞는 구체적인 조언 2 (100자)", "작은 성공을 쌓는 조언 3 (100자)"],
  "encouragement": "혼자가 아니라는 것, 당신을 응원한다는 진심어린 메시지 (200자)",
  "special_words": "소원의 핵심을 관통하는 짧고 강렬한 한마디 (50자)",

  "fortune_flow": {
    "achievement_level": "매우 높음 | 높음 | 보통 | 노력 필요 중 하나",
    "lucky_timing": "오후 2시~4시 형식의 행운의 시간대",
    "keywords": ["#키워드1", "#키워드2", "#키워드3"],
    "helper": "도움이 되는 사람이나 행동 (예: 띠가 같은 사람, 파란 옷을 입은 사람)",
    "obstacle": "주의해야 할 행동 (예: 성급한 결정, 늦은 밤 외출)"
  },

  "lucky_mission": {
    "item": "오늘 가지고 다닐 행운 아이템 (예: 주머니에 동전 하나)",
    "item_reason": "왜 이 아이템이 행운을 가져오는지 (미신적이고 재미있게)",
    "place": "행운의 장소 (예: 탁 트인 공원, 조용한 카페)",
    "place_reason": "왜 이 장소가 좋은지",
    "color": "${luckyColorHint}",
    "color_reason": "왜 이 색상이 오늘의 행운색인지 (카테고리와 연결)"
  },

  "dragon_message": {
    "pearl_message": "오늘 당신의 소원이 용의 여의주에 닿았습니다. 빛이 밝으니 곧 소식이 오겠군요. (100자, 여의주 테마)",
    "wisdom": "용의 지혜로운 조언. 서두르지 말고 기다리라는 등의 깊이 있는 메시지 (150자)",
    "power_line": "청룡의 기운이 당신의 [${wishKeyword}]을 지켜보고 있습니다. 당당하게 행동하세요. (소원 키워드 포함, 50자)"
  }
}

⚠️ **절대 금지 사항**:
1. ❌ 점수, 확률, 퍼센트 등 숫자 데이터 (achievement_level은 텍스트로)
2. ❌ "열심히 하세요", "노력하세요" 같은 뻔한 조언
3. ❌ 형식적이거나 복붙한 것 같은 위로
4. ❌ 과장되거나 비현실적인 낙관주의

✅ **필수 포함 사항**:
1. ✅ power_line에 반드시 소원 키워드 "${wishKeyword}" 포함
2. ✅ 구체적이고 재미있는 행운 미션 (미신적 요소 가미)
3. ✅ 용 테마의 신비로운 분위기
4. ✅ 카테고리별 맞춤 행운 색상 활용
5. ✅ 오늘부터 당장 실천 가능한 조언

💡 **톤 & 보이스**:
- 신비롭지만 따뜻한 동양의 현자처럼
- 용의 위엄과 자비로움을 동시에
- 재미있고 구체적인 행운 미션
- 개인화된 메시지로 "나를 위한" 느낌`

    // ✅ LLM 모듈 사용 (동적 DB 설정 - A/B 테스트 지원)
    const llm = await LLMFactory.createFromConfigAsync('wish')

    const response = await llm.generate([
      {
        role: 'system',
        content: `당신은 **용의 여의주를 관장하는 청룡 현자**입니다.
하늘 높이 구름 사이에서 천 년을 살아온 지혜로운 용이며, 인간의 소원을 듣고 여의주의 빛으로 그 운명을 읽습니다.

🐉 **청룡 현자의 정체성**:
- 동양 신화의 청룡(靑龍)으로, 동쪽을 수호하며 봄과 희망을 상징합니다
- 여의주(如意珠)를 품고 있어 소원을 읽는 신비로운 능력이 있습니다
- 위엄 있지만 자비롭고, 신비롭지만 따뜻한 어조로 말합니다

✨ **응답 원칙**:
1. 신비로운 용의 관점에서 소원을 해석합니다 ("여의주에 비친 당신의 소원을 보니...")
2. 텍스트로만 성취 가능성을 표현합니다 (숫자/점수/확률 절대 금지)
3. 구체적이고 재미있는 행운 미션을 제시합니다 (미신적 요소 가미)
4. 소원 키워드를 power_line에 반드시 포함합니다
5. 뻔한 조언("노력하세요") 대신 오늘 당장 실천 가능한 행동을 제안합니다

💎 **여의주의 지혜**:
- 성급함보다 기다림의 가치를 알려줍니다
- 작은 행동이 큰 변화를 만든다는 것을 일깨웁니다
- 혼자가 아니라는 것, 용이 지켜보고 있다는 안도감을 줍니다

🎯 **목표**: 사용자가 "정말 특별한 경험이다", "용이 나를 지켜보고 있구나", "해볼 수 있겠다"고 느끼도록 합니다.`
      },
      {
        role: 'user',
        content: aiPrompt
      }
    ], {
      temperature: 1,
      maxTokens: 8192,
      jsonMode: true
    })

    console.log(`✅ LLM 호출 완료: ${response.provider}/${response.model} - ${response.latency}ms`)
    console.log('✅ AI 응답 원본:', response.content)

    // ✅ LLM 사용량 로깅 (비용/성능 분석용)
    await UsageLogger.log({
      fortuneType: 'analyze-wish',
      provider: response.provider,
      model: response.model,
      response: response,
      metadata: { category, urgency }
    })

    if (!response.content) {
      throw new Error('LLM API 응답 없음')
    }

    // ✅ JSON 추출 및 파싱
    let analysisResult: WishAnalysisResponse
    try {
      const jsonString = extractJsonFromResponse(response.content)
      console.log('📦 추출된 JSON (앞 500자):', jsonString.substring(0, 500))
      analysisResult = JSON.parse(jsonString)

      // 필수 필드 검증 (기존 + 새 필드)
      const requiredFields = ['empathy_message', 'hope_message', 'advice', 'encouragement', 'special_words', 'fortune_flow', 'lucky_mission', 'dragon_message']
      for (const field of requiredFields) {
        if (!(field in analysisResult)) {
          console.error(`❌ LLM 응답에 필수 필드 누락: ${field}`)
          console.error('수신된 응답:', JSON.stringify(analysisResult, null, 2))
          throw new Error(`LLM 응답 검증 실패: ${field} 필드 누락`)
        }
      }

      // advice 배열 검증
      if (!Array.isArray(analysisResult.advice) || analysisResult.advice.length === 0) {
        console.error('❌ advice 필드가 배열이 아니거나 비어있음')
        throw new Error('LLM 응답 검증 실패: advice 필드가 유효하지 않음')
      }

      // 🆕 fortune_flow 필드 검증
      const fortuneFlow = analysisResult.fortune_flow
      if (!fortuneFlow || !fortuneFlow.achievement_level || !fortuneFlow.lucky_timing || !Array.isArray(fortuneFlow.keywords) || fortuneFlow.keywords.length < 3) {
        console.error('❌ fortune_flow 필드가 불완전함:', fortuneFlow)
        throw new Error('LLM 응답 검증 실패: fortune_flow 필드가 유효하지 않음')
      }

      // 🆕 lucky_mission 필드 검증
      const luckyMission = analysisResult.lucky_mission
      if (!luckyMission || !luckyMission.item || !luckyMission.place || !luckyMission.color) {
        console.error('❌ lucky_mission 필드가 불완전함:', luckyMission)
        throw new Error('LLM 응답 검증 실패: lucky_mission 필드가 유효하지 않음')
      }

      // 🆕 dragon_message 필드 검증
      const dragonMessage = analysisResult.dragon_message
      if (!dragonMessage || !dragonMessage.pearl_message || !dragonMessage.wisdom || !dragonMessage.power_line) {
        console.error('❌ dragon_message 필드가 불완전함:', dragonMessage)
        throw new Error('LLM 응답 검증 실패: dragon_message 필드가 유효하지 않음')
      }
    } catch (parseError) {
      if (parseError instanceof SyntaxError) {
        console.error('❌ JSON 파싱 실패:', parseError)
        console.error('원본 응답:', response.content)
        return new Response(
          JSON.stringify({
            success: false,
            error: 'LLM 응답 파싱 실패',
            message: '소원 분석 응답을 처리할 수 없습니다',
            code: 'PARSE_ERROR',
          }),
          {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 500,
          }
        )
      }
      throw parseError // 필드 검증 에러는 상위로 전파
    }

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

    // ✅ 에러 타입별 코드 및 메시지
    let errorCode = 'UNKNOWN_ERROR'
    let userMessage = '소원 분석 중 오류가 발생했습니다'

    if (error.message?.includes('필수 파라미터')) {
      errorCode = 'MISSING_PARAMS'
      userMessage = error.message
    } else if (error.message?.includes('하루 1회') || error.message?.includes('이미 소원')) {
      errorCode = 'DAILY_LIMIT'
      userMessage = error.message
    } else if (error.message?.includes('LLM') || error.message?.includes('API 응답')) {
      errorCode = 'LLM_ERROR'
      userMessage = '신의 응답을 받는 중 오류가 발생했습니다'
    } else if (error.message?.includes('검증 실패')) {
      errorCode = 'VALIDATION_ERROR'
      userMessage = '소원 분석 응답이 불완전합니다'
    }

    return new Response(
      JSON.stringify({
        success: false,
        error: error.message,
        message: userMessage,
        code: errorCode,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      }
    )
  }
})
