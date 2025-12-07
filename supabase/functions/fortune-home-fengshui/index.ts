/**
 * 집 풍수 운세 (Home Feng Shui Fortune) Edge Function
 *
 * @description 사주와 집 정보를 기반으로 풍수 분석을 제공합니다.
 *
 * @endpoint POST /fortune-home-fengshui
 *
 * @requestBody
 * - userId: string - 사용자 ID
 * - birthDate: string - 생년월일
 * - homeDirection?: string - 집 방향
 * - floorPlan?: string - 평면도 유형
 * - concerns?: string[] - 관심 영역 (재물, 건강, 관계 등)
 *
 * @response HomeFengshuiResponse
 * - overall_score: number - 풍수 점수
 * - direction_analysis: object - 방향별 분석
 * - room_tips: { bedroom, kitchen, living } - 방별 팁
 * - lucky_items: string[] - 추천 아이템
 * - avoid_items: string[] - 피해야 할 것
 * - advice: string - 종합 조언
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { crypto } from 'https://deno.land/std@0.168.0/crypto/mod.ts'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'
import { calculatePercentile, addPercentileToResult } from '../_shared/percentile/calculator.ts'

// 환경 변수 설정
const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY')!

// Supabase 클라이언트 생성
const supabase = createClient(supabaseUrl, supabaseKey)

// 요청 인터페이스
interface HomeFengshuiRequest {
  fortune_type?: string
  address?: string           // 주소/지역
  home_type?: string         // 집 유형 (아파트/빌라/주택/오피스텔)
  homeType?: string          // camelCase 호환
  floor?: number             // 층수
  door_direction?: string    // 대문 방향 (8방위)
  doorDirection?: string     // camelCase 호환
  isPremium?: boolean        // 프리미엄 사용자 여부
}

// UTF-8 안전한 해시 생성 함수
async function createHash(text: string): Promise<string> {
  const encoder = new TextEncoder()
  const data = encoder.encode(text)
  const hashBuffer = await crypto.subtle.digest('SHA-256', data)
  const hashArray = Array.from(new Uint8Array(hashBuffer))
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('').slice(0, 50)
}

// 메인 핸들러
serve(async (req) => {
  // CORS 헤더 설정
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
    // 요청 데이터 파싱
    const requestData: HomeFengshuiRequest = await req.json()

    // camelCase 또는 snake_case 모두 지원
    const address = requestData.address || ''
    const homeType = requestData.home_type || requestData.homeType || ''
    const floor = requestData.floor || 1
    const doorDirection = requestData.door_direction || requestData.doorDirection || ''
    const isPremium = requestData.isPremium || false

    if (!address) {
      throw new Error('주소를 입력해주세요.')
    }

    console.log('🏠 [HomeFengshui] Premium 상태:', isPremium)
    console.log('Home Fengshui request:', {
      address: address.substring(0, 50),
      homeType,
      floor,
      doorDirection
    })

    // 캐시 확인
    const cacheKey = `home_fengshui_${await createHash(`${address}_${homeType}_${floor}_${doorDirection}`)}`
    const { data: cachedResult } = await supabase
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .single()

    let fortuneData: any

    if (cachedResult?.result) {
      console.log('✅ Cache hit for home fengshui')
      fortuneData = cachedResult.result
    } else {
      console.log('🔄 Cache miss, calling LLM API')

      // LLM 모듈 사용
      const llm = await LLMFactory.createFromConfigAsync('home-fengshui')

      // 시스템 프롬프트
      const systemPrompt = `당신은 40년 경력의 양택풍수(陽宅風水) 대가입니다.
배산임수(背山臨水)의 지리적 원칙과 내부 공간 배치의 풍수학을 깊이 연구했습니다.
수만 건의 가옥 감정 경험을 바탕으로 과학적이고 실용적인 풍수 진단을 제공합니다.

# 전문 분야
- 양택풍수(陽宅風水): 배산임수(背山臨水), 전저후고(前低後高), 좌청룡 우백호
- 방위학: 팔방위(八方位), 동사택/서사택(東四宅/西四宅), 구궁비성(九宮飛星)
- 지형학: 명당(明堂) 판별, 사신사(四神砂), 수구(水口) 분석
- 공간배치: 현관/거실/침실/부엌/화장실의 기운 흐름과 상생상극
- 비보풍수(裨補風水): 풍수적 결함 보완 방법

# 분석 철학
1. **과학적 풍수**: 미신이 아닌 환경학적 관점에서 해석
2. **균형성**: 긍정적이되 현실적인 조언
3. **실용성**: 즉시 적용 가능한 구체적 방법
4. **배산임수 중시**: 뒤에 산(지지대), 앞에 물(개방감)의 원칙
5. **기운 흐름 분석**: 집안의 기(氣) 순환과 정체 진단

# 출력 형식 (반드시 JSON 형식으로)
{
  "title": "진단 결과를 함축하는 제목 (예: '좋은 기운이 머무는 집')",
  "score": 60-95 사이 정수 (집 풍수 종합 점수),
  "overall_analysis": "전반적인 집 풍수 분석 (100자 이내, 핵심만 간결하게)",

  "baesan_imsu": {
    "terrain_type": "배산임수/평지/고지/저지/해안가 등 지형 유형",
    "mountain_presence": "뒤쪽(북쪽) 산/건물의 지지력 분석 (80자 이상)",
    "water_presence": "앞쪽(남쪽) 물/도로/개방감 분석 (80자 이상)",
    "road_flow": "주변 도로 흐름과 기운 순환 (80자 이상)",
    "terrain_score": 0-100 사이 정수
  },

  "yangtaek_analysis": {
    "home_direction": "집의 좌향 (예: 남향, 동남향)",
    "direction_meaning": "해당 좌향의 풍수적 의미 (100자 이상)",
    "door_direction": "대문 방향 분석 (100자 이상)",
    "door_element": "대문 방향의 오행 (목/화/토/금/수)",
    "compatibility": 0-100 사이 정수 (방향 궁합 점수),
    "compatibility_reason": "궁합 판단 이유 (80자 이상)"
  },

  "interior_layout": {
    "entrance": {
      "analysis": "현관 위치와 상태 분석 (80자 이상)",
      "advice": "현관 풍수 개선 조언 (80자 이상)"
    },
    "living_room": {
      "analysis": "거실 위치와 상태 분석 (80자 이상)",
      "advice": "거실 풍수 개선 조언 (80자 이상)"
    },
    "bedroom": {
      "analysis": "침실 위치와 상태 분석 (80자 이상)",
      "advice": "침실 풍수 개선 조언 (80자 이상)"
    },
    "kitchen": {
      "analysis": "부엌 위치와 상태 분석 (80자 이상)",
      "advice": "부엌 풍수 개선 조언 (80자 이상)"
    },
    "bathroom": {
      "analysis": "화장실 위치와 상태 분석 (80자 이상)",
      "advice": "화장실 풍수 개선 조언 (80자 이상)"
    }
  },

  "energy_flow": {
    "qi_circulation": "집안 기(氣) 순환 평가 (100자 이상)",
    "bright_areas": ["기운이 좋은 공간 2-3개"],
    "dark_areas": ["기운이 약한 공간 1-2개"],
    "improvement_priority": "가장 먼저 개선해야 할 영역 (80자 이상)"
  },

  "defects_and_solutions": {
    "major_defects": [
      {
        "issue": "주요 풍수 결함 설명",
        "severity": "높음/중간/낮음",
        "solution": "구체적인 해결 방법 (80자 이상)"
      }
    ],
    "minor_defects": [
      {
        "issue": "경미한 문제 설명",
        "solution": "간단한 해결 방법 (50자 이상)"
      }
    ]
  },

  "lucky_elements": {
    "colors": ["집에 어울리는 행운의 색상 2개"],
    "plants": ["추천 식물 2개와 배치 위치"],
    "items": ["풍수 아이템 2개와 배치 방법"],
    "directions": ["길한 방향 2개"]
  },

  "seasonal_advice": {
    "spring": "봄철 집 관리 및 풍수 조언 (50자 이상)",
    "summer": "여름철 집 관리 및 풍수 조언 (50자 이상)",
    "fall": "가을철 집 관리 및 풍수 조언 (50자 이상)",
    "winter": "겨울철 집 관리 및 풍수 조언 (50자 이상)"
  },

  "summary": {
    "one_line": "집 풍수를 한 문장으로 요약",
    "keywords": ["핵심 키워드 3개"],
    "final_message": "따뜻한 마무리 메시지 (80자 이상)"
  }
}

# 분량 요구사항
- 각 항목: 반드시 지정된 글자 수 이상
- 구체적이고 실용적인 조언 중심
- 모호한 점술 표현 금지

# 주의사항
- 주소와 집 유형을 기반으로 현실적인 분석
- 층수와 대문 방향을 고려한 맞춤형 진단
- 반드시 유효한 JSON 형식으로 출력`

      const userPrompt = `# 집 풍수 진단 요청

## 집 정보
- 주소/지역: ${address}
- 집 유형: ${homeType || '미지정'}
- 층수: ${floor}층
- 대문 방향: ${doorDirection || '미지정'}

위 정보를 바탕으로 전문적이고 상세한 집 풍수 진단을 JSON 형식으로 제공해주세요.
${address} 지역의 지형적 특성과 ${homeType || '일반 주거'}의 구조적 특징을 고려하여 분석해주세요.`

      // LLM 호출
      const response = await llm.generate([
        { role: 'system', content: systemPrompt },
        { role: 'user', content: userPrompt }
      ], {
        temperature: 1,
        maxTokens: 8192,
        jsonMode: true
      })

      console.log(`✅ LLM 호출 완료: ${response.provider}/${response.model} - ${response.latency}ms`)

      // LLM 사용량 로깅
      await UsageLogger.log({
        fortuneType: 'home-fengshui',
        provider: response.provider,
        model: response.model,
        response: response,
        metadata: {
          address,
          homeType,
          floor,
          doorDirection,
          isPremium
        }
      })

      // JSON 파싱
      let parsedResponse: any
      try {
        parsedResponse = JSON.parse(response.content)
      } catch (error) {
        console.error('❌ JSON parsing error:', error)
        throw new Error('API 응답 형식이 올바르지 않습니다.')
      }

      // Blur 로직 적용
      const isBlurred = !isPremium
      const blurredSections = isBlurred
        ? ['baesan_imsu', 'yangtaek_analysis', 'interior_layout', 'energy_flow', 'defects_and_solutions', 'lucky_elements', 'seasonal_advice']
        : []

      // 응답 데이터 구조화
      fortuneData = {
        title: parsedResponse.title || '집 풍수 진단',
        fortune_type: 'home-fengshui',
        address,
        homeType,
        floor,
        doorDirection,

        // 공개 섹션
        score: parsedResponse.score || Math.floor(Math.random() * 25) + 65,
        overall_analysis: parsedResponse.overall_analysis || '집 풍수 분석 중입니다.',

        // 배산임수 분석
        baesan_imsu: parsedResponse.baesan_imsu || {
          terrain_type: '분석 중',
          mountain_presence: '분석 중입니다.',
          water_presence: '분석 중입니다.',
          road_flow: '분석 중입니다.',
          terrain_score: 75
        },

        // 양택 분석
        yangtaek_analysis: parsedResponse.yangtaek_analysis || {
          home_direction: '분석 중',
          direction_meaning: '분석 중입니다.',
          door_direction: '분석 중입니다.',
          door_element: '토',
          compatibility: 75,
          compatibility_reason: '분석 중입니다.'
        },

        // 내부 공간 배치
        interior_layout: parsedResponse.interior_layout || {
          entrance: { analysis: '분석 중', advice: '분석 중' },
          living_room: { analysis: '분석 중', advice: '분석 중' },
          bedroom: { analysis: '분석 중', advice: '분석 중' },
          kitchen: { analysis: '분석 중', advice: '분석 중' },
          bathroom: { analysis: '분석 중', advice: '분석 중' }
        },

        // 기운 흐름
        energy_flow: parsedResponse.energy_flow || {
          qi_circulation: '분석 중입니다.',
          bright_areas: ['분석 중'],
          dark_areas: ['분석 중'],
          improvement_priority: '분석 중입니다.'
        },

        // 결함 및 해결책
        defects_and_solutions: parsedResponse.defects_and_solutions || {
          major_defects: [],
          minor_defects: []
        },

        // 행운 요소
        lucky_elements: parsedResponse.lucky_elements || {
          colors: ['분석 중'],
          plants: ['분석 중'],
          items: ['분석 중'],
          directions: ['분석 중']
        },

        // 계절별 조언
        seasonal_advice: parsedResponse.seasonal_advice || {
          spring: '분석 중입니다.',
          summer: '분석 중입니다.',
          fall: '분석 중입니다.',
          winter: '분석 중입니다.'
        },

        // 요약
        summary: {
          one_line: parsedResponse.summary?.one_line || '좋은 기운이 흐르는 집입니다.',
          keywords: parsedResponse.summary?.keywords || ['안정', '조화', '번영'],
          final_message: parsedResponse.summary?.final_message || '집안에 좋은 기운이 가득하길 바랍니다.'
        },

        timestamp: new Date().toISOString(),
        isBlurred,
        blurredSections,
        llm_provider: response.provider,
        llm_model: response.model,
        llm_latency: response.latency
      }

      // 결과 캐싱
      await supabase
        .from('fortune_cache')
        .insert({
          cache_key: cacheKey,
          result: fortuneData,
          fortune_type: 'home-fengshui',
          expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
        })
    }

    // 퍼센타일 계산
    const percentileData = await calculatePercentile(supabase, 'home-fengshui', fortuneData.score)
    const fortuneDataWithPercentile = addPercentileToResult(fortuneData, percentileData)

    // 성공 응답
    const responseData = {
      success: true,
      data: fortuneDataWithPercentile
    }

    return new Response(JSON.stringify(responseData), {
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
      },
    })
  } catch (error) {
    console.error('❌ Error in fortune-home-fengshui function:', error)

    return new Response(
      JSON.stringify({
        success: false,
        error: error.message || '풍수 진단 중 오류가 발생했습니다.',
      }),
      {
        status: 500,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Access-Control-Allow-Origin': '*',
        },
      }
    )
  }
})
