/**
 * MBTI 운세 (MBTI Fortune) Edge Function
 *
 * @description MBTI 유형과 생년월일을 기반으로 맞춤형 운세를 생성합니다.
 *
 * @endpoint POST /fortune-mbti
 *
 * @requestBody
 * - mbti: string - MBTI 유형 (예: "INTJ", "ENFP")
 * - name: string - 사용자 이름
 * - birthDate: string - 생년월일 (YYYY-MM-DD)
 * - userId?: string - 사용자 ID
 * - isPremium?: boolean - 프리미엄 사용자 여부
 *
 * @response MbtiFortuneResponse
 * - mbti_analysis: { type, characteristics, strengths, weaknesses }
 * - today_fortune: { overall, work, relationship, health }
 * - lucky_elements: { color, number, time, activity }
 * - advice: string - 오늘의 조언
 * - tips: string[] - MBTI별 맞춤 팁
 * - percentile: number - 상위 백분위
 *
 * @example
 * curl -X POST https://xxx.supabase.co/functions/v1/fortune-mbti \
 *   -H "Authorization: Bearer <token>" \
 *   -d '{"mbti":"INTJ","name":"홍길동","birthDate":"1990-01-01"}'
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

interface MbtiFortuneRequest {
  mbti: string;
  name: string;
  birthDate: string;
  userId?: string;
  isPremium?: boolean; // ✅ 프리미엄 사용자 여부
}

interface MbtiFortuneResponse {
  success: boolean;
  data: {
    todayFortune: string;
    loveFortune: string;
    careerFortune: string;
    moneyFortune: string;
    healthFortune: string;
    luckyColor: string;
    luckyNumber: number;
    advice: string;
    compatibility: string[];
    energyLevel: number; // 0-100
    cognitiveStrengths: string[];
    challenges: string[];
    mbtiDescription: string;
    timestamp: string;
    isBlurred?: boolean; // ✅ 블러 상태
    blurredSections?: string[]; // ✅ 블러 처리된 섹션 목록
  };
  error?: string;
}

// MBTI별 특성 및 인지 기능 매핑
const MBTI_CHARACTERISTICS = {
  'INTJ': {
    description: '전략가 - 상상력이 풍부하고 전략적인 사고를 하는 계획가',
    cognitiveStrengths: ['전략적 사고', '체계적 계획', '독립적 판단', '미래 지향적'],
    compatibility: ['ENFP', 'ENTP', 'INFJ', 'ISFJ'],
    challenges: ['감정 표현', '즉흥성 부족', '완벽주의']
  },
  'INTP': {
    description: '논리술사 - 지적 호기심이 많고 창의적인 사색가',
    cognitiveStrengths: ['논리적 분석', '창의적 사고', '개념적 이해', '객관적 판단'],
    compatibility: ['ENFJ', 'ESTJ', 'INTJ', 'ISFJ'],
    challenges: ['실행력 부족', '일상 관리', '감정 무시']
  },
  'ENTJ': {
    description: '통솔자 - 대담하고 상상력이 풍부한 강력한 리더',
    cognitiveStrengths: ['리더십', '목표 지향', '전략적 사고', '효율성'],
    compatibility: ['INFP', 'INTP', 'ENFP', 'ISFP'],
    challenges: ['참을성 부족', '타인 감정 무시', '과도한 경쟁심']
  },
  'ENTP': {
    description: '변론가 - 똑똑하고 호기심이 많은 사색가',
    cognitiveStrengths: ['창의적 아이디어', '논리적 토론', '적응력', '열정'],
    compatibility: ['INFJ', 'INTJ', 'ENFJ', 'ISFJ'],
    challenges: ['지속력 부족', '루틴 회피', '세부사항 간과']
  },
  'INFJ': {
    description: '옹호자 - 선의의 옹호자이며 창의적이고 통찰력 있는 이상주의자',
    cognitiveStrengths: ['직관적 통찰', '공감 능력', '계획성', '이상주의'],
    compatibility: ['ENFP', 'ENTP', 'INTJ', 'ISFP'],
    challenges: ['완벽주의', '번아웃', '갈등 회피']
  },
  'INFP': {
    description: '중재자 - 항상 선을 행할 준비가 되어 있는 부드럽고 선량한 이타주의자',
    cognitiveStrengths: ['공감 능력', '창의성', '진정성', '가치 중시'],
    compatibility: ['ENFJ', 'ENTJ', 'ISFJ', 'ESFJ'],
    challenges: ['결정 어려움', '비판 민감', '현실 회피']
  },
  'ENFJ': {
    description: '선도자 - 카리스마 있고 영감을 주는 지도자',
    cognitiveStrengths: ['리더십', '소통 능력', '동기 부여', '공감'],
    compatibility: ['INFP', 'ISFP', 'INTP', 'ISTP'],
    challenges: ['자기희생', '비판 민감', '번아웃']
  },
  'ENFP': {
    description: '활동가 - 열정적이고 창의적인 자유로운 영혼',
    cognitiveStrengths: ['열정', '창의성', '소통', '적응력'],
    compatibility: ['INTJ', 'INFJ', 'ISTJ', 'ISFJ'],
    challenges: ['집중력 부족', '루틴 회피', '감정 기복']
  },
  'ISTJ': {
    description: '현실주의자 - 사실에 근거하여 신뢰할 수 있고 성실한 실용주의자',
    cognitiveStrengths: ['책임감', '신뢰성', '체계성', '세심함'],
    compatibility: ['ESFP', 'ESTP', 'ENFP', 'ISFP'],
    challenges: ['변화 적응', '융통성 부족', '감정 표현']
  },
  'ISFJ': {
    description: '수호자 - 마음이 따뜻하고 성실하며 항상 타인을 보호할 준비가 된 사람',
    cognitiveStrengths: ['배려심', '세심함', '충성심', '실용성'],
    compatibility: ['ESFP', 'ESTP', 'ENFP', 'ENTP'],
    challenges: ['자기주장 부족', '변화 거부', '스트레스 내재화']
  },
  'ESTJ': {
    description: '경영자 - 우수한 관리자이며 계획을 관리하고 사람을 통솔하는 데 탁월함',
    cognitiveStrengths: ['조직력', '리더십', '효율성', '현실감각'],
    compatibility: ['ISFP', 'ISTP', 'INTP', 'INFP'],
    challenges: ['융통성 부족', '감정 경시', '권위주의']
  },
  'ESFJ': {
    description: '집정관 - 매우 충성스럽고 따뜻하며 배려심이 넘치는 협력자',
    cognitiveStrengths: ['협력', '배려', '조화', '실용성'],
    compatibility: ['ISFP', 'ISTP', 'INFP', 'INTP'],
    challenges: ['비판 민감', '갈등 회피', '자기소홀']
  },
  'ISTP': {
    description: '만능재주꾼 - 대담하고 실용적인 실험정신이 풍부한 문제 해결사',
    cognitiveStrengths: ['문제해결', '실용성', '적응력', '독립성'],
    compatibility: ['ESFJ', 'ESTJ', 'ENFJ', 'ESFP'],
    challenges: ['감정 표현', '장기 계획', '타인과의 깊은 관계']
  },
  'ISFP': {
    description: '모험가 - 유연하고 매력적인 예술가 기질의 탐험가',
    cognitiveStrengths: ['예술적 감각', '공감', '유연성', '진정성'],
    compatibility: ['ESFJ', 'ESTJ', 'ENFJ', 'ENTJ'],
    challenges: ['스트레스 관리', '계획성 부족', '갈등 회피']
  },
  'ESTP': {
    description: '사업가 - 영리하고 에너지 넘치며 인식이 뛰어난 사람',
    cognitiveStrengths: ['실행력', '에너지', '사교성', '현실감각'],
    compatibility: ['ISFJ', 'ISTJ', 'INFJ', 'ISFP'],
    challenges: ['장기 계획', '세부사항', '감정 처리']
  },
  'ESFP': {
    description: '연예인 - 자발적이고 열정적이며 사교적인 자유로운 영혼',
    cognitiveStrengths: ['사교성', '열정', '즉흥성', '낙천성'],
    compatibility: ['ISFJ', 'ISTJ', 'INFJ', 'INTJ'],
    challenges: ['집중력', '비판 처리', '장기 목표']
  }
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    )

    const { mbti, name, birthDate, userId, isPremium }: MbtiFortuneRequest = await req.json()

    console.log(`[MBTI] Request - User: ${userId}, Premium: ${isPremium}, MBTI: ${mbti}`)

    // 입력 데이터 검증
    if (!mbti || !name || !birthDate) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'MBTI, 이름, 생년월일이 모두 필요합니다.'
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
          status: 400
        }
      )
    }

    // MBTI 유효성 검증
    if (!MBTI_CHARACTERISTICS[mbti as keyof typeof MBTI_CHARACTERISTICS]) {
      return new Response(
        JSON.stringify({
          success: false,
          error: '유효하지 않은 MBTI 타입입니다.'
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
          status: 400
        }
      )
    }

    // 캐시 확인 (오늘 같은 사용자, 같은 MBTI로 생성된 운세가 있는지)
    const today = new Date().toISOString().split('T')[0]
    const cacheKey = `${userId || 'anonymous'}_${mbti}_${today}`

    const { data: cachedResult } = await supabaseClient
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .eq('fortune_type', 'mbti')
      .single()

    if (cachedResult) {
      return new Response(
        JSON.stringify({
          success: true,
          data: cachedResult.result
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
      )
    }

    // ✅ LLM 모듈 사용 (동적 DB 설정 - A/B 테스트 지원)
    const llm = await LLMFactory.createFromConfigAsync('mbti')

    const systemPrompt = `당신은 전문적인 MBTI 운세 전문가입니다. 각 MBTI 유형의 특성을 깊이 이해하고 있으며, 한국 전통 운세와 현대 심리학을 결합하여 정확하고 의미있는 운세를 제공합니다.

다음 JSON 형식으로 응답해주세요:
{
  "todayFortune": "오늘의 전체적인 운세 (100자 이내, 핵심만)",
  "loveFortune": "연애/사랑 운세 (80자 이내)",
  "careerFortune": "직장/학업 운세 (80자 이내)",
  "moneyFortune": "금전/재물 운세 (80자 이내)",
  "healthFortune": "건강 운세 (80자 이내)",
  "luckyColor": "오늘의 행운 색상",
  "luckyNumber": 행운 숫자 (1-99),
  "advice": "MBTI 특성 기반 조언 (100자 이내)",
  "energyLevel": 오늘의 에너지 레벨 (0-100),
  "mbtiDescription": "해당 MBTI의 간단한 설명 (50자 이내)"
}

모든 내용은 따뜻하고 긍정적이며 실용적인 조언을 포함해야 합니다.`

    const userPrompt = `이름: ${name}
MBTI: ${mbti}
생년월일: ${birthDate}
오늘 날짜: ${new Date().toLocaleDateString('ko-KR')}

${mbti} 유형의 특성을 고려하여 오늘의 운세를 JSON 형식으로 봐주세요.`

    const response = await llm.generate([
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userPrompt }
    ], {
      temperature: 1,
      maxTokens: 8192,
      jsonMode: true
    })

    console.log(`✅ LLM 호출 완료: ${response.provider}/${response.model} - ${response.latency}ms`)

    // ✅ LLM 사용량 로깅 (비용/성능 분석용)
    await UsageLogger.log({
      fortuneType: 'mbti',
      userId: userId,
      provider: response.provider,
      model: response.model,
      response: response,
      metadata: { name, mbti, birthDate, isPremium }
    })

    if (!response.content) {
      console.error('LLM 응답 없음')
      throw new Error('LLM API 응답 형식 오류')
    }

    const fortuneData = JSON.parse(response.content)

    // MBTI 특성 정보 추가
    const mbtiCharacteristics = MBTI_CHARACTERISTICS[mbti as keyof typeof MBTI_CHARACTERISTICS]

    // ✅ RewardedAd 방식: Premium 여부에 따라 Blur 처리
    const isBlurred = !isPremium
    const blurredSections = isBlurred
      ? ['loveFortune', 'careerFortune', 'moneyFortune', 'healthFortune', 'advice', 'compatibility', 'cognitiveStrengths', 'challenges']
      : []

    console.log(`[MBTI] isPremium: ${isPremium}, isBlurred: ${isBlurred}`)

    const result: MbtiFortuneResponse['data'] = {
      todayFortune: fortuneData.todayFortune,  // ✅ 무료: 공개
      loveFortune: fortuneData.loveFortune,    // 🔒 유료
      careerFortune: fortuneData.careerFortune, // 🔒 유료
      moneyFortune: fortuneData.moneyFortune,  // 🔒 유료
      healthFortune: fortuneData.healthFortune, // 🔒 유료
      luckyColor: fortuneData.luckyColor,      // ✅ 무료: 공개
      luckyNumber: fortuneData.luckyNumber,    // ✅ 무료: 공개
      advice: fortuneData.advice,              // 🔒 유료
      compatibility: mbtiCharacteristics.compatibility, // 🔒 유료
      energyLevel: fortuneData.energyLevel || 50, // ✅ 무료: 공개
      cognitiveStrengths: mbtiCharacteristics.cognitiveStrengths, // 🔒 유료
      challenges: mbtiCharacteristics.challenges, // 🔒 유료
      mbtiDescription: mbtiCharacteristics.description, // ✅ 무료: 공개
      timestamp: new Date().toISOString(),
      isBlurred,           // ✅ 블러 상태
      blurredSections,     // ✅ 블러 처리된 섹션 목록
    }

    console.log(`[MBTI] Result generated for ${mbti}`)

    // 결과 캐싱
    await supabaseClient
      .from('fortune_cache')
      .insert({
        cache_key: cacheKey,
        fortune_type: 'mbti',
        user_id: userId || null,
        result: result,
        created_at: new Date().toISOString()
      })

    // ✅ 퍼센타일 계산
    const percentileData = await calculatePercentile(supabaseClient, 'mbti', result.energyLevel)
    const resultWithPercentile = addPercentileToResult(result, percentileData)

    return new Response(
      JSON.stringify({
        success: true,
        data: resultWithPercentile
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
    )

  } catch (error) {
    console.error('MBTI Fortune API Error:', error)

    // 에러 상세 로그
    const errorMessage = error instanceof Error ? error.message : String(error)
    console.error('Error details:', {
      message: errorMessage,
      stack: error instanceof Error ? error.stack : undefined,
      mbti,
      name,
      birthDate
    })

    return new Response(
      JSON.stringify({
        success: false,
        error: '운세 생성 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
        details: process.env.NODE_ENV === 'development' ? errorMessage : undefined
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        status: 500
      }
    )
  }
})