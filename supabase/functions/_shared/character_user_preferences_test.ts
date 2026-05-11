import {
  assertEquals,
  assertFalse,
  assertStringIncludes,
} from "https://deno.land/std@0.224.0/assert/mod.ts";
import { buildConversationPreferencePrompt } from "./character_user_preferences.ts";

Deno.test("buildConversationPreferencePrompt reflects onboarding relationship, tone, and topics", () => {
  const prompt = buildConversationPreferencePrompt({
    relationship: "멘토",
    tone: {
      formality: 2,
      warmth: 0,
      length: 2,
    },
    topics: ["감정", "일/커리어"],
  });

  assertStringIncludes(prompt, "[CONVERSATION PREFERENCES - 온보딩 대화스킬 반영]");
  assertStringIncludes(prompt, "관계 기대값: 멘토");
  assertStringIncludes(prompt, "말투: 반말에 가깝게");
  assertStringIncludes(prompt, "온도: 따뜻하고 공감 먼저");
  assertStringIncludes(prompt, "길이: 충분히 자세하게");
  assertStringIncludes(prompt, "관심 주제: 감정, 일/커리어");
});

Deno.test("buildConversationPreferencePrompt returns empty string without usable preferences", () => {
  assertEquals(buildConversationPreferencePrompt(), "");
  assertEquals(buildConversationPreferencePrompt({ relationship: "   " }), "");
  assertEquals(buildConversationPreferencePrompt({ topics: ["", "   "] }), "");
});

Deno.test("buildConversationPreferencePrompt supports relationship-only, tone-only, and topics-only inputs", () => {
  const relationshipOnly = buildConversationPreferencePrompt({ relationship: "친구" });
  assertStringIncludes(relationshipOnly, "관계 기대값: 친구");
  assertFalse(relationshipOnly.includes("말투:"));
  assertFalse(relationshipOnly.includes("관심 주제:"));

  const toneOnly = buildConversationPreferencePrompt({
    tone: { formality: 0, warmth: 2, length: 0 },
  });
  assertStringIncludes(toneOnly, "말투: 존댓말을 기본으로");
  assertStringIncludes(toneOnly, "온도: 빙빙 돌리지 말고");
  assertStringIncludes(toneOnly, "길이: 짧고 리듬감 있게");

  const topicsOnly = buildConversationPreferencePrompt({ topics: ["연애", "자기계발"] });
  assertStringIncludes(topicsOnly, "관심 주제: 연애, 자기계발");
  assertFalse(topicsOnly.includes("관계 기대값:"));
});

Deno.test("buildConversationPreferencePrompt trims and caps topics", () => {
  const prompt = buildConversationPreferencePrompt({
    topics: [" 감정 ", "", "커리어", "가족", "재테크", "건강", "취미", "여행", "초과"],
  });

  assertStringIncludes(prompt, "관심 주제: 감정, 커리어, 가족, 재테크, 건강, 취미");
  assertFalse(prompt.includes("여행"));
  assertFalse(prompt.includes("초과"));
});

Deno.test("buildConversationPreferencePrompt falls back invalid tone levels to middle guidance", () => {
  const prompt = buildConversationPreferencePrompt({
    tone: {
      formality: 3 as never,
      warmth: "1" as never,
      length: null as never,
    },
  });

  assertStringIncludes(prompt, "말투: 너무 딱딱하지 않은 자연스러운 반존대/친근체");
  assertStringIncludes(prompt, "온도: 공감과 현실적인 코멘트를 균형 있게");
  assertStringIncludes(prompt, "길이: 중간 길이, 핵심 반응 후 한두 문장 보태기");
});
