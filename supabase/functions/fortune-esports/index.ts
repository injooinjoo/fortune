import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.21.0";
import { corsHeaders } from "../_shared/cors.ts";
import { verifyToken } from "../_shared/auth.ts";
import { generateFortune } from "../_shared/openai.ts";

const ESPORTS_GAMES = ['lol', 'valorant', 'overwatch', 'pubg', 'fifa'];

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

    const { game, birthDate, name } = await req.json();
    
    if (!game || !ESPORTS_GAMES.includes(game)) {
      throw new Error("Invalid game specified");
    }

    // 사용자 정보 가져오기
    const { data: profile } = await supabase
      .from("user_profiles")
      .select("*")
      .eq("user_id", userId)
      .single();

    const userBirthDate = birthDate || profile?.birth_date;
    const userName = name || profile?.name || "게이머";

    // 게임별 프롬프트 생성
    const gamePrompts = {
      lol: `리그 오브 레전드 플레이어 ${userName}님의 오늘 게임 운세를 알려주세요.
생년월일: ${userBirthDate}

다음 내용을 포함해주세요:
1. 오늘의 승률 예측 (대승 예상/승리 가능/접전 예상/패배 주의)
2. 예상 KDA
3. 추천 포지션과 챔피언 3개
4. 피해야 할 챔피언 2개
5. 최적의 플레이 시간대
6. 팀워크 점수 (100점 만점)
7. 오늘의 게임 팁 3가지

JSON 형식으로 응답해주세요.`,

      valorant: `발로란트 플레이어 ${userName}님의 오늘 게임 운세를 알려주세요.
생년월일: ${userBirthDate}

다음 내용을 포함해주세요:
1. 오늘의 승률 예측 (대승 예상/승리 가능/접전 예상/패배 주의)
2. 예상 헤드샷 확률
3. 추천 요원 3개
4. 피해야 할 요원 2개
5. 최적의 플레이 시간대
6. 에임 정확도 점수 (100점 만점)
7. 오늘의 전술 팁 3가지

JSON 형식으로 응답해주세요.`,

      overwatch: `오버워치 플레이어 ${userName}님의 오늘 게임 운세를 알려주세요.
생년월일: ${userBirthDate}

다음 내용을 포함해주세요:
1. 오늘의 승률 예측 (대승 예상/승리 가능/접전 예상/패배 주의)
2. 팀 시너지 점수
3. 추천 영웅 3개와 역할
4. 피해야 할 영웅 2개
5. 최적의 플레이 시간대
6. 팀워크 점수 (100점 만점)
7. 오늘의 팀플레이 팁 3가지

JSON 형식으로 응답해주세요.`,

      pubg: `배틀그라운드 플레이어 ${userName}님의 오늘 게임 운세를 알려주세요.
생년월일: ${userBirthDate}

다음 내용을 포함해주세요:
1. 오늘의 치킨 확률 예측
2. 예상 최종 순위
3. 추천 낙하 지점 3곳
4. 추천 무기 조합
5. 최적의 플레이 시간대
6. 생존력 점수 (100점 만점)
7. 오늘의 생존 팁 3가지

JSON 형식으로 응답해주세요.`,

      fifa: `FIFA 온라인 플레이어 ${userName}님의 오늘 게임 운세를 알려주세요.
생년월일: ${userBirthDate}

다음 내용을 포함해주세요:
1. 오늘의 승률 예측 (대승 예상/승리 가능/접전 예상/패배 주의)
2. 예상 득점
3. 추천 포메이션
4. 추천 전술
5. 최적의 플레이 시간대
6. 컨트롤 정확도 점수 (100점 만점)
7. 오늘의 전술 팁 3가지

JSON 형식으로 응답해주세요.`
    };

    const prompt = gamePrompts[game];
    
    // OpenAI API 호출
    const fortuneResult = await generateFortune(prompt, "lucky-esports");

    // 결과 파싱
    let parsedResult;
    try {
      parsedResult = JSON.parse(fortuneResult);
    } catch (e) {
      parsedResult = {
        fortune: fortuneResult,
        score: Math.floor(Math.random() * 30) + 70 // 70-100 사이의 랜덤 점수
      };
    }

    // 기본 구조 보장
    const result = {
      game,
      winRate: parsedResult.winRate || parsedResult['오늘의 승률 예측'] || "승리 가능",
      score: parsedResult.score || parsedResult['점수'] || 85,
      recommendations: parsedResult.recommendations || {
        characters: parsedResult['추천 챔피언'] || parsedResult['추천 요원'] || parsedResult['추천 영웅'] || [],
        avoidCharacters: parsedResult['피해야 할 챔피언'] || parsedResult['피해야 할 요원'] || parsedResult['피해야 할 영웅'] || [],
        bestTime: parsedResult['최적의 플레이 시간대'] || "오후 8시-10시",
        tips: parsedResult['오늘의 게임 팁'] || parsedResult['오늘의 전술 팁'] || parsedResult['오늘의 팁'] || []
      },
      gameSpecific: {
        kda: parsedResult['예상 KDA'],
        headshotRate: parsedResult['예상 헤드샷 확률'],
        teamSynergy: parsedResult['팀 시너지 점수'],
        chickenRate: parsedResult['오늘의 치킨 확률 예측'],
        expectedGoals: parsedResult['예상 득점'],
        formation: parsedResult['추천 포메이션'],
        tactics: parsedResult['추천 전술'],
        dropZones: parsedResult['추천 낙하 지점'],
        weaponCombo: parsedResult['추천 무기 조합']
      },
      performanceStats: {
        kda: parsedResult.kda || Math.random() * 2 + 2,
        teamwork: parsedResult.teamwork || parsedResult['팀워크 점수'] || Math.floor(Math.random() * 20) + 80,
        focus: parsedResult.focus || Math.floor(Math.random() * 20) + 80,
        reactionSpeed: parsedResult.reactionSpeed || Math.floor(Math.random() * 20) + 80,
        strategy: parsedResult.strategy || Math.floor(Math.random() * 20) + 80
      },
      rawFortune: fortuneResult
    };

    // 운세 결과 저장
    await supabase.from("fortune_results").insert({
      user_id: userId,
      fortune_type: "lucky-esports",
      result,
      created_at: new Date().toISOString(),
    });

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error) {
    console.error("Error in fortune-esports function:", error);
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 400,
      }
    );
  }
});