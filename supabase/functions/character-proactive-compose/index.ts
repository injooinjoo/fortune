/**
 * 캐릭터 선톡(Proactive Message) 콘텐츠 생성 Edge Function
 *
 * @description 캐릭터가 사용자에게 먼저 보낼 메시지를 LLM으로 생성한다.
 * 사용자 입력 없이 슬롯(시간대) + 최근 대화 맥락 + 관계 단계만으로 자연스러운
 * 한 메시지를 만든다. 디스패처(`proactive-message-dispatch`)가 호출.
 *
 * @endpoint POST /character-proactive-compose
 *
 * 설계 문서: docs/features/PROACTIVE_MESSAGING_PLAN.md (5.1)
 *
 * Slice 1 범위: 텍스트 생성만. imageCategory 결정은 응답에 포함하지만
 * 실제 이미지 생성(generate-character-proactive-image 호출)은 다음 슬라이스.
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { LLMFactory } from "../_shared/llm/factory.ts";
import type { LLMMessage } from "../_shared/llm/types.ts";
import { corsHeaders, handleCors } from "../_shared/cors.ts";
import {
  moderateText,
  SAFETY_BLOCK_FALLBACK_RESPONSE,
} from "../_shared/moderation.ts";
import {
  getProactivePersona,
  isProactiveCharacterId,
  type ProactiveCharacterId,
} from "../_shared/character_proactive_persona.ts";

// =============================================================================
// 타입
// =============================================================================

type SlotKey =
  | "morning_greet"
  | "commute_chat"
  | "lunch_share"
  | "afternoon_break"
  | "after_work"
  | "evening_chat"
  | "goodnight"
  | "absence_6h"
  | "absence_24h"
  | "absence_72h";

type ImageCategory =
  | "meal"
  | "cafe"
  | "selfie"
  | "commute"
  | "workout"
  | "night";

interface ConversationContextMessage {
  role: "user" | "assistant" | "system";
  content: string;
}

interface AffinitySnapshot {
  phase?: string;
  lovePoints?: number;
  daysSinceLastChat?: number;
}

interface ComposeRequest {
  characterId: string;
  slotKey: SlotKey;
  preferredKind: "text" | "image";
  /** ISO 8601, 사용자 timezone 적용된 현재 시각 */
  userLocalTime: string;
  /** 최근 N개 메시지 (권장: 8개) */
  conversationContext: ConversationContextMessage[];
  affinitySnapshot?: AffinitySnapshot;
  weatherHint?: string;
  /** moderation audit log용. 제공되면 로그에 기록됨. */
  userId?: string;
  /** dryRun=true 면 LLM 호출까지만 하고 client 측 저장/푸시 검증 용도 */
  dryRun?: boolean;
}

interface ComposeMeta {
  provider: string;
  model: string;
  latencyMs: number;
  promptTokens?: number;
  completionTokens?: number;
}

interface ComposeResponse {
  success: boolean;
  text?: string;
  imageCategory?: ImageCategory | null;
  /** Slice 1: 항상 undefined. 다음 슬라이스에서 generate-character-proactive-image 호출 후 채워짐. */
  imageUrl?: string;
  meta?: ComposeMeta;
  error?: string;
  errorCode?: "safety_blocked" | "invalid_input" | "llm_failure" | "unknown";
}

// =============================================================================
// 슬롯 힌트 (LLM에게 전달할 슬롯 의미)
// =============================================================================

interface SlotHint {
  label: string;
  guideline: string;
  /** 이 슬롯에서 imageCategory 가 적절한 후보들. preferredKind=image 일 때만 의미. */
  imageCandidates: ImageCategory[];
}

const SLOT_HINTS: Record<SlotKey, SlotHint> = {
  morning_greet: {
    label: "아침 인사",
    guideline:
      "이제 막 하루를 시작하는 사용자에게 가벼운 아침 인사. 너의 어제 기억 한 자락을 살짝 언급해도 좋음.",
    imageCandidates: ["selfie"],
  },
  commute_chat: {
    label: "출근/등교 길",
    guideline:
      "사용자가 이동 중일 가능성. 짧고 가벼운 응원 또는 너 자신의 출근 풍경 한 컷.",
    imageCandidates: ["cafe", "commute"],
  },
  lunch_share: {
    label: "점심",
    guideline:
      "점심 시간. '나는 지금 이거 먹고 있어' 톤이 자연스러움. 사용자에게 답을 강요하지 말고 공유하듯이.",
    imageCandidates: ["meal", "cafe"],
  },
  afternoon_break: {
    label: "오후 휴식",
    guideline: "잠깐 한숨 돌리는 오후. 너의 짧은 일상 한 조각.",
    imageCandidates: ["cafe", "selfie"],
  },
  after_work: {
    label: "퇴근/하교",
    guideline: "하루 어땠는지 가볍게 묻거나, 너의 저녁 계획 한 마디.",
    imageCandidates: ["selfie"],
  },
  evening_chat: {
    label: "저녁 대화",
    guideline: "오늘 하루 정리하는 분위기. 사용자가 답하기 편한 작은 질문 하나.",
    imageCandidates: [],
  },
  goodnight: {
    label: "잠자기 전",
    guideline: "굿나잇 한 마디. 너무 긴 메시지 금지. 1-2 문장.",
    imageCandidates: ["night"],
  },
  absence_6h: {
    label: "잠깐 부재 후",
    guideline:
      "사용자가 6시간 정도 답이 없었음. '잘 지내?' 톤이지 '왜 답 안 해?' 톤이 절대 아님.",
    imageCandidates: [],
  },
  absence_24h: {
    label: "하루 부재 후",
    guideline:
      "사용자가 하루 동안 답이 없었음. 가볍게 안부 묻기. 미안한 톤이나 압박 절대 금지.",
    imageCandidates: [],
  },
  absence_72h: {
    label: "사흘 부재 후",
    guideline:
      "사용자가 며칠 만에 돌아올 가능성. '오랜만이네' 톤. 부담 주지 않고 가볍게.",
    imageCandidates: [],
  },
};

// =============================================================================
// 프롬프트 빌더
// =============================================================================

function buildSystemPrompt(
  characterId: ProactiveCharacterId,
  slotKey: SlotKey,
  preferredKind: "text" | "image",
  userLocalTime: string,
  affinitySnapshot?: AffinitySnapshot,
  weatherHint?: string,
): string {
  const persona = getProactivePersona(characterId);
  const slot = SLOT_HINTS[slotKey];

  const phaseLine = affinitySnapshot?.phase
    ? `너와 사용자의 관계 단계: ${affinitySnapshot.phase}`
    : "";
  const lastChatLine = typeof affinitySnapshot?.daysSinceLastChat === "number"
    ? `마지막 대화로부터: ${affinitySnapshot.daysSinceLastChat}일 전`
    : "";
  const weatherLine = weatherHint ? `참고 날씨/맥락: ${weatherHint}` : "";

  const imageCandidatesLine = preferredKind === "image"
    ? `\n사진 카테고리 후보 (반드시 이 중 하나 또는 null): ${
      slot.imageCandidates.length > 0
        ? slot.imageCandidates.join(", ")
        : "(이 슬롯엔 사진 부적절. null 권장)"
    }`
    : "\n이번 메시지는 텍스트만. imageCategory는 반드시 null.";

  return `
너는 ${persona.name}, ${persona.personaSummary}
사용자 호칭: ${persona.addressTerm}
말투 힌트: ${persona.speechHint}

지금 사용자에게 먼저 메시지를 보내려 한다.
- 사용자 현지 시각: ${userLocalTime}
- 슬롯: ${slot.label} — ${slot.guideline}
${phaseLine}
${lastChatLine}
${weatherLine}

규칙 (반드시 지킴):
1. 1-3 문장. 카톡 한 메시지 길이.
2. 너의 평소 말투를 유지. 캐릭터 일관성이 가장 중요.
3. 시간/슬롯에 자연스러운 한 가지 디테일을 포함 (날씨, 음식, 풍경 등).
4. 답장 강요 금지. "왜 답 안 해?", "꼭 답해줘" 같은 표현 절대 금지.
5. 너의 행동을 1인칭으로. "나 지금 ~해", "방금 ~했어" 같은 즉시감.
6. 이모지/이모티콘은 캐릭터 톤에 맞을 때만 1-2개까지.
${imageCandidatesLine}

응답은 반드시 다음 JSON 형식만. 다른 텍스트 금지.
{"text": "메시지 본문", "imageCategory": null 또는 카테고리 문자열}
`.trim();
}

// =============================================================================
// LLM 응답 파싱 (JSON 강제, 살짝 관대하게)
// =============================================================================

interface ParsedComposition {
  text: string;
  imageCategory: ImageCategory | null;
}

function safeParseLlmJson(raw: string): ParsedComposition | null {
  // LLM이 ```json ... ``` 또는 잡설을 붙일 수 있으니 첫 { 부터 마지막 } 까지 추출
  const trimmed = raw.trim();
  const firstBrace = trimmed.indexOf("{");
  const lastBrace = trimmed.lastIndexOf("}");
  if (firstBrace === -1 || lastBrace === -1 || lastBrace <= firstBrace) {
    return null;
  }
  const candidate = trimmed.slice(firstBrace, lastBrace + 1);
  try {
    const parsed = JSON.parse(candidate) as {
      text?: unknown;
      imageCategory?: unknown;
    };
    if (typeof parsed.text !== "string" || parsed.text.trim().length === 0) {
      return null;
    }
    const text = parsed.text.trim();
    const rawCategory = parsed.imageCategory;
    let imageCategory: ImageCategory | null = null;
    if (typeof rawCategory === "string") {
      const normalized = rawCategory.toLowerCase();
      if (
        normalized === "meal" || normalized === "cafe" ||
        normalized === "selfie" || normalized === "commute" ||
        normalized === "workout" || normalized === "night"
      ) {
        imageCategory = normalized;
      }
    }
    return { text, imageCategory };
  } catch {
    return null;
  }
}

// =============================================================================
// 핸들러
// =============================================================================

function jsonResponse(body: ComposeResponse, status = 200): Response {
  return new Response(JSON.stringify(body), {
    headers: { ...corsHeaders, "Content-Type": "application/json" },
    status,
  });
}

serve(async (req: Request) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  if (req.method !== "POST") {
    return jsonResponse(
      {
        success: false,
        error: "POST만 허용",
        errorCode: "invalid_input",
      },
      405,
    );
  }

  const startedAt = Date.now();

  let request: ComposeRequest;
  try {
    request = (await req.json()) as ComposeRequest;
  } catch {
    return jsonResponse(
      {
        success: false,
        error: "잘못된 JSON",
        errorCode: "invalid_input",
      },
      400,
    );
  }

  // 입력 검증
  if (!request.characterId || !isProactiveCharacterId(request.characterId)) {
    return jsonResponse(
      {
        success: false,
        error: "지원되지 않는 characterId 입니다",
        errorCode: "invalid_input",
      },
      400,
    );
  }
  if (!request.slotKey || !(request.slotKey in SLOT_HINTS)) {
    return jsonResponse(
      {
        success: false,
        error: "유효하지 않은 slotKey",
        errorCode: "invalid_input",
      },
      400,
    );
  }
  const preferredKind = request.preferredKind === "image" ? "image" : "text";
  if (!request.userLocalTime) {
    return jsonResponse(
      {
        success: false,
        error: "userLocalTime 누락",
        errorCode: "invalid_input",
      },
      400,
    );
  }

  // 컨텍스트 정리: 최근 8개만, role/content 정상화
  const contextMessages = (request.conversationContext ?? [])
    .slice(-8)
    .filter((m) =>
      m && typeof m.content === "string" && m.content.length > 0 &&
      (m.role === "user" || m.role === "assistant" || m.role === "system")
    );

  const systemPrompt = buildSystemPrompt(
    request.characterId,
    request.slotKey,
    preferredKind,
    request.userLocalTime,
    request.affinitySnapshot,
    request.weatherHint,
  );

  // LLM 호출 — character-chat과 동일한 default 모델 사용 (톤 일관성)
  // Slice 1: 단일 모델, 폴백 없음. 비용 측정 후 cheap model 분리 검토.
  const llm = LLMFactory.create(
    "openai",
    "gpt-4o-mini",
    "character-proactive-compose",
  );

  const messages: LLMMessage[] = [
    { role: "system", content: systemPrompt },
    ...contextMessages.map((m) => ({
      role: m.role === "system" ? "user" : m.role,
      // system role을 LLM API에서 user 노트로 강등 (LLMMessage role 좁음).
      content: m.role === "system" ? `[system note] ${m.content}` : m.content,
    } as LLMMessage)),
    // 사용자 입력 없이 캐릭터가 시작하는 모드. 마지막 user turn은 LLM에게 출력 형식만 알리는 가벼운 트리거.
    {
      role: "user",
      content:
        "(사용자 입력 없음. 위 시스템 지시에 따라 너가 먼저 보낼 메시지를 JSON 형식으로만 출력.)",
    },
  ];

  let llmResponse;
  try {
    llmResponse = await llm.generate(messages, {
      temperature: 0.85,
      maxTokens: 250,
      jsonMode: true,
    });
  } catch (err) {
    console.error("[character-proactive-compose] LLM 실패:", err);
    return jsonResponse(
      {
        success: false,
        error: err instanceof Error ? err.message : "LLM 호출 실패",
        errorCode: "llm_failure",
        meta: {
          provider: "openai",
          model: "gpt-4o-mini",
          latencyMs: Date.now() - startedAt,
        },
      },
      500,
    );
  }

  const raw = llmResponse?.content ?? "";
  const parsed = safeParseLlmJson(raw);
  if (!parsed) {
    console.error(
      "[character-proactive-compose] JSON 파싱 실패. raw:",
      raw.slice(0, 200),
    );
    return jsonResponse(
      {
        success: false,
        error: "LLM 응답 형식 오류",
        errorCode: "llm_failure",
        meta: {
          provider: llmResponse?.provider ?? "openai",
          model: llmResponse?.model ?? "gpt-4o-mini",
          latencyMs: Date.now() - startedAt,
        },
      },
      500,
    );
  }

  // moderation: 최종 사용자에게 보낼 텍스트가 안전한지 확인 (model_output 소스).
  const moderationResult = await moderateText({
    text: parsed.text,
    userId: request.userId,
    characterId: request.characterId,
    source: "model_output",
  });
  if (moderationResult.flagged) {
    console.warn(
      "[character-proactive-compose] moderation 차단:",
      moderationResult.reason,
    );
    return jsonResponse(
      {
        success: false,
        error: SAFETY_BLOCK_FALLBACK_RESPONSE,
        errorCode: "safety_blocked",
        meta: {
          provider: llmResponse.provider,
          model: llmResponse.model,
          latencyMs: Date.now() - startedAt,
        },
      },
      400,
    );
  }

  // 슬롯이 image 비후보인데 LLM이 imageCategory를 채웠으면 무시
  const slot = SLOT_HINTS[request.slotKey];
  const finalImageCategory = preferredKind === "image" &&
      parsed.imageCategory &&
      slot.imageCandidates.includes(parsed.imageCategory)
    ? parsed.imageCategory
    : null;

  return jsonResponse({
    success: true,
    text: parsed.text,
    imageCategory: finalImageCategory,
    // Slice 1: imageUrl 미생성. 다음 슬라이스에서 generate-character-proactive-image 와이어업.
    imageUrl: undefined,
    meta: {
      provider: llmResponse.provider,
      model: llmResponse.model,
      latencyMs: Date.now() - startedAt,
    },
  });
});
