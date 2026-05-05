/**
 * 캐릭터 선톡 디스패처 Edge Function
 *
 * @description 활성 슬롯에 해당하는 후보 사용자에게 캐릭터 선톡을 발송한다.
 * 한 번 호출 = 한 슬롯 처리. cron(5분 단위) 또는 수동 호출(`forceSlotKey`).
 *
 * @endpoint POST /proactive-message-dispatch
 *
 * 설계 문서: docs/features/PROACTIVE_MESSAGING_PLAN.md (5.2)
 *
 * Slice 1 범위:
 *  - lunch_share 슬롯만 활성 슬롯으로 결정. 나머지 슬롯은 forceSlotKey 로만 호출 가능.
 *  - 텍스트 콘텐츠만 (preferredKind = 'text').
 *  - 캐릭터 선택: affinity 가중 랜덤.
 *  - 일일 cap: low=2, moderate=3 (default), high=8.
 *  - 캐릭터 쿨다운: 최근 24h 미답 선톡 2건 누적 시 그 캐릭터 스킵.
 *  - dryRun 지원 (compose까지 호출, 메시지 저장/푸시 스킵).
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import {
  createClient,
  type SupabaseClient,
} from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders, handleCors } from "../_shared/cors.ts";
import { persistAndPushCharacterMessage } from "../_shared/character_message_helper.ts";
import { LLMFactory } from "../_shared/llm/factory.ts";
import type { LLMMessage } from "../_shared/llm/types.ts";
import {
  moderateText,
  SAFETY_BLOCK_FALLBACK_RESPONSE,
} from "../_shared/moderation.ts";
import {
  getProactivePersona,
  isProactiveCharacterId,
  listProactiveCharacterIds,
  type ProactiveCharacterId,
} from "../_shared/character_proactive_persona.ts";
import { SERVICE_TONE_PATTERN as PROACTIVE_SERVICE_TONE_PATTERN } from "../_shared/service_tone_guard.ts";
import { requireWorkerAuth } from "../_shared/worker_auth.ts";

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

interface DispatchRequest {
  forceSlotKey?: SlotKey;
  forceUserId?: string;
  dryRun?: boolean;
}

interface DispatchSkipped {
  userId: string;
  characterId?: string;
  reason: string;
}

interface DispatchSent {
  userId: string;
  characterId: string;
  slotKey: string;
  messageId: string;
  pushSentCount: number;
  dryRun?: boolean;
  textPreview?: string;
}

interface DispatchResponse {
  success: boolean;
  slotKey: string | null;
  candidatesEvaluated: number;
  messagesSent: number;
  sent: DispatchSent[];
  skipped: DispatchSkipped[];
  errors: Array<{ userId: string; characterId?: string; error: string }>;
  error?: string;
}

interface PreferenceRow {
  user_id: string;
  timezone: string;
  frequency_tier: "low" | "moderate" | "high";
  enabled_character_ids: string[];
  disabled_slot_keys: string[];
  quiet_hours_start: number;
  quiet_hours_end: number;
}

// =============================================================================
// 슬롯 윈도우 (사용자 local hour 기준)
// =============================================================================

interface SlotWindow {
  startHour: number; // 시작 시 (포함)
  endHour: number; // 끝 시 (미포함)
}

const SLOT_WINDOWS: Record<SlotKey, SlotWindow> = {
  morning_greet: { startHour: 7, endHour: 9 },
  commute_chat: { startHour: 8, endHour: 10 },
  lunch_share: { startHour: 11, endHour: 14 }, // 11:00-14:00 (디자인은 11:30-13:30이지만 hour 단위)
  afternoon_break: { startHour: 14, endHour: 17 },
  after_work: { startHour: 18, endHour: 20 },
  evening_chat: { startHour: 20, endHour: 22 },
  goodnight: { startHour: 22, endHour: 24 },
  // 부재 트리거는 시간 슬롯 무관 (Slice 3+)
  absence_6h: { startHour: 0, endHour: 24 },
  absence_24h: { startHour: 0, endHour: 24 },
  absence_72h: { startHour: 0, endHour: 24 },
};

// 자동 활성화 슬롯 (cron 호출 시 dispatcher 가 사용자별 local time 으로 결정).
// 부재 트리거(absence_*) 는 시간 무관이라 별도 경로(forceSlotKey) 로만 호출.
//
// Slice 2 (2026-05-05): luts 파일럿용으로 3 슬롯만 활성. 나머지 4 슬롯은 미활성.
// PROACTIVE_MESSAGING_PLAN.md Slice 2 §2.2.2. Slice 3 진입 시 7 슬롯 복구.
const AUTO_ACTIVE_SLOTS: SlotKey[] = [
  "lunch_share",
  "evening_chat",
  "goodnight",
];

// Slice 2 파일럿 캐릭터 화이트리스트. D10 결정 — luts 1명만.
// Slice 3 에서 9명 캐릭터 확장 시 이 배열 또는 환경변수로 토글.
const SLICE_2_PILOT_CHARACTER_IDS: ProactiveCharacterId[] = ["luts"];

// Slice 2 placeholder 사진 카테고리 + 장수. 사용자가 Storage 에 업로드.
// Slice 3 에서 selfie/night 추가 시 이 맵 확장.
const PLACEHOLDER_CATEGORY_TOTAL: Record<string, number> = {
  meal: 7, // /autoplan UC1 결정. last 5 LRU 보장.
};

// Storage 버킷명 — generate-character-proactive-image 와 동일.
const PLACEHOLDER_BUCKET = "character-proactive-images";

function determineSlotForLocalHour(localHour: number): SlotKey | null {
  for (const slotKey of AUTO_ACTIVE_SLOTS) {
    const w = SLOT_WINDOWS[slotKey];
    if (localHour >= w.startHour && localHour < w.endHour) return slotKey;
  }
  return null;
}

// =============================================================================
// Slice 2 — 일별 image-bearing 결정 + LRU placeholder 선택
// =============================================================================

// 단순 hash — 같은 (userId, localDate) 입력은 항상 같은 출력. cron 5min 재시도가
// 동일 사용자에게 슬롯 결정을 뒤집지 않도록 deterministic 보장.
function simpleHash(s: string): number {
  let h = 0;
  for (let i = 0; i < s.length; i++) {
    h = ((h << 5) - h + s.charCodeAt(i)) | 0;
  }
  return Math.abs(h);
}

// 오늘 lunch_share 가 image-bearing 인지 결정. ~33% 확률 (3일 중 1일).
// Slice 2 는 meal 사진만 큐레이션됐으므로 lunch_share 만 image-bearing 가능.
// Slice 3 에서 selfie/night 추가 시 이 함수가 (slot, category) 쌍을 반환하는 형태로 확장.
function isLunchImageBearing(userId: string, localDate: string): boolean {
  return simpleHash(`${userId}::${localDate}::lunch_image`) % 3 === 0;
}

// LRU: 최근 5개 placeholderIndex 제외하고 랜덤 선택. 5장 무중복 보장 (총 7장 중 5 제외 = 2 후보).
async function pickPlaceholderIndexLRU(
  supabase: SupabaseClient,
  userId: string,
  characterId: string,
  category: string,
): Promise<number> {
  const total = PLACEHOLDER_CATEGORY_TOTAL[category] ?? 5;

  const { data: recentLogs } = await supabase
    .from("proactive_message_log")
    .select("meta")
    .eq("user_id", userId)
    .eq("character_id", characterId)
    .order("created_at", { ascending: false })
    .limit(20);

  const recentIndices = new Set<number>();
  for (const row of (recentLogs ?? []) as Array<{ meta?: Record<string, unknown> }>) {
    const meta = row.meta;
    if (!meta) continue;
    const idx = meta.placeholderIndex;
    const cat = meta.imageCategory;
    if (typeof idx === "number" && cat === category) {
      recentIndices.add(idx);
      if (recentIndices.size >= 5) break;
    }
  }

  const candidates: number[] = [];
  for (let i = 1; i <= total; i++) {
    if (!recentIndices.has(i)) candidates.push(i);
  }
  if (candidates.length === 0) {
    // 7장 모두 최근 사용됨 (사실상 발생 불가, 7-5=2 보장) — 그냥 랜덤.
    return 1 + Math.floor(Math.random() * total);
  }
  return candidates[Math.floor(Math.random() * candidates.length)];
}

// Storage 의 character-proactive-images 버킷은 public — getPublicUrl 만으로 충분.
// signed URL 불요 (PROACTIVE_MESSAGING_PLAN.md Slice 2 A2 결정).
function getPlaceholderPublicUrl(
  supabase: SupabaseClient,
  characterId: string,
  category: string,
  index: number,
): string {
  const path = `${characterId}/${category}/${index}.png`;
  const { data } = supabase.storage.from(PLACEHOLDER_BUCKET).getPublicUrl(path);
  return data.publicUrl;
}

// =============================================================================
// LLM 인라인 컴포저 — 슬롯 힌트 + 시스템 프롬프트 + JSON 응답 강제
// (Slice 1: character-proactive-compose 함수와 분리돼 있었지만
//  Edge Function 간 verify_jwt 인증이 신형 키 형식 때문에 통과 안 돼서
//  dispatcher 안에 인라인.)
// =============================================================================

interface SlotComposeHint {
  label: string;
  guideline: string;
}

const SLOT_COMPOSE_HINTS: Record<SlotKey, SlotComposeHint> = {
  morning_greet: {
    label: "아침 인사",
    guideline:
      "이제 막 하루를 시작하는 사용자에게 가벼운 아침 인사. 너의 어제 기억 한 자락을 살짝 언급해도 좋음.",
  },
  commute_chat: {
    label: "출근/등교 길",
    guideline: "사용자가 이동 중일 가능성. 짧고 가벼운 응원 또는 너 자신의 출근 풍경 한 컷.",
  },
  lunch_share: {
    label: "점심",
    guideline:
      "점심 시간. '나는 지금 이거 먹고 있어' 톤이 자연스러움. 사용자에게 답을 강요하지 말고 공유하듯이.",
  },
  afternoon_break: {
    label: "오후 휴식",
    guideline: "잠깐 한숨 돌리는 오후. 너의 짧은 일상 한 조각.",
  },
  after_work: {
    label: "퇴근/하교",
    guideline: "하루 어땠는지 가볍게 묻거나, 너의 저녁 계획 한 마디.",
  },
  evening_chat: {
    label: "저녁 대화",
    guideline: "오늘 하루 정리하는 분위기. 사용자가 답하기 편한 작은 질문 하나.",
  },
  goodnight: {
    label: "잠자기 전",
    guideline: "굿나잇 한 마디. 너무 긴 메시지 금지. 1-2 문장.",
  },
  absence_6h: {
    label: "잠깐 부재 후",
    guideline:
      "사용자가 6시간 정도 답이 없었음. '잘 지내?' 톤이지 '왜 답 안 해?' 톤이 절대 아님.",
  },
  absence_24h: {
    label: "하루 부재 후",
    guideline:
      "사용자가 하루 동안 답이 없었음. 가볍게 안부 묻기. 미안한 톤이나 압박 절대 금지.",
  },
  absence_72h: {
    label: "사흘 부재 후",
    guideline: "사용자가 며칠 만에 돌아올 가능성. '오랜만이네' 톤. 부담 주지 않고 가볍게.",
  },
};

interface AffinitySnapshot {
  phase: string;
  lovePoints: number;
  daysSinceLastChat: number;
}

function buildComposeSystemPrompt(
  characterId: ProactiveCharacterId,
  slotKey: SlotKey,
  userLocalIsoTime: string,
  affinity: AffinitySnapshot,
): string {
  const persona = getProactivePersona(characterId);
  const slot = SLOT_COMPOSE_HINTS[slotKey];

  return `
너는 ${persona.name}, ${persona.personaSummary}
사용자 호칭: ${persona.addressTerm}
말투 힌트: ${persona.speechHint}

지금 사용자에게 먼저 메시지를 보내려 한다.
- 사용자 현지 시각: ${userLocalIsoTime}
- 슬롯: ${slot.label} — ${slot.guideline}
너와 사용자의 관계 단계: ${affinity.phase}
마지막 대화로부터: ${affinity.daysSinceLastChat}일 전

규칙 (반드시 지킴):
1. 1-3 문장. 카톡 한 메시지 길이.
2. 너의 평소 말투를 유지. 캐릭터 일관성이 가장 중요.
3. 시간/슬롯에 자연스러운 한 가지 디테일을 포함 (날씨, 음식, 풍경 등).
4. 답장 강요 금지. "왜 답 안 해?", "꼭 답해줘" 같은 표현 절대 금지.
5. 너의 행동을 1인칭으로. "나 지금 ~해", "방금 ~했어" 같은 즉시감.
6. 이모지/이모티콘은 캐릭터 톤에 맞을 때만 1-2개까지.
7. **상담봇/서비스 톤 절대 금지** — "네, 무엇을 도와드릴까요?", "무엇을 도와드릴 수", "도움이 필요하시면", "문의해주세요", "지원해드릴게요", "how can I help", "let me help" 같은 콜센터/상담 문구 한 단어라도 들어가면 캐릭터 즉사. 이런 톤이 필요하면 차라리 보내지 마라.
이번 메시지는 텍스트만. imageCategory는 반드시 null.

응답은 반드시 다음 JSON 형식만. 다른 텍스트 금지.
{"text": "메시지 본문", "imageCategory": null}
`.trim();
}

interface InlineComposed {
  text: string;
  meta: { provider: string; model: string; latencyMs: number };
}

interface InlineComposeError {
  error: string;
  // service_tone_blocked: 모델이 콜센터/상담봇 톤 출력 → 페르소나 즉사 회피용 발송 스킵.
  errorCode:
    | "safety_blocked"
    | "llm_failure"
    | "parse_failure"
    | "service_tone_blocked";
  meta?: { provider: string; model: string; latencyMs: number };
}

function safeParseComposeJson(
  raw: string,
): { text: string } | null {
  const trimmed = raw.trim();
  // Object form `{...}` 또는 Array form `[...]` 모두 허용 (Gemini가 종종 배열로 응답).
  const firstObj = trimmed.indexOf("{");
  const firstArr = trimmed.indexOf("[");
  const candidates: number[] = [];
  if (firstObj !== -1) candidates.push(firstObj);
  if (firstArr !== -1) candidates.push(firstArr);
  if (candidates.length === 0) {
    // JSON 형식 아님 → raw 텍스트가 한 메시지일 가능성
    return trimmed.length > 0 ? { text: trimmed } : null;
  }
  const start = Math.min(...candidates);
  const lastObj = trimmed.lastIndexOf("}");
  const lastArr = trimmed.lastIndexOf("]");
  const end = Math.max(lastObj, lastArr);
  if (end <= start) return null;

  const candidate = trimmed.slice(start, end + 1);
  try {
    const parsed = JSON.parse(candidate);
    // Array form: 첫 비어있지 않은 string 사용
    if (Array.isArray(parsed)) {
      const first = parsed.find(
        (x) => typeof x === "string" && x.trim().length > 0,
      );
      return first ? { text: String(first).trim() } : null;
    }
    // Object form: text 필드
    if (parsed && typeof parsed === "object") {
      const t = (parsed as { text?: unknown }).text;
      if (typeof t === "string" && t.trim().length > 0) {
        return { text: t.trim() };
      }
      // Object지만 text 없음 → 첫 string 값 fallback
      const firstString = Object.values(parsed as Record<string, unknown>)
        .find((v) => typeof v === "string" && v.trim().length > 0);
      return firstString ? { text: String(firstString).trim() } : null;
    }
    return null;
  } catch {
    return null;
  }
}

async function composeProactiveMessageInline(params: {
  characterId: ProactiveCharacterId;
  slotKey: SlotKey;
  userLocalIsoTime: string;
  conversationContext: Array<
    { role: "user" | "assistant" | "system"; content: string }
  >;
  affinity: AffinitySnapshot;
  userId: string;
}): Promise<InlineComposed | InlineComposeError> {
  const startedAt = Date.now();
  const systemPrompt = buildComposeSystemPrompt(
    params.characterId,
    params.slotKey,
    params.userLocalIsoTime,
    params.affinity,
  );

  // Slice 1: gemini-2.0-flash-lite — production에서 character-chat 폴백 모델로 검증됨.
  // openai provider는 production safety guard 차단. 비용도 더 저렴.
  const llm = LLMFactory.create(
    "gemini",
    "gemini-2.0-flash-lite",
    "proactive-message-dispatch",
  );

  const messages: LLMMessage[] = [
    { role: "system", content: systemPrompt },
    ...params.conversationContext.map((m) => ({
      role: m.role === "system" ? "user" : m.role,
      content: m.role === "system" ? `[system note] ${m.content}` : m.content,
    } as LLMMessage)),
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
    return {
      error: err instanceof Error ? err.message : "LLM 호출 실패",
      errorCode: "llm_failure",
      meta: {
        provider: "gemini",
        model: "gemini-2.0-flash-lite",
        latencyMs: Date.now() - startedAt,
      },
    };
  }

  const parsed = safeParseComposeJson(llmResponse?.content ?? "");
  if (!parsed) {
    return {
      error: `LLM 응답 형식 오류: ${
        (llmResponse?.content ?? "").slice(0, 120)
      }`,
      errorCode: "parse_failure",
      meta: {
        provider: llmResponse?.provider ?? "openai",
        model: llmResponse?.model ?? "gpt-4o-mini",
        latencyMs: Date.now() - startedAt,
      },
    };
  }

  // Service-bot tone guard: 캐릭터(특히 로맨스 페르소나) 가 "네, 무엇을
  // 도와드릴까요?" 류 상담봇 문구를 첫 메시지로 보내면 페르소나 즉사.
  // character-chat 의 system prompt 와 후처리 strip 가 잘 막아주지만, 선톡
  // 경로는 별도 LLM 호출이라 가드를 우회한다. 모델이 이 패턴을 뱉으면 차라리
  // 발송 자체를 스킵 (재시도 없이 슬롯 하나 비움) — 잘못된 인사 한 번이
  // 캐릭터 신뢰를 깨뜨리는 비용이, 슬롯 하나 비우는 비용보다 훨씬 크다.
  if (PROACTIVE_SERVICE_TONE_PATTERN.test(parsed.text)) {
    console.warn(
      `[proactive] service-tone 차단 (${params.characterId}/${params.slotKey}): ${
        parsed.text.slice(0, 80)
      }`,
    );
    return {
      error: "service_tone_blocked: 모델이 상담봇 톤 출력 → 발송 스킵",
      errorCode: "service_tone_blocked",
      meta: {
        provider: llmResponse.provider,
        model: llmResponse.model,
        latencyMs: Date.now() - startedAt,
      },
    };
  }

  const moderationResult = await moderateText({
    text: parsed.text,
    userId: params.userId,
    characterId: params.characterId,
    source: "model_output",
  });
  if (moderationResult.flagged) {
    return {
      error: SAFETY_BLOCK_FALLBACK_RESPONSE,
      errorCode: "safety_blocked",
      meta: {
        provider: llmResponse.provider,
        model: llmResponse.model,
        latencyMs: Date.now() - startedAt,
      },
    };
  }

  return {
    text: parsed.text,
    meta: {
      provider: llmResponse.provider,
      model: llmResponse.model,
      latencyMs: Date.now() - startedAt,
    },
  };
}

// PROACTIVE_SERVICE_TONE_PATTERN 은 _shared/service_tone_guard.ts 로 통합됨 (Slice 2 A13).
// 양쪽 (dispatcher + character-chat) 가 같은 패턴을 import 한다.

// =============================================================================
// 유틸 — timezone-aware 시간 계산
// =============================================================================

function computeLocalHour(timezone: string, now = new Date()): number {
  try {
    const fmt = new Intl.DateTimeFormat("en-US", {
      timeZone: timezone,
      hour: "numeric",
      hour12: false,
    });
    const parts = fmt.formatToParts(now);
    const hourPart = parts.find((p) => p.type === "hour");
    if (!hourPart) return now.getUTCHours();
    // hour12: false 인데 일부 환경에서 "24" 가 나오는 케이스 보호
    const h = parseInt(hourPart.value, 10);
    return Number.isFinite(h) ? h % 24 : now.getUTCHours();
  } catch {
    console.warn(
      `[dispatch] 알 수 없는 timezone "${timezone}", UTC 시 사용`,
    );
    return now.getUTCHours();
  }
}

function computeLocalDate(timezone: string, now = new Date()): string {
  // 'YYYY-MM-DD' 포맷. user_local_date 컬럼에 저장.
  try {
    const fmt = new Intl.DateTimeFormat("sv-SE", {
      timeZone: timezone,
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
    });
    return fmt.format(now);
  } catch {
    return now.toISOString().slice(0, 10);
  }
}

function computeLocalIsoTime(timezone: string, now = new Date()): string {
  // compose 함수에 전달할 ISO 8601 (사용자 local 시각).
  // Slice 1: timezone offset을 정확히 붙이는 건 복잡하니 "YYYY-MM-DDTHH:mm:ss" 형태로
  // 사용자 local wall-clock을 표현. compose 프롬프트는 시각의 의미만 활용한다.
  const local = new Date(
    now.toLocaleString("en-US", { timeZone: timezone }),
  );
  const yyyy = local.getFullYear();
  const mm = String(local.getMonth() + 1).padStart(2, "0");
  const dd = String(local.getDate()).padStart(2, "0");
  const hh = String(local.getHours()).padStart(2, "0");
  const mi = String(local.getMinutes()).padStart(2, "0");
  return `${yyyy}-${mm}-${dd}T${hh}:${mi}:00`;
}

function inQuietHours(hour: number, start: number, end: number): boolean {
  if (start === end) return false;
  if (start < end) return hour >= start && hour < end;
  // start > end → 자정 넘김 (예: 22-9)
  return hour >= start || hour < end;
}

function withinSlotWindow(hour: number, slotKey: SlotKey): boolean {
  const w = SLOT_WINDOWS[slotKey];
  return hour >= w.startHour && hour < w.endHour;
}

function dailyCapForTier(tier: PreferenceRow["frequency_tier"]): number {
  switch (tier) {
    case "low":
      return 2;
    case "high":
      return 8;
    case "moderate":
    default:
      return 3;
  }
}

// =============================================================================
// 캐릭터 선택 — affinity 가중 랜덤
// =============================================================================

interface AffinityRow {
  character_id: string;
  phase: string | null;
  love_points: number | null;
}

function pickWeightedCharacter(
  candidates: ProactiveCharacterId[],
  affinityMap: Map<string, AffinityRow>,
): ProactiveCharacterId {
  // 가중치 = max(1, lovePoints + 10). 모든 캐릭터 최소 1.
  // lovePoints 가 -10 이하인 적대 관계면 1 (거의 안 뽑힘).
  const weights = candidates.map((id) => {
    const lp = affinityMap.get(id)?.love_points ?? 0;
    return Math.max(1, lp + 10);
  });
  const total = weights.reduce((acc, w) => acc + w, 0);
  let r = Math.random() * total;
  for (let i = 0; i < candidates.length; i++) {
    r -= weights[i];
    if (r <= 0) return candidates[i];
  }
  return candidates[candidates.length - 1];
}

// =============================================================================
// 활성 슬롯 결정 — 사용자별 local time 으로 결정 (메인 루프 안에서 수행).
// =============================================================================

// =============================================================================
// 핸들러
// =============================================================================

function jsonResponse(body: DispatchResponse, status = 200): Response {
  return new Response(JSON.stringify(body), {
    headers: { ...corsHeaders, "Content-Type": "application/json" },
    status,
  });
}

serve(async (req: Request) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  // /ultrareview SRE P0 #6: cron worker 인증 강제. SUPABASE_SERVICE_ROLE_KEY
  // 또는 CRON_SECRET 만 호출 가능. 외부 호출자가 강제로 dispatch 트리거 + LLM
  // 비용 폭주 방지.
  const authError = requireWorkerAuth(req);
  if (authError) return authError;

  if (req.method !== "POST") {
    return jsonResponse(
      {
        success: false,
        slotKey: null,
        candidatesEvaluated: 0,
        messagesSent: 0,
        sent: [],
        skipped: [],
        errors: [],
        error: "POST만 허용",
      },
      405,
    );
  }

  let request: DispatchRequest = {};
  try {
    const text = await req.text();
    if (text.length > 0) {
      request = JSON.parse(text) as DispatchRequest;
    }
  } catch {
    return jsonResponse(
      {
        success: false,
        slotKey: null,
        candidatesEvaluated: 0,
        messagesSent: 0,
        sent: [],
        skipped: [],
        errors: [],
        error: "잘못된 JSON",
      },
      400,
    );
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  if (!supabaseUrl || !serviceRoleKey) {
    return jsonResponse(
      {
        success: false,
        slotKey: null,
        candidatesEvaluated: 0,
        messagesSent: 0,
        sent: [],
        skipped: [],
        errors: [],
        error: "Supabase service role 환경변수 미설정",
      },
      500,
    );
  }

  const supabase = createClient(supabaseUrl, serviceRoleKey);
  const dryRun = Boolean(request.dryRun);
  const now = new Date();

  // 1. 후보 사용자 1차 쿼리
  let prefQuery = supabase
    .from("user_proactive_preferences")
    .select(
      "user_id, timezone, frequency_tier, enabled_character_ids, disabled_slot_keys, quiet_hours_start, quiet_hours_end",
    )
    .eq("enabled", true);

  if (request.forceUserId) {
    prefQuery = prefQuery.eq("user_id", request.forceUserId);
  }

  const { data: prefRows, error: prefErr } = await prefQuery;
  if (prefErr) {
    console.error("[dispatch] preferences 조회 실패:", prefErr);
    return jsonResponse(
      {
        success: false,
        slotKey: null,
        candidatesEvaluated: 0,
        messagesSent: 0,
        sent: [],
        skipped: [],
        errors: [],
        error: prefErr.message,
      },
      500,
    );
  }

  const preferences = (prefRows ?? []) as PreferenceRow[];

  // forceUserId 인데 row 가 없으면 디폴트 prefs 로 fallback (D1: opt-out — 모든 사용자 디폴트 ON).
  if (request.forceUserId && preferences.length === 0) {
    preferences.push({
      user_id: request.forceUserId,
      timezone: "Asia/Seoul",
      frequency_tier: "moderate",
      enabled_character_ids: [],
      disabled_slot_keys: [],
      quiet_hours_start: 22,
      quiet_hours_end: 9,
    });
  }

  // 2. 활성 슬롯 결정 — forceSlotKey 면 모든 사용자에게 동일 슬롯, 아니면 사용자별 local time으로 결정.
  const forcedSlot: SlotKey | null = request.forceSlotKey ?? null;

  const sent: DispatchSent[] = [];
  const skipped: DispatchSkipped[] = [];
  const errors: Array<{ userId: string; characterId?: string; error: string }> =
    [];

  // 3. 후보 사용자 순회
  for (const pref of preferences) {
    try {
      const localHour = computeLocalHour(pref.timezone, now);
      const localDate = computeLocalDate(pref.timezone, now);
      const localIsoTime = computeLocalIsoTime(pref.timezone, now);

      // 사용자별 슬롯 결정 — forcedSlot 있으면 그것, 없으면 local hour 로 자동 결정
      const slotKey: SlotKey | null = forcedSlot ??
        determineSlotForLocalHour(localHour);

      if (!slotKey) {
        skipped.push({
          userId: pref.user_id,
          reason: `no active slot for local hour=${localHour}`,
        });
        continue;
      }

      // 슬롯 비활성 체크
      if (pref.disabled_slot_keys.includes(slotKey)) {
        skipped.push({
          userId: pref.user_id,
          reason: `slot disabled by user (${slotKey})`,
        });
        continue;
      }

      // quiet hours 체크
      if (
        inQuietHours(localHour, pref.quiet_hours_start, pref.quiet_hours_end)
      ) {
        skipped.push({ userId: pref.user_id, reason: "quiet hours" });
        continue;
      }

      // 슬롯 윈도우 체크 (forcedSlot 가 윈도우 밖일 때만 의미)
      if (forcedSlot && !withinSlotWindow(localHour, slotKey)) {
        skipped.push({
          userId: pref.user_id,
          reason: `outside slot window for forced slot ${slotKey} (local hour=${localHour})`,
        });
        continue;
      }

      // 오늘 이 슬롯 발송 여부
      const { count: alreadySentCount, error: alreadySentErr } = await supabase
        .from("proactive_message_log")
        .select("id", { head: true, count: "exact" })
        .eq("user_id", pref.user_id)
        .eq("slot_key", slotKey)
        .eq("user_local_date", localDate);
      if (alreadySentErr) {
        errors.push({ userId: pref.user_id, error: alreadySentErr.message });
        continue;
      }
      if ((alreadySentCount ?? 0) > 0) {
        skipped.push({
          userId: pref.user_id,
          reason: "already sent this slot today",
        });
        continue;
      }

      // 일일 cap
      const cap = dailyCapForTier(pref.frequency_tier);
      const { count: todayCount, error: todayErr } = await supabase
        .from("proactive_message_log")
        .select("id", { head: true, count: "exact" })
        .eq("user_id", pref.user_id)
        .eq("user_local_date", localDate);
      if (todayErr) {
        errors.push({ userId: pref.user_id, error: todayErr.message });
        continue;
      }
      if ((todayCount ?? 0) >= cap) {
        skipped.push({
          userId: pref.user_id,
          reason: `daily cap reached (${todayCount}/${cap})`,
        });
        continue;
      }

      // 후보 캐릭터 결정
      // Slice 2 (D10): 파일럿은 luts 1명만. SLICE_2_PILOT_CHARACTER_IDS 와 교집합.
      // Slice 3 진입 시 이 교집합 제거하면 9명 확장.
      const allEligible: ProactiveCharacterId[] =
        pref.enabled_character_ids.length > 0
          ? pref.enabled_character_ids.filter(isProactiveCharacterId)
          : listProactiveCharacterIds();
      const eligible = allEligible.filter((id) =>
        SLICE_2_PILOT_CHARACTER_IDS.includes(id)
      );

      if (eligible.length === 0) {
        skipped.push({
          userId: pref.user_id,
          reason: "no eligible characters in Slice 2 pilot",
        });
        continue;
      }

      // affinity 일괄 조회
      const { data: affRows } = await supabase
        .from("user_character_affinity")
        .select("character_id, phase, love_points")
        .eq("user_id", pref.user_id)
        .in("character_id", eligible);
      const affMap = new Map<string, AffinityRow>(
        ((affRows ?? []) as AffinityRow[]).map((r) => [r.character_id, r]),
      );

      const chosenCharId = pickWeightedCharacter(eligible, affMap);
      const chosenAff = affMap.get(chosenCharId);

      // 캐릭터 쿨다운 (최근 24h 미답 선톡 2건 누적)
      const cooldownSince = new Date(now.getTime() - 24 * 3600 * 1000)
        .toISOString();
      const { data: recentLogs } = await supabase
        .from("proactive_message_log")
        .select("user_replied")
        .eq("user_id", pref.user_id)
        .eq("character_id", chosenCharId)
        .gte("created_at", cooldownSince)
        .order("created_at", { ascending: false })
        .limit(3);
      const unansweredCount = ((recentLogs ?? []) as Array<
        { user_replied: boolean }
      >)
        .filter((r) => !r.user_replied).length;
      if (unansweredCount >= 2) {
        skipped.push({
          userId: pref.user_id,
          characterId: chosenCharId,
          reason: "character cooldown (2+ unanswered)",
        });
        continue;
      }

      // 최근 대화 컨텍스트 로드
      const { data: convoRow } = await supabase
        .from("character_conversations")
        .select("messages, last_message_at")
        .eq("user_id", pref.user_id)
        .eq("character_id", chosenCharId)
        .maybeSingle();

      const existingMessages = ((convoRow?.messages ?? []) as Array<{
        type?: string;
        content?: string;
      }>);

      // 빈 대화방 자동 인사 차단: 사용자가 한 번도 발화하지 않은 채팅방엔
      // proactive 발송 금지. 그렇지 않으면 사용자가 처음 진입할 때 LLM 이
      // 임의로 만든 "네, 무엇을 도와드릴까요?" 같은 콜센터 톤이 인트로 자리에
      // 박혀버림 (메모리 feedback_chat_intro_phrase_forbidden.md 의 두 번째
      // 규칙 — 사용자가 말 걸기 전엔 캐릭터 침묵).
      const userMessageCount = existingMessages.filter(
        (m) => m.type === "user",
      ).length;
      if (userMessageCount === 0) {
        skipped.push({
          userId: pref.user_id,
          characterId: chosenCharId,
          reason:
            "no prior user message — proactive 첫 인사는 사용자 진입 후로 미룸",
        });
        continue;
      }

      const recentForCompose = existingMessages
        .slice(-8)
        .filter((m) => typeof m.content === "string" && m.content.length > 0)
        .map((m) => ({
          role: m.type === "user"
            ? "user" as const
            : m.type === "character" || m.type === "assistant"
            ? "assistant" as const
            : "system" as const,
          content: m.content as string,
        }));

      const lastChatAt = convoRow?.last_message_at
        ? new Date(convoRow.last_message_at as string).getTime()
        : null;
      const daysSinceLastChat = lastChatAt
        ? Math.floor((now.getTime() - lastChatAt) / (24 * 3600 * 1000))
        : 0;

      // 인라인 LLM 호출 — 별도 compose 함수 fetch 대신 같은 프로세스에서 처리.
      const composeResult = await composeProactiveMessageInline({
        characterId: chosenCharId,
        slotKey,
        userLocalIsoTime: localIsoTime,
        conversationContext: recentForCompose,
        affinity: {
          phase: chosenAff?.phase ?? "stranger",
          lovePoints: chosenAff?.love_points ?? 0,
          daysSinceLastChat,
        },
        userId: pref.user_id,
      });

      if ("errorCode" in composeResult) {
        errors.push({
          userId: pref.user_id,
          characterId: chosenCharId,
          error: `compose ${composeResult.errorCode}: ${composeResult.error}`,
        });
        continue;
      }

      const composed = {
        success: true,
        text: composeResult.text,
        imageCategory: null as string | null,
        meta: composeResult.meta,
      };

      // Slice 2: 오늘 lunch_share 가 image-bearing 인지 deterministic 결정.
      // image-bearing 이면 텍스트는 hooking, character-chat 이 다음 user turn 에서
      // 사진 reveal. PROACTIVE_MESSAGING_PLAN.md Slice 2 §2.2.4.
      let hookForReveal = false;
      let plannedImageCategory: string | null = null;
      let plannedPlaceholderIndex: number | null = null;
      let plannedPlaceholderUrl: string | null = null;

      if (slotKey === "lunch_share" && isLunchImageBearing(pref.user_id, localDate)) {
        plannedImageCategory = "meal";
        plannedPlaceholderIndex = await pickPlaceholderIndexLRU(
          supabase,
          pref.user_id,
          chosenCharId,
          plannedImageCategory,
        );
        plannedPlaceholderUrl = getPlaceholderPublicUrl(
          supabase,
          chosenCharId,
          plannedImageCategory,
          plannedPlaceholderIndex,
        );
        hookForReveal = true;
      }

      const messageId =
        `proactive-${slotKey}-${chosenCharId}-${now.getTime()}-${
          Math.random().toString(36).slice(2, 6)
        }`;

      // Slice 2: log row id 를 미리 발급. push payload 에 동봉되어 character-chat
      // 의 reveal claim 이 race 없이 정확한 row 를 잠그도록.
      const logRowId = crypto.randomUUID();

      // dryRun: 메시지 저장/푸시 모두 스킵
      if (dryRun) {
        sent.push({
          userId: pref.user_id,
          characterId: chosenCharId,
          slotKey,
          messageId,
          pushSentCount: 0,
          dryRun: true,
          textPreview: composed.text,
        });
        continue;
      }

      // 알림 토글 체크 (character_proactive 별도 컬럼). 메시지 저장 + push
      // 발송은 _shared/character_message_helper persistAndPushCharacterMessage
      // 가 통합 처리 (deliver-due-replies 와 동일 helper, "서버 한 곳" 정책).
      // 토글 off 면 push 만 skip 하고 메시지는 RPC merge 로 직접 저장.
      const { data: notifPrefs } = await supabase
        .from("user_notification_preferences")
        .select("enabled, character_proactive")
        .eq("user_id", pref.user_id)
        .maybeSingle();
      const globalEnabled = (notifPrefs?.enabled as boolean | undefined) !==
        false;
      const proactiveEnabled =
        (notifPrefs?.character_proactive as boolean | undefined) !== false;

      const persona = getProactivePersona(chosenCharId);
      const proactiveMeta = {
        slotKey,
        category: composed.imageCategory ?? "greeting",
        generatedAt: now.toISOString(),
      };
      let pushSentCount = 0;
      let pushSkippedReason: string | undefined;

      // Slice 2 (Server Review fix #5): log INSERT 를 push 보다 먼저 수행.
      // 순서를 뒤집은 이유: 만약 push 후 log INSERT 가 실패하면 character-chat 의
      // reveal claim 시 row 가 없어 silent failure (사용자는 hook 만 받고 사진 못 봄).
      // INSERT 먼저 → 실패 시 push 자체를 abort. push_sent_count 는 0 으로 시작
      // 후 push 결과로 UPDATE.
      const { error: logInsertErr } = await supabase
        .from("proactive_message_log")
        .insert({
          id: logRowId,
          user_id: pref.user_id,
          character_id: chosenCharId,
          slot_key: slotKey,
          content_kind: "text",
          message_id: messageId,
          user_local_date: localDate,
          push_sent_count: 0,
          push_skipped_reason: null,
          meta: {
            provider: composed.meta?.provider ?? "unknown",
            model: composed.meta?.model ?? "unknown",
            latency_ms: composed.meta?.latencyMs ?? null,
            dispatch_at_utc: now.toISOString(),
            user_local_time: localIsoTime,
            hookForReveal,
            imageCategory: plannedImageCategory,
            placeholderIndex: plannedPlaceholderIndex,
            placeholderUrl: plannedPlaceholderUrl,
          },
        });
      if (logInsertErr) {
        errors.push({
          userId: pref.user_id,
          characterId: chosenCharId,
          error: `log INSERT 실패 (push 미발송): ${logInsertErr.message}`,
        });
        continue;
      }

      if (!globalEnabled || !proactiveEnabled) {
        // push 토글 off — merge 만 직접 (helper 우회). 클라가 다음 진입 시 봄.
        const { error: mergeErr } = await supabase.rpc(
          "merge_character_conversation_messages",
          {
            p_user_id: pref.user_id,
            p_character_id: chosenCharId,
            p_incoming_messages: [{
              id: messageId,
              type: "character",
              content: composed.text,
              timestamp: now.toISOString(),
              proactive: proactiveMeta,
            }],
            p_runtime_state: null,
            p_max_messages: 200,
          },
        );
        if (mergeErr) {
          errors.push({
            userId: pref.user_id,
            characterId: chosenCharId,
            error: `conversation merge 실패: ${mergeErr.message}`,
          });
          continue;
        }
        pushSkippedReason = !globalEnabled
          ? "notif globally disabled"
          : "character_proactive disabled";
      } else {
        // 통합 helper — RPC merge + push 동시. fail-soft.
        const result = await persistAndPushCharacterMessage({
          supabase,
          userId: pref.user_id,
          characterId: chosenCharId,
          characterName: persona.name,
          messageContent: composed.text,
          messageId,
          pushType: "character_follow_up",
          proactive: proactiveMeta,
          // Slice 2: hookForReveal 인 메시지일 때만 push 에 logRowId 동봉.
          // character-chat 이 다음 user turn 에서 이 id 로 reveal claim.
          pendingProactiveMessageId: hookForReveal ? logRowId : undefined,
        });
        if (result.persistError) {
          errors.push({
            userId: pref.user_id,
            characterId: chosenCharId,
            error: `conversation merge 실패: ${result.persistError}`,
          });
          continue;
        }
        pushSentCount = result.pushSentCount;
        if (result.pushSkipped) pushSkippedReason = result.pushSkipReason;
      }

      // log push 결과 UPDATE — 위 INSERT 가 push_sent_count=0 으로 시작했으니 실제 결과 반영.
      // hookForReveal=true 인데 push_sent_count=0 이면 사용자는 hook 못 받음 → reveal 안 됨.
      // hookAbandoned 플래그로 metric 노출. (Server Review #6 fix)
      const updateMeta: Record<string, unknown> = {};
      if (hookForReveal && pushSentCount === 0) {
        updateMeta.hookAbandoned = true;
        updateMeta.hookAbandonedReason = pushSkippedReason ?? "push_failed";
      }
      const { error: logUpdateErr } = await supabase
        .from("proactive_message_log")
        .update({
          push_sent_count: pushSentCount,
          push_skipped_reason: pushSkippedReason ?? null,
          ...(Object.keys(updateMeta).length > 0
            ? {
              meta: {
                provider: composed.meta?.provider ?? "unknown",
                model: composed.meta?.model ?? "unknown",
                latency_ms: composed.meta?.latencyMs ?? null,
                dispatch_at_utc: now.toISOString(),
                user_local_time: localIsoTime,
                hookForReveal,
                imageCategory: plannedImageCategory,
                placeholderIndex: plannedPlaceholderIndex,
                placeholderUrl: plannedPlaceholderUrl,
                ...updateMeta,
              },
            }
            : {}),
        })
        .eq("id", logRowId);
      if (logUpdateErr) {
        // 비치명: push 는 이미 나갔고 log row 는 살아있음 (push_sent_count 만 0 으로 잘못 기록).
        console.warn(
          `[dispatch] log push update 실패 user=${pref.user_id}: ${logUpdateErr.message}`,
        );
      }

      sent.push({
        userId: pref.user_id,
        characterId: chosenCharId,
        slotKey,
        messageId,
        pushSentCount,
      });
    } catch (e) {
      console.error(`[dispatch] user=${pref.user_id} 예외:`, e);
      errors.push({
        userId: pref.user_id,
        error: e instanceof Error ? e.message : String(e),
      });
    }
  }

  return jsonResponse({
    success: true,
    slotKey: forcedSlot, // 자동 모드면 null. 사용자별 슬롯은 sent[].slotKey 참조.
    candidatesEvaluated: preferences.length,
    messagesSent: sent.length,
    sent,
    skipped,
    errors,
  });
});
