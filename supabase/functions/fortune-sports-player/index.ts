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

    const { playerName, sport, team, position, birthDate, name } = await req.json();
    
    if (!playerName || !sport) {
      throw new Error("Player and sport information required");
    }

    // 사용자 정보 가져오기
    const { data: profile } = await supabase
      .from("user_profiles")
      .select("*")
      .eq("user_id", userId)
      .single();

    const userBirthDate = birthDate || profile?.birth_date;
    const userName = name || profile?.name || "선수";

    const prompt = `${userName}님이 ${playerName} 선수(${sport}, ${position})의 스타일을 참고하여 운동하는 오늘의 운세를 알려주세요.
생년월일: ${userBirthDate}
참고 선수: ${playerName} (${team}, ${position})

다음 내용을 포함해주세요:
1. 오늘의 운동 운세 (전반적인 컨디션과 운동 효과)
2. 체력 상태 분석 (체력, 지구력, 순발력)
3. 부상 예방 지수와 주의사항
4. 경기력 예측 (경기나 운동 시 발휘할 수 있는 능력)
5. 팀워크 운 (함께 운동하는 사람들과의 호흡)
6. 훈련 효율성 (오늘 훈련의 효과와 집중도)
7. 경기력 분석 (체력/집중력/반응속도/판단력/정신력 각 100점 만점)
8. 훈련 팁 3가지
9. 멘탈 코칭 (동기부여와 마인드셋)
10. ${playerName} 선수의 강점 중 오늘 배울 점

JSON 형식으로 응답해주세요.`;

    // OpenAI API 호출
    const fortuneResult = await generateFortune(prompt, "sports-player");

    // 결과 파싱
    let parsedResult;
    try {
      parsedResult = JSON.parse(fortuneResult);
    } catch (e) {
      parsedResult = {
        fortune: fortuneResult,
        todaysFortune: "좋은 컨디션으로 운동 효과가 높은 날"
      };
    }

    // 기본 구조 보장
    const result = {
      playerName,
      sport,
      team,
      position,
      todaysFortune: parsedResult.todaysFortune || parsedResult['오늘의 운동 운세'] || 
        "전반적으로 좋은 컨디션을 유지할 수 있는 날입니다",
      physicalCondition: parsedResult.physicalCondition || parsedResult['체력 상태'] || {
        overall: "양호",
        stamina: "지구력이 좋은 상태",
        power: "순발력 발휘 가능",
        flexibility: "유연성 관리 필요"
      },
      injuryPrevention: parsedResult.injuryPrevention || parsedResult['부상 예방 지수'] || {
        score: 85,
        caution: "충분한 워밍업 필수",
        riskAreas: ["무릎", "어깨"],
        prevention: "스트레칭과 쿨다운 중요"
      },
      performancePrediction: parsedResult.performancePrediction || parsedResult['경기력 예측'] || {
        level: "상급",
        description: "평소보다 높은 경기력 발휘 가능",
        peakTime: "오후 3-6시",
        focus: "집중력이 높아 기술 훈련에 적합"
      },
      teamworkLuck: parsedResult.teamworkLuck || parsedResult['팀워크 운'] || {
        score: 88,
        chemistry: "팀원들과 호흡이 잘 맞는 날",
        communication: "의사소통이 원활함",
        leadership: "리더십 발휘 가능"
      },
      trainingEfficiency: parsedResult.trainingEfficiency || parsedResult['훈련 효율성'] || {
        effectiveness: "매우 높음",
        learningRate: "새로운 기술 습득에 유리",
        muscleMemory: "근육 기억력 향상",
        recovery: "회복 속도 빠름"
      },
      performanceAnalysis: parsedResult.performanceAnalysis || parsedResult['경기력 분석'] || {
        stamina: Math.floor(Math.random() * 20) + 80,
        focus: Math.floor(Math.random() * 20) + 80,
        reaction: Math.floor(Math.random() * 20) + 80,
        decision: Math.floor(Math.random() * 20) + 80,
        mental: Math.floor(Math.random() * 20) + 80
      },
      trainingTips: parsedResult.trainingTips || parsedResult['훈련 팁'] || [
        "오늘은 기술 훈련에 집중하면 좋은 성과",
        "팀 훈련보다 개인 기량 향상에 유리",
        "새로운 동작이나 전술 시도해보기"
      ],
      mentalCoaching: parsedResult.mentalCoaching || parsedResult['멘탈 코칭'] || {
        motivation: "작은 성공이 큰 변화를 만듭니다",
        mindset: "과정을 즐기면 결과는 따라옵니다",
        visualization: "성공적인 플레이를 머릿속에 그려보세요",
        confidence: "자신감을 가지고 도전하세요"
      },
      playerStrength: parsedResult.playerStrength || 
        parsedResult[`${playerName} 선수의 강점`] || 
        `${playerName} 선수의 꾸준함과 프로정신을 배워보세요`,
      rawFortune: fortuneResult
    };

    // 운세 결과 저장
    await supabase.from("fortune_results").insert({
      user_id: userId,
      fortune_type: "sports-player",
      result,
      created_at: new Date().toISOString(),
    });

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error) {
    console.error("Error in fortune-sports-player function:", error);
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 400,
      }
    );
  }
});