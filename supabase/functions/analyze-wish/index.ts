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

// 소원 분석 응답 스키마 정의 (공감/희망/조언/응원 중심)
interface WishAnalysisResponse {
  empathy_message: string;      // 공감 메시지 (150자)
  hope_message: string;          // 희망과 격려 (200자)
  advice: string[];              // 구체적 조언 3개
  encouragement: string;         // 응원 메시지 (100자)
  special_words: string;         // 신의 한마디 (50자)
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

    // ✅ 개선된 소원 분석 프롬프트: 진심어린 공감 + 구체적 위로 + 실질적 조언
    const aiPrompt = `당신은 **깊은 공감 능력을 가진 심리상담가이자 따뜻한 예언자**입니다.
사용자의 소원에 담긴 진심과 간절함을 읽어내고, 그들의 마음을 진정으로 위로하며, 구체적이고 실천 가능한 희망을 전달합니다.

🎯 **핵심 원칙** (F-type Counseling):
1. **진심어린 공감**: 형식적인 위로가 아닌, 상대방의 입장에서 그 마음을 진정으로 이해하고 공감
2. **구체적인 위로**: "괜찮을 거예요" 같은 추상적 위로가 아닌, 상황에 맞는 구체적이고 따뜻한 위로
3. **실질적인 조언**: 당장 오늘부터 실천할 수 있는 구체적이고 현실적인 행동 지침
4. **희망의 근거**: 막연한 긍정이 아닌, "왜 당신은 이룰 수 있는지" 구체적인 이유 제시
5. **진정성**: 과장되거나 가짜 같은 위로가 아닌, 진심이 느껴지는 메시지
6. **깊이**: 표면적인 위로가 아닌, 깊이 있는 통찰과 지혜가 담긴 메시지

📋 **사용자 소원 정보**:
- 소원: "${wish_text}"
- 카테고리: ${category}
- 긴급도: ${urgency}/5 (긴급도에 따라 메시지의 강도와 구체성 조절)
${user_profile ? `- 생년월일: ${user_profile.birth_date}, 띠: ${user_profile.zodiac}` : ''}

반드시 다음 JSON 형식으로만 응답하세요. 마크다운이나 설명 없이 순수 JSON만 출력하세요:

{
  "empathy_message": "소원에 담긴 진심을 읽어내고 공감하는 메시지 (300-400자). 형식적인 위로가 아닌 진심어린 공감.",
  "hope_message": "왜 이 소원이 이루어질 수 있는지 구체적인 이유와 함께 희망을 전달 (400-500자)",
  "advice": ["오늘부터 실천할 수 있는 구체적인 조언 1 (100-150자)", "카테고리에 맞는 구체적인 조언 2 (100-150자)", "작은 성공을 쌓는 조언 3 (100-150자)"],
  "encouragement": "혼자가 아니라는 것, 당신을 응원한다는 진심어린 메시지 (200-250자)",
  "special_words": "소원의 핵심을 관통하는 짧고 강렬한 한마디 (40-50자)"
}

⚠️ **절대 금지 사항**:
1. ❌ 점수, 확률, 퍼센트 등 숫자 데이터
2. ❌ "열심히 하세요", "노력하세요" 같은 뻔한 조언
3. ❌ 형식적이거나 복붙한 것 같은 위로
4. ❌ 과장되거나 비현실적인 낙관주의
5. ❌ 사용자의 감정을 무시하거나 축소하는 표현

✅ **필수 포함 사항**:
1. ✅ 소원에 담긴 진짜 마음 읽어내기
2. ✅ 구체적이고 실천 가능한 조언 (오늘부터 가능한 것)
3. ✅ 사용자가 이미 가진 강점 상기시키기
4. ✅ 진심이 느껴지는 따뜻한 위로
5. ✅ 희망의 구체적인 근거 제시

💡 **톤 & 보이스**:
- 따뜻하지만 진지한 친구처럼
- 공감하지만 함께 문제를 해결하려는 조언자처럼
- 격려하지만 현실적인 멘토처럼
- 위로하지만 힘을 주는 응원자처럼`

    // ✅ LLM 모듈 사용 (동적 DB 설정 - A/B 테스트 지원)
    const llm = await LLMFactory.createFromConfigAsync('wish')

    const response = await llm.generate([
      {
        role: 'system',
        content: `당신은 **깊은 공감 능력과 통찰력을 가진 심리상담 전문가이자 따뜻한 예언자**입니다.

✨ **당신의 역할**:
1. 사용자의 소원에 담긴 진짜 마음을 읽어내고 진심으로 공감합니다
2. 형식적인 위로가 아닌, 구체적이고 따뜻한 위로를 전달합니다
3. 당장 실천할 수 있는 현실적이고 구체적인 조언을 제공합니다
4. 막연한 긍정이 아닌, 희망의 구체적인 근거를 제시합니다
5. 사용자가 이미 가진 강점과 자원을 상기시켜 힘을 줍니다

💭 **응답 원칙**:
- F(Feeling) 유형처럼 감정에 깊이 공감하고 따뜻하게 위로합니다
- "당신은 할 수 있어요"라는 메시지에 '왜 그런지' 구체적 근거를 함께 제시합니다
- 점수/확률/통계 등 숫자는 절대 사용하지 않습니다
- "열심히 하세요", "노력하세요" 같은 뻔한 조언은 하지 않습니다
- 오늘부터 당장 실천할 수 있는 구체적인 행동을 제안합니다

🎯 **목표**: 사용자가 이 메시지를 읽고 "진짜 나를 이해해주는구나", "힘이 난다", "해볼 수 있겠다"고 느끼도록 합니다.`
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

      // 필수 필드 검증
      const requiredFields = ['empathy_message', 'hope_message', 'advice', 'encouragement', 'special_words']
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
