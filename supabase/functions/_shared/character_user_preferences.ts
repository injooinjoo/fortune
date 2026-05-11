export type ConversationToneLevel = 0 | 1 | 2;

export interface ConversationTonePreference {
  /** 0 = 존댓말, 1 = 중간, 2 = 반말 */
  formality?: ConversationToneLevel;
  /** 0 = 따뜻함, 1 = 중간, 2 = 직설 */
  warmth?: ConversationToneLevel;
  /** 0 = 짧게, 1 = 중간, 2 = 길게 */
  length?: ConversationToneLevel;
}

export interface ConversationPreferenceInput {
  relationship?: string;
  tone?: ConversationTonePreference;
  topics?: string[];
}

function isToneLevel(value: unknown): value is ConversationToneLevel {
  return value === 0 || value === 1 || value === 2;
}

function normalizeToneLevel(value: unknown, fallback: ConversationToneLevel) {
  return isToneLevel(value) ? value : fallback;
}

function cleanText(value: unknown) {
  return typeof value === "string" ? value.trim() : "";
}

function cleanTopics(topics: unknown) {
  if (!Array.isArray(topics)) {
    return [];
  }

  return topics
    .map(cleanText)
    .filter((topic) => topic.length > 0)
    .slice(0, 6);
}

function formalityGuide(level: ConversationToneLevel) {
  if (level === 0) {
    return "존댓말을 기본으로 하되 캐릭터 친밀감은 유지";
  }
  if (level === 2) {
    return "반말에 가깝게, 과한 예의체/상담체 금지";
  }
  return "너무 딱딱하지 않은 자연스러운 반존대/친근체";
}

function warmthGuide(level: ConversationToneLevel) {
  if (level === 0) {
    return "따뜻하고 공감 먼저";
  }
  if (level === 2) {
    return "빙빙 돌리지 말고 부드럽게 직설";
  }
  return "공감과 현실적인 코멘트를 균형 있게";
}

function lengthGuide(level: ConversationToneLevel) {
  if (level === 0) {
    return "짧고 리듬감 있게, 한 번에 많이 설명하지 않기";
  }
  if (level === 2) {
    return "충분히 자세하게, 감정 반응과 이유를 함께";
  }
  return "중간 길이, 핵심 반응 후 한두 문장 보태기";
}

export function buildConversationPreferencePrompt(
  preferences?: ConversationPreferenceInput,
): string {
  const relationship = cleanText(preferences?.relationship);
  const topics = cleanTopics(preferences?.topics);
  const tone = preferences?.tone ?? {};
  const formality = normalizeToneLevel(tone.formality, 1);
  const warmth = normalizeToneLevel(tone.warmth, 1);
  const length = normalizeToneLevel(tone.length, 1);

  if (!relationship && topics.length === 0 && !preferences?.tone) {
    return "";
  }

  const lines = [
    "\n\n[CONVERSATION PREFERENCES - 온보딩 대화스킬 반영]",
    "아래는 사용자가 온보딩에서 고른 대화 선호입니다. 캐릭터 고유 성격을 유지하되 답변 스타일에 자연스럽게 반영하세요.",
  ];

  if (relationship) {
    lines.push(`- 관계 기대값: ${relationship}`);
    lines.push("  → 실제 관계를 단정하지 말고, 거리감/호칭/조언 강도를 맞추는 힌트로만 사용하세요.");
  }

  if (preferences?.tone) {
    lines.push(`- 말투: ${formalityGuide(formality)}`);
    lines.push(`- 온도: ${warmthGuide(warmth)}`);
    lines.push(`- 길이: ${lengthGuide(length)}`);
  }

  if (topics.length > 0) {
    lines.push(`- 관심 주제: ${topics.join(", ")}`);
    lines.push("  → 사용자가 먼저 관련 맥락을 꺼냈을 때 소재 선택/예시로 활용하고, 매번 억지로 끼워 넣지 마세요.");
  }

  lines.push("⚠️ 선호는 캐릭터 페르소나보다 우선하지 않습니다. 사용자의 방금 메시지에 직접 반응하는 규칙이 항상 최우선입니다.");

  return lines.join("\n");
}
