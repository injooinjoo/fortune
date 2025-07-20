import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.21.0";
import { corsHeaders } from "../_shared/cors.ts";
import { verifyToken } from "../_shared/auth.ts";
import { generateFortune } from "../_shared/openai.ts";

const PLATFORMS = ['youtube', 'streaming', 'instagram', 'tiktok'];

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      throw new Error("No authorization header");
    }

    const token = authHeader.replace("Bearer ", "");
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      {
        global: { headers: { Authorization: authHeader } },
      }
    );

    const { userId, error: authError } = await verifyToken(supabase, token);
    if (authError) throw authError;

    const { platform, influencer, birthDate, name } = await req.json();
    
    if (!platform || !PLATFORMS.includes(platform)) {
      throw new Error("Invalid platform specified");
    }

    if (!influencer) {
      throw new Error("Influencer not selected");
    }

    // 사용자 정보 가져오기
    const { data: profile } = await supabase
      .from("user_profiles")
      .select("*")
      .eq("user_id", userId)
      .single();

    const userBirthDate = birthDate || profile?.birth_date;
    const userName = name || profile?.name || "크리에이터";

    // 플랫폼별 프롬프트 생성
    const platformContext = {
      youtube: "유튜브 크리에이터",
      streaming: "스트리머",
      instagram: "인스타그래머",
      tiktok: "틱톡커"
    };

    const prompt = `${userName}님이 ${influencer}님처럼 성공적인 ${platformContext[platform]}가 되기 위한 오늘의 운세를 알려주세요.
생년월일: ${userBirthDate}

다음 내용을 포함해주세요:
1. 콘텐츠 성공 예측 (대박 예상/성공 가능/평범함/주의 필요)
2. 구독자/팔로워 증가 예측 (일간/주간/월간 증가율)
3. 추천 콘텐츠 주제 3가지
4. 최적 업로드/방송 시간대
5. 협업 운 (다른 크리에이터와의 콜라보 가능성)
6. 수익화 전망 (광고, 후원, 굿즈 등)
7. 오늘의 성공 팁 3가지
8. 피해야 할 실수나 주의사항
9. ${influencer}님의 성공 전략 중 오늘 참고할 점

JSON 형식으로 응답해주세요. 각 항목은 구체적이고 실용적인 조언을 포함해야 합니다.`;

    // OpenAI API 호출
    const fortuneResult = await generateFortune(prompt, "influencer");

    // 결과 파싱
    let parsedResult;
    try {
      parsedResult = JSON.parse(fortuneResult);
    } catch (e) {
      parsedResult = {
        fortune: fortuneResult,
        contentSuccess: "성공 가능",
        subscriberGrowth: "일간 +100명, 주간 +1000명 예상"
      };
    }

    // 기본 구조 보장
    const result = {
      platform,
      influencer,
      contentSuccess: parsedResult.contentSuccess || parsedResult['콘텐츠 성공 예측'] || "성공 가능",
      subscriberGrowth: parsedResult.subscriberGrowth || parsedResult['구독자 증가 예측'] || {
        daily: "+100",
        weekly: "+1000",
        monthly: "+5000"
      },
      recommendedContent: parsedResult.recommendedContent || parsedResult['추천 콘텐츠'] || [
        "일상 브이로그",
        "챌린지 콘텐츠",
        "Q&A/소통 콘텐츠"
      ],
      bestUploadTime: parsedResult.bestUploadTime || parsedResult['최적 업로드 시간대'] || "오후 6시-8시",
      collaborationLuck: parsedResult.collaborationLuck || parsedResult['협업 운'] || {
        score: 85,
        description: "좋은 협업 기회가 찾아올 수 있는 날입니다"
      },
      monetizationOutlook: parsedResult.monetizationOutlook || parsedResult['수익화 전망'] || {
        advertising: "광고 수익 증가 예상",
        sponsorship: "브랜드 협찬 가능성 높음",
        merchandise: "굿즈 판매 적기"
      },
      tips: parsedResult.tips || parsedResult['오늘의 성공 팁'] || [
        "일관된 업로드 스케줄 유지하기",
        "댓글 소통 적극적으로 하기",
        "트렌드 파악하고 빠르게 대응하기"
      ],
      warnings: parsedResult.warnings || parsedResult['피해야 할 실수'] || [
        "논란이 될 수 있는 주제 피하기",
        "과도한 광고 콘텐츠 자제"
      ],
      influencerStrategy: parsedResult.influencerStrategy || parsedResult[`${influencer}님의 성공 전략`] || 
        `${influencer}님처럼 진정성 있는 콘텐츠로 팬들과 소통하세요`,
      performanceScore: {
        content: Math.floor(Math.random() * 20) + 80,
        engagement: Math.floor(Math.random() * 20) + 80,
        growth: Math.floor(Math.random() * 20) + 80,
        monetization: Math.floor(Math.random() * 20) + 80,
        creativity: Math.floor(Math.random() * 20) + 80
      },
      rawFortune: fortuneResult
    };

    // 운세 결과 저장
    await supabase.from("fortune_results").insert({
      user_id: userId,
      fortune_type: "influencer",
      result,
      created_at: new Date().toISOString(),
    });

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error) {
    console.error("Error in fortune-influencer function:", error);
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 400,
      }
    );
  }
});