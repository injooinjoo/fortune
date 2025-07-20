import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.21.0";
import { corsHeaders } from "../_shared/cors.ts";
import { verifyToken } from "../_shared/auth.ts";
import { generateFortune } from "../_shared/openai.ts";

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

    const { politician, party, birthDate, name } = await req.json();
    
    if (!politician) {
      throw new Error("Politician not selected");
    }

    // 사용자 정보 가져오기
    const { data: profile } = await supabase
      .from("user_profiles")
      .select("*")
      .eq("user_id", userId)
      .single();

    const userBirthDate = birthDate || profile?.birth_date;
    const userName = name || profile?.name || "시민";

    const prompt = `${userName}님이 ${politician}님의 정치 스타일을 참고하여 사회 활동과 리더십을 발휘하기 위한 오늘의 운세를 알려주세요.
생년월일: ${userBirthDate}
참고 정치인: ${politician} (${party})

다음 내용을 포함해주세요:
1. 정치 성향 분석 (진보/중도/보수 성향과 특징)
2. 리더십 스타일 (카리스마형/소통형/실무형/비전형)
3. 오늘의 정치 운세 (사회 활동, 의견 표현, 영향력)
4. 사회 이슈 관심도 (어떤 분야에 관심을 가져야 할지)
5. 대인 관계 운 (네트워킹, 협력 관계)
6. 설득력 지수 (100점 만점, 설득 전략)
7. 정치적 조언 (3가지 구체적 조언)
8. 경력 전망 (시민 참여부터 정치 활동까지)
9. ${politician}님의 강점 중 오늘 배울 점

JSON 형식으로 응답해주세요. 편향되지 않고 균형잡힌 시각으로 작성해주세요.`;

    // OpenAI API 호출
    const fortuneResult = await generateFortune(prompt, "politician");

    // 결과 파싱
    let parsedResult;
    try {
      parsedResult = JSON.parse(fortuneResult);
    } catch (e) {
      parsedResult = {
        fortune: fortuneResult,
        politicalTendency: "중도 성향",
        leadershipStyle: "소통형 리더십"
      };
    }

    // 기본 구조 보장
    const result = {
      politician,
      party,
      politicalTendency: parsedResult.politicalTendency || parsedResult['정치 성향 분석'] || {
        tendency: "중도",
        description: "균형잡힌 시각으로 다양한 의견을 수용하는 성향"
      },
      leadershipStyle: parsedResult.leadershipStyle || parsedResult['리더십 스타일'] || {
        type: "소통형",
        description: "경청과 대화를 통해 합의를 이끌어내는 스타일"
      },
      todaysPoliticalFortune: parsedResult.todaysPoliticalFortune || parsedResult['오늘의 정치 운세'] || {
        overall: "긍정적",
        activity: "사회 활동에 적극 참여하기 좋은 날",
        expression: "의견을 명확히 표현하면 좋은 반응을 얻을 수 있음",
        influence: "주변에 긍정적인 영향력을 행사할 수 있는 시기"
      },
      socialIssueInterest: parsedResult.socialIssueInterest || parsedResult['사회 이슈 관심도'] || [
        "환경 보호와 지속가능한 발전",
        "교육 격차 해소",
        "청년 일자리 창출"
      ],
      networkingLuck: parsedResult.networkingLuck || parsedResult['대인 관계 운'] || {
        score: 85,
        description: "새로운 인맥을 형성하기 좋은 시기",
        advice: "다양한 배경의 사람들과 교류하세요"
      },
      persuasionIndex: parsedResult.persuasionIndex || parsedResult['설득력 지수'] || {
        score: 78,
        strategy: "논리와 감성을 균형있게 사용하여 설득력 향상",
        tips: [
          "구체적인 사례와 데이터 활용",
          "상대방의 입장 먼저 이해하기",
          "공감대 형성 후 의견 제시"
        ]
      },
      politicalAdvice: parsedResult.politicalAdvice || parsedResult['정치적 조언'] || {
        "시민 참여": "지역 사회 봉사나 시민 단체 활동 시작하기",
        "의견 표현": "SNS나 커뮤니티에서 건설적인 의견 나누기",
        "학습과 성장": "정치 관련 서적이나 강연 통해 식견 넓히기"
      },
      careerPath: parsedResult.careerPath || parsedResult['경력 전망'] || {
        path: "시민 활동가 → 지역 활동가 → 정책 제안자 → 공직 진출",
        milestone: "3년 내 지역 사회에서 인정받는 활동가로 성장 가능",
        potential: "사회 변화를 이끌 수 있는 잠재력 보유"
      },
      politicianStrength: parsedResult.politicianStrength || 
        parsedResult[`${politician}님의 강점`] || 
        `${politician}님의 소통 능력과 추진력을 배워 실천하세요`,
      scores: {
        leadership: Math.floor(Math.random() * 20) + 80,
        communication: Math.floor(Math.random() * 20) + 80,
        vision: Math.floor(Math.random() * 20) + 80,
        execution: Math.floor(Math.random() * 20) + 80,
        empathy: Math.floor(Math.random() * 20) + 80
      },
      rawFortune: fortuneResult
    };

    // 운세 결과 저장
    await supabase.from("fortune_results").insert({
      user_id: userId,
      fortune_type: "politician",
      result,
      created_at: new Date().toISOString(),
    });

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error) {
    console.error("Error in fortune-politician function:", error);
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 400,
      }
    );
  }
});