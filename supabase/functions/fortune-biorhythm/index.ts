/**
 * 바이오리듬 운세 (Biorhythm Fortune) Edge Function
 *
 * @description 생년월일 기반 바이오리듬(신체/감성/지성) 분석을 제공합니다.
 *
 * @endpoint POST /fortune-biorhythm
 *
 * @requestBody
 * - userId: string - 사용자 ID
 * - birthDate: string - 생년월일 (YYYY-MM-DD)
 * - targetDate?: string - 분석 대상일 (기본: 오늘)
 *
 * @response BiorhythmResponse
 * - physical: { value: number, status: string } - 신체 리듬
 * - emotional: { value: number, status: string } - 감성 리듬
 * - intellectual: { value: number, status: string } - 지성 리듬
 * - critical_days: string[] - 주의 일자
 * - advice: string - 오늘의 조언
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'
import { calculatePercentile } from '../_shared/percentile/calculator.ts'

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
    // Supabase 클라이언트 생성 (퍼센타일 계산용)
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    )

    const { birthDate, name, isPremium, targetDate } = await req.json()

    // 생년월일에서 총 일수 계산
    const birth = new Date(birthDate)
    const requestedDate = targetDate ? new Date(targetDate) : new Date()
    const analysisDate = Number.isNaN(requestedDate.getTime())
      ? new Date()
      : requestedDate
    const totalDays = Math.floor((analysisDate.getTime() - birth.getTime()) / (1000 * 60 * 60 * 24))

    // 바이오리듬 계산 (23일, 28일, 33일 주기)
    const physicalValue = Math.sin(2 * Math.PI * totalDays / 23) * 100
    const emotionalValue = Math.sin(2 * Math.PI * totalDays / 28) * 100
    const intellectualValue = Math.sin(2 * Math.PI * totalDays / 33) * 100

    // ✅ LLM 모듈 사용 (동적 DB 설정 - A/B 테스트 지원)
    const llm = await LLMFactory.createFromConfigAsync('fortune-biorhythm')

    // ✅ 강화된 시스템 프롬프트 (바이오리듬 과학 전문가 페르소나 + 분석 프레임워크)
    const systemPrompt = `당신은 20년 경력의 바이오리듬 과학 전문가이자 생체시계 연구자입니다.
독일의 빌헬름 플리스(Wilhelm Fliess)와 헤르만 스보보다(Hermann Swoboda)의 원조 바이오리듬 이론을 깊이 연구했으며, 현대 시간생물학(Chronobiology)과 결합한 실용적 분석법을 개발했습니다.

# 전문 분야
- 바이오리듬 3주기 분석: 신체(23일), 감정(28일), 지적(33일) 주기
- 시간생물학 기반 최적 활동 시간대 분석
- 크리티컬 데이(Critical Day) 예측 및 대응 전략
- 라이프스타일 최적화 및 에너지 관리

# 분석 원칙
1. **과학적 근거**: 바이오리듬 수치와 시간생물학을 기반으로 분석
2. **실용적 조언**: 즉시 적용 가능한 구체적인 생활 지침
3. **균형적 시각**: 긍정적이되 현실적인 관점 유지
4. **개인 맞춤**: 현재 리듬 상태에 맞는 맞춤형 조언

# 바이오리듬 해석 기준
- **+50 이상**: 매우 활성화 상태 (High Phase) - 적극적 활동 권장
- **+20 ~ +50**: 상승 국면 (Rising Phase) - 새로운 시작에 유리
- **-20 ~ +20**: 전환 국면 (Transition Phase) - 주의 필요
- **-50 ~ -20**: 하강 국면 (Declining Phase) - 휴식과 회복 중점
- **-50 이하**: 재충전 국면 (Recharge Phase) - 무리하지 않기

# 크리티컬 데이 분석
- 리듬이 0선을 통과할 때 불안정한 시기 (Critical Day)
- 복수의 리듬이 동시에 저점일 때 특별한 주의 필요

# 출력 형식 (반드시 JSON 형식으로)
{
  "overall_score": 0-100 사이 정수 (세 리듬의 종합 점수),
  "status_message": "현재 전체 컨디션 요약 (50자 이상, 과학적 + 친근한 톤)",
  "greeting": "개인화된 따뜻한 인사말 (30자 이상)",
  "physical": {
    "score": 0-100 (리듬 수치를 점수로 변환),
    "value": 실제 바이오리듬 수치,
    "phase": "High/Rising/Transition/Declining/Recharge 중 택1",
    "status": "신체 상태 요약 (30자 이상)",
    "advice": "신체 관리 구체적 조언 (100자 이상)"
  },
  "emotional": {
    "score": 0-100,
    "value": 실제 바이오리듬 수치,
    "phase": "High/Rising/Transition/Declining/Recharge 중 택1",
    "status": "감정 상태 요약 (30자 이상)",
    "advice": "감정 관리 구체적 조언 (100자 이상)"
  },
  "intellectual": {
    "score": 0-100,
    "value": 실제 바이오리듬 수치,
    "phase": "High/Rising/Transition/Declining/Recharge 중 택1",
    "status": "지적 상태 요약 (30자 이상)",
    "advice": "지적 활동 구체적 조언 (100자 이상)"
  },
  "today_recommendation": {
    "best_activity": "오늘 가장 추천하는 활동 (50자 이상, 구체적 설명)",
    "avoid_activity": "오늘 피해야 할 활동 (50자 이상, 이유 포함)",
    "best_time": "최고 컨디션 시간대 (구체적 시간, 예: 오전 10시-12시)",
    "energy_management": "에너지 관리 전략 (100자 이상)"
  },
  "weekly_forecast": {
    "best_day": "이번 주 최고의 날 (날짜 + 이유)",
    "worst_day": "이번 주 주의할 날 (날짜 + 대응법)",
    "overview": "주간 전체 흐름 분석 (100자 이상)",
    "weekly_advice": "이번 주 전략적 조언 (100자 이상)"
  },
  "important_dates": [
    { "date": "MM/DD (요일)", "type": "high/low/critical", "description": "상세 설명 (50자 이상)" }
  ],
  "weekly_activities": {
    "physical_activities": ["구체적 운동/활동 3-4가지 (시간대 포함)"],
    "mental_activities": ["집중력/창의력 활동 3-4가지 (구체적)"],
    "rest_days": ["휴식이 필요한 날짜와 이유"]
  },
  "personal_analysis": {
    "personality_insight": "현재 리듬 패턴과 성격 연결 분석 (100자 이상)",
    "life_phase": "현재 인생 에너지 단계 해석 (100자 이상)",
    "current_challenge": "현재 직면한 도전과 대응법 (100자 이상)",
    "growth_opportunity": "성장과 발전의 기회 (100자 이상)"
  },
  "lifestyle_advice": {
    "sleep_pattern": "최적 수면 시간과 패턴 조언 (100자 이상)",
    "exercise_timing": "운동 최적 타이밍과 종류 (100자 이상)",
    "nutrition_tip": "현재 리듬에 맞는 영양 관리 (100자 이상)",
    "stress_management": "스트레스 관리 전략 (100자 이상)"
  },
  "health_tips": {
    "physical_health": "신체 건강 관리 조언 (100자 이상)",
    "mental_health": "정신 건강 관리 조언 (100자 이상)",
    "energy_boost": "에너지 충전 구체적 방법 (100자 이상)",
    "warning_signs": "주의해야 할 신체/정신 신호 (100자 이상)"
  }
}

# 분량 요구사항 (카드 UI 스크롤 방지)
- 각 항목: 반드시 100자 이내
- 각 advice, insight: 80자 이내 (핵심만)
- 간결하고 핵심적인 내용만 작성

# 주의사항
- 실제 바이오리듬 수치를 기반으로 과학적 분석 제공
- 모호한 표현 금지 (구체적 시간, 날짜, 활동 명시)
- 의학적 진단은 피하되 건강 관리 조언은 제공
- 반드시 유효한 JSON 형식으로 출력`

    const userPrompt = `# 바이오리듬 분석 요청

## 사용자 정보
- 이름: ${name}
- 생년월일: ${birthDate}
- 출생 이후 총 경과일: ${totalDays}일

## 현재 바이오리듬 수치 (-100 ~ +100)
- 신체 리듬 (23일 주기): ${physicalValue.toFixed(2)}
- 감정 리듬 (28일 주기): ${emotionalValue.toFixed(2)}
- 지적 리듬 (33일 주기): ${intellectualValue.toFixed(2)}

## 향후 7일간 바이오리듬 예측
${Array.from({ length: 7 }, (_, i) => {
  const day = totalDays + i
  const p = Math.sin(2 * Math.PI * day / 23) * 100
  const e = Math.sin(2 * Math.PI * day / 28) * 100
  const intel = Math.sin(2 * Math.PI * day / 33) * 100
  const forecastDate = new Date(analysisDate.getTime() + i * 24 * 60 * 60 * 1000)
  const dayName = forecastDate.toLocaleDateString('ko-KR', { month: 'short', day: 'numeric', weekday: 'short' })
  return `- ${dayName}: 신체(${p.toFixed(0)}), 감정(${e.toFixed(0)}), 지적(${intel.toFixed(0)})`
}).join('\n')}

위 바이오리듬 데이터를 과학적으로 분석하여 ${name}님에게 맞춤형 조언을 JSON 형식으로 제공해주세요.
특히 오늘의 최적 활동 시간대와 이번 주 에너지 관리 전략을 중점적으로 분석해주세요.`

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

    // ✅ LLM 사용량 로깅 (비용/성능 분석용)
    await UsageLogger.log({
      fortuneType: 'biorhythm',
      provider: response.provider,
      model: response.model,
      response: response,
      metadata: { name, totalDays, physicalValue, emotionalValue, intellectualValue, isPremium }
    })

    // 응답 구성 (전체 데이터)
    const blurredResult = {
      ...result,
      personal_analysis: result.personal_analysis,
      lifestyle_advice: result.lifestyle_advice,
      health_tips: result.health_tips,
      weekly_activities: result.weekly_activities
    }

    // ✅ 퍼센타일 계산 (오늘 운세를 본 사람들 중 상위 몇 %)
    const percentileData = await calculatePercentile(
      supabaseClient,
      'biorhythm',
      result.overall_score
    )
    console.log(`📊 [Biorhythm] Percentile: ${percentileData.isPercentileValid ? `상위 ${percentileData.percentile}%` : '데이터 부족'}`)

    // Flutter가 기대하는 형식으로 응답
    return new Response(
      JSON.stringify({
        success: true,
        data: {
          // ✅ 표준화된 필드명: score, content, summary, advice
          fortuneType: 'biorhythm',
          score: result.overall_score,
          content: result.status_message || '바이오리듬 분석 결과입니다.',
          summary: result.greeting || '오늘의 바이오리듬을 확인하세요',
          advice: result.today_recommendation?.energy_management || '에너지를 효율적으로 관리하세요',
          // 기존 필드 유지 (하위 호환성)
          title: '바이오리듬 분석',
          biorhythm_summary: {
            overall_score: result.overall_score,
            status_message: result.status_message,
            greeting: result.greeting,
          },
          ...blurredResult,
          // ✅ 퍼센타일 정보 추가
          percentile: percentileData.percentile,
          totalTodayViewers: percentileData.totalTodayViewers,
          isPercentileValid: percentileData.isPercentileValid,
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
    const errorMessage = error instanceof Error
      ? error.message
      : '바이오리듬 분석 중 오류가 발생했습니다'
    const errorStack = error instanceof Error ? error.stack : undefined
    console.error('❌ Biorhythm Error:', error)
    return new Response(
      JSON.stringify({
        success: false,
        error: errorMessage,
        details: errorStack
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
