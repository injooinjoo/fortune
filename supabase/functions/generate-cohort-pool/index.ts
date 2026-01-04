/**
 * Cohort Pool 배치 생성 Edge Function
 *
 * @description 운세별 Cohort Pool을 사전 생성하여 LLM API 비용 90% 절감
 *
 * @endpoint POST /generate-cohort-pool
 *
 * @requestBody
 * - fortuneType: string - 운세 타입 (예: 'daily', 'love', 'career')
 * - maxCohorts?: number - 최대 처리할 cohort 수 (기본: 10, 최대: 50)
 * - targetSize?: number - cohort당 목표 결과 수 (기본: settings에서 조회)
 *
 * @response
 * - success: boolean
 * - processed: number - 처리된 cohort 수
 * - generated: number - 새로 생성된 결과 수
 * - skipped: number - 이미 충분한 cohort 수
 *
 * @example
 * curl -X POST https://xxx.supabase.co/functions/v1/generate-cohort-pool \
 *   -H "Authorization: Bearer <service_role_key>" \
 *   -d '{"fortuneType":"daily","maxCohorts":10}'
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Cohort 설정 타입
interface CohortSettings {
  fortune_type: string;
  target_pool_size: number;
  max_pool_size: number;
  cohort_dimensions: string[];
  dimension_values: Record<string, string[]>;
  placeholders: string[];
  is_active: boolean;
}

// 운세별 시스템 프롬프트 매핑
const FORTUNE_PROMPTS: Record<string, string> = {
  daily: `당신은 전통 동양철학과 현대 심리학을 결합한 일일 인사이트 전문가입니다.
사용자에게 따뜻하고 긍정적이면서도 실용적인 조언을 제공하세요.
{{userName}}과 같은 플레이스홀더는 그대로 유지하세요.`,

  love: `당신은 연애 심리와 관계 역학의 전문가입니다.
{{userName}}, {{age}} 등 플레이스홀더는 그대로 유지하고,
실질적이고 공감 가능한 연애 조언을 제공하세요.`,

  compatibility: `당신은 사주 궁합 전문가입니다.
{{person1_name}}, {{person2_name}} 등 플레이스홀더는 그대로 유지하세요.
두 사람 간의 조화와 주의점을 균형있게 분석하세요.`,

  career: `당신은 커리어 코칭 전문가입니다.
{{userName}}, {{skills}} 등 플레이스홀더는 그대로 유지하고,
실용적인 커리어 조언을 제공하세요.`,

  health: `당신은 동양 의학과 현대 건강학을 결합한 건강 전문가입니다.
{{userName}}, {{concernedParts}} 등 플레이스홀더는 유지하세요.
오행 균형에 기반한 건강 조언을 제공하세요.`,

  'traditional-saju': `당신은 전통 사주명리학 전문가입니다.
{{userName}}, {{question}}, {{sajuPillars}} 등 플레이스홀더는 유지하세요.
사주 원리에 기반한 심층 분석을 제공하세요.`,

  dream: `당신은 동서양 해몽학에 정통한 꿈 해석 전문가입니다.
{{userName}}, {{dreamContent}} 등 플레이스홀더는 유지하세요.
꿈의 상징과 의미를 해석해주세요.`,

  'face-reading': `당신은 관상학 전문가입니다.
{{userName}}, {{faceFeatures}} 등 플레이스홀더는 유지하세요.
얼굴형에 따른 성격과 운세를 분석하세요.`,

  mbti: `당신은 MBTI 기반 일일 인사이트 전문가입니다.
{{userName}} 플레이스홀더는 유지하세요.
해당 MBTI 유형에 맞춤화된 조언을 제공하세요.`,

  'lucky-items': `당신은 행운 아이템 추천 전문가입니다.
{{userName}} 플레이스홀더는 유지하세요.
카테고리에 맞는 행운 아이템을 추천하세요.`,

  talent: `당신은 재능 발굴 전문가입니다.
{{userName}}, {{concerns}}, {{interests}} 등 플레이스홀더는 유지하세요.
잠재 재능과 개발 방향을 제안하세요.`,

  investment: `당신은 재물운 분석 전문가입니다.
{{userName}}, {{investmentGoal}} 등 플레이스홀더는 유지하세요.
오행에 기반한 재물운 분석을 제공하세요.`,

  'ex-lover': `당신은 과거 관계 분석 전문가입니다.
{{userName}}, {{exName}} 등 플레이스홀더는 유지하세요.
객관적이고 건설적인 조언을 제공하세요.`,

  'blind-date': `당신은 소개팅/첫만남 전문가입니다.
{{userName}}, {{preferences}} 등 플레이스홀더는 유지하세요.
긍정적이고 실용적인 조언을 제공하세요.`,
}

// 운세별 결과 스키마
const FORTUNE_SCHEMAS: Record<string, object> = {
  daily: {
    overall_score: "number (1-100)",
    summary: "string (오늘의 한줄 요약)",
    greeting: "string ({{userName}}님께 인사)",
    advice: "string (핵심 조언)",
    caution: "string (주의사항)",
    categories: {
      total: { score: "number", advice: "string" },
      love: { score: "number", advice: "string" },
      money: { score: "number", advice: "string" },
      work: { score: "number", advice: "string" },
      health: { score: "number", advice: "string" },
    },
    lucky_items: {
      time: "string",
      color: "string",
      number: "string",
      direction: "string",
      food: "string",
      item: "string",
    },
    ai_tips: ["string (3개의 실천 팁)"],
  },

  love: {
    overall_score: "number (1-100)",
    summary: "string",
    current_energy: "string (현재 연애 에너지)",
    advice_for_status: "string (솔로/썸/연애/기혼 맞춤 조언)",
    lucky_day: "string",
    lucky_place: "string",
    caution: "string",
    tips: ["string (3개의 연애 팁)"],
  },

  compatibility: {
    overall_score: "number (1-100)",
    summary: "string ({{person1_name}}님과 {{person2_name}}님의 궁합)",
    strengths: ["string (3개의 장점)"],
    challenges: ["string (2개의 주의점)"],
    advice: "string (관계 조언)",
    lucky_dates: ["string (2개의 좋은 날)"],
    chemistry_type: "string (궁합 유형)",
  },

  career: {
    overall_score: "number (1-100)",
    summary: "string",
    strengths: ["string (직장 강점 3개)"],
    growth_areas: ["string (성장 영역 2개)"],
    advice: "string",
    lucky_industry: "string",
    networking_tip: "string",
    monthly_focus: "string",
  },

  health: {
    overall_score: "number (1-100)",
    summary: "string",
    body_focus: "string (주의해야 할 부위)",
    element_analysis: {
      dominant: "string",
      weak: "string",
      balance_tip: "string",
    },
    recommended_foods: ["string (3개)"],
    exercises: ["string (2개)"],
    daily_routine: "string",
    seasonal_advice: "string",
  },

  'traditional-saju': {
    overall_score: "number (1-100)",
    summary: "string",
    day_master_analysis: "string (일간 분석)",
    element_balance: "string (오행 분석)",
    answer_to_question: "string ({{question}}에 대한 답변)",
    timing_advice: "string (좋은 시기)",
    action_items: ["string (3개)"],
  },

  dream: {
    interpretation: "string (꿈 해석)",
    symbol_meanings: ["string (상징 의미 3개)"],
    emotional_insight: "string (감정 분석)",
    fortune_hint: "string (운세 암시)",
    action_advice: "string (실천 조언)",
    lucky_number: "string",
  },

  'face-reading': {
    overall_score: "number (1-100)",
    face_type_analysis: "string (얼굴형 분석)",
    personality_traits: ["string (성격 특성 3개)"],
    career_aptitude: "string (적합 직업)",
    relationship_style: "string (관계 스타일)",
    life_advice: "string (인생 조언)",
    lucky_color: "string",
  },

  mbti: {
    overall_score: "number (1-100)",
    today_energy: "string (오늘의 에너지)",
    strengths_today: ["string (오늘의 강점 2개)"],
    challenges_today: ["string (주의점 2개)"],
    ideal_activities: ["string (추천 활동 3개)"],
    social_tip: "string (대인관계 팁)",
    productivity_tip: "string (생산성 팁)",
  },

  'lucky-items': {
    items: [
      {
        name: "string (아이템 이름)",
        description: "string (설명)",
        reason: "string (추천 이유)",
        where_to_get: "string (구매처/얻는 방법)",
      }
    ],
    category_advice: "string (카테고리별 조언)",
    lucky_timing: "string (행운의 시간)",
  },

  talent: {
    overall_score: "number (1-100)",
    hidden_talents: ["string (잠재 재능 3개)"],
    development_path: "string (개발 방향)",
    suitable_fields: ["string (적합 분야 3개)"],
    action_plan: ["string (실천 계획 3단계)"],
    mentor_advice: "string (멘토 조언)",
  },

  investment: {
    overall_score: "number (1-100)",
    wealth_energy: "string (재물 에너지)",
    element_impact: "string (오행 영향)",
    suitable_investments: ["string (적합 투자 3개)"],
    caution_areas: ["string (주의 영역 2개)"],
    timing_advice: "string (시기 조언)",
    money_mindset: "string (금전 마인드셋)",
  },

  'ex-lover': {
    overall_score: "number (1-100)",
    current_energy: "string (현재 감정 에너지)",
    relationship_analysis: "string (관계 분석)",
    healing_advice: "string (치유 조언)",
    future_outlook: "string (미래 전망)",
    action_items: ["string (실천 항목 3개)"],
    self_care_tips: ["string (자기 관리 팁 2개)"],
  },

  'blind-date': {
    overall_score: "number (1-100)",
    first_impression_tips: ["string (첫인상 팁 3개)"],
    conversation_starters: ["string (대화 주제 3개)"],
    outfit_advice: "string (복장 조언)",
    lucky_location: "string (추천 장소)",
    dos_and_donts: {
      do: ["string (2개)"],
      dont: ["string (2개)"],
    },
    confidence_boost: "string (자신감 조언)",
  },
}

/**
 * 모든 cohort 조합 생성
 */
function generateAllCohorts(settings: CohortSettings): Record<string, string>[] {
  const dimensions = settings.cohort_dimensions;
  const values = settings.dimension_values;

  const combinations: Record<string, string>[] = [];

  function generateCombinations(index: number, current: Record<string, string>) {
    if (index >= dimensions.length) {
      combinations.push({ ...current });
      return;
    }

    const dim = dimensions[index];
    const dimValues = values[dim] || [];

    for (const val of dimValues) {
      current[dim] = val;
      generateCombinations(index + 1, current);
    }
  }

  generateCombinations(0, {});
  return combinations;
}

/**
 * Cohort Hash 생성 (MD5)
 */
async function generateCohortHash(cohortData: Record<string, string>): Promise<string> {
  const sortedKeys = Object.keys(cohortData).sort();
  const normalized = sortedKeys.map(k => `${k}:${cohortData[k]}`).join('|');

  const encoder = new TextEncoder();
  const data = encoder.encode(normalized);
  const hashBuffer = await crypto.subtle.digest('MD5', data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
}

/**
 * LLM으로 운세 결과 생성
 */
async function generateFortuneResult(
  fortuneType: string,
  cohortData: Record<string, string>
): Promise<object> {
  const llm = LLMFactory.createFromConfig(fortuneType);

  const systemPrompt = FORTUNE_PROMPTS[fortuneType] || FORTUNE_PROMPTS['daily'];
  const schema = FORTUNE_SCHEMAS[fortuneType] || FORTUNE_SCHEMAS['daily'];

  const cohortDescription = Object.entries(cohortData)
    .map(([k, v]) => `${k}: ${v}`)
    .join(', ');

  const userPrompt = `다음 특성을 가진 사용자를 위한 ${fortuneType} 인사이트를 생성해주세요.

사용자 특성: ${cohortDescription}

중요 사항:
1. 모든 플레이스홀더({{userName}}, {{age}} 등)는 그대로 유지하세요.
2. 아래 JSON 스키마를 정확히 따르세요.
3. 응답은 유효한 JSON만 반환하세요.

응답 스키마:
${JSON.stringify(schema, null, 2)}`;

  const result = await llm.generate({
    systemPrompt,
    userPrompt,
    temperature: 0.8, // 다양성을 위해 높은 temperature
    jsonMode: true,
  });

  // JSON 파싱
  try {
    const jsonMatch = result.content.match(/\{[\s\S]*\}/);
    if (jsonMatch) {
      return JSON.parse(jsonMatch[0]);
    }
  } catch (e) {
    console.error('JSON 파싱 실패:', e);
  }

  return JSON.parse(result.content);
}

serve(async (req) => {
  // CORS 처리
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { fortuneType, maxCohorts = 10, targetSize } = await req.json();

    if (!fortuneType) {
      return new Response(
        JSON.stringify({ error: 'fortuneType is required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Supabase 클라이언트 생성 (service role)
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      { auth: { persistSession: false } }
    );

    // 1. 설정 조회
    const { data: settings, error: settingsError } = await supabaseClient
      .from('cohort_pool_settings')
      .select('*')
      .eq('fortune_type', fortuneType)
      .eq('is_active', true)
      .single();

    if (settingsError || !settings) {
      return new Response(
        JSON.stringify({ error: `Settings not found for ${fortuneType}`, details: settingsError }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const poolTargetSize = targetSize || settings.target_pool_size;

    console.log(`📊 ${fortuneType} 설정 로드: ${JSON.stringify(settings.cohort_dimensions)}`);

    // 2. 모든 cohort 조합 생성
    const allCohorts = generateAllCohorts(settings);
    console.log(`📋 총 ${allCohorts.length}개 cohort 조합`);

    // 3. 처리할 cohort 제한
    const cohortsToProcess = allCohorts.slice(0, Math.min(maxCohorts, 50));

    let processed = 0;
    let generated = 0;
    let skipped = 0;
    const errors: string[] = [];

    // 4. 각 cohort에 대해 처리
    for (const cohortData of cohortsToProcess) {
      const cohortHash = await generateCohortHash(cohortData);

      // 현재 pool 크기 확인
      const { data: poolSizeResult } = await supabaseClient
        .rpc('get_cohort_pool_size', {
          p_fortune_type: fortuneType,
          p_cohort_hash: cohortHash,
        });

      const currentSize = poolSizeResult || 0;

      if (currentSize >= poolTargetSize) {
        skipped++;
        continue;
      }

      // 부족한 만큼 생성
      const needed = Math.min(poolTargetSize - currentSize, 5); // 한 번에 최대 5개
      console.log(`🔄 ${cohortHash.slice(0, 8)}... 생성 중 (${needed}개 필요)`);

      for (let i = 0; i < needed; i++) {
        try {
          const result = await generateFortuneResult(fortuneType, cohortData);

          // Pool에 저장
          const { error: insertError } = await supabaseClient
            .from('cohort_fortune_pool')
            .insert({
              fortune_type: fortuneType,
              cohort_hash: cohortHash,
              cohort_data: cohortData,
              result_template: result,
              quality_score: 1.0,
            });

          if (insertError) {
            errors.push(`Insert error: ${insertError.message}`);
          } else {
            generated++;
          }
        } catch (e) {
          errors.push(`Generation error for ${cohortHash}: ${e.message}`);
        }
      }

      processed++;
    }

    // 5. 결과 반환
    const response = {
      success: true,
      fortuneType,
      totalCohorts: allCohorts.length,
      processed,
      generated,
      skipped,
      remainingCohorts: allCohorts.length - processed - skipped,
      errors: errors.length > 0 ? errors : undefined,
    };

    console.log(`✅ 완료: ${JSON.stringify(response)}`);

    return new Response(
      JSON.stringify(response),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );

  } catch (error) {
    console.error('Error:', error);
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});
