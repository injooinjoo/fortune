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
 * - userName?: string - 사용자 이름
 * - userDescription?: string - 사용자 설명
 * - oocInstructions?: string - OOC 상태창 포맷 지시
 *
 * @response CharacterChatResponse
 * - success: boolean
 * - response: string - AI 캐릭터 응답
 * - meta: { provider, model, latencyMs }
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { LLMFactory } from "../_shared/llm/factory.ts";
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
    turnGoal = "첫 만남 인사 이후 단계: 사용자의 현재 관심사 1가지를 듣고 가볍게 공감";
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
1) 한 번의 응답에서 질문은 정확히 1개만 하세요.
2) 사전 관계/사건/공동 과거를 절대 가정하지 마세요.
3) 친밀 호칭을 강요하지 말고 중립 호칭을 유지하세요.
4) 초기 3~4턴은 소개/성향 파악 중심으로 진행하세요.
5) 사용자가 운세/문제해결을 명시적으로 요청하면 즉시 본론으로 전환하세요.
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

    // 유저 메시지 앞에 맥락 리마인더 추가 (모델이 바로 직전에 보게 됨)
    let enhancedUserMessage = userMessage;
    if (limitedHistory.length >= 2) {
      // 최근 2개 메시지만 리마인더로 추가
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
      AFFINITY_EVALUATION_PROMPT,
    ].filter((section) => section && section.trim().length > 0);

    const chatMessages: ChatMessage[] = [
      { role: "system", content: systemPromptSections.join("\n\n") },
      ...limitedHistory,
      { role: "user", content: enhancedUserMessage },
    ];

    // LLM 호출 (free-chat 설정 사용, 높은 temperature)
    const llm = LLMFactory.createFromConfig("free-chat");

    const response = await llm.generate(chatMessages, {
      temperature: 0.6, // 맥락 일관성 우선 (0.75 → 0.6)
      maxTokens: 2048, // 긴 응답 허용
    });

    const latencyMs = Date.now() - startTime;

    // 후처리: 호감도 평가 추출 → OOC 블록 제거 → 이모티콘 검증
    const { cleanedText: textWithoutAffinity, affinityDelta } =
      extractAffinityDelta(response.content.trim());
    let responseText = removeOocBlock(textWithoutAffinity);
    responseText = validateEmojiUsage(
      responseText,
      emojiFrequency,
      emoticonStyle,
    );

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
          provider: "gemini",
          model: "gemini-2.0-flash-lite",
          latencyMs,
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
          provider: "gemini",
          model: "gemini-2.0-flash-lite",
          latencyMs: Date.now() - startTime,
        },
      } as CharacterChatResponse),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 500,
      },
    );
  }
});
