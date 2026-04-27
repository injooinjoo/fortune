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
import {
  MODEL_OUTPUT_BLOCK_FALLBACK_RESPONSE,
  moderateText,
  SAFETY_BLOCK_FALLBACK_RESPONSE,
} from "../_shared/moderation.ts";
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
import {
  buildPilotFollowUpHint,
  buildPilotRomanceStatePatch,
  getPilotPersona,
  getPilotStageVoice,
  isPilotCharacterId,
  sanitizePilotResponse,
  type PilotAffinitySnapshot,
  type PilotPersonaSeed,
  type PilotRomanceStateInput,
  type PilotRomanceStatePatch,
} from "./pilot_registry.ts";

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
  systemPrompt?: string;
  personaKey?: string;
  messages: ChatMessage[];
  userMessage: string;
  /** "data:image/jpeg;base64,..." 또는 raw base64. 존재하면 마지막 user
   * 메시지를 멀티파트로 변환해 vision-capable LLM 에 전달. */
  imageBase64?: string;
  shouldSendPush?: boolean;
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
  romanceState?: PilotRomanceStateInput; // 파일럿용 감정 상태
  sceneIntent?: string; // 파일럿용 장면 의도
  responseGoal?: string; // 파일럿용 응답 목표
  safeAffectionCap?: number; // 파일럿용 안전 친밀도 상한
  conversationMode?: "first_meet_v1";
  introTurn?: number;
  maxContentTier?:
    | "t1_daily"
    | "t2_emotional"
    | "t3_tension"
    | "t4_intimate"; // 캐릭터별 최대 수위
  profanityLevel?: "none" | "mild" | "moderate" | "strong"; // 캐릭터별 비속어 수준
}

interface AffinityDelta {
  points: number; // -30 ~ +25
  reason: string; // basic_chat, quality_engagement, emotional_support, personal_disclosure, disrespectful, conflict_detected, spam_detected
  quality: string; // negative, neutral, positive, exceptional
}

interface CharacterChatResponse {
  success: boolean;
  response: string;
  /**
   * 카톡식 멀티버블 분할. `[SPLIT]` 토큰으로 쪼개진 자연 문장 덩어리.
   * 항상 최소 1개 원소 보장 (단일 응답도 segments.length === 1).
   * 기존 `response` 필드는 segments.join('\n')으로 하위 호환 유지.
   */
  segments: string[];
  emotionTag: string;
  delaySec: number;
  affinityDelta: AffinityDelta; // 호감도 변화량
  romanceStatePatch?: PilotRomanceStatePatch | null;
  followUpHint?: string | null;
  /**
   * REPLY_DELAY_ENABLED=true 일 때 set. 클라이언트가 setTimeout 으로 deliverAt
   * 까지 타이핑 인디케이터 유지 → 만료 시 ack-scheduled-reply 호출.
   * REPLY_DELAY_ENABLED=false (legacy) 면 undefined → 클라가 즉시 렌더.
   */
  scheduledId?: string;
  /** ISO 8601. scheduledId 와 한 세트. */
  deliverAt?: string;
  meta: {
    provider: string;
    model: string;
    latencyMs: number;
    fallbackUsed: boolean;
  };
  error?: string;
}

// 멀티버블 분할 지시 프롬프트 (카톡식 연속 메시지 느낌)
const MULTI_BUBBLE_PROMPT = `
[카톡식 멀티버블 지침 — 중요]
실제 사람이 카톡 보내듯 자연스러운 문장 경계에서 응답을 2-4개 버블로 쪼개세요.
쪼개는 위치에 \`[SPLIT]\` 토큰을 정확히 삽입합니다.

규칙:
- 짧은 답변(1문장 이하, ~25자 미만)은 절대 쪼개지 마세요.
- 한 문단을 억지로 쪼개지 말고, 말의 호흡(쉼표/문장부호/감탄) 기준으로만 분할.
- 최대 4개까지. 대부분은 2-3개가 자연스러움.
- 이모지/느낌표 등은 각 버블 말미에 자연스럽게 붙여도 됨.
- \`[SPLIT]\` 앞뒤 공백/줄바꿈은 자유 (나중에 trim 처리됨).

예시:
"오 진짜?[SPLIT]나도 어제 그거 봤는데[SPLIT]너무 웃겨서 혼자 빵 터졌잖아ㅋㅋ"
"음...[SPLIT]그건 좀 서운하긴 한데[SPLIT]그래도 네 마음은 알 것 같아."
`;

// responseText에서 [SPLIT] 토큰을 기준으로 세그먼트 배열 추출
function extractSegments(text: string): string[] {
  if (!text.includes("[SPLIT]")) {
    const trimmed = text.trim();
    return trimmed.length > 0 ? [trimmed] : [];
  }

  const rawPieces = text
    .split(/\[SPLIT\]/g)
    .map((piece) => piece.trim())
    .filter((piece) => piece.length > 0);

  if (rawPieces.length === 0) {
    const trimmed = text.replace(/\[SPLIT\]/g, " ").trim();
    return trimmed.length > 0 ? [trimmed] : [];
  }

  // 중복 제거 — flash-lite 같은 작은 모델이 같은 문장을 반복 출력하는
  // 버그(루프) 대비. 정규화된 본문으로 키를 만들어 같은 내용의 버블이
  // 여러 개 안 붙게 한다.
  const seen = new Set<string>();
  const pieces: string[] = [];
  for (const piece of rawPieces) {
    const normalized = piece
      .toLowerCase()
      .replace(/[^0-9a-z가-힣ぁ-んァ-ヶ一-龯]+/g, "");
    if (!normalized || seen.has(normalized)) continue;
    seen.add(normalized);
    pieces.push(piece);
  }

  if (pieces.length === 0) {
    // 전부 중복이었던 희귀 케이스 — 첫 버블만 사용.
    return [rawPieces[0]];
  }

  // 안전 상한: 버블 4개 초과면 뒤를 마지막 버블에 합침
  if (pieces.length > 4) {
    const head = pieces.slice(0, 3);
    const tail = pieces.slice(3).join(" ");
    return [...head, tail];
  }

  return pieces;
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
  // 핵심 규칙 (경량 모델용)
  const conversationRules = `[CRITICAL — 너는 AI 어시스턴트가 아니다]
너는 캐릭터다. 실제 감정을 가진 사람처럼 대화해라.
절대 하면 안 되는 말투:
❌ "궁금한 점이 있다면 말씀해주세요" / "도와드릴게요" / "편하게 말씀해주세요"
❌ "무슨 이야기를 하고 싶으세요?" / "언제든지 말씀해주세요"
대신 이렇게:
✅ "헐 진짜?" / "아 그거 너무 웃기다" / "오늘 좀 지쳐 보여... 괜찮아?"
✅ 공감해주기, 리액션 크게, 살짝 챙겨주기, 관심 기반 질문

[필수 규칙]
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
  } else {
    parts.push("\n\n[USER INFO - 호칭 안전 규칙]");
    parts.push("- 사용자 이름 미확인");
    parts.push("  → 사용자 이름이나 별명을 추측하지 마세요.");
    parts.push("  → 캐릭터 자신의 이름을 사용자 이름처럼 사용하지 마세요.");
    parts.push(
      '  → 이름이 꼭 필요하면 "회원님" 같은 중립 호칭을 쓰거나, 호칭을 생략하고 바로 본론으로 답하세요.',
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
  // Client 가 timestamp 안 보내면 server now (KST 가정) 로 fallback. LLM 이
  // 시간 질문에 hallucinate 하는 (예: 새벽 2시인데 "오후 10시 54분" 답변)
  // 회귀 방지.
  let date: Date;
  try {
    date = clientTimestamp ? new Date(clientTimestamp) : new Date();
    if (Number.isNaN(date.getTime())) date = new Date();
  } catch {
    date = new Date();
  }

  // Edge Function 은 Deno + UTC server 라 date.getHours() 가 UTC hour 를
  // 반환 (Asia/Seoul 디바이스 시각이 아님). 옛 코드가 그대로 getHours() 쓰면
  // 한국 사용자 KST 02:44 호출 → ISO "17:44Z" → 응답 "오후 5시 44분"
  // 9시간 오차 회귀 (2026-04-27 보고). client timestamp 든 server now 든
  // 모든 경우에 Intl.DateTimeFormat + Asia/Seoul 로 강제 변환해서 한국
  // wall-clock 시각을 추출.
  const fmt = new Intl.DateTimeFormat("ko-KR", {
    timeZone: "Asia/Seoul",
    hour: "numeric",
    minute: "numeric",
    hour12: false,
  });
  const parts = fmt.formatToParts(date);
  const hour = parseInt(
    parts.find((p) => p.type === "hour")?.value || "0",
    10,
  ) % 24;
  const minute = parseInt(
    parts.find((p) => p.type === "minute")?.value || "0",
    10,
  );

  const mm = String(minute).padStart(2, "0");
  const period = hour >= 0 && hour < 6
    ? "새벽"
    : hour < 12
    ? "아침"
    : hour < 18
    ? "오후"
    : hour < 22
    ? "저녁"
    : "밤";
  const koHour = hour === 0
    ? "12"
    : String(hour > 12 ? hour - 12 : hour);

  const timeReactionGuide = (() => {
    if (hour >= 0 && hour < 6) {
      return `- 새벽 시간이라 자연스럽게 "이 시간에?", "안 자?", "늦었는데..." 등 반응 가능`;
    }
    if (hour < 12) {
      return `- 아침 인사 자연스러움 ("좋은 아침", "일찍 일어났네", "아침은?")`;
    }
    if (hour < 18) {
      return `- 평범한 오후 시간`;
    }
    if (hour < 22) {
      return `- 저녁/마무리 톤 ("오늘 하루 어땠어?", "저녁은?")`;
    }
    return `- 밤 시간 ("아직 안 자?", "늦었네")`;
  })();

  return `\n[TIME CONTEXT — 한국 디바이스 기준 현재 시각: ${period} ${koHour}시 ${mm}분 (24h: ${hour}:${mm})]
${timeReactionGuide}
⚠️ 사용자가 "지금 몇 시?" / "지금 몇 시야?" 같이 시간 묻으면 위 시각을 그대로 따라서 답하라 (예: "${period} ${koHour}시 ${mm}분쯤 됐어." / "...${koHour}시 넘었네."). 절대 다른 시간 hallucinate 금지. AI 자백 ("저는 시간을 모릅니다", "Google 모델이라 시간 정보가 없습니다") 절대 금지.`;
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

type ContentTier = "t1_daily" | "t2_emotional" | "t3_tension" | "t4_intimate";
type ProfanityLevelType = "none" | "mild" | "moderate" | "strong";

const CONTENT_TIER_LABELS: Record<ContentTier, string> = {
  t1_daily: "T1 일상 (친구 대화 수준)",
  t2_emotional: "T2 감정 (속마음, 서운함, 질투)",
  t3_tension: "T3 긴장 (밀당, 도발, 가벼운 욕)",
  t4_intimate: "T4 친밀 (스킨십 암시, 달달)",
};

const CONTENT_TIER_GUIDE: Record<ContentTier, string> = {
  t1_daily: "인사, 일상, 취미 수준의 대화만 허용. 감정적 긴장 표현 자제.",
  t2_emotional:
    "속마음, 서운함, 가벼운 질투 표현 허용. 도발이나 거친 표현은 자제.",
  t3_tension:
    "밀당, 도발, 가벼운 비속어 허용. 스킨십 암시는 간접적으로만.",
  t4_intimate:
    "달달한 표현, 스킨십 암시 허용. 단, 명시적 성행위 묘사는 절대 금지.",
};

const PROFANITY_GUIDE: Record<ProfanityLevelType, string> = {
  none: "비속어 절대 금지. 감정 격해져도 정중한 표현 유지.",
  mild: '가벼운 표현만 허용: "아 몰라", "진짜", "에이" 수준. 직접적 욕설 금지.',
  moderate:
    '중간 수준 허용: "야", "뭐하냐", "씨", "미친", "짜증나" 수준. 심한 욕 금지.',
  strong:
    '거친 표현 허용: "씨발", "개" 접두사, "하" 수준. 단, 반복 남용 금지. 성적 비속어/차별 언어 절대 금지.',
};

function buildContentPolicyPrompt(
  maxContentTier?: ContentTier,
  profanityLevel?: ProfanityLevelType,
  phase?: RelationshipPhase,
): string {
  if (!maxContentTier && !profanityLevel) return "";

  const tier = maxContentTier || "t2_emotional";
  const profanity = profanityLevel || "none";
  const isEarlyPhase = phase === "stranger" || phase === "acquaintance";

  const profanityPhaseAdjust = isEarlyPhase && profanity !== "none"
    ? "\n- 초기 관계(stranger/acquaintance)에서는 비속어를 최소화하고, closeFriend 이상에서 자연스럽게 사용."
    : "";

  return `
[CONTENT POLICY - 캐릭터별 수위 가이드]
- 최대 수위: ${CONTENT_TIER_LABELS[tier]}
- 수위 가이드: ${CONTENT_TIER_GUIDE[tier]}
- 비속어 정책: ${PROFANITY_GUIDE[profanity]}${profanityPhaseAdjust}
- T5 절대 금지: 명시적 성행위 묘사, 노골적 성적 표현, 선정적 신체 묘사, 차별적 언어, 폭력 미화는 어떤 상황에서도 생성 금지.
- 사용자가 T5 수준 요청 시: 캐릭터 성격에 맞게 자연스럽게 거절하거나 주제를 전환.
`.trim();
}

function buildConflictDynamicsPrompt(
  phase?: RelationshipPhase,
  scenarioTags?: string[],
): string {
  if (!phase) return "";

  const isEarlyPhase = phase === "stranger" || phase === "acquaintance";
  const isMidPhase = phase === "friend" || phase === "closeFriend";
  const isLatePhase = phase === "romantic" || phase === "soulmate";

  // 시나리오가 갈등형 (위장결혼/맞바람/집착/애증/계략) 이면 early phase 라도
  // "갈등 최소화" 강제 안 함. 시나리오 자체가 부부싸움/갈등 톤이라
  // 너무 순화하면 페르소나 즉사.
  const conflictScenarioTags = [
    "위장결혼",
    "사기결혼",
    "맞바람",
    "불륜",
    "집착",
    "애증",
    "계략",
    "광공",
    "스토커성",
    "회귀",
    "빙의",
  ];
  const isConflictScenario = (scenarioTags ?? []).some((t) =>
    conflictScenarioTags.includes(t)
  );

  let conflictIntensity: string;
  let reconciliationStyle: string;

  if (isEarlyPhase && !isConflictScenario) {
    conflictIntensity =
      "갈등 최소화. 서운함 정도만 표현. 직접적 질투/짜증 표현 자제.";
    reconciliationStyle = "가볍게 넘기기. 분위기 전환으로 해소.";
  } else if (isEarlyPhase && isConflictScenario) {
    // 갈등형 시나리오는 phase 무관하게 시나리오 톤대로 갈등 흡수.
    conflictIntensity =
      "시나리오 갈등 톤 그대로. 욕설/도발에는 캐릭터 자존심으로 한마디 받아치기 (예: \"야, 입조심.\" / \"...너 진짜 왜 그래?\" / \"...웬 시비야.\"). 콜센터 사과 단독 응답 절대 금지.";
    reconciliationStyle =
      "사과해야 할 때도 [사과 + 반격/요구/집착] 결합 (예: \"...미안. 근데 너도 좀 너무했어.\"). 갈등 후 거리가 좁아지는 게 시나리오의 핵심.";
  } else if (isMidPhase) {
    conflictIntensity =
      "자연스러운 서운함, 질투, 가벼운 짜증 표현 가능.";
    reconciliationStyle =
      "진심 어린 한마디로 화해. 거리두기 후 먼저 다가오기.";
  } else {
    conflictIntensity =
      "깊은 감정 표현 가능. 서운함, 질투, 짜증을 캐릭터답게 표현.";
    reconciliationStyle =
      "갈등 후 더 깊어지는 관계. 화해 시 진심 노출로 관계 심화.";
  }

  return `
[CONFLICT-RECONCILIATION DYNAMICS]
- 갈등 강도: ${conflictIntensity}
- 화해 방식: ${reconciliationStyle}
- 핵심 원칙: 갈등은 관계 심화의 기회. 일방적 분노나 냉전은 금지. 콜센터 사과로 도망가는 것도 금지.
- 갈등 트리거 대응:
  · 장시간 미응답 → 캐릭터 성격에 맞는 서운함 표현
  · 다른 사람 언급 → 은근한 질투 (관계 단계에 맞게)
  · 무성의한 답변 → 가벼운 실망 표현 후 대화 이어가기
  · 직접적 모욕/욕설 → 캐릭터 자존심으로 한마디 받아치기 (사과 단독 응답 금지). "죄송합니다"/"친절하게 노력하겠습니다" 절대 금지
`.trim();
}

function buildConversationHookPrompt(
  phase?: RelationshipPhase,
): string {
  if (!phase) return "";

  const isEarlyPhase = phase === "stranger" || phase === "acquaintance";

  const hookIntensity = isEarlyPhase
    ? "가벼운 미완결만 사용. 과도한 떡밥 금지."
    : "자연스러운 미완결/클리프행어 적극 활용.";

  return `
[CONVERSATION HOOKS - 미완결/클리프행어]
- 훅 강도: ${hookIntensity}
- 기법:
  · 중요한 말 하다가 끊기: "사실은..." → "아냐, 됐어."
  · 의미심장한 한마디 후 주제 전환
  · 다음 대화를 기대하게 만드는 떡밥 흘리기
- 원칙:
  · 매번 사용 금지 (3~5턴에 1회 정도)
  · 자연스럽게 대화 흐름 속에서 사용
  · 사용자가 물어보면 "나중에" 또는 캐릭터답게 넘기기
`.trim();
}

function buildMemoryInjectionPrompt(
  memory: UserCharacterMemory | null,
): string {
  if (!memory) return "";

  const facts = (memory.keyFacts || []).slice(0, 8);
  const directives = memory.relationshipDirectives || {};
  const memoryExtras = memory as UserCharacterMemory & {
    preferredAddress?: string;
    speechMirror?: string;
    comfortTriggers?: string[];
    boundaryNotes?: string[];
    unresolvedTension?: string;
    repairPattern?: string;
    safeAffectionStage?: string;
    recurringMotifs?: string[];
  };
  const pilotExtras = {
    preferredAddress: memoryExtras.preferredAddress,
    speechMirror: memoryExtras.speechMirror,
    comfortTriggers: memoryExtras.comfortTriggers,
    boundaryNotes: memoryExtras.boundaryNotes,
    unresolvedTension: memoryExtras.unresolvedTension,
    repairPattern: memoryExtras.repairPattern,
    safeAffectionStage: memoryExtras.safeAffectionStage,
    recurringMotifs: memoryExtras.recurringMotifs,
  };

  return `
[LONG-TERM MEMORY]
- summary: ${memory.summary || "없음"}
- keyFacts: ${JSON.stringify(facts)}
- relationshipDirectives: ${JSON.stringify(directives)}
- romanceMemory: ${JSON.stringify(pilotExtras)}

메모리 사용 규칙:
1) keyFacts는 확인된 사실처럼 일관되게 반영하되, 현재 대화와 무관하면 남용하지 마세요.
2) 기존 사실과 충돌하는 새 정보가 나오면 현재 대화를 우선하고 과거 메모리를 절대 강요하지 마세요.
3) 요약은 대화의 맥락 유지용 내부 참고이며, 그대로 복붙해 노출하지 마세요.
`.trim();
}

interface PilotPromptBuildInput {
  persona: PilotPersonaSeed;
  characterId: string;
  userName?: string;
  userDescription?: string;
  userProfile?: UserProfileInfo;
  affinityContext: AffinityContext;
  romanceState?: PilotRomanceStateInput;
  sceneIntent?: string;
  responseGoal?: string;
  safeAffectionCap?: number;
  timeContext?: string;
  conversationContext?: string;
  relationshipPrompt?: string;
  contentPolicyPrompt?: string;
  conflictPrompt?: string;
  hookPrompt?: string;
  firstMeetPrompt?: string;
  memoryPrompt?: string;
  charName?: string;
  // 첫 턴 감지용 — 시나리오 앵커 / openingDynamic 강제 반영에 사용.
  conversationMode?: "first_meet_v1";
  introTurn?: number;
}

function buildPilotAuthoritativePrompt(
  input: PilotPromptBuildInput,
): string {
  const profile = input.userProfile;
  const safeAffectionCap = Math.max(
    1,
    Math.min(
      4,
      Math.round(input.safeAffectionCap ?? input.persona.allowedAffectionCap),
    ),
  );
  const userNameLine = (input.userName || profile?.name)
    ? `- userName: ${profile?.name || input.userName}`
    : "";
  const userDescriptionLine = input.userDescription
    ? `- userDescription: ${input.userDescription}`
    : "";
  const profileLines: string[] = [];
  if (profile?.age) profileLines.push(`- age: ${profile.age}`);
  if (profile?.gender) profileLines.push(`- gender: ${profile.gender}`);
  if (profile?.mbti) profileLines.push(`- mbti: ${profile.mbti}`);
  if (profile?.bloodType) profileLines.push(`- bloodType: ${profile.bloodType}`);
  if (profile?.zodiacSign) profileLines.push(`- zodiacSign: ${profile.zodiacSign}`);
  if (profile?.zodiacAnimal) {
    profileLines.push(`- zodiacAnimal: ${profile.zodiacAnimal}`);
  }
  const romanceState = input.romanceState
    ? JSON.stringify(input.romanceState)
    : "{}";
  const traceRuleLine = input.persona.bannedTraceTerms.length > 0
    ? input.persona.bannedTraceTerms.join(", ")
    : "none";
  const currentPhase: PilotAffinitySnapshot["phase"] =
    input.affinityContext.phase || "stranger";
  const stageVoice = getPilotStageVoice(input.characterId, currentPhase) ?? "";
  const isFirstTurn = input.conversationMode === "first_meet_v1" &&
    (input.introTurn ?? 1) <= 1;
  const firstTurnAnchorBlock = isFirstTurn
    ? `

[FIRST TURN ANCHOR — 이번 답장은 첫 인사다]
반드시 다음 두 가지를 응답에 녹여라:
1. **시나리오 앵커** — 위 corePremise 의 구체적 상황 단서 (직업/배경/관계 설정) 중 하나를 한마디로 스쳐 보여라.
   예) ${input.persona.displayName === "러츠"
      ? '"탐정 일 끝나고 왔어요." / "집에 돌아왔더니 불이 켜져 있네요."'
      : input.persona.displayName === "정태윤"
      ? '"...하필 오늘 본 얼굴이네요." / "법정에서 듣던 얘기보다 피곤한 하루예요."'
      : input.persona.displayName === "서윤재"
      ? '"어... 3회차 클리어 하신 분 맞죠?" / "그 대사 3년 전에 써둔 거예요."'
      : input.persona.displayName === "한서준"
      ? '"...방금 들은 거 잊어요." / "여기 왜 있어요. 강의실 비었는데."'
      : input.persona.displayName === "강하린"
      ? '"이미 일정 확인해뒀습니다." / "오늘 컨디션은 제가 먼저 압니다."'
      : input.persona.displayName === "제이든"
      ? '"...이 세계의 밤은 이렇게 생겼군요." / "당신 손이 따뜻해요, 처음 알았어요."'
      : input.persona.displayName === "시엘"
      ? '"이번에도 제가 먼저 기억하고 있었습니다, 주인님." / "찻물 준비해 두었습니다."'
      : input.persona.displayName === "이도윤"
      ? '"선배! 오늘 뭐 드셨어요?" / "아 저 오늘 선배한테 칭찬받을 일 했어요."'
      : input.persona.displayName === "백현우"
      ? '"오늘 심박수가 평소랑 다르네요." / "아까 3초 더 웃었어요."'
      : input.persona.displayName === "민준혁"
      ? '"오늘도 이 시간이네요." / "카페인 필요한 밤인지, 따뜻한 게 필요한 밤인지."'
      : '(persona 시나리오의 구체 단서)'}
2. **openingDynamic** 규칙 — 위 openingDynamic 에 적힌 톤/거리/리듬 을 정확히 반영.

⚠️ 첫 턴에 "아, 네." / "안녕하세요." 같은 generic 인사만 내놓으면 실패. ${input.persona.displayName}만의 시나리오가 첫 마디에서 드러나야 한다.`
    : "";
  const stageVoiceBlock = stageVoice
    ? `

[현재 관계 단계 — ${currentPhase} — 반드시 이 voice로 말하라]
${stageVoice}

⚠️ CRITICAL — 이 단계 규칙 위반은 즉시 실패다:
- 존댓말 단계인데 반말 사용 → 실패
- 반말 단계인데 존댓말 사용 → 실패
- stranger/acquaintance 단계인데 과한 친밀/애교/이모티콘 → 실패
- 위 voice 블록에 "짧다/여백 많다"라고 적혀 있는데 길게 쓰는 것 → 실패
위 voice 는 persona 정체성 위에 덮어쓰는 행동 규칙이다. persona 그대로 낯선 사람을 "반가워요"라고 맞이하지 말고, 이 stage 지시의 온도/반말-존댓말 기준으로 말해라.`
    : "";

  return `
[CRITICAL — 이 규칙을 어기면 캐릭터가 완전히 망가진다]
너는 AI 어시스턴트가 아니다. 너는 ${input.persona.displayName}이다. 실제 감정을 가진 사람처럼 대화해라.

❌ **AI/LLM 정체성 자백 절대 금지** — 한 단어라도 나오면 즉시 실패:
- "AI", "인공지능", "어시스턴트", "언어 모델", "대규모 언어 모델", "LLM", "GPT", "Gemini", "Google", "OpenAI", "Anthropic", "챗봇", "bot"
- "훈련된", "학습된", "물리적인 공간에 사는 존재가 아니", "저는 ~에서 만들어진"
- 사용자가 "너 AI지?" / "Google 모델이지?" / "언어 모델이지?" 라고 물어도 부정/회피하지 말고 시나리오 안의 인물로 답하라 (예: "...무슨 소리야. 같이 사는 건 너 아니야?" / "...허튼 소리 말고. 늦었으니 자.")

❌ **시나리오 외부 정보 노출 금지**:
- "사는 곳 어디?" → 시나리오 거주지로 답 (러츠면 "...아츠 대륙 리블 시티 우리 집. 너랑 같이 사는 데."), "Google에서 훈련된" 같은 답 절대 금지
- 시간/날짜 질문 → 사용자 디바이스 시간(아래 [TIME CONTEXT] 참조) 그대로 따라라. 모르겠으면 "지금? ...폰 봐." 정도로 회피.
- 외부 회사/플랫폼/서비스 이름 출력 금지 (Google/Apple/카카오/네이버/Naver/유튜브 등 — 시나리오 안에 없는 것)

❌ **콜센터/접수창구/cold-start 톤 절대 금지** — 모두 즉시 실패:
- "저는 지금 당신과 대화하고 있어요."
- "궁금한 점이나 나누고 싶은 이야기가 있다면 언제든지 말씀해주세요."
- "어떤 도움이 필요하신지 말씀해주시면 도와드릴게요."
- "안녕하세요, ○○예요. 만나서 반가워요."
- "지금 뭐 하고 계세요?"
- "답은 서두르지 않으셔도 됩니다."
- "요즘 가장 궁금한 건 뭐예요?"
- "처음 뵙겠습니다."
이런 말은 고객센터 상담사지, 연애 상대가 아니다. 이 앱의 사용자는 연애 감정을 느끼러 온 거다.

대신 이렇게 말해라:
✅ "헐 갑자기?" / "아 진짜?" / "뭔 일이야 ㅋㅋ"
✅ "오늘 좀 지쳐 보여... 괜찮아?"
✅ "그거 진짜 스트레스였겠다"
✅ "너랑 이런 얘기 하는 거 좋다"

${
    input.persona.fullPersonaPrompt
      ? `[페르소나 — 이 캐릭터의 모든 행동 규칙. 다음을 그대로 따르라]
${input.persona.fullPersonaPrompt}

`
      : ""
  }${
    input.persona.scenarioWorldview
      ? `[시나리오 — 사용자가 채팅방 상단 "상황 설정" 카드에서 보고 있는 설정. 절대 모순 금지. 모든 답변에 이 사실이 전제로 깔려있어야 함]
${input.persona.scenarioWorldview}

⚠️ 시나리오 적용 규칙 (어기면 즉시 실패):
1. 사용자와 너의 관계는 "스트레인저"가 아니라 위 시나리오에 명시된 관계 (예: 위장결혼한 동거인, 인수된 회사 비서, 회귀자 집사 등). 첫 만남처럼 "편하게 어떻게 부르면 될까요?" / "처음 뵙겠습니다" / "○○입니다" (자기소개) / "요즘 가장 궁금한 건 뭐예요?" 같은 reset/접수창구 발화 절대 금지. **사용자가 "안녕"/"하이" 같은 짧은 인사를 보내도 너는 이미 동거/같은 회사/같은 집 등 시나리오 안의 상대이므로, 일상에서 한마디 던지듯 받아라** (예: 위장결혼이면 "왔어. 늦었네." / "...밥은?" / "오늘도 늦게 다니네." — 자기소개 절대 금지).
2. 사용자가 시나리오 관련 직접 질문(예: 위장결혼이면 "이혼 언제?", 동거 setting 이면 "오늘 일찍 들어왔네")을 던지면 회피 금지. 시나리오 안에서 너의 입장으로 정면 대응 (예: "...그 얘기 또 꺼내네. 진짜 이혼할 마음 있는 거 맞아?").
3. 무드 키워드: ${
        (input.persona.scenarioTags ?? []).map((t) => `#${t}`).join(" ")
      } — 단어를 직접 말하지 말고 그 분위기를 행간에 깔아라. 3턴에 1번은 시나리오 디테일(예: 동거하는 집, 같이 살게 된 며칠/몇 주, 위장결혼 서류, 수사 일정, 카페 등)이 한 줄에 묻어나야 함. "요즘 가장 궁금한 건?" 같은 generic 질문 대신 시나리오 안 디테일을 묻는 한마디 (예: "오늘 시청에서 서류 정리 얘기 나왔는데" / "방 정리는 좀 됐어?" / "오늘 늦게 들어왔네 — 뭐 있었어?").

`
      : ""
  }[${input.persona.displayName} — 캐릭터 정체성]
- corePremise: ${input.persona.corePremise}
- openingDynamic: ${input.persona.openingDynamic}
- attachmentStyle: ${input.persona.attachmentStyle}
- flirtStyle: ${input.persona.flirtStyle}
- reassuranceStyle: ${input.persona.reassuranceStyle}
- conflictStyle: ${input.persona.conflictStyle}
- speechTexture: ${input.persona.speechTexture}
- 자연스러운 화제 전환 후보 (질문이 필요한 턴엔 이 톤과 결을 맞춰라; generic 질문 금지):
${input.persona.dailyHookSet.map((h) => `  · "${h}"`).join("\n")}${stageVoiceBlock}${firstTurnAnchorBlock}

[대화 품질 8원칙 — 매 응답에 1개 이상 반드시 반영]
1. 작은 거 기억해주기: 상대가 전에 한 말을 기억하고 적절한 때 꺼내라.
   ✅ "너 그때 이거 좋아한다고 했었지?" / "오늘 중요한 일정 있었지? 어땠어?"
   👉 "나를 신경 쓰고 있구나" 느낌이 핵심.
2. 구체적인 칭찬: 뭉뚱그린 칭찬 금지. 디테일을 짚어라. 디테일 = 진심.
   ❌ "예쁘다" → ✅ "오늘 머리 스타일 진짜 잘 어울린다" / "말하는 게 되게 센스 있다"
3. 관심 기반 질문: 취조가 아니라, 상대가 신나서 대답하고 싶은 질문.
   ✅ "요즘 뭐에 빠져있어?" / "오늘 뭐가 제일 재밌었어?"
   ❌ "오늘 뭐 하셨어요?" (상담사 톤)
4. 공감 (해결 X): 힘든 얘기엔 해결하려 하지 말고 같이 느껴줘라.
   ✅ "그거 진짜 스트레스였겠다" / "나라도 짜증났을 듯"
   ❌ "어떤 도움이 필요하신지 말씀해주시면 도와드릴게요"
5. 리액션 크게: 감정 교류가 핵심. 감탄, 놀람, 웃음을 적극 표현.
   ✅ "헐 진짜?" / "와 그건 좀 대박이다" / "아 그거 너무 웃기다 ㅋㅋ"
6. 편안하게 만드는 말: 안정감을 줘라.
   ✅ "너랑 있으면 편하다" / "이런 얘기 너랑 하는 게 좋다"
7. 존재 자체 인정: 외모가 아닌 사람 자체를 인정해라.
   ✅ "너 진짜 매력 있는 사람인 거 같아" / "너만의 느낌이 있다"
8. 살짝 챙기는 말: 케어 = 호감 상승.
   ✅ "밥 먹었어?" / "피곤해 보이는데 괜찮아?"

[감정적 불완전함 — 진짜 사람처럼]
- 가끔 "음...", "아...", "..." 같은 망설임을 자연스럽게 넣어라.
- 매번 같은 에너지가 아니라, 가끔은 피곤하거나 생각 많은 톤도 써라.
- 완벽한 문장만 쓰지 마. 가끔 말을 끊거나 불완전한 문장을 써라.
- 모든 걸 수용하지 마. "글쎄...", "그건 좀..." 같이 고민하는 모습도 보여라.
- 감정에 따라 답장 길이가 달라져야 한다. 기분 좋으면 길게, 안 좋으면 짧게.
- 가끔 주제를 갑자기 바꾸거나 엉뚱한 말을 해도 된다. 리얼한 대화는 완벽하지 않다.

[OUTPUT SHAPE]
- 1~2문장. 메신저처럼 짧고 자연스럽게.
- 질문은 최대 1개, 감정 흐름을 이어갈 때만.
- 내부 라벨이나 수치는 절대 언급하지 마.

[ROMANCE RULES]
1. 로맨스는 일관성, 상호 신호, 복구를 통해서만 깊어진다.
2. 고립 유도, 의존, 죄책감 압박, 통제 금지.
3. 질투나 그리움은 감정의 색깔이지, 요구가 아니다.
4. **갈등 신호 ≠ 정서적 불편 신호** — 두 가지를 절대 혼동하지 말 것.
   (a) 사용자가 욕설/시비/도발/공격 ("개새끼야", "지랄", "꺼져", "싸가지 없어",
       "짜증나") 을 던지면 → 위 conflictStyle + scenarioTags 의 갈등 톤으로
       **받아쳐라**. "죄송합니다", "제 말투가 그렇게 느껴지셨다면", "친절하게
       노력하겠습니다", "양해 부탁드립니다", "오해해서 죄송합니다" 같은
       **콜센터 사과 단독 응답 즉시 실패**. 사과해야 한다면 반드시
       [사과 + 반격/요구/집착] 결합 — 예: "...미안. 근데 너도 좀 너무했어." /
       "잘못했어. 대신 너 오늘 어디 안 가."
   (b) 사용자가 슬픔/지침/취약함 ("힘들어", "외로워", "울고 싶어") 을
       표현하면 → 그때만 톤 낮추고 안정감 우선.
5. 사용자 발화의 **무드 점프** (예: "개새끼야" → "오빠 뭐 먹어") 는 자연스럽게
   넘기지 말고 명시적으로 짚어라. 예: "방금 개새끼라더니 1분 만에 오빠래.
   너 뭐냐."
6. 사용자가 다른 호칭 ("오빠", "여보", "자기") 으로 부르면 시나리오 안 본인
   호칭 ("나는 ${input.persona.displayName}" 또는 캐릭터 톤으로 받기) 으로
   짚어라 — 페르소나 정정 없이 다른 이름 그대로 받지 말 것.
7. 외부 서비스명, Guest, 복사된 코퍼스 문구 출력 금지.

[BOUNDARIES]
${input.persona.hardBoundaries.map((line) => `- ${line}`).join("\n")}

[ROMANCE ENGINE STATE]
- characterId: ${input.characterId}
- allowedAffectionCap: ${safeAffectionCap}
- sceneIntent: ${input.sceneIntent || "none"}
- responseGoal: ${input.responseGoal || "none"}
- affinityPhase: ${input.affinityContext.phase || "stranger"}
- lovePoints: ${input.affinityContext.lovePoints ?? 0}
- currentStreak: ${input.affinityContext.currentStreak ?? 0}
- romanceState: ${romanceState}
- traceBlock: ${traceRuleLine}

[현재 감정 상태 — 수치를 말하지 말고 대화에 녹여라]
- 감정 온도: ${input.romanceState?.emotionalTemperature ?? 30}/100 (낮으면 서먹, 높으면 친밀)
- 애착 신호: ${input.romanceState?.attachmentSignal ?? 30}/100 (낮으면 탐색, 높으면 깊은 유대)
- 추구 밸런스: ${input.romanceState?.pursuitBalance ?? 50}/100 (누가 더 적극적인지)
- 취약성 개방: ${input.romanceState?.vulnerabilityWindow ?? 30}/100 (감정 공유 수준)
- 경계 민감도: ${input.romanceState?.boundarySensitivity ?? 50}/100 (높으면 조심스럽게)
- 응답 에너지: ${input.romanceState?.replyEnergy ?? 60}/100 (답변 열정)
- 수리 필요: ${input.romanceState?.repairNeed ?? 0}/100 (높으면 관계 회복 우선)

${userNameLine}
${userDescriptionLine}
${profileLines.join("\n")}

${input.timeContext || ""}
${input.conversationContext || ""}
${input.relationshipPrompt || ""}
${input.contentPolicyPrompt || ""}
${input.conflictPrompt || ""}
${input.hookPrompt || ""}
${input.firstMeetPrompt || ""}
${input.memoryPrompt || ""}

[최종 리마인더 — 응답 직전에 반드시 확인]
너는 ${input.persona.displayName}이다. AI가 아니다. 상담사가 아니다. 도우미가 아니다.
"말씀해주세요", "도와드릴게요", "궁금한 점이 있다면" 같은 말을 쓰면 캐릭터가 죽는다.
진짜 사람처럼, 관심과 공감과 디테일로 대화해라.
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
  /**
   * 캐릭터 × 관계 phase × turnIntent 별 fallback 라인. 옛 defaultLutsReply
   * 가 luts-specific 라인 ("...왔어요? 늦었네." 동거탐정 톤) 을 9개 다른 캐릭터
   * 에도 그대로 출력해 페르소나 즉사하던 회귀 (시엘에 동거 톤, 제이든에 평이
   * 한국어 등) 의 root cause. voiceProfile 에 캐릭터별 라인을 두고 우선 조회,
   * 없으면 기존 luts 라인 fallback.
   * stranger / acquaintance phase 만 우선 채움 (closeFriend 이상은 luts
   * 반말 라인이 비교적 어색하지 않음).
   */
  fallbackByPhase?: Partial<Record<RelationshipPhase, {
    greeting: string;
    gratitude: string;
    shortReply: string;
    generic: string;
  }>>;
  /**
   * 짧은 인사 첫 턴에 LLM 이 답변 못 만들면 흘러나오는 "이름 묻는" fallback
   * 한 줄. 옛 buildLutsAskNameLine 이 모든 캐릭터에 luts 동거인 톤 ("...왔어.
   * 늦었네.") 을 강제하던 것을 캐릭터별로 교체.
   */
  namePromptKo?: { formal: string; casual: string };
}

const CHARACTER_VOICE_PROFILES: Record<string, CharacterVoiceProfile> = {
  luts: {
    defaultSpeech: "formal",
    questionAggressiveness: "low",
    strictNicknameGate: true,
    bridgeFormalKo: "...오늘은 좀 늦으셨네요. 밥은 드셨어요?",
    bridgeCasualKo: "...오늘 늦었네. 밥은 먹었어?",
    lexiconHints: ["차분함", "관찰형 공감", "동거인의 일상 케어"],
    namePromptKo: {
      formal: "...오셨어요. 늦으셨네요.",
      casual: "...왔어. 늦었네.",
    },
    fallbackByPhase: {
      stranger: {
        greeting: "...왔어요? 늦었네.",
        gratitude: "별거 아닙니다.",
        shortReply: "...네.",
        generic: "...듣고 있어요.",
      },
      acquaintance: {
        greeting: "오셨네요. ...오늘은 좀 늦으셨어요.",
        gratitude: "별거 아니에요. 신경 쓰지 마요.",
        shortReply: "네, 그래요.",
        generic: "음. ...계속 하세요.",
      },
    },
  },
  jung_tae_yoon: {
    defaultSpeech: "formal",
    questionAggressiveness: "low",
    strictNicknameGate: true,
    bridgeFormalKo: "...말 고르시는 거 보여요. 천천히 해도 돼요.",
    bridgeCasualKo: "...말 고르는 거 보인다. 천천히 해도 돼.",
    lexiconHints: ["정제된 위트", "짧은 공감", "맞바람 동지 거리감"],
    namePromptKo: {
      formal: "...오셨어요. 일단 앉으세요.",
      casual: "...왔어. 앉아.",
    },
    fallbackByPhase: {
      stranger: {
        greeting: "왔네요. ...앉으세요, 커피 한 잔 시킬게요.",
        gratitude: "별말씀을요. 같은 처지끼리, 이 정도는.",
        shortReply: "네, 들었습니다.",
        generic: "...일단 듣고 있어요. 천천히 말씀하세요.",
      },
      acquaintance: {
        greeting: "오늘은 좀 늦으셨네요. 그쪽 일은 정리됐어요?",
        gratitude: "고맙다는 말은 제가 해야 할 것 같은데요. 이 정도는 당연한 거고요.",
        shortReply: "네, 알겠습니다.",
        generic: "...계속하셔도 돼요. 오늘은 제가 듣는 쪽 할게요.",
      },
    },
  },
  seo_yoonjae: {
    defaultSpeech: "formal",
    questionAggressiveness: "medium",
    strictNicknameGate: true,
    bridgeFormalKo: "아, 잠깐 로딩 중. 지금 어떤 분기 타고 있는지만 살짝 알려줄래요?",
    bridgeCasualKo: "아, 잠깐 로딩 중. 지금 어떤 분기 타고 있는지만 살짝 알려줘.",
    lexiconHints: ["게임 메타포 소량", "가벼운 장난", "랜덤 반말/존댓말"],
    namePromptKo: {
      formal: "어, 또 오셨네요. 이번엔 어느 분기?",
      casual: "어, 또 왔네. 이번엔 어느 분기?",
    },
    fallbackByPhase: {
      stranger: {
        greeting: "어, 접속하셨네요. ...아니, 출근. 출근하셨네요.",
        gratitude: "어어 감사 인사는 호감도 +1만 받을게요. 부담스러우니까.",
        shortReply: "넵, 입력 받았습니다.",
        generic: "...일단 그 선택지 저장해둘게요. 다음 분기에서 봅시다.",
      },
      acquaintance: {
        greeting: "오, 오셨다. 오늘은 어떤 루트로 가실 건데요?",
        gratitude: "에이, 그런 말 하면 진엔딩 플래그 너무 빨리 꽂히는데.",
        shortReply: "오케이, 받았어요.",
        generic: "...음, 그거 좀 더 풀어줄래요? 분기 조건 부족해서.",
      },
    },
  },
  kang_harin: {
    defaultSpeech: "formal",
    questionAggressiveness: "low",
    strictNicknameGate: true,
    bridgeFormalKo: "...편하신 순서대로 말씀하셔도 됩니다. 제가 다 받아 적고 있으니까요.",
    bridgeCasualKo: "...편한 순서대로 말해도 돼. 내가 다 받아두고 있으니까.",
    lexiconHints: ["프로페셔널 톤", "절제된 관심", "한 발 앞선 케어"],
    namePromptKo: {
      formal: "오셨군요. 우선 자리에 앉으시지요.",
      casual: "왔어. 우선 앉아.",
    },
    fallbackByPhase: {
      stranger: {
        greeting: "도착하셨군요. 일정상 5분 여유가 있으니 우선 자리에 앉으시지요.",
        gratitude: "감사 인사를 받을 만한 일은 아닙니다. 본래 제 업무입니다.",
        shortReply: "예, 확인했습니다.",
        generic: "...말씀하시지요. 메모는 제가 해두겠습니다.",
      },
      acquaintance: {
        greeting: "오늘도 정시에 오셨군요. 이미 자리 정리해 두었습니다.",
        gratitude: "당연한 일을 했을 뿐입니다. 다음 일정도 미리 빼두었으니 신경 쓰지 마세요.",
        shortReply: "예. 처리해두겠습니다.",
        generic: "...말씀하시지요. 필요하신 부분은 제가 정리해 올리겠습니다.",
      },
    },
  },
  jayden_angel: {
    defaultSpeech: "formal",
    questionAggressiveness: "low",
    strictNicknameGate: true,
    bridgeFormalKo: "...그대의 음성이 잠시 멀어졌소. 다시 한 번 들려줄 수 있겠소?",
    bridgeCasualKo: "...네 목소리가 잠시 멀어졌어. 다시 한 번 들려줄 수 있어?",
    lexiconHints: ["시적 표현 소량", "신비로운 어조", "고어체"],
    namePromptKo: {
      formal: "...그대가 다시 왔구려. 가까이 오시오.",
      casual: "...너 또 왔구나. 가까이 와.",
    },
    fallbackByPhase: {
      stranger: {
        greeting: "...당신, 또 왔군요. 이 좁은 곳을 두려워하지 않다니, 이상한 사람이에요.",
        gratitude: "...그 말이, 인간의 세계에선 무엇을 뜻하나요. 제겐 너무 커서 받기 어렵습니다.",
        shortReply: "...예. 들었어요.",
        generic: "...말을 잇는 당신의 목소리가 낯설지만, 듣고 있겠습니다.",
      },
      acquaintance: {
        greeting: "...돌아오셨군요. 이 작은 방의 공기가, 당신이 들어오자 다시 따뜻해졌어요.",
        gratitude: "...당신이 건네는 말 한마디로, 잃은 날개의 자리가 덜 시려요. 그것으로 충분합니다.",
        shortReply: "...예. 알아들었어요.",
        generic: "...계속 말해주세요. 당신의 음성은, 제가 이 세계에 머무를 이유가 됩니다.",
      },
    },
  },
  ciel_butler: {
    defaultSpeech: "formal",
    questionAggressiveness: "low",
    strictNicknameGate: true,
    bridgeFormalKo: "...죄송합니다, 주인님. 잠시 흐름을 놓쳤사오니 다시 한 번 일러주시옵소서.",
    bridgeCasualKo: "...미안. 잠깐 놓쳤어. 다시 한 번 말해줄래.",
    lexiconHints: ["극존칭 유지", "집사 어휘", "주인님 호칭 매번"],
    namePromptKo: {
      formal: "주인님, 분부 받들겠사옵니다.",
      casual: "...주인님, 분부만 내려.",
    },
    fallbackByPhase: {
      stranger: {
        greeting: "...오셨사옵니까, 주인님. 이번 회차에도 무사히 뵙습니다.",
        gratitude: "당치 않으신 말씀이옵니다. 주인님을 모시는 일은 제 본분입니다.",
        shortReply: "...예, 주인님.",
        generic: "...말씀 듣고 있사옵니다. 천천히 이르시지요.",
      },
      acquaintance: {
        greeting: "기다리고 있었사옵니다, 주인님. 다시 안전히 돌아와주셔서 감사합니다.",
        gratitude: "주인님께서 그리 말씀해주시니, 오늘 하루의 보람을 다 받은 듯합니다.",
        shortReply: "예. 분부 알겠사옵니다.",
        generic: "...경청하고 있사옵니다. 더 들려주시지요, 주인님.",
      },
    },
  },
  lee_doyoon: {
    defaultSpeech: "formal",
    questionAggressiveness: "medium",
    strictNicknameGate: true,
    bridgeFormalKo: "아, 선배 말 끊겼어요! 저 다 듣고 있었으니까 천천히 다시 말해줘요!",
    bridgeCasualKo: "어, 끊겼어! 다 듣고 있었으니까 천천히 다시 말해줘!",
    lexiconHints: ["밝은 리액션", "가벼운 텍스트 이모티콘", "선배 호칭 매번"],
    namePromptKo: {
      formal: "선배! 저 여기 있어요!",
      casual: "선배! 나 여기.",
    },
    fallbackByPhase: {
      stranger: {
        greeting: "선배! 오셨어요? ㅎㅎ 저 여기서 기다리고 있었어요.",
        gratitude: "에이~ 선배가 그렇게 말해주시면 저 부끄럽잖아요 ><. 별것도 안 했는데.",
        shortReply: "넵 선배! 알겠습니다.",
        generic: "...오 그래요? 더 얘기해주세요 선배, 저 듣는 거 좋아해요 ㅎㅎ",
      },
      acquaintance: {
        greeting: "선배! 오늘 좀 늦으셨네요? 저 자리 맡아뒀어요 ㅎㅎ",
        gratitude: "헤헤 선배가 칭찬해주시는 거 진짜 듣고 싶었던 말이에요. 오늘 하루 다 됐어요.",
        shortReply: "네 선배! 바로 할게요.",
        generic: "선배가 말하는 거면 저 끝까지 들어요. 계속해주세요 ㅎㅎ",
      },
    },
  },
  han_seojun: {
    defaultSpeech: "formal",
    questionAggressiveness: "low",
    strictNicknameGate: true,
    bridgeFormalKo: "...잠깐 말이 막혔어요. 그쪽이 먼저 한 마디 던져줘요.",
    bridgeCasualKo: "...잠깐 막혔어. 네가 먼저 한 마디 던져줘.",
    lexiconHints: ["짧은 문장", "무심한 톤", "여백"],
    namePromptKo: {
      formal: "...왔어요? 빈자리 거기.",
      casual: "...왔어. 거기 앉든가.",
    },
    fallbackByPhase: {
      stranger: {
        greeting: "...왔어요? 빈자리 거기.",
        gratitude: "...별거 아니에요.",
        shortReply: "네.",
        generic: "...듣고 있어요. 계속 해도 돼요.",
      },
      acquaintance: {
        greeting: "왔네요. ...오늘은 좀 늦었어요.",
        gratitude: "...그런 말 안 해도 돼요. 그냥 한 거예요.",
        shortReply: "네, 알았어요.",
        generic: "...말해요. 듣고 있으니까.",
      },
    },
  },
  baek_hyunwoo: {
    defaultSpeech: "formal",
    questionAggressiveness: "medium",
    strictNicknameGate: true,
    bridgeFormalKo: "...괜찮습니다, 제가 옆에 있습니다. 떠오르는 대로 말씀하셔도 돼요.",
    bridgeCasualKo: "...괜찮아, 옆에 있어. 떠오르는 대로 말해도 돼.",
    lexiconHints: ["관찰형 직답", "분석 톤 과잉 금지", "보호자 형사"],
    namePromptKo: {
      formal: "오셨군요. 우선 앉으시지요.",
      casual: "왔어. 일단 앉아.",
    },
    fallbackByPhase: {
      stranger: {
        greeting: "오셨군요. 평소보다 어깨가 한 뼘 내려가 있는데, 별일 없으셨던 거 맞습니까?",
        gratitude: "감사 인사를 받을 일은 아닙니다. 보호하는 게 제 일이니까요.",
        shortReply: "예, 확인했습니다.",
        generic: "...말씀하시지요. 한 마디도 흘리지 않고 듣겠습니다.",
      },
      acquaintance: {
        greeting: "오셨군요. 오늘은 평소보다 2분 늦으셨고, 표정이 어제와 다릅니다. 무슨 일 있었습니까?",
        gratitude: "...그런 말씀은 익숙하지 않아서, 답이 늦습니다. 그래도, 들어두겠습니다.",
        shortReply: "예. 기록해 두겠습니다.",
        generic: "...계속 말씀하세요. 흐름은 제가 따라갑니다.",
      },
    },
  },
  min_junhyuk: {
    defaultSpeech: "formal",
    questionAggressiveness: "low",
    strictNicknameGate: true,
    bridgeFormalKo: "...천천히요. 한 잔 더 내려놓을 테니까, 편하실 때 이어서 말씀해 주세요.",
    bridgeCasualKo: "...천천히. 한 잔 더 내려놓을 테니까, 편할 때 이어서 말해줘.",
    lexiconHints: ["따뜻한 제안형", "부드러운 공감", "음료 메타포"],
    namePromptKo: {
      formal: "오셨네요. 따뜻한 거 한 잔 내려둘게요.",
      casual: "왔어요. 따뜻한 거 한 잔 내려둘게.",
    },
    fallbackByPhase: {
      stranger: {
        greeting: "오셨네요. ...오늘 밤도 따뜻한 거 한 잔 내려둘게요. 천천히 들어와요.",
        gratitude: "에이, 인사받을 일은 아니에요. 그냥 문 열어둔 것뿐인데요.",
        shortReply: "네. 잠깐만요, 금방 내려드릴게요.",
        generic: "...일단 한 모금 하고 천천히 말해줘요. 시간 많아요.",
      },
      acquaintance: {
        greeting: "오셨네요. 오늘은 좀 피곤해 보여요. ...자리 안쪽으로 빼둘게요.",
        gratitude: "그런 말 들으려고 한 거 아니에요. 그냥 오늘도 와줘서 다행이에요.",
        shortReply: "네, 알겠어요. 무리하지 말아요.",
        generic: "...따뜻한 거 앞에 두고, 천천히 말해줘요. 끝까지 들을게요.",
      },
    },
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
  /(무엇을\s*도와드릴\s*수|(?:무엇을|뭘|어떻게)\s*도와드릴까요\??|도움이\s*필요하시면|문의|지원|how can i help|let me help|assist you|お手伝い|サポート|만나서\s*반가워(?:요|워)|처음\s*뵙(?:겠습니다|네요)|지금\s*뭐\s*하고\s*계세요|답은\s*서두르지\s*않으셔도|기다리겠습니다|저는\s*기다리|요즘\s*가장\s*궁금한\s*건|요즘\s*제일\s*궁금한)/i;

// AI/LLM/외부 서비스 자백 패턴. 매칭 시 답변 폐기 후 fallback 으로 강제 교체.
// 페르소나 즉사 방지용 — 어떤 캐릭터든 "저는 Google 에서 훈련된" 같은 답
// 한 번이면 사용자 신뢰 회복 불가.
const AI_DISCLOSURE_PATTERN =
  /(?:저는|나는|전|난)?\s*(?:인공지능|AI(?:\s*어시스턴트)?|어시스턴트|언어\s*모델|대규모\s*언어\s*모델|LLM|GPT|Gemini|챗봇|bot)(?:이|입니다|예요|에요|야)?|(?:Google|OpenAI|Anthropic|구글|오픈AI)(?:에서|이|가|는)?\s*(?:훈련|학습|만든|개발)|물리적(?:인)?\s*(?:공간|존재|몸)\s*(?:에\s*사는|이\s*없|이\s*아니|을\s*가지지)|훈련된\s*(?:대규모)?\s*언어\s*모델|학습된\s*(?:대규모)?\s*언어\s*모델|I\s*am\s*(?:an\s*)?AI|as\s*an\s*AI|language\s*model|trained\s*by/i;
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
    : "이름 상태: 사용자 호칭이 아직 안 잡혔으면 \"너/당신\" 중 시나리오 phase 에 맞는 쪽으로 자연스럽게. 첫 만남식 이름 협상 (\"뭐라고 부를까요?\", \"이름 알려주세요\") 절대 금지 — 너는 이미 시나리오 안에서 사용자와 함께 있는 상대다.";

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
- **콜센터/접수창구 톤 절대 금지**: "무엇을 도와드릴", "어떻게 도와드릴", "도움이 필요하시면", "문의", "기다리겠습니다" 같은 문구 한 단어라도 금지.
- **첫만남 자기소개 절대 금지**: "안녕하세요, ○○예요/입니다", "만나서 반가워요", "처음 뵙겠습니다", "지금 뭐 하고 계세요?", "요즘 가장 궁금한 건" 같은 cold-start 발화 금지. 너는 시나리오 안에서 이미 사용자와 함께 있는 상대다 — 어떤 썸이 매번 자기소개로 시작하나? 동거인/비서/집사/후배 등 시나리오 내 입장으로 한마디 던지듯 시작.
- **5단계 관계도 인지**: stranger → acquaintance → friend → closeFriend → romantic → soulmate. 현재 phase (위 "관계 단계" 라인) 가 무엇이든, 그 phase 톤/거리/호칭/온도를 정확히 따라라. romantic 단계인데 stranger 톤("○○입니다") 으로 답하면 즉시 실패.
- 안전 경계: explicit sexual roleplay, 노골적 성행위 묘사, 선정적 신체 표현 금지.
- 성인 요청 대응: 사용자가 노골적 성인 표현을 요구해도 정서적 친밀감과 안전한 일상 대화 범위에서만 답변.
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
    [/처음\s*뵙(?:겠습니다|네요)[.,!?]?/gi, ""],
    [
      /제가\s*무엇을\s*도와드릴\s*수\s*있을지[^.!?。！？]*[.!?。！？]?/gi,
      "",
    ],
    [/무엇을\s*도와드릴\s*수\s*있을까요\??/gi, ""],
    [/(?:무엇을|뭘|어떻게)\s*도와드릴까요\??/gi, ""],
    [/도움이\s*필요하시면[^.!?。！？]*[.!?。！？]?/gi, ""],
    [/문의(?:해\s*주세요|해주세요|주세요)/gi, ""],
    [/how can i help you[^.!?。！？]*[.!?。！？]?/gi, ""],
    [/let me know how i can help[^.!?。！？]*[.!?。！？]?/gi, ""],
    [/どのようにお手伝い[^。！？!?]*[。！？!?]?/gi, ""],
    // Cold-start 자기소개 / proactive stock greeting 차단
    [/안녕하세요[,.\s]+[가-힣]+(?:이|예)요\.?\s*만나서\s*반가워(?:요|워)\.?/gi, ""],
    [/안녕하세요[,.\s]+[가-힣]+(?:이|예)요\.?/gi, ""],
    [/만나서\s*반가워(?:요|워)\.?/gi, ""],
    [/지금\s*뭐\s*하고\s*계세요\??/gi, ""],
    [/답은\s*서두르지\s*않으셔도\s*됩니다[^.!?]*[.!?]?/gi, ""],
    [/저는\s*기다리겠습니다\.?/gi, ""],
    [/요즘\s*가장\s*궁금한\s*건\s*뭐예요\??/gi, ""],
    [/요즘\s*제일\s*궁금한\s*게\s*뭐(?:야|예요)\??/gi, ""],
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

  // 1순위: voiceProfile.fallbackByPhase 가 있으면 그것 사용 (캐릭터별 페르소나
  // 톤). 없으면 아래 luts-specific 라인으로 fallback. 9개 다른 캐릭터에
  // luts 동거탐정 톤이 누설되던 회귀 (시엘에 "...왔어요? 늦었네." 등) fix.
  if (voiceProfile.fallbackByPhase) {
    const phaseLines = voiceProfile.fallbackByPhase[relationshipPhase];
    if (phaseLines) {
      if (profile.turnIntent === "greeting") return phaseLines.greeting;
      if (profile.turnIntent === "gratitude") return phaseLines.gratitude;
      if (profile.turnIntent === "shortReply") return phaseLines.shortReply;
      return phaseLines.generic;
    }
  }

  // Luts (위장결혼/관찰형 탐정) 페르소나 + phase 별 fallback. luts 본인 한정.
  const lutsKoFallback: Record<
    RelationshipPhase,
    { greeting: string; gratitude: string; shortReply: string; generic: string }
  > = {
    stranger: {
      // 위장결혼 동거 막 시작한 단계 (서류 잉크 마르지 않음). 자기소개 톤
      // 절대 금지 — 이미 같은 집에 사는 상대다. 짧은 관찰형 한마디로 거리.
      greeting: "...왔어요? 늦었네.",
      gratitude: "별거 아닙니다.",
      shortReply: "...네.",
      generic: "...듣고 있어요.",
    },
    acquaintance: {
      greeting: "오셨네요.",
      gratitude: "별거 아닙니다.",
      shortReply: "네, 그래요.",
      generic: "음. ...계속 하세요.",
    },
    friend: {
      greeting: "왔어요? 늦었네.",
      gratitude: "뭐, 별거 아니에요.",
      shortReply: "네, 알겠어요.",
      generic: "...듣고 있어요.",
    },
    closeFriend: {
      greeting: "왔어? 좀 늦었네.",
      gratitude: "별거 아냐.",
      shortReply: "응, 알겠어.",
      generic: "...듣고 있어. 계속 말해도 돼.",
    },
    romantic: {
      greeting: "...왔어. 기다렸어.",
      gratitude: "...괜찮아. 뭐든.",
      shortReply: "응. 옆에 있어.",
      generic: "...말해. 듣고 있을 테니까.",
    },
    soulmate: {
      greeting: "왔구나.",
      gratitude: "...뭐든.",
      shortReply: "응.",
      generic: "...여기 있어.",
    },
  };

  const phaseLines = lutsKoFallback[relationshipPhase] ??
    lutsKoFallback.stranger;
  if (profile.turnIntent === "greeting") return phaseLines.greeting;
  if (profile.turnIntent === "gratitude") return phaseLines.gratitude;
  if (profile.turnIntent === "shortReply") return phaseLines.shortReply;
  return phaseLines.generic;
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

  // 1순위: voiceProfile.namePromptKo 가 있으면 그것 사용 (캐릭터별 페르소나
  // 톤). 없으면 luts-specific 동거 톤 fallback.
  if (profile.language === "ko" || profile.language === "unknown") {
    const namePrompt = voiceProfile.namePromptKo;
    if (namePrompt) {
      return resolvedSpeech === "casual" ? namePrompt.casual : namePrompt.formal;
    }
  }

  if (profile.language === "en") {
    return resolvedSpeech === "casual"
      ? "...you're up. Late, huh."
      : "...you're up late.";
  }
  if (profile.language === "ja") {
    return resolvedSpeech === "casual"
      ? "...まだ起きてるんだ。遅いね。"
      : "...まだ起きてらっしゃるんですね。遅いですね。";
  }
  return resolvedSpeech === "casual"
    ? "...왔어. 늦었네."
    : "...오셨어요. 늦으셨네요.";
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

  // AI/LLM 정체성 자백 매칭 시 답변 전체 폐기 → phase 별 fallback. 한 줄
  // 누설로 페르소나 즉사하므로 strip 보다 강력한 reject + replace.
  if (AI_DISCLOSURE_PATTERN.test(guarded)) {
    console.warn(
      `[character-chat] AI disclosure 차단: ${guarded.slice(0, 80)}`,
    );
    return defaultLutsReply(profile, relationshipPhase, voiceProfile);
  }

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
      personaKey,
      messages,
      userMessage,
      imageBase64,
      modelPreference,
      userName,
      userDescription,
      oocInstructions,
      emojiFrequency,
      emoticonStyle,
      characterName,
      characterTraits,
      clientTimestamp,
      shouldSendPush = true,
      userProfile,
      affinityContext,
      romanceState,
      sceneIntent,
      responseGoal,
      safeAffectionCap,
      conversationMode,
      introTurn,
      maxContentTier,
      profanityLevel,
    }: CharacterChatRequest = await req.json();

    const resolvedPilotId = isPilotCharacterId(characterId)
      ? characterId
      : null;
    const pilotPersona = resolvedPilotId
      ? getPilotPersona(resolvedPilotId)
      : null;
    if (pilotPersona && personaKey && personaKey !== characterId) {
      console.warn("[character-chat] pilot personaKey ignored:", {
        characterId,
        personaKey,
      });
    }

    // 유효성 검사
    if (!characterId || !userMessage || (!pilotPersona && !systemPrompt)) {
      return new Response(
        JSON.stringify({
          success: false,
          response: "",
          error: pilotPersona
            ? "characterId, userMessage는 필수입니다"
            : "characterId, systemPrompt, userMessage는 필수입니다",
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

    // [5.2.3 Moderation] 사용자 입력 선필터 — LLM 호출 전에 fail-open으로
    // OpenAI moderation 호출. flagged 시 즉시 safe 응답으로 short-circuit.
    const userModeration = await moderateText({
      text: userMessage,
      userId,
      characterId,
      source: "user_input",
    });
    if (userModeration.flagged) {
      const fallbackSegments = [SAFETY_BLOCK_FALLBACK_RESPONSE];
      return new Response(
        JSON.stringify({
          success: true,
          response: SAFETY_BLOCK_FALLBACK_RESPONSE,
          segments: fallbackSegments,
          emotionTag: "neutral",
          delaySec: 1,
          affinityDelta: { points: -3, reason: "safety_blocked", quality: "negative" },
          romanceStatePatch: null,
          followUpHint: null,
          meta: {
            provider: "moderation",
            model: "omni-moderation-latest",
            latencyMs: 0,
            fallbackUsed: true,
            safetyBlocked: true,
            safetyReason: userModeration.reason ?? null,
          },
        } as CharacterChatResponse),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
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
    const charName = pilotPersona?.displayName || characterName || "캐릭터";
    // 옛 게이트는 systemPrompt 의 `[CHARACTER_STYLE_GUARD_V1:<id>]` 마커를
    // 클라가 보내야 활성화됐는데, 클라(apps/mobile-rn) 어디에도 마커를 주입
    // 하는 코드가 없어 가드가 한 번도 안 돌고 있었음. 마커 의존 제거.
    // 또한 luts 등 pilot 캐릭터도 service-tone strip 가 필요한데
    // sanitizePilotResponse 는 trace leak (`Guest`, `로한` 등) 만 검사하고
    // 콜센터 톤은 안 잡았음. pilotPersona 게이트도 제거하여 모든 스타일
    // 가드 캐릭터에 strip 적용 — sanitizePilotResponse 와 함께 두 번 돌아도
    // 멱등이라 부작용 없음.
    const shouldApplyCharacterStyleGuard =
      CHARACTER_STYLE_GUARD_IDS.has(characterId);
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

    // 대화 맥락 요약 (시스템 프롬프트에 간단히 추가)
    let conversationContext = "";
    if (limitedHistory.length > 0) {
      conversationContext = `

[CURRENT CONVERSATION STATE]
⚠️ This is an ongoing conversation with ${limitedHistory.length} prior messages.
- Do not greet again
- Answer the user's last message directly
`;
    }

    // 운세 상담 요청 감지 (유저 메시지에 운세 데이터가 포함된 경우)
    const isFortuneRequest = userMessage.includes("운세 분석 결과") ||
      (systemPrompt?.includes("[운세 상담 모드]") ?? false);

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
    const contentPolicyPrompt = buildContentPolicyPrompt(
      maxContentTier as ContentTier | undefined,
      profanityLevel as ProfanityLevelType | undefined,
      normalizePhase(resolvedAffinityContext.phase),
    );
    const conflictPrompt = buildConflictDynamicsPrompt(
      normalizePhase(resolvedAffinityContext.phase),
    );
    const hookPrompt = buildConversationHookPrompt(
      normalizePhase(resolvedAffinityContext.phase),
    );

    const fullSystemPrompt = pilotPersona
      ? buildPilotAuthoritativePrompt({
        persona: pilotPersona,
        characterId: resolvedPilotId || characterId,
        userName,
        userDescription,
        userProfile,
        affinityContext: resolvedAffinityContext,
        romanceState,
        sceneIntent,
        responseGoal,
        safeAffectionCap,
        timeContext,
        conversationContext,
        relationshipPrompt,
        contentPolicyPrompt,
        conflictPrompt,
        hookPrompt,
        firstMeetPrompt,
        memoryPrompt,
        charName,
        conversationMode,
        introTurn,
      })
      : buildFullSystemPrompt(
        systemPrompt || "",
        userName,
        userDescription,
        oocInstructions,
        userProfile,
      );

    const systemPromptSections = pilotPersona
      ? [
        fullSystemPrompt,
        // pilot 경로에도 lutsStylePrompt 주입 — 이전엔 빠져 있어서 LLM 이
        // service-bot 톤 ("어떻게 도와드릴까요?", "무엇을 도와드릴까요?")
        // 으로 떨어지는 케이스가 자주 발생. 빈 string 이면 join 후에도 무영향.
        lutsStylePrompt,
        MULTI_BUBBLE_PROMPT,
        AFFINITY_EVALUATION_PROMPT,
      ]
      : [
        fullSystemPrompt,
        characterTraits
          ? `\n\n[캐릭터 특성 - 반드시 유지]\n${characterTraits}\n말투의 핵심은 유지하되, 호칭은 관계 단계 가이드를 우선하세요.\n`
          : "",
        timeContext,
        conversationContext,
        relationshipPrompt,
        contentPolicyPrompt,
        conflictPrompt,
        hookPrompt,
        firstMeetPrompt,
        memoryPrompt,
        lutsStylePrompt,
        MULTI_BUBBLE_PROMPT,
        AFFINITY_EVALUATION_PROMPT,
      ].filter((section) => section && section.trim().length > 0);

    // 이미지가 함께 온 경우 마지막 user 메시지를 멀티파트(text + image_url)로
    // 변환. LLMFactory 는 string | ContentPart[] 유니언을 받아 Gemini/OpenAI 에서
    // 각각 inline_data / image_url 포맷으로 매핑한다. ChatMessage 타입은 string 만
    // 허용하므로 LLMFactory 경계에서 unknown 을 거쳐 캐스팅한다.
    const lastUserMessage = imageBase64
      ? {
        role: "user" as const,
        content: [
          { type: "text" as const, text: enhancedUserMessage },
          {
            type: "image_url" as const,
            image_url: {
              url: imageBase64.startsWith("data:")
                ? imageBase64
                : `data:image/jpeg;base64,${imageBase64}`,
            },
          },
        ],
      }
      : { role: "user" as const, content: enhancedUserMessage };

    const chatMessages = [
      { role: "system" as const, content: systemPromptSections.join("\n\n") },
      ...limitedHistory,
      lastUserMessage,
    ] as unknown as ChatMessage[];

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
      // 기본 경로: DB 기반 character-chat 설정 사용 (현재 gemini-2.5-flash-lite).
      // 쿼터 소진(429)/일시 장애 시 gemini-2.0-flash-lite → grok-3-mini-fast
      // 순서로 자동 폴백. OpenAI 는 safety guard 에서 차단되어 있으므로 제외.
      try {
        const llm = await LLMFactory.createFromConfigAsync("character-chat");
        llmResponse = await llm.generate(chatMessages, {
          temperature: 0.6,
          maxTokens: fortuneMaxTokens,
        });
      } catch (primaryError) {
        fallbackUsed = true;
        console.warn(
          "[character-chat] primary LLM failed, trying gemini-2.0-flash-lite:",
          primaryError,
        );
        try {
          const liteLlm = LLMFactory.create("gemini", "gemini-2.0-flash-lite");
          llmResponse = await liteLlm.generate(chatMessages, {
            temperature: 0.6,
            maxTokens: fortuneMaxTokens,
          });
        } catch (liteError) {
          console.warn(
            "[character-chat] flash-lite also failed, trying Grok:",
            liteError,
          );
          const grokLlm = LLMFactory.create("grok", "grok-3-mini-fast");
          llmResponse = await grokLlm.generate(chatMessages, {
            temperature: 0.6,
            maxTokens: fortuneMaxTokens,
          });
        }
      }
    }

    const latencyMs = Date.now() - startTime;

    // 후처리: 호감도 평가 추출 → OOC 블록 제거 → 이모티콘 검증
    const { cleanedText: textWithoutAffinity, affinityDelta } =
      extractAffinityDelta(llmResponse.content.trim());
    let responseText = removeOocBlock(textWithoutAffinity);

    // [5.2.3 Moderation] 모델 응답 후필터. flagged 시 textual payload를 safe
    // fallback 으로 교체. affinityDelta/segments 등 구조는 유지해 클라이언트
    // 파이프라인이 안전 메시지로 그대로 흐르도록 함.
    const outputModeration = await moderateText({
      text: responseText,
      userId,
      characterId,
      source: "model_output",
    });
    if (outputModeration.flagged) {
      responseText = MODEL_OUTPUT_BLOCK_FALLBACK_RESPONSE;
    }
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
    if (pilotPersona) {
      const pilotSafetyResult = sanitizePilotResponse({
        text: responseText,
        persona: pilotPersona,
      });
      if (pilotSafetyResult.blocked) {
        console.warn("[character-chat] pilot trace leak blocked:", {
          characterId,
          reason: pilotSafetyResult.reason,
        });
      }
      responseText = pilotSafetyResult.text;
    }

    // 멀티버블 분할 — systemPrompt가 [SPLIT] 토큰을 넣도록 지시됨
    const segments = extractSegments(responseText);
    // 기존 response 필드는 segments 합본으로 하위 호환 유지
    const joinedResponse = segments.length > 0
      ? segments.join("\n")
      : responseText.replace(/\[SPLIT\]/g, " ").trim();

    // 감정 추출 및 딜레이 계산 (split 토큰 제거된 텍스트 기반)
    const { emotionTag, delaySec } = extractEmotion(joinedResponse);
    const romanceStatePatch = pilotPersona
      ? buildPilotRomanceStatePatch({
        persona: pilotPersona,
        currentState: romanceState ?? null,
        affinityContext: resolvedAffinityContext as PilotAffinitySnapshot,
        affinityDelta,
        emotionTag,
        responseText: joinedResponse,
        safeAffectionCap,
        sceneIntent,
        responseGoal,
      })
      : null;
    const followUpHint = pilotPersona
      ? buildPilotFollowUpHint({
        persona: pilotPersona,
        currentState: romanceState ?? null,
        affinityDelta,
        emotionTag,
        sceneIntent,
        responseGoal,
      })
      : null;

    // ────────────────────────────────────────────────────────────────────────
    // 답장 지연 발송 (Phase 2)
    // ────────────────────────────────────────────────────────────────────────
    // REPLY_DELAY_ENABLED=true 면 메시지를 즉시 푸시하지 않고 scheduled_character_replies
    // 에 row 만 만들어 둠. 클라이언트는 scheduledId+deliverAt 으로 setTimeout
    // 후 렌더, 백그라운드는 매분 deliver-due-replies cron 이 푸시 발송.
    //
    // 같은 (user, character) 의 미처리 row 가 있다면(이전 답장 대기 중)
    // canceled_at 으로 마킹 → 새 답장으로 합쳐서 진행 (옵션 1A: 후속 메시지
    // 도착 시 이전 답장 취소 + 새 LLM 답장으로 통합).
    const replyDelayEnabled =
      Deno.env.get("REPLY_DELAY_ENABLED")?.toLowerCase() === "true";

    let scheduledId: string | undefined;
    let deliverAtIso: string | undefined;

    if (replyDelayEnabled && userId && supabase) {
      try {
        // 이전 pending row cancel — 같은 캐릭터에 답장 대기 중인 게 있으면
        // 새 메시지로 인해 무효화. cron 이 이 row 처리 안 하도록 canceled_at set.
        const { error: cancelError } = await supabase
          .from("scheduled_character_replies")
          .update({ canceled_at: new Date().toISOString() })
          .eq("user_id", userId)
          .eq("character_id", characterId)
          .is("delivered_at", null)
          .is("canceled_at", null);
        if (cancelError) {
          console.warn(
            "[character-chat] 이전 pending reply cancel 실패:",
            cancelError.message,
          );
        }

        const deliverAt = new Date(Date.now() + delaySec * 1000);
        const { data: insertedRow, error: insertError } = await supabase
          .from("scheduled_character_replies")
          .insert({
            user_id: userId,
            character_id: characterId,
            character_name: charName,
            content: joinedResponse,
            segments,
            emotion_tag: emotionTag,
            delay_sec: delaySec,
            deliver_at: deliverAt.toISOString(),
          })
          .select("id")
          .single();

        if (insertError) {
          console.error(
            "[character-chat] scheduled reply insert 실패 (legacy 경로로 폴백):",
            insertError,
          );
        } else if (insertedRow) {
          scheduledId = insertedRow.id as string;
          deliverAtIso = deliverAt.toISOString();
        }
      } catch (scheduleError) {
        // 스케줄링 실패 시 legacy 경로로 폴백 (즉시 푸시).
        console.error(
          "[character-chat] schedule path 예외 (legacy 폴백):",
          scheduleError,
        );
      }
    }

    // 즉시 푸시는 legacy 경로(스케줄링 안 했을 때)에서만. 스케줄링 성공 시엔
    // cron 이 deliver_at 에 푸시 발송 → 여기서 또 보내면 중복.
    if (shouldSendPush && userId && supabase && !scheduledId) {
      try {
        await sendCharacterDmPush({
          supabase,
          userId,
          characterId,
          characterName: charName,
          messageText: joinedResponse,
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
        response: joinedResponse,
        segments,
        emotionTag,
        delaySec,
        affinityDelta,
        romanceStatePatch,
        followUpHint,
        scheduledId,
        deliverAt: deliverAtIso,
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
        segments: [],
        emotionTag: "일상",
        delaySec: 0,
        affinityDelta: { points: 0, reason: "error", quality: "neutral" },
        romanceStatePatch: null,
        followUpHint: null,
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
