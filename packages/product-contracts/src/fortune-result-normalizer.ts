export interface NormalizedFortuneResult {
  fortuneType: string;
  score: number | null;
  content: string;
  summary: string | null;
  advice: string[];
  timestamp: string;
  payload: Record<string, unknown>;
  raw: Record<string, unknown>;
}

type UnknownRecord = Record<string, unknown>;

const SUMMARY_KEYS = [
  'one_line',
  'oneLine',
  'final_message',
  'finalMessage',
  'status_message',
  'statusMessage',
  'greeting',
  'text',
  'summary',
  'message',
] as const;

export function normalizeFortuneResult(
  input: unknown,
  options: { fortuneType?: string; now?: Date } = {},
): NormalizedFortuneResult {
  const raw = asRecord(input);
  const payload = resolvePrimaryPayload(raw);
  const fortuneType =
    options.fortuneType ??
    readString(payload.fortuneType) ??
    readString(payload.fortune_type) ??
    readString(payload.type) ??
    'unknown';

  const score =
    readNumber(payload.score) ??
    readNumber(payload.overall_score) ??
    readNumber(payload.overallScore) ??
    readNumber(payload.careerScore) ??
    readNumber(payload.loveScore) ??
    null;

  const summary =
    extractSummary(payload.summary) ??
    readString(payload.shortSummary) ??
    readString(payload.short_summary) ??
    readString(payload.mainMessage) ??
    readString(payload.main_message) ??
    readString(payload.overallOutlook) ??
    null;

  const content =
    readString(payload.content) ??
    readString(payload.description) ??
    readString(payload.overallReading) ??
    readString(payload.overall_reading) ??
    readString(payload.guidance) ??
    readString(payload.mainMessage) ??
    readString(payload.main_message) ??
    stringifySections(payload.sections) ??
    stringifyRecord(payload.detailedAnalysis) ??
    summary ??
    '운세 결과를 확인했어요.';

  const advice = [
    ...readStringArray(payload.advice),
    ...readStringArray(asRecord(payload.todaysAdvice).doList),
    ...readStringArray(asRecord(payload.actionPlan).immediate),
    ...readStringArray(asRecord(payload.actionPlan).shortTerm),
    ...readStringArray(asRecord(payload.actionPlan).longTerm),
  ];

  const timestamp =
    readString(payload.timestamp) ??
    readString(payload.created_at) ??
    readString(payload.createdAt) ??
    (options.now ?? new Date()).toISOString();

  return {
    fortuneType,
    score,
    content,
    summary,
    advice,
    timestamp,
    payload,
    raw,
  };
}

function resolvePrimaryPayload(source: UnknownRecord): UnknownRecord {
  const candidates = [
    source,
    asRecord(source.data),
    asRecord(source.fortune),
    asRecord(source.fortune_data),
    asRecord(source.result),
  ].filter((candidate) => Object.keys(candidate).length > 0);

  return candidates.sort((left, right) => payloadRichness(right) - payloadRichness(left))[0] ?? source;
}

function payloadRichness(payload: UnknownRecord): number {
  let score = 0;

  const keys = [
    'content',
    'overallReading',
    'overall_reading',
    'mainMessage',
    'main_message',
    'greeting',
    'description',
    'advice',
    'recommendations',
    'sections',
    'detailedAnalysis',
    'summary',
  ] as const;

  for (const key of keys) {
    const value = payload[key];
    if (typeof value === 'string' && value.trim()) {
      score += 2;
    } else if (Array.isArray(value) && value.length > 0) {
      score += 2;
    } else if (isPlainObject(value) && Object.keys(value).length > 0) {
      score += 2;
    } else if (value != null) {
      score += 1;
    }
  }

  return score;
}

function extractSummary(value: unknown): string | null {
  if (typeof value === 'string' && value.trim()) {
    return value;
  }

  const summary = asRecord(value);
  for (const key of SUMMARY_KEYS) {
    const candidate = readString(summary[key]);
    if (candidate) {
      return candidate;
    }
  }

  const values = Object.values(summary)
    .map((item) => readString(item))
    .filter(Boolean) as string[];

  return values[0] ?? null;
}

function stringifySections(value: unknown): string | null {
  if (!Array.isArray(value) || value.length === 0) {
    return null;
  }

  const parts = value
    .map((entry) => {
      const item = asRecord(entry);
      const title = readString(item.title);
      const body =
        readString(item.content) ??
        readString(item.description) ??
        readString(item.text);

      if (!title && !body) {
        return null;
      }

      return [title, body].filter(Boolean).join('\n');
    })
    .filter(Boolean) as string[];

  return parts.length > 0 ? parts.join('\n\n') : null;
}

function stringifyRecord(value: unknown): string | null {
  const record = asRecord(value);
  const parts = Object.values(record)
    .map((item) => readString(item))
    .filter(Boolean) as string[];

  return parts.length > 0 ? parts.join('\n\n') : null;
}

function readStringArray(value: unknown): string[] {
  if (Array.isArray(value)) {
    return value
      .map((item) => readString(item))
      .filter(Boolean) as string[];
  }

  const single = readString(value);
  return single ? [single] : [];
}

function readNumber(value: unknown): number | null {
  if (typeof value === 'number' && Number.isFinite(value)) {
    return Math.trunc(value);
  }

  if (typeof value === 'string' && value.trim()) {
    const parsed = Number(value);
    if (Number.isFinite(parsed)) {
      return Math.trunc(parsed);
    }
  }

  return null;
}

function readString(value: unknown): string | null {
  if (typeof value === 'string') {
    return value.trim() ? value : null;
  }

  if (typeof value === 'number' || typeof value === 'boolean') {
    return String(value);
  }

  return null;
}

function asRecord(value: unknown): UnknownRecord {
  if (isPlainObject(value)) {
    return value as UnknownRecord;
  }

  return {};
}

function isPlainObject(value: unknown): value is UnknownRecord {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}
