/**
 * process-long-running-jobs handler 등록부.
 *
 * job_type 별로 LLM 호출 + 결과 cardPayload 빌드를 담당하는 handler 를 export.
 * worker (index.ts) 가 dispatch 키로 사용. Phase D 에서 tarot/dream/compatibility/
 * traditional-saju handler 를 추가 등록한다.
 *
 * Handler contract:
 *   - 입력: { job, admin (service-role client), supabaseUrl, serviceKey }
 *   - 출력: LongRunningJobOutcome
 *     - cardPayload: 클라이언트 ChatShellEmbeddedResultMessage 형식 객체
 *       (id 는 `result-{job.id}` 권장, 멱등성 확보).
 *     - previewText (선택): 옛 클라 fallback 용 한 줄 미리보기.
 *     - pushBody (선택): push 본문. 미지정 시 worker default 사용.
 *     - result (선택): long_running_jobs.result 컬럼에 저장할 JSON
 *       (디버깅/audit 용 — 실제 표시는 cardPayload).
 *   - throw 하면 worker 가 status=failed 처리 + 사용자 실패 메시지 INSERT.
 */

import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

export interface LongRunningJobRow {
  id: string;
  user_id: string;
  character_id: string;
  character_name: string;
  job_type: string;
  payload: Record<string, unknown>;
  retry_count: number;
}

export interface LongRunningJobHandlerInput {
  job: LongRunningJobRow;
  admin: SupabaseClient;
  supabaseUrl: string;
  serviceKey: string;
}

export interface LongRunningJobCardPayload {
  id: string;
  kind: string;
  sender: "assistant";
  embeddedWidgetType: "fortune_result_card";
  fortuneType: string;
  resultKind: string;
  title: string;
  payload: Record<string, unknown>;
}

export interface LongRunningJobOutcome {
  cardPayload: LongRunningJobCardPayload;
  previewText?: string;
  pushBody?: string;
  result?: Record<string, unknown>;
}

export type LongRunningJobHandler = (
  input: LongRunningJobHandlerInput,
) => Promise<LongRunningJobOutcome>;

/**
 * job_type 별 운세 라벨 + resultKind + 위임할 fortune Edge Function 정보.
 * 4개 텍스트-운세는 모두 동일 패턴 — 기존 fortune-* 엔드포인트로 위임 + 응답을
 * cardPayload 로 감싸기. 따라서 1 함수로 일반화 가능.
 *
 * resultKind 는 RN `apps/mobile-rn/src/features/fortune-results/mapping.ts` 의
 * resolveResultKindFromFortuneType 매핑과 일치해야 한다 — 클라가 카드를 어떤
 * 결과 컴포넌트로 렌더할지 결정.
 */
const TEXT_FORTUNE_REGISTRY: Record<
  string,
  {
    endpoint: string;
    resultKind: string;
    label: string;
    eyebrow: string;
    subtitle: string;
    pushBody?: string;
  }
> = {
  tarot: {
    endpoint: "/fortune-tarot",
    resultKind: "tarot",
    label: "타로",
    eyebrow: "오늘의 카드 흐름",
    subtitle: "카드 3장이 들려주는 흐름과 행동 힌트",
  },
  dream: {
    endpoint: "/fortune-dream",
    // dream 결과 화면이 tarot UI 를 재사용 (mapping.ts 의 dream→tarot 매핑).
    resultKind: "tarot",
    label: "꿈 해몽",
    eyebrow: "오늘의 꿈 메시지",
    subtitle: "꿈이 전하는 상징과 오늘의 지침",
  },
  compatibility: {
    endpoint: "/fortune-compatibility",
    resultKind: "compatibility",
    label: "궁합",
    eyebrow: "오늘의 궁합 흐름",
    subtitle: "두 사람의 리듬과 관계 포인트",
  },
  "traditional-saju": {
    endpoint: "/fortune-traditional-saju",
    resultKind: "traditional-saju",
    label: "전통 사주",
    eyebrow: "오늘의 사주 흐름",
    subtitle: "사주가 짚어주는 핵심 균형과 조언",
  },
};

// ---------------------------------------------------------------------------
// fortune-* 응답 → EmbeddedResultPayload 정규화 helpers (Deno-friendly).
//
// 클라 동기 경로 (edge-runtime.ts) 는 normalizeFortuneResult +
// buildEmbeddedResultPayloadFromNormalizedResult 로 정규화하지만, 비동기
// 워커는 이를 호출할 수 없어 (RN-only deps) Deno 측에서 같은 모양의 payload
// 를 직접 빚는다. ResultCardFrame / Hero* 가 직접 읽는 필드만 채우면 OK.
// ---------------------------------------------------------------------------

const SAJU_ELEMENT_KO_TO_EN: Record<string, string> = {
  목: "wood",
  화: "fire",
  토: "earth",
  금: "metal",
  수: "water",
};
const SAJU_STEM_TO_EL: Record<string, string> = {
  甲: "wood",
  乙: "wood",
  丙: "fire",
  丁: "fire",
  戊: "earth",
  己: "earth",
  庚: "metal",
  辛: "metal",
  壬: "water",
  癸: "water",
};
const SAJU_BRANCH_TO_EL: Record<string, string> = {
  子: "water",
  丑: "earth",
  寅: "wood",
  卯: "wood",
  辰: "earth",
  巳: "fire",
  午: "fire",
  未: "earth",
  申: "metal",
  酉: "metal",
  戌: "earth",
  亥: "water",
};

function clip(s: unknown, n: number): string {
  const str = typeof s === "string" ? s.trim() : "";
  if (!str) return "";
  return str.length > n ? `${str.slice(0, n - 1)}…` : str;
}

function asStringArray(v: unknown, max = 6): string[] {
  if (!Array.isArray(v)) return [];
  return v
    .map((x) => (typeof x === "string" ? x.trim() : ""))
    .filter((x) => x.length > 0)
    .slice(0, max);
}

function buildBasePayload(
  fortuneType: string,
  resultKind: string,
  entry: { eyebrow: string; subtitle: string; label: string },
  generatedAt: string,
  raw: Record<string, unknown>,
): Record<string, unknown> {
  return {
    widgetType: "fortune_result_card",
    kind: resultKind,
    fortuneType,
    resultKind,
    eyebrow: entry.eyebrow,
    title: entry.label,
    subtitle: entry.subtitle,
    summary: "",
    generatedAt,
    rawApiResponse: raw,
  };
}

function normalizeTarotPayload(
  raw: Record<string, unknown>,
  base: Record<string, unknown>,
): Record<string, unknown> {
  const cards = Array.isArray(raw.cards)
    ? (raw.cards as Record<string, unknown>[])
    : [];
  const spread = cards.slice(0, 3).map((c) => ({
    name: typeof c.cardNameKr === "string" && c.cardNameKr
      ? c.cardNameKr
      : (c.cardName as string) ?? "",
    suit: typeof c.suit === "string" ? c.suit : undefined,
    position: typeof c.positionName === "string" ? c.positionName : undefined,
    meaning: typeof c.interpretation === "string"
      ? clip(c.interpretation, 200)
      : undefined,
  }));
  const interpretations = cards
    .map((
      c,
    ) => (typeof c.interpretation === "string"
      ? `${c.positionName ?? ""}: ${clip(c.interpretation, 180)}`
      : "")
    )
    .filter(Boolean);
  return {
    ...base,
    title: typeof raw.storyTitle === "string" && raw.storyTitle
      ? raw.storyTitle
      : base.title,
    summary: clip(raw.overallReading ?? raw.guidance, 220),
    score: typeof raw.energyLevel === "number" ? raw.energyLevel : undefined,
    spread,
    highlights: interpretations.slice(0, 3),
    recommendations: [
      typeof raw.advice === "string" ? raw.advice : "",
      typeof raw.guidance === "string" ? raw.guidance : "",
    ].filter(Boolean) as string[],
    luckyItems: asStringArray(raw.keyThemes, 4),
    specialTip: typeof raw.luckyElement === "string"
      ? `행운 원소: ${raw.luckyElement}`
      : undefined,
    contextTags: asStringArray(raw.focusAreas, 3),
  };
}

function normalizeDreamPayload(
  raw: Record<string, unknown>,
  base: Record<string, unknown>,
): Record<string, unknown> {
  // dream 은 tarot UI(spread)를 빌리지만 카드 데이터가 없으므로 spread 미설정.
  // HeroDream 은 motif 필드를 직접 읽음.
  const symbols = Array.isArray(raw.relatedSymbols)
    ? (raw.relatedSymbols as string[])
    : [];
  const motif = typeof raw.dreamType === "string" && raw.dreamType
    ? raw.dreamType
    : (symbols[0] ?? "바다");
  return {
    ...base,
    summary: clip(raw.interpretation ?? raw.summary, 220),
    score: typeof raw.score === "number" ? raw.score : undefined,
    motif,
    dreamMotif: motif,
    highlights: asStringArray(raw.luckyKeywords, 5),
    recommendations: asStringArray(raw.actionAdvice, 4),
    warnings: asStringArray(raw.avoidKeywords, 3),
    luckyItems: asStringArray(raw.affirmations, 3),
    specialTip: typeof raw.todayGuidance === "string"
      ? clip(raw.todayGuidance, 200)
      : undefined,
    contextTags: symbols.slice(0, 3),
  };
}

function normalizeCompatPayload(
  raw: Record<string, unknown>,
  base: Record<string, unknown>,
): Record<string, unknown> {
  const p1 = (raw.person1 ?? {}) as Record<string, unknown>;
  const p2 = (raw.person2 ?? {}) as Record<string, unknown>;
  const left = typeof p1.name === "string" && p1.name ? p1.name : "나";
  const right = typeof p2.name === "string" && p2.name ? p2.name : "상대";
  return {
    ...base,
    title: typeof raw.title === "string" && raw.title ? raw.title : base.title,
    summary: clip(raw.overall_compatibility ?? raw.summary, 220),
    score: typeof raw.score === "number" ? raw.score : undefined,
    compat: { leftLabel: left, rightLabel: right, metrics: [] },
    highlights: [
      typeof raw.personality_match === "string"
        ? clip(raw.personality_match, 180)
        : "",
      typeof raw.communication_match === "string"
        ? clip(raw.communication_match, 180)
        : "",
      typeof raw.love_match === "string" ? clip(raw.love_match, 180) : "",
    ].filter(Boolean) as string[],
    recommendations: asStringArray(raw.advice, 4),
    warnings: asStringArray(raw.cautions, 3),
    luckyItems: asStringArray(raw.strengths, 4),
    specialTip: typeof raw.compatibility_keyword === "string"
      ? raw.compatibility_keyword
      : undefined,
  };
}

function normalizeSajuPayload(
  raw: Record<string, unknown>,
  base: Record<string, unknown>,
  reqPayload: Record<string, unknown>,
): Record<string, unknown> {
  // saju 응답엔 pillars 가 없음 — 요청 본문 sajuData 에서 끌어옴.
  const sajuData = (reqPayload.sajuData ?? {}) as Record<string, unknown>;
  const pillarSrc = (sajuData.pillar ?? {}) as Record<string, unknown>;
  const pillarKeys: Array<[string, string]> = [
    ["year", "年"],
    ["month", "月"],
    ["day", "日"],
    ["time", "時"],
  ];
  const pillars = pillarKeys
    .map(([k, label]) => {
      const p = (pillarSrc[k] ?? {}) as Record<string, unknown>;
      const sky = typeof p.heavenlyStem === "string" ? p.heavenlyStem : "";
      const gnd = typeof p.earthlyBranch === "string" ? p.earthlyBranch : "";
      if (!sky && !gnd) return null;
      return {
        label,
        sky,
        gnd,
        skyEl: SAJU_STEM_TO_EL[sky] ?? "earth",
        gndEl: SAJU_BRANCH_TO_EL[gnd] ?? "earth",
      };
    })
    .filter(Boolean) as Array<Record<string, unknown>>;
  const elementsKo = (sajuData.elements ?? {}) as Record<string, unknown>;
  const elements: Record<string, number> = {};
  for (const [ko, en] of Object.entries(SAJU_ELEMENT_KO_TO_EN)) {
    const v = elementsKo[ko];
    if (typeof v === "number") elements[en] = Math.min(100, Math.max(0, v));
  }
  const sections = (raw.sections ?? {}) as Record<string, unknown>;
  return {
    ...base,
    summary: clip(raw.summary ?? sections.analysis ?? raw.content, 220),
    score: typeof raw.score === "number" ? raw.score : 75,
    pillars: pillars.length === 4 ? pillars : undefined,
    elements: Object.keys(elements).length > 0 ? elements : undefined,
    highlights: [
      typeof sections.analysis === "string" ? clip(sections.analysis, 200) : "",
      typeof sections.answer === "string" ? clip(sections.answer, 200) : "",
    ].filter(Boolean) as string[],
    recommendations: [
      typeof sections.advice === "string" ? clip(sections.advice, 200) : "",
      typeof raw.advice === "string" ? clip(raw.advice, 200) : "",
    ].filter(Boolean) as string[],
    specialTip: typeof sections.supplement === "string"
      ? clip(sections.supplement, 200)
      : undefined,
  };
}

function normalizeFortunePayload(
  fortuneType: string,
  raw: Record<string, unknown>,
  base: Record<string, unknown>,
  reqPayload: Record<string, unknown>,
): Record<string, unknown> {
  switch (fortuneType) {
    case "tarot":
      return normalizeTarotPayload(raw, base);
    case "dream":
      return normalizeDreamPayload(raw, base);
    case "compatibility":
      return normalizeCompatPayload(raw, base);
    case "traditional-saju":
      return normalizeSajuPayload(raw, base, reqPayload);
    default:
      return base;
  }
}

/**
 * 일반화된 텍스트 운세 worker.
 *
 * 흐름:
 *   1. job.payload 를 fortune-* Edge Function 에 그대로 forward.
 *   2. 응답을 rawApiResponse 에 박은 cardPayload 빌드.
 *   3. previewText / pushBody 도 동봉해 worker 가 INSERT/push 에 사용.
 *
 * 같은 fortune-* endpoint 가 동기 직접 호출 (edge-runtime.ts) 과 비동기 큐
 * (handler) 양쪽에서 동일하게 작동 — 내부 LLMFactory 로직은 두 호출자를 구분하지
 * 않으므로 안전.
 *
 * 인증 위임 — 두 갈래로 동작:
 *   1) `fortune-tarot`: deriveUserIdFromJwt 를 사용 → 본 worker 가 보내는
 *      service_role + X-Internal-User-Id 조합으로 위임 식별 (auth.ts 의 internal
 *      bypass).
 *   2) `fortune-dream` / `fortune-compatibility` / `fortune-traditional-saju`:
 *      현재 본문 `userId` 만 참조 (JWT 미사용). worker 가 forward 하는 `payload`
 *      에 buildFortuneRequestBody 가 이미 정확한 userId 를 박아두므로 동작 OK.
 *      단, 본 3개 endpoint 는 외부 직접 호출 시 body.userId 위조 가능한 기존
 *      문제를 그대로 보유 — 별도 PR 에서 deriveUserIdFromJwt 일원화 예정.
 */
async function handleTextFortuneJob(
  input: LongRunningJobHandlerInput,
): Promise<LongRunningJobOutcome> {
  const entry = TEXT_FORTUNE_REGISTRY[input.job.job_type];
  if (!entry) {
    throw new Error(`text fortune registry missing for ${input.job.job_type}`);
  }

  const url = `${input.supabaseUrl}/functions/v1${entry.endpoint}`;
  // Internal-worker 위임 헤더 — fortune-* 의 deriveUserIdFromJwt 가 이 두 헤더
  // 조합을 보고 user identity 를 X-Internal-User-Id 로 신뢰. 일반 클라이언트는
  // service_role 키를 보유하지 못하므로 위조 불가.
  const response = await fetch(url, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${input.serviceKey}`,
      "X-Internal-User-Id": input.job.user_id,
      "X-Internal-Worker": "process-long-running-jobs",
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      ...(input.job.payload ?? {}),
      serverChargeId: `long-running-job:${input.job.id}:${input.job.job_type}`,
    }),
  });

  if (!response.ok) {
    const errBody = await response.text();
    throw new Error(
      `${entry.endpoint} returned ${response.status}: ${errBody.slice(0, 300)}`,
    );
  }

  const apiData = (await response.json()) as Record<string, unknown>;

  // `data` 키가 있는 응답 (`{success, data: {...}}`) 도 있고 결과를 최상단에
  // 펼친 응답도 있어 둘 다 수용. RN edge-runtime.ts:177 와 동일 처리.
  const rawApiResponse =
    typeof apiData === "object" && apiData !== null && "data" in apiData
      ? ((apiData.data as Record<string, unknown>) ?? apiData)
      : apiData;

  const messageId = `result-${input.job.id}`;
  const generatedAt = new Date().toISOString();

  // 정규화: ResultCardFrame / Hero* 가 직접 읽는 필드 (eyebrow/title/summary/
  // score/spread/pillars/compat/...) 를 빚어 박는다. 빈 슬롯 + 뒷면 카드 더미
  // 렌더링 회피. rawApiResponse 도 디버깅/하위 컴포넌트 fallback 용 보존.
  const base = buildBasePayload(
    input.job.job_type,
    entry.resultKind,
    entry,
    generatedAt,
    rawApiResponse,
  );
  const normalizedPayload = normalizeFortunePayload(
    input.job.job_type,
    rawApiResponse,
    base,
    input.job.payload ?? {},
  );

  const cardPayload: LongRunningJobCardPayload = {
    id: messageId,
    kind: "embedded-result",
    sender: "assistant",
    embeddedWidgetType: "fortune_result_card",
    fortuneType: input.job.job_type,
    resultKind: entry.resultKind,
    title: entry.label,
    payload: normalizedPayload,
  };

  return {
    cardPayload,
    previewText: `[운세 결과 — ${entry.label}]`,
    pushBody: `${entry.label} 결과가 도착했어! 확인해봐 👀`,
    result: rawApiResponse,
  };
}

/**
 * job_type → handler 등록부.
 *
 * 4개 텍스트 운세 모두 같은 forward-and-wrap 패턴이라 단일 핸들러로 등록.
 * 향후 image-gen 등 다른 패턴이 추가되면 별도 함수로 분기.
 */
export const JOB_HANDLERS: Record<string, LongRunningJobHandler> = {
  tarot: handleTextFortuneJob,
  dream: handleTextFortuneJob,
  compatibility: handleTextFortuneJob,
  "traditional-saju": handleTextFortuneJob,
};
