/**
 * 전 연인 운세 (Ex-Lover Fortune) Edge Function
 *
 * @description 전 연인과의 관계를 사주 기반으로 분석합니다.
 *
 * @endpoint POST /fortune-ex-lover
 *
 * @requestBody
 * - name: string - 사용자 이름
 * - ex_name?: string - 전 연인 이름/닉네임
 * - ex_mbti?: string - 전 연인 MBTI
 * - ex_birth_date?: string - 전 연인 생년월일
 * - relationship_duration: string - 관계 기간
 * - time_since_breakup: string - 이별 후 경과 시간
 * - breakup_initiator: string - 이별 통보자 (me/them/mutual)
 * - contact_status: string - 현재 연락 상태
 * - breakup_reason?: string - 이별 이유 (선택지)
 * - breakup_detail?: string - 이별 이유 상세 (자유 텍스트)
 * - current_emotion: string - 현재 감정
 * - main_curiosity: string - 가장 궁금한 것
 * - chat_history?: string - 카톡/대화 내용
 * - isPremium?: boolean - 프리미엄 사용자 여부
 *
 * @response ExLoverResponse
 * - reunion_probability: number - 재회 가능성
 * - karma_analysis: string - 인연 분석
 * - emotional_healing: string[] - 감정 치유 조언
 * - future_outlook: string - 향후 전망
 * - advice: string - 조언
 */
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
  // 상대방 정보
  ex_name?: string
  ex_mbti?: string
  ex_birth_date?: string
  // 관계 정보
  relationship_duration: string
  time_since_breakup: string
  breakup_initiator: string // me, them, mutual
  contact_status: string // blocked, noContact, sometimes, often, stillMeeting
  // 이별 상세
  breakup_reason?: string
  breakup_detail?: string // STT/타이핑으로 입력한 상세 이유
  // 감정 정보
  current_emotion: string // miss, anger, sadness, relief, acceptance
  main_curiosity: string // theirFeelings, reunionChance, newLove, healing
  // 추가 정보
  chat_history?: string // 카톡/대화 내용
  isPremium?: boolean
}

// 한글 변환 헬퍼 함수들
function getRelationshipDurationKorean(duration: string): string {
  const map: Record<string, string> = {
    'lessThan1Month': '1개월 미만',
    '1to3Months': '1-3개월',
    '3to6Months': '3-6개월',
    '6to12Months': '6개월-1년',
    '1to2Years': '1-2년',
    '2to3Years': '2-3년',
    'moreThan3Years': '3년 이상',
  }
  return map[duration] || duration
}

function getTimeSinceBreakupKorean(time: string): string {
  const map: Record<string, string> = {
    'recent': '1개월 미만 (매우 최근)',
    'short': '1-3개월',
    'medium': '3-6개월',
    'long': '6개월-1년',
    'verylong': '1년 이상',
  }
  return map[time] || time
}

function getBreakupInitiatorKorean(initiator: string): string {
  const map: Record<string, string> = {
    'me': '내가 먼저 이별을 말함',
    'them': '상대가 먼저 이별을 말함',
    'mutual': '서로 합의하에 헤어짐',
  }
  return map[initiator] || initiator
}

function getContactStatusKorean(status: string): string {
  const map: Record<string, string> = {
    'blocked': '완전 차단 상태',
    'noContact': '연락 없음',
    'sometimes': '가끔 연락함',
    'often': '자주 연락함',
    'stillMeeting': '아직 만나고 있음',
  }
  return map[status] || status
}

function getCurrentEmotionKorean(emotion: string): string {
  const map: Record<string, string> = {
    'miss': '그리움 (아직도 그 사람이 보고 싶음)',
    'anger': '분노 (배신감과 분노를 느낌)',
    'sadness': '슬픔 (너무 슬프고 외로움)',
    'relief': '안도 (헤어진 게 다행)',
    'acceptance': '받아들임 (이제는 받아들일 수 있음)',
  }
  return map[emotion] || emotion
}

function getMainCuriosityKorean(curiosity: string): string {
  const map: Record<string, string> = {
    'theirFeelings': '상대방 마음 (그 사람도 나를 생각할까?)',
    'reunionChance': '재회 가능성 (우리 다시 만날 수 있을까?)',
    'newLove': '새로운 사랑 (언제 새로운 사랑을 시작할까?)',
    'healing': '치유 방법 (어떻게 마음을 치유할까?)',
  }
  return map[curiosity] || curiosity
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
      ex_name,
      ex_mbti,
      relationship_duration = '',
      time_since_breakup = '',
      breakup_initiator = '',
      contact_status = '',
      breakup_reason,
      breakup_detail,
      current_emotion = '',
      main_curiosity = '',
      chat_history,
      isPremium = false
    } = requestData

    console.log('💎 [ExLover] Premium 상태:', isPremium)

    // 필수 필드 검증
    if (!name || !relationship_duration || !breakup_initiator || !contact_status || !current_emotion || !main_curiosity) {
      throw new Error('필수 정보를 입력해주세요.')
    }

    // breakup_detail이 없으면 에러
    if (!breakup_detail || breakup_detail.trim() === '') {
      throw new Error('이별 이유를 상세히 입력해주세요.')
    }

    console.log('Ex-lover fortune request:', { name, relationship_duration, breakup_initiator })

    // 캐시 키 생성 (상세 내용 제외 - 재사용 가능하게)
    const hash = await createHash(`${name}_${current_emotion}_${time_since_breakup}_${main_curiosity}_${breakup_initiator}_${contact_status}`)
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
      console.log('Cache miss, calling LLM API')

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
5. **맞춤형**: 사용자가 제공한 상세 정보(이별 이유, 대화 내용 등)를 적극 반영

# 출력 형식 (반드시 JSON 형식으로)
{
  "title": "감성적이고 희망적인 제목 (예: 'OOO님, 새로운 인연의 문이 열립니다')",
  "score": 70-95 사이 정수 (전반적인 인연 점수),
  "overall_fortune": "전반적인 운세 분석 (100자 이내, 핵심만 간결하게)",
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
  "comfort_message": "현재 감정에 대한 공감과 희망적 전망 (100자 이내)"
}

# 분량 요구사항 (카드 UI 스크롤 방지)
- 각 항목: 반드시 100자 이내
- overall_fortune, comfort_message: 각각 100자 이내 (핵심만)
- 간결하고 핵심적인 내용만 작성

# 주의사항
- 사용자 정보를 면밀히 분석하여 맞춤형 조언 제공
- 특히 이별 이유 상세(breakup_detail)와 대화 내용(chat_history)을 적극 분석하여 구체적 조언 제공
- 모호한 점술 표현 금지 (예: "때가 되면 알게 됩니다" → 구체적 시기와 조건 명시)
- 부정적 단정 금지 (예: "재회는 불가능합니다" → "현재 조건에서는 어려우나, ~하면 가능성이 열립니다")
- 반드시 유효한 JSON 형식으로 출력`

      // 사용자 프롬프트 생성
      let userPromptParts = [
        `# 상담 요청 정보`,
        ``,
        `## 사용자 정보`,
        `- 이름: ${name}`,
        ``,
        `## 상대방 정보`,
        `- 이름/닉네임: ${ex_name || '미입력'}`,
        `- MBTI: ${ex_mbti && ex_mbti !== 'unknown' ? ex_mbti : '모름'}`,
        ``,
        `## 관계 정보`,
        `- 교제 기간: ${getRelationshipDurationKorean(relationship_duration)}`,
        `- 이별 후 경과: ${getTimeSinceBreakupKorean(time_since_breakup)}`,
        `- 이별 통보자: ${getBreakupInitiatorKorean(breakup_initiator)}`,
        `- 현재 연락 상태: ${getContactStatusKorean(contact_status)}`,
        ``,
        `## 이별 이유`,
        `${breakup_detail}`,
        ``,
        `## 현재 감정 상태`,
        `${getCurrentEmotionKorean(current_emotion)}`,
        ``,
        `## 가장 궁금한 것`,
        `${getMainCuriosityKorean(main_curiosity)}`,
      ]

      // 대화 내용이 있으면 추가
      if (chat_history && chat_history.trim() !== '') {
        userPromptParts.push(
          ``,
          `## 카톡/대화 내용`,
          `\`\`\``,
          chat_history,
          `\`\`\``,
          ``,
          `(위 대화 내용을 분석하여 두 사람의 관계 패턴, 숨겨진 감정, 재회 가능성 등을 파악해주세요)`
        )
      }

      userPromptParts.push(
        ``,
        `위 정보를 바탕으로 전문적이고 상세한 전 애인 운세 분석을 JSON 형식으로 제공해주세요.`,
        `특히 ${name}님의 상황에 맞는 구체적이고 실용적인 조언을 부탁드립니다.`,
        `가장 궁금해하는 "${getMainCuriosityKorean(main_curiosity)}"에 대해 특히 자세히 분석해주세요.`
      )

      const userPrompt = userPromptParts.join('\n')

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
        metadata: {
          name,
          ex_name,
          relationship_duration,
          breakup_initiator,
          contact_status,
          current_emotion,
          main_curiosity,
          has_chat_history: !!chat_history,
          isPremium
        }
      })

      if (!response.content) throw new Error('LLM API 응답을 받을 수 없습니다.')

      const parsedResponse = JSON.parse(response.content)

      // ✅ Blur 로직 적용 (프리미엄이 아니면 일부 섹션 블러 처리)
      const isBlurred = !isPremium
      const blurredSections = isBlurred
        ? ['relationship_analysis', 'breakup_analysis', 'reunion_possibility', 'healing_roadmap', 'new_love_forecast', 'practical_advice']
        : []

      fortuneData = {
        title: parsedResponse.title || `${name}님, 새로운 시작을 응원합니다`,
        fortune_type: 'ex_lover',
        name,
        relationship_duration,
        breakup_initiator,
        contact_status,
        // ✅ 무료: 공개 섹션
        score: parsedResponse.score || Math.floor(Math.random() * 25) + 70,
        overall_fortune: parsedResponse.overall_fortune || '이별은 끝이 아닌 새로운 시작입니다.',
        comfort_message: parsedResponse.comfort_message || '지금의 아픔은 반드시 지나갑니다.',

        // 인연 분석
        relationship_analysis: parsedResponse.relationship_analysis || {
          energy_compatibility: '두 분의 에너지 분석이 진행 중입니다.',
          meeting_meaning: '만남의 의미를 분석 중입니다.',
          karma_interpretation: '인연의 깊이를 해석 중입니다.'
        },

        // 이별 분석
        breakup_analysis: parsedResponse.breakup_analysis || {
          type: '분석 중',
          type_description: '이별 유형을 분석 중입니다.',
          pattern: '관계 패턴을 분석 중입니다.',
          hidden_emotions: '숨겨진 감정을 분석 중입니다.'
        },

        // 재회 가능성
        reunion_possibility: parsedResponse.reunion_possibility || {
          score: 50,
          analysis: '재회 가능성을 분석 중입니다.',
          favorable_timing: '적절한 시기를 분석 중입니다.',
          conditions: ['조건을 분석 중입니다.'],
          recommendation: '추천 방향을 분석 중입니다.'
        },

        // 치유 로드맵
        healing_roadmap: parsedResponse.healing_roadmap || {
          phase1: { period: '수용기', goal: '감정 인정', actions: ['천천히 감정 정리하기'] },
          phase2: { period: '정리기', goal: '관계 복기', actions: ['배움 찾기'] },
          phase3: { period: '회복기', goal: '새로운 시작', actions: ['자기 성장'] }
        },

        // 새로운 인연 전망
        new_love_forecast: parsedResponse.new_love_forecast || {
          timing: '새 인연 시기를 분석 중입니다.',
          ideal_type: '이상형을 분석 중입니다.',
          meeting_context: '만남 계기를 분석 중입니다.'
        },

        // 실천 조언
        practical_advice: parsedResponse.practical_advice || {
          do_now: ['자기 돌봄에 집중하기'],
          never_do: ['충동적 연락 금지'],
          monthly_checklist: ['감정 일기 쓰기']
        },

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
