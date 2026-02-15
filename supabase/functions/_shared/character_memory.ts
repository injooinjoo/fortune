import { LLMFactory } from "./llm/factory.ts";
import { PromptManager } from "./prompts/manager.ts";
import type { PromptTemplate } from "./prompts/types.ts";

const MEMORY_TEMPLATE_TYPE = "character-memory-summary";
const MESSAGE_DELTA_THRESHOLD = 8;
const TIME_DELTA_HOURS_THRESHOLD = 12;
const MAX_SUMMARY_MESSAGES = 30;

const MEMORY_TEMPLATE: PromptTemplate = {
  id: "character-memory-summary-v1",
  fortuneType: MEMORY_TEMPLATE_TYPE,
  version: 1,
  systemPrompt: `
너는 캐릭터 챗 장기 메모리 요약기다.
반드시 JSON 객체만 출력한다. 마크다운 금지.

목표:
1) 캐릭터 아이덴티티를 해치지 않도록 대화 핵심 사실을 압축
2) 유저-캐릭터 관계 단계에 맞는 안전한 관계 지시 생성
3) 사실과 추측을 구분하고, 검증되지 않은 추측은 배제

출력 스키마(키 이름 고정):
{
  "summary": "한국어 3~6문장",
  "keyFacts": ["사실1", "사실2"],
  "relationshipDirectives": {
    "toneBoundary": "관계 단계 경계",
    "preferredAddressing": "호칭/말투 가이드",
    "proactiveLevel": "low|medium|high",
    "notes": ["추가 지시"]
  }
}

주의:
- keyFacts는 최대 8개.
- 개인정보/민감정보는 최소화.
- 캐릭터 원본 말투를 바꾸라는 지시는 금지.
`.trim(),
  userPromptTemplate: `
[characterId]
{{characterId}}

[relationship]
phase={{phase}}, lovePoints={{lovePoints}}, currentStreak={{currentStreak}}

[existingSummary]
{{existingSummary}}

[existingKeyFactsJson]
{{existingKeyFactsJson}}

[recentConversationJson]
{{recentConversationJson}}

위 정보를 바탕으로 장기 메모리를 갱신해 JSON만 출력해.
`.trim(),
  generationConfig: {
    temperature: 0.2,
    maxTokens: 1200,
    jsonMode: true,
  },
  variables: [
    {
      name: "characterId",
      type: "string",
      required: true,
      description: "캐릭터 ID",
    },
    {
      name: "phase",
      type: "string",
      required: true,
      description: "관계 단계",
    },
    {
      name: "lovePoints",
      type: "number",
      required: true,
      description: "호감도 포인트",
    },
    {
      name: "currentStreak",
      type: "number",
      required: true,
      description: "연속 대화 일수",
    },
    {
      name: "existingSummary",
      type: "string",
      required: false,
      description: "기존 요약",
    },
    {
      name: "existingKeyFactsJson",
      type: "string",
      required: false,
      description: "기존 핵심 사실 JSON",
    },
    {
      name: "recentConversationJson",
      type: "string",
      required: true,
      description: "최근 대화 JSON",
    },
  ],
};

export interface CharacterConversationMessage {
  id?: string;
  type: string;
  content: string;
  timestamp?: string;
}

export interface AffinityContext {
  phase: string;
  lovePoints: number;
  currentStreak: number;
}

export interface UserCharacterMemory {
  summary: string;
  keyFacts: string[];
  relationshipDirectives: Record<string, unknown>;
  messageCountSnapshot: number;
  lastSummarizedAt: string | null;
}

interface StoredMemoryRow {
  summary: string | null;
  key_facts: unknown;
  relationship_directives: unknown;
  message_count_snapshot: number | null;
  last_summarized_at: string | null;
}

interface MemorySummaryResult {
  summary: string;
  keyFacts: string[];
  relationshipDirectives: Record<string, unknown>;
}

export interface RefreshCharacterMemoryParams {
  supabase: any;
  userId: string;
  characterId: string;
  messages: CharacterConversationMessage[];
  affinityContext?: AffinityContext | null;
}

export interface RefreshCharacterMemoryResult {
  refreshed: boolean;
  skippedReason?: "no-messages" | "threshold-not-met";
  memory?: UserCharacterMemory | null;
}

function ensureTemplateRegistered(): void {
  if (PromptManager.hasTemplate(MEMORY_TEMPLATE_TYPE)) {
    return;
  }

  PromptManager.registerTemplate(MEMORY_TEMPLATE);
}

function safeJsonStringify(value: unknown): string {
  try {
    return JSON.stringify(value);
  } catch {
    return "[]";
  }
}

function parseJsonContent(content: string): Record<string, unknown> {
  const trimmed = content.trim();

  try {
    return JSON.parse(trimmed) as Record<string, unknown>;
  } catch {
    // ```json ... ``` 포맷 보정
    const fenced = trimmed.match(/```(?:json)?\s*([\s\S]*?)\s*```/i);
    if (fenced && fenced[1]) {
      return JSON.parse(fenced[1].trim()) as Record<string, unknown>;
    }

    throw new Error("Invalid JSON response from memory summarizer");
  }
}

function toStringArray(value: unknown): string[] {
  if (!Array.isArray(value)) {
    return [];
  }

  return value
    .filter((item) => typeof item === "string")
    .map((item) => item.trim())
    .filter((item) => item.length > 0);
}

function normalizeSummaryPayload(
  payload: Record<string, unknown>,
): MemorySummaryResult {
  const summary = typeof payload.summary === "string"
    ? payload.summary.trim()
    : "";
  if (!summary) {
    throw new Error("Memory summary is empty");
  }

  const keyFacts = toStringArray(payload.keyFacts).slice(0, 8);

  const relationshipDirectives = payload.relationshipDirectives &&
      typeof payload.relationshipDirectives === "object" &&
      !Array.isArray(payload.relationshipDirectives)
    ? payload.relationshipDirectives as Record<string, unknown>
    : {};

  return {
    summary,
    keyFacts,
    relationshipDirectives,
  };
}

function mapMemoryRow(row: StoredMemoryRow | null): UserCharacterMemory | null {
  if (!row) {
    return null;
  }

  return {
    summary: row.summary?.trim() ?? "",
    keyFacts: toStringArray(row.key_facts),
    relationshipDirectives: row.relationship_directives &&
        typeof row.relationship_directives === "object" &&
        !Array.isArray(row.relationship_directives)
      ? row.relationship_directives as Record<string, unknown>
      : {},
    messageCountSnapshot: row.message_count_snapshot ?? 0,
    lastSummarizedAt: row.last_summarized_at,
  };
}

function shouldRefreshMemory(
  memory: UserCharacterMemory | null,
  messages: CharacterConversationMessage[],
): boolean {
  const totalMessages = messages.length;
  if (totalMessages <= 0) {
    return false;
  }

  if (!memory) {
    return true;
  }

  if (memory.lastSummarizedAt) {
    const lastTimestamp = Date.parse(memory.lastSummarizedAt);
    if (!Number.isNaN(lastTimestamp)) {
      const newMessagesSinceLast = messages.reduce((count, message) => {
        if (!message.timestamp) {
          return count;
        }

        const messageTimestamp = Date.parse(message.timestamp);
        if (Number.isNaN(messageTimestamp)) {
          return count;
        }

        return messageTimestamp > lastTimestamp ? count + 1 : count;
      }, 0);

      if (newMessagesSinceLast >= MESSAGE_DELTA_THRESHOLD) {
        return true;
      }
    }
  }

  const fallbackMessageDelta = totalMessages - memory.messageCountSnapshot;
  if (fallbackMessageDelta >= MESSAGE_DELTA_THRESHOLD) {
    return true;
  }

  if (!memory.lastSummarizedAt) {
    return true;
  }

  const last = Date.parse(memory.lastSummarizedAt);
  if (Number.isNaN(last)) {
    return true;
  }

  const hoursSinceLast = (Date.now() - last) / (1000 * 60 * 60);
  return hoursSinceLast >= TIME_DELTA_HOURS_THRESHOLD;
}

function toConversationDigest(
  messages: CharacterConversationMessage[],
): Array<Record<string, string>> {
  return messages
    .slice(-MAX_SUMMARY_MESSAGES)
    .filter((message) => message.content && message.content.trim().length > 0)
    .map((message) => {
      const rawType = message.type || "unknown";
      const role = rawType === "user" ? "user" : "character";
      return {
        role,
        content: message.content.trim().slice(0, 400),
      };
    });
}

export async function loadUserCharacterMemory(
  supabase: any,
  userId: string,
  characterId: string,
): Promise<UserCharacterMemory | null> {
  const { data, error } = await supabase
    .from("user_character_memory")
    .select(
      "summary, key_facts, relationship_directives, message_count_snapshot, last_summarized_at",
    )
    .eq("user_id", userId)
    .eq("character_id", characterId)
    .maybeSingle();

  if (error) {
    console.warn(
      "[character_memory] loadUserCharacterMemory failed:",
      error.message,
    );
    return null;
  }

  return mapMemoryRow((data ?? null) as StoredMemoryRow | null);
}

export async function loadUserCharacterAffinity(
  supabase: any,
  userId: string,
  characterId: string,
): Promise<AffinityContext | null> {
  const { data, error } = await supabase
    .from("user_character_affinity")
    .select("phase, love_points, current_streak")
    .eq("user_id", userId)
    .eq("character_id", characterId)
    .maybeSingle();

  if (error) {
    console.warn(
      "[character_memory] loadUserCharacterAffinity failed:",
      error.message,
    );
    return null;
  }

  if (!data) {
    return null;
  }

  return {
    phase: (data.phase as string | null) || "stranger",
    lovePoints: (data.love_points as number | null) ?? 0,
    currentStreak: (data.current_streak as number | null) ?? 0,
  };
}

async function summarizeMemory(params: {
  characterId: string;
  messages: CharacterConversationMessage[];
  existingMemory: UserCharacterMemory | null;
  affinity: AffinityContext;
}): Promise<MemorySummaryResult> {
  ensureTemplateRegistered();
  if (!PromptManager.isInitialized()) {
    await PromptManager.initialize();
  }

  const systemPrompt = PromptManager.getSystemPrompt(MEMORY_TEMPLATE_TYPE);
  const userPrompt = PromptManager.getUserPrompt(MEMORY_TEMPLATE_TYPE, {
    characterId: params.characterId,
    phase: params.affinity.phase,
    lovePoints: params.affinity.lovePoints,
    currentStreak: params.affinity.currentStreak,
    existingSummary: params.existingMemory?.summary ?? "",
    existingKeyFactsJson: safeJsonStringify(
      params.existingMemory?.keyFacts ?? [],
    ),
    recentConversationJson: safeJsonStringify(
      toConversationDigest(params.messages),
    ),
  });

  const generationConfig = PromptManager.getGenerationConfig(
    MEMORY_TEMPLATE_TYPE,
  );
  const llm = LLMFactory.createFromConfig("free-chat");

  const response = await llm.generate(
    [
      { role: "system", content: systemPrompt },
      { role: "user", content: userPrompt },
    ],
    {
      temperature: generationConfig.temperature,
      maxTokens: generationConfig.maxTokens,
      jsonMode: generationConfig.jsonMode,
    },
  );

  const payload = parseJsonContent(response.content);
  return normalizeSummaryPayload(payload);
}

export async function maybeRefreshCharacterMemory(
  params: RefreshCharacterMemoryParams,
): Promise<RefreshCharacterMemoryResult> {
  const totalMessages = params.messages.length;

  if (totalMessages <= 0) {
    return {
      refreshed: false,
      skippedReason: "no-messages",
    };
  }

  const existingMemory = await loadUserCharacterMemory(
    params.supabase,
    params.userId,
    params.characterId,
  );

  if (!shouldRefreshMemory(existingMemory, params.messages)) {
    return {
      refreshed: false,
      skippedReason: "threshold-not-met",
      memory: existingMemory,
    };
  }

  const affinity = params.affinityContext ??
    (await loadUserCharacterAffinity(
      params.supabase,
      params.userId,
      params.characterId,
    )) ?? {
    phase: "stranger",
    lovePoints: 0,
    currentStreak: 0,
  };

  const summarized = await summarizeMemory({
    characterId: params.characterId,
    messages: params.messages,
    existingMemory,
    affinity,
  });

  const persistedMemory: UserCharacterMemory = {
    summary: summarized.summary,
    keyFacts: summarized.keyFacts,
    relationshipDirectives: summarized.relationshipDirectives,
    messageCountSnapshot: totalMessages,
    lastSummarizedAt: new Date().toISOString(),
  };

  const { error: upsertError } = await params.supabase
    .from("user_character_memory")
    .upsert(
      {
        user_id: params.userId,
        character_id: params.characterId,
        summary: persistedMemory.summary,
        key_facts: persistedMemory.keyFacts,
        relationship_directives: persistedMemory.relationshipDirectives,
        message_count_snapshot: persistedMemory.messageCountSnapshot,
        last_summarized_at: persistedMemory.lastSummarizedAt,
      },
      { onConflict: "user_id,character_id" },
    );

  if (upsertError) {
    throw new Error(
      `user_character_memory upsert failed: ${upsertError.message}`,
    );
  }

  return {
    refreshed: true,
    memory: persistedMemory,
  };
}
