/**
 * 전통 사주팔자 (Traditional Saju) Edge Function
 *
 * @description 전통 사주팔자 해석을 기반으로 상세한 운세 분석을 제공합니다.
 *
 * @endpoint POST /fortune-traditional-saju
 *
 * @requestBody
 * - userId: string - 사용자 ID
 * - birthDate: string - 생년월일 (YYYY-MM-DD)
 * - birthTime: string - 출생 시간 (필수, 예: "축시 (01:00 - 03:00)")
 * - gender: string - 성별
 * - isLunar?: boolean - 음력 여부
 * - question?: string - 특정 질문 (선택)
 *
 * @response TraditionalSajuResponse
 * - four_pillars: { year, month, day, hour } - 사주팔자 (년주, 월주, 일주, 시주)
 * - ten_gods: object - 십신 분석
 * - element_analysis: { distribution, dominant, weak } - 오행 분석
 * - personality: { traits, strengths, weaknesses } - 성격 분석
 * - life_path: { career, relationship, health, wealth } - 인생 운로
 * - annual_fortune: object - 연운 분석
 * - advice: string - 종합 조언
 * - percentile: number - 상위 백분위
 *
 * @example
 * curl -X POST https://xxx.supabase.co/functions/v1/fortune-traditional-saju \
 *   -H "Authorization: Bearer <token>" \
 *   -d '{"userId":"xxx","birthDate":"1990-01-01","birthTime":"축시","gender":"male"}'
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

// 전통 사주팔자 응답 스키마
interface TraditionalSajuResponse {
  question: string;
  sections: {
    analysis: string;      // 사주 분석 (항상 표시)
    answer: string;        // 질문에 대한 답변 (블러)
    advice: string;        // 실용적인 조언 (블러)
    supplement: string;    // 오행 보완 방법 (블러)
  };
  summary: string;
  isBlurred: boolean;
  blurredSections: string[];
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    )

    const requestData = await req.json()
    const {
      userId,
      question,
      sajuData,
      isPremium = false
    } = requestData

    console.log('💎 [Traditional-Saju] Premium 상태:', isPremium)
    console.log('📋 [Traditional-Saju] 질문:', question)

    // 사주 데이터 추출
    const dominantElement = sajuData?.dominantElement || '목'
    const lackingElement = sajuData?.lackingElement || '수'
    const elements = sajuData?.elements || {}

    // 사주 명식 정보
    const pillar = sajuData?.pillar || {}
    const yearPillar = pillar?.year || { heavenlyStem: '갑', earthlyBranch: '자' }
    const monthPillar = pillar?.month || { heavenlyStem: '을', earthlyBranch: '축' }
    const dayPillar = pillar?.day || { heavenlyStem: '병', earthlyBranch: '인' }
    const timePillar = pillar?.time || { heavenlyStem: '정', earthlyBranch: '묘' }

    // LLM 프롬프트 생성 (JSON 형식으로 섹션 분리)
    const prompt = `당신은 전문 사주 상담가입니다.
사용자의 사주팔자를 기반으로 질문에 답변해주세요.

사주 정보:
- 사주 명식:
  년주: ${yearPillar.heavenlyStem}${yearPillar.earthlyBranch}
  월주: ${monthPillar.heavenlyStem}${monthPillar.earthlyBranch}
  일주: ${dayPillar.heavenlyStem}${dayPillar.earthlyBranch}
  시주: ${timePillar.heavenlyStem}${timePillar.earthlyBranch}

- 오행 균형:
  목: ${elements['목'] || 0}
  화: ${elements['화'] || 0}
  토: ${elements['토'] || 0}
  금: ${elements['금'] || 0}
  수: ${elements['수'] || 0}

- 주된 오행: ${dominantElement} (가장 강함)
- 부족한 오행: ${lackingElement} (보완 필요)

질문: ${question}

다음 JSON 형식으로 답변해주세요 (절대로 "(xx자 이내)" 같은 글자수 지시문을 출력에 포함하지 마세요):
{
  "analysis": "사주 분석 핵심",
  "answer": "질문에 대한 핵심 답변",
  "advice": "핵심 조언",
  "supplement": "오행 보완 방법"
}

조건:
- 따뜻하고 긍정적인 어조
- 오행의 균형과 상생상극 원리를 적용
- 한국 전통 사주 해석 방식 적용
- 각 섹션은 독립적으로 읽을 수 있어야 함
- 가독성을 위해 긴 내용은 \\n\\n으로 문단을 나누어 작성 (2-3문장마다 문단 구분)
- 반드시 JSON 형식으로만 응답`

    // LLM 호출
    console.log('');
    console.log('🤖 [Traditional-Saju] LLM 호출 시작...');

    const llm = await LLMFactory.createFromConfigAsync('traditional-saju')

    const response = await llm.generate([
      {
        role: 'system',
        content: '당신은 전통 사주팔자에 정통한 전문 상담가입니다. 천간, 지지, 오행의 상생상극 원리를 바탕으로 정확하고 따뜻한 조언을 제공합니다. 반드시 JSON 형식으로만 응답하세요.'
      },
      {
        role: 'user',
        content: prompt
      }
    ], {
      temperature: 1,
      maxTokens: 8192,
      jsonMode: true  // JSON 모드 활성화
    })

    console.log(`✅ LLM 호출 완료: ${response.provider}/${response.model} - ${response.latency}ms`)

    // ✅ LLM 사용량 로깅 (비용/성능 분석용)
    await UsageLogger.log({
      fortuneType: 'traditional-saju',
      userId: userId,
      provider: response.provider,
      model: response.model,
      response: response,
      metadata: { question, dominantElement, lackingElement, isPremium }
    })

    console.log('')

    // JSON 파싱
    let sections
    try {
      sections = JSON.parse(response.content.trim())
    } catch (e) {
      console.error('❌ JSON 파싱 실패, 기본값 사용:', e)
      sections = {
        analysis: '사주 분석 중 오류가 발생했습니다.',
        answer: '답변 생성 중 오류가 발생했습니다.',
        advice: '조언을 생성할 수 없습니다.',
        supplement: '보완 방법을 생성할 수 없습니다.'
      }
    }

    // 요약 생성 (analysis 섹션 사용)
    const summary = sections.analysis || '사주 분석'

    // 블러 처리 (일반 사용자는 answer, advice, supplement 블러)
    const isBlurred = !isPremium
    const blurredSections = isBlurred ? ['answer', 'advice', 'supplement'] : []

    console.log('');
    console.log('📊 [Traditional-Saju] 결과 생성 완료');
    console.log(`   - isBlurred: ${isBlurred}`);
    console.log(`   - blurredSections: ${blurredSections.join(', ')}`);
    console.log(`   - sections: analysis(${sections.analysis?.length || 0}), answer(${sections.answer?.length || 0}), advice(${sections.advice?.length || 0}), supplement(${sections.supplement?.length || 0})`);
    console.log('');

    const fortuneResponse = {
      // ✅ 표준화된 필드명: score, content, summary, advice
      success: true,
      data: {
        fortuneType: 'traditional-saju',
        score: 75, // 전통 사주는 점수 없음, 기본값 사용
        content: sections.analysis || '사주 분석 결과입니다.',
        summary: summary,
        advice: sections.advice || '오행의 균형을 유지하세요.',

        // 기존 필드 유지 (하위 호환성)
        question,
        sections,
        saju_summary: summary,
        isBlurred,
        blurredSections
      }
    }

    return new Response(
      JSON.stringify(fortuneResponse),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        status: 200
      }
    )

  } catch (error) {
    console.error('❌ [Traditional-Saju] Error:', error)

    return new Response(
      JSON.stringify({
        error: 'Failed to generate traditional saju fortune',
        message: error.message
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        status: 500
      }
    )
  }
})
