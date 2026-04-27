/**
 * manseryeok-interpret — SajuResult → LLM 해석 Edge Function.
 *
 * 입력: `{ userId?, sajuData, sections? }` — sajuData는 `@fortune/saju-engine`의
 * `SajuResult` shape을 가정 (unknown으로 받아 런타임 검증).
 * 출력: `InterpretationData` (성격/직업/재물/애정/건강/오늘/대운 10개 + 종합).
 *
 * 설계 원칙:
 * - LLMFactory.createFromConfigAsync('saju-interpret')만 사용 (OpenAI/Gemini 직접 호출 금지)
 * - JSON 파싱 실패 / 구조 이상 시 fallbackInterpretation으로 자연스러운 기본값 반환
 * - 필드 부족한 sajuData도 fallback 경로로 흘러 빈 화면 방지
 */

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { LLMFactory } from "../_shared/llm/factory.ts";
import { buildUserPrompt, SYSTEM_PROMPT } from "./prompts.ts";
import type {
  InterpretationData,
  LuckCycleInterpretation,
  ManseryeokInterpretRequest,
  ManseryeokInterpretResponse,
  SajuDataLite,
} from "./types.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

/** 느슨한 런타임 validator — 필요한 필드가 갖춰져 있으면 SajuDataLite로 승격 */
function toSajuDataLite(input: unknown): SajuDataLite | null {
  if (!input || typeof input !== "object") return null;
  const data = input as Record<string, unknown>;
  const pillars = data.pillars as Record<string, unknown> | undefined;
  const tenGods = data.tenGods as Record<string, unknown> | undefined;
  const elements = data.elements as Record<string, unknown> | undefined;
  const luckCycles = data.luckCycles as Record<string, unknown> | undefined;

  if (!pillars || !tenGods || !elements || !luckCycles) return null;

  const cycles = luckCycles.cycles;
  if (!Array.isArray(cycles) || cycles.length === 0) return null;

  // 최소 필드 존재 체크 (타입 단언은 validator 통과 후에만 신뢰)
  const pillarNames: Array<"year" | "month" | "day" | "hour"> = [
    "year",
    "month",
    "day",
    "hour",
  ];
  for (const name of pillarNames) {
    const pillar = pillars[name] as Record<string, unknown> | undefined;
    if (!pillar) return null;
    const stem = pillar.stem as Record<string, unknown> | undefined;
    const branch = pillar.branch as Record<string, unknown> | undefined;
    if (!stem?.korean || !branch?.korean) return null;
  }

  return input as SajuDataLite;
}

function fallbackInterpretation(saju: SajuDataLite | null): InterpretationData {
  const cycles = saju?.luckCycles.cycles ?? [];
  const luckCycles: LuckCycleInterpretation[] = cycles.slice(0, 10).map(
    (c) => ({
      ageRange: `${c.startAge}~${c.startAge + 9}세`,
      theme: c.tenGod || "변화",
      summary: "이 시기는 새로운 기회와 배움이 함께 찾아오는 때예요.",
    }),
  );

  return {
    overallSummary:
      "균형을 잡아가며 성장하는 사주예요. 꾸준히 나를 돌보면 안정감이 따라와요.",
    personality: {
      summary:
        "겉으로는 차분하지만 속으로는 꽤 단단한 타입이에요. 자기만의 리듬을 지키려 해요.",
      strengths: ["성실함", "책임감", "신중함"],
      challenges: ["때로는 여유도 필요해요", "과몰입 주의"],
    },
    career: {
      summary:
        "꾸준히 쌓아 올리는 타입이라 전문성 있는 분야에서 빛나요.",
      suitableFields: ["기획", "연구", "관리직"],
      advice: "자신의 강점을 살릴 수 있는 분야를 먼저 탐색해 보세요.",
    },
    wealth: {
      summary: "큰 한 방보다 꾸준한 축적이 잘 맞아요.",
      bestPeriods: ["30대 중반", "50대 초반"],
      caution: "무리한 단기 투자는 피하세요.",
    },
    love: {
      summary: "진심으로 대하는 관계를 선호해요. 천천히 가까워지는 편.",
      compatibleTypes: ["차분한 사람", "이해심 깊은 사람"],
      advice: "솔직한 대화가 관계를 단단하게 해요.",
    },
    health: {
      summary:
        "전반적으로 건강한 체질이지만 스트레스 누적에 약한 편이에요.",
      weakPoints: ["소화기", "어깨/목"],
      advice: "규칙적인 가벼운 운동이 도움이 돼요.",
    },
    daily: {
      oneLiner: "오늘은 차분하게 나를 돌아보기 좋은 날이에요.",
      luckyColor: "파랑",
      luckyDirection: "북",
    },
    luckCycles,
  };
}

/** LLM 응답 문자열에서 JSON 블록 추출 (```json ... ``` 래핑 허용) */
function extractJsonBlock(text: string): string | null {
  const fence = text.match(/```(?:json)?\s*([\s\S]*?)```/);
  if (fence && fence[1]) return fence[1].trim();
  const match = text.match(/\{[\s\S]*\}/);
  return match ? match[0] : null;
}

/** LLM 결과 구조 검증 — 필수 필드 누락 시 Error */
function assertInterpretationShape(
  value: unknown,
): asserts value is InterpretationData {
  if (!value || typeof value !== "object") {
    throw new Error("interpretation is not an object");
  }
  const v = value as Record<string, unknown>;
  const required: Array<keyof InterpretationData> = [
    "overallSummary",
    "personality",
    "career",
    "wealth",
    "love",
    "health",
    "daily",
    "luckCycles",
  ];
  for (const key of required) {
    if (!(key in v) || v[key] == null) {
      throw new Error(`missing field: ${key}`);
    }
  }
  if (!Array.isArray(v.luckCycles)) {
    throw new Error("luckCycles must be array");
  }
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const body = (await req.json()) as ManseryeokInterpretRequest;
    const { sajuData } = body;

    if (!sajuData) {
      const errResp: ManseryeokInterpretResponse = {
        success: false,
        error: "sajuData is required",
      };
      return new Response(JSON.stringify(errResp), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const saju = toSajuDataLite(sajuData);

    // sajuData 구조 자체가 깨졌다면 fallback으로 바로 응답
    if (!saju) {
      console.warn(
        "[manseryeok-interpret] invalid sajuData shape — using fallback",
      );
      const resp: ManseryeokInterpretResponse = {
        success: true,
        data: fallbackInterpretation(null),
      };
      return new Response(JSON.stringify(resp), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    let interpretation: InterpretationData;
    try {
      const llm = await LLMFactory.createFromConfigAsync("saju-interpret");
      const userPrompt = buildUserPrompt(saju);

      console.log("🔮 [manseryeok-interpret] LLM 호출 시작");

      const response = await llm.generate(
        [
          { role: "system", content: SYSTEM_PROMPT },
          { role: "user", content: userPrompt },
        ],
        {
          temperature: 0.7,
          maxTokens: 2500,
          jsonMode: true,
        },
      );

      const jsonBlock = extractJsonBlock(response.content);
      if (!jsonBlock) throw new Error("no JSON block in LLM response");

      const parsed: unknown = JSON.parse(jsonBlock);
      assertInterpretationShape(parsed);
      interpretation = parsed;

      // luckCycles가 10개에 못 미치면 fallback으로 채움
      if (interpretation.luckCycles.length < saju.luckCycles.cycles.length) {
        const fill = fallbackInterpretation(saju).luckCycles.slice(
          interpretation.luckCycles.length,
        );
        interpretation.luckCycles = [...interpretation.luckCycles, ...fill];
      }

      console.log(
        `✅ [manseryeok-interpret] LLM 응답 OK (${response.usage.totalTokens} tokens, ${response.latency}ms)`,
      );
    } catch (err) {
      console.error(
        "[manseryeok-interpret] LLM pipeline failed, using fallback:",
        err,
      );
      interpretation = fallbackInterpretation(saju);
    }

    const resp: ManseryeokInterpretResponse = {
      success: true,
      data: interpretation,
    };
    return new Response(JSON.stringify(resp), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    console.error("[manseryeok-interpret] fatal:", message);
    const resp: ManseryeokInterpretResponse = {
      success: false,
      error: message,
    };
    return new Response(JSON.stringify(resp), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
