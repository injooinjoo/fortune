import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { LLMFactory } from '../_shared/llm/factory.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// 바이오리듬 응답 스키마
interface BiorhythmResponse {
  // 오늘의 전체 상태
  overall_score: number;
  status_message: string;
  greeting: string;

  // 3가지 리듬
  physical: {
    score: number;
    value: number; // -100 ~ 100
    status: string;
    advice: string;
  };
  emotional: {
    score: number;
    value: number; // -100 ~ 100
    status: string;
    advice: string;
  };
  intellectual: {
    score: number;
    value: number; // -100 ~ 100
    status: string;
    advice: string;
  };

  // 오늘의 추천
  today_recommendation: {
    best_activity: string;
    avoid_activity: string;
    best_time: string;
    energy_management: string;
  };

  // 주간 전망
  weekly_forecast: {
    best_day: string;
    worst_day: string;
    overview: string;
    weekly_advice: string;
  };

  // 주요 날짜들 (7일)
  important_dates: Array<{
    date: string;
    type: 'high' | 'low' | 'critical';
    description: string;
  }>;

  // 주간 활동 가이드
  weekly_activities: {
    physical_activities: string[];
    mental_activities: string[];
    rest_days: string[];
  };

  // 개인 맞춤 분석 (블러 처리 대상)
  personal_analysis: {
    personality_insight: string;
    life_phase: string;
    current_challenge: string;
    growth_opportunity: string;
  };

  // 라이프스타일 조언 (블러 처리 대상)
  lifestyle_advice: {
    sleep_pattern: string;
    exercise_timing: string;
    nutrition_tip: string;
    stress_management: string;
  };

  // 건강 관리 팁 (블러 처리 대상)
  health_tips: {
    physical_health: string;
    mental_health: string;
    energy_boost: string;
    warning_signs: string;
  };
}

serve(async (req) => {
  // CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { birthDate, name, isPremium } = await req.json()

    // 생년월일에서 총 일수 계산
    const birth = new Date(birthDate)
    const today = new Date()
    const totalDays = Math.floor((today.getTime() - birth.getTime()) / (1000 * 60 * 60 * 24))

    // 바이오리듬 계산 (23일, 28일, 33일 주기)
    const physicalValue = Math.sin(2 * Math.PI * totalDays / 23) * 100
    const emotionalValue = Math.sin(2 * Math.PI * totalDays / 28) * 100
    const intellectualValue = Math.sin(2 * Math.PI * totalDays / 33) * 100

    // LLM으로 맞춤형 해석 생성
    const llm = LLMFactory.createFromConfig('fortune-biorhythm')

    const systemPrompt = `당신은 바이오리듬 전문 상담사입니다.
사용자의 신체/감정/지적 리듬을 분석하여 오늘의 컨디션과 맞춤형 조언을 제공합니다.

**응답 형식**: 반드시 JSON으로만 응답하세요.`

    const userPrompt = `**사용자 정보**:
- 이름: ${name}
- 생년월일: ${birthDate}
- 총 경과일: ${totalDays}일

**현재 바이오리듬 값** (-100 ~ 100):
- 신체 리듬: ${physicalValue.toFixed(2)}
- 감정 리듬: ${emotionalValue.toFixed(2)}
- 지적 리듬: ${intellectualValue.toFixed(2)}

**다음 7일 예측**:
${Array.from({ length: 7 }, (_, i) => {
  const day = totalDays + i
  const p = Math.sin(2 * Math.PI * day / 23) * 100
  const e = Math.sin(2 * Math.PI * day / 28) * 100
  const intel = Math.sin(2 * Math.PI * day / 33) * 100
  const dayName = new Date(Date.now() + i * 24 * 60 * 60 * 1000).toLocaleDateString('ko-KR', { month: 'short', day: 'numeric', weekday: 'short' })
  return `${dayName}: 신체(${p.toFixed(0)}), 감정(${e.toFixed(0)}), 지적(${intel.toFixed(0)})`
}).join('\n')}

위 바이오리듬 데이터를 기반으로 다음 JSON 형식으로 상세한 분석을 제공하세요:

{
  "overall_score": <0-100 점수>,
  "status_message": "<현재 전체 컨디션 한줄 요약>",
  "greeting": "<친근한 인사말>",
  "physical": {
    "score": <0-100 점수>,
    "value": ${physicalValue},
    "status": "<신체 상태 설명 (15자 이내)>",
    "advice": "<신체 관리 조언 (50자)>"
  },
  "emotional": {
    "score": <0-100 점수>,
    "value": ${emotionalValue},
    "status": "<감정 상태 설명 (15자 이내)>",
    "advice": "<감정 관리 조언 (50자)>"
  },
  "intellectual": {
    "score": <0-100 점수>,
    "value": ${intellectualValue},
    "status": "<지적 상태 설명 (15자 이내)>",
    "advice": "<지적 활동 조언 (50자)>"
  },
  "today_recommendation": {
    "best_activity": "<오늘 가장 추천하는 활동>",
    "avoid_activity": "<오늘 피해야 할 활동>",
    "best_time": "<최고 컨디션 시간대>",
    "energy_management": "<에너지 관리 팁>"
  },
  "weekly_forecast": {
    "best_day": "<이번 주 최고의 날>",
    "worst_day": "<이번 주 주의할 날>",
    "overview": "<주간 전체 흐름 요약>",
    "weekly_advice": "<이번 주 전략 조언>"
  },
  "important_dates": [
    { "date": "MM/DD (요일)", "type": "high", "description": "<무엇을 하기 좋은지>" },
    ...3-5개
  ],
  "weekly_activities": {
    "physical_activities": ["활동1", "활동2", "활동3"],
    "mental_activities": ["활동1", "활동2", "활동3"],
    "rest_days": ["날짜1", "날짜2"]
  },
  "personal_analysis": {
    "personality_insight": "<성격과 리듬의 관계 분석>",
    "life_phase": "<현재 인생 단계 해석>",
    "current_challenge": "<현재 직면한 도전>",
    "growth_opportunity": "<성장 기회>"
  },
  "lifestyle_advice": {
    "sleep_pattern": "<수면 패턴 조언>",
    "exercise_timing": "<운동 타이밍 추천>",
    "nutrition_tip": "<영양 관리 팁>",
    "stress_management": "<스트레스 관리법>"
  },
  "health_tips": {
    "physical_health": "<신체 건강 관리>",
    "mental_health": "<정신 건강 관리>",
    "energy_boost": "<에너지 충전 방법>",
    "warning_signs": "<주의해야 할 증상>"
  }
}`

    const response = await llm.generate([
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userPrompt }
    ], {
      temperature: 1,
      maxTokens: 4096,
      jsonMode: true
    })

    const result = JSON.parse(response.content) as BiorhythmResponse

    console.log(`✅ ${response.provider}/${response.model} - ${response.latency}ms`)

    // Flutter가 기대하는 형식으로 응답
    return new Response(
      JSON.stringify({
        success: true,
        data: {
          title: '바이오리듬 분석',
          summary: {
            overall_score: result.overall_score,
            status_message: result.status_message,
            greeting: result.greeting,
          },
          ...result,
        }
      }),
      {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json'
        }
      }
    )

  } catch (error) {
    console.error('❌ Biorhythm Error:', error)
    return new Response(
      JSON.stringify({
        success: false,
        error: error.message || '바이오리듬 분석 중 오류가 발생했습니다',
        details: error.stack
      }),
      {
        status: 500,
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json'
        }
      }
    )
  }
})
