import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";
import { generateFortuneWithAI } from "../_shared/openai.ts";

// 시스템 레벨 운세 타입 정의
const SYSTEM_FORTUNE_TYPES = {
  mbti: {
    types: ['INTJ', 'INTP', 'ENTJ', 'ENTP', 'INFJ', 'INFP', 'ENFJ', 'ENFP', 
            'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ', 'ISTP', 'ISFP', 'ESTP', 'ESFP'],
    cache_days: 30
  },
  blood_type: {
    types: ['A', 'B', 'O', 'AB'],
    cache_days: 30
  },
  zodiac: {
    types: ['양자리', '황소자리', '쌍둥이자리', '게자리', '사자자리', '처녀자리',
            '천칭자리', '전갈자리', '사수자리', '염소자리', '물병자리', '물고기자리'],
    cache_days: 30
  },
  zodiac_animal: {
    types: ['쥐띠', '소띠', '호랑이띠', '토끼띠', '용띠', '뱀띠',
            '말띠', '양띠', '원숭이띠', '닭띠', '개띠', '돼지띠'],
    cache_days: 365
  },
  zodiac_age: {
    types: ['쥐', '소', '호랑이', '토끼', '용', '뱀',
            '말', '양', '원숭이', '닭', '개', '돼지'],
    cache_days: 1 // Daily generation for age-based fortunes
  }
};

serve(async (req) => {
  // CORS 처리
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Supabase 클라이언트 생성
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseKey);

    // 요청 데이터 파싱
    const { fortune_type, period = 'monthly', force_regenerate = false } = await req.json();

    // 유효한 시스템 운세 타입인지 확인
    if (!SYSTEM_FORTUNE_TYPES[fortune_type]) {
      return new Response(
        JSON.stringify({ error: "유효하지 않은 시스템 운세 타입입니다" }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 400 }
      );
    }

    const systemConfig = SYSTEM_FORTUNE_TYPES[fortune_type];
    const cacheKey = `system_${fortune_type}_${period}_${new Date().getMonth()}_${new Date().getFullYear()}`;

    // 강제 재생성이 아니면 캐시 확인
    if (!force_regenerate) {
      const { data: cached } = await supabase
        .from('system_fortune_cache')
        .select('*')
        .eq('cache_key', cacheKey)
        .gte('expires_at', new Date().toISOString())
        .single();

      if (cached) {
        // 캐시 히트 카운트 증가
        await supabase
          .from('system_fortune_cache')
          .update({ hit_count: (cached.hit_count || 0) + 1 })
          .eq('id', cached.id);

        return new Response(
          JSON.stringify({
            success: true,
            fortune_type,
            period,
            data: cached.fortune_data,
            cached: true,
            expires_at: cached.expires_at
          }),
          { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 200 }
        );
      }
    }

    // 배치 프롬프트 생성
    let batchPrompt = '';
    const periodText = period === 'monthly' ? '이번 달' : period === 'weekly' ? '이번 주' : '오늘';

    switch (fortune_type) {
      case 'mbti':
        batchPrompt = `
당신은 MBTI 전문가이자 운세 상담사입니다.
다음 16개 MBTI 타입의 ${periodText} 운세를 작성해주세요.

MBTI 타입: ${systemConfig.types.join(', ')}

각 타입별로 다음 형식으로 작성해주세요:
{
  "INTJ": {
    "summary": "한 줄 요약 (20자 내외)",
    "overall_score": 점수(0-100),
    "description": "INTJ 특성을 반영한 상세 운세 (200자 이상)",
    "career_advice": "경력 관련 조언",
    "relationship_advice": "인간관계 조언",
    "lucky_color": "행운의 색",
    "lucky_item": "행운의 아이템"
  },
  ... (모든 16개 타입)
}

각 MBTI의 고유한 특성을 반영하여 개성있게 작성해주세요.
`;
        break;

      case 'blood_type':
        batchPrompt = `
당신은 혈액형 심리학 전문가이자 운세 상담사입니다.
다음 4개 혈액형의 ${periodText} 운세를 작성해주세요.

혈액형: ${systemConfig.types.join(', ')}

각 혈액형별로 다음 형식으로 작성해주세요:
{
  "A": {
    "summary": "한 줄 요약",
    "overall_score": 점수(0-100),
    "description": "A형 특성을 반영한 상세 운세 (200자 이상)",
    "health_advice": "건강 조언",
    "money_luck": "금전운",
    "love_luck": "애정운",
    "lucky_number": 행운의 숫자
  },
  ... (모든 4개 혈액형)
}

각 혈액형의 특성을 살려서 작성해주세요.
`;
        break;

      case 'zodiac':
        batchPrompt = `
당신은 서양 점성술 전문가입니다.
다음 12개 별자리의 ${periodText} 운세를 작성해주세요.

별자리: ${systemConfig.types.join(', ')}

각 별자리별로 다음 형식으로 작성해주세요:
{
  "양자리": {
    "summary": "한 줄 요약",
    "overall_score": 점수(0-100),
    "description": "양자리 특성을 반영한 상세 운세 (200자 이상)",
    "element_influence": "화(火) 원소의 영향",
    "planetary_influence": "지배 행성의 영향",
    "lucky_day": "행운의 요일",
    "compatibility": "오늘 궁합이 좋은 별자리"
  },
  ... (모든 12개 별자리)
}

각 별자리의 원소와 지배 행성을 고려하여 작성해주세요.
`;
        break;

      case 'zodiac_animal':
        batchPrompt = `
당신은 동양 십이지 전문가입니다.
다음 12개 띠의 ${new Date().getFullYear()}년 운세를 작성해주세요.

띠: ${systemConfig.types.join(', ')}

각 띠별로 다음 형식으로 작성해주세요:
{
  "쥐띠": {
    "summary": "올해 운세 한 줄 요약",
    "overall_score": 연간 운세 점수(0-100),
    "description": "쥐띠 특성을 반영한 연간 상세 운세 (300자 이상)",
    "best_months": "가장 좋은 달 3개",
    "caution_months": "주의해야 할 달 3개",
    "career_fortune": "직업운",
    "wealth_fortune": "재물운",
    "health_fortune": "건강운",
    "relationship_fortune": "인연운"
  },
  ... (모든 12개 띠)
}

각 띠의 특성과 올해의 기운을 고려하여 작성해주세요.
`;
        break;
        
      case 'zodiac_age':
        // Note: zodiac_age fortunes should be generated by fortune-zodiac-scheduler
        // This case is here for completeness but redirects to the scheduler
        return new Response(
          JSON.stringify({ 
            error: "나이별 띠 운세는 fortune-zodiac-scheduler를 통해 생성됩니다",
            redirect_to: "/functions/v1/fortune-zodiac-scheduler"
          }),
          { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 400 }
        );
        break;
    }

    // OpenAI API 호출
    const batchResult = await generateFortuneWithAI(batchPrompt, 'system_batch');
    const fortuneData = JSON.parse(batchResult);

    // 캐시 만료 시간 계산
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + systemConfig.cache_days);

    // 시스템 캐시에 저장
    await supabase
      .from('system_fortune_cache')
      .upsert({
        cache_key: cacheKey,
        fortune_type,
        period,
        fortune_data: fortuneData,
        expires_at: expiresAt.toISOString(),
        hit_count: 0
      });

    // 통계 업데이트
    await supabase
      .from('system_fortune_stats')
      .insert({
        fortune_type,
        period,
        generated_at: new Date().toISOString(),
        types_count: systemConfig.types.length
      });

    return new Response(
      JSON.stringify({
        success: true,
        fortune_type,
        period,
        data: fortuneData,
        cached: false,
        expires_at: expiresAt.toISOString()
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 200 }
    );

  } catch (error) {
    console.error('Error:', error);
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 500 }
    );
  }
});

// 개별 사용자 운세 조회 함수 (다른 Edge Function에서 사용)
export async function getSystemFortune(
  supabase: any,
  fortuneType: string,
  specificType: string,
  period: string = 'monthly'
): Promise<any> {
  const cacheKey = `system_${fortuneType}_${period}_${new Date().getMonth()}_${new Date().getFullYear()}`;
  
  const { data: cached } = await supabase
    .from('system_fortune_cache')
    .select('fortune_data')
    .eq('cache_key', cacheKey)
    .gte('expires_at', new Date().toISOString())
    .single();

  if (cached && cached.fortune_data[specificType]) {
    return cached.fortune_data[specificType];
  }

  // 캐시가 없으면 null 반환 (개별 생성 필요)
  return null;
}