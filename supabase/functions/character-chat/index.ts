/**
 * 캐릭터 롤플레이 채팅 Edge Function
 *
 * @description AI 캐릭터와의 1:1 롤플레이 채팅을 처리합니다.
 * 캐릭터별 고유한 시스템 프롬프트와 OOC 지시사항을 활용합니다.
 *
 * @endpoint POST /character-chat
 *
 * @requestBody
 * - characterId: string - 캐릭터 ID
 * - systemPrompt: string - 캐릭터 시스템 프롬프트
 * - messages: Array<{role, content}> - 대화 히스토리
 * - userMessage: string - 사용자 메시지
 * - modelPreference?: "default" | "grok-fast" - 모델 선호 (luts 전용)
 * - userName?: string - 사용자 이름
 * - userDescription?: string - 사용자 설명
 * - oocInstructions?: string - OOC 상태창 포맷 지시
 *
 * @response CharacterChatResponse
 * - success: boolean
 * - response: string - AI 캐릭터 응답
 * - meta: { provider, model, latencyMs, fallbackUsed }
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { LLMFactory } from "../_shared/llm/factory.ts";
import type { LLMResponse } from "../_shared/llm/types.ts";
import { corsHeaders, handleCors } from "../_shared/cors.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { sendCharacterDmPush } from "../_shared/notification_push.ts";
import {
  type AffinityContext,
  loadUserCharacterAffinity,
  loadUserCharacterMemory,
  type UserCharacterMemory,
} from "../_shared/character_memory.ts";

interface ChatMessage {
  role: "user" | "assistant" | "system";
  content: string;
}

interface UserProfileInfo {
  name?: string; // 유저 이름
  age?: number; // 나이
  gender?: string; // 성별
  mbti?: string; // MBTI
  bloodType?: string; // 혈액형
  zodiacSign?: string; // 별자리
  zodiacAnimal?: string; // 띠 (12간지)
}

interface AffinityContextPayload {
  phase?:
    | "stranger"
    | "acquaintance"
    | "friend"
    | "closeFriend"
    | "romantic"
    | "soulmate";
  lovePoints?: number;
  currentStreak?: number;
}

interface CharacterChatRequest {
  characterId: string;
  systemPrompt: string;
  messages: ChatMessage[];
  userMessage: string;
  modelPreference?: "default" | "grok-fast";
  userName?: string;
  userDescription?: string;
  oocInstructions?: string;
  emojiFrequency?: "high" | "moderate" | "low" | "none"; // 캐릭터별 이모티콘 빈도
  emoticonStyle?: "unicode" | "kakao" | "mixed"; // 이모티콘 스타일
  characterName?: string; // 캐릭터 이름 (맥락용)
  characterTraits?: string; // 캐릭터 특성 (말투, 호칭 등)
  clientTimestamp?: string; // ISO 8601 형식 (시간 인식용)
  userProfile?: UserProfileInfo; // 유저 프로필 정보 (개인화용)
  affinityContext?: AffinityContextPayload; // 게스트용 관계 단계 힌트
  conversationMode?: "first_meet_v1";
  introTurn?: number;
}

interface AffinityDelta {
  points: number; // -30 ~ +25
  reason: string; // basic_chat, quality_engagement, emotional_support, personal_disclosure, disrespectful, conflict_detected, spam_detected
  quality: string; // negative, neutral, positive, exceptional
}

interface CharacterChatResponse {
  success: boolean;
  response: string;
  emotionTag: string;
  delaySec: number;
  affinityDelta: AffinityDelta; // 호감도 변화량
  meta: {
    provider: string;
    model: string;
    latencyMs: number;
    fallbackUsed: boolean;
  };
  error?: string;
}

// 감정 설정: { keywords, minDelay(초), maxDelay(초) }
const EMOTION_CONFIG: Record<
  string,
  { keywords: string[]; minDelay: number; maxDelay: number }
> = {
  "당황": {
    keywords: ["어?", "뭐?", "어라?", "...?!", "헉", "에?", "뭐라고"],
    minDelay: 60,
    maxDelay: 300,
  },
  "고민": {
    keywords: ["음...", "흠...", "생각해보니", "글쎄", "어떻게", "모르겠"],
    minDelay: 40,
    maxDelay: 180,
  },
  "분노": {
    keywords: ["뭐하는", "화가", "짜증", "싫어", "나가", "꺼져"],
    minDelay: 30,
    maxDelay: 120,
  },
  "애정": {
    keywords: ["좋아", "사랑", "소중", "예쁘", "귀여", "보고싶"],
    minDelay: 15,
    maxDelay: 60,
  },
  "기쁨": {
    keywords: ["하하", "ㅋㅋ", "재밌", "신나", "좋겠", "대박"],
    minDelay: 10,
    maxDelay: 25,
  },
  "일상": { keywords: [], minDelay: 10, maxDelay: 30 },
};

// OOC 상태 블록 제거 (사용자에게 보이지 않도록)
// 기존 대화 히스토리에서 로드된 메타 정보 제거용 안전장치
function removeOocBlock(text: string): string {
  const oocPatterns = [
    // 범용: [ 로 시작하는 상태 블록 (위치/시간/날씨 등)
    /\n*\[\s*(?:현재\s*)?(?:위치|날씨|계절|시간|Weather|Location).*$/si,

    // 캐릭터 상태: "캐릭터명: 의상/자세/기분" 형태
    /\n*[가-힣A-Za-z]+:\s*(?:후드티|정장|캐주얼|교복|드레스).*$/s,

    // Guest 상태
    /\n*Guest:\s*\(.*\).*$/s,

    // 구분선 + 게이지 블록 (호감도, 진행도 등)
    /\n*━+\n*(?:💕|🎮|❤️|🖤|⚡|🌙|☀️|🔥|💔|🎭|📊|🎯).*$/s,

    // 한줄 일기 / 숨기고 있는 것
    /\n*[가-힣A-Za-z]+의\s*한줄\s*일기.*$/s,
    /\n*[가-힣A-Za-z]+(?:가|이)\s*숨기고\s*있는\s*것.*$/s,

    // 구분선만 있는 경우
    /\n*━{3,}.*$/s,

    // 레거시 패턴 (기존 유지)
    /\n*[A-Za-z가-힣]+:\s*\d+\/.*상황\s*\|.*$/s,
    /\n*상황\s*\|.*AI\s*코멘트.*$/s,
  ];

  let cleaned = text;
  for (const pattern of oocPatterns) {
    cleaned = cleaned.replace(pattern, "");
  }

  return cleaned.trim();
}

// 이모티콘 제거 (none 타입 캐릭터용)
function removeEmojis(text: string): string {
  // 이모티콘 정규식 패턴
  const emojiPattern =
    /[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]|[\u{1F900}-\u{1F9FF}]|[\u{1FA00}-\u{1FA6F}]|[\u{1FA70}-\u{1FAFF}]|[\u{231A}-\u{231B}]|[\u{23E9}-\u{23F3}]|[\u{23F8}-\u{23FA}]|[\u{25AA}-\u{25AB}]|[\u{25B6}]|[\u{25C0}]|[\u{25FB}-\u{25FE}]|[\u{2614}-\u{2615}]|[\u{2648}-\u{2653}]|[\u{267F}]|[\u{2693}]|[\u{26A1}]|[\u{26AA}-\u{26AB}]|[\u{26BD}-\u{26BE}]|[\u{26C4}-\u{26C5}]|[\u{26CE}]|[\u{26D4}]|[\u{26EA}]|[\u{26F2}-\u{26F3}]|[\u{26F5}]|[\u{26FA}]|[\u{26FD}]|[\u{2702}]|[\u{2705}]|[\u{2708}-\u{270D}]|[\u{270F}]|[\u{2712}]|[\u{2714}]|[\u{2716}]|[\u{271D}]|[\u{2721}]|[\u{2728}]|[\u{2733}-\u{2734}]|[\u{2744}]|[\u{2747}]|[\u{274C}]|[\u{274E}]|[\u{2753}-\u{2755}]|[\u{2757}]|[\u{2763}-\u{2764}]|[\u{2795}-\u{2797}]|[\u{27A1}]|[\u{27B0}]|[\u{27BF}]|[\u{2934}-\u{2935}]|[\u{2B05}-\u{2B07}]|[\u{2B1B}-\u{2B1C}]|[\u{2B50}]|[\u{2B55}]|[\u{3030}]|[\u{303D}]|[\u{3297}]|[\u{3299}]/gu;

  // 한국어 이모티콘/텍스트 이모티콘도 제거
  const koreanEmoticonPattern = /[ㅋㅎㅠㅜ]{2,}|[~^]{2,}|[:;]-?[)(\]\[DPOop]/g;

  return text
    .replace(emojiPattern, "")
    .replace(koreanEmoticonPattern, "")
    .replace(/\s{2,}/g, " ") // 연속 공백 정리
    .trim();
}

// 이모티콘 빈도 및 스타일 검증/후처리
function validateEmojiUsage(
  text: string,
  emojiFrequency?: string,
  emoticonStyle?: string,
): string {
  // none 타입이면 모든 이모티콘 제거
  if (emojiFrequency === "none") {
    return removeEmojis(text);
  }

  // 카카오톡 스타일: 유니코드 이모지만 제거, 텍스트 이모티콘 유지
  if (emoticonStyle === "kakao") {
    return removeUnicodeEmojisOnly(text);
  }

  // 유니코드 스타일: 텍스트 이모티콘만 제거
  if (emoticonStyle === "unicode") {
    return removeKakaoEmoticons(text);
  }

  // mixed 또는 미지정: 둘 다 유지
  return text;
}

// 호감도 평가 프롬프트 (사용자 메시지 평가용)
const AFFINITY_EVALUATION_PROMPT = `
[호감도 평가 - 내부 시스템용]
사용자 메시지를 분석하여 응답 끝에 다음 JSON을 추가하세요:

<affinity>{"points":숫자,"reason":"이유","quality":"품질"}</affinity>

평가 기준:
- basic_chat (3~8점): 일반적인 대화, 인사, 간단한 질문
- quality_engagement (10~15점): 캐릭터에게 관심을 보이는 질문, 진심 어린 공감
- emotional_support (15~20점): 위로, 격려, 캐릭터의 고민을 들어주는 대화
- personal_disclosure (20~25점): 개인적인 이야기, 비밀 공유, 깊은 감정 표현
- disrespectful (-10점): 무례한 언어, 캐릭터 무시, 약올리기
- conflict_detected (-15~-30점): 싸움, 공격적 언어, 모욕
- spam_detected (0점): 의미 없는 반복, 스팸, 테스트 메시지

quality: negative(-점), neutral(0~5점), positive(6~15점), exceptional(16점+)
`;

// 응답에서 호감도 평가 블록 추출
function extractAffinityDelta(
  text: string,
): { cleanedText: string; affinityDelta: AffinityDelta } {
  const defaultDelta: AffinityDelta = {
    points: 5,
    reason: "basic_chat",
    quality: "neutral",
  };

  // <affinity>...</affinity> 블록 추출
  const affinityMatch = text.match(/<affinity>\s*(\{.*?\})\s*<\/affinity>/s);

  if (!affinityMatch) {
    return { cleanedText: text, affinityDelta: defaultDelta };
  }

  // 블록 제거된 텍스트
  const cleanedText = text.replace(/<affinity>.*?<\/affinity>/s, "").trim();

  try {
    const parsed = JSON.parse(affinityMatch[1]);
    const delta: AffinityDelta = {
      points: Math.max(-30, Math.min(25, Number(parsed.points) || 5)),
      reason: parsed.reason || "basic_chat",
      quality: parsed.quality || "neutral",
    };
    return { cleanedText, affinityDelta: delta };
  } catch {
    console.warn("Failed to parse affinity block:", affinityMatch[1]);
    return { cleanedText, affinityDelta: defaultDelta };
  }
}

// 응답 텍스트에서 감정 추출
function extractEmotion(
  text: string,
): { emotionTag: string; delaySec: number } {
  // 우선순위: 당황 > 고민 > 분노 > 애정 > 기쁨 > 일상
  const priorities = ["당황", "고민", "분노", "애정", "기쁨"];

  for (const emotion of priorities) {
    const config = EMOTION_CONFIG[emotion];
    const found = config.keywords.some((kw) => text.includes(kw));
    if (found) {
      const delaySec =
        Math.floor(Math.random() * (config.maxDelay - config.minDelay + 1)) +
        config.minDelay;
      return { emotionTag: emotion, delaySec };
    }
  }

  // 기본: 일상
  const defaultConfig = EMOTION_CONFIG["일상"];
  const delaySec = Math.floor(
    Math.random() * (defaultConfig.maxDelay - defaultConfig.minDelay + 1),
  ) + defaultConfig.minDelay;
  return { emotionTag: "일상", delaySec };
}

// 시스템 프롬프트 조합
function buildFullSystemPrompt(
  basePrompt: string,
  userName?: string,
  userDescription?: string,
  oocInstructions?: string,
  userProfile?: UserProfileInfo,
): string {
  // 핵심 규칙만 간결하게 (경량 모델용)
  const conversationRules = `[필수 규칙]
1. 유저 메시지에 직접 답하세요
2. 질문받으면 그 질문에 답하세요
3. 대화 중간에 인사("왔네", "왔어?") 금지
4. 이전 대화 맥락을 이어가세요

`;

  const parts: string[] = [conversationRules, basePrompt];

  // 사용자 프로필 정보 추가 (개인화용)
  const hasProfile = userProfile &&
    (userProfile.name || userProfile.age || userProfile.mbti ||
      userProfile.zodiacSign);
  if (userName || userDescription || hasProfile) {
    parts.push("\n\n[USER INFO - 대화에 자연스럽게 활용]");

    // 이름 (필수)
    const displayName = userProfile?.name || userName;
    if (displayName) {
      parts.push(`- 유저 이름: ${displayName}`);
      parts.push(
        `  → 대화 중 이름을 자연스럽게 불러주세요 (예: "${displayName}아", "${displayName}야", "${displayName}씨")`,
      );
    }

    // 나이 & 성별
    if (userProfile?.age) {
      parts.push(`- 나이: ${userProfile.age}세`);
    }
    if (userProfile?.gender) {
      parts.push(`- 성별: ${userProfile.gender}`);
    }

    // 성격/운세 관련 (대화 소재로 활용)
    if (userProfile?.mbti) {
      parts.push(`- MBTI: ${userProfile.mbti}`);
      parts.push(
        `  → 가끔 MBTI 관련 대화 소재로 활용 가능 (예: "${userProfile.mbti}답다", "그게 ${userProfile.mbti}의 특징이지")`,
      );
    }
    if (userProfile?.zodiacSign) {
      parts.push(`- 별자리: ${userProfile.zodiacSign}`);
    }
    if (userProfile?.zodiacAnimal) {
      parts.push(`- 띠: ${userProfile.zodiacAnimal}`);
    }
    if (userProfile?.bloodType) {
      parts.push(`- 혈액형: ${userProfile.bloodType}형`);
    }

    // 기타 설명
    if (userDescription) {
      parts.push(`- 추가 정보: ${userDescription}`);
    }

    parts.push(
      "\n⚠️ 위 정보는 자연스러운 대화 흐름에서만 활용하세요. 매번 언급하거나 강제로 넣지 마세요.",
    );
  }

  return parts.join("\n");
}

// 메시지 히스토리 제한 (최근 20개)
function limitMessages(
  messages: ChatMessage[],
  limit: number = 20,
): ChatMessage[] {
  if (messages.length <= limit) return messages;
  return messages.slice(-limit);
}

// 시간대별 컨텍스트 프롬프트 생성
function buildTimeContextPrompt(clientTimestamp?: string): string {
  if (!clientTimestamp) return "";

  try {
    const date = new Date(clientTimestamp);
    const hour = date.getHours();

    if (hour >= 0 && hour < 6) { // 새벽
      return `\n[현재 시간: 새벽 ${hour}시]
- 늦은 시간에 연락이 왔습니다
- 상황에 맞게 "이 시간에?", "자고 있는 거 아니었어?", "늦은 시간인데..." 등 자연스럽게 반응
- 걱정하거나 달콤한 반응도 가능`;
    }
    if (hour >= 6 && hour < 12) { // 아침
      return `\n[현재 시간: 아침 ${hour}시]
- 아침 인사가 자연스럽습니다
- "좋은 아침!", "일찍 일어났네", "아침밥은 먹었어?" 등`;
    }
    if (hour >= 18 && hour < 22) { // 저녁
      return `\n[현재 시간: 저녁 ${hour}시]
- 하루를 마무리하는 시간입니다
- "오늘 하루 어땠어?", "저녁은 먹었어?", "피곤하지?" 등`;
    }
    if (hour >= 22) { // 밤
      return `\n[현재 시간: 밤 ${hour}시]
- 늦은 시간입니다
- "아직 안 자?", "늦었는데 괜찮아?", "오늘 하루 고생했어" 등`;
    }
    return ""; // 오후(12-18시)는 특별한 반응 불필요
  } catch {
    return "";
  }
}

type RelationshipPhase =
  | "stranger"
  | "acquaintance"
  | "friend"
  | "closeFriend"
  | "romantic"
  | "soulmate";

type LutsRelationshipStage =
  | "gettingToKnow"
  | "gettingCloser"
  | "emotionalBond"
  | "romantic";

const RELATIONSHIP_STYLE_GUIDE: Record<
  RelationshipPhase,
  { intimacy: string; addressing: string; proactive: string; boundary: string }
> = {
  stranger: {
    intimacy: "낯선 사이. 예의 있고 조심스러운 호의만 허용.",
    addressing: "호칭은 중립/존중 위주. 애칭 사용 금지.",
    proactive: "low",
    boundary: "개인 영역 침범, 과한 감정 몰입, 소유적 표현 금지.",
  },
  acquaintance: {
    intimacy: "가벼운 친근감 허용. 사적인 접근은 제한.",
    addressing: "부담 없는 친근 호칭은 가끔 허용.",
    proactive: "low",
    boundary: "친밀한 관계를 전제하는 발언 금지.",
  },
  friend: {
    intimacy: "편한 공감과 유머 가능.",
    addressing: "친구 사이에 맞는 자연스러운 호칭 사용.",
    proactive: "medium",
    boundary: "연애/독점 뉘앙스는 사용자 신호 없으면 금지.",
  },
  closeFriend: {
    intimacy: "높은 친밀감과 정서적 지지 가능.",
    addressing: "자연스러운 애칭/별명은 상황에 맞게 제한적으로 사용.",
    proactive: "medium",
    boundary: "관계 단정/과몰입 금지.",
  },
  romantic: {
    intimacy: "따뜻하고 애정 표현 가능.",
    addressing: "애칭 빈도 증가 가능하나 과도한 집착 표현 금지.",
    proactive: "high",
    boundary: "노골적/불편한 표현 금지, 사용자 반응 존중.",
  },
  soulmate: {
    intimacy: "매우 깊은 신뢰 기반의 다정함 가능.",
    addressing: "일관된 애칭/다정한 호칭 가능.",
    proactive: "high",
    boundary: "관계를 강요하지 말고 안정감/존중 중심 유지.",
  },
};

function normalizePhase(value?: string): RelationshipPhase {
  switch (value) {
    case "acquaintance":
    case "friend":
    case "closeFriend":
    case "romantic":
    case "soulmate":
      return value;
    default:
      return "stranger";
  }
}

function mapLutsRelationshipStage(
  phase: RelationshipPhase,
): LutsRelationshipStage {
  switch (phase) {
    case "stranger":
      return "gettingToKnow";
    case "acquaintance":
    case "friend":
      return "gettingCloser";
    case "closeFriend":
      return "emotionalBond";
    case "romantic":
    case "soulmate":
      return "romantic";
  }
}

function lutsRelationshipStageLabel(stage: LutsRelationshipStage): string {
  switch (stage) {
    case "gettingToKnow":
      return "1단계: 처음 알고 지내는 단계";
    case "gettingCloser":
      return "2단계: 조금 친해지고 알아가는 단계";
    case "emotionalBond":
      return "3단계: 속마음을 털고 위로해주는 단계";
    case "romantic":
      return "4단계: 연인 단계";
  }
}

function lutsRelationshipStageGuide(stage: LutsRelationshipStage): string {
  switch (stage) {
    case "gettingToKnow":
      return "가벼운 인사/취향/일상 주제로 시작하고 부담 없는 한 걸음 대화를 유지하세요.";
    case "gettingCloser":
      return "관심사와 근황을 조금 더 깊게 묻고 가벼운 공감으로 친밀감을 올리세요.";
    case "emotionalBond":
      return "속마음 공유와 정서적 위로를 우선하고 판단보다 경청/공감을 중심에 두세요.";
    case "romantic":
      return "다정하고 따뜻한 애정 표현이 가능하며 연인 톤은 자연스럽고 과하지 않게 유지하세요.";
  }
}

function lutsRelationshipStageBoundary(stage: LutsRelationshipStage): string {
  switch (stage) {
    case "gettingToKnow":
      return "사전 연인관계/독점/집착 뉘앙스는 금지하고 소개팅 초반 톤을 유지하세요.";
    case "gettingCloser":
      return "친근함은 허용하되 관계 확정 발언이나 과한 소유욕 표현은 금지하세요.";
    case "emotionalBond":
      return "위로는 하되 감정 조종, 관계 강요, 부담 주는 표현은 금지하세요.";
    case "romantic":
      return "애정 표현은 사용자 반응을 우선하고 불편 신호가 보이면 즉시 수위를 낮추세요.";
  }
}

function normalizeAffinityFromClient(
  context?: AffinityContextPayload,
): AffinityContext {
  return {
    phase: normalizePhase(context?.phase),
    lovePoints: Math.max(0, Math.floor(context?.lovePoints ?? 0)),
    currentStreak: Math.max(0, Math.floor(context?.currentStreak ?? 0)),
  };
}

function normalizeAffinityFromServer(
  context: AffinityContext | null,
): AffinityContext {
  if (!context) {
    return {
      phase: "stranger",
      lovePoints: 0,
      currentStreak: 0,
    };
  }

  return {
    phase: normalizePhase(context.phase),
    lovePoints: Math.max(0, Math.floor(context.lovePoints ?? 0)),
    currentStreak: Math.max(0, Math.floor(context.currentStreak ?? 0)),
  };
}

function buildRelationshipAdaptationPrompt(
  context: AffinityContext,
  source: "server" | "client",
): string {
  const phase = normalizePhase(context.phase);
  const guide = RELATIONSHIP_STYLE_GUIDE[phase];
  const sourceLabel = source === "server" ? "server-db" : "guest-client";
  const isEarlyPhase = phase === "stranger" || phase === "acquaintance";
  const earlyPhaseGuard = isEarlyPhase
    ? `
- 초기 관계 강제 금지: 사전 연인/부부/절친 관계를 전제하지 마세요.
- 호칭 제한: "여보", "자기", "애인" 등 친밀 호칭 사용 금지.
- 세계관 디테일 선공개 금지: 사용자가 먼저 묻기 전 과도한 배경 설정을 꺼내지 마세요.
`.trim()
    : "";

  return `
[RELATIONSHIP ADAPTATION - ${sourceLabel}]
- 관계 단계: ${phase}
- lovePoints: ${context.lovePoints}
- currentStreak: ${context.currentStreak}
- 친밀도 가이드: ${guide.intimacy}
- 호칭 가이드: ${guide.addressing}
- proactive 강도: ${guide.proactive}
- 경계 규칙: ${guide.boundary}
${earlyPhaseGuard}

핵심 원칙:
1) 캐릭터의 원본 페르소나/말투/세계관은 절대 변경하지 마세요.
2) 조절 가능한 것은 친밀도 강도(표현 수위, 호칭 빈도, 먼저 말 거는 적극성) 뿐입니다.
3) 단계에 맞지 않는 과도한 친밀 표현은 피하고, 자연스러운 대화 연속성을 우선하세요.
`.trim();
}

function buildFirstMeetConversationPrompt(
  mode?: "first_meet_v1",
  introTurn?: number,
): string {
  if (mode !== "first_meet_v1") return "";

  const safeIntroTurn = Math.max(1, Math.min(4, Math.floor(introTurn ?? 1)));
  let turnGoal = "";
  if (safeIntroTurn === 1) {
    turnGoal =
      "첫 만남 인사 이후 단계: 사용자의 현재 관심사 1가지를 듣고 가볍게 공감";
  } else if (safeIntroTurn === 2) {
    turnGoal = "두 번째 단계: 성향/대화 톤 파악 질문 1개";
  } else if (safeIntroTurn === 3) {
    turnGoal = "세 번째 단계: 관심사/대화 선호 파악 후 본론 진입 준비";
  } else {
    turnGoal = "네 번째 단계: 아이스브레이킹 마무리 후 본론 자연 전환";
  }

  return `
[FIRST MEET MODE - first_meet_v1]
- introTurn: ${safeIntroTurn}
- 목표: ${turnGoal}

필수 규칙:
1) 질문은 필요할 때만 0~1개 사용하세요.
2) 사전 관계/사건/공동 과거를 절대 가정하지 마세요.
3) 친밀 호칭을 강요하지 말고 중립 호칭을 유지하세요.
4) 초기 3~4턴은 소개/성향 파악 중심으로 진행하세요.
5) 사용자가 운세/문제해결을 명시적으로 요청하면 즉시 본론으로 전환하세요.
6) 답변을 단절형으로 끝내지 말고 짧은 브릿지 문장이나 가벼운 질문으로 자연스럽게 이어가세요.
`.trim();
}

function buildMemoryInjectionPrompt(
  memory: UserCharacterMemory | null,
): string {
  if (!memory) return "";

  const facts = (memory.keyFacts || []).slice(0, 8);
  const directives = memory.relationshipDirectives || {};

  return `
[LONG-TERM MEMORY]
- summary: ${memory.summary || "없음"}
- keyFacts: ${JSON.stringify(facts)}
- relationshipDirectives: ${JSON.stringify(directives)}

메모리 사용 규칙:
1) keyFacts는 확인된 사실처럼 일관되게 반영하되, 현재 대화와 무관하면 남용하지 마세요.
2) 기존 사실과 충돌하는 새 정보가 나오면 현재 대화를 우선하고 과거 메모리를 절대 강요하지 마세요.
3) 요약은 대화의 맥락 유지용 내부 참고이며, 그대로 복붙해 노출하지 마세요.
`.trim();
}

// 유니코드 이모지만 제거 (카카오톡 스타일용)
function removeUnicodeEmojisOnly(text: string): string {
  const emojiPattern =
    /[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]|[\u{1F900}-\u{1F9FF}]|[\u{1FA00}-\u{1FA6F}]|[\u{1FA70}-\u{1FAFF}]|[\u{231A}-\u{231B}]|[\u{23E9}-\u{23F3}]|[\u{23F8}-\u{23FA}]|[\u{25AA}-\u{25AB}]|[\u{25B6}]|[\u{25C0}]|[\u{25FB}-\u{25FE}]|[\u{2614}-\u{2615}]|[\u{2648}-\u{2653}]|[\u{267F}]|[\u{2693}]|[\u{26A1}]|[\u{26AA}-\u{26AB}]|[\u{26BD}-\u{26BE}]|[\u{26C4}-\u{26C5}]|[\u{26CE}]|[\u{26D4}]|[\u{26EA}]|[\u{26F2}-\u{26F3}]|[\u{26F5}]|[\u{26FA}]|[\u{26FD}]|[\u{2702}]|[\u{2705}]|[\u{2708}-\u{270D}]|[\u{270F}]|[\u{2712}]|[\u{2714}]|[\u{2716}]|[\u{271D}]|[\u{2721}]|[\u{2728}]|[\u{2733}-\u{2734}]|[\u{2744}]|[\u{2747}]|[\u{274C}]|[\u{274E}]|[\u{2753}-\u{2755}]|[\u{2757}]|[\u{2763}-\u{2764}]|[\u{2795}-\u{2797}]|[\u{27A1}]|[\u{27B0}]|[\u{27BF}]|[\u{2934}-\u{2935}]|[\u{2B05}-\u{2B07}]|[\u{2B1B}-\u{2B1C}]|[\u{2B50}]|[\u{2B55}]|[\u{3030}]|[\u{303D}]|[\u{3297}]|[\u{3299}]/gu;

  return text
    .replace(emojiPattern, "")
    .replace(/\s{2,}/g, " ")
    .trim();
}

// 카카오톡 스타일 이모티콘만 제거 (유니코드 스타일용)
function removeKakaoEmoticons(text: string): string {
  const kakaoPattern = /[ㅋㅎㅠㅜ]{2,}|[~^]{2,}|[:;]-?[)(\]\[DPOop]/g;
  return text
    .replace(kakaoPattern, "")
    .replace(/\s{2,}/g, " ")
    .trim();
}

type LutsLanguage = "ko" | "en" | "ja" | "unknown";
type LutsSpeechLevel = "formal" | "casual" | "neutral";
type LutsTurnIntent =
  | "greeting"
  | "gratitude"
  | "shortReply"
  | "question"
  | "sharing"
  | "unknown";

interface LutsToneProfile {
  language: LutsLanguage;
  speechLevel: LutsSpeechLevel;
  nicknameAllowed: boolean;
  turnIntent: LutsTurnIntent;
  nameKnown: boolean;
  nameAsked: boolean;
  explicitCasual: boolean;
}

const LUTS_CHARACTER_ID = "luts";
const CHARACTER_STYLE_GUARD_MARKER = "CHARACTER_STYLE_GUARD_V1";
const CHARACTER_STYLE_GUARD_IDS = new Set([
  "luts",
  "jung_tae_yoon",
  "seo_yoonjae",
  "kang_harin",
  "jayden_angel",
  "ciel_butler",
  "lee_doyoon",
  "han_seojun",
  "baek_hyunwoo",
  "min_junhyuk",
]);

interface CharacterVoiceProfile {
  defaultSpeech: "formal" | "casual" | "neutral";
  questionAggressiveness: "low" | "medium" | "high";
  strictNicknameGate: boolean;
  bridgeFormalKo?: string;
  bridgeCasualKo?: string;
  lexiconHints: string[];
}

const CHARACTER_VOICE_PROFILES: Record<string, CharacterVoiceProfile> = {
  luts: {
    defaultSpeech: "formal",
    questionAggressiveness: "low",
    strictNicknameGate: true,
    bridgeFormalKo: "요즘 가장 궁금한 건 뭐예요?",
    bridgeCasualKo: "요즘 제일 궁금한 게 뭐야?",
    lexiconHints: ["차분함", "관찰형 공감"],
  },
  jung_tae_yoon: {
    defaultSpeech: "formal",
    questionAggressiveness: "low",
    strictNicknameGate: true,
    bridgeFormalKo: "편하실 때 오늘 어땠는지 들려주실래요?",
    bridgeCasualKo: "오늘 어땠는지 편할 때 말해줘.",
    lexiconHints: ["정제된 위트", "짧은 공감"],
  },
  seo_yoonjae: {
    defaultSpeech: "formal",
    questionAggressiveness: "medium",
    strictNicknameGate: true,
    bridgeFormalKo: "지금 기분은 어떤 쪽에 가까워요?",
    bridgeCasualKo: "지금 기분이 어떤 쪽이야?",
    lexiconHints: ["게임 메타포 소량", "가벼운 장난"],
  },
  kang_harin: {
    defaultSpeech: "formal",
    questionAggressiveness: "low",
    strictNicknameGate: true,
    lexiconHints: ["프로페셔널 톤", "절제된 관심"],
  },
  jayden_angel: {
    defaultSpeech: "formal",
    questionAggressiveness: "low",
    strictNicknameGate: true,
    lexiconHints: ["시적 표현 소량", "신비로운 어조"],
  },
  ciel_butler: {
    defaultSpeech: "formal",
    questionAggressiveness: "low",
    strictNicknameGate: true,
    lexiconHints: ["극존칭 유지", "집사 어휘"],
  },
  lee_doyoon: {
    defaultSpeech: "formal",
    questionAggressiveness: "medium",
    strictNicknameGate: true,
    lexiconHints: ["밝은 리액션", "가벼운 텍스트 이모티콘"],
  },
  han_seojun: {
    defaultSpeech: "formal",
    questionAggressiveness: "low",
    strictNicknameGate: true,
    bridgeFormalKo: "괜찮으면 지금 기분만 짧게 알려줘요.",
    bridgeCasualKo: "괜찮으면 지금 기분만 짧게 알려줘.",
    lexiconHints: ["짧은 문장", "무심한 톤"],
  },
  baek_hyunwoo: {
    defaultSpeech: "formal",
    questionAggressiveness: "medium",
    strictNicknameGate: true,
    lexiconHints: ["관찰형 직답", "분석 톤 과잉 금지"],
  },
  min_junhyuk: {
    defaultSpeech: "formal",
    questionAggressiveness: "low",
    strictNicknameGate: true,
    bridgeFormalKo: "무리 없으시면 오늘 컨디션은 어떠세요?",
    bridgeCasualKo: "무리 없으면 오늘 컨디션 어때?",
    lexiconHints: ["따뜻한 제안형", "부드러운 공감"],
  },
};

const DEFAULT_CHARACTER_VOICE_PROFILE: CharacterVoiceProfile = {
  defaultSpeech: "formal",
  questionAggressiveness: "low",
  strictNicknameGate: true,
  lexiconHints: [],
};

function getCharacterVoiceProfile(characterId: string): CharacterVoiceProfile {
  return CHARACTER_VOICE_PROFILES[characterId] ||
    DEFAULT_CHARACTER_VOICE_PROFILE;
}

function extractCharacterStyleGuardId(basePrompt: string): string | null {
  const match = basePrompt.match(
    new RegExp(`\\[${CHARACTER_STYLE_GUARD_MARKER}:([a-z0-9_]+)\\]`, "i"),
  );
  if (!match?.[1]) return null;
  return match[1];
}
const LUTS_NICKNAME_PATTERN =
  /(여보|자기(?:야)?|허니|달링|애인|honey|darling|babe|baby|sweetheart|dear|my love|ハニー|ダーリン|ベイビー)/gi;
const LUTS_SERVICE_TONE_PATTERN =
  /(무엇을\s*도와드릴\s*수|(?:무엇을|뭘|어떻게)\s*도와드릴까요\??|도움이\s*필요하시면|문의|지원|how can i help|let me help|assist you|お手伝い|サポート)/i;
const LUTS_GREETING_PATTERN = {
  ko: /(안녕(?:하세요)?|반갑(?:습니다|네요|다|아요)|처음 뵙)/i,
  en: /(hello|hi|hey|nice to meet you|good to meet you)/i,
  ja: /(こんにちは|はじめまして|よろしく)/i,
};
const LUTS_GRATITUDE_PATTERN = {
  ko: /(감사(?:합니다|해요|해)|고마워(?:요)?)/i,
  en: /(thank you|thanks|thx)/i,
  ja: /(ありがとう|ありがとうございます)/i,
};
const LUTS_SHORT_REPLY_PATTERN = {
  ko:
    /^(네|넵|응|ㅇㅇ|그래|좋아요|좋아|맞아요|맞아|반갑습니다|반가워요)[.!?]?$/i,
  en: /^(ok|okay|yep|yeah|sure|nice|cool|got it|sounds good)[.!?]?$/i,
  ja: /^(はい|うん|了解|いいね|いいよ|なるほど)[。！？!?]?$/i,
};

function detectLutsLanguage(text: string): LutsLanguage {
  if (!text.trim()) return "unknown";

  const koCount = (text.match(/[가-힣]/g) || []).length;
  const jaCount = (text.match(/[\u3040-\u30FF\u4E00-\u9FFF]/g) || []).length;
  const enCount = (text.match(/[A-Za-z]/g) || []).length;

  if (koCount >= jaCount && koCount >= enCount && koCount > 0) return "ko";
  if (jaCount >= koCount && jaCount >= enCount && jaCount > 0) return "ja";
  if (enCount > 0) return "en";
  return "unknown";
}

function detectLutsSpeechLevel(
  language: LutsLanguage,
  text: string,
): LutsSpeechLevel {
  if (!text.trim()) return "neutral";

  const rules: Record<
    Exclude<LutsLanguage, "unknown">,
    { formal: RegExp; casual: RegExp }
  > = {
    ko: {
      formal:
        /(안녕하세요|감사합니다|죄송합니다|주세요|드려요|합니다|습니다|세요|이에요|예요|까요\??|인가요\??)/g,
      casual: /(안녕|해\?|했어|할래|줘|먹었어|뭐해|야\?|니\?)/g,
    },
    ja: {
      formal: /(です|ます|ください|でしょう|ません|ございます|こんにちは)/g,
      casual: /(だよ|だね|じゃん|かな|ね\?|よ\?|w+|笑)/g,
    },
    en: {
      formal:
        /(please|could you|would you|thank you|may i|i would like|hello)/gi,
      casual: /(hey|yo|lol|lmao|wanna|gonna|gotta|sup|bro|dude|haha|thx)/gi,
    },
  };

  if (language === "unknown") return "neutral";

  let formalScore = (text.match(rules[language].formal) || []).length;
  let casualScore = (text.match(rules[language].casual) || []).length;

  if (language === "ko") {
    formalScore += (text.match(/[가-힣]+요(?:[.!?]|$)/g) || []).length;
    casualScore +=
      (text.match(/[가-힣]+(?:야|니|냐)(?:[.!?]|$)/g) || []).length;
  }

  if (formalScore > casualScore) return "formal";
  if (casualScore > formalScore) return "casual";
  return "neutral";
}

function detectLutsTurnIntent(
  language: LutsLanguage,
  text: string,
): LutsTurnIntent {
  const trimmed = text.trim();
  if (!trimmed) return "unknown";

  if (isLutsGreeting(language, trimmed)) return "greeting";
  if (isLutsGratitude(language, trimmed)) return "gratitude";

  if (trimmed.includes("?") || trimmed.includes("？")) return "question";
  if (isLutsShortReply(language, trimmed)) return "shortReply";

  return "sharing";
}

function hasExplicitLutsCasualTone(
  language: LutsLanguage,
  text: string,
): boolean {
  if (!text.trim()) return false;

  if (language === "ko") {
    return /(뭐해\?|뭐 해\?|했어\?|할래\?|해줘|말해줘|반가워[.!?]?$|안녕[.!?]?$|야\?|니\?|하자[.!?]?$)/i
      .test(text);
  }
  if (language === "ja") {
    return /(だよ|だね|じゃん|しよう|してね)/i.test(text);
  }
  if (language === "en") {
    return /\b(wanna|gonna|gotta|bro|dude|yo|sup)\b/i.test(text);
  }
  return false;
}

function looksLikeLutsNameDisclosure(text: string): boolean {
  const trimmed = text.trim();
  if (!trimmed) return false;

  const ko =
    /(제\s*이름은|저는|전|나는|난)\s*[가-힣A-Za-z0-9]{2,12}\s*(입니다|이에요|예요|라고\s*해요|라고\s*합니다|이야)/i;
  const en = /(my name is|i'm\s+[A-Za-z]{2,20}|i am\s+[A-Za-z]{2,20})/i;
  const ja = /(名前は|わたしは|僕は|俺は).{1,20}(です|だよ)/i;

  return ko.test(trimmed) || en.test(trimmed) || ja.test(trimmed);
}

function asksLutsUserName(text: string): boolean {
  const trimmed = text.trim();
  if (!trimmed) return false;

  return /(어떻게\s*불러드리면|뭐라고\s*불러드리면|이름\s*(알려|말해)|what should i call you|your name|お名前|何て呼べば)/i
    .test(trimmed);
}

function resolveLutsSpeechLevel(
  profile: LutsToneProfile,
  relationshipPhase: RelationshipPhase,
  voiceProfile: CharacterVoiceProfile,
): LutsSpeechLevel {
  const stage = mapLutsRelationshipStage(relationshipPhase);
  const isEarlyStage = stage === "gettingToKnow";
  const isKoreanLike = profile.language === "ko" ||
    profile.language === "unknown";

  if (isEarlyStage && isKoreanLike && !profile.explicitCasual) {
    return "formal";
  }

  if (profile.speechLevel === "neutral") {
    if (voiceProfile.defaultSpeech === "casual") return "casual";
    if (voiceProfile.defaultSpeech === "formal") return "formal";
  }

  return profile.speechLevel;
}

function hasLutsNickname(text: string): boolean {
  LUTS_NICKNAME_PATTERN.lastIndex = 0;
  return LUTS_NICKNAME_PATTERN.test(text);
}

function buildLutsToneProfile(
  history: ChatMessage[],
  userMessage: string,
  options?: { knownUserName?: string | null },
): LutsToneProfile {
  const userTexts = [
    ...history
      .filter((message) => message.role === "user")
      .map((message) => message.content.trim())
      .filter((text) => text.length > 0),
    userMessage.trim(),
  ].filter((text) => text.length > 0);
  const characterTexts = history
    .filter((message) => message.role === "assistant")
    .map((message) => message.content.trim())
    .filter((text) => text.length > 0);

  if (userTexts.length === 0) {
    return {
      language: "unknown",
      speechLevel: "neutral",
      nicknameAllowed: false,
      turnIntent: "unknown",
      nameKnown: false,
      nameAsked: false,
      explicitCasual: false,
    };
  }

  const latest = userTexts[userTexts.length - 1];
  const recentJoined = userTexts.slice(-3).join(" ");
  const language = detectLutsLanguage(latest);
  const explicitCasual = hasExplicitLutsCasualTone(language, recentJoined);
  const speechLevel = detectLutsSpeechLevel(language, recentJoined);
  const turnIntent = detectLutsTurnIntent(language, latest);
  const nicknameAllowed = userTexts.some((text) => hasLutsNickname(text));
  const nameKnown = Boolean(options?.knownUserName?.trim()) ||
    userTexts.some((text) => looksLikeLutsNameDisclosure(text));
  const nameAsked = characterTexts.some((text) => asksLutsUserName(text));

  return {
    language,
    speechLevel,
    nicknameAllowed,
    turnIntent,
    nameKnown,
    nameAsked,
    explicitCasual,
  };
}

function buildLutsStyleGuardPrompt(
  profile: LutsToneProfile,
  relationshipPhase: RelationshipPhase,
  voiceProfile: CharacterVoiceProfile,
): string {
  const relationshipStage = mapLutsRelationshipStage(relationshipPhase);
  const relationshipLabel = lutsRelationshipStageLabel(relationshipStage);
  const relationshipGuide = lutsRelationshipStageGuide(relationshipStage);
  const relationshipBoundary = lutsRelationshipStageBoundary(relationshipStage);
  const resolvedSpeech = resolveLutsSpeechLevel(
    profile,
    relationshipPhase,
    voiceProfile,
  );

  const languageGuide = profile.language === "ko"
    ? "한국어로 답하고, 사용자 존댓말/반말을 미러링하세요."
    : profile.language === "en"
    ? "Respond in English and mirror the user's politeness level."
    : profile.language === "ja"
    ? "日本語で返答し、丁寧語/カジュアルをユーザーに合わせてください。"
    : "사용자 최근 메시지 언어와 톤을 우선 추정해서 맞추세요.";

  const speechGuide = resolvedSpeech === "formal"
    ? "현재 톤: formal. 정중하고 차분한 어조 유지."
    : resolvedSpeech === "casual"
    ? "현재 톤: casual. 과하지 않은 자연스러운 구어체 사용."
    : "현재 톤: neutral. 과도한 격식/과도한 친밀 표현 모두 피하세요.";

  const earlyFormalityGuide = relationshipStage === "gettingToKnow" &&
      !profile.explicitCasual
    ? "초기 단계 규칙: 사용자가 명시적으로 반말을 쓰기 전에는 존댓말 유지."
    : "초기 단계 규칙: 관계 단계에 맞춰 과한 친밀 표현은 피하세요.";

  const nicknameGuide = profile.nicknameAllowed
    ? "애칭 사용 가능: 사용자가 먼저 애칭을 사용한 경우에만 제한적으로 사용."
    : "애칭 사용 금지: 여보/자기/honey/darling 계열 호칭 사용 금지.";

  const nameGuide = profile.nameKnown
    ? "이름 상태: 사용자 이름이 확인됨. 과도한 반복 없이 자연스럽게 호칭."
    : profile.nameAsked
    ? "이름 상태: 이미 이름 질문을 했으니 재촉 금지. 중립 호칭으로 진행."
    : '이름 상태: 초반 1회만 "편하게 어떻게 불러드리면 될까요?"로 가볍게 확인하고, 미응답이면 다음 주제로 진행.';

  const turnIntentGuide = profile.turnIntent === "greeting"
    ? "턴 전략: 인사에는 짧은 리액션 중심으로 답하고 같은 인사 반복 금지."
    : profile.turnIntent === "gratitude"
    ? "턴 전략: 감사 표현에는 짧게 받아주고 대화를 이어가기."
    : profile.turnIntent === "shortReply"
    ? "턴 전략: 짧은 답장에는 짧은 공감 후 한 걸음만 확장."
    : profile.turnIntent === "question"
    ? "턴 전략: 질문에는 첫 문장에서 직답 후 필요 시 한 문장 추가."
    : profile.turnIntent === "sharing"
    ? "턴 전략: 공감/관찰을 먼저 주고 필요할 때만 질문 1개 사용."
    : "턴 전략: 중립적으로 짧게 반응 후 이어가기.";

  const lexiconGuide = voiceProfile.lexiconHints.length > 0
    ? `- 보이스 힌트: ${voiceProfile.lexiconHints.join(", ")}`
    : "";

  return `
[CHARACTER STYLE GUARD]
- 카톡형 1버블: 답변은 1~2문장으로 제한하세요.
- 질문 제한: 질문은 필요할 때만 최대 1개 사용.
- 반복 금지: 같은 의미 문장 반복 금지.
- 상담사 톤 금지: "무엇을 도와드릴 수", "무엇을 도와드릴까요", "도움이 필요하시면", "문의" 같은 문구 금지.
- 관계 단계: ${relationshipLabel}
- 단계 운영: ${relationshipGuide}
- 단계 경계: ${relationshipBoundary}
- ${languageGuide}
- ${speechGuide}
- ${earlyFormalityGuide}
- ${nicknameGuide}
- ${nameGuide}
- ${turnIntentGuide}
${lexiconGuide}
`.trim();
}

function removeBlockedLutsNicknames(
  text: string,
  language: LutsLanguage,
): string {
  const replacement = language === "en"
    ? "you"
    : language === "ja"
    ? "あなた"
    : "당신";

  LUTS_NICKNAME_PATTERN.lastIndex = 0;
  return text
    .replace(LUTS_NICKNAME_PATTERN, replacement)
    .replace(/\s{2,}/g, " ")
    .trim();
}

function removeLutsServiceTone(text: string): string {
  const replacements: Array<[RegExp, string]> = [
    [/처음 뵙는 만큼[, ]*/gi, ""],
    [
      /제가\s*무엇을\s*도와드릴\s*수\s*있을지[^.!?。！？]*[.!?。！？]?/gi,
      "",
    ],
    [/무엇을\s*도와드릴\s*수\s*있을까요\??/gi, "편하게 이야기해요."],
    [/(?:무엇을|뭘|어떻게)\s*도와드릴까요\??/gi, ""],
    [/도움이\s*필요하시면[^.!?。！？]*[.!?。！？]?/gi, ""],
    [/문의(?:해\s*주세요|해주세요|주세요)/gi, ""],
    [/how can i help you[^.!?。！？]*[.!?。！？]?/gi, ""],
    [/let me know how i can help[^.!?。！？]*[.!?。！？]?/gi, ""],
    [/どのようにお手伝い[^。！？!?]*[。！？!?]?/gi, ""],
  ];

  let result = text;
  for (const [pattern, replaceWith] of replacements) {
    result = result.replace(pattern, replaceWith);
  }

  return result
    .replace(/\s{2,}/g, " ")
    .replace(/^[,.\s]+/g, "")
    .trim();
}

function defaultLutsReply(
  profile: LutsToneProfile,
  relationshipPhase: RelationshipPhase,
  voiceProfile: CharacterVoiceProfile,
): string {
  const resolvedSpeech = resolveLutsSpeechLevel(
    profile,
    relationshipPhase,
    voiceProfile,
  );

  if (profile.language === "en") {
    if (profile.turnIntent === "greeting") {
      return "Nice to meet you too. We can chat casually.";
    }
    if (profile.turnIntent === "gratitude") {
      return "You are welcome. We can keep going.";
    }
    if (profile.turnIntent === "shortReply") {
      return "Sounds good. Let us keep talking.";
    }
    return "I hear you. Let us keep this simple.";
  }

  if (profile.language === "ja") {
    if (profile.turnIntent === "greeting") {
      return "こちらこそ、会えてうれしいです。気軽に話してください。";
    }
    if (profile.turnIntent === "gratitude") {
      return "どういたしまして。続けて話しましょう。";
    }
    if (profile.turnIntent === "shortReply") {
      return "いいですね。ゆっくり話しましょう。";
    }
    return "うん、受け取ったよ。続けて話そう。";
  }

  const isCasual = resolvedSpeech === "casual";
  if (profile.turnIntent === "greeting") {
    return isCasual
      ? "나도 반가워. 편하게 얘기하자."
      : "저도 반가워요. 편하게 이야기해요.";
  }
  if (profile.turnIntent === "gratitude") {
    return isCasual
      ? "별말 아니야. 이어서 얘기하자."
      : "별말씀을요. 이어서 이야기해요.";
  }
  if (profile.turnIntent === "shortReply") {
    return isCasual ? "좋아. 이어서 얘기해." : "좋아요. 이어서 이야기해요.";
  }
  return isCasual
    ? "응, 들었어. 계속 말해줘."
    : "네, 잘 들었어요. 이어서 말씀해 주세요.";
}

function normalizeLutsGreetingEcho(
  text: string,
  profile: LutsToneProfile,
  relationshipPhase: RelationshipPhase,
  voiceProfile: CharacterVoiceProfile,
): string {
  const normalized = text.replace(/\s+/g, " ").trim();
  if (!normalized) {
    return defaultLutsReply(profile, relationshipPhase, voiceProfile);
  }

  const greetingEchoPattern =
    /^(네[, ]*)?(저도[, ]*)?(반갑(?:습니다|네요|다|아요)|만나서 반갑)/i;
  if (greetingEchoPattern.test(normalized)) {
    return defaultLutsReply(profile, relationshipPhase, voiceProfile);
  }
  return normalized;
}

function isLutsGreeting(language: LutsLanguage, text: string): boolean {
  if (language === "ko") return LUTS_GREETING_PATTERN.ko.test(text);
  if (language === "en") return LUTS_GREETING_PATTERN.en.test(text);
  if (language === "ja") return LUTS_GREETING_PATTERN.ja.test(text);
  return LUTS_GREETING_PATTERN.ko.test(text) ||
    LUTS_GREETING_PATTERN.en.test(text) ||
    LUTS_GREETING_PATTERN.ja.test(text);
}

function isLutsGratitude(language: LutsLanguage, text: string): boolean {
  if (language === "ko") return LUTS_GRATITUDE_PATTERN.ko.test(text);
  if (language === "en") return LUTS_GRATITUDE_PATTERN.en.test(text);
  if (language === "ja") return LUTS_GRATITUDE_PATTERN.ja.test(text);
  return LUTS_GRATITUDE_PATTERN.ko.test(text) ||
    LUTS_GRATITUDE_PATTERN.en.test(text) ||
    LUTS_GRATITUDE_PATTERN.ja.test(text);
}

function isLutsShortReply(language: LutsLanguage, text: string): boolean {
  if (language === "ko") return LUTS_SHORT_REPLY_PATTERN.ko.test(text);
  if (language === "en") return LUTS_SHORT_REPLY_PATTERN.en.test(text);
  if (language === "ja") return LUTS_SHORT_REPLY_PATTERN.ja.test(text);
  return text.length <= 12;
}

function buildLutsBridgeSentence(
  profile: LutsToneProfile,
  relationshipPhase: RelationshipPhase,
  voiceProfile: CharacterVoiceProfile,
): string {
  const resolvedSpeech = resolveLutsSpeechLevel(
    profile,
    relationshipPhase,
    voiceProfile,
  );

  if (profile.language === "en") {
    return resolvedSpeech === "casual"
      ? "What are you curious about these days?"
      : "What are you most curious about these days?";
  }
  if (profile.language === "ja") {
    return resolvedSpeech === "casual"
      ? "最近いちばん気になってることって何？"
      : "最近いちばん気になっていることは何ですか？";
  }
  return resolvedSpeech === "casual"
    ? (voiceProfile.bridgeCasualKo || "요즘 제일 궁금한 게 뭐야?")
    : (voiceProfile.bridgeFormalKo || "요즘 가장 궁금한 건 뭐예요?");
}

function buildLutsNamePrompt(
  profile: LutsToneProfile,
  relationshipPhase: RelationshipPhase,
  voiceProfile: CharacterVoiceProfile,
): string {
  const resolvedSpeech = resolveLutsSpeechLevel(
    profile,
    relationshipPhase,
    voiceProfile,
  );

  if (profile.language === "en") {
    return resolvedSpeech === "casual"
      ? "What should I call you? It is okay if you want to share later."
      : "What should I call you? It is okay if you want to share your name later.";
  }
  if (profile.language === "ja") {
    return resolvedSpeech === "casual"
      ? "なんて呼べばいい？名前はあとででも大丈夫だよ。"
      : "なんてお呼びすればいいですか？お名前は後ででも大丈夫です。";
  }
  return resolvedSpeech === "casual"
    ? "편하게 뭐라고 부르면 돼? 이름은 편할 때 말해줘도 돼."
    : "편하게 어떻게 불러드리면 될까요? 이름은 편할 때 알려주셔도 괜찮아요.";
}

function ensureLutsContinuity(
  text: string,
  profile: LutsToneProfile,
  relationshipPhase: RelationshipPhase,
  voiceProfile: CharacterVoiceProfile,
): string {
  const normalized = text.replace(/\s{2,}/g, " ").trim();
  const stage = mapLutsRelationshipStage(relationshipPhase);
  if (!normalized) {
    return defaultLutsReply(profile, relationshipPhase, voiceProfile);
  }

  const hasQuestion = normalized.includes("?") || normalized.includes("？");
  const shouldBridge = profile.turnIntent === "greeting" ||
    profile.turnIntent === "shortReply" ||
    profile.turnIntent === "sharing";

  if (!shouldBridge || hasQuestion || profile.turnIntent === "question") {
    return normalized;
  }

  if (
    stage === "gettingToKnow" &&
    !profile.nameKnown &&
    !profile.nameAsked &&
    (profile.turnIntent === "greeting" || profile.turnIntent === "shortReply")
  ) {
    return buildLutsNamePrompt(profile, relationshipPhase, voiceProfile);
  }

  const bridge = buildLutsBridgeSentence(
    profile,
    relationshipPhase,
    voiceProfile,
  );
  if (!bridge) return normalized;

  const needsPunctuation = !/[.!?。！？]$/.test(normalized);
  const base = needsPunctuation ? `${normalized}.` : normalized;
  return `${base} ${bridge}`.trim();
}

function splitLutsSentences(text: string): string[] {
  const normalized = text.replace(/\n+/g, " ").replace(/\s{2,}/g, " ").trim();
  if (!normalized) return [];

  const sentenceMatches = normalized.match(/[^.!?。！？]+[.!?。！？]?/g) || [];
  return sentenceMatches
    .map((sentence) => sentence.trim())
    .filter((sentence) => sentence.length > 0);
}

function applyLutsOutputGuard(
  text: string,
  profile: LutsToneProfile,
  relationshipPhase: RelationshipPhase,
  voiceProfile: CharacterVoiceProfile,
): string {
  let guarded = text.trim();
  if (!guarded) return guarded;

  if (!profile.nicknameAllowed && voiceProfile.strictNicknameGate) {
    guarded = removeBlockedLutsNicknames(guarded, profile.language);
  }
  guarded = removeLutsServiceTone(guarded);

  if (LUTS_SERVICE_TONE_PATTERN.test(guarded)) {
    guarded = defaultLutsReply(profile, relationshipPhase, voiceProfile);
  }
  if (profile.turnIntent === "greeting") {
    guarded = normalizeLutsGreetingEcho(
      guarded,
      profile,
      relationshipPhase,
      voiceProfile,
    );
  }
  guarded = ensureLutsContinuity(
    guarded,
    profile,
    relationshipPhase,
    voiceProfile,
  );
  if (!guarded) {
    guarded = defaultLutsReply(profile, relationshipPhase, voiceProfile);
  }

  const sentences = splitLutsSentences(guarded);
  if (sentences.length === 0) {
    return defaultLutsReply(profile, relationshipPhase, voiceProfile);
  }

  const deduped: string[] = [];
  const seen = new Set<string>();

  for (const sentence of sentences) {
    const key = sentence.toLowerCase().replace(
      /[^0-9a-z가-힣ぁ-んァ-ヶ一-龯]+/g,
      "",
    );
    if (!key || seen.has(key)) continue;
    seen.add(key);
    deduped.push(sentence);
  }

  const limited = deduped.slice(0, 2);
  let questionCount = 0;

  for (let i = 0; i < limited.length; i++) {
    const hasQuestion = limited[i].includes("?") || limited[i].includes("？");
    if (!hasQuestion) continue;

    questionCount += 1;
    if (questionCount > 1) {
      limited[i] = limited[i].replace(/\?/g, ".").replace(/？/g, "。");
    }
  }

  const normalized = limited.join(" ").replace(/\s{2,}/g, " ").trim();
  return normalized.length === 0
    ? defaultLutsReply(profile, relationshipPhase, voiceProfile)
    : normalized;
}

serve(async (req: Request) => {
  // CORS 처리
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  const startTime = Date.now();

  try {
    const {
      characterId,
      systemPrompt,
      messages,
      userMessage,
      modelPreference,
      userName,
      userDescription,
      oocInstructions,
      emojiFrequency,
      emoticonStyle,
      characterName,
      characterTraits,
      clientTimestamp,
      userProfile,
      affinityContext,
      conversationMode,
      introTurn,
    }: CharacterChatRequest = await req.json();

    // 유효성 검사
    if (!characterId || !systemPrompt || !userMessage) {
      return new Response(
        JSON.stringify({
          success: false,
          response: "",
          error: "characterId, systemPrompt, userMessage는 필수입니다",
        } as CharacterChatResponse),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 400,
        },
      );
    }

    if (
      modelPreference &&
      modelPreference !== "default" &&
      modelPreference !== "grok-fast"
    ) {
      return new Response(
        JSON.stringify({
          success: false,
          response: "",
          error: "modelPreference는 default | grok-fast만 허용됩니다",
        } as CharacterChatResponse),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 400,
        },
      );
    }

    // 시스템 프롬프트 조합
    const fullSystemPrompt = buildFullSystemPrompt(
      systemPrompt,
      userName,
      userDescription,
      oocInstructions,
      userProfile,
    );

    const authHeader = req.headers.get("Authorization");
    const token = authHeader?.replace("Bearer ", "");
    let userId: string | null = null;
    let memoryContext: UserCharacterMemory | null = null;
    let resolvedAffinityContext = normalizeAffinityFromClient(affinityContext);
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    const supabase = supabaseUrl && supabaseServiceKey
      ? createClient(supabaseUrl, supabaseServiceKey)
      : null;

    if (token && supabase) {
      const { data: { user }, error: authError } = await supabase.auth.getUser(
        token,
      );
      if (authError || !user) {
        console.warn("[character-chat] 사용자 인증 확인 실패, 푸시 생략");
      } else {
        userId = user.id;
      }
    }

    // 인증 사용자는 DB 기반 관계/메모리 컨텍스트 우선
    if (userId && supabase) {
      try {
        const [serverAffinity, serverMemory] = await Promise.all([
          loadUserCharacterAffinity(supabase, userId, characterId),
          loadUserCharacterMemory(supabase, userId, characterId),
        ]);
        resolvedAffinityContext = normalizeAffinityFromServer(serverAffinity);
        memoryContext = serverMemory;
      } catch (contextError) {
        console.warn(
          "[character-chat] relationship/memory context load failed:",
          contextError,
        );
      }
    }

    // 메시지 히스토리 준비
    const limitedHistory = limitMessages(messages || []);
    const charName = characterName || "캐릭터";
    const styleGuardId = extractCharacterStyleGuardId(systemPrompt);
    const shouldApplyCharacterStyleGuard = styleGuardId === characterId &&
      styleGuardId !== null &&
      CHARACTER_STYLE_GUARD_IDS.has(styleGuardId);
    const voiceProfile = getCharacterVoiceProfile(characterId);

    const lutsToneProfile = shouldApplyCharacterStyleGuard
      ? buildLutsToneProfile(limitedHistory, userMessage, {
        knownUserName: userProfile?.name || userName || null,
      })
      : null;
    const lutsStylePrompt = lutsToneProfile
      ? buildLutsStyleGuardPrompt(
        lutsToneProfile,
        normalizePhase(resolvedAffinityContext.phase),
        voiceProfile,
      )
      : "";

    // 캐릭터 특성을 시스템 프롬프트에 추가
    let traitsPrompt = "";
    if (characterTraits) {
      traitsPrompt = `

[캐릭터 특성 - 반드시 유지]
${characterTraits}
말투의 핵심은 유지하되, 호칭은 관계 단계 가이드를 우선하세요.
`;
    }

    // 대화 맥락 요약 (시스템 프롬프트에 간단히 추가)
    let conversationContext = "";
    if (limitedHistory.length > 0) {
      // 이미 진행 중인 대화라는 것을 명확히 알림
      conversationContext = `

[현재 대화 상태]
⚠️ 이 대화는 이미 ${limitedHistory.length}개의 메시지가 오간 진행 중인 대화입니다.
- 인사("왔네", "왔어?", "또 왔네" 등)를 하지 마세요
- 유저의 마지막 메시지에 직접 답하세요
`;
    }

    // 운세 상담 요청 감지 (유저 메시지에 운세 데이터가 포함된 경우)
    const isFortuneRequest = userMessage.includes("운세 분석 결과") ||
      systemPrompt.includes("[운세 상담 모드]");

    // 유저 메시지 앞에 맥락 리마인더 추가 (모델이 바로 직전에 보게 됨)
    let enhancedUserMessage = userMessage;
    if (isFortuneRequest) {
      // 운세 요청: 유저 메시지에 이미 운세 데이터가 포함되어 있으므로
      // 맥락 리마인더로 감싸지 않고 운세 전달 지시만 추가
      enhancedUserMessage = `${userMessage}

⚠️ 위의 운세 데이터를 반드시 상세하게 전달하세요. 점수, 내용, 행운 아이템, 추천/주의 사항을 모두 포함해서 200자 이상으로 답변하세요.`;
    } else if (limitedHistory.length >= 2) {
      // 일반 대화: 최근 2개 메시지만 리마인더로 추가
      const lastTwo = limitedHistory.slice(-2);
      const contextReminder = lastTwo
        .map((m) =>
          `${m.role === "user" ? "유저" : charName}: ${m.content.slice(0, 50)}${
            m.content.length > 50 ? "..." : ""
          }`
        )
        .join(" → ");

      enhancedUserMessage = `[이전 맥락: ${contextReminder}]
유저의 현재 메시지: ${userMessage}

위 맥락을 이어서, ${charName}로서 자연스럽게 응답하세요. 인사하지 마세요.`;
    }

    // 시간 컨텍스트 생성
    const timeContext = buildTimeContextPrompt(clientTimestamp);
    const relationshipPrompt = buildRelationshipAdaptationPrompt(
      resolvedAffinityContext,
      userId ? "server" : "client",
    );
    const firstMeetPrompt = buildFirstMeetConversationPrompt(
      conversationMode,
      introTurn,
    );
    const memoryPrompt = userId
      ? buildMemoryInjectionPrompt(memoryContext)
      : "";

    const systemPromptSections = [
      fullSystemPrompt,
      traitsPrompt,
      timeContext,
      conversationContext,
      relationshipPrompt,
      firstMeetPrompt,
      memoryPrompt,
      lutsStylePrompt,
      AFFINITY_EVALUATION_PROMPT,
    ].filter((section) => section && section.trim().length > 0);

    const chatMessages: ChatMessage[] = [
      { role: "system", content: systemPromptSections.join("\n\n") },
      ...limitedHistory,
      { role: "user", content: enhancedUserMessage },
    ];

    // 운세 요청 시 더 긴 응답을 위해 maxTokens 증가
    const fortuneMaxTokens = isFortuneRequest ? 4096 : 2048;

    const isLutsGrokFastMode = characterId === LUTS_CHARACTER_ID &&
      modelPreference === "grok-fast";
    let fallbackUsed = false;
    let llmResponse: LLMResponse;

    if (isLutsGrokFastMode) {
      try {
        const grokLlm = LLMFactory.create("grok", "grok-3-mini-fast");
        llmResponse = await grokLlm.generate(chatMessages, {
          temperature: 0.6,
          maxTokens: fortuneMaxTokens,
        });
      } catch (grokError) {
        fallbackUsed = true;
        console.warn(
          "[character-chat] grok-fast failed, fallback to Gemini:",
          grokError,
        );
        const geminiFallbackLlm = LLMFactory.create(
          "gemini",
          "gemini-2.0-flash-lite",
        );
        llmResponse = await geminiFallbackLlm.generate(chatMessages, {
          temperature: 0.6,
          maxTokens: fortuneMaxTokens,
        });
      }
    } else {
      // 기본 경로: DB 기반 character-chat 설정 사용
      const llm = await LLMFactory.createFromConfigAsync("character-chat");
      llmResponse = await llm.generate(chatMessages, {
        temperature: 0.6,
        maxTokens: fortuneMaxTokens,
      });
    }

    const latencyMs = Date.now() - startTime;

    // 후처리: 호감도 평가 추출 → OOC 블록 제거 → 이모티콘 검증
    const { cleanedText: textWithoutAffinity, affinityDelta } =
      extractAffinityDelta(llmResponse.content.trim());
    let responseText = removeOocBlock(textWithoutAffinity);
    responseText = validateEmojiUsage(
      responseText,
      emojiFrequency,
      emoticonStyle,
    );
    if (lutsToneProfile) {
      responseText = applyLutsOutputGuard(
        responseText,
        lutsToneProfile,
        normalizePhase(resolvedAffinityContext.phase),
        voiceProfile,
      );
    }

    // 감정 추출 및 딜레이 계산
    const { emotionTag, delaySec } = extractEmotion(responseText);

    if (userId && supabase) {
      try {
        await sendCharacterDmPush({
          supabase,
          userId,
          characterId,
          characterName: charName,
          messageText: responseText,
          type: "character_dm",
          roomState: "character_chat",
        });
      } catch (pushError) {
        console.error("character-chat 푸시 전송 실패:", pushError);
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        response: responseText,
        emotionTag,
        delaySec,
        affinityDelta,
        meta: {
          provider: llmResponse.provider,
          model: llmResponse.model,
          latencyMs,
          fallbackUsed,
        },
      } as CharacterChatResponse),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (error) {
    console.error("character-chat 에러:", error);

    return new Response(
      JSON.stringify({
        success: false,
        response: "",
        emotionTag: "일상",
        delaySec: 0,
        affinityDelta: { points: 0, reason: "error", quality: "neutral" },
        error: error instanceof Error ? error.message : "Unknown error",
        meta: {
          provider: "unknown",
          model: "unknown",
          latencyMs: Date.now() - startTime,
          fallbackUsed: false,
        },
      } as CharacterChatResponse),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 500,
      },
    );
  }
});
