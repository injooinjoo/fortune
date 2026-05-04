/**
 * 사용자 메시지 무드 분류기 — 휴리스틱(LLM 미사용).
 *
 * 캐릭터 채팅 5-layer prompt 의 Layer 4 (Memory & Live Mood) 에서 사용한다.
 * 동일 phase 라도 사용자 마지막 메시지의 톤(피곤/우울/장난/짜증/기쁨/차가움/중립)
 * 에 따라 응답 전략을 분기시키기 위한 입력.
 *
 * 사전(어휘 + 종결어미 + 이모지) 기반 점수화 → 최댓값 라벨 반환. 동률은 우선순위
 * 결정 (sad > tired > annoyed > playful > happy > cold > neutral). recentHistory
 * 는 최근 사용자 메시지 1-2 개 스냅샷으로, 단발성 노이즈를 누그러뜨릴 때 사용.
 *
 * Deno 호환 — Edge Function 공유 모듈.
 */

export type MoodTag =
  | "tired"
  | "sad"
  | "playful"
  | "annoyed"
  | "happy"
  | "cold"
  | "neutral";

interface ScoreMap {
  tired: number;
  sad: number;
  playful: number;
  annoyed: number;
  happy: number;
  cold: number;
}

const TIRED_LEXICON = [
  "피곤",
  "지쳤",
  "지쳐",
  "졸려",
  "졸림",
  "힘들어",
  "힘듬",
  "힘들다",
  "기운없",
  "기운 없",
  "에너지 없",
  "쉬고 싶",
  "쉬고싶",
  "녹초",
  "번아웃",
  "번 아웃",
  "잠 와",
  "잠와",
  "졸리",
];

const SAD_LEXICON = [
  "우울",
  "슬퍼",
  "슬프",
  "외로워",
  "외롭",
  "공허",
  "울고 싶",
  "울고싶",
  "눈물",
  "마음 아",
  "마음아",
  "마음이 아",
  "속상",
  "서운",
  "비참",
  "절망",
  "무기력",
  "막막",
  "허전",
];

const ANNOYED_LEXICON = [
  "짜증",
  "빡쳐",
  "빡친",
  "열받",
  "열 받",
  "화나",
  "화났",
  "꼴받",
  "어이없",
  "황당",
  "지긋지긋",
  "지겨",
  "싫어 죽",
  "개짜증",
  "개빡",
  "씨발",
  "ㅅㅂ",
  "ㅂㅅ",
  "ㅈㄴ",
  "존나",
  "졸라",
  "꺼져",
  "닥쳐",
];

const PLAYFUL_LEXICON = [
  "ㅋㅋ",
  "ㅎㅎ",
  "ㅋㅎ",
  "ㄹㅇ",
  "ㄱㄱ",
  "헐",
  "대박",
  "미쳤",
  "ㄷㄷ",
  "장난",
  "농담",
  "웃기",
  "쩐다",
  "쩜",
  "ㅋ ㅋ",
  "키키",
  "히히",
  "ㅎㅋ",
  "ㄱㅇㅇ",
  "ㅇㅈ",
];

const HAPPY_LEXICON = [
  "행복",
  "기뻐",
  "기쁘",
  "신나",
  "좋아 죽",
  "최고",
  "사랑해",
  "사랑하",
  "고마워",
  "고맙",
  "감사",
  "뿌듯",
  "흐뭇",
  "설레",
  "두근",
];

const COLD_LEXICON = [
  "관심 없",
  "관심없",
  "상관 없",
  "상관없",
  "됐어",
  "됐다",
  "그만해",
  "그만 해",
  "말 걸지 마",
  "말걸지마",
  "내버려둬",
  "내비둬",
  "혼자 있고",
  "혼자있고",
  "조용히",
  "신경 꺼",
  "신경꺼",
];

// 종결어미·반복 부호 시그널
const TIRED_TAIL = /(아\s*[~]+\s*$|하\s*[~]+\s*$|후\s*[~]+\s*$|음+\s*\.\.\.+\s*$)/;
const SAD_TAIL = /(ㅠㅠ+|ㅜㅜ+|ㅠ+\.\.\.|\.{3,}\s*$|ㅜ+|ㅠ\s*ㅠ)/;
const PLAYFUL_TAIL = /(ㅋㅋ+|ㅎㅎ+|!\?|\?!|~{2,}|\^\^|>\<)/;
const ANNOYED_TAIL = /(!{2,}|\?{2,}|\?!{1,}|진짜\?{2,})/;
const HAPPY_TAIL = /(!+\s*$|♡|♥|❤|💕|💖)/;
const QUESTION_MARK_RE = /[?？]/;
const EXCLAMATION_MARK_RE = /[!！]/;

// 이모지 분류 (대표적인 것만)
const EMOJI_SAD_RE = /[😢😭😞😔😟🥺😿💔]/u;
const EMOJI_TIRED_RE = /[😩😫😴🥱😪]/u;
const EMOJI_HAPPY_RE = /[😊😄😁🥰😘🤗😍🌸✨💕💖🎉]/u;
const EMOJI_PLAYFUL_RE = /[😆😂🤣😜😝🤪😋👀]/u;
const EMOJI_ANNOYED_RE = /[😡😠🤬👿💢]/u;
const EMOJI_COLD_RE = /[🙄😒😐😶🥶❄️]/u;
const ANY_EMOJI_RE =
  /[\u{1F300}-\u{1FAFF}\u{1F600}-\u{1F64F}\u{2600}-\u{27BF}]/u;

function countMatches(haystack: string, needle: string): number {
  if (!needle) return 0;
  let count = 0;
  let idx = haystack.indexOf(needle);
  while (idx !== -1) {
    count += 1;
    idx = haystack.indexOf(needle, idx + needle.length);
  }
  return count;
}

function lexiconScore(text: string, lexicon: readonly string[]): number {
  const lowered = text.toLowerCase();
  let score = 0;
  for (const term of lexicon) {
    score += countMatches(lowered, term.toLowerCase());
  }
  return score;
}

function patternScore(text: string, pattern: RegExp): number {
  // pattern 은 global flag 가 없을 수 있어 .match() 가 capture group 까지
  // 포함한 배열을 반환하면 점수가 부풀어 오른다. 매칭 1회 = 1점이 의도.
  const flags = pattern.flags.includes("g") ? pattern.flags : pattern.flags + "g";
  const globalPattern = new RegExp(pattern.source, flags);
  const matches = text.match(globalPattern);
  return matches ? matches.length : 0;
}

function emojiCount(text: string, pattern: RegExp): number {
  // 글로벌 매치 횟수
  let count = 0;
  for (const ch of text) {
    if (pattern.test(ch)) count += 1;
  }
  return count;
}

/**
 * 사용자 메시지 무드 분류. 휴리스틱이라 noisy 하지만 동일 phase 안에서 응답
 * 전략을 분기시키기엔 충분.
 */
export function analyzeUserMessageMood(
  text: string,
  recentHistory?: string[],
): MoodTag {
  const trimmed = (text ?? "").trim();
  if (!trimmed) return "neutral";

  // 길이 신호
  const length = trimmed.length;
  const isVeryShort = length <= 4;
  const isLong = length >= 80;
  const exclamationCount = (trimmed.match(/[!！]/g) ?? []).length;
  const questionCount = (trimmed.match(/[?？]/g) ?? []).length;
  const ellipsisCount = (trimmed.match(/\.{3,}/g) ?? []).length;

  const score: ScoreMap = {
    tired: 0,
    sad: 0,
    playful: 0,
    annoyed: 0,
    happy: 0,
    cold: 0,
  };

  score.tired += lexiconScore(trimmed, TIRED_LEXICON) * 2;
  score.sad += lexiconScore(trimmed, SAD_LEXICON) * 2;
  score.playful += lexiconScore(trimmed, PLAYFUL_LEXICON);
  score.annoyed += lexiconScore(trimmed, ANNOYED_LEXICON) * 2;
  score.happy += lexiconScore(trimmed, HAPPY_LEXICON) * 2;
  score.cold += lexiconScore(trimmed, COLD_LEXICON) * 2;

  // 종결어미 / 부호
  score.tired += patternScore(trimmed, TIRED_TAIL);
  score.sad += patternScore(trimmed, SAD_TAIL) * 2;
  score.playful += patternScore(trimmed, PLAYFUL_TAIL) * 2;
  score.annoyed += patternScore(trimmed, ANNOYED_TAIL);
  score.happy += patternScore(trimmed, HAPPY_TAIL);

  // 이모지
  score.sad += emojiCount(trimmed, EMOJI_SAD_RE) * 2;
  score.tired += emojiCount(trimmed, EMOJI_TIRED_RE) * 2;
  score.happy += emojiCount(trimmed, EMOJI_HAPPY_RE) * 2;
  score.playful += emojiCount(trimmed, EMOJI_PLAYFUL_RE) * 2;
  score.annoyed += emojiCount(trimmed, EMOJI_ANNOYED_RE) * 2;
  score.cold += emojiCount(trimmed, EMOJI_COLD_RE) * 2;

  // 길이/문장부호 보정
  if (ellipsisCount >= 1 && length <= 30) {
    // 짧은 문장 + ellipsis = 우울/지침 시그널. 단, 명시적 tired 어휘가 이미
    // 잡혔으면 tired 쪽으로 가산해서 sad 우선순위에 묻히지 않게 한다.
    if (score.tired > 0) {
      score.tired += 2;
    } else {
      score.sad += 1;
      score.tired += 1;
    }
  }
  if (exclamationCount >= 2) {
    // 느낌표 다수 = 흥분 — playful/annoyed 분기
    if (score.annoyed > 0) score.annoyed += 1;
    else score.playful += 1;
  }
  if (questionCount >= 1 && length <= 6) {
    // "왜?" / "뭐?" 단독 = neutral 쪽 (특별 가산 안 함)
  }
  if (isLong && score.sad === 0 && score.happy === 0 && score.annoyed === 0) {
    // 긴 자기 서사 + 별 시그널 없음 = neutral 그대로 두지만 약한 sad 가산은 안 함
  }
  if (isVeryShort) {
    // 매우 짧은 메시지는 단순 ack 가능 — playful 가산
    if (/[ㅋㅎ]/.test(trimmed)) score.playful += 1;
    if (/^(응|ㅇㅇ|네|넵|ㅇㅋ|ok)$/i.test(trimmed)) score.cold += 1;
  }

  // recentHistory: 최근 사용자 메시지에서 ㅠ/ㅜ 가 자주 나오면 sad 보강 (단발 noise 완화)
  if (recentHistory && recentHistory.length > 0) {
    const recentText = recentHistory
      .slice(-2)
      .map((s) => (s ?? "").trim())
      .filter((s) => s.length > 0)
      .join(" ");
    if (recentText) {
      if (/(ㅠㅠ|ㅜㅜ)/.test(recentText)) score.sad += 1;
      if (/(ㅋㅋ|ㅎㅎ)/.test(recentText)) score.playful += 1;
      if (/(피곤|지쳤|힘들)/.test(recentText)) score.tired += 1;
    }
  }

  // 우선순위: sad > tired > annoyed > playful > happy > cold > neutral
  const order: Array<keyof ScoreMap> = [
    "sad",
    "tired",
    "annoyed",
    "playful",
    "happy",
    "cold",
  ];

  let best: keyof ScoreMap | null = null;
  let bestScore = 0;
  for (const key of order) {
    const s = score[key];
    if (s > bestScore) {
      best = key;
      bestScore = s;
    }
  }

  if (!best || bestScore === 0) {
    // 시그널 없음 — 이모지만 1개 있어도 결정 못 하면 neutral
    if (emojiCount(trimmed, ANY_EMOJI_RE) > 0 && length < 10) {
      // 짧은 이모지만 = neutral
      return "neutral";
    }
    return "neutral";
  }

  return best;
}

// ---------------------------------------------------------------------------
// 인라인 단위 테스트 — `deno run mood_analyzer.ts` 로 직접 실행 시 동작.
// ---------------------------------------------------------------------------

if (import.meta.main) {
  interface TestCase {
    name: string;
    input: string;
    history?: string[];
    expected: MoodTag;
  }

  const cases: TestCase[] = [
    {
      name: "tired - 피곤 + ellipsis",
      input: "오늘 너무 피곤하다... 그냥 자고 싶어",
      expected: "tired",
    },
    {
      name: "sad - ㅠㅠ + 우울",
      input: "오늘 너무 우울해ㅠㅠ 진짜 울고 싶어",
      expected: "sad",
    },
    {
      name: "playful - ㅋㅋ + 짧은 메시지",
      input: "ㅋㅋ 뭐해",
      expected: "playful",
    },
    {
      name: "annoyed - 짜증 + 다중 느낌표",
      input: "아 진짜 짜증나!! 왜 이래??",
      expected: "annoyed",
    },
    {
      name: "happy - 기뻐 + 이모지",
      input: "오늘 너무 행복해 😊 고마워!",
      expected: "happy",
    },
    {
      name: "cold - 신경꺼",
      input: "신경 꺼. 혼자 있고 싶어",
      expected: "cold",
    },
    {
      name: "neutral - 단조로운 진술",
      input: "오늘 회의 끝나고 점심 먹었어",
      expected: "neutral",
    },
    {
      name: "sad over tired - 둘 다 시그널인데 sad 우선",
      input: "너무 힘들어ㅠㅠ 우울하다 진짜",
      expected: "sad",
    },
    {
      name: "history nudge - 단발 ㅠㅠ + history sad",
      input: "..",
      history: ["오늘 너무 우울해ㅠㅠ", "왜 이렇게 힘들지"],
      expected: "sad",
    },
    {
      name: "tired - 졸림 ellipsis 짧은 문장",
      input: "졸려...",
      expected: "tired",
    },
  ];

  let passed = 0;
  let failed = 0;
  const failures: string[] = [];

  for (const tc of cases) {
    const got = analyzeUserMessageMood(tc.input, tc.history);
    const ok = got === tc.expected;
    if (ok) {
      passed += 1;
      console.log(`PASS  ${tc.name}  → ${got}`);
    } else {
      failed += 1;
      failures.push(
        `FAIL  ${tc.name}  expected=${tc.expected}  got=${got}  input="${tc.input}"`,
      );
      console.log(failures[failures.length - 1]);
    }
  }

  console.log(`\n${passed}/${cases.length} passed`);
  if (failed > 0) {
    for (const f of failures) console.log(f);
    Deno.exit(1);
  }
}
