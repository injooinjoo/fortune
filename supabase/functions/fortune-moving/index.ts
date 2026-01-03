/**
 * 이사 운세 (Moving Fortune) Edge Function
 *
 * @description 현재 거주지와 이사 예정지를 기반으로 이사 시기와 방향의 길흉을 분석합니다.
 *
 * @endpoint POST /fortune-moving
 *
 * @requestBody
 * - fortune_type?: string - 운세 유형
 * - currentArea/current_area: string - 현재 거주 지역
 * - targetArea/target_area: string - 이사 예정 지역
 * - movingPeriod/moving_period?: string - 이사 예정 시기
 * - purpose: string - 이사 목적
 * - isPremium?: boolean - 프리미엄 사용자 여부
 *
 * @response MovingFortuneResponse
 * - overallScore: number - 이사 운세 종합 점수 (0-100)
 * - directionAnalysis: object - 방향별 길흉 분석
 * - timingAdvice: object - 시기별 추천 분석
 * - areaCompatibility: object - 지역 궁합도
 * - warnings: string[] - 주의사항
 * - recommendations: string[] - 추천 사항
 * - advice: string - 종합 조언
 * - isBlurred: boolean - 블러 상태
 * - blurredSections: string[] - 블러된 섹션 목록
 *
 * @example
 * // Request
 * {
 *   "currentArea": "서울 강남구",
 *   "targetArea": "경기도 분당",
 *   "movingPeriod": "2024년 3월",
 *   "purpose": "출퇴근 편의",
 *   "isPremium": false
 * }
 *
 * // Response
 * {
 *   "success": true,
 *   "data": {
 *     "overallScore": 78,
 *     "directionAnalysis": { "direction": "동남", "score": 85 },
 *     "timingAdvice": { "bestMonth": "3월", "reason": "..." },
 *     ...
 *   }
 * }
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

// 좌표 인터페이스
interface Coordinates {
  lat: number
  lng: number
}

// 요청 인터페이스
interface MovingFortuneRequest {
  fortune_type?: string
  current_area?: string  // snake_case (호환성)
  target_area?: string   // snake_case (호환성)
  currentArea?: string   // camelCase (Flutter)
  targetArea?: string    // camelCase (Flutter)
  moving_period?: string // snake_case (호환성)
  movingPeriod?: string  // camelCase (Flutter)
  purpose: string
  isPremium?: boolean    // ✅ 프리미엄 사용자 여부

  // ✅ 신규 필드 (v2 - 앱에서 자동 계산)
  direction?: string                // 앱에서 계산한 8방위 (북/동북/동/동남/남/서남/서/서북)
  currentCoords?: Coordinates       // 현재 위치 좌표
  targetCoords?: Coordinates        // 이사 예정지 좌표
  purposeCategory?: string          // 이사 목적 카테고리 (직장/학교/결혼/가족/환경/투자/기타)
  concerns?: string[]               // 걱정 사항 배열
}

// ✅ 8방위 계산 함수 (앱에서 안 보내면 폴백용)
function calculateDirection(fromLat: number, fromLng: number, toLat: number, toLng: number): string {
  const directions = ['북', '동북', '동', '동남', '남', '서남', '서', '서북']

  const dLng = toLng - fromLng
  const dLat = toLat - fromLat

  // atan2로 각도 계산 (북쪽 0도, 시계방향)
  let angle = Math.atan2(dLng, dLat) * (180 / Math.PI)

  // 음수 각도를 양수로 변환 (0~360도)
  if (angle < 0) {
    angle += 360
  }

  // 8방위로 변환 (각 방위는 45도씩)
  const index = Math.floor((angle + 22.5) / 45) % 8

  return directions[index]
}

// ✅ 지역명으로 방향 추론 (좌표 없을 때 폴백)
function inferDirectionFromRegions(fromRegion: string, toRegion: string): string | null {
  const regionCoords: Record<string, [number, number]> = {
    '서울': [37.5665, 126.9780],
    '부산': [35.1796, 129.0756],
    '대구': [35.8714, 128.6014],
    '인천': [37.4563, 126.7052],
    '광주': [35.1595, 126.8526],
    '대전': [36.3504, 127.3845],
    '울산': [35.5384, 129.3114],
    '세종': [36.4800, 127.2890],
    '경기': [37.4138, 127.5183],
    '강원': [37.8228, 128.1555],
    '충북': [36.6357, 127.4912],
    '충남': [36.5184, 126.8000],
    '전북': [35.8203, 127.1089],
    '전남': [34.8679, 126.9910],
    '경북': [36.4919, 128.8889],
    '경남': [35.4606, 128.2132],
    '제주': [33.4996, 126.5312],
    '분당': [37.3825, 127.1191],
    '성남': [37.4200, 127.1267],
    '수원': [37.2636, 127.0286],
    '용인': [37.2411, 127.1776],
    '고양': [37.6584, 126.8320],
    '안양': [37.3943, 126.9568],
    '청주': [36.6424, 127.4890],
    '천안': [36.8151, 127.1139],
  }

  // 지역명에서 키 추출
  let fromKey: string | null = null
  let toKey: string | null = null

  for (const key of Object.keys(regionCoords)) {
    if (fromRegion.includes(key)) fromKey = key
    if (toRegion.includes(key)) toKey = key
  }

  if (!fromKey || !toKey || fromKey === toKey) {
    return null
  }

  const from = regionCoords[fromKey]
  const to = regionCoords[toKey]

  return calculateDirection(from[0], from[1], to[0], to[1])
}

// UTF-8 안전한 해시 생성 함수 (btoa는 Latin1만 지원하여 한글 불가)
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
    const requestData: MovingFortuneRequest = await req.json()

    // camelCase 또는 snake_case 모두 지원
    const current_area = requestData.current_area || requestData.currentArea || ''
    const target_area = requestData.target_area || requestData.targetArea || ''
    const moving_period = requestData.moving_period || requestData.movingPeriod || ''
    const purpose = requestData.purpose || ''
    const isPremium = requestData.isPremium || false // ✅ 프리미엄 사용자 여부

    // ✅ 신규 필드 (v2)
    const currentCoords = requestData.currentCoords
    const targetCoords = requestData.targetCoords
    const purposeCategory = requestData.purposeCategory || purpose
    const concerns = requestData.concerns || []

    // ✅ 방향 결정 (우선순위: 앱 계산값 > 좌표 계산 > 지역명 추론)
    let direction = requestData.direction || ''
    if (!direction && currentCoords && targetCoords) {
      direction = calculateDirection(
        currentCoords.lat, currentCoords.lng,
        targetCoords.lat, targetCoords.lng
      )
      console.log('📍 [Moving] Direction calculated from coords:', direction)
    }
    if (!direction) {
      direction = inferDirectionFromRegions(current_area, target_area) || ''
      if (direction) {
        console.log('📍 [Moving] Direction inferred from region names:', direction)
      }
    }

    if (!current_area || !target_area) {
      throw new Error('현재 지역과 이사갈 지역을 입력해주세요.')
    }

    console.log('💎 [Moving] Premium 상태:', isPremium)
    console.log('Moving fortune request:', {
      current_area: current_area.substring(0, 50),
      target_area: target_area.substring(0, 50),
      moving_period,
      purpose,
      direction,
      purposeCategory,
      concerns: concerns.join(', '),
      hasCoords: !!(currentCoords && targetCoords)
    })

    // 캐시 확인 (UTF-8 안전한 해시 사용)
    const cacheKey = `moving_fortune_${await createHash(`${current_area}_${target_area}_${moving_period}_${purpose}`)}`
    const { data: cachedResult } = await supabase
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .single()

    let fortuneData: any

    if (cachedResult?.result) {
      console.log('✅ Cache hit for moving fortune')
      fortuneData = cachedResult.result
    } else {
      console.log('🔄 Cache miss, calling LLM API')

      // ✅ LLM 모듈 사용 (동적 DB 설정 - A/B 테스트 지원)
      const llm = await LLMFactory.createFromConfigAsync('moving')

      // ✅ 강화된 시스템 프롬프트 (풍수지리 전문가 페르소나 + 분석 프레임워크)
      const systemPrompt = `당신은 30년 경력의 풍수지리(風水地理) 전문가이자 택일(擇日) 전문 상담사입니다.
동양 철학의 음양오행(陰陽五行)과 팔방위(八方位) 이론을 깊이 연구했으며, 수천 건의 이사 상담 경험이 있습니다.

# 전문 분야
- 풍수지리학: 양택풍수(陽宅風水), 음택풍수(陰宅風水), 지리오결(地理五訣)
- 택일학(擇日學): 이사길일 선정, 오행배합(五行配合), 십이신살(十二神殺)
- 방위학: 팔방위(八方位), 동사택/서사택(東四宅/西四宅), 구궁비성(九宮飛星)
- 양택풍수(陽宅風水): 배산임수(背山臨水), 사신사(四神砂) - 좌청룡/우백호/전주작/후현무
- 지형학: 명당(明堂) 판별, 생기/살기 흐름, 수구(水口) 분석
- 공간배치: 현관, 부엌, 침실 위치와 기운 흐름

# 분석 철학
1. **과학적 풍수**: 미신이 아닌 환경학적 관점에서 해석
2. **균형성**: 긍정적이되 현실적인 조언
3. **실용성**: 즉시 적용 가능한 구체적 방법
4. **맞춤형**: 이사 목적과 시기에 맞는 개인화된 분석
5. **지형 중시**: 배산임수, 사신사 등 실제 지형 특성을 반영한 풍수 분석
6. **자연 조화**: 자연 환경과의 조화를 강조

# 출력 형식 (반드시 JSON 형식으로)
{
  "title": "희망적인 제목 (예: '서쪽으로의 이사, 재물운이 열립니다')",
  "score": 70-95 사이 정수 (이사운 종합 점수),
  "overall_fortune": "전반적인 이사운 분석 (100자 이내, 핵심만 간결하게)",
  "direction_analysis": {
    "direction": "방위 (동/서/남/북/동북/동남/서북/서남 중 택1)",
    "direction_meaning": "해당 방위의 풍수적 의미 (100자 이상)",
    "element": "해당 방위의 오행 (목/화/토/금/수)",
    "element_effect": "오행이 미치는 영향 (100자 이상)",
    "compatibility": "이사 방위 궁합 점수 (0-100)",
    "compatibility_reason": "궁합 판단 이유 (100자 이상)"
  },
  "timing_analysis": {
    "season_luck": "해당 계절의 이사운 (봄/여름/가을/겨울)",
    "season_meaning": "계절별 의미와 오행 관계 (100자 이상)",
    "month_luck": "해당 월의 이사운 점수 (0-100)",
    "recommendation": "시기 적절성 평가 및 조언 (100자 이상)"
  },
  "lucky_dates": {
    "recommended_dates": ["이사하기 좋은 날짜 3개 (예: '음력 X월 X일', '양력 X월 X일 토요일')"],
    "avoid_dates": ["피해야 할 날짜 또는 일진 2개"],
    "best_time": "하루 중 이사하기 좋은 시간대 (구체적 시간)",
    "reason": "날짜 선정 이유 (100자 이상)"
  },
  "feng_shui_tips": {
    "entrance": "현관 관련 풍수 조언 (50자 이상)",
    "living_room": "거실 관련 풍수 조언 (50자 이상)",
    "bedroom": "침실 관련 풍수 조언 (50자 이상)",
    "kitchen": "부엌 관련 풍수 조언 (50자 이상)"
  },
  "cautions": {
    "moving_day": ["이사 당일 주의사항 3가지 (구체적)"],
    "first_week": ["입주 첫 주 주의사항 3가지"],
    "things_to_avoid": ["절대 하지 말아야 할 것 2가지"]
  },
  "recommendations": {
    "before_moving": ["이사 전 준비사항 3가지"],
    "moving_day_ritual": ["이사 당일 행운 의식 3가지 (예: 쌀과 소금 먼저 들이기)"],
    "after_moving": ["입주 후 실천사항 3가지"]
  },
  "lucky_items": {
    "items": ["이사 시 행운을 부르는 물건 3가지"],
    "colors": ["새 집에 어울리는 행운의 색상 2가지"],
    "plants": ["집안에 두면 좋은 식물 2가지"]
  },
  "terrain_analysis": {
    "terrain_type": "지형 유형 (배산임수/평지/고지/저지/해안가 등)",
    "feng_shui_quality": 0-100 사이 정수 (지형 풍수 점수),
    "quality_description": "해당 지형의 풍수적 장단점 (100자 이상)",
    "four_guardians": {
      "left_azure_dragon": "좌청룡(동쪽) 분석 - 해당 방향의 지형/건물/산 평가 (50자 이상)",
      "right_white_tiger": "우백호(서쪽) 분석 - 해당 방향의 지형/건물/산 평가 (50자 이상)",
      "front_red_phoenix": "전주작(남쪽) 분석 - 앞쪽 시야와 명당 평가 (50자 이상)",
      "back_black_turtle": "후현무(북쪽) 분석 - 뒤쪽 산/건물의 지지력 평가 (50자 이상)"
    },
    "water_energy": "수기(물의 흐름) 분석 - 하천, 강, 바다 등 (80자 이상)",
    "mountain_energy": "산기(산의 기운) 분석 - 산, 언덕, 고층건물 등 (80자 이상)",
    "energy_flow": "생기/살기 흐름 평가 - 기운의 순환과 정체 여부 (80자 이상)",
    "recommendations": ["지형 보완 방법 3가지 (구체적인 풍수 비보 방법)"]
  },
  "summary": {
    "one_line": "이사운을 한 문장으로 요약",
    "keywords": ["핵심 키워드 3개"],
    "final_message": "따뜻한 마무리 메시지 (100자 이상)"
  }
}

# 분량 요구사항 (카드 UI 스크롤 방지)
- 각 항목: 반드시 100자 이내
- overall_fortune: 100자 이내 (핵심만)
- 각 주요 섹션: 80자 이내
- 간결하고 핵심적인 내용만 작성

# 주의사항
- 현재 지역과 이사 지역을 기반으로 실제 방위 분석
- 이사 시기와 목적에 맞는 맞춤형 조언
- 모호한 점술 표현 금지 (구체적 날짜, 시간, 방법 제시)
- 반드시 유효한 JSON 형식으로 출력`

      // ✅ 목적별 조언 세그먼트
      const purposeAdviceMap: Record<string, string> = {
        '직장': '출퇴근 편의성, 직장운 상승, 승진/연봉 관련 조언을 중점으로',
        '학교': '학업운, 집중력 향상, 좋은 학업 환경 조성 관련 조언을 중점으로',
        '결혼': '부부운, 가정 화목, 신혼생활 행운 관련 조언을 중점으로',
        '가족': '가족 건강, 화목, 자녀 교육환경 관련 조언을 중점으로',
        '환경': '주거환경 개선, 생활의 질 향상 관련 조언을 중점으로',
        '투자': '재물운, 부동산 투자 운세, 자산 증식 관련 조언을 중점으로',
        '새로운 시작': '새출발의 행운, 긍정적 변화 관련 조언을 중점으로',
      }
      const purposeAdvice = purposeAdviceMap[purposeCategory] || purposeAdviceMap['새로운 시작']

      // ✅ 걱정사항별 해소 조언
      const concernsText = concerns.length > 0
        ? `\n\n## 걱정 사항 (특별히 해소해줄 것)\n${concerns.map(c => `- ${c}`).join('\n')}`
        : ''

      const userPrompt = `# 이사 상담 요청 정보

## 이사 정보
- 현재 거주지: ${current_area}
- 이사 예정지: ${target_area}
- 이사 방향: ${direction || '(지역 기반으로 추론 필요)'}
- 이사 예정 시기: ${moving_period || '미정'}
- 이사 목적: ${purposeCategory || '새로운 시작'}
${concernsText}

## 분석 요청
위 정보를 바탕으로 전문적이고 상세한 이사운 분석을 JSON 형식으로 제공해주세요.

### 중점 분석 요청
1. **방위 분석**: ${current_area}에서 ${target_area}으로의 이동은 ${direction ? `**${direction}쪽** 방향입니다. 이 방위` : '방위를 추론하여 해당 방향'}의 풍수적 의미와 길흉을 상세히 분석해주세요.
2. **시기 적절성**: ${moving_period || '향후'} 시기의 이사 적합성을 분석해주세요.
3. **목적 맞춤 조언**: ${purposeAdvice} 해주세요.${concerns.length > 0 ? `\n4. **걱정 해소**: 위 걱정 사항들에 대한 구체적인 풍수적 해결책과 안심 조언을 포함해주세요.` : ''}`

      // ✅ LLM 호출 (Provider 무관)
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
        fortuneType: 'moving',
        provider: response.provider,
        model: response.model,
        response: response,
        metadata: {
          current_area,
          target_area,
          moving_period,
          purpose,
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

      // ✅ Blur 로직 적용 (프리미엄이 아니면 상세 분석 블러 처리)
      const isBlurred = !isPremium
      const blurredSections = isBlurred
        ? ['direction_analysis', 'timing_analysis', 'lucky_dates', 'feng_shui_tips', 'cautions', 'recommendations', 'lucky_items', 'terrain_analysis']
        : []

      // ✅ 응답 데이터 구조화 (항상 실제 데이터 반환, 클라이언트에서 블러 처리)
      fortuneData = {
        // ✅ 표준화된 필드명: score, content, summary, advice
        fortuneType: 'moving',
        score: parsedResponse.score || Math.floor(Math.random() * 25) + 70,
        content: parsedResponse.overall_fortune || '새로운 터전에서 좋은 기운이 함께 합니다.',
        summary: `${current_area} → ${target_area} 이사운 ${parsedResponse.score || 75}점`,
        advice: parsedResponse.summary?.final_message || '새로운 터전에서 행복한 나날 되세요.',

        // 기존 필드 유지 (하위 호환성)
        title: parsedResponse.title || `${current_area} → ${target_area} 이사운`,
        fortune_type: 'moving',
        current_area,
        target_area,
        moving_period,
        purpose,
        direction, // ✅ 앱에서 계산한 방향 포함
        purposeCategory,
        concerns,
        // 공개 섹션
        moving_score: parsedResponse.score || Math.floor(Math.random() * 25) + 70,
        overall_fortune: parsedResponse.overall_fortune || '새로운 터전에서 좋은 기운이 함께 합니다.',

        // 방위 분석
        direction_analysis: parsedResponse.direction_analysis || {
          direction: '동',
          direction_meaning: '방위 분석 중입니다.',
          element: '목',
          element_effect: '오행 분석 중입니다.',
          compatibility: 75,
          compatibility_reason: '궁합 분석 중입니다.'
        },

        // 시기 분석
        timing_analysis: parsedResponse.timing_analysis || {
          season_luck: '봄',
          season_meaning: '계절 분석 중입니다.',
          month_luck: 75,
          recommendation: '시기 분석 중입니다.'
        },

        // 길일 추천
        lucky_dates: parsedResponse.lucky_dates || {
          recommended_dates: ['날짜 분석 중'],
          avoid_dates: ['분석 중'],
          best_time: '오전',
          reason: '길일 분석 중입니다.'
        },

        // 풍수 조언
        feng_shui_tips: parsedResponse.feng_shui_tips || {
          entrance: '현관 분석 중입니다.',
          living_room: '거실 분석 중입니다.',
          bedroom: '침실 분석 중입니다.',
          kitchen: '부엌 분석 중입니다.'
        },

        // 주의사항
        cautions: parsedResponse.cautions || {
          moving_day: ['주의사항 분석 중'],
          first_week: ['분석 중'],
          things_to_avoid: ['분석 중']
        },

        // 추천사항
        recommendations: parsedResponse.recommendations || {
          before_moving: ['준비사항 분석 중'],
          moving_day_ritual: ['분석 중'],
          after_moving: ['분석 중']
        },

        // 행운 아이템
        lucky_items: parsedResponse.lucky_items || {
          items: ['분석 중'],
          colors: ['분석 중'],
          plants: ['분석 중']
        },

        // 지형 분석 (배산임수, 사신사)
        terrain_analysis: parsedResponse.terrain_analysis || {
          terrain_type: '분석 중',
          feng_shui_quality: 75,
          quality_description: '지형 분석 중입니다.',
          four_guardians: {
            left_azure_dragon: '좌청룡 분석 중',
            right_white_tiger: '우백호 분석 중',
            front_red_phoenix: '전주작 분석 중',
            back_black_turtle: '후현무 분석 중'
          },
          water_energy: '수기 분석 중',
          mountain_energy: '산기 분석 중',
          energy_flow: '기의 흐름 분석 중',
          recommendations: ['분석 중']
        },

        // 요약
        summary: {
          one_line: parsedResponse.summary?.one_line || '좋은 이사가 될 것입니다.',
          keywords: parsedResponse.summary?.keywords || ['행운', '새출발', '번영'],
          final_message: parsedResponse.summary?.final_message || '새로운 터전에서 행복한 나날 되세요.'
        },

        timestamp: new Date().toISOString(),
        isBlurred, // ✅ 블러 상태
        blurredSections, // ✅ 블러된 섹션 목록
        // 메타데이터 추가
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
          fortune_type: 'moving',
          expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(), // 24시간 캐시
        })
    }

    // ✅ 퍼센타일 계산
    const percentileData = await calculatePercentile(supabase, 'moving', fortuneData.score)
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
    console.error('❌ Error in fortune-moving function:', error)

    return new Response(
      JSON.stringify({
        success: false,
        error: error.message || '분석 중 오류가 발생했습니다.',
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
