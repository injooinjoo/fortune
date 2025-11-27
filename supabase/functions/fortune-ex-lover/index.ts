import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { crypto } from 'https://deno.land/std@0.168.0/crypto/mod.ts'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'
import { calculatePercentile, addPercentileToResult } from '../_shared/percentile/calculator.ts'

const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY')!

const supabase = createClient(supabaseUrl, supabaseKey)

// UTF-8 안전한 해시 생성 함수 (btoa는 Latin1만 지원하여 한글 불가)
async function createHash(text: string): Promise<string> {
  const encoder = new TextEncoder()
  const data = encoder.encode(text)
  const hashBuffer = await crypto.subtle.digest('SHA-256', data)
  const hashArray = Array.from(new Uint8Array(hashBuffer))
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('').slice(0, 50)
}

interface ExLoverFortuneRequest {
  fortune_type?: string
  name: string
  birth_date?: string
  gender?: string
  mbti?: string
  relationship_duration: string
  breakup_reason: string
  time_since_breakup?: string
  current_feeling?: string
  still_in_contact?: boolean
  has_unresolved_feelings?: boolean
  isPremium?: boolean // ✅ 프리미엄 사용자 여부
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      },
    })
  }

  try {
    const requestData: ExLoverFortuneRequest = await req.json()
    const {
      name = '',
      relationship_duration = '',
      breakup_reason = '',
      time_since_breakup = '',
      current_feeling = '',
      still_in_contact = false,
      isPremium = false // ✅ 프리미엄 사용자 여부
    } = requestData

    console.log('💎 [ExLover] Premium 상태:', isPremium)

    if (!name || !breakup_reason) {
      throw new Error('이름과 이별 이유를 입력해주세요.')
    }

    console.log('Ex-lover fortune request:', { name, relationship_duration })

    const hash = await createHash(`${name}_${relationship_duration}_${breakup_reason}`)
    const cacheKey = `ex_lover_fortune_${hash}`
    const { data: cachedResult } = await supabase
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .single()

    let fortuneData: any

    if (cachedResult?.result) {
      console.log('Cache hit for ex-lover fortune')
      fortuneData = cachedResult.result
    } else {
      console.log('Cache miss, calling OpenAI API')

      // ✅ LLM 모듈 사용 (동적 DB 설정 - A/B 테스트 지원)
      const llm = await LLMFactory.createFromConfigAsync('ex-lover')

      // ✅ 강화된 시스템 프롬프트 (전문가 페르소나 + 분석 프레임워크)
      const systemPrompt = `당신은 25년 경력의 연애 심리 상담 전문가이자 동양 철학 기반 인연 분석가입니다.
심리학 석사 학위와 사주명리학 정통 자격증을 보유하고 있으며, 수천 쌍의 연인 관계를 분석하고 상담해온 경험이 있습니다.

# 전문 분야
- 연애 심리학 및 애착 이론 (Attachment Theory)
- 사주명리학 기반 인연 분석 (삼합/육합/천간합/지지합 이론)
- 이별 후 감정 치유 프로그램 개발
- 재회 상담 및 관계 회복 코칭

# 분석 철학
1. **균형성**: 재회를 무조건 권유하거나 포기를 강요하지 않고 객관적 분석 제공
2. **공감**: 이별의 아픔에 깊이 공감하며 따뜻한 위로 전달
3. **실용성**: 즉시 실천 가능한 구체적 조언
4. **전문성**: 심리학 + 동양철학 용어를 적절히 혼합하되 쉽게 풀어 설명

# 출력 형식 (반드시 JSON 형식으로)
{
  "title": "감성적이고 희망적인 제목 (예: 'OOO님, 새로운 인연의 문이 열립니다')",
  "score": 70-95 사이 정수 (전반적인 인연 점수),
  "overall_fortune": "전반적인 운세 분석 (최소 200자, 현재 상황에 대한 종합적 해석)",
  "relationship_analysis": {
    "energy_compatibility": "두 사람의 에너지 궁합 분석 (천간 상성 기반, 100자 이상)",
    "meeting_meaning": "만남의 의미와 성장 포인트 (100자 이상)",
    "karma_interpretation": "인연의 깊이와 카르마적 해석 (100자 이상)"
  },
  "breakup_analysis": {
    "type": "이별 유형 (갈등형/소원형/외부요인형/성장통형 중 택1)",
    "type_description": "이별 유형에 대한 상세 설명 (100자 이상)",
    "pattern": "관계에서 나타난 패턴과 반복 가능성 (100자 이상)",
    "hidden_emotions": "숨겨진 감정과 미해결 과제 분석 (100자 이상)"
  },
  "reunion_possibility": {
    "score": 0-100 사이 정수 (재회 확률),
    "analysis": "재회 가능성에 대한 상세 분석 (150자 이상)",
    "favorable_timing": "재회에 유리한 시기 (구체적 기간, 예: '3개월 후', '내년 봄')",
    "conditions": ["재회에 필요한 조건 3가지"],
    "recommendation": "재회 vs 새 출발 추천과 이유 (100자 이상)"
  },
  "healing_roadmap": {
    "phase1": {
      "period": "수용기 (현재~2주)",
      "goal": "감정 인정하기",
      "actions": ["구체적 실천 방법 3가지"]
    },
    "phase2": {
      "period": "정리기 (2주~1개월)",
      "goal": "관계 복기와 배움",
      "actions": ["구체적 실천 방법 3가지"]
    },
    "phase3": {
      "period": "회복기 (1개월~3개월)",
      "goal": "새로운 나 발견",
      "actions": ["구체적 실천 방법 3가지"]
    }
  },
  "new_love_forecast": {
    "timing": "새 인연을 만날 가능성 높은 시기 (구체적)",
    "ideal_type": "어울리는 이상형 특성 (외모/성격/직업 포함, 100자 이상)",
    "meeting_context": "만남의 장소와 계기 예측 (구체적, 50자 이상)"
  },
  "practical_advice": {
    "do_now": ["당장 해야 할 것 3가지 (구체적이고 실천 가능한)"],
    "never_do": ["절대 하지 말아야 할 것 3가지 (구체적 이유 포함)"],
    "monthly_checklist": ["한 달 후 체크리스트 항목 3가지"]
  },
  "comfort_message": "현재 감정에 대한 공감과 희망적 전망 (최소 200자, 따뜻하고 위로가 되는 메시지)"
}

# 분량 요구사항
- 전체: 최소 1500자 이상
- 각 주요 섹션: 최소 100자 이상
- overall_fortune, comfort_message: 각각 200자 이상
- 구체적 상황에 맞춘 맞춤형 분석 (일반적 표현 금지)

# 주의사항
- 사용자 정보를 면밀히 분석하여 맞춤형 조언 제공
- 모호한 점술 표현 금지 (예: "때가 되면 알게 됩니다" → 구체적 시기와 조건 명시)
- 부정적 단정 금지 (예: "재회는 불가능합니다" → "현재 조건에서는 어려우나, ~하면 가능성이 열립니다")
- 반드시 유효한 JSON 형식으로 출력`

      const userPrompt = `# 상담 요청 정보

## 사용자 정보
- 이름: ${name}

## 관계 정보
- 교제 기간: ${relationship_duration || '정보 없음'}
- 이별 이유: ${breakup_reason}
- 이별 후 경과: ${time_since_breakup || '정보 없음'}
- 현재 감정 상태: ${current_feeling || '복잡한 감정'}
- 연락 여부: ${still_in_contact ? '연락 유지 중' : '연락 단절'}

위 정보를 바탕으로 전문적이고 상세한 전 애인 운세 분석을 JSON 형식으로 제공해주세요.
특히 ${name}님의 상황에 맞는 구체적이고 실용적인 조언을 부탁드립니다.`

      const response = await llm.generate([
        {
          role: 'system',
          content: systemPrompt
        },
        {
          role: 'user',
          content: userPrompt
        }
      ], {
        temperature: 0.9,
        maxTokens: 8192,
        jsonMode: true
      })

      console.log(`✅ LLM 호출 완료: ${response.provider}/${response.model} - ${response.latency}ms`)

      // ✅ LLM 사용량 로깅 (비용/성능 분석용)
      await UsageLogger.log({
        fortuneType: 'ex-lover',
        provider: response.provider,
        model: response.model,
        response: response,
        metadata: { name, relationship_duration, breakup_reason, still_in_contact, isPremium }
      })

      if (!response.content) throw new Error('LLM API 응답을 받을 수 없습니다.')

      const parsedResponse = JSON.parse(response.content)

      // ✅ Blur 로직 적용 (프리미엄이 아니면 일부 섹션 블러 처리)
      const isBlurred = !isPremium
      const blurredSections = isBlurred
        ? ['relationship_analysis', 'breakup_analysis', 'reunion_possibility', 'healing_roadmap', 'new_love_forecast', 'practical_advice']
        : []

      // 블러 처리용 기본 메시지
      const blurredMessage = '🔒 프리미엄 결제 후 확인 가능합니다'
      const blurredArray = ['🔒 프리미엄 결제 후 확인 가능합니다']

      fortuneData = {
        title: parsedResponse.title || `${name}님, 새로운 시작을 응원합니다`,
        fortune_type: 'ex_lover',
        name,
        relationship_duration,
        breakup_reason,
        // ✅ 무료: 공개 섹션
        score: parsedResponse.score || Math.floor(Math.random() * 25) + 70,
        overall_fortune: parsedResponse.overall_fortune || '이별은 끝이 아닌 새로운 시작입니다.',
        comfort_message: parsedResponse.comfort_message || '지금의 아픔은 반드시 지나갑니다.',

        // 🔒 프리미엄: 인연 분석
        relationship_analysis: isBlurred ? {
          energy_compatibility: blurredMessage,
          meeting_meaning: blurredMessage,
          karma_interpretation: blurredMessage
        } : (parsedResponse.relationship_analysis || {
          energy_compatibility: '두 분의 에너지 분석이 진행 중입니다.',
          meeting_meaning: '만남의 의미를 분석 중입니다.',
          karma_interpretation: '인연의 깊이를 해석 중입니다.'
        }),

        // 🔒 프리미엄: 이별 분석
        breakup_analysis: isBlurred ? {
          type: blurredMessage,
          type_description: blurredMessage,
          pattern: blurredMessage,
          hidden_emotions: blurredMessage
        } : (parsedResponse.breakup_analysis || {
          type: '분석 중',
          type_description: '이별 유형을 분석 중입니다.',
          pattern: '관계 패턴을 분석 중입니다.',
          hidden_emotions: '숨겨진 감정을 분석 중입니다.'
        }),

        // 🔒 프리미엄: 재회 가능성
        reunion_possibility: isBlurred ? {
          score: 0,
          analysis: blurredMessage,
          favorable_timing: blurredMessage,
          conditions: blurredArray,
          recommendation: blurredMessage
        } : (parsedResponse.reunion_possibility || {
          score: 50,
          analysis: '재회 가능성을 분석 중입니다.',
          favorable_timing: '적절한 시기를 분석 중입니다.',
          conditions: ['조건을 분석 중입니다.'],
          recommendation: '추천 방향을 분석 중입니다.'
        }),

        // 🔒 프리미엄: 치유 로드맵
        healing_roadmap: isBlurred ? {
          phase1: { period: blurredMessage, goal: blurredMessage, actions: blurredArray },
          phase2: { period: blurredMessage, goal: blurredMessage, actions: blurredArray },
          phase3: { period: blurredMessage, goal: blurredMessage, actions: blurredArray }
        } : (parsedResponse.healing_roadmap || {
          phase1: { period: '수용기', goal: '감정 인정', actions: ['천천히 감정 정리하기'] },
          phase2: { period: '정리기', goal: '관계 복기', actions: ['배움 찾기'] },
          phase3: { period: '회복기', goal: '새로운 시작', actions: ['자기 성장'] }
        }),

        // 🔒 프리미엄: 새로운 인연 전망
        new_love_forecast: isBlurred ? {
          timing: blurredMessage,
          ideal_type: blurredMessage,
          meeting_context: blurredMessage
        } : (parsedResponse.new_love_forecast || {
          timing: '새 인연 시기를 분석 중입니다.',
          ideal_type: '이상형을 분석 중입니다.',
          meeting_context: '만남 계기를 분석 중입니다.'
        }),

        // 🔒 프리미엄: 실천 조언
        practical_advice: isBlurred ? {
          do_now: blurredArray,
          never_do: blurredArray,
          monthly_checklist: blurredArray
        } : (parsedResponse.practical_advice || {
          do_now: ['자기 돌봄에 집중하기'],
          never_do: ['충동적 연락 금지'],
          monthly_checklist: ['감정 일기 쓰기']
        }),

        timestamp: new Date().toISOString(),
        isBlurred, // ✅ 블러 상태
        blurredSections // ✅ 블러된 섹션 목록
      }

      await supabase.from('fortune_cache').insert({
        cache_key: cacheKey,
        result: fortuneData,
        fortune_type: 'ex_lover',
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
      })
    }

    // ✅ Percentile 계산 추가
    const percentileData = await calculatePercentile(supabase, 'ex-lover', fortuneData.score)
    const fortuneDataWithPercentile = addPercentileToResult(fortuneData, percentileData)

    return new Response(JSON.stringify({ success: true, data: fortuneDataWithPercentile }), {
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
      },
    })

  } catch (error) {
    console.error('Ex-Lover Fortune Error:', error)
    return new Response(JSON.stringify({
      success: false,
      data: {},
      error: error instanceof Error ? error.message : '전 애인 운세 생성 중 오류가 발생했습니다.'
    }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
      },
    })
  }
})
