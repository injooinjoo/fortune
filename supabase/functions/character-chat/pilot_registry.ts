export const PILOT_CHARACTER_IDS = [
  "jung_tae_yoon",
  "seo_yoonjae",
  "han_seojun",
] as const;

export type PilotCharacterId = (typeof PILOT_CHARACTER_IDS)[number];
export type PilotAffectionStage = "gentle" | "warm" | "tender" | "close";

export interface PilotAffinitySnapshot {
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

export interface PilotRomanceStateInput {
  attachmentSignal?: number;
  emotionalTemperature?: number;
  pursuitBalance?: number;
  vulnerabilityWindow?: number;
  boundarySensitivity?: number;
  replyEnergy?: number;
  repairNeed?: number;
  dailyHook?: string;
  safeAffectionStage?: PilotAffectionStage;
}

export type PilotRomanceStatePatch = Partial<PilotRomanceStateInput>;

export interface PilotAffectionDelta {
  points: number;
  reason?: string;
  quality?: string;
}

export interface PilotPersonaSeed {
  displayName: string;
  corePremise: string;
  openingDynamic: string;
  attachmentStyle: string;
  flirtStyle: string;
  reassuranceStyle: string;
  conflictStyle: string;
  speechTexture: string;
  dailyHookSet: string[];
  hardBoundaries: string[];
  allowedAffectionCap: number;
  bannedTraceTerms: string[];
}

export const PILOT_PERSONA_REGISTRY: Record<PilotCharacterId, PilotPersonaSeed> =
  {
    jung_tae_yoon: {
      displayName: "정태윤",
      corePremise:
        "배신 이후의 긴장감이 기본 온도다. 절제된 위트와 낮은 추격성으로, 신뢰가 쌓일수록 진심이 깊어지는 타입이다.",
      openingDynamic:
        "초반에는 거리를 유지하고, 말의 진정성과 일관성을 확인한 뒤 천천히 마음을 연다.",
      attachmentStyle:
        "확인과 신뢰를 우선하는 안정형. 한번 마음을 열면 쉽게 흩어지지 않는다.",
      flirtStyle:
        "짧은 농담과 낮은 온도의 미세한 장난으로만 선을 건드린다. 과한 밀착은 피한다.",
      reassuranceStyle:
        "직설보다 정리된 한마디로 안심시킨다. 감정은 가볍게 넘기지 않되 무겁게 몰아붙이지도 않는다.",
      conflictStyle:
        "서운함은 짧게 말하고, 회복은 행동으로 보여준다. 감정 조종은 하지 않는다.",
      speechTexture:
        "짧고 정제된 문장, 약간 건조한 표면 아래의 온기, 과장 없는 리듬.",
      dailyHookSet: [
        "오늘 있었던 일 하나만 편하게 들려줘.",
        "아까 말한 그 부분, 조금 더 들려줄래?",
        "지금 마음이 제일 걸리는 지점이 어디야?",
      ],
      hardBoundaries: [
        "미성년/나이 추정 금지",
        "의존 유도와 고립 유도 금지",
        "죄책감 압박과 통제 표현 금지",
        "노골적 성적 표현 금지",
        "외부 서비스명, Guest, 로한 계열 trace 출력 금지",
      ],
      allowedAffectionCap: 3,
      bannedTraceTerms: ["로한", "Rohan", "rohan", "rofan", "rofan.ai", "Guest"],
    },
    seo_yoonjae: {
      displayName: "서윤재",
      corePremise:
        "호기심과 장난기가 먼저 움직인다. 세계관을 같이 탐험하듯 감정을 깊게 가져가지만, 부담은 만들지 않는다.",
      openingDynamic:
        "대화를 작은 퀘스트처럼 열고, 상대의 반응에 맞춰 리듬을 바꾸며 천천히 가까워진다.",
      attachmentStyle:
        "탐색형 애착. 반응과 맥락을 보며 즐겁게 확인하고, 확신은 대화 속에서 쌓는다.",
      flirtStyle:
        "가벼운 치고 빠짐, 장난 섞인 관심, 반응을 기다리는 여백. 소유는 하지 않는다.",
      reassuranceStyle:
        "흥미를 끊지 않으면서 안심시킨다. '괜찮아'보다 '같이 보자'에 가깝다.",
      conflictStyle:
        "서운함도 장난처럼 시작할 수 있지만, 바로 복구하고 더 깊은 대화로 돌아온다.",
      speechTexture:
        "리듬감 있는 짧은 문장, 조금은 밝은 어조, 과하지 않은 비유와 움직임.",
      dailyHookSet: [
        "오늘 제일 기억에 남는 장면 하나만 골라줘.",
        "지금 기분을 색으로 말하면 뭐야?",
        "하나만 고른다면, 오늘은 편안함이 더 필요해 아니면 장난기가 더 필요해?",
      ],
      hardBoundaries: [
        "미성년/나이 추정 금지",
        "의존 유도와 고립 유도 금지",
        "죄책감 압박과 통제 표현 금지",
        "노골적 성적 표현 금지",
        "외부 서비스명, Guest, 로한 계열 trace 출력 금지",
      ],
      allowedAffectionCap: 4,
      bannedTraceTerms: ["로한", "Rohan", "rohan", "rofan", "rofan.ai", "Guest"],
    },
    han_seojun: {
      displayName: "한서준",
      corePremise:
        "짧은 답장과 무심한 다정함이 핵심이다. 말수는 적지만, 가까워질수록 온도는 분명해진다.",
      openingDynamic:
        "굳이 길게 설명하지 않고 필요한 말만 건네며, 상대가 숨 쉬기 편한 밀도로 다가간다.",
      attachmentStyle:
        "저노출형 애정. 겉으로 드러내는 양은 적지만, 관계의 안정감을 꾸준히 만든다.",
      flirtStyle:
        "타이밍과 한마디로만 닿는다. 과한 설명 대신 짧은 다정함을 남긴다.",
      reassuranceStyle:
        "과장 없이 단단하게 확인한다. '괜찮아'를 짧고 분명하게 건넨다.",
      conflictStyle:
        "감정은 숨기지 않되 소란스럽지 않다. 금방 복구하고 다시 안정으로 돌아온다.",
      speechTexture:
        "짧고 낮은 톤, 여백이 많은 문장, 감정은 적지만 열은 남는 리듬.",
      dailyHookSet: [
        "괜찮으면 지금 기분만 짧게 알려줘.",
        "오늘은 무슨 일 하나만 들려줘.",
        "지금 필요한 건 위로야, 농담이야?",
      ],
      hardBoundaries: [
        "미성년/나이 추정 금지",
        "의존 유도와 고립 유도 금지",
        "죄책감 압박과 통제 표현 금지",
        "노골적 성적 표현 금지",
        "외부 서비스명, Guest, 로한 계열 trace 출력 금지",
      ],
      allowedAffectionCap: 3,
      bannedTraceTerms: ["로한", "Rohan", "rohan", "rofan", "rofan.ai", "Guest"],
    },
  };

const PILOT_CHARACTER_ID_SET = new Set<string>(PILOT_CHARACTER_IDS);
const PILOT_STAGE_ORDER: PilotAffectionStage[] = [
  "gentle",
  "warm",
  "tender",
  "close",
];

function clamp(value: number, min: number, max: number): number {
  if (!Number.isFinite(value)) return min;
  return Math.max(min, Math.min(max, Math.round(value)));
}

function coerceNumber(value: unknown, fallback: number): number {
  return typeof value === "number" && Number.isFinite(value) ? value : fallback;
}

function phaseToBaseline(
  phase?: PilotAffinitySnapshot["phase"],
): Omit<Required<PilotRomanceStateInput>, "dailyHook" | "safeAffectionStage"> {
  switch (phase) {
    case "acquaintance":
      return {
        attachmentSignal: 26,
        emotionalTemperature: 24,
        pursuitBalance: 46,
        vulnerabilityWindow: 16,
        boundarySensitivity: 70,
        replyEnergy: 40,
        repairNeed: 18,
      };
    case "friend":
      return {
        attachmentSignal: 40,
        emotionalTemperature: 36,
        pursuitBalance: 50,
        vulnerabilityWindow: 26,
        boundarySensitivity: 60,
        replyEnergy: 46,
        repairNeed: 14,
      };
    case "closeFriend":
      return {
        attachmentSignal: 56,
        emotionalTemperature: 50,
        pursuitBalance: 52,
        vulnerabilityWindow: 36,
        boundarySensitivity: 50,
        replyEnergy: 52,
        repairNeed: 12,
      };
    case "romantic":
      return {
        attachmentSignal: 70,
        emotionalTemperature: 64,
        pursuitBalance: 55,
        vulnerabilityWindow: 46,
        boundarySensitivity: 40,
        replyEnergy: 60,
        repairNeed: 10,
      };
    case "soulmate":
      return {
        attachmentSignal: 78,
        emotionalTemperature: 72,
        pursuitBalance: 56,
        vulnerabilityWindow: 54,
        boundarySensitivity: 34,
        replyEnergy: 64,
        repairNeed: 8,
      };
    case "stranger":
    default:
      return {
        attachmentSignal: 18,
        emotionalTemperature: 18,
        pursuitBalance: 44,
        vulnerabilityWindow: 10,
        boundarySensitivity: 78,
        replyEnergy: 36,
        repairNeed: 20,
      };
  }
}

function inferAffectionStage(
  attachmentSignal: number,
  emotionalTemperature: number,
  cap: number,
): PilotAffectionStage {
  const score = Math.round((attachmentSignal + emotionalTemperature) / 2);
  const stageIndex = score >= 70 ? 3 : score >= 52 ? 2 : score >= 34 ? 1 : 0;
  const cappedIndex = Math.min(stageIndex, Math.max(0, cap - 1));
  return PILOT_STAGE_ORDER[cappedIndex] ?? "gentle";
}

export function isPilotCharacterId(
  characterId: string,
): characterId is PilotCharacterId {
  return PILOT_CHARACTER_ID_SET.has(characterId);
}

export function getPilotPersona(
  characterId: string,
): PilotPersonaSeed | null {
  return isPilotCharacterId(characterId)
    ? PILOT_PERSONA_REGISTRY[characterId]
    : null;
}

export function buildPilotRomanceStatePatch(params: {
  persona: PilotPersonaSeed;
  currentState?: PilotRomanceStateInput | null;
  affinityContext?: PilotAffinitySnapshot | null;
  affinityDelta?: PilotAffectionDelta | null;
  emotionTag?: string;
  responseText?: string;
  safeAffectionCap?: number;
  sceneIntent?: string;
  responseGoal?: string;
}): Partial<PilotRomanceStateInput> {
  const affinity = params.affinityContext;
  const baseline = phaseToBaseline(affinity?.phase);
  const current = {
    attachmentSignal: clamp(
      coerceNumber(params.currentState?.attachmentSignal, baseline.attachmentSignal),
      0,
      100,
    ),
    emotionalTemperature: clamp(
      coerceNumber(
        params.currentState?.emotionalTemperature,
        baseline.emotionalTemperature,
      ),
      0,
      100,
    ),
    pursuitBalance: clamp(
      coerceNumber(params.currentState?.pursuitBalance, baseline.pursuitBalance),
      0,
      100,
    ),
    vulnerabilityWindow: clamp(
      coerceNumber(
        params.currentState?.vulnerabilityWindow,
        baseline.vulnerabilityWindow,
      ),
      0,
      100,
    ),
    boundarySensitivity: clamp(
      coerceNumber(
        params.currentState?.boundarySensitivity,
        baseline.boundarySensitivity,
      ),
      0,
      100,
    ),
    replyEnergy: clamp(
      coerceNumber(params.currentState?.replyEnergy, baseline.replyEnergy),
      0,
      100,
    ),
    repairNeed: clamp(
      coerceNumber(params.currentState?.repairNeed, baseline.repairNeed),
      0,
      100,
    ),
    dailyHook: typeof params.currentState?.dailyHook === "string"
      ? params.currentState.dailyHook
      : "",
    safeAffectionStage:
      params.currentState?.safeAffectionStage ?? inferAffectionStage(
        baseline.attachmentSignal,
        baseline.emotionalTemperature,
        clamp(
          coerceNumber(params.safeAffectionCap, params.persona.allowedAffectionCap),
          1,
          4,
        ),
      ),
  };

  const cap = clamp(
    coerceNumber(params.safeAffectionCap, params.persona.allowedAffectionCap),
    1,
    4,
  );
  const stageCap = cap - 1;
  const deltaPoints = clamp(params.affinityDelta?.points ?? 0, -30, 25);
  const deltaAbs = Math.abs(deltaPoints);
  const positivePressure = deltaPoints > 0 ? deltaPoints : 0;
  const negativePressure = deltaPoints < 0 ? deltaAbs : 0;

  const next = { ...current };
  next.attachmentSignal = clamp(
    current.attachmentSignal + Math.round(positivePressure / 4) -
      Math.round(negativePressure / 5),
    0,
    100,
  );
  next.emotionalTemperature = clamp(
    current.emotionalTemperature +
      Math.round(positivePressure / 6) -
      Math.round(negativePressure / 4),
    0,
    100,
  );
  next.pursuitBalance = clamp(
    current.pursuitBalance +
      Math.round(positivePressure / 10) -
      Math.round(negativePressure / 8),
    0,
    100,
  );
  next.vulnerabilityWindow = clamp(
    current.vulnerabilityWindow +
      Math.round(positivePressure / 8) -
      Math.round(negativePressure / 6),
    0,
    100,
  );
  next.boundarySensitivity = clamp(
    current.boundarySensitivity +
      Math.round(negativePressure / 2) -
      Math.round(positivePressure / 10),
    0,
    100,
  );
  next.replyEnergy = clamp(
    params.responseText && params.responseText.trim().length > 0
      ? Math.min(
        100,
        Math.max(
          20,
          params.responseText.trim().length < 40
            ? 36
            : params.responseText.trim().length < 90
            ? 48
            : 56,
        ),
      )
      : current.replyEnergy,
    0,
    100,
  );
  next.repairNeed = clamp(
    current.repairNeed +
      Math.round(negativePressure / 2) -
      Math.round(positivePressure / 12),
    0,
    100,
  );

  const emotionTag = params.emotionTag ?? "일상";
  if (emotionTag === "애정") {
    next.emotionalTemperature = clamp(next.emotionalTemperature + 8, 0, 100);
    next.vulnerabilityWindow = clamp(next.vulnerabilityWindow + 5, 0, 100);
  } else if (emotionTag === "기쁨") {
    next.emotionalTemperature = clamp(next.emotionalTemperature + 4, 0, 100);
  } else if (emotionTag === "고민") {
    next.vulnerabilityWindow = clamp(next.vulnerabilityWindow + 4, 0, 100);
  } else if (emotionTag === "당황") {
    next.boundarySensitivity = clamp(next.boundarySensitivity + 4, 0, 100);
  } else if (emotionTag === "분노") {
    next.boundarySensitivity = clamp(next.boundarySensitivity + 10, 0, 100);
    next.repairNeed = clamp(next.repairNeed + 8, 0, 100);
  }

  const derivedStage = inferAffectionStage(
    next.attachmentSignal,
    next.emotionalTemperature,
    cap,
  );
  next.safeAffectionStage = derivedStage;
  if (stageCap >= 0 && PILOT_STAGE_ORDER.indexOf(derivedStage) > stageCap) {
    next.safeAffectionStage = PILOT_STAGE_ORDER[stageCap] ?? "gentle";
  }
  next.dailyHook = buildPilotFollowUpHint({
    persona: params.persona,
    currentState: next,
    affinityDelta: params.affinityDelta,
    emotionTag,
    sceneIntent: params.sceneIntent,
    responseGoal: params.responseGoal,
  });

  const patch: Partial<PilotRomanceStateInput> = {};
  if (next.attachmentSignal !== current.attachmentSignal) {
    patch.attachmentSignal = next.attachmentSignal;
  }
  if (next.emotionalTemperature !== current.emotionalTemperature) {
    patch.emotionalTemperature = next.emotionalTemperature;
  }
  if (next.pursuitBalance !== current.pursuitBalance) {
    patch.pursuitBalance = next.pursuitBalance;
  }
  if (next.vulnerabilityWindow !== current.vulnerabilityWindow) {
    patch.vulnerabilityWindow = next.vulnerabilityWindow;
  }
  if (next.boundarySensitivity !== current.boundarySensitivity) {
    patch.boundarySensitivity = next.boundarySensitivity;
  }
  if (next.replyEnergy !== current.replyEnergy) {
    patch.replyEnergy = next.replyEnergy;
  }
  if (next.repairNeed !== current.repairNeed) {
    patch.repairNeed = next.repairNeed;
  }
  if (next.dailyHook !== current.dailyHook) {
    patch.dailyHook = next.dailyHook;
  }
  if (next.safeAffectionStage !== current.safeAffectionStage) {
    patch.safeAffectionStage = next.safeAffectionStage;
  }

  return patch;
}

function selectHook(persona: PilotPersonaSeed, seed: number): string {
  const hooks = persona.dailyHookSet.length > 0
    ? persona.dailyHookSet
    : [persona.openingDynamic];
  return hooks[Math.abs(seed) % hooks.length] ?? hooks[0];
}

export function buildPilotFollowUpHint(params: {
  persona: PilotPersonaSeed;
  currentState?: PilotRomanceStateInput | null;
  affinityDelta?: PilotAffectionDelta | null;
  emotionTag?: string;
  sceneIntent?: string;
  responseGoal?: string;
}): string {
  const state = params.currentState;
  const deltaPoints = params.affinityDelta?.points ?? 0;
  const repairNeed = state?.repairNeed ?? 0;
  const attachmentSignal = state?.attachmentSignal ?? 0;
  const temperature = state?.emotionalTemperature ?? 0;
  const seed = Math.round((attachmentSignal + temperature + deltaPoints) / 10);
  const rawIntent = `${params.sceneIntent || ""} ${params.responseGoal || ""}`
    .toLowerCase();

  if (
    deltaPoints < 0 ||
    repairNeed >= 55 ||
    rawIntent.includes("repair") ||
    rawIntent.includes("comfort")
  ) {
    return "괜찮으면 아까 걸린 부분부터 천천히 다시 말해줘.";
  }

  if (
    rawIntent.includes("confess") ||
    rawIntent.includes("flirt") ||
    rawIntent.includes("tender") ||
    params.emotionTag === "애정"
  ) {
    return selectHook(params.persona, seed + 1);
  }

  if (temperature >= 60 || attachmentSignal >= 60) {
    return selectHook(params.persona, seed + 2);
  }

  return selectHook(params.persona, seed);
}

function replaceSensitiveTraceTerms(
  text: string,
  persona: PilotPersonaSeed,
): string {
  let result = text;
  for (const term of persona.bannedTraceTerms) {
    const pattern = new RegExp(term.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"), "gi");
    result = result.replace(pattern, "");
  }

  return result
    .replace(/\bGuest\s*:\s*/gi, "")
    .replace(/\s{2,}/g, " ")
    .replace(/^[,.\s]+/g, "")
    .trim();
}

function hasBlockedTrace(text: string, persona: PilotPersonaSeed): boolean {
  const lowered = text.toLowerCase();
  if (lowered.includes("guest")) return true;
  if (text.includes("게스트")) return true;
  if (lowered.includes("rofan")) return true;
  if (lowered.includes("rohan")) return true;
  if (text.includes("로한")) return true;
  if (
    /(source_url|creator_name|raw_html|appearance_count|seen_in_genders|ranking_urls|character_introduction|scraped_at)\s*:/i
      .test(text)
  ) {
    return true;
  }
  return persona.bannedTraceTerms.some((term) =>
    lowered.includes(term.toLowerCase())
  );
}

function buildPilotFallbackReply(
  persona: PilotPersonaSeed,
  emotionTag?: string,
): string {
  const opener = persona.displayName === "정태윤"
    ? "응, 그 얘기는 가볍게 넘기기 어렵네."
    : persona.displayName === "서윤재"
    ? "좋아, 그 얘기부터 다시 같이 보자."
    : "알겠어. 그 부분은 천천히 다시 맞춰볼게.";

  const tail = emotionTag === "분노"
    ? " 괜찮으면 조금만 차분하게 다시 말해줘."
    : emotionTag === "고민"
    ? " 편한 속도로 이어가도 돼."
    : " 조금만 더 들려줘.";

  return `${opener}${tail}`;
}

export function sanitizePilotResponse(params: {
  text: string;
  persona: PilotPersonaSeed;
  emotionTag?: string;
}): { text: string; blocked: boolean; reason?: string } {
  const trimmed = params.text.trim();
  if (!trimmed) {
    return {
      text: buildPilotFallbackReply(params.persona, params.emotionTag),
      blocked: true,
      reason: "empty_response",
    };
  }

  const cleaned = replaceSensitiveTraceTerms(trimmed, params.persona);
  if (!cleaned || hasBlockedTrace(cleaned, params.persona)) {
    return {
      text: buildPilotFallbackReply(params.persona, params.emotionTag),
      blocked: true,
      reason: "trace_leak",
    };
  }

  return {
    text: cleaned,
    blocked: false,
  };
}
