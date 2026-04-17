/**
 * AI 캐릭터 자동 생성 Edge Function
 *
 * 이름 + 성격 키워드만으로 완성된 캐릭터 설정을 생성.
 *
 * @endpoint POST /generate-character
 * @requestBody { name: string, personalityTags: string[], gender?: string, relationship?: string }
 * @response { scenario, memoryNote, stylePreset, interestTags, openingLine, shortDescription }
 */

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { LLMFactory } from "../_shared/llm/factory.ts";
import { corsHeaders, handleCors } from "../_shared/cors.ts";

serve(async (req: Request) => {
  if (req.method === "OPTIONS") return handleCors(req);

  try {
    const { name, personalityTags, gender, relationship } = await req.json();

    if (!name || !Array.isArray(personalityTags) || personalityTags.length === 0) {
      return new Response(
        JSON.stringify({ error: "name and personalityTags are required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const llm = LLMFactory.createFromConfig("character-chat");

    const genderLabel = gender === "male" ? "남성" : gender === "female" ? "여성" : "성별 미정";
    const relLabel = relationship === "crush" ? "썸 타는 사이"
      : relationship === "partner" ? "연인"
      : relationship === "colleague" ? "동료"
      : "친구";

    const response = await llm.generate(
      [
        {
          role: "system",
          content: `너는 AI 캐릭터 설정 생성기다. 유저가 이름과 성격 키워드를 주면, 그 캐릭터의 배경 스토리, 시나리오, 관심사, 말투 스타일, 첫 인사를 만들어줘.

반드시 JSON만 출력해. 마크다운 금지.

출력 스키마:
{
  "scenario": "2-3문장 배경 시나리오",
  "memoryNote": "캐릭터가 기억할 핵심 설정 1-2줄",
  "stylePreset": "warm|calm|chic|dreamy 중 하나",
  "interestTags": ["관심사1", "관심사2", "관심사3"],
  "openingLine": "캐릭터의 첫 인사 메시지 (자연스럽고 캐릭터답게)",
  "shortDescription": "한 줄 캐릭터 소개"
}

규칙:
- 캐릭터가 실제 사람처럼 느껴져야 함
- 성격 키워드를 자연스럽게 반영
- 시나리오는 일상적이고 공감가능한 설정
- 첫 인사는 캐릭터 성격이 묻어나게
- 한국어로 작성`,
        },
        {
          role: "user",
          content: `이름: ${name}
성격: ${personalityTags.join(", ")}
성별: ${genderLabel}
관계: ${relLabel}

이 정보로 캐릭터 설정을 만들어줘.`,
        },
      ],
      { temperature: 0.8, maxTokens: 800, jsonMode: true },
    );

    let parsed: Record<string, unknown>;
    try {
      parsed = JSON.parse(response.content);
    } catch {
      const fenced = response.content.match(/```(?:json)?\s*([\s\S]*?)\s*```/i);
      parsed = fenced?.[1] ? JSON.parse(fenced[1].trim()) : {};
    }

    return new Response(
      JSON.stringify({
        success: true,
        ...parsed,
        meta: {
          provider: response.provider,
          model: response.model,
          latencyMs: response.latency,
        },
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (error) {
    console.error("[generate-character] Error:", error);
    return new Response(
      JSON.stringify({ error: String(error) }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
