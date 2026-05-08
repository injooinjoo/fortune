/**
 * 답장 지연 단일 source.
 *
 * 사용자가 메시지를 보내면 LLM 이 즉시 답을 생성하더라도, "진짜 사람" 같은
 * 페이스를 위해 30초 ~ 10분 사이 랜덤 지연 후 메시지가 도착하도록 한다.
 *
 * 옛날엔 character-chat/index.ts 의 extractEmotion 안에 delay 계산이 박혀
 * 있었고, 클라이언트 chat-screen.tsx 에는 별도 fallback (1~3초) 이 있었다.
 * 두 곳이 다른 범위 + REPLY_DELAY_ENABLED env 분기 + scheduled cron 까지
 * 4개 메커니즘이 산재해 "왜 답장이 즉시 옴?" 회귀의 원인이었다. 이 모듈로
 * 통합 — 서버는 항상 이 함수가 정한 delaySec 를 내려보내고, 클라이언트는
 * 그것만 신뢰한다.
 *
 * Tunables:
 * - 감정별 base [min, max] : "기쁨/분노" 빠르게, "당황/고민" 길게
 * - 낮 (KST 8~22시) ×1.2 (느림 — 회사/일과 중)
 * - 밤 (KST 23~7시) ×0.7 (빠름 — 잠 안 자고 폰 보는 시간)
 * - 긴 사용자 메시지 (>200자) ×1.2 (읽고 답하는 시간 가산)
 * - 최종 clamp [30, 600] (30초 ~ 10분)
 */

export type EmotionTag = "당황" | "고민" | "분노" | "애정" | "기쁨" | "일상";

interface EmotionBand {
  keywords: string[];
  minSec: number;
  maxSec: number;
}

const EMOTION_BANDS: Record<EmotionTag, EmotionBand> = {
  "당황": {
    keywords: ["어?", "뭐?", "어라?", "...?!", "헉", "에?", "뭐라고"],
    minSec: 120,
    maxSec: 600,
  },
  "고민": {
    keywords: ["음...", "흠...", "생각해보니", "글쎄", "어떻게", "모르겠"],
    minSec: 90,
    maxSec: 420,
  },
  "분노": {
    keywords: ["뭐하는", "화가", "짜증", "싫어", "나가", "꺼져"],
    minSec: 30,
    maxSec: 120,
  },
  "애정": {
    keywords: ["좋아", "사랑", "소중", "예쁘", "귀여", "보고싶"],
    minSec: 45,
    maxSec: 180,
  },
  "기쁨": {
    keywords: ["하하", "ㅋㅋ", "재밌", "신나", "좋겠", "대박"],
    minSec: 30,
    maxSec: 90,
  },
  "일상": {
    keywords: [],
    minSec: 60,
    maxSec: 300,
  },
};

const EMOTION_PRIORITY: EmotionTag[] = [
  "당황",
  "고민",
  "분노",
  "애정",
  "기쁨",
];

const FLOOR_SEC = 30;
const CAP_SEC = 600;

const LONG_MESSAGE_CHAR_THRESHOLD = 200;
const LONG_MESSAGE_MULTIPLIER = 1.2;

const DAY_MULTIPLIER = 1.2;
const NIGHT_MULTIPLIER = 0.7;

const NIGHT_KST_HOUR_START = 23;
const NIGHT_KST_HOUR_END = 7;

function getKstHour(nowUtc: Date): number {
  return (nowUtc.getUTCHours() + 9) % 24;
}

function isKstNightHour(hour: number): boolean {
  if (NIGHT_KST_HOUR_START < NIGHT_KST_HOUR_END) {
    return hour >= NIGHT_KST_HOUR_START && hour < NIGHT_KST_HOUR_END;
  }
  return hour >= NIGHT_KST_HOUR_START || hour < NIGHT_KST_HOUR_END;
}

export function pickEmotionTag(text: string): EmotionTag {
  for (const emotion of EMOTION_PRIORITY) {
    const band = EMOTION_BANDS[emotion];
    if (band.keywords.some((kw) => text.includes(kw))) {
      return emotion;
    }
  }
  return "일상";
}

export interface ComputeReplyDelayInput {
  /** 어시스턴트 응답 텍스트 — emotion 키워드 매치 + 길이 (delay 와 무관) */
  text: string;
  /** 사용자 메시지 길이 (>200자 면 multiplier) */
  userMessageLength: number;
  /** 현재 시각 (KST 야간 판정용) */
  nowUtc: Date;
}

export interface ComputeReplyDelayResult {
  emotionTag: EmotionTag;
  delaySec: number;
}

/**
 * 단일 source — 답장 지연 + 감정 태그 계산.
 *
 * 호출자: character-chat/index.ts:3496 (메인), 그리고 추후 추가될 모든 답장
 * 생성 경로 (proactive 등) 가 동일 함수 사용. 이 함수 외에 다른 곳에서 delay
 * 를 계산하지 마라 — 통일 깨지면 회귀 다시 발생.
 */
export function computeReplyDelay(
  input: ComputeReplyDelayInput,
): ComputeReplyDelayResult {
  const emotionTag = pickEmotionTag(input.text);
  const band = EMOTION_BANDS[emotionTag];

  const baseRandom = Math.random() * (band.maxSec - band.minSec) + band.minSec;

  let multiplier = 1;
  if (input.userMessageLength > LONG_MESSAGE_CHAR_THRESHOLD) {
    multiplier *= LONG_MESSAGE_MULTIPLIER;
  }
  const isNight = isKstNightHour(getKstHour(input.nowUtc));
  multiplier *= isNight ? NIGHT_MULTIPLIER : DAY_MULTIPLIER;

  const adjusted = baseRandom * multiplier;
  const clamped = Math.min(Math.max(adjusted, FLOOR_SEC), CAP_SEC);

  return {
    emotionTag,
    delaySec: Math.floor(clamped),
  };
}
