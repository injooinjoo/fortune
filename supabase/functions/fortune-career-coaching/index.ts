import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { crypto } from 'https://deno.land/std@0.168.0/crypto/mod.ts'
import { LLMFactory } from '../_shared/llm/factory.ts'

// 환경 변수 설정
const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY')!

// Supabase 클라이언트 생성
const supabase = createClient(supabaseUrl, supabaseKey)

// UTF-8 안전한 해시 생성 함수
async function createHash(text: string): Promise<string> {
  const encoder = new TextEncoder()
  const data = encoder.encode(text)
  const hashBuffer = await crypto.subtle.digest('SHA-256', data)
  const hashArray = Array.from(new Uint8Array(hashBuffer))
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('').slice(0, 50)
}

// 요청 인터페이스
interface CareerCoachingRequest {
  currentRole?: string
  experienceLevel?: string
  industry?: string
  primaryConcern?: string
  shortTermGoal?: string
  skillsToImprove?: string[]
  coreValue?: string
  isPremium?: boolean // ✅ 프리미엄 사용자 여부
}

// 응답 인터페이스
interface CareerCoachingResponse {
  success: boolean
  fortune: {
    health_score: {
      overall_score: number
      growth_score: number
      satisfaction_score: number
      market_score: number
      balance_score: number
      level: string
    }
    key_insights: Array<{
      icon: string
      title: string
      description: string
      impact: string
      category: string
    }>
    thirty_day_plan: {
      focus_area: string
      expected_outcome: string
      weeks: Array<{
        week_number: number
        theme: string
        tasks: string[]
        milestone: string
      }>
    }
    growth_roadmap: {
      current_stage: string
      next_stage: string
      estimated_months: number
      key_milestones: string[]
    }
    recommendations: {
      skills: Array<{
        name: string
        priority: string
        reason: string
      }>
    }
    market_trends: {
      industry_outlook: string
      demand_level: string
      salary_trend: string
    }
    isBlurred?: boolean // ✅ 블러 상태
    blurredSections?: string[] // ✅ 블러된 섹션
  }
  error?: string
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
    const requestData: CareerCoachingRequest = await req.json()
    const {
      currentRole = 'junior',
      experienceLevel = 'mid',
      industry = '',
      primaryConcern = 'growth',
      shortTermGoal = 'skillup',
      skillsToImprove = [],
      coreValue = 'growth',
      isPremium = false // ✅ 프리미엄 사용자 여부
    } = requestData

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
    console.log('🔮 [커리어 코칭] 운세 생성 요청')
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
    console.log('현재 직무:', currentRole)
    console.log('경력 수준:', experienceLevel)
    console.log('주요 고민:', primaryConcern)
    console.log('단기 목표:', shortTermGoal)
    console.log('개선 스킬:', skillsToImprove.join(', '))
    console.log('isPremium:', isPremium)

    // 캐시 확인
    const hash = await createHash(`career_coaching_${currentRole}_${experienceLevel}_${primaryConcern}_${shortTermGoal}_${skillsToImprove.join(',')}`)
    const cacheKey = `career_coaching_${hash}`
    const { data: cachedResult } = await supabase
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .single()

    let fortuneData: any

    if (cachedResult?.result) {
      console.log('✅ 캐시에서 커리어 코칭 결과 로드')
      fortuneData = cachedResult.result

      // ✅ 캐시된 데이터도 프리미엄 상태에 따라 블러 적용
      const isBlurred = !isPremium
      if (isBlurred) {
        fortuneData.isBlurred = true
        fortuneData.blurredSections = ['key_insights', 'action_plan', 'growth_roadmap', 'recommendations']
      } else {
        fortuneData.isBlurred = false
        fortuneData.blurredSections = []
      }
    } else {
      console.log('❌ 캐시 미스 - LLM API 호출')

      // LLM 프롬프트 생성
      const prompt = `당신은 한국의 전문 커리어 컨설턴트입니다. 다음 정보를 바탕으로 실용적인 커리어 코칭을 제공해주세요.

**현재 상황**
- 현재 직급: ${currentRole}
- 경력 수준: ${experienceLevel}
- 산업 분야: ${industry || '미지정'}
- 주요 고민: ${primaryConcern}
- 단기 목표: ${shortTermGoal}
- 개선 희망 스킬: ${skillsToImprove.join(', ')}
- 핵심 가치: ${coreValue}

**필수 응답 형식 (JSON)**
{
  "health_score": {
    "overall_score": 70,  // 0-100 점수
    "growth_score": 75,
    "satisfaction_score": 70,
    "market_score": 65,
    "balance_score": 60,
    "level": "good"  // excellent/good/moderate/needs-attention
  },
  "key_insights": [
    {
      "icon": "📈",
      "title": "성장 기회 발견",
      "description": "구체적인 인사이트 내용...",
      "impact": "high",  // high/medium/low
      "category": "opportunity"  // opportunity/warning/trend/advice
    }
    // 3-4개 인사이트
  ],
  "thirty_day_plan": {
    "focus_area": "스킬 개발과 전문성 강화",
    "expected_outcome": "새로운 성장 기회 발견",
    "weeks": [
      {
        "week_number": 1,
        "theme": "학습 계획 수립",
        "tasks": ["태스크1", "태스크2", "태스크3"],
        "milestone": "구체적인 마일스톤"
      }
      // 4주치 계획
    ]
  },
  "growth_roadmap": {
    "current_stage": "미드레벨 전문가",
    "next_stage": "시니어 리더",
    "estimated_months": 18,
    "key_milestones": ["마일스톤1", "마일스톤2", "마일스톤3"]
  },
  "recommendations": {
    "skills": [
      {
        "name": "리더십 & 팀 관리",
        "priority": "high",  // critical/high/medium/low
        "reason": "다음 커리어 단계에 필수적"
      }
      // 3-5개 스킬 추천
    ]
  },
  "market_trends": {
    "industry_outlook": "positive",  // positive/stable/challenging
    "demand_level": "high",  // high/moderate/low
    "salary_trend": "연 5-10% 상승 추세"
  }
}

**중요 가이드라인:**
1. 현실적이고 실행 가능한 조언 제공
2. 구체적인 액션 아이템 포함
3. 긍정적이면서도 솔직한 피드백
4. 한국 직장 문화를 고려한 조언
5. 반드시 JSON 형식으로만 응답

응답은 반드시 위 JSON 형식을 따라주세요.`

      // ✅ LLM 모듈 사용
      const llm = LLMFactory.createFromConfig('career-coaching')

      const response = await llm.generate([
        {
          role: 'system',
          content: '당신은 한국의 전문 커리어 컨설턴트이며, 10년 이상의 경험을 가진 커리어 코칭 전문가입니다. 항상 한국어로 응답하며, 실용적이고 실현 가능한 조언을 제공합니다. 반드시 JSON 형식으로만 응답합니다.'
        },
        {
          role: 'user',
          content: prompt
        }
      ], {
        temperature: 1,
        maxTokens: 8192,
        jsonMode: true
      })

      console.log(`✅ LLM 호출 완료:`)
      console.log(`  Provider: ${response.provider}`)
      console.log(`  Model: ${response.model}`)
      console.log(`  Latency: ${response.latency}ms`)
      console.log(`  Tokens: ${response.usage.totalTokens}`)

      // JSON 파싱
      let parsedResponse: any
      try {
        parsedResponse = JSON.parse(response.content)
      } catch (error) {
        console.error('❌ JSON 파싱 실패:', error)
        throw new Error('API 응답 형식이 올바르지 않습니다.')
      }

      // ✅ 블러 로직 적용
      const isBlurred = !isPremium
      const blurredSections = isBlurred
        ? ['key_insights', 'action_plan', 'growth_roadmap', 'recommendations']
        : []

      // 응답 데이터 구조화
      fortuneData = {
        health_score: parsedResponse.health_score || {
          overall_score: 70,
          growth_score: 75,
          satisfaction_score: 70,
          market_score: 65,
          balance_score: 60,
          level: 'good'
        },
        key_insights: parsedResponse.key_insights || [],
        thirty_day_plan: parsedResponse.thirty_day_plan || {
          focus_area: '커리어 성장',
          expected_outcome: '목표 달성',
          weeks: []
        },
        growth_roadmap: parsedResponse.growth_roadmap || {
          current_stage: '현재 단계',
          next_stage: '다음 단계',
          estimated_months: 12,
          key_milestones: []
        },
        recommendations: parsedResponse.recommendations || { skills: [] },
        market_trends: parsedResponse.market_trends || {
          industry_outlook: 'stable',
          demand_level: 'moderate',
          salary_trend: '안정적'
        },
        isBlurred, // ✅ 블러 상태
        blurredSections // ✅ 블러된 섹션 목록
      }

      // 결과 캐싱 (프리미엄 상태 무관하게 원본 저장)
      await supabase
        .from('fortune_cache')
        .insert({
          cache_key: cacheKey,
          result: fortuneData,
          fortune_type: 'career-coaching',
          expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(), // 24시간 캐시
        })

      console.log('✅ 캐시에 저장 완료')
    }

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
    console.log('✅ [커리어 코칭] 운세 생성 완료')
    if (fortuneData.isBlurred) {
      console.log('   → 블러된 섹션:', fortuneData.blurredSections.join(', '))
    } else {
      console.log('   → 프리미엄 사용자: 전체 공개')
    }
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')

    // 성공 응답
    const apiResponse: CareerCoachingResponse = {
      success: true,
      fortune: fortuneData
    }

    return new Response(JSON.stringify(apiResponse), {
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
      },
    })

  } catch (error) {
    console.error('❌ 커리어 코칭 에러:', error)

    const errorResponse: CareerCoachingResponse = {
      success: false,
      fortune: {} as any,
      error: error instanceof Error ? error.message : '커리어 코칭 생성 중 오류가 발생했습니다.'
    }

    return new Response(JSON.stringify(errorResponse), {
      status: 500,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
      },
    })
  }
})
