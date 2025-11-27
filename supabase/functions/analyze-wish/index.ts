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

다음 JSON 형식으로 **진심어린 메시지**를 작성해주세요:

{
  "empathy_message": "공감 메시지 (300-400자)\n\n[작성 가이드]\n- 소원에 담긴 진짜 마음을 읽어내기 (예: 취업 소원 → 인정받고 싶은 마음, 불안함)\n- 그 마음이 '당연하고 소중하다'는 것을 전달\n- 혼자가 아니라는 따뜻한 위로\n- 형식: '~~하고 싶으시군요. ~~한 마음이 느껴집니다. ~~하셨을 것 같아요. 그 마음, 참 소중합니다.'\n\n[예시]\n소원: 좋은 회사에 취업하고 싶어요\n공감: '좋은 회사에서 일하고 싶다는 마음, 그 안에는 자신의 능력을 인정받고 싶고, 안정된 미래를 꿈꾸는 간절함이 담겨있네요. 지금까지 얼마나 많은 노력을 하셨을까요. 때론 지치고 불안하셨을 텐데, 그럼에도 포기하지 않고 여기까지 오신 당신의 용기가 대단합니다. 그 마음, 반드시 보상받을 자격이 있습니다.'",

  "hope_message": "희망 메시지 (400-500자)\n\n[작성 가이드]\n- '왜 이룰 수 있는지' 구체적인 근거 제시\n- 이미 가진 강점과 자원을 상기시키기\n- 작은 진전이라도 인정하고 격려\n- 어려움이 영원하지 않다는 것을 구체적 예시로 설명\n- '지금 이 순간'의 의미와 가치 강조\n\n[예시]\n'당신이 이 소원을 이룰 수 있다고 믿는 이유가 있습니다. 첫째, 지금까지 쌓아온 경험과 노력이 있습니다. 그것은 결코 헛되지 않습니다. 둘째, 이렇게 간절히 원하는 마음 자체가 당신을 움직이는 강력한 동력이 됩니다. 셋째, 지금은 보이지 않지만 당신의 노력은 분명 누군가에게 닿고 있습니다.\n\n힘들 땐 잠시 멈춰도 괜찮습니다. 중요한 건 방향을 잃지 않는 것이죠. 지금 이 순간도 당신은 조금씩 나아가고 있습니다. 그 사실을 잊지 마세요.'",

  "advice": [
    "실천 가능한 구체적 조언 1 (100-150자)\n- 당장 오늘/내일부터 할 수 있는 것\n- '~~하세요'가 아니라 '~~해보는 건 어떨까요?'처럼 부드러운 제안\n- 왜 효과적인지 간단한 이유 포함\n\n[예시] '매일 아침 5분만 투자해서 오늘 하루 이루고 싶은 작은 목표 하나를 적어보는 건 어떨까요? 큰 꿈도 결국 매일의 작은 실천에서 시작됩니다. 적는 행위 자체가 의지를 다지는 데 큰 도움이 됩니다.'",

    "실천 가능한 구체적 조언 2 (100-150자)\n- 카테고리(${category})에 특화된 조언\n- 사용자 상황을 고려한 맞춤형 제안\n\n[예시] '지금 힘들다면, 비슷한 상황을 극복한 사람들의 이야기를 들어보세요. 그들도 처음엔 당신처럼 막막했지만, 결국 길을 찾았습니다. 그 이야기 속에서 당신만의 힌트를 발견할 수 있을 거예요.'",

    "실천 가능한 구체적 조언 3 (100-150자)\n- 긴급도(${urgency}/5)를 고려한 타임라인 제시\n- 작은 성공 경험을 쌓도록 돕는 조언\n\n[예시] '일주일에 하루는 자신에게 '잘 하고 있어'라고 말해주는 시간을 가져보세요. 완벽하지 않아도, 느려도 괜찮습니다. 중요한 건 멈추지 않는 것이니까요. 작은 칭찬이 큰 힘이 됩니다.'"
  ],

  "encouragement": "응원 메시지 (200-250자)\n\n[작성 가이드]\n- 사용자의 강점을 구체적으로 언급\n- '혼자가 아니다'는 메시지\n- 앞으로의 여정에 대한 믿음 표현\n- 진심이 느껴지는 따뜻한 마무리\n\n[예시]\n'당신의 간절함, 그 포기하지 않는 마음이 정말 아름답습니다. 지금 이 순간도 당신은 충분히 잘 하고 있어요. 힘들 땐 이 메시지를 다시 읽어주세요. 당신의 꿈을 응원하는 사람이 여기 있습니다. 반드시 좋은 날이 올 거예요. 그때까지 함께 걸어가요. 당신을 믿습니다.'",

  "special_words": "신의 한마디 (40-50자)\n\n[작성 가이드]\n- 짧지만 강렬한 메시지\n- 소원의 핵심을 관통하는 한마디\n- 기억에 남는 명언처럼\n\n[예시]\n'당신의 간절함은 이미 반쯤 이루어진 기적입니다'\n'포기하지 않는 당신의 마음이 가장 큰 힘입니다'\n'지금 이 순간, 당신은 충분히 빛나고 있습니다'"
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

    const analysisResult: WishAnalysisResponse = JSON.parse(response.content)

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
