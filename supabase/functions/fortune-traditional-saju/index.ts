import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { LLMFactory } from '../_shared/llm/factory.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// 전통 사주팔자 응답 스키마
interface TraditionalSajuResponse {
  question: string;
  answer: string;
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

    // LLM 프롬프트 생성
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

조건:
- 최소 500자 이상의 상세한 답변
- 사주 명식의 천간(天干)과 지지(地支)를 바탕으로 구체적으로 분석
- 오행의 균형과 상생상극 원리를 적용하여 해석
- 주된 오행(${dominantElement})의 영향과 부족한 오행(${lackingElement})을 보완하는 방법 제시
- 따뜻하고 긍정적인 어조
- 실용적이고 구체적인 조언 포함
- 한국 전통 사주 해석 방식 적용
- 한국어로 작성

답변 형식:
1. 사주 분석 (천간, 지지, 오행 균형 기반)
2. 질문에 대한 구체적인 답변
3. 실용적인 조언과 주의사항
4. 오행 보완 방법`

    // LLM 호출
    console.log('');
    console.log('🤖 [Traditional-Saju] LLM 호출 시작...');

    const llm = LLMFactory.createFromConfig('traditional-saju')

    const response = await llm.generate([
      {
        role: 'system',
        content: '당신은 전통 사주팔자에 정통한 전문 상담가입니다. 천간, 지지, 오행의 상생상극 원리를 바탕으로 정확하고 따뜻한 조언을 제공합니다.'
      },
      {
        role: 'user',
        content: prompt
      }
    ], {
      temperature: 1,
      maxTokens: 8192,
      jsonMode: false
    })

    console.log(`✅ LLM 호출 완료: ${response.provider}/${response.model} - ${response.latency}ms`)
    console.log('')

    const answer = response.content.trim()

    // 요약 생성 (답변의 첫 200자)
    const summary = answer.length > 200
      ? answer.substring(0, 200) + '...'
      : answer

    // 블러 처리 (일반 사용자만)
    const isBlurred = !isPremium
    const blurredSections = isBlurred ? ['answer'] : []

    console.log('');
    console.log('📊 [Traditional-Saju] 결과 생성 완료');
    console.log(`   - isBlurred: ${isBlurred}`);
    console.log(`   - blurredSections: ${blurredSections.join(', ')}`);
    console.log(`   - answer length: ${answer.length} characters`);
    console.log('');

    const fortuneResponse: TraditionalSajuResponse = {
      question,
      answer,
      summary,
      isBlurred,
      blurredSections
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
