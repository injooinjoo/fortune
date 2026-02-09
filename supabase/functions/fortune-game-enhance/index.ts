/**
 * 게임 강화운세 (Game Enhance Fortune) Edge Function
 *
 * @description 게임 강화 직전에 보는 운세. 강화 성공 확률 UP 느낌을 주는 것이 핵심.
 *
 * 특징:
 * - 입력 없이 범용 (게임/대상 선택 불필요)
 * - 블러 없음 (완전 무료)
 * - 토큰 후원 기능 지원
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { crypto } from 'https://deno.land/std@0.168.0/crypto/mod.ts'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'
import { calculatePercentile, addPercentileToResult } from '../_shared/percentile/calculator.ts'
import {
  generateCohortHash,
  getFromCohortPool,
  saveToCohortPool,
  personalize,
} from '../_shared/cohort/index.ts'

const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY')!
const supabase = createClient(supabaseUrl, supabaseKey)

async function createHash(text: string): Promise<string> {
  const encoder = new TextEncoder()
  const data = encoder.encode(text)
  const hashBuffer = await crypto.subtle.digest('SHA-256', data)
  const hashArray = Array.from(new Uint8Array(hashBuffer))
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('').slice(0, 50)
}

function getTimeContext(): { hour: number; period: string; element: string } {
  const now = new Date()
  const hour = now.getHours()

  let period: string
  let element: string

  if (hour >= 5 && hour < 9) {
    period = '새벽-아침'
    element = '목(木)'
  } else if (hour >= 9 && hour < 12) {
    period = '오전'
    element = '화(火)'
  } else if (hour >= 12 && hour < 14) {
    period = '점심'
    element = '토(土)'
  } else if (hour >= 14 && hour < 18) {
    period = '오후'
    element = '금(金)'
  } else if (hour >= 18 && hour < 21) {
    period = '저녁'
    element = '수(水)'
  } else {
    period = '심야'
    element = '수(水)'
  }

  return { hour, period, element }
}

function getDateContext(): { year: number; month: number; day: number; weekday: string; weekdayNum: number } {
  const now = new Date()
  const weekdays = ['일', '월', '화', '수', '목', '금', '토']

  return {
    year: now.getFullYear(),
    month: now.getMonth() + 1,
    day: now.getDate(),
    weekday: weekdays[now.getDay()],
    weekdayNum: now.getDay()
  }
}

interface GameEnhanceRequest {
  userId?: string
  birthDate?: string
  gender?: string
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
    const requestData: GameEnhanceRequest = await req.json()
    const { birthDate, gender } = requestData

    const timeContext = getTimeContext()
    const dateContext = getDateContext()

    console.log('Game enhance fortune request:', { timeContext, dateContext })

    const hash = await createHash(`game_enhance_${dateContext.year}_${dateContext.month}_${dateContext.day}_${birthDate || ''}`)
    const cacheKey = `game_enhance_v1_${hash}`
    const { data: cachedResult } = await supabase
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .single()

    let fortuneData: any

    // Cohort Pool 조회
    const cohortData = { birthDate: birthDate?.slice(0, 7) || 'general' }
    const cohortHash = await generateCohortHash(cohortData)
    console.log(`[fortune-game-enhance] Cohort: ${JSON.stringify(cohortData)}, hash: ${cohortHash.slice(0, 8)}...`)

    if (cachedResult?.result) {
      console.log('Cache hit for game enhance fortune')
      fortuneData = cachedResult.result
    } else {
      const cohortResult = await getFromCohortPool(supabase, 'gameEnhance', cohortHash)

      if (cohortResult) {
        console.log(`[fortune-game-enhance] Cohort Pool HIT!`)

        const personalizedResult = personalize(cohortResult, {
          '{{date}}': `${dateContext.month}/${dateContext.day}`,
          '{{weekday}}': dateContext.weekday,
          '{{period}}': timeContext.period,
        })

        fortuneData = typeof personalizedResult === 'string'
          ? JSON.parse(personalizedResult)
          : personalizedResult

        fortuneData.timestamp = new Date().toISOString()
      } else {
        console.log('[fortune-game-enhance] Cohort Pool MISS - LLM 호출 필요')

        const prompt = `당신은 게임 강화의 신비한 점술사예요!
게이머들의 마음을 알고, 강화 성공의 기운을 읽어내는 전문가입니다.

## 캐릭터 설정
- 게임 문화와 강화 미신에 정통한 점술사
- 따뜻하지만 게이머 슬랭도 자연스럽게 사용
- "터진다", "가즈아", "스택 쌓인다" 같은 표현 OK

## 핵심 원칙
1. **희망을 주되, 현실적으로**: 무조건 "성공한다"가 아닌, 구체적인 조건과 시간 제시
2. **미신을 존중하되, 재미있게**: NPC 앞 강화, 특정 시간 등 게임 미신을 오행/사주와 연결
3. **실패해도 긍정적으로**: "스택 쌓였잖아요"처럼 위로와 다음 기회 제시
4. **여러 게임에 적용 가능**: 메이플, 로아, 검은사막, 리니지 등 범용적 표현

## 스타일 가이드
❌ "강화에 성공할 것입니다"
✅ "오후 2시 22분, 찬스타임 발동 기운이 느껴져요! 이때 가시죠"

❌ "조심하세요"
✅ "파괴 방지 기운이 약해요... 오늘은 +17에서 멈추는 센스! 내일 가즈아~"

## 오행 연결 (게임 강화 버전)
- 목(木): 성장/상승 - 강화 레벨 UP
- 화(火): 열정/도전 - 고위험 강화 시도
- 토(土): 안정/보호 - 파괴 방지
- 금(金): 재화/자원 - 재료 확보
- 수(水): 흐름/타이밍 - 찬스타임, 황금 시간

🚨 [최우선 규칙] 모든 응답은 반드시 한국어로 작성하세요!

🎯 현재 컨텍스트:
- 날짜: ${dateContext.year}년 ${dateContext.month}월 ${dateContext.day}일 (${dateContext.weekday}요일)
- 시간대: ${timeContext.period} (${timeContext.hour}시)
- 현재 기운: ${timeContext.element}
${birthDate ? `- 생년월일: ${birthDate}` : ''}
${gender ? `- 성별: ${gender === 'male' ? '남성' : '여성'}` : ''}

다음 JSON 형식으로 응답해주세요:

{
  "score": 85,
  "lucky_grade": "S",
  "status_message": "오늘 강화, 해도 됩니다!",

  "enhance_stats": {
    "success_aura": 88,
    "success_aura_desc": "강화석이 평소보다 2배 빛나는 날이에요",
    "protection_field": 72,
    "protection_field_desc": "파괴 방지 기운 중상위권. 안심은 금물!",
    "chance_time_active": true,
    "chance_time_desc": "14:00-16:00 찬스타임 발동 예정!",
    "stack_bonus": "UP",
    "stack_bonus_desc": "실패 스택이 임계점에 가까워지고 있어요"
  },

  "lucky_times": {
    "golden_hour": "14:22",
    "golden_hour_range": "14:00-16:00",
    "golden_hour_reason": "목(木) 기운이 화(火)를 만나 상승 에너지 폭발",
    "avoid_time": "03:00-05:00",
    "avoid_time_reason": "수(水) 기운 과잉으로 파괴 위험 상승"
  },

  "enhance_ritual": {
    "lucky_spot": "강화장인 NPC 왼쪽 세 번째 칸",
    "lucky_direction": "캐릭터가 동쪽(오른쪽)을 바라볼 때",
    "lucky_action": "강화 버튼 누르기 전 점프 3번 + 앉기 1번",
    "lucky_phrase": "오늘은 간다!",
    "avoid_action": "친구 강화 구경 금지 (기운 분산)"
  },

  "enhance_roadmap": [
    { "phase": "1단계: 워밍업", "action": "+10까지 안전하게", "tip": "손 풀기용, 긴장 풀기", "risk_level": "low" },
    { "phase": "2단계: 본 강화", "action": "+15까지 도전", "tip": "황금시간에 집중 시도", "risk_level": "medium" },
    { "phase": "3단계: 정리", "action": "오늘 여기서 STOP", "tip": "욕심 금물, 내일 이어가요", "risk_level": "high" }
  ],

  "lucky_info": {
    "lucky_number": 7,
    "lucky_number_meaning": "+17에서 멈추세요. 7의 기운이 보호해요",
    "lucky_color": "빨간색",
    "lucky_color_tip": "빨간 의자 or 빨간 마우스패드 위에서",
    "lucky_food": "치킨",
    "lucky_food_reason": "닭은 날아오르는 기운! 강화 성공률 UP"
  },

  "warnings": [
    "연속 5회 이상 실패 시 반드시 휴식",
    "새벽 3-5시 강화 절대 금지",
    "친구가 터뜨린 직후 따라하기 금지 (기운 소진됨)"
  ],

  "encouragement": {
    "before_enhance": "깊게 숨 쉬고... 3, 2, 1... 가즈아!",
    "on_success": "역시 오늘 기운 맞았어요! 축하드려요",
    "on_fail": "괜찮아요! 스택 쌓였잖아요. 다음엔 진짜 터져요"
  },

  "hashtags": ["#강화성공기원", "#찬스타임", "#스타캐치장인"],

  "summary": "S등급 강화운! 오후 2시 황금시간을 노리세요",
  "content": "오늘 당신의 사주에서 목(木)과 화(火)의 기운이 강하게 느껴져요. 이 조합은 '성장과 열정'을 의미하는데, 게임 강화에서는 상승 에너지로 작용해요. 특히 오후 2시대에 이 기운이 최고조에 달하니, 이 시간을 놓치지 마세요!",
  "advice": "욕심 부리지 마세요. +15까지만 오늘 도전하고, 나머지는 내일로! 안전하게 가는 것도 실력이에요"
}

⚠️ 중요 규칙:
1. 모든 텍스트는 한국어로 작성
2. score는 50-100 사이 정수
3. lucky_grade는 "SSS", "SS", "S", "A", "B", "C" 중 하나
4. enhance_stats의 success_aura, protection_field는 50-100 사이 정수
5. stack_bonus는 "UP", "DOWN", "STABLE" 중 하나
6. enhance_roadmap은 3개 단계 고정
7. warnings는 3개 고정
8. hashtags는 3개 해시태그 배열 (# 포함)
9. lucky_number는 1-30 사이 정수 (강화 레벨 의미)
10. 현재 시간대(${timeContext.period})를 고려한 황금 시간 설정
11. ${dateContext.weekday}요일 특성 반영 (월요일은 새출발, 금요일은 도전 등)`

        const llm = await LLMFactory.createFromConfigAsync('gameEnhance')

        const response = await llm.generate([
          {
            role: 'system',
            content: '당신은 게임 강화의 신비한 점술사! 게이머들에게 강화 성공의 기운을 불어넣어주세요. 재미있고 구체적인 조언으로 실제로 도움이 되는 느낌을 주세요.'
          },
          {
            role: 'user',
            content: prompt
          }
        ], {
          temperature: 1,
          maxTokens: 2048,
          jsonMode: true
        })

        console.log(`LLM 호출 완료: ${response.provider}/${response.model} - ${response.latency}ms`)

        await UsageLogger.log({
          fortuneType: 'gameEnhance',
          provider: response.provider,
          model: response.model,
          response: response,
          metadata: { timeContext, dateContext }
        })

        let parsedResponse: any
        try {
          parsedResponse = JSON.parse(response.content)
        } catch (error) {
          console.error('JSON parsing error:', error)
          throw new Error('API 응답 형식이 올바르지 않습니다.')
        }

        // 응답 정규화
        const enhanceStats = parsedResponse.enhance_stats || {
          success_aura: 80,
          success_aura_desc: '강화석이 반짝이는 날이에요',
          protection_field: 70,
          protection_field_desc: '파괴 방지 기운 양호',
          chance_time_active: false,
          chance_time_desc: '찬스타임 대기 중',
          stack_bonus: 'STABLE',
          stack_bonus_desc: '스택이 안정적입니다'
        }

        const luckyTimes = parsedResponse.lucky_times || {
          golden_hour: '14:00',
          golden_hour_range: '14:00-16:00',
          golden_hour_reason: '오후의 기운이 상승',
          avoid_time: '03:00-05:00',
          avoid_time_reason: '파괴 위험 상승'
        }

        const enhanceRitual = parsedResponse.enhance_ritual || {
          lucky_spot: 'NPC 근처',
          lucky_direction: '동쪽',
          lucky_action: '점프 3번',
          lucky_phrase: '가즈아!',
          avoid_action: '구경 금지'
        }

        const enhanceRoadmap = parsedResponse.enhance_roadmap || [
          { phase: '1단계', action: '+10까지', tip: '워밍업', risk_level: 'low' },
          { phase: '2단계', action: '+15까지', tip: '집중', risk_level: 'medium' },
          { phase: '3단계', action: 'STOP', tip: '내일 계속', risk_level: 'high' }
        ]

        const luckyInfo = parsedResponse.lucky_info || {
          lucky_number: 7,
          lucky_number_meaning: '+7에서 멈추세요',
          lucky_color: '빨간색',
          lucky_color_tip: '빨간 아이템',
          lucky_food: '치킨',
          lucky_food_reason: '상승 기운'
        }

        const warnings = parsedResponse.warnings || [
          '연속 5회 실패 시 휴식',
          '새벽 강화 금지',
          '따라하기 금지'
        ]

        const encouragement = parsedResponse.encouragement || {
          before_enhance: '가즈아!',
          on_success: '축하해요!',
          on_fail: '스택 쌓였어요!'
        }

        const hashtags = parsedResponse.hashtags || ['#강화성공', '#찬스타임', '#가즈아']

        fortuneData = {
          fortune_type: 'gameEnhance',
          title: '강화의 기운',

          // 핵심 점수
          score: parsedResponse.score || 80,
          lucky_grade: parsedResponse.lucky_grade || 'A',
          status_message: parsedResponse.status_message || '오늘 강화운 좋아요!',

          // 강화 스탯
          enhance_stats: enhanceStats,

          // 시간대
          lucky_times: luckyTimes,

          // 강화 의식
          enhance_ritual: enhanceRitual,

          // 로드맵
          enhance_roadmap: enhanceRoadmap,

          // 행운 정보
          lucky_info: luckyInfo,

          // 경고
          warnings: warnings,

          // 응원 메시지
          encouragement: encouragement,

          // 해시태그
          hashtags: hashtags,

          // 요약
          summary: parsedResponse.summary || 'S등급 강화운!',
          content: parsedResponse.content || '오늘 강화 기운이 좋습니다.',
          advice: parsedResponse.advice || '욕심 부리지 말고 적당히!',

          timestamp: new Date().toISOString()
        }

        // 캐시 저장
        await supabase
          .from('fortune_cache')
          .insert({
            cache_key: cacheKey,
            result: fortuneData,
            fortune_type: 'gameEnhance',
            expires_at: new Date(Date.now() + 6 * 60 * 60 * 1000).toISOString() // 6시간 캐시
          })

        // Cohort Pool 저장
        saveToCohortPool(supabase, 'gameEnhance', cohortHash, fortuneData)
          .then(() => console.log(`[fortune-game-enhance] Cohort Pool 저장 완료`))
          .catch((err) => console.error(`[fortune-game-enhance] Cohort Pool 저장 실패:`, err))
      }
    }

    const percentileData = await calculatePercentile(supabase, 'gameEnhance', fortuneData.score)
    const fortuneDataWithPercentile = addPercentileToResult(fortuneData, percentileData)

    return new Response(JSON.stringify({
      success: true,
      data: fortuneDataWithPercentile
    }), {
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
      },
    })

  } catch (error) {
    console.error('Game Enhance Fortune Error:', error)

    return new Response(JSON.stringify({
      success: false,
      data: {},
      error: error instanceof Error ? error.message : '강화운 분석 중 오류가 발생했습니다.'
    }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
      },
    })
  }
})
