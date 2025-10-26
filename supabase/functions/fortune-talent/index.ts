import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'

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
      isPremium = false // ✅ 프리미엄 사용자 여부
    } = requestData

    console.log('💎 [Talent] Premium 상태:', isPremium)

    // 캐시 확인
    const today = new Date().toISOString().split('T')[0]
    const cacheKey = `${userId || 'anonymous'}_talent_${today}_${JSON.stringify({talentArea, goals})}`

    const { data: cachedResult } = await supabaseClient
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .eq('fortune_type', 'talent')
      .single()

    if (cachedResult) {
      return new Response(
        JSON.stringify({
          fortune: cachedResult.result,
          cached: true,
          tokensUsed: 0
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
      )
    }

    // OpenAI API 호출
    const controller = new AbortController()
    const timeoutId = setTimeout(() => controller.abort(), 30000)

    // ✅ LLM 모듈 사용
    const llm = LLMFactory.createFromConfig('talent')

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
    "thinkingStyle": "사고 방식 분석 (논리적/직관적/균형형 등, 200자)",
    "decisionPattern": "의사결정 패턴 분석 (신중형/빠른형/데이터기반 등, 200자)",
    "learningStyle": "효율적인 학습 방법 (시각적/청각적/실습형 등, 200자)"
  },

  "collaboration": {
    "goodMatch": ["잘 맞는 타입 1 (이유)", "잘 맞는 타입 2 (이유)", "잘 맞는 타입 3 (이유)"],
    "challenges": ["주의할 타입 1 (이유)", "주의할 타입 2 (이유)"],
    "teamRole": "팀에서의 최적 역할 (200자, 리더/조정자/실행자/전문가 등 + 이유)"
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
      "monetizationStrategy": "수익화 전략 (300자)\n- 단기 수익 (1-3개월)\n- 중기 수익 (6개월-1년)\n- 장기 비전",
      "portfolioBuilding": "포트폴리오 구축 가이드 (300자)\n- 필수 프로젝트 3개\n- 노출 전략\n- 차별화 포인트",
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
      "효율적인 학습법 1 (200자, 방법 + 이유 + 실행 팁)",
      "효율적인 학습법 2 (200자)",
      "효율적인 학습법 3 (200자)"
    ],
    "timeManagement": "시간 관리 팁 (300자)\n- 하루 루틴 제안\n- 집중 시간대 활용\n- 휴식 전략",
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
    "mentorshipAdvice": "멘토링 찾는 방법 (300자)\n- 어디서 찾을지\n- 어떤 멘토가 좋은지\n- 멘토링 받는 방법"
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

  "advice": "종합 조언 (500자)\n- 핵심 메시지 1문장\n- 동기부여 문구 (200자)\n- 첫 액션 아이템 3가지 (내일 당장 할 수 있는 것)\n- 격려 메시지"
}

⚠️ **중요**: 사용자가 입력한 관심사, 고민 영역, 업무 스타일 등을 **반드시** 분석에 반영하고, 각 섹션마다 **구체적이고 실행 가능한** 내용으로 채워주세요. 추상적이거나 일반적인 조언은 피하고, 사용자 맞춤형 상세 분석을 제공해야 합니다.`
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

위 정보를 바탕으로 재능 개발 운세를 JSON 형식으로 분석하고, 구체적인 주간 실행 계획을 제공해주세요. 현실적이면서도 동기부여가 되는 조언을 부탁드립니다.`
      }
    ], {
      temperature: 1,
      maxTokens: 8192,
      jsonMode: true
    })

    console.log(`✅ LLM 호출 완료: ${response.provider}/${response.model} - ${response.latency}ms`)

    if (!response.content) {
      throw new Error('LLM API 응답 없음')
    }

    const fortuneData = JSON.parse(response.content)

    // ✅ Blur 로직 적용: 실제 데이터는 항상 반환, isBlurred만 설정
    const isBlurred = !isPremium
    const blurredSections = isBlurred
      ? ['top3_talents', 'career_roadmap', 'growth_timeline']
      : []

    // ✅ 모든 데이터를 실제 LLM 분석 결과로 반환 (프리미엄 플레이스홀더 제거)
    const result = {
      id: `talent-${Date.now()}`,
      type: 'talent',
      userId: userId,
      talentArea: talentArea,
      goals: goals,
      overallScore: fortuneData.overallScore, // ✅ 무료: 공개
      overall_score: fortuneData.overallScore, // ✅ 무료: 공개
      content: fortuneData.content, // ✅ 무료: 공개 (재능 분석)
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

      recommendations: fortuneData.recommendations, // ✅ 실제 데이터 (블러 처리는 클라이언트에서)
      warnings: fortuneData.warnings, // ✅ 실제 데이터 (블러 처리는 클라이언트에서)
      advice: fortuneData.advice, // ✅ 실제 데이터 (블러 처리는 클라이언트에서)
      created_at: new Date().toISOString(),
      metadata: {
        currentSkills,
        experience,
        timeAvailable,
        challenges
      },
      isBlurred, // ✅ 블러 상태 (true면 클라이언트가 블러 처리)
      blurredSections // ✅ 블러된 섹션 목록
    }

    // 결과 캐싱
    await supabaseClient
      .from('fortune_cache')
      .insert({
        cache_key: cacheKey,
        fortune_type: 'talent',
        user_id: userId || null,
        result: result,
        created_at: new Date().toISOString()
      })

    return new Response(
      JSON.stringify({
        fortune: result,
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
