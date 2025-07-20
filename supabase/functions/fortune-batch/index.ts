import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";
import { authenticateUser, checkTokenBalance, deductTokens } from "../_shared/auth.ts";
import { generateFortuneWithAI } from "../_shared/openai.ts";
import { FORTUNE_TOKEN_COSTS } from "../_shared/types.ts";
import { generateBatchPrompt, recommendBundle } from "../_shared/batch-prompts.ts";

// 배치 패키지 정의
const BATCH_PACKAGES = {
  // 기존 패키지
  onboarding: {
    fortune_types: ['saju', 'personality', 'talent', 'daily', 'yearly'],
    token_cost: 5,
    description: '온보딩 완료 패키지',
    bundle_type: 'deep_analysis'
  },
  daily_refresh: {
    fortune_types: ['daily', 'hourly', 'biorhythm', 'lucky-color'],
    token_cost: 2,
    description: '일일 갱신 패키지',
    bundle_type: 'time_based'
  },
  love_single: {
    fortune_types: ['love', 'destiny', 'blind-date', 'celebrity-match'],
    token_cost: 4,
    description: '연애운 패키지 (솔로)',
    bundle_type: 'lifestyle'
  },
  love_couple: {
    fortune_types: ['love', 'couple-match', 'chemistry', 'marriage'],
    token_cost: 5,
    description: '연애운 패키지 (커플)',
    bundle_type: 'lifestyle'
  },
  career: {
    fortune_types: ['career', 'wealth', 'business', 'talent'],
    token_cost: 6,
    description: '커리어 패키지',
    bundle_type: 'lifestyle'
  },
  lucky_items: {
    fortune_types: ['lucky-color', 'lucky-number', 'lucky-items', 'lucky-food', 'lucky-outfit'],
    token_cost: 3,
    description: '행운 아이템 패키지',
    bundle_type: 'lifestyle'
  },
  premium_complete: {
    fortune_types: [
      'saju', 'traditional-saju', 'tojeong', 'destiny', 'past-life',
      'daily', 'weekly', 'monthly', 'yearly',
      'love', 'career', 'wealth', 'health', 'lucky-items', 'biorhythm'
    ],
    token_cost: 15,
    description: '프리미엄 종합 패키지',
    bundle_type: 'deep_analysis'
  },
  
  // 새로운 시간 기반 번들
  morning_bundle: {
    fortune_types: ['daily', 'hourly', 'biorhythm', 'lucky-color'],
    token_cost: 2,
    description: '아침 시작 패키지',
    bundle_type: 'time_based'
  },
  evening_bundle: {
    fortune_types: ['tomorrow', 'weekly', 'health', 'lucky-items'],
    token_cost: 3,
    description: '저녁 마무리 패키지',
    bundle_type: 'time_based'
  },
  
  // 라이프스타일 번들
  work_life_bundle: {
    fortune_types: ['career', 'wealth', 'business', 'daily', 'lucky-number'],
    token_cost: 5,
    description: '커리어 성공 패키지',
    bundle_type: 'lifestyle'
  },
  love_life_bundle: {
    fortune_types: ['love', 'compatibility', 'chemistry', 'lucky-items'],
    token_cost: 4,
    description: '연애 성공 패키지',
    bundle_type: 'lifestyle'
  },
  health_life_bundle: {
    fortune_types: ['health', 'biorhythm', 'lucky-food', 'lucky-fitness'],
    token_cost: 3,
    description: '건강 라이프 패키지',
    bundle_type: 'lifestyle'
  },
  
  // 의사결정 번들
  major_decision_bundle: {
    fortune_types: ['destiny', 'daily', 'hourly', 'avoid-people', 'lucky-place'],
    token_cost: 4,
    description: '중대 결정 패키지',
    bundle_type: 'decision'
  },
  investment_decision_bundle: {
    fortune_types: ['wealth', 'lucky-investment', 'lucky-stock', 'biorhythm'],
    token_cost: 3,
    description: '투자 결정 패키지',
    bundle_type: 'decision'
  },
  
  // 깊이 있는 분석 번들
  self_discovery_bundle: {
    fortune_types: ['saju', 'personality', 'talent', 'mbti', 'past-life'],
    token_cost: 8,
    description: '자아 발견 패키지',
    bundle_type: 'deep_analysis'
  },
  future_planning_bundle: {
    fortune_types: ['yearly', 'monthly', 'weekly', 'timeline', 'destiny'],
    token_cost: 6,
    description: '미래 계획 패키지',
    bundle_type: 'deep_analysis'
  },
  
  // 활동별 번들
  sports_bundle: {
    fortune_types: ['lucky-golf', 'lucky-tennis', 'lucky-running', 'biorhythm'],
    token_cost: 3,
    description: '스포츠 성공 패키지',
    bundle_type: 'activity'
  },
  social_bundle: {
    fortune_types: ['daily', 'lucky-outfit', 'lucky-place', 'avoid-people'],
    token_cost: 2,
    description: '소셜 활동 패키지',
    bundle_type: 'activity'
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

    // 사용자 인증
    const authHeader = req.headers.get("Authorization");
    const { user, error: authError } = await authenticateUser(supabase, authHeader);
    if (authError) {
      return new Response(
        JSON.stringify({ error: authError }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 401 }
      );
    }

    // 요청 데이터 파싱
    const { package_type, custom_fortune_types, user_profile, additional_context, get_recommendations } = await req.json();
    
    // 번들 추천 요청 처리
    if (get_recommendations) {
      const recommendations = recommendBundle(user_profile || {}, new Date());
      return new Response(
        JSON.stringify({ 
          recommendations,
          packages: Object.entries(BATCH_PACKAGES)
            .filter(([key]) => recommendations.some(r => r.includes(key)))
            .map(([key, pkg]) => ({ key, ...pkg }))
        }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 200 }
      );
    }

    // 패키지 또는 커스텀 운세 타입 확인
    let fortuneTypes: string[];
    let tokenCost: number;

    if (package_type && BATCH_PACKAGES[package_type]) {
      // 사전 정의된 패키지 사용
      const selectedPackage = BATCH_PACKAGES[package_type];
      fortuneTypes = selectedPackage.fortune_types;
      tokenCost = selectedPackage.token_cost;
    } else if (custom_fortune_types && Array.isArray(custom_fortune_types)) {
      // 커스텀 운세 타입 사용
      fortuneTypes = custom_fortune_types;
      // 개별 토큰 비용의 50% 할인 적용
      tokenCost = Math.ceil(
        fortuneTypes.reduce((sum, type) => sum + (FORTUNE_TOKEN_COSTS[type] || 2), 0) * 0.5
      );
    } else {
      return new Response(
        JSON.stringify({ error: "패키지 타입 또는 운세 타입을 지정해주세요" }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 400 }
      );
    }

    // 토큰 잔액 확인
    const { hasBalance, currentBalance } = await checkTokenBalance(supabase, user.id, tokenCost);
    if (!hasBalance) {
      return new Response(
        JSON.stringify({ 
          error: "토큰이 부족합니다", 
          required: tokenCost,
          current: currentBalance 
        }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 402 }
      );
    }

    // 프로필 데이터 가져오기 (제공되지 않은 경우)
    let profile = user_profile;
    if (!profile) {
      const { data: profileData } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', user.id)
        .single();
      
      profile = profileData;
    }

    // 캐시된 운세 확인
    const today = new Date().toISOString().split('T')[0];
    const cachedFortunes: any[] = [];
    const fortunesToGenerate: string[] = [];

    for (const fortuneType of fortuneTypes) {
      // 캐시 키 생성
      const cacheKey = `${fortuneType}_${user.id}_${today}`;
      
      // 캐시 확인
      const { data: cached } = await supabase
        .from('fortune_cache')
        .select('*')
        .eq('cache_key', cacheKey)
        .gte('expires_at', new Date().toISOString())
        .single();

      if (cached) {
        cachedFortunes.push({
          type: fortuneType,
          data: cached.fortune_data,
          cached: true
        });
      } else {
        fortunesToGenerate.push(fortuneType);
      }
    }

    // 캐시되지 않은 운세들을 배치로 생성
    let generatedFortunes: any[] = [];
    if (fortunesToGenerate.length > 0) {
      let batchPrompt: string;
      
      // 번들 타입에 따른 최적화된 프롬프트 사용
      if (package_type && BATCH_PACKAGES[package_type]) {
        const selectedPackage = BATCH_PACKAGES[package_type];
        if (selectedPackage.bundle_type) {
          try {
            batchPrompt = generateBatchPrompt(
              selectedPackage.bundle_type,
              package_type.replace('_bundle', ''),
              profile,
              additional_context
            );
          } catch (e) {
            // 폴백: 기본 배치 프롬프트 사용
            batchPrompt = getDefaultBatchPrompt(fortunesToGenerate, profile);
          }
        } else {
          batchPrompt = getDefaultBatchPrompt(fortunesToGenerate, profile);
        }
      } else {
        // 커스텀 운세의 경우 기본 배치 프롬프트 사용
        batchPrompt = getDefaultBatchPrompt(fortunesToGenerate, profile);
      }

      try {
        // OpenAI API 호출 (배치)
        const batchResult = await generateFortuneWithAI(batchPrompt, 'batch');
        const parsedResults = JSON.parse(batchResult);

        // 결과를 개별 운세로 분리
        for (const fortuneType of fortunesToGenerate) {
          if (parsedResults[fortuneType]) {
            const fortuneData = parsedResults[fortuneType];
            
            // 캐시 저장
            const cacheKey = `${fortuneType}_${user.id}_${today}`;
            const expiresAt = getExpirationTime(fortuneType);
            
            await supabase
              .from('fortune_cache')
              .upsert({
                cache_key: cacheKey,
                fortune_type: fortuneType,
                user_id: user.id,
                fortune_data: fortuneData,
                expires_at: expiresAt
              });

            // 히스토리 저장
            await supabase
              .from('fortunes')
              .insert({
                user_id: user.id,
                fortune_type: fortuneType,
                fortune_data: fortuneData,
                tokens_used: 0, // 배치에서는 개별 토큰 계산 안함
                batch_id: `batch_${Date.now()}`
              });

            generatedFortunes.push({
              type: fortuneType,
              data: fortuneData,
              cached: false
            });
          }
        }
      } catch (error) {
        console.error('배치 생성 실패:', error);
        
        // 폴백: 개별 생성
        for (const fortuneType of fortunesToGenerate) {
          try {
            const individualPrompt = getIndividualPrompt(fortuneType, profile);
            const fortuneData = await generateFortuneWithAI(individualPrompt, fortuneType);
            
            generatedFortunes.push({
              type: fortuneType,
              data: JSON.parse(fortuneData),
              cached: false
            });
          } catch (individualError) {
            console.error(`${fortuneType} 생성 실패:`, individualError);
          }
        }
      }
    }

    // 토큰 차감 (새로 생성된 운세가 있는 경우만)
    if (generatedFortunes.length > 0) {
      await deductTokens(supabase, user.id, tokenCost);
    }

    // 모든 운세 결합
    const allFortunes = [...cachedFortunes, ...generatedFortunes];

    // 배치 결과 저장
    if (package_type) {
      await supabase
        .from('fortune_batches')
        .insert({
          user_id: user.id,
          batch_type: package_type,
          fortune_data: allFortunes,
          tokens_used: generatedFortunes.length > 0 ? tokenCost : 0
        });
    }

    return new Response(
      JSON.stringify({
        success: true,
        package: package_type || 'custom',
        fortunes: allFortunes,
        tokens_used: generatedFortunes.length > 0 ? tokenCost : 0,
        cached_count: cachedFortunes.length,
        generated_count: generatedFortunes.length
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

// 운세 타입별 만료 시간 계산
function getExpirationTime(fortuneType: string): string {
  const now = new Date();
  
  // 평생 운세
  if (['saju', 'traditional-saju', 'past-life', 'destiny', 'personality', 'talent'].includes(fortuneType)) {
    now.setFullYear(now.getFullYear() + 1); // 1년
  }
  // 월간 운세
  else if (['monthly', 'zodiac', 'blood-type', 'mbti', 'lucky-color', 'lucky-number'].includes(fortuneType)) {
    now.setDate(now.getDate() + 30); // 30일
  }
  // 주간 운세
  else if (['weekly', 'biorhythm', 'career', 'wealth', 'business'].includes(fortuneType)) {
    now.setDate(now.getDate() + 7); // 7일
  }
  // 일일 운세
  else {
    now.setDate(now.getDate() + 1); // 24시간
  }
  
  return now.toISOString();
}

// 기본 배치 프롬프트 생성 함수
function getDefaultBatchPrompt(fortuneTypes: string[], profile: any): string {
  return `
다음 사용자의 ${fortuneTypes.length}개 운세를 한 번에 생성해주세요.

사용자 정보:
- 이름: ${profile.name || '사용자'}
- 생년월일: ${profile.birth_date || ''}
- 성별: ${profile.gender || ''}
- MBTI: ${profile.mbti || ''}

생성할 운세 목록:
${fortuneTypes.map((type, idx) => `${idx + 1}. ${type}`).join('\n')}

각 운세별로 다음 형식으로 작성해주세요:
{
  "${fortuneTypes[0]}": {
    "summary": "한 줄 요약",
    "overall_score": 점수(0-100),
    "description": "상세 운세 (최소 200자)",
    "lucky_items": {
      "color": "행운의 색",
      "number": 행운의 숫자,
      "direction": "행운의 방향",
      "time": "행운의 시간"
    },
    "advice": "조언",
    "caution": "주의사항"
  },
  ...
}

각 운세는 개인화되고 구체적이며 긍정적인 내용으로 작성해주세요.
`;
}

// 개별 운세 프롬프트 생성 (폴백용)
function getIndividualPrompt(fortuneType: string, profile: any): string {
  const baseInfo = `
사용자 정보:
- 이름: ${profile.name || '사용자'}
- 생년월일: ${profile.birth_date || ''}
- 성별: ${profile.gender || ''}
- MBTI: ${profile.mbti || ''}
`;

  const responseFormat = `
응답 형식 (JSON):
{
  "summary": "한 줄 요약",
  "overall_score": 점수(0-100),
  "description": "상세 운세 (최소 200자)",
  "lucky_items": {
    "color": "행운의 색",
    "number": 행운의 숫자,
    "direction": "행운의 방향",
    "time": "행운의 시간"
  },
  "advice": "조언",
  "caution": "주의사항"
}
`;

  return `당신은 전문 운세 상담사입니다.
${baseInfo}

${fortuneType} 운세를 작성해주세요.
${responseFormat}

긍정적이고 희망적인 메시지를 전달하되, 구체적이고 실용적인 조언을 포함해주세요.`;
}