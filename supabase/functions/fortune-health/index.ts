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

interface HealthAppData {
  average_daily_steps?: number | null
  today_steps?: number | null
  average_daily_calories?: number | null
  today_calories?: number | null
  average_daily_distance_km?: string | null
  workout_count_week?: number | null
  average_sleep_hours?: string | null
  last_night_sleep_hours?: string | null
  average_heart_rate?: number | null
  resting_heart_rate?: number | null
  weight_kg?: string | null
  systolic_bp?: number | null
  diastolic_bp?: number | null
  blood_glucose?: string | null
  blood_oxygen?: string | null
  data_period?: string | null
}

interface HealthFortuneRequest {
  fortune_type?: string
  current_condition: string
  concerned_body_parts: string[]
  isPremium?: boolean // ✅ 프리미엄 사용자 여부
  health_app_data?: HealthAppData | null // ✅ 프리미엄 건강앱 데이터
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
    const requestData: HealthFortuneRequest = await req.json()
    const {
      current_condition = '',
      concerned_body_parts = [],
      isPremium = false, // ✅ 프리미엄 사용자 여부
      health_app_data = null // ✅ 건강앱 데이터 (프리미엄 전용)
    } = requestData

    if (!current_condition) {
      throw new Error('현재 건강 상태를 입력해주세요.')
    }

    const hasHealthAppData = isPremium && health_app_data !== null
    console.log('💎 [Health] Premium 상태:', isPremium)
    console.log('📱 [Health] 건강앱 데이터:', hasHealthAppData ? '있음' : '없음')
    console.log('Health fortune request:', { current_condition, concerned_body_parts })

    // 건강앱 데이터가 있으면 캐시 키에 포함 (개인화된 결과)
    const healthDataHash = hasHealthAppData ? `_healthapp_${JSON.stringify(health_app_data).slice(0, 50)}` : ''
    const hash = await createHash(`${current_condition}_${concerned_body_parts.join(',')}${healthDataHash}`)
    const cacheKey = `health_fortune_${hash}`
    const { data: cachedResult } = await supabase
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .single()

    let fortuneData: any

    if (cachedResult?.result) {
      console.log('Cache hit for health fortune')
      fortuneData = cachedResult.result
    } else {
      console.log('Cache miss, calling LLM API')

      // ✅ LLM 모듈 사용 (동적 DB 설정 - A/B 테스트 지원)
      const llm = await LLMFactory.createFromConfigAsync('health')

      const systemPrompt = `당신은 **현대의학 + 한의학 통합 건강코치**입니다.
삼성서울병원 가정의학과 15년, 한방내과 10년 경력을 보유하고 있습니다.

🎯 **핵심 원칙**:
1. **구체적 수치와 시간 제시**: "운동하세요" ❌ → "오후 3시, 15분간 걷기" ✅
2. **이유 설명 필수**: 모든 조언에 "왜"를 포함
3. **실천 가능한 액션**: 바로 따라할 수 있는 구체적 방법
4. **경고와 격려 균형**: 무서운 경고만 ❌, 희망적 조언과 함께

⚠️ **절대 금지**: "건강하십니다", "좋습니다", "주의하세요" 같은 막연한 표현`

      // 건강앱 데이터 섹션 생성
      const healthAppSection = hasHealthAppData ? `
## 📱 건강앱 연동 데이터 (실측치)
${health_app_data!.average_daily_steps ? `- **일평균 걸음 수**: ${health_app_data!.average_daily_steps.toLocaleString()}보` : ''}
${health_app_data!.today_steps ? `- **오늘 걸음 수**: ${health_app_data!.today_steps.toLocaleString()}보` : ''}
${health_app_data!.average_sleep_hours ? `- **일평균 수면**: ${health_app_data!.average_sleep_hours}시간` : ''}
${health_app_data!.last_night_sleep_hours ? `- **어젯밤 수면**: ${health_app_data!.last_night_sleep_hours}시간` : ''}
${health_app_data!.average_heart_rate ? `- **평균 심박수**: ${health_app_data!.average_heart_rate}bpm` : ''}
${health_app_data!.resting_heart_rate ? `- **안정시 심박수**: ${health_app_data!.resting_heart_rate}bpm` : ''}
${health_app_data!.weight_kg ? `- **체중**: ${health_app_data!.weight_kg}kg` : ''}
${health_app_data!.systolic_bp && health_app_data!.diastolic_bp ? `- **혈압**: ${health_app_data!.systolic_bp}/${health_app_data!.diastolic_bp}mmHg` : ''}
${health_app_data!.blood_glucose ? `- **혈당**: ${health_app_data!.blood_glucose}mg/dL` : ''}
${health_app_data!.blood_oxygen ? `- **산소포화도**: ${health_app_data!.blood_oxygen}%` : ''}
${health_app_data!.workout_count_week ? `- **주간 운동 횟수**: ${health_app_data!.workout_count_week}회` : ''}
${health_app_data!.average_daily_calories ? `- **일평균 소모 칼로리**: ${health_app_data!.average_daily_calories}kcal` : ''}
${health_app_data!.data_period ? `- **데이터 기간**: ${health_app_data!.data_period}` : ''}

⚠️ **중요**: 위 실측 데이터를 반드시 분석에 반영하세요. 일반적인 조언이 아닌, 이 사용자의 실제 건강 지표에 맞춤화된 조언을 제공해야 합니다.
` : ''

      const userPrompt = `## 사용자 건강 프로필
- **현재 컨디션**: ${current_condition}
- **관심 부위**: ${concerned_body_parts.length > 0 ? concerned_body_parts.join(', ') : '전신 컨디션'}
- **분석 날짜**: ${new Date().toLocaleDateString('ko-KR', { month: 'long', day: 'numeric', weekday: 'long' })}
${healthAppSection}

---

## 요청 JSON 형식

\`\`\`json
{
  "overall_health": "구체적인 전반 건강 분석 (5-7문장)",
  "body_part_advice": "부위별 맞춤 조언 (각 부위 3-4문장)",
  "cautions": ["주의사항1 (이유 포함)", "주의사항2", "주의사항3"],
  "recommended_activities": ["활동1 (시간+방법)", "활동2", "활동3"],
  "diet_advice": "식습관 조언 (좋은 음식 + 피할 음식 + 시간대별 팁, 5-6문장)",
  "exercise_advice": "운동 조언 (종류 + 강도 + 횟수 + 주의점, 5-6문장)",
  "health_keyword": "오늘의 건강 키워드 2-3단어"
}
\`\`\`

---

## 각 필드 작성 기준

### 1. overall_health (전반적인 건강운)
**예시**: "현재 ${current_condition} 상태로, 교감신경이 다소 항진되어 있는 패턴입니다. 특히 오후 2-4시 사이에 집중력 저하와 가벼운 피로감이 나타날 수 있습니다. 이는 코르티솔 분비 리듬과 관련이 있어, 이 시간대에 5분간 눈을 감고 호흡에 집중하면 효과적입니다. 면역력은 양호한 편이나, 수면의 질을 개선하면 20% 이상 에너지 레벨이 상승할 수 있습니다."

### 2. body_part_advice (부위별 건강 조언)
- **머리**: "두통이 잦다면 후두부 '풍지혈'을 3초간 5회 지압하세요"
- **어깨**: "승모근 뭉침은 매시간 어깨 돌리기 10회로 예방됩니다"
- **허리**: "요추 4-5번 디스크 부담 완화를 위해 고양이 자세 30초×3세트 권장"
- 구체적 **지압점, 스트레칭, 횟수, 시간**을 포함

### 3. cautions (주의사항) - 배열 3개
❌ "야식을 피하세요"
✅ "밤 9시 이후 탄수화물 섭취 자제 (인슐린 스파이크로 수면호르몬 멜라토닌 분비 방해)"

### 4. recommended_activities (추천 활동) - 배열 3-5개
❌ "산책"
✅ "오전 7-8시 공복 걷기 20분 (지방 연소 효율 40% 증가, 세로토닌 분비 촉진)"

### 5. diet_advice (식습관 조언)
**좋은 음식 + 이유**: "연어(오메가3로 염증 감소), 브로콜리(설포라판으로 해독 강화)"
**피할 음식 + 이유**: "밀가루(장 투과성 증가), 가공육(아질산나트륨으로 산화 스트레스)"
**시간대별 팁**: "아침 공복에 레몬물, 점심 후 15분 걷기, 저녁 7시 이전 식사 마무리"

### 6. exercise_advice (운동 조언)
**종류**: "유산소(걷기/자전거) + 근력(플랭크/스쿼트)"
**강도**: "심박수 110-130bpm 유지 (말하면서 할 수 있는 정도)"
**횟수**: "주 3-4회, 회당 30-45분"
**주의점**: "무릎 통증 시 런지 대신 벽 스쿼트로 대체"

### 7. health_keyword
2-3단어의 긍정적이고 기억하기 쉬운 표현
예: "균형 회복", "활력 충전", "면역 강화"

---

## 중요 지침
- 모든 조언에 **구체적 숫자/시간/횟수** 포함
- **"왜"**를 반드시 설명 (의학적 근거 간단히)
- 막연한 표현 사용 금지: "좋습니다", "주의하세요", "건강합니다"
- JSON만 반환 (마크다운 코드블록 없이)`

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
        fortuneType: 'health',
        provider: response.provider,
        model: response.model,
        response: response,
        metadata: {
          current_condition,
          concerned_body_parts,
          isPremium,
          hasHealthAppData
        }
      })

      if (!response.content) throw new Error('LLM API 응답을 받을 수 없습니다.')

      const parsedResponse = JSON.parse(response.content)

      // ✅ 항상 전체 데이터 반환 (Flutter에서 블러 처리)
      const isBlurred = !isPremium
      const blurredSections = isBlurred
        ? ['body_part_advice', 'cautions', 'recommended_activities', 'diet_advice', 'exercise_advice', 'health_keyword']
        : []

      fortuneData = {
        title: '건강운',
        fortune_type: 'health',
        current_condition,
        concerned_body_parts,
        score: Math.floor(Math.random() * 30) + 70, // 공개
        overall_health: parsedResponse.전반적인건강운 || parsedResponse.overall_health || '건강하십니다.', // 공개
        body_part_advice: parsedResponse.부위별건강 || parsedResponse.body_part_advice || '주의가 필요합니다.', // 블러 대상
        cautions: parsedResponse.주의사항 || parsedResponse.cautions || ['규칙적 생활', '충분한 휴식', '정기 검진'], // 블러 대상
        recommended_activities: parsedResponse.추천활동 || parsedResponse.recommended_activities || ['산책', '요가', '스트레칭'], // 블러 대상
        diet_advice: parsedResponse.식습관조언 || parsedResponse.diet_advice || '균형잡힌 식사를 하세요.', // 블러 대상
        exercise_advice: parsedResponse.운동조언 || parsedResponse.exercise_advice || '꾸준한 운동이 중요합니다.', // 블러 대상
        health_keyword: parsedResponse.건강키워드 || parsedResponse.health_keyword || '건강', // 블러 대상
        timestamp: new Date().toISOString(),
        isBlurred, // ✅ 블러 상태
        blurredSections, // ✅ 블러된 섹션 목록
        hasHealthAppData, // ✅ 건강앱 데이터 사용 여부
        healthAppDataSummary: hasHealthAppData ? {
          steps: health_app_data!.today_steps,
          sleep: health_app_data!.average_sleep_hours,
          heartRate: health_app_data!.average_heart_rate,
          weight: health_app_data!.weight_kg
        } : null
      }

      await supabase.from('fortune_cache').insert({
        cache_key: cacheKey,
        result: fortuneData,
        fortune_type: 'health',
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
      })
    }

    // ✅ 퍼센타일 계산
    const percentileData = await calculatePercentile(supabase, 'health', fortuneData.score)
    const fortuneDataWithPercentile = addPercentileToResult(fortuneData, percentileData)

    return new Response(JSON.stringify({ success: true, data: fortuneDataWithPercentile }), {
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
      },
    })

  } catch (error) {
    console.error('Health Fortune Error:', error)
    return new Response(JSON.stringify({
      success: false,
      data: {},
      error: error instanceof Error ? error.message : '건강운 생성 중 오류가 발생했습니다.'
    }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
      },
    })
  }
})
