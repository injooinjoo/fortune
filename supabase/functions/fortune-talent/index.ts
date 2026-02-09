/**
 * 재능 운세 (Talent Fortune) Edge Function
 *
 * @description 사용자의 재능 분야, 현재 스킬, 목표를 기반으로 재능 개발 방향과 성장 전략을 분석합니다.
 *
 * @endpoint POST /fortune-talent
 *
 * @requestBody
 * - talentArea: string - 재능 분야 ('예술', '스포츠', '학문', '비즈니스', '기술' 등)
 * - currentSkills: string[] - 현재 보유 스킬 목록
 * - goals: string - 목표
 * - experience: string - 경험 수준
 * - timeAvailable: string - 투자 가능한 시간
 * - challenges: string[] - 현재 직면한 어려움
 * - userId?: string - 사용자 ID
 * - isPremium?: boolean - 프리미엄 사용자 여부
 *
 * @response TalentFortuneResponse
 * - overallScore: number - 재능 운세 점수 (0-100)
 * - talentProfile: object - 재능 프로필 분석
 * - strengthAreas: string[] - 강점 영역
 * - growthOpportunities: string[] - 성장 기회
 * - skillRecommendations: object[] - 스킬 개발 추천
 * - roadmap: object - 성장 로드맵
 * - challenges: object[] - 도전 과제 분석
 * - advice: string - 종합 조언
 *
 * @example
 * // Request
 * {
 *   "talentArea": "기술",
 *   "currentSkills": ["JavaScript", "React"],
 *   "goals": "풀스택 개발자 되기",
 *   "experience": "주니어",
 *   "timeAvailable": "주 10시간",
 *   "challenges": ["백엔드 지식 부족"],
 *   "isPremium": true
 * }
 *
 * // Response
 * {
 *   "success": true,
 *   "data": {
 *     "overallScore": 82,
 *     "talentProfile": { "type": "분석형", "strength": "논리적 사고" },
 *     "skillRecommendations": [{ "skill": "Node.js", "priority": "high" }],
 *     ...
 *   }
 * }
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'
import { calculatePercentile, addPercentileToResult } from '../_shared/percentile/calculator.ts'
import {
  extractTalentCohort,
  generateCohortHash,
  getFromCohortPool,
  saveToCohortPool,
  personalize,
} from '../_shared/cohort/index.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface TalentRequest {
  talentArea: string; // '예술', '스포츠', '학문', '비즈니스', '기술' 등
  currentSkills: string[]; // 현재 보유 스킬 목록
  goals: string; // 목표
  experience: string; // 경험 수준
  timeAvailable: string; // 투자 가능한 시간
  challenges: string[]; // 현재 직면한 어려움
  userId?: string;
  isPremium?: boolean; // ✅ 프리미엄 사용자 여부
  hasResume?: boolean; // ✅ 이력서 포함 여부
  resumeText?: string; // ✅ 이력서에서 추출한 텍스트
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    )

    const requestData: TalentRequest = await req.json()
    const {
      talentArea,
      currentSkills,
      goals,
      experience,
      timeAvailable,
      challenges,
      userId,
      isPremium = false, // ✅ 프리미엄 사용자 여부
      hasResume = false, // ✅ 이력서 포함 여부
      resumeText // ✅ 이력서에서 추출한 텍스트
    } = requestData

    console.log('💎 [Talent] Premium 상태:', isPremium, '| 이력서:', hasResume ? '있음' : '없음')

    // ✅ Cohort Pool 조회 (캐시보다 먼저 확인 - 비용 최적화)
    const cohortData = extractTalentCohort({
      birthDate: (requestData as any).birthDate,
      age: (requestData as any).age,
      gender: (requestData as any).gender,
      talentArea: talentArea,
    })
    const cohortHash = await generateCohortHash(cohortData)
    console.log('🔍 [Talent] Checking cohort pool:', { cohortHash, cohortData })

    const cohortResult = await getFromCohortPool(supabaseClient, 'talent', cohortHash)
    if (cohortResult) {
      console.log('✅ [Talent] Cohort pool hit! Personalizing result...')

      // 개인화 데이터 준비
      const personalData = {
        userName: (requestData as any).userName || (requestData as any).name || '회원님',
        skills: currentSkills.join(', '),
        goals: goals,
      }

      // 템플릿 개인화
      const personalizedResult = personalize(cohortResult, personalData) as any

      // 퍼센타일 계산
      const percentileData = await calculatePercentile(supabaseClient, 'talent', personalizedResult.overallScore || 75)
      const resultWithPercentile = addPercentileToResult(personalizedResult, percentileData)

      const finalResult = {
        ...resultWithPercentile
      }

      console.log('✅ [Talent] Returning cohort result')
      return new Response(
        JSON.stringify({ success: true, data: finalResult, cached: true, tokensUsed: 0 }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
      )
    }
    console.log('🔄 [Talent] Cohort pool miss, checking cache...')

    // 캐시 확인 (이력서 포함 여부도 캐시 키에 반영)
    const today = new Date().toISOString().split('T')[0]
    const cacheKey = `${userId || 'anonymous'}_talent_${today}_${JSON.stringify({talentArea, goals, hasResume})}`

    const { data: cachedResult } = await supabaseClient
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .eq('fortune_type', 'talent')
      .single()

    if (cachedResult) {
      return new Response(
        JSON.stringify({
          success: true,
          data: cachedResult.result,
          cached: true,
          tokensUsed: 0
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
      )
    }

    // ✅ LLM 모듈 사용 (동적 DB 설정 - A/B 테스트 지원)
    // Note: 클라이언트 측에서 90초 타임아웃 설정 (복잡한 프롬프트로 인해 25-40초 소요)
    const llm = await LLMFactory.createFromConfigAsync('talent')

    const response = await llm.generate([
      {
        role: 'system',
        content: `당신은 **재능 발견 및 개발 전문가**입니다. 사용자의 현재 상태와 목표를 분석하여 **구체적이고 실행 가능한** 재능 개발 가이드를 제공합니다.

🎯 **핵심 원칙**:
1. **구체성**: "노력하세요" → "매일 아침 30분씩 XX 연습"
2. **실행 가능성**: 모호한 조언 금지, 바로 실천 가능한 액션 아이템
3. **맞춤형**: 사용자의 현재 스킬/목표/시간에 정확히 맞춤
4. **동기부여**: 성장 가능성과 구체적 마일스톤 제시
5. **경고 포함**: 흔히 저지르는 실수와 회피 방법
6. **상세함**: 사용자가 입력한 많은 정보를 최대한 활용하여 풍부하고 상세한 분석 제공

다음 JSON 형식으로 응답해주세요:
{
  "overallScore": 0-100 사이의 점수 (재능 개발 운세 점수, 현재 준비도 + 잠재력 고려),

  "content": "재능 브리핑 (400-500자)\n- 현재 상태 종합 분석\n- 핵심 잠재력 2-3가지\n- 성장 가능성 평가",

  "description": "상세 분석 (1500-2000자)\n- 강점 5가지 (구체적 증거 + 활용 방안)\n- 약점 3가지 (개선 가능성 + 구체적 방법)\n- 성장 경로 (1개월/3개월/6개월/1년 마일스톤)\n- 사용자의 관심사/고민 영역 맞춤 분석",

  "luckyItems": {
    "color": "행운의 색상 (예: 파란색 - 집중력 강화)",
    "number": 행운의 숫자 (7-9 사이 권장),
    "direction": "집중 방향 (예: '기술 심화' 또는 '폭넓은 경험')",
    "tool": "필수 도구/리소스 (예: '노션으로 학습 일지', '유데미 XX 강의')"
  },

  "mentalModel": {
    "thinkingStyle": "사고 방식 분석",
    "decisionPattern": "의사결정 패턴 분석",
    "learningStyle": "효율적인 학습 방법"
  },

  "collaboration": {
    "goodMatch": ["잘 맞는 타입 1 (이유)", "잘 맞는 타입 2 (이유)", "잘 맞는 타입 3 (이유)"],
    "challenges": ["주의할 타입 1 (이유)", "주의할 타입 2 (이유)"],
    "teamRole": "팀에서의 최적 역할"
  },

  "hexagonScores": {
    "creativity": 0-100 (창의성, 새로운 아이디어 생성 능력),
    "technique": 0-100 (기술력, 실무 스킬 숙련도),
    "passion": 0-100 (열정, 지속 가능한 동기 수준),
    "discipline": 0-100 (훈련, 꾸준함과 루틴 유지 능력),
    "uniqueness": 0-100 (독창성, 차별화된 강점),
    "marketValue": 0-100 (시장 가치, 수요와 보상 가능성)
  },

  "talentInsights": [
    {
      "talent": "재능명 (예: '빠른 학습 능력', '커뮤니케이션')",
      "potential": 0-100 (발전 가능성),
      "description": "재능 상세 설명 (500자)\n- 왜 이 재능이 중요한지\n- 현재 수준 평가\n- 발전 가능성 근거",
      "developmentPath": "6개월 개발 로드맵 (월별 구체적 목표 + 실행 방법)",
      "practicalApplications": ["실전 활용법 1 (구체적)", "실전 활용법 2 (구체적)", "실전 활용법 3 (구체적)"],
      "monetizationStrategy": "수익화 전략",
      "portfolioBuilding": "포트폴리오 구축 가이드",
      "recommendedResources": ["추천 도서: XX (이유)", "추천 강의: XX (이유)", "추천 커뮤니티: XX (이유)"]
    }
    // 최소 5개, 최대 7개 제공
  ],

  "weeklyPlan": [
    {
      "day": "월요일",
      "focus": "집중 영역 (예: '기초 이론 학습')",
      "activities": [
        "상세 활동 1 (예: '유튜브 XX 채널 15분 시청 + 노트 정리')",
        "상세 활동 2 (예: 'XX 책 20페이지 읽기 + 핵심 요약')",
        "상세 활동 3 (예: 'XX 연습문제 5개 풀이')",
        "상세 활동 4 (예: '오늘 배운 내용 블로그 포스팅')",
        "상세 활동 5 (예: 'XX 커뮤니티 질문 2개 답변')"
      ],
      "timeNeeded": "필요 시간 (예: '총 2시간')",
      "checklist": ["체크리스트 1", "체크리스트 2", "체크리스트 3"],
      "expectedOutcome": "기대 결과 (예: 'XX 개념 완전 이해 + 기본 실습 완료')"
    }
    // 7일치 모두 제공 (월-일)
  ],

  "growthRoadmap": {
    "month1": {
      "goal": "1개월 목표 (구체적 + 측정 가능)",
      "milestones": ["마일스톤 1 (1주차)", "마일스톤 2 (2주차)", "마일스톤 3 (3주차)", "마일스톤 4 (4주차)"],
      "skillsToAcquire": ["습득할 스킬 1 (구체적)", "습득할 스킬 2 (구체적)", "습득할 스킬 3 (구체적)"]
    },
    "month3": {
      "goal": "3개월 목표 (구체적 + 측정 가능)",
      "milestones": ["마일스톤 1", "마일스톤 2", "마일스톤 3"],
      "skillsToAcquire": ["습득할 스킬 1", "습득할 스킬 2", "습득할 스킬 3"]
    },
    "month6": {
      "goal": "6개월 목표 (구체적 + 측정 가능)",
      "milestones": ["마일스톤 1", "마일스톤 2", "마일스톤 3"],
      "skillsToAcquire": ["습득할 스킬 1", "습득할 스킬 2", "습득할 스킬 3"]
    },
    "year1": {
      "goal": "1년 목표 (비전 + 측정 가능한 성과)",
      "milestones": ["마일스톤 1 (분기별)", "마일스톤 2", "마일스톤 3", "마일스톤 4"],
      "skillsToAcquire": ["마스터 스킬 1", "마스터 스킬 2", "마스터 스킬 3"]
    }
  },

  "learningStrategy": {
    "effectiveMethods": [
      "효율적인 학습법 1",
      "효율적인 학습법 2",
      "효율적인 학습법 3"
    ],
    "timeManagement": "시간 관리 팁",
    "recommendedBooks": [
      "추천 도서 1: 제목 (저자) - 왜 필독서인지",
      "추천 도서 2: 제목 (저자) - 왜 필독서인지",
      "추천 도서 3: 제목 (저자) - 왜 필독서인지",
      "추천 도서 4: 제목 (저자) - 왜 필독서인지",
      "추천 도서 5: 제목 (저자) - 왜 필독서인지"
    ],
    "recommendedCourses": [
      "추천 강의 1: 플랫폼/제목 - 이유",
      "추천 강의 2: 플랫폼/제목 - 이유",
      "추천 강의 3: 플랫폼/제목 - 이유"
    ],
    "mentorshipAdvice": "멘토링 찾는 방법"
  },

  "recommendations": [
    "즉시 실행 (내일부터): XX",
    "1주일 내: XX",
    "1개월 목표: XX",
    "3개월 마일스톤: XX",
    "6개월 비전: XX",
    "1년 장기 목표: XX",
    "평생 커리어 방향: XX"
  ],

  "warnings": [
    "함정 1: XX → 해결: XX",
    "함정 2: XX → 해결: XX",
    "함정 3: XX → 해결: XX",
    "함정 4: XX → 해결: XX",
    "함정 5: XX → 해결: XX"
  ],

  "advice": "종합 조언 (100자 이내, 핵심만 간결하게)",

  // ✅ 이력서 기반 분석 (이력서 제공 시에만 포함)
  "resumeAnalysis": {
    "careerFit": "현재 경력과 목표의 적합도 분석 (200자)",
    "skillGaps": [
      "보완이 필요한 스킬 1: 설명 + 학습 방법",
      "보완이 필요한 스킬 2: 설명 + 학습 방법",
      "보완이 필요한 스킬 3: 설명 + 학습 방법"
    ],
    "careerTransition": "이직/전환 추천 방향 (300자)",
    "hiddenPotentials": [
      "이력서에서 발견한 숨은 재능 1",
      "이력서에서 발견한 숨은 재능 2",
      "이력서에서 발견한 숨은 재능 3"
    ],
    "experienceValue": "경력 가치 평가 (200자)",
    "positioningAdvice": "포지셔닝 전략 (300자)"
  }
}

⚠️ **중요**: 사용자가 입력한 관심사, 고민 영역, 업무 스타일 등을 **반드시** 분석에 반영하고, 각 섹션마다 **구체적이고 실행 가능한** 내용으로 채워주세요. 추상적이거나 일반적인 조언은 피하고, 사용자 맞춤형 상세 분석을 제공해야 합니다. **이력서가 제공된 경우, resumeAnalysis 섹션을 반드시 포함하여 이력서 기반 상세 분석을 제공해주세요.**`
      },
      {
        role: 'user',
        content: `재능 분야: ${talentArea}
현재 스킬: ${currentSkills.join(', ')}
목표: ${goals}
경험 수준: ${experience}
가능 시간: ${timeAvailable}
어려움: ${challenges.join(', ')}
오늘 날짜: ${new Date().toLocaleDateString('ko-KR', { year: 'numeric', month: 'long', day: 'numeric', weekday: 'long' })}
${hasResume && resumeText ? `
📄 **이력서 정보**:
${resumeText.slice(0, 3000)}${resumeText.length > 3000 ? '...(이하 생략)' : ''}

위 이력서 내용을 바탕으로 resumeAnalysis 섹션에서 경력 적합도, 보완 스킬, 이직 방향, 숨은 재능 등을 상세히 분석해주세요.
` : ''}
위 정보를 바탕으로 재능 개발 운세를 JSON 형식으로 분석하고, 구체적인 주간 실행 계획을 제공해주세요. 현실적이면서도 동기부여가 되는 조언을 부탁드립니다.`
      }
    ], {
      temperature: 1,
      maxTokens: 8192,
      jsonMode: true
    })

    console.log(`✅ LLM 호출 완료: ${response.provider}/${response.model} - ${response.latency}ms`)

    // ✅ LLM 사용량 로깅 (비용/성능 분석용)
    await UsageLogger.log({
      fortuneType: 'talent',
      userId: userId,
      provider: response.provider,
      model: response.model,
      response: response,
      metadata: { talentArea, goals, experience, timeAvailable, isPremium, hasResume }
    })

    if (!response.content) {
      throw new Error('LLM API 응답 없음')
    }

    const fortuneData = JSON.parse(response.content)

    // ✅ 모든 데이터를 실제 LLM 분석 결과로 반환 (프리미엄 플레이스홀더 제거)
    const result = {
      // ✅ 표준화된 필드명: score, content, summary, advice
      fortuneType: 'talent',
      score: fortuneData.overallScore,
      content: fortuneData.content,
      summary: `${talentArea} 재능 개발 운세 ${fortuneData.overallScore}점`,
      advice: fortuneData.advice || '지속적인 노력으로 재능을 발전시켜 보세요.',

      // 기존 필드 유지 (하위 호환성)
      id: `talent-${Date.now()}`,
      type: 'talent',
      userId: userId,
      talentArea: talentArea,
      goals: goals,
      overallScore: fortuneData.overallScore, // ✅ 무료: 공개
      overall_score: fortuneData.overallScore, // ✅ 무료: 공개
      talent_content: fortuneData.content, // ✅ 무료: 공개 (재능 분석)
      description: fortuneData.description, // ✅ 실제 데이터 (블러 처리는 클라이언트에서)
      luckyItems: fortuneData.luckyItems, // ✅ 무료: 공개
      lucky_items: fortuneData.luckyItems, // ✅ 무료: 공개

      // ✅ 신규: 멘탈 모델 분석
      mentalModel: fortuneData.mentalModel,

      // ✅ 신규: 협업 궁합
      collaboration: fortuneData.collaboration,

      hexagonScores: fortuneData.hexagonScores, // ✅ 실제 데이터 (블러 처리는 클라이언트에서)
      talentInsights: fortuneData.talentInsights, // ✅ 실제 데이터 (블러 처리는 클라이언트에서)
      weeklyPlan: fortuneData.weeklyPlan, // ✅ 실제 데이터 (블러 처리는 클라이언트에서)

      // ✅ 신규: 단계별 성장 로드맵
      growthRoadmap: fortuneData.growthRoadmap,

      // ✅ 신규: 학습 전략
      learningStrategy: fortuneData.learningStrategy,

      // ✅ 신규: 이력서 기반 분석 (이력서 제공 시에만 포함)
      ...(hasResume && fortuneData.resumeAnalysis ? { resumeAnalysis: fortuneData.resumeAnalysis } : {}),

      recommendations: fortuneData.recommendations, // ✅ 실제 데이터 (블러 처리는 클라이언트에서)
      warnings: fortuneData.warnings, // ✅ 실제 데이터 (블러 처리는 클라이언트에서)
      advice: fortuneData.advice, // ✅ 실제 데이터 (블러 처리는 클라이언트에서)
      created_at: new Date().toISOString(),
      metadata: {
        currentSkills,
        experience,
        timeAvailable,
        challenges,
        hasResume // ✅ 이력서 포함 여부
      }
    }

    // ✅ 퍼센타일 계산 (오늘 운세를 본 사람들 중 상위 몇 %)
    const percentileData = await calculatePercentile(
      supabaseClient,
      'talent',
      fortuneData.overallScore
    )
    const resultWithPercentile = addPercentileToResult(result, percentileData)
    console.log(`📊 [Talent] Percentile: ${percentileData.isPercentileValid ? `상위 ${percentileData.percentile}%` : '데이터 부족'}`)

    // 결과 캐싱
    await supabaseClient
      .from('fortune_cache')
      .insert({
        cache_key: cacheKey,
        fortune_type: 'talent',
        user_id: userId || null,
        result: resultWithPercentile,
        created_at: new Date().toISOString()
      })

    // ✅ Cohort Pool에 저장 (비동기, fire-and-forget)
    saveToCohortPool(supabaseClient, 'talent', cohortHash, cohortData, resultWithPercentile)
      .catch(e => console.error('[Talent] Cohort 저장 오류:', e))

    return new Response(
      JSON.stringify({
        success: true,
        data: resultWithPercentile,
        cached: false,
        tokensUsed: response.usage?.totalTokens || 0
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
    )

  } catch (error) {
    console.error('Error in fortune-talent:', error)

    return new Response(
      JSON.stringify({
        error: error.message,
        details: error.toString()
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        status: 500
      }
    )
  }
})
